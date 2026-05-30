import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_field.dart';
import '../../used_up/view/used_up_page.dart';
import '../bloc/inventory_cubit.dart';
import '../bloc/inventory_state.dart';
import '../widgets/inventory_controls.dart';
import '../widgets/stock_card.dart';
import '../widgets/use_modal.dart';
import 'product_detail_page.dart';

/// Главный экран «Запасы». Cubit предоставляется на уровне приложения, поэтому
/// он доступен и на pushed-экранах (детали, модалка).
class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) => const _InventoryView();
}

class _InventoryView extends StatelessWidget {
  const _InventoryView();

  void _openDetail(BuildContext context, StockEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailPage(entryId: entry.id)),
    );
  }

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
                  locations: state.locations,
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
                        itemBuilder: (_, i) => StockCard(
                          entry: items[i],
                          onTap: () => _openDetail(context, items[i]),
                          onUse: () => showUseSheet(context, items[i]),
                        ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.appName, style: AppTypography.brand(colors.accent)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                parts.join(' · '),
                style: context.textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: AppL10n.of(context).usedUpTitle,
          icon: Icon(Icons.history, color: colors.textMuted),
          onPressed: () {
            AppHaptics.light();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UsedUpPage()),
            );
          },
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

    // При поиске без результатов — простое состояние, без маскотов.
    if (hasQuery) {
      return EmptyState(icon: Icons.search_off, title: l.emptySearch);
    }

    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        const opacity = 0.65;
        return Stack(
          children: [
            Positioned(
              right: -w * 0.04,
              top: h * 0.06,
              child: Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/images/empty_blueberry.png',
                  width: w * 0.26,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.55, -0.35),
              child: Opacity(
                opacity: opacity,
                child: Image.asset('assets/images/add_pepper.png', width: w * 0.33),
              ),
            ),
            Positioned(
              left: -w * 0.05,
              bottom: h * 0.02,
              child: Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/images/empty_holodos.png',
                  width: w * 0.3,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.kitchen_outlined, size: 48, color: colors.textFaint),
                  const SizedBox(height: AppSpacing.l),
                  Text(l.emptyStockTitle, style: context.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    l.emptyStockAction,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
