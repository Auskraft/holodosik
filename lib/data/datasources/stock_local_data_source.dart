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
        location: StorageLocation.values.byName(r['location'] as String),
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
        'location': b.location.name,
        ..._quantityColumns(b.quantity, 'qty_'),
        'purchase_date': b.purchaseDate?.millisecondsSinceEpoch,
        'expiry_date': b.expiryDate?.millisecondsSinceEpoch,
        'opened_date': b.openedDate?.millisecondsSinceEpoch,
        'note': b.note,
      };

  Map<String, Object?> _quantityColumns(Quantity q, String prefix) {
    final base = {
      '${prefix}mode': '',
      '${prefix}count': null,
      '${prefix}amount': null,
      '${prefix}per_pack': null,
      '${prefix}unit': q.unit.name,
    };
    switch (q) {
      case CountQuantity(:final count):
        return {...base, '${prefix}mode': 'count', '${prefix}count': count};
      case WeightQuantity(:final amount):
        return {...base, '${prefix}mode': 'weight', '${prefix}amount': amount};
      case PacksQuantity(:final packs, :final perPack):
        return {
          ...base,
          '${prefix}mode': 'packs',
          '${prefix}count': packs,
          '${prefix}per_pack': perPack,
        };
    }
  }

  Quantity _quantityFromRow(Map<String, Object?> r, String prefix) {
    final unit = QtyUnit.values.byName(r['${prefix}unit'] as String);
    return switch (r['${prefix}mode'] as String) {
      'count' => CountQuantity(r['${prefix}count'] as int, unit: unit),
      'weight' => WeightQuantity((r['${prefix}amount'] as num).toDouble(), unit),
      'packs' => PacksQuantity(
          r['${prefix}count'] as int,
          (r['${prefix}per_pack'] as num).toDouble(),
          unit,
        ),
      _ => CountQuantity(0, unit: unit),
    };
  }

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
