import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Короткий доступ к токенам из любого виджета: `context.colors.accent`,
/// `context.textTheme.titleLarge`.
extension ContextThemeX on BuildContext {
  AppColors get colors => AppTheme.of(this).colors;
  AppThemeId get themeId => AppTheme.of(this).id;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
