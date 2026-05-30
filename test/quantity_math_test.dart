import 'package:flutter_test/flutter_test.dart';
import 'package:holodosik/domain/entities/quantity.dart';
import 'package:holodosik/domain/services/quantity_math.dart';

void main() {
  test('total по режимам учёта', () {
    expect(QuantityMath.total(const CountQuantity(3)), 3);
    expect(QuantityMath.total(const WeightQuantity(500, QtyUnit.gram)), 500);
    expect(
      QuantityMath.total(const PacksQuantity(2, 250, QtyUnit.gram)),
      500,
    );
  });

  test('reduceBy уменьшает остаток', () {
    final r = QuantityMath.reduceBy(const WeightQuantity(500, QtyUnit.gram), 200);
    expect(r, const WeightQuantity(300, QtyUnit.gram));
  });

  test('reduceBy для упаковок переводит в измеримое количество', () {
    final r = QuantityMath.reduceBy(const PacksQuantity(2, 250, QtyUnit.gram), 200);
    expect(r, const WeightQuantity(300, QtyUnit.gram));
  });

  test('reduceBy не уходит ниже нуля и помечает пустым', () {
    final r = QuantityMath.reduceBy(const CountQuantity(3), 5);
    expect(r, const CountQuantity(0));
    expect(QuantityMath.isEmpty(r), isTrue);
  });

  test('isEmpty false для непустого', () {
    expect(QuantityMath.isEmpty(const CountQuantity(1)), isFalse);
  });
}
