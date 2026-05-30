import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';
import '../seed/sample_inventory.dart';

/// Временное хранилище в памяти с демо-данными. Заменим на sqflite-реализацию,
/// сохранив интерфейс [StockRepository].
class InMemoryStockRepository implements StockRepository {
  @override
  Future<List<StockEntry>> loadInventory() async {
    return buildSampleInventory(DateTime.now());
  }
}
