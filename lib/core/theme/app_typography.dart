import 'package:flutter/material.dart';

/// Типографика. Шрифты бандлятся в assets (офлайн): UI — Onest, брендовый
/// логотип — Unbounded. Размеры в логических пикселях уважают системный масштаб.
abstract final class AppTypography {
  static const String fontFamily = 'Onest';
  static const String brandFamily = 'MTS Wide';

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

  /// Брендовый логотип «Холодосик» — Unbounded.
  static TextStyle brand(Color color) => TextStyle(
        fontFamily: brandFamily,
        fontSize: sizeXl,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextTheme textTheme(Color color) {
    TextStyle s(double size, FontWeight weight, [double height = 1.25]) =>
        TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: color,
        );

    return TextTheme(
      displayLarge: s(size4xl, FontWeight.w800, 1.05),
      displayMedium: s(size3xl, FontWeight.w800, 1.1),
      headlineMedium: s(size2xl, FontWeight.w700, 1.15),
      titleLarge: s(sizeXl, FontWeight.w700),
      titleMedium: s(sizeLg, FontWeight.w600),
      bodyLarge: s(sizeBase, FontWeight.w400),
      bodyMedium: s(sizeMd, FontWeight.w400),
      bodySmall: s(sizeSm, FontWeight.w400),
      labelLarge: s(sizeMd, FontWeight.w600),
      labelSmall: s(sizeXs, FontWeight.w500),
    );
  }
}
