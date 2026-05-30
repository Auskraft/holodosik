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

  static const String _seedAsset = 'assets/data/ingredients.json';

  final CatalogLocalDataSource _dataSource;
  final AssetLoader _loadAsset;

  @override
  Future<void> ensureSeeded() async {
    if (await _dataSource.productCount() > 0) return;
    final seed = parseIngredients(await _loadAsset(_seedAsset));
    await _dataSource.seed(seed.categories, seed.products);
  }

  @override
  Future<List<ProductCategory>> categories() => _dataSource.categories();

  @override
  Future<List<Product>> products() => _dataSource.products();
}
