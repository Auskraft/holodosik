import 'package:equatable/equatable.dart';

/// Единицы измерения. Символы — данные (как г/кг/шт), не локализуемый текст.
enum QtyUnit {
  piece('шт'),
  bunch('пучок'),
  pack('уп'),
  gram('г'),
  kilogram('кг'),
  milliliter('мл'),
  liter('л');

  const QtyUnit(this.label);
  final String label;
}

/// Количество запаса в одном из трёх режимов учёта.
sealed class Quantity extends Equatable {
  const Quantity();
  QtyUnit get unit;
}

/// Поштучно: 3 шт.
final class CountQuantity extends Quantity {
  const CountQuantity(this.count, {this.unit = QtyUnit.piece});
  final int count;
  @override
  final QtyUnit unit;

  @override
  List<Object?> get props => [count, unit];
}

/// По весу/объёму: 500 г, 1 л.
final class WeightQuantity extends Quantity {
  const WeightQuantity(this.amount, this.unit);
  final double amount;
  @override
  final QtyUnit unit;

  @override
  List<Object?> get props => [amount, unit];
}

/// Упаковки с содержимым: 2 уп × 250 г.
final class PacksQuantity extends Quantity {
  const PacksQuantity(this.packs, this.perPack, this.unit);
  final int packs;
  final double perPack;
  @override
  final QtyUnit unit;

  @override
  List<Object?> get props => [packs, perPack, unit];
}
