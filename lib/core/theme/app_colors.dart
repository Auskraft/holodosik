import 'package:flutter/material.dart';

/// Доступные темы. Добавить новую = добавить значение и палитру в [AppColors].
enum AppThemeId { light, dark, warm }

/// Семантические цветовые токены. Единственный источник цвета в приложении —
/// компоненты берут цвета только отсюда (`context.colors.*`), без хардкода.
@immutable
class AppColors {
  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.accentSoftText,
    required this.fresh,
    required this.freshSoft,
    required this.freshText,
    required this.soon,
    required this.soonSoft,
    required this.soonText,
    required this.expired,
    required this.expiredSoft,
    required this.expiredText,
    required this.low,
    required this.lowSoft,
    required this.lowText,
  });

  final Brightness brightness;

  final Color background;
  final Color surface;
  final Color surface2;
  final Color surface3;

  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color border;

  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color accentSoftText;

  final Color fresh;
  final Color freshSoft;
  final Color freshText;

  final Color soon;
  final Color soonSoft;
  final Color soonText;

  final Color expired;
  final Color expiredSoft;
  final Color expiredText;

  final Color low;
  final Color lowSoft;
  final Color lowText;

  static AppColors of(AppThemeId id) => switch (id) {
        AppThemeId.light => light,
        AppThemeId.dark => dark,
        AppThemeId.warm => warm,
      };

  /// Светлая — по умолчанию.
  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFEEF1EB),
    surface: Color(0xFFFBFCFA),
    surface2: Color(0xFFF2F4EE),
    surface3: Color(0xFFE7EBE2),
    text: Color(0xFF1B241E),
    textMuted: Color(0xFF5E6B61),
    textFaint: Color(0xFF9AA59C),
    border: Color(0xFFE0E5DA),
    accent: Color(0xFF2F7D5B),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFDCEBE2),
    accentSoftText: Color(0xFF226148),
    fresh: Color(0xFF3E9B6E),
    freshSoft: Color(0xFFDDEEE3),
    freshText: Color(0xFF246B49),
    soon: Color(0xFFD98A2B),
    soonSoft: Color(0xFFF7E9D2),
    soonText: Color(0xFF95591A),
    expired: Color(0xFFCD5443),
    expiredSoft: Color(0xFFF6DDD8),
    expiredText: Color(0xFF9A3729),
    low: Color(0xFF4C7FB3),
    lowSoft: Color(0xFFDEE9F2),
    lowText: Color(0xFF2F5A85),
  );

  /// Тёмная — «тёмный сад».
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF0E1613),
    surface: Color(0xFF18211D),
    surface2: Color(0xFF1F2A24),
    surface3: Color(0xFF283631),
    text: Color(0xFFEAF1EC),
    textMuted: Color(0xFF93A399),
    textFaint: Color(0xFF62716A),
    border: Color(0xFF2A3731),
    accent: Color(0xFF74C79B),
    onAccent: Color(0xFF0C1512),
    accentSoft: Color(0xFF1E3329),
    accentSoftText: Color(0xFF9FDCBC),
    fresh: Color(0xFF6FC295),
    freshSoft: Color(0xFF1C3328),
    freshText: Color(0xFF9DD9B9),
    soon: Color(0xFFE2A857),
    soonSoft: Color(0xFF34291A),
    soonText: Color(0xFFE9BE81),
    expired: Color(0xFFE07765),
    expiredSoft: Color(0xFF371F1B),
    expiredText: Color(0xFFEE9D8E),
    low: Color(0xFF6FA3D6),
    lowSoft: Color(0xFF1C2A38),
    lowText: Color(0xFF9DC2E6),
  );

  /// Тёплая — «крем и глина».
  static const AppColors warm = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF2E7D6),
    surface: Color(0xFFFFFBF4),
    surface2: Color(0xFFF7EEDF),
    surface3: Color(0xFFEFE2CD),
    text: Color(0xFF2C2318),
    textMuted: Color(0xFF7A6A54),
    textFaint: Color(0xFFA8987F),
    border: Color(0xFFE7D8C0),
    accent: Color(0xFFB5673C),
    onAccent: Color(0xFFFFF8EF),
    accentSoft: Color(0xFFF2DEC9),
    accentSoftText: Color(0xFF8F4A28),
    fresh: Color(0xFF6E8B3D),
    freshSoft: Color(0xFFE7E6C9),
    freshText: Color(0xFF506626),
    soon: Color(0xFFC58329),
    soonSoft: Color(0xFFF6E4C6),
    soonText: Color(0xFF8C5816),
    expired: Color(0xFFC0533A),
    expiredSoft: Color(0xFFF3D9CD),
    expiredText: Color(0xFF8E3623),
    low: Color(0xFF5E7E8C),
    lowSoft: Color(0xFFDEE7E6),
    lowText: Color(0xFF3F5862),
  );
}
