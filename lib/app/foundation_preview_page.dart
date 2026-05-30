import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/haptics/app_haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/context_theme_x.dart';
import '../l10n/app_localizations.dart';
import 'theme/theme_cubit.dart';

/// Временный экран: проверяет, что токены, темы, шрифты, хаптика и локализация
/// работают. Будет заменён реальными экранами на следующих этапах.
class FoundationPreviewPage extends StatelessWidget {
  const FoundationPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            Text(l.appName, style: AppTypography.brand(colors.accent)),
            const SizedBox(height: AppSpacing.xxl),
            _ThemeSwitcher(),
            const SizedBox(height: AppSpacing.xxl),
            _StatusRow(
              children: [
                _Badge(l.statusFresh, colors.freshSoft, colors.freshText),
                _Badge(l.statusSoon, colors.soonSoft, colors.soonText),
                _Badge(l.statusExpired, colors.expiredSoft, colors.expiredText),
                _Badge(l.statusLow, colors.lowSoft, colors.lowText),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _SampleCard(),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final current = context.themeId;
    final labels = {
      AppThemeId.light: l.themeLight,
      AppThemeId.dark: l.themeDark,
      AppThemeId.warm: l.themeWarm,
    };

    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final id in AppThemeId.values)
          ChoiceChip(
            label: Text(labels[id]!),
            selected: id == current,
            onSelected: (_) {
              AppHaptics.selection();
              context.read<ThemeCubit>().select(id);
            },
          ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: AppSpacing.s, runSpacing: AppSpacing.s, children: children);
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.bg, this.fg);
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surface3,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.egg_outlined, color: colors.textMuted),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Молоко', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '1 л',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: AppHaptics.light,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accentSoft,
              foregroundColor: colors.accentSoftText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Text(l.actionUse),
          ),
        ],
      ),
    );
  }
}
