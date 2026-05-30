import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/quantity.dart';
import '../../domain/entities/stock.dart';
import '../../domain/entities/storage.dart';

/// Доступ к запасам и журналу (stock_batches, usage_events) с join на продукты
/// и категории. Сериализация Quantity — в плоские поля.
class StockLocalDataSource {
  StockLocalDataSource(this._db);
  final AppDatabase _db;

  Future<List<StockEntry>> loadEntries({bool usedUp = false}) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT b.*, p.name AS product_name, p.category_id AS product_category_id,
             c.name AS category_name, c.icon_id AS category_icon, c.sort_order AS category_sort
      FROM stock_batches b
      JOIN products p ON p.id = b.product_id
      JOIN categories c ON c.id = p.category_id
      WHERE b.used_up = ?
    ''', [usedUp ? 1 : 0]);

    final events = await db.query('usage_events', orderBy: 'timestamp ASC');
    final byBatch = <String, List<UsageEvent>>{};
    for (final e in events) {
      byBatch.putIfAbsent(e['batch_id'] as String, () => []).add(_eventFromRow(e));
    }

    return rows.map((r) {
      final product = Product(
        id: r['product_id'] as String,
        name: r['product_name'] as String,
        categoryId: r['product_category_id'] as String,
      );
      final category = ProductCategory(
        id: r['product_category_id'] as String,
        name: r['category_name'] as String,
        iconId: r['category_icon'] as String,
        sortOrder: r['category_sort'] as int,
      );
      final batch = StockBatch(
        id: r['id'] as String,
        productId: r['product_id'] as String,
        location: r['location'] as String,
        quantity: _quantityFromRow(r, 'qty_'),
        purchaseDate: _date(r['purchase_date']),
        expiryDate: _date(r['expiry_date']),
        openedDate: _date(r['opened_date']),
        note: r['note'] as String?,
        history: byBatch[r['id']] ?? const [],
      );
      return StockEntry(batch: batch, product: product, category: category);
    }).toList();
  }

  Future<void> insertEntry(StockEntry entry) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.insert('categories', {
        'id': entry.category.id,
        'name': entry.category.name,
        'icon_id': entry.category.iconId,
        'sort_order': entry.category.sortOrder,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('products', {
        'id': entry.product.id,
        'name': entry.product.name,
        'category_id': entry.product.categoryId,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert('stock_batches', _batchColumns(entry.batch));
    });
  }

  Future<void> updateEntry(StockEntry entry) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        'products',
        {'name': entry.product.name, 'category_id': entry.product.categoryId},
        where: 'id = ?',
        whereArgs: [entry.product.id],
      );
      final cols = _batchColumns(entry.batch)..remove('id')..remove('product_id');
      await txn.update(
        'stock_batches',
        cols,
        where: 'id = ?',
        whereArgs: [entry.batch.id],
      );
    });
  }

  Future<void> updateQuantity(String batchId, Quantity quantity) async {
    final db = await _db.database;
    await db.update(
      'stock_batches',
      _quantityColumns(quantity, 'qty_'),
      where: 'id = ?',
      whereArgs: [batchId],
    );
  }

  /// Помечает партию израсходованной (уходит в «Использованные», история цела).
  Future<void> markUsedUp(String batchId, Quantity finalQuantity) async {
    final db = await _db.database;
    await db.update(
      'stock_batches',
      {..._quantityColumns(finalQuantity, 'qty_'), 'used_up': 1},
      where: 'id = ?',
      whereArgs: [batchId],
    );
  }

  Future<void> insertUsage(String batchId, UsageEvent event) async {
    final db = await _db.database;
    await db.insert('usage_events', {
      'id': event.id,
      'batch_id': batchId,
      ..._quantityColumns(event.amount, 'amount_'),
      'reason': event.reason.name,
      'timestamp': event.timestamp.millisecondsSinceEpoch,
      'note': event.note,
    });
  }

  // --- пользовательские места хранения ---

  Future<List<String>> loadCustomLocations() async {
    final db = await _db.database;
    final rows = await db.query('custom_locations', orderBy: 'sort_order ASC');
    return [for (final r in rows) r['name'] as String];
  }

  Future<void> addCustomLocation(String name) async {
    final db = await _db.database;
    await db.insert(
      'custom_locations',
      {'name': name, 'sort_order': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> renameLocation(String from, String to) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('custom_locations', where: 'name = ?', whereArgs: [from]);
      await txn.insert(
        'custom_locations',
        {'name': to, 'sort_order': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.update('stock_batches', {'location': to},
          where: 'location = ?', whereArgs: [from]);
    });
  }

  Future<void> deleteCustomLocation(String name) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('custom_locations', where: 'name = ?', whereArgs: [name]);
      // Партии из удалённого места переносим в холодильник.
      await txn.update('stock_batches', {'location': StorageLocations.fridge},
          where: 'location = ?', whereArgs: [name]);
    });
  }

  /// Удаляет весь архив израсходованных партий вместе с их журналом.
  Future<void> clearUsedUp() async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final used = await txn.query('stock_batches',
          columns: ['id'], where: 'used_up = ?', whereArgs: [1]);
      final ids = [for (final r in used) r['id'] as String];
      if (ids.isEmpty) return;
      final marks = List.filled(ids.length, '?').join(',');
      await txn.delete('usage_events',
          where: 'batch_id IN ($marks)', whereArgs: ids);
      await txn.delete('stock_batches', where: 'used_up = ?', whereArgs: [1]);
    });
  }

  Future<void> deleteBatch(String batchId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('usage_events', where: 'batch_id = ?', whereArgs: [batchId]);
      await txn.delete('stock_batches', where: 'id = ?', whereArgs: [batchId]);
    });
  }

  // --- сериализация ---

  Map<String, Object?> _batchColumns(StockBatch b) => {
        'id': b.id,
        'product_id': b.productId,
        'location': b.location,
        ..._quantityColumns(b.quantity, 'qty_'),
        'purchase_date': b.purchaseDate?.millisecondsSinceEpoch,
        'expiry_date': b.expiryDate?.millisecondsSinceEpoch,
        'opened_date': b.openedDate?.millisecondsSinceEpoch,
        'note': b.note,
      };

  Map<String, Object?> _quantityColumns(Quantity q, String prefix) => {
        '${prefix}mode': 'measure',
        '${prefix}count': null,
        '${prefix}amount': q.amount,
        '${prefix}per_pack': null,
        '${prefix}unit': q.unit,
      };

  Quantity _quantityFromRow(Map<String, Object?> r, String prefix) => Quantity(
        amount: (r['${prefix}amount'] as num?)?.toDouble() ?? 0,
        unit: r['${prefix}unit'] as String? ?? 'шт',
      );

  UsageEvent _eventFromRow(Map<String, Object?> r) => UsageEvent(
        id: r['id'] as String,
        amount: _quantityFromRow(r, 'amount_'),
        reason: UsageReason.values.byName(r['reason'] as String),
        timestamp: DateTime.fromMillisecondsSinceEpoch(r['timestamp'] as int),
        note: r['note'] as String?,
      );

  DateTime? _date(Object? millis) =>
      millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis as int);
}
