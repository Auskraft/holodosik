import 'package:flutter/material.dart';

/// Маппинг `iconId` категории → нейтральная иконка. Категории не раскрашиваем.
abstract final class CategoryIcons {
  static const Map<String, IconData> _map = {
    'dairy': Icons.local_drink_outlined,
    'eggs': Icons.egg_outlined,
    'meat': Icons.lunch_dining_outlined,
    'fish': Icons.set_meal_outlined,
    'veg': Icons.eco_outlined,
    'fruit': Icons.spa_outlined,
    'greens': Icons.grass_outlined,
    'bakery': Icons.bakery_dining_outlined,
  };

  static IconData of(String iconId) => _map[iconId] ?? Icons.inventory_2_outlined;
}
