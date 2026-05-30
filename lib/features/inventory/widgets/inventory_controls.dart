import 'package:flutter/material.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../l10n/app_localizations.dart';

/// Сегменты места хранения: Все / Холодильник / Морозилка / Шкаф.
class LocationSegments extends StatelessWidget {
  const LocationSegments({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final LocationFilter value;
  final ValueChanged<LocationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final labels = {
      LocationFilter.all: l.locAll,
      LocationFilter.fridge: l.locFridge,
      LocationFilter.freezer: l.locFreezer,
      LocationFilter.pantry: l.locPantry,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          for (final f in LocationFilter.values)
            Expanded(
              child: _Segment(
                label: labels[f]!,
                selected: f == value,
                onTap: () {
                  AppHaptics.selection();
                  onChanged(f);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.easing,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: selected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: selected ? colors.text : colors.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Чипы сортировки: По сроку / По категории / По названию.
class SortChips extends StatelessWidget {
  const SortChips({super.key, required this.value, required this.onChanged});

  final SortMode value;
  final ValueChanged<SortMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final labels = {
      SortMode.byExpiry: l.sortExpiry,
      SortMode.byCategory: l.sortCategory,
      SortMode.byName: l.sortName,
    };

    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final mode in SortMode.values)
          ChoiceChip(
            label: Text(labels[mode]!),
            selected: mode == value,
            showCheckmark: false,
            backgroundColor: colors.surface,
            selectedColor: colors.accent,
            side: BorderSide(color: colors.border),
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: mode == value ? colors.onAccent : colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              AppHaptics.selection();
              onChanged(mode);
            },
          ),
      ],
    );
  }
}
