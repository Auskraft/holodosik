import '../entities/stock.dart';

/// Доступ к запасам. Реализация — пока in-memory, позже sqflite (интерфейс
/// остаётся стабильным).
abstract interface class StockRepository {
  Future<List<StockEntry>> loadInventory();
}
