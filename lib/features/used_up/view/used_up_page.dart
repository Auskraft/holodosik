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
class UsedUpPage extends StatefulWidget {
  const UsedUpPage({super.key});

  @override
  State<UsedUpPage> createState() => _UsedUpPageState();
}

class _UsedUpPageState extends State<UsedUpPage> {
  late Future<List<StockEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<InventoryCubit>().loadUsedUp();
  }

  Future<void> _clear() async {
    final l = AppL10n.of(context);
    final cubit = context.read<InventoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.usedUpClearTitle),
        content: Text(l.usedUpClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.usedUpClear),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await cubit.clearUsedUp();
    if (!mounted) return;
    setState(() => _future = cubit.loadUsedUp());
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.usedUpCleared)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.usedUpTitle),
        actions: [
          FutureBuilder<List<StockEntry>>(
            future: _future,
            builder: (context, snapshot) {
              if (!(snapshot.data?.isNotEmpty ?? false)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s),
                child: IconButton(
                  tooltip: l.usedUpClear,
                  icon: Icon(
                    Icons.cleaning_services,
                    color: context.colors.textMuted,
                  ),
                  onPressed: _clear,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<StockEntry>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 50),
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              'assets/images/turtle.png',
                              width: MediaQuery.sizeOf(context).width * 0.72,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  EmptyState(
                    icon: Icons.history,
                    title: l.usedUpEmpty,
                  ),
                ],
              );
            }
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Opacity(
                          opacity: 0.2,
                          child: Image.asset(
                            'assets/images/dragon.png',
                            width: MediaQuery.sizeOf(context).width * 0.675,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
                  itemBuilder: (_, i) => _UsedUpRow(items[i]),
                ),
              ],
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
