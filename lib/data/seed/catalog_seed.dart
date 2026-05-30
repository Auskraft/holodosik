import 'dart:convert';

import '../../domain/entities/product.dart';

/// Разобранные данные справочника: категории и продукты.
class CatalogSeedData {
  const CatalogSeedData(this.categories, this.products);
  final List<ProductCategory> categories;
  final List<Product> products;
}

/// Чистит JSON5 (комментарии `//`, висячие запятые) до строгого JSON.
String stripJson5(String src) {
  final noComments = src.replaceAll(RegExp(r'//[^\n\r]*'), '');
  return noComments.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
}

/// Парсит один или несколько источников (массивы объектов name/sub/category/...)
/// в общий справочник: категории в порядке первого появления и продукты со
/// сквозной нумерацией. Дубли имён различаются по `sub`.
CatalogSeedData parseCatalog(List<String> sources) {
  final order = <String>[];
  final categoryId = <String, String>{};
  final products = <Product>[];

  for (final src in sources) {
    final list = jsonDecode(stripJson5(src)) as List<dynamic>;
    for (final raw in list) {
      final m = raw as Map<String, dynamic>;
      final catName = (m['category'] as String?)?.trim().isNotEmpty == true
          ? (m['category'] as String).trim()
          : 'Прочее';
      if (!categoryId.containsKey(catName)) {
        categoryId[catName] = 'cat_${order.length}';
        order.add(catName);
      }

      final name = (m['name'] as String).trim();
      final sub = (m['sub'] as String?)?.trim() ?? '';
      final display = sub.isEmpty ? name : '$name, $sub';
      final units = [
        for (final u in (m['units'] as List<dynamic>? ?? const []))
          (u as String).trim(),
      ];

      products.add(
        Product(
          id: 'prod_${products.length}',
          name: display,
          categoryId: categoryId[catName]!,
          units: units.isEmpty ? const ['шт'] : units,
        ),
      );
    }
  }

  final categories = [
    for (var i = 0; i < order.length; i++)
      ProductCategory(
        id: 'cat_$i',
        name: order[i],
        iconId: _iconIdFor(order[i]),
        sortOrder: i,
      ),
  ];

  return CatalogSeedData(categories, products);
}

/// Подбор иконки по названию категории справочника.
String _iconIdFor(String category) {
  final c = category.toLowerCase();
  if (c.contains('молоч')) return 'dairy';
  if (c.contains('яйц')) return 'eggs';
  if (c.contains('мяс') || c.contains('субпродукт')) return 'meat';
  if (c.contains('рыб') || c.contains('морепродукт')) return 'fish';
  if (c.contains('овощ')) return 'veg';
  if (c.contains('фрукт') || c.contains('ягод')) return 'fruit';
  if (c.contains('зелен')) return 'greens';
  if (c.contains('гриб')) return 'mushroom';
  if (c.contains('бобов')) return 'legumes';
  if (c.contains('мука') || c.contains('круп')) return 'grain';
  if (c.contains('макарон') || c.contains('тесто')) return 'pasta';
  if (c.contains('масл') || c.contains('жир')) return 'oil';
  if (c.contains('напит') || c.contains('алког')) return 'drink';
  if (c.contains('разрыхл') || c.contains('загустит')) return 'baking';
  if (c.contains('сахар') || c.contains('сладк')) return 'sweet';
  if (c.contains('соус') || c.contains('приправ') || c.contains('уксус') ||
      c.contains('кислот')) {
    return 'sauce';
  }
  if (c.contains('специ') || c.contains('пряност') || c.contains('паст')) {
    return 'spices';
  }
  if (c.contains('сухофрукт') || c.contains('орех')) return 'nuts';
  if (c.contains('хлеб') || c.contains('выпеч')) return 'bakery';
  if (c.contains('консерв') || c.contains('заготов')) return 'canned';
  return 'other';
}
