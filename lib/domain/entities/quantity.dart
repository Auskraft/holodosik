import 'package:equatable/equatable.dart';

/// Количество запаса: число + единица измерения (свободная строка из набора
/// единиц конкретного продукта — «г», «кг», «стакан», «шт», «ст.л.» и т.п.).
class Quantity extends Equatable {
  const Quantity({required this.amount, required this.unit});

  final double amount;
  final String unit;

  Quantity copyWith({double? amount, String? unit}) =>
      Quantity(amount: amount ?? this.amount, unit: unit ?? this.unit);

  @override
  List<Object?> get props => [amount, unit];
}
