import '../../core/database/app_database.dart';
import '../../domain/entities/product.dart';

/// Доступ к таблицам справочника (categories, products).
class CatalogLocalDataSource {
  CatalogLocalDataSource(this._db);
  final AppDatabase _db;

  Future<int> productCount() async {
    final db = await _db.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM products');
    return (rows.first['c'] as int?) ?? 0;
  }

  Future<void> seed(
    List<ProductCategory> categories,
    List<Product> products,
  ) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final c in categories) {
        batch.insert('categories', {
          'id': c.id,
          'name': c.name,
          'icon_id': c.iconId,
          'sort_order': c.sortOrder,
        });
      }
      for (final p in products) {
        batch.insert('products', {
          'id': p.id,
          'name': p.name,
          'category_id': p.categoryId,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<ProductCategory>> categories() async {
    final db = await _db.database;
    final rows = await db.query('categories', orderBy: 'sort_order ASC');
    return rows
        .map((r) => ProductCategory(
              id: r['id'] as String,
              name: r['name'] as String,
              iconId: r['icon_id'] as String,
              sortOrder: r['sort_order'] as int,
            ))
        .toList();
  }

  Future<List<Product>> products() async {
    final db = await _db.database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows
        .map((r) => Product(
              id: r['id'] as String,
              name: r['name'] as String,
              categoryId: r['category_id'] as String,
            ))
        .toList();
  }
}
