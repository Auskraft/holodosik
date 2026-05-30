import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/theme_cubit.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          Text(l.settingsTitle, style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(l.settingsAppearance),
          const SizedBox(height: AppSpacing.m),
          const _ThemePicker(),
          const SizedBox(height: AppSpacing.xl),
          _SectionTitle(l.settingsLanguage),
          const SizedBox(height: AppSpacing.m),
          _LanguageRow(label: l.langRu),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.textTheme.titleMedium
            ?.copyWith(color: context.colors.textMuted),
      );
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final current = context.themeId;
    final labels = {
      AppThemeId.light: l.themeLight,
      AppThemeId.dark: l.themeDark,
      AppThemeId.warm: l.themeWarm,
    };

    return Row(
      children: [
        for (final id in AppThemeId.values) ...[
          Expanded(
            child: _ThemeCard(
              colors: AppColors.of(id),
              label: labels[id]!,
              selected: id == current,
              onTap: () {
                AppHaptics.selection();
                context.read<ThemeCubit>().select(id);
              },
            ),
          ),
          if (id != AppThemeId.values.last)
            const SizedBox(width: AppSpacing.m),
        ],
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.colors,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppColors colors;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? active.accent : active.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _Swatch(colors.accent),
                const SizedBox(width: AppSpacing.xs),
                _Swatch(colors.soon),
                const SizedBox(width: AppSpacing.xs),
                _Swatch(colors.surface),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: active.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.border),
        ),
      );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
          Icon(Icons.check, color: colors.accent),
        ],
      ),
    );
  }
}
