import 'package:flutter/services.dart';

/// Тактильный отклик. Единая точка — чтобы вся вибрация была согласованной
/// и лёгкой. Использовать на действиях: нажатия, переключения, подтверждения.
abstract final class AppHaptics {
  /// Лёгкое касание — нажатие кнопки, переключение вкладки.
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Выбор из набора — сегменты, чипы, шаги счётчика.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Подтверждение действия — сохранили, использовали продукт.
  static Future<void> success() => HapticFeedback.mediumImpact();

  /// Предупреждение — списание, удаление.
  static Future<void> warning() => HapticFeedback.heavyImpact();
}
