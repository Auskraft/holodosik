import 'package:flutter_test/flutter_test.dart';
import 'package:holodosik/domain/entities/quantity.dart';
import 'package:holodosik/domain/services/quantity_math.dart';

void main() {
  test('total возвращает количество', () {
    expect(QuantityMath.total(const Quantity(amount: 500, unit: 'г')), 500);
  });

  test('reduceBy уменьшает остаток в той же единице', () {
    final r = QuantityMath.reduceBy(const Quantity(amount: 500, unit: 'г'), 200);
    expect(r, const Quantity(amount: 300, unit: 'г'));
  });

  test('reduceBy не уходит ниже нуля и помечает пустым', () {
    final r = QuantityMath.reduceBy(const Quantity(amount: 3, unit: 'шт'), 5);
    expect(r.amount, 0);
    expect(QuantityMath.isEmpty(r), isTrue);
  });

  test('isEmpty false для непустого', () {
    expect(QuantityMath.isEmpty(const Quantity(amount: 1, unit: 'шт')), isFalse);
  });
}
