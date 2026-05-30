import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/icons/category_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/search_field.dart';
import '../../add_batch/view/add_batch_page.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';

/// «Справочник» — все известные продукты, сгруппированные по категориям.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CatalogCubit(locator<CatalogRepository>()),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatelessWidget {
  const _CatalogView();

  void _openAdd(BuildContext context, Product product) {
    final categories = context.read<CatalogCubit>().state.categories;
    final category =
        categories.where((c) => c.id == product.categoryId).firstOrNull;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddBatchPage(
          initialProduct: product,
          initialCategory: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final cubit = context.read<CatalogCubit>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.m,
            ),
            child: Text(l.catalogTitle, style: context.textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: SearchField(onChanged: cubit.setQuery),
          ),
          const SizedBox(height: AppSpacing.m),
          Expanded(
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = state.rows;
                if (rows.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: l.emptySearch,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.l,
                    0,
                    AppSpacing.l,
                    AppSpacing.giant,
                  ),
                  itemCount: rows.length,
                  itemBuilder: (_, i) => switch (rows[i]) {
                    CategoryHeaderRow(:final category) =>
                      _CategoryHeader(category),
                    ProductRow(:final product) => _ProductRow(
                      product,
                      onAdd: () => _openAdd(context, product),
                    ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(this.category);
  final ProductCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
      child: Row(
        children: [
          Icon(CategoryIcons.of(category.iconId), size: 18, color: colors.textMuted),
          const SizedBox(width: AppSpacing.s),
          Text(
            category.name,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow(this.product, {required this.onAdd});
  final Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              style: context.textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: colors.accent),
            onPressed: () {
              AppHaptics.light();
              onAdd();
            },
          ),
        ],
      ),
    );
  }
}
