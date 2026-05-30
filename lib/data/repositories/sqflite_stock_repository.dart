import 'dart:async';

import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/services/quantity_math.dart';
import '../datasources/stock_local_data_source.dart';

/// Запасы в sqflite. Реактивность — через broadcast-поток, пересчитываемый
/// после каждой мутации.
class SqfliteStockRepository implements StockRepository {
  SqfliteStockRepository(this._dataSource);
  final StockLocalDataSource _dataSource;

  final _controller = StreamController<List<StockEntry>>.broadcast();

  @override
  Stream<List<StockEntry>> watchInventory() async* {
    yield await _dataSource.loadEntries();
    yield* _controller.stream;
  }

  @override
  Future<void> addBatch(StockEntry entry) async {
    await _dataSource.insertEntry(entry);
    await _emit();
  }

  @override
  Future<void> updateBatch(StockEntry entry) async {
    await _dataSource.updateEntry(entry);
    await _emit();
  }

  @override
  Future<void> applyUsage(String batchId, UsageEvent event) async {
    final entries = await _dataSource.loadEntries();
    final entry = entries.where((e) => e.id == batchId).firstOrNull;
    if (entry == null) return;

    final left = QuantityMath.reduceBy(
      entry.batch.quantity,
      QuantityMath.total(event.amount),
    );
    if (QuantityMath.isEmpty(left)) {
      await _dataSource.deleteBatch(batchId);
    } else {
      await _dataSource.insertUsage(batchId, event);
      await _dataSource.updateQuantity(batchId, left);
    }
    await _emit();
  }

  @override
  Future<void> discard(String batchId) async {
    await _dataSource.deleteBatch(batchId);
    await _emit();
  }

  Future<void> _emit() async => _controller.add(await _dataSource.loadEntries());
}
