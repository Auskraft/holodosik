import 'package:flutter/material.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';

/// Сегменты места хранения: «Все» + встроенные и пользовательские места.
class LocationSegments extends StatelessWidget {
  const LocationSegments({
    super.key,
    required this.value,
    required this.locations,
    required this.onChanged,
  });

  /// Текущий выбор: пустая строка — «Все».
  final String value;
  final List<String> locations;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final options = ['', ...locations];

    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final loc in options)
          _Segment(
            label: loc.isEmpty ? l.locAll : loc,
            selected: loc == value,
            onTap: () {
              AppHaptics.selection();
              onChanged(loc);
            },
          ),
      ],
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
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s,
          horizontal: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: selected ? colors.accentSoft : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: colors.border),
        ),
        child: Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: selected ? colors.accentSoftText : colors.textMuted,
            fontWeight: FontWeight.w600,
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
