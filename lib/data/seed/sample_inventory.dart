import '../../domain/entities/product.dart';
import '../../domain/entities/quantity.dart';
import '../../domain/entities/stock.dart';
import '../../domain/entities/storage.dart';

/// Встроенные категории (нейтральные иконки, маппинг iconId → IconData в UI).
abstract final class SampleCategories {
  static const dairy = ProductCategory(id: 'dairy', name: 'Молочное', iconId: 'dairy');
  static const eggs = ProductCategory(id: 'eggs', name: 'Яйца', iconId: 'eggs');
  static const meat = ProductCategory(id: 'meat', name: 'Мясо', iconId: 'meat');
  static const fish = ProductCategory(id: 'fish', name: 'Рыба', iconId: 'fish');
  static const veg = ProductCategory(id: 'veg', name: 'Овощи', iconId: 'veg');
  static const fruit = ProductCategory(id: 'fruit', name: 'Фрукты', iconId: 'fruit');
  static const greens = ProductCategory(id: 'greens', name: 'Зелень', iconId: 'greens');
  static const bakery = ProductCategory(id: 'bakery', name: 'Выпечка', iconId: 'bakery');
}

/// Демонстрационные запасы с разными статусами срока — пока БД не подключена.
List<StockEntry> buildSampleInventory(DateTime today) {
  DateTime day(int offset) => today.add(Duration(days: offset));
  var seq = 0;
  String nextId() => 'seed_${++seq}';

  StockEntry entry({
    required String name,
    required ProductCategory cat,
    required StorageLocation loc,
    required Quantity qty,
    int? expiresInDays,
    int boughtDaysAgo = 2,
  }) {
    final id = nextId();
    return StockEntry(
      product: Product(id: 'p_$id', name: name, categoryId: cat.id),
      category: cat,
      batch: StockBatch(
        id: id,
        productId: 'p_$id',
        location: loc,
        quantity: qty,
        purchaseDate: day(-boughtDaysAgo),
        expiryDate: expiresInDays == null ? null : day(expiresInDays),
      ),
    );
  }

  return [
    entry(
      name: 'Куриное филе',
      cat: SampleCategories.meat,
      loc: StorageLocation.fridge,
      qty: const WeightQuantity(500, QtyUnit.gram),
      expiresInDays: -1,
    ),
    entry(
      name: 'Молоко',
      cat: SampleCategories.dairy,
      loc: StorageLocation.fridge,
      qty: const PacksQuantity(2, 1000, QtyUnit.milliliter),
      expiresInDays: 0,
    ),
    entry(
      name: 'Творог',
      cat: SampleCategories.dairy,
      loc: StorageLocation.fridge,
      qty: const WeightQuantity(250, QtyUnit.gram),
      expiresInDays: 2,
    ),
    entry(
      name: 'Яйца',
      cat: SampleCategories.eggs,
      loc: StorageLocation.fridge,
      qty: const CountQuantity(10),
      expiresInDays: 14,
    ),
    entry(
      name: 'Петрушка',
      cat: SampleCategories.greens,
      loc: StorageLocation.fridge,
      qty: const CountQuantity(1, unit: QtyUnit.bunch),
      expiresInDays: 1,
    ),
    entry(
      name: 'Лосось',
      cat: SampleCategories.fish,
      loc: StorageLocation.freezer,
      qty: const WeightQuantity(1.2 * 1000, QtyUnit.gram),
      expiresInDays: 40,
    ),
    entry(
      name: 'Яблоки',
      cat: SampleCategories.fruit,
      loc: StorageLocation.pantry,
      qty: const WeightQuantity(1500, QtyUnit.gram),
      expiresInDays: 10,
    ),
    entry(
      name: 'Гречка',
      cat: SampleCategories.bakery,
      loc: StorageLocation.pantry,
      qty: const WeightQuantity(900, QtyUnit.gram),
    ),
  ];
}
