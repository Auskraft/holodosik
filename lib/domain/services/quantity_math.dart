import '../entities/quantity.dart';

/// Операции над количеством — чистые функции.
abstract final class QuantityMath {
  /// «Уменьшаемое» число (для модалки «Использовать»).
  static double total(Quantity q) => q.amount;

  /// Остаток после расхода [used] (в той же единице). Не уходит ниже нуля.
  static Quantity reduceBy(Quantity q, double used) => q.copyWith(
        amount: (q.amount - used).clamp(0, double.infinity).toDouble(),
      );

  static bool isEmpty(Quantity q) => q.amount <= 1e-9;
}
