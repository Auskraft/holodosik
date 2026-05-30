import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'theme/theme_cubit.dart';
import 'foundation_preview_page.dart';

class HolodosikApp extends StatelessWidget {
  const HolodosikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppThemeId>(
      builder: (context, themeId) {
        final colors = AppColors.of(themeId);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.materialThemeFrom(colors),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          builder: (context, child) => AppTheme(
            id: themeId,
            colors: colors,
            child: child!,
          ),
          home: const FoundationPreviewPage(),
        );
      },
    );
  }
}
