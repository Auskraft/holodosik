import '../entities/stock.dart';

/// Доступ к запасам. Реактивный список + мутации. Реализация — пока in-memory,
/// позже sqflite (интерфейс остаётся стабильным).
abstract interface class StockRepository {
  /// Поток актуального списка запасов (обновляется после любой мутации).
  Stream<List<StockEntry>> watchInventory();

  /// Добавляет новую партию в запасы.
  Future<void> addBatch(StockEntry entry);

  /// Обновляет существующую партию (редактирование).
  Future<void> updateBatch(StockEntry entry);

  /// Расход: уменьшает остаток партии и пишет запись в журнал. Пустая партия
  /// уходит из активного списка.
  Future<void> applyUsage(String batchId, UsageEvent event);

  /// Списание партии (испортилось / выбросили).
  Future<void> discard(String batchId);

  /// Израсходованные партии (архив с историей).
  Future<List<StockEntry>> loadUsedUp();
}
