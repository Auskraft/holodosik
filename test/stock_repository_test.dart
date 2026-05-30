import 'package:flutter_test/flutter_test.dart';
import 'package:holodosik/core/database/app_database.dart';
import 'package:holodosik/data/datasources/stock_local_data_source.dart';
import 'package:holodosik/data/repositories/sqflite_stock_repository.dart';
import 'package:holodosik/domain/entities/product.dart';
import 'package:holodosik/domain/entities/quantity.dart';
import 'package:holodosik/domain/entities/stock.dart';
import 'package:holodosik/domain/entities/storage.dart';
import 'package:holodosik/domain/services/quantity_math.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  StockEntry sampleEntry() => const StockEntry(
        product: Product(id: 'p1', name: 'Молоко', categoryId: 'c1'),
        category: ProductCategory(id: 'c1', name: 'Молочное', iconId: 'dairy'),
        batch: StockBatch(
          id: 'b1',
          productId: 'p1',
          location: StorageLocation.fridge,
          quantity: WeightQuantity(500, QtyUnit.gram),
        ),
      );

  test('добавление, расход и списание партии', () async {
    final repo = SqfliteStockRepository(
      StockLocalDataSource(AppDatabase(path: inMemoryDatabasePath)),
    );

    await repo.addBatch(sampleEntry());
    var list = await repo.watchInventory().first;
    expect(list.length, 1);
    expect(QuantityMath.total(list.first.quantity), 500);

    await repo.applyUsage(
      'b1',
      UsageEvent(
        id: 'u1',
        amount: const WeightQuantity(200, QtyUnit.gram),
        reason: UsageReason.consumed,
        timestamp: DateTime(2026, 5, 30),
      ),
    );
    list = await repo.watchInventory().first;
    expect(QuantityMath.total(list.first.quantity), 300);
    expect(list.first.batch.history.length, 1);

    await repo.discard('b1');
    list = await repo.watchInventory().first;
    expect(list, isEmpty);
  });
}
