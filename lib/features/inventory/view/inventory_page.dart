import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../bloc/inventory_cubit.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_controls.dart';
import '../widgets/stock_card.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InventoryCubit(locator<StockRepository>()),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatelessWidget {
  const _InventoryView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InventoryCubit>();

    return SafeArea(
      bottom: false,
      child: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = state.visible;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.m,
                ),
                child: _Header(
                  productCount: state.all.length,
                  attentionCount: state.attentionCount,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: SearchField(onChanged: cubit.setQuery),
              ),
              const SizedBox(height: AppSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: LocationSegments(
                  value: state.location,
                  onChanged: cubit.setLocation,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: SortChips(value: state.sort, onChanged: cubit.setSort),
              ),
              const SizedBox(height: AppSpacing.m),
              Expanded(
                child: items.isEmpty
                    ? _EmptyView(hasQuery: state.query.trim().isNotEmpty)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.l,
                          0,
                          AppSpacing.l,
                          AppSpacing.giant,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.m),
                        itemBuilder: (_, i) => StockCard(entry: items[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.productCount, required this.attentionCount});

  final int productCount;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    final parts = [
      l.inventoryProductsCount(productCount),
      if (attentionCount > 0) l.inventoryAttentionCount(attentionCount),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.appName, style: AppTypography.brand(colors.accent)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          parts.join(' · '),
          style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return EmptyState(
      icon: hasQuery ? Icons.search_off : Icons.kitchen_outlined,
      title: hasQuery ? l.emptySearch : l.emptyStockTitle,
      hint: hasQuery ? null : l.emptyStockAction,
    );
  }
}
