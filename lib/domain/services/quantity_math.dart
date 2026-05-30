import '../entities/quantity.dart';

/// Операции над количеством — чистые функции, общие для всех режимов учёта.
abstract final class QuantityMath {
  /// «Уменьшаемое» число для модалки «Использовать»:
  /// count → штуки, weight → значение, packs → упаковки × содержимое.
  static double total(Quantity q) => switch (q) {
        CountQuantity(:final count) => count.toDouble(),
        WeightQuantity(:final amount) => amount,
        PacksQuantity(:final packs, :final perPack) => packs * perPack,
      };

  /// Единица, в которой измеряется [total].
  static QtyUnit unit(Quantity q) => q.unit;

  /// Остаток после расхода [used] (в единицах [total]). Упаковки после
  /// частичного расхода становятся измеримым количеством.
  static Quantity reduceBy(Quantity q, double used) {
    final left = (total(q) - used).clamp(0, double.infinity).toDouble();
    return switch (q) {
      CountQuantity(:final unit) => CountQuantity(left.round(), unit: unit),
      WeightQuantity(:final unit) => WeightQuantity(left, unit),
      PacksQuantity(:final unit) => WeightQuantity(left, unit),
    };
  }

  static bool isEmpty(Quantity q) => total(q) <= 1e-9;
}
