import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'splash_screen.dart';

class HolodosikApp extends StatelessWidget {
  const HolodosikApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Тема приложения — только тёплая.
    const id = AppThemeId.warm;
    const colors = AppColors.warm;
    final iconBrightness = colors.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialThemeFrom(colors),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          statusBarBrightness: colors.brightness,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
        child: AppTheme(id: id, colors: colors, child: child!),
      ),
      home: const SplashScreen(),
    );
  }
}
