import '../../domain/entities/stock.dart';
import 'quantity_formatter.dart';

/// Текст списка для копирования/выгрузки: «Название | количество» построчно.
abstract final class ReportBuilder {
  static String build(List<StockEntry> entries) {
    return entries
        .map((e) => '${e.name} | ${QuantityFormatter.format(e.quantity)}')
        .join('\n');
  }
}
