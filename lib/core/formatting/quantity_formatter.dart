import '../../domain/entities/quantity.dart';

/// Готовое представление количества: основная строка и (для упаковок) итог.
class FormattedQuantity {
  const FormattedQuantity(this.primary, {this.totalValue});
  final String primary;
  final String? totalValue;
}

/// Формат количества под три режима учёта. Чистая логика — без зависимостей от UI.
abstract final class QuantityFormatter {
  static FormattedQuantity format(Quantity q) {
    switch (q) {
      case CountQuantity(:final count, :final unit):
        return FormattedQuantity('$count ${unit.label}');
      case WeightQuantity(:final amount, :final unit):
        final (value, u) = _compress(amount, unit);
        return FormattedQuantity('${_num(value)} ${u.label}');
      case PacksQuantity(:final packs, :final perPack, :final unit):
        final (total, tu) = _compress(packs * perPack, unit);
        return FormattedQuantity(
          '$packs ${QtyUnit.pack.label} × ${_num(perPack)} ${unit.label}',
          totalValue: '${_num(total)} ${tu.label}',
        );
    }
  }

  /// Сжатие к крупной единице: ≥1000 г → кг, ≥1000 мл → л.
  static (double, QtyUnit) _compress(double value, QtyUnit unit) {
    if (unit == QtyUnit.gram && value >= 1000) return (value / 1000, QtyUnit.kilogram);
    if (unit == QtyUnit.milliliter && value >= 1000) return (value / 1000, QtyUnit.liter);
    return (value, unit);
  }

  /// Целое — без дробной части, дробное — с запятой.
  static String _num(double v) {
    if (v == v.truncateToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll('.', ',');
  }
}
