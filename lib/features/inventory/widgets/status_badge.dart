import 'package:flutter/material.dart';

import '../../../core/formatting/expiry_presenter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/expiry.dart';
import '../../../l10n/app_localizations.dart';

/// Мягкий pill-бейдж статуса срока. Цвета — из токенов активной темы.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final ExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = _colors(colors, status);

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
        ExpiryPresenter.label(AppL10n.of(context), status),
        style: context.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (Color, Color) _colors(AppColors c, ExpiryStatus status) =>
      switch (status) {
        ExpiryStatus.fresh => (c.freshSoft, c.freshText),
        ExpiryStatus.soon => (c.soonSoft, c.soonText),
        ExpiryStatus.expired => (c.expiredSoft, c.expiredText),
        ExpiryStatus.none => (c.surface3, c.textMuted),
      };
}
