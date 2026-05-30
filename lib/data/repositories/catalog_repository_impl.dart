import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';
import '../seed/catalog_seed.dart';

/// Загрузчик asset-файла. Вынесен ради тестируемости (можно подменить).
typedef AssetLoader = Future<String> Function(String path);

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._dataSource, {AssetLoader? assetLoader})
      : _loadAsset = assetLoader ?? rootBundle.loadString;

  static const List<String> _seedAssets = [
    'assets/data/ingredients.json',
    'assets/data/non_food_ingredients.json',
  ];

  final CatalogLocalDataSource _dataSource;
  final AssetLoader _loadAsset;

  @override
  Future<void> ensureSeeded() async {
    if (await _dataSource.productCount() > 0) return;
    final sources = [for (final a in _seedAssets) await _loadAsset(a)];
    final seed = parseCatalog(sources);
    await _dataSource.seed(seed.categories, seed.products);
  }

  @override
  Future<List<ProductCategory>> categories() => _dataSource.categories();

  @override
  Future<List<Product>> products() => _dataSource.products();
}
