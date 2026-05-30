import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/quantity.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/services/quantity_math.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/inventory_cubit.dart';

/// Открывает модалку «Использовать» для партии. Возвращает true, если расход
/// подтверждён (например, чтобы закрыть экран деталей при опустошении).
Future<bool> showUseSheet(BuildContext context, StockEntry entry) async {
  final cubit = context.read<InventoryCubit>();
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (_) => BlocProvider.value(value: cubit, child: _UseSheet(entry)),
  );
  return result ?? false;
}

class _UseSheet extends StatefulWidget {
  const _UseSheet(this.entry);
  final StockEntry entry;

  @override
  State<_UseSheet> createState() => _UseSheetState();
}

class _UseSheetState extends State<_UseSheet> {
  late final double _total = QuantityMath.total(widget.entry.quantity);
  late final QtyUnit _unit = widget.entry.quantity.unit;
  double _used = 0;
  UsageReason _reason = UsageReason.consumed;

  bool get _isCount => widget.entry.quantity is CountQuantity;
  double get _step => switch (_unit) {
        QtyUnit.piece || QtyUnit.bunch || QtyUnit.pack => 1,
        QtyUnit.gram || QtyUnit.milliliter => 50,
        QtyUnit.kilogram || QtyUnit.liter => 0.1,
      };

  void _setUsed(double v) {
    setState(() => _used = v.clamp(0, _total).toDouble());
  }

  void _confirm() {
    AppHaptics.success();
    final amount = _isCount
        ? CountQuantity(_used.round(), unit: _unit) as Quantity
        : WeightQuantity(_used, _unit);
    context.read<InventoryCubit>().use(
          widget.entry.id,
          UsageEvent(
            id: 'use_${DateTime.now().microsecondsSinceEpoch}',
            amount: amount,
            reason: _reason,
            timestamp: DateTime.now(),
          ),
        );
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(AppL10n.of(context).toastUsed)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final remaining = QuantityMath.reduceBy(widget.entry.quantity, _used);
    final remainingFmt = QuantityFormatter.format(remaining);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.entry.name, style: context.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l.useAmountLabel,
            style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.l),
          _Stepper(
            value: _used,
            unit: _unit.label,
            isCount: _isCount,
            onMinus: () {
              AppHaptics.selection();
              _setUsed(_used - _step);
            },
            onPlus: () {
              AppHaptics.selection();
              _setUsed(_used + _step);
            },
          ),
          const SizedBox(height: AppSpacing.l),
          _Progress(fraction: _total == 0 ? 0 : _used / _total),
          const SizedBox(height: AppSpacing.l),
          Wrap(
            spacing: AppSpacing.s,
            children: [
              _QuickChip(l.useQuarter, () => _setUsed(_total * 0.25)),
              _QuickChip(l.useHalf, () => _setUsed(_total * 0.5)),
              _QuickChip(l.useAll, () => _setUsed(_total)),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _ReasonChip(l.reasonCooked, UsageReason.cooked, _reason,
                  (r) => setState(() => _reason = r)),
              _ReasonChip(l.reasonConsumed, UsageReason.consumed, _reason,
                  (r) => setState(() => _reason = r)),
              _ReasonChip(l.reasonSpoiled, UsageReason.expired, _reason,
                  (r) => setState(() => _reason = r)),
              _ReasonChip(l.reasonThrown, UsageReason.discarded, _reason,
                  (r) => setState(() => _reason = r)),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            QuantityMath.isEmpty(remaining)
                ? l.useWillBeUsedUp
                : l.useRemaining(remainingFmt.primary),
            style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _used <= 0 ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: Text(l.useConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.unit,
    required this.isCount,
    required this.onMinus,
    required this.onPlus,
  });

  final double value;
  final String unit;
  final bool isCount;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = isCount
        ? value.round().toString()
        : (value == value.truncateToDouble()
            ? value.toInt().toString()
            : value.toStringAsFixed(1).replaceAll('.', ','));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundButton(icon: Icons.remove, onTap: onMinus),
        Expanded(
          child: Column(
            children: [
              Text(
                text,
                style: AppTypography.textTheme(colors.text).displayMedium,
              ),
              Text(unit, style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
        _RoundButton(icon: Icons.add, onTap: onPlus),
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
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: colors.surface2,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, color: colors.text),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1),
        minHeight: 8,
        backgroundColor: colors.surface2,
        valueColor: AlwaysStoppedAnimation(colors.accent),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ActionChip(
      label: Text(label),
      backgroundColor: colors.surface2,
      side: BorderSide(color: colors.border),
      labelStyle: context.textTheme.bodySmall?.copyWith(
        color: colors.text,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        AppHaptics.selection();
        onTap();
      },
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip(this.label, this.value, this.selected, this.onSelected);
  final String label;
  final UsageReason value;
  final UsageReason selected;
  final ValueChanged<UsageReason> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSel = value == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      showCheckmark: false,
      backgroundColor: colors.surface,
      selectedColor: colors.accentSoft,
      side: BorderSide(color: colors.border),
      labelStyle: context.textTheme.bodySmall?.copyWith(
        color: isSel ? colors.accentSoftText : colors.textMuted,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        AppHaptics.selection();
        onSelected(value);
      },
    );
  }
}
