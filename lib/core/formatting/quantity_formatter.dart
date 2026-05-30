import '../../domain/entities/quantity.dart';

/// Формат количества: «500 г», «1,2 кг», «3 шт». Целое — без дробной части,
/// дробное — с запятой.
abstract final class QuantityFormatter {
  static String format(Quantity q) => '${number(q.amount)} ${q.unit}';

  static String number(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll('.', ',');
  }
}
