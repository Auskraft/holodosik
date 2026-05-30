/// Места хранения — свободные строки (встроенные + пользовательские).
abstract final class StorageLocations {
  static const String fridge = 'Холодильник';
  static const String freezer = 'Морозилка';
  static const String pantry = 'Шкаф';

  /// Встроенные места, всегда доступны в выборе и фильтре.
  static const List<String> builtins = [fridge, freezer, pantry];
}
