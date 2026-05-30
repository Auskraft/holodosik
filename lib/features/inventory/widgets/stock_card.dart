import 'package:flutter/material.dart';

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

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Bubble(
                emoji: ProductEmoji.of(entry.name, category: entry.category.name),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.name,
                      style: context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      qty,
                      style: context.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      entry.category.name,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(info.status),
                  const SizedBox(height: AppSpacing.s),
                  FilledButton(
                    onPressed: () {
                      AppHaptics.light();
                      onUse?.call();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accentSoft,
                      foregroundColor: colors.accentSoftText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
