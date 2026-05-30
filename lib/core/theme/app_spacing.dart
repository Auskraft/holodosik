import 'package:flutter/animation.dart';

/// Шкала отступов 4pt. В вёрстке — только эти токены, без «магических» чисел.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 56;
}

/// Скругления.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Тайминги и кривая переходов из дизайн-системы.
abstract final class AppMotion {
  static const Cubic easing = Cubic(0.32, 0.72, 0, 1);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 320);
}
