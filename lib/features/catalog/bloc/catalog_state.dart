import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

/// Строка списка справочника: заголовок категории или продукт.
sealed class CatalogRow {
  const CatalogRow();
}

class CategoryHeaderRow extends CatalogRow {
  const CategoryHeaderRow(this.category);
  final ProductCategory category;
}

class ProductRow extends CatalogRow {
  const ProductRow(this.product);
  final Product product;
}

class CatalogState extends Equatable {
  const CatalogState({
    this.isLoading = true,
    this.categories = const [],
    this.products = const [],
    this.query = '',
  });

  final bool isLoading;
  final List<ProductCategory> categories;
  final List<Product> products;
  final String query;

  /// Плоский список заголовков и продуктов, сгруппированный по категориям.
  List<CatalogRow> get rows {
    final q = query.trim().toLowerCase();
    final byCategory = <String, List<Product>>{};
    for (final p in products) {
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) continue;
      byCategory.putIfAbsent(p.categoryId, () => []).add(p);
    }

    final result = <CatalogRow>[];
    for (final c in categories) {
      final items = byCategory[c.id];
      if (items == null || items.isEmpty) continue;
      result.add(CategoryHeaderRow(c));
      result.addAll(items.map(ProductRow.new));
    }
    return result;
  }

  CatalogState copyWith({
    bool? isLoading,
    List<ProductCategory>? categories,
    List<Product>? products,
    String? query,
  }) {
    return CatalogState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [isLoading, categories, products, query];
}
