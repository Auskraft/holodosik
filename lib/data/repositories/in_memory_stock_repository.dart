import 'dart:async';

import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/services/quantity_math.dart';
import '../seed/sample_inventory.dart';

/// Временное хранилище в памяти с демо-данными. Заменим на sqflite-реализацию,
/// сохранив интерфейс [StockRepository].
class InMemoryStockRepository implements StockRepository {
  InMemoryStockRepository() {
    _entries = buildSampleInventory(DateTime.now());
  }

  late List<StockEntry> _entries;
  final _controller = StreamController<List<StockEntry>>.broadcast();

  @override
  Stream<List<StockEntry>> watchInventory() async* {
    yield _snapshot();
    yield* _controller.stream;
  }

  @override
  Future<void> addBatch(StockEntry entry) async {
    _entries.insert(0, entry);
    _emit();
  }

  @override
  Future<void> applyUsage(String batchId, UsageEvent event) async {
    final i = _entries.indexWhere((e) => e.batch.id == batchId);
    if (i < 0) return;
    final entry = _entries[i];
    final left = QuantityMath.reduceBy(
      entry.batch.quantity,
      QuantityMath.total(event.amount),
    );
    if (QuantityMath.isEmpty(left)) {
      _entries.removeAt(i);
    } else {
      _entries[i] = StockEntry(
        batch: entry.batch.copyWith(
          quantity: left,
          history: [...entry.batch.history, event],
        ),
        product: entry.product,
        category: entry.category,
      );
    }
    _emit();
  }

  @override
  Future<void> discard(String batchId) async {
    _entries.removeWhere((e) => e.batch.id == batchId);
    _emit();
  }

  List<StockEntry> _snapshot() => List.unmodifiable(_entries);
  void _emit() => _controller.add(_snapshot());
}
