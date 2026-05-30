import '../../domain/entities/stock.dart';
import 'quantity_formatter.dart';

/// Текст списка для копирования/выгрузки: «Название | количество» построчно.
abstract final class ReportBuilder {
  /// По текущему остатку партий.
  static String build(List<StockEntry> entries) {
    return entries
        .map((e) => '${e.name} | ${QuantityFormatter.format(e.quantity)}')
        .join('\n');
  }

  /// Для «Использованных»: показываем, сколько израсходовали (сумма по журналу).
  static String buildUsed(List<StockEntry> entries) {
    return entries.map((e) {
      final history = e.batch.history;
      final used = history.fold<double>(0, (s, ev) => s + ev.amount.amount);
      final unit = history.isNotEmpty ? history.last.amount.unit : e.quantity.unit;
      final qty = used > 0
          ? '${QuantityFormatter.number(used)} $unit'
          : QuantityFormatter.format(e.quantity);
      return '${e.name} | $qty';
    }).join('\n');
  }
}
