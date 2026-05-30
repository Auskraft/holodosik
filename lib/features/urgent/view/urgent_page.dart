import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/expiry.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/bloc/inventory_cubit.dart';
import '../../inventory/bloc/inventory_state.dart';
import '../../inventory/view/product_detail_page.dart';
import '../../inventory/widgets/stock_card.dart';
import '../../inventory/widgets/use_modal.dart';

/// «Срочное» — приоритетная полка: что съесть в первую очередь.
class UrgentPage extends StatelessWidget {
  const UrgentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return SafeArea(
      bottom: false,
      child: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          final sections = _buildSections(l, state.all);
          final header = Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(l.urgentTitle, style: context.textTheme.headlineMedium),
          );

          if (sections.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header, const Expanded(child: _UrgentEmpty())],
            );
          }

          return Stack(
            children: [
              const Positioned.fill(child: _UrgentBackground()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.l,
                        0,
                        AppSpacing.l,
                        AppSpacing.giant,
                      ),
                      children: [
                        for (final s in sections) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.m,
                              bottom: AppSpacing.s,
                            ),
                            child: Text(
                              s.title,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          for (final entry in s.items)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.m,
                              ),
                              child: StockCard(
                                entry: entry,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailPage(entryId: entry.id),
                                  ),
                                ),
                                onUse: () => showUseSheet(context, entry),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<({String title, List<StockEntry> items})> _buildSections(
    AppL10n l,
    List<StockEntry> all,
  ) {
    final today = DateTime.now();
    final expired = <StockEntry>[];
    final todayItems = <StockEntry>[];
    final upcoming = <StockEntry>[];

    for (final e in all) {
      final info = e.expiryInfo(today);
      switch (info.status) {
        case ExpiryStatus.expired:
          expired.add(e);
        case ExpiryStatus.soon when info.daysLeft == 0:
          todayItems.add(e);
        case ExpiryStatus.soon:
          upcoming.add(e);
        case _:
          break;
      }
    }

    int byDays(StockEntry a, StockEntry b) =>
        (a.expiryInfo(today).daysLeft ?? 0).compareTo(
          b.expiryInfo(today).daysLeft ?? 0,
        );
    expired.sort(byDays);
    upcoming.sort(byDays);

    return [
      if (expired.isNotEmpty) (title: l.urgentExpired, items: expired),
      if (todayItems.isNotEmpty) (title: l.urgentToday, items: todayItems),
      if (upcoming.isNotEmpty) (title: l.urgentUpcoming, items: upcoming),
    ];
  }
}

/// Пустое «Срочное»: маскоты на фоне (80% прозрачности) + спокойное сообщение.
class _UrgentEmpty extends StatelessWidget {
  const _UrgentEmpty();

  static const double _opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.55),
              child: Opacity(
                opacity: _opacity,
                child: Image.asset('assets/images/holodos.png', width: w * 0.5),
              ),
            ),
            Positioned(
              right: -w * 0.05,
              top: h * 0.5,
              child: Opacity(
                opacity: _opacity,
                child: Image.asset(
                  'assets/images/blueberry.png',
                  width: w * 0.3,
                ),
              ),
            ),
            Positioned(
              left: -w * 0.05,
              bottom: h * 0.12,
              child: Opacity(
                opacity: _opacity,
                child: Image.asset('assets/images/pepper.png', width: w * 0.3),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    size: 40,
                    color: colors.textFaint,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(l.urgentEmpty, style: context.textTheme.titleMedium),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Фон при наличии просрочки: грустные маскоты с прозрачностью 80%.
class _UrgentBackground extends StatelessWidget {
  const _UrgentBackground();

  static const double _opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return Stack(
          children: [
            Positioned(
              right: w * 0.03,
              top: h * 0.05,
              child: Opacity(
                opacity: _opacity,
                child: Image.asset('assets/images/tomato.png', width: w * 0.18),
              ),
            ),
            Positioned(
              right: -w * 0.05,
              top: h * 0.42,
              child: Opacity(
                opacity: _opacity,
                child: Image.asset('assets/images/onion.png', width: w * 0.34),
              ),
            ),
            Positioned(
              left: -w * 0.04,
              bottom: h * 0.1,
              child: Opacity(
                opacity: _opacity,
                child: Image.asset(
                  'assets/images/holodos_sad.png',
                  width: w * 0.34,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
