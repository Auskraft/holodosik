import 'package:flutter/material.dart';

import '../../../core/formatting/expiry_presenter.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/icons/ingredient_emoji.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';
import 'status_badge.dart';

/// Карточка запаса (раскладка cozy): иконка категории, название, статус,
/// количество, хинт срока и быстрое действие «Использовать».
class StockCard extends StatelessWidget {
  const StockCard({super.key, required this.entry, this.onTap, this.onUse});

  final StockEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final info = entry.expiryInfo(DateTime.now());
    final qty = QuantityFormatter.format(entry.quantity);
    final hint = ExpiryPresenter.hint(l, info);
    // qty — готовая строка вида «500 г».

    final meta = [entry.category.name, ?hint].join(' · ');

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.l),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bubble(
                    emoji: ProductEmoji.of(
                      entry.name,
                      category: entry.category.name,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.name,
                          style: context.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          qty,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  StatusBadge(info.status),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meta,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  FilledButton(
                    onPressed: () {
                      AppHaptics.light();
                      onUse?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accentSoft,
                      foregroundColor: colors.accentSoftText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.l,
                        vertical: AppSpacing.s,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    child: Text(l.actionUse),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.emoji});
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface3,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}
