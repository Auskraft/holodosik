/// Место хранения партии.
enum StorageLocation { fridge, freezer, pantry }

/// Фильтр места на главной (включает «Все»).
enum LocationFilter {
  all,
  fridge,
  freezer,
  pantry;

  bool matches(StorageLocation loc) => switch (this) {
        LocationFilter.all => true,
        LocationFilter.fridge => loc == StorageLocation.fridge,
        LocationFilter.freezer => loc == StorageLocation.freezer,
        LocationFilter.pantry => loc == StorageLocation.pantry,
      };
}
