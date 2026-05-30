import 'package:flutter/material.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/quantity.dart';
import '../../../l10n/app_localizations.dart';

enum QtyMode { count, weight, packs }

/// Черновик количества формы. Перестраивается под выбранный режим учёта.
class QuantityDraft {
  const QuantityDraft({
    this.mode = QtyMode.count,
    this.count = 1,
    this.amount = 100,
    this.packs = 1,
    this.perPack = 100,
    this.unit = QtyUnit.piece,
  });

  final QtyMode mode;
  final int count;
  final double amount;
  final int packs;
  final double perPack;
  final QtyUnit unit;

  /// Восстанавливает черновик из существующего количества (режим редактирования).
  factory QuantityDraft.fromQuantity(Quantity q) => switch (q) {
        CountQuantity(:final count, :final unit) =>
          QuantityDraft(mode: QtyMode.count, count: count, unit: unit),
        WeightQuantity(:final amount, :final unit) =>
          QuantityDraft(mode: QtyMode.weight, amount: amount, unit: unit),
        PacksQuantity(:final packs, :final perPack, :final unit) => QuantityDraft(
            mode: QtyMode.packs,
            packs: packs,
            perPack: perPack,
            unit: unit,
          ),
      };

  QuantityDraft copyWith({
    QtyMode? mode,
    int? count,
    double? amount,
    int? packs,
    double? perPack,
    QtyUnit? unit,
  }) {
    return QuantityDraft(
      mode: mode ?? this.mode,
      count: count ?? this.count,
      amount: amount ?? this.amount,
      packs: packs ?? this.packs,
      perPack: perPack ?? this.perPack,
      unit: unit ?? this.unit,
    );
  }

  Quantity build() => switch (mode) {
        QtyMode.count => CountQuantity(count, unit: unit),
        QtyMode.weight => WeightQuantity(amount, unit),
        QtyMode.packs => PacksQuantity(packs, perPack, unit),
      };

  bool get isValid => switch (mode) {
        QtyMode.count => count > 0,
        QtyMode.weight => amount > 0,
        QtyMode.packs => packs > 0 && perPack > 0,
      };
}

const _unitsByMode = {
  QtyMode.count: [QtyUnit.piece, QtyUnit.bunch, QtyUnit.pack],
  QtyMode.weight: [QtyUnit.gram, QtyUnit.kilogram, QtyUnit.milliliter, QtyUnit.liter],
  QtyMode.packs: [QtyUnit.gram, QtyUnit.milliliter],
};

QtyUnit _defaultUnit(QtyMode mode) => _unitsByMode[mode]!.first;

double _stepFor(QtyUnit unit) => switch (unit) {
      QtyUnit.piece || QtyUnit.bunch || QtyUnit.pack => 1,
      QtyUnit.gram || QtyUnit.milliliter => 50,
      QtyUnit.kilogram || QtyUnit.liter => 0.1,
    };

/// Редактор количества: сегменты режима + соответствующие поля и единицы.
class QuantityEditor extends StatelessWidget {
  const QuantityEditor({super.key, required this.draft, required this.onChanged});

  final QuantityDraft draft;
  final ValueChanged<QuantityDraft> onChanged;

  void _setMode(QtyMode mode) {
    onChanged(draft.copyWith(mode: mode, unit: _defaultUnit(mode)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final modeLabels = {
      QtyMode.count: l.qtyModeCount,
      QtyMode.weight: l.qtyModeWeight,
      QtyMode.packs: l.qtyModePacks,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          children: [
            for (final mode in QtyMode.values)
              ChoiceChip(
                label: Text(modeLabels[mode]!),
                selected: mode == draft.mode,
                showCheckmark: false,
                backgroundColor: context.colors.surface,
                selectedColor: context.colors.accentSoft,
                side: BorderSide(color: context.colors.border),
                labelStyle: context.textTheme.bodySmall?.copyWith(
                  color: mode == draft.mode
                      ? context.colors.accentSoftText
                      : context.colors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  AppHaptics.selection();
                  _setMode(mode);
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        ..._buildFields(context),
        const SizedBox(height: AppSpacing.m),
        _UnitChips(
          units: _unitsByMode[draft.mode]!,
          selected: draft.unit,
          onSelected: (u) => onChanged(draft.copyWith(unit: u)),
        ),
        if (draft.mode == QtyMode.packs) ...[
          const SizedBox(height: AppSpacing.m),
          Text(
            l.qtyTotal(
              QuantityFormatter.format(draft.build()).totalValue ?? '',
            ),
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    final l = AppL10n.of(context);
    return switch (draft.mode) {
      QtyMode.count => [
          _NumberRow(
            value: draft.count.toDouble(),
            step: 1,
            isInt: true,
            onChanged: (v) => onChanged(draft.copyWith(count: v.round())),
          ),
        ],
      QtyMode.weight => [
          _NumberRow(
            value: draft.amount,
            step: _stepFor(draft.unit),
            isInt: false,
            onChanged: (v) => onChanged(draft.copyWith(amount: v)),
          ),
        ],
      QtyMode.packs => [
          _LabeledNumber(
            label: l.packsCountLabel,
            value: draft.packs.toDouble(),
            step: 1,
            isInt: true,
            onChanged: (v) => onChanged(draft.copyWith(packs: v.round())),
          ),
          const SizedBox(height: AppSpacing.m),
          _LabeledNumber(
            label: l.perPackLabel,
            value: draft.perPack,
            step: _stepFor(draft.unit),
            isInt: false,
            onChanged: (v) => onChanged(draft.copyWith(perPack: v)),
          ),
        ],
    };
  }
}

class _LabeledNumber extends StatelessWidget {
  const _LabeledNumber({
    required this.label,
    required this.value,
    required this.step,
    required this.isInt,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double step;
  final bool isInt;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
          ),
        ),
        _NumberRow(value: value, step: step, isInt: isInt, onChanged: onChanged),
      ],
    );
  }
}

class _NumberRow extends StatelessWidget {
  const _NumberRow({
    required this.value,
    required this.step,
    required this.isInt,
    required this.onChanged,
  });

  final double value;
  final double step;
  final bool isInt;
  final ValueChanged<double> onChanged;

  String get _text => isInt
      ? value.round().toString()
      : (value == value.truncateToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1).replaceAll('.', ','));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: Icons.remove,
          onTap: () {
            AppHaptics.selection();
            onChanged((value - step).clamp(0, double.infinity).toDouble());
          },
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 64),
          alignment: Alignment.center,
          child: Text(_text, style: context.textTheme.titleLarge),
        ),
        _RoundButton(
          icon: Icons.add,
          onTap: () {
            AppHaptics.selection();
            onChanged(value + step);
          },
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, size: 20, color: colors.text),
      ),
    );
  }
}

class _UnitChips extends StatelessWidget {
  const _UnitChips({
    required this.units,
    required this.selected,
    required this.onSelected,
  });

  final List<QtyUnit> units;
  final QtyUnit selected;
  final ValueChanged<QtyUnit> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final u in units)
          ChoiceChip(
            label: Text(u.label),
            selected: u == selected,
            showCheckmark: false,
            backgroundColor: colors.surface,
            selectedColor: colors.accent,
            side: BorderSide(color: colors.border),
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: u == selected ? colors.onAccent : colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              AppHaptics.selection();
              onSelected(u);
            },
          ),
      ],
    );
  }
}
