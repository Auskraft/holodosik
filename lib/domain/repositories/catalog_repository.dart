import '../entities/product.dart';

/// Справочник продуктов: категории и продукты (включая отсутствующие в запасах).
abstract interface class CatalogRepository {
  /// Импортирует встроенный справочник при первом запуске (если БД пуста).
  Future<void> ensureSeeded();
  Future<List<ProductCategory>> categories();
  Future<List<Product>> products();
}
