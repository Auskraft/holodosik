import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../core/formatting/expiry_presenter.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/formatting/usage_reason_presenter.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/icons/ingredient_emoji.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../add_batch/view/add_batch_page.dart';
import '../bloc/inventory_cubit.dart';
import '../bloc/inventory_state.dart';
import '../widgets/status_badge.dart';
import '../widgets/use_modal.dart';

/// Карточка продукта: количество, сроки, место, история и действия.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.entryId});
  final String entryId;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        final entry = context.read<InventoryCubit>().entryById(entryId);
        if (entry == null) {
          // Запас израсходован или списан — закрываем экран.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        final info = entry.expiryInfo(DateTime.now());
        final qty = QuantityFormatter.format(entry.quantity);
        final hint = ExpiryPresenter.hint(l, info);

        return Scaffold(
          appBar: AppBar(title: Text(entry.name)),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                _Hero(entry: entry, statusInfo: info),
                const SizedBox(height: AppSpacing.l),
                _QuantityBlock(primary: qty, hint: hint),
                const SizedBox(height: AppSpacing.l),
                _MetaRows(entry: entry),
                const SizedBox(height: AppSpacing.xl),
                Text(l.detailHistory, style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.s),
                _History(history: entry.batch.history),
                const SizedBox(height: AppSpacing.xl),
                _SecondaryActions(entry: entry),
              ],
            ),
          ),
          bottomNavigationBar: _UseBar(entry: entry),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.entry, required this.statusInfo});
  final StockEntry entry;
  final dynamic statusInfo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: colors.surface3,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: Text(
            ProductEmoji.of(entry.name, category: entry.category.name),
            style: const TextStyle(fontSize: 38),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.category.name,
                style: context.textTheme.bodySmall?.copyWith(color: colors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(entry.name, style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.s),
              StatusBadge(entry.expiryInfo(DateTime.now()).status),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityBlock extends StatelessWidget {
  const _QuantityBlock({required this.primary, this.hint});
  final String primary;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.detailInStock,
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(primary, style: context.textTheme.headlineMedium),
              ],
            ),
          ),
          if (hint != null)
            Text(
              hint!,
              style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
        ],
      ),
    );
  }
}

class _MetaRows extends StatelessWidget {
  const _MetaRows({required this.entry});
  final StockEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final b = entry.batch;
    final locName = switch (entry.location) {
      StorageLocation.fridge => l.locFridge,
      StorageLocation.freezer => l.locFreezer,
      StorageLocation.pantry => l.locPantry,
    };

    return Column(
      children: [
        if (b.expiryDate != null)
          _MetaRow(Icons.event_outlined, l.detailExpiry, DateFormatter.full(b.expiryDate!)),
        if (b.purchaseDate != null)
          _MetaRow(Icons.shopping_bag_outlined, l.detailPurchased, DateFormatter.full(b.purchaseDate!)),
        if (b.openedDate != null)
          _MetaRow(Icons.lock_open_outlined, l.detailOpened, DateFormatter.full(b.openedDate!)),
        _MetaRow(Icons.place_outlined, l.detailLocation, locName),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.textMuted),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ),
          Text(value, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.history});
  final List<UsageEvent> history;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    if (history.isEmpty) {
      return Text(
        l.detailNoHistory,
        style: context.textTheme.bodyMedium?.copyWith(color: colors.textFaint),
      );
    }
    final items = history.reversed.toList();
    return Column(
      children: [
        for (final e in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Text(
                  '−${QuantityFormatter.format(e.amount)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    e.reason.label(l),
                    style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
                  ),
                ),
                Text(
                  DateFormatter.dayMonth(e.timestamp),
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textFaint),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({required this.entry});
  final StockEntry entry;

  void _openForm(BuildContext context, {required bool edit}) {
    AppHaptics.light();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => edit
            ? AddBatchPage(editEntry: entry)
            : AddBatchPage(
                initialProduct: entry.product,
                initialCategory: entry.category,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            icon: Icons.add,
            label: l.actionAddBatch,
            onTap: () => _openForm(context, edit: false),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _SecondaryButton(
            icon: Icons.edit_outlined,
            label: l.actionEdit,
            onTap: () => _openForm(context, edit: true),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _SecondaryButton(
            icon: Icons.delete_outline,
            label: l.actionDiscard,
            color: colors.expiredText,
            onTap: () {
              AppHaptics.warning();
              context.read<InventoryCubit>().discard(entry.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(SnackBar(content: Text(l.toastDiscarded)));
            },
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = color ?? colors.text;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: colors.border),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class _UseBar extends StatelessWidget {
  const _UseBar({required this.entry});
  final StockEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              AppHaptics.light();
              showUseSheet(context, entry);
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Text(l.actionUse),
          ),
        ),
      ),
    );
  }
}
