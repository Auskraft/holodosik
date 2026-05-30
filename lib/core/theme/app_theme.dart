import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Прокидывает активные токены вниз по дереву. Доступ — через
/// `context.colors` (см. `context_theme_x.dart`).
class AppTheme extends InheritedWidget {
  const AppTheme({
    super.key,
    required this.id,
    required this.colors,
    required super.child,
  });

  final AppThemeId id;
  final AppColors colors;

  static AppTheme of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(theme != null, 'AppTheme не найден в дереве');
    return theme!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => oldWidget.id != id;

  /// Material-тема, собранная из семантических токенов: стандартные виджеты
  /// получают цвета из той же палитры, что и кастомные компоненты.
  static ThemeData materialThemeFrom(AppColors c) {
    final scheme = ColorScheme(
      brightness: c.brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accentSoft,
      onSecondary: c.accentSoftText,
      error: c.expired,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.text,
      surfaceContainerHighest: c.surface3,
      outline: c.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      textTheme: AppTypography.textTheme(c.text),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
