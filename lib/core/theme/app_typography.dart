import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Типографика. Размеры в логических пикселях уважают системный масштаб шрифта
/// (Flutter применяет `textScaler` автоматически). UI-шрифт — Onest,
/// брендовый логотип — Unbounded.
abstract final class AppTypography {
  // Типошкала (база 16).
  static const double sizeXs = 12;
  static const double sizeSm = 13;
  static const double sizeMd = 15;
  static const double sizeBase = 16;
  static const double sizeLg = 18;
  static const double sizeXl = 22;
  static const double size2xl = 28;
  static const double size3xl = 36;
  static const double size4xl = 48;

  /// Брендовый логотип «холодос» — Unbounded, строчными.
  static TextStyle brand(Color color) => GoogleFonts.unbounded(
        fontSize: sizeXl,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextTheme textTheme(Color color) {
    final base = GoogleFonts.onestTextTheme();
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontSize: size4xl,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontSize: size3xl,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: size2xl,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: sizeXl,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: sizeLg,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: base.bodyLarge?.copyWith(fontSize: sizeBase),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: sizeMd),
          bodySmall: base.bodySmall?.copyWith(fontSize: sizeSm),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: sizeXs,
            fontWeight: FontWeight.w500,
          ),
        )
        .apply(bodyColor: color, displayColor: color);
  }
}
