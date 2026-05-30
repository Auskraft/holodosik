import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../core/icons/ingredient_emoji.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../inventory/bloc/inventory_cubit.dart';

/// «Использованные» — архив израсходованных партий с сохранённой историей.
class UsedUpPage extends StatelessWidget {
  const UsedUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.usedUpTitle)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<StockEntry>>(
          future: context.read<InventoryCubit>().loadUsedUp(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.history,
                title: l.usedUpEmpty,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
              itemBuilder: (_, i) => _UsedUpRow(items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _UsedUpRow extends StatelessWidget {
  const _UsedUpRow(this.entry);
  final StockEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final history = entry.batch.history;
    final lastDate = history.isEmpty ? null : history.last.timestamp;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surface3,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Text(
              ProductEmoji.of(entry.name, category: entry.category.name),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l.usedUpLabel,
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          if (lastDate != null)
            Text(
              DateFormatter.dayMonth(lastDate),
              style: context.textTheme.bodySmall?.copyWith(color: colors.textFaint),
            ),
        ],
      ),
    );
  }
}
