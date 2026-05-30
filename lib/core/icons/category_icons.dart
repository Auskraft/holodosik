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
    'grain': Icons.rice_bowl_outlined,
    'spices': Icons.soup_kitchen_outlined,
    'legumes': Icons.bubble_chart_outlined,
    'mushroom': Icons.forest_outlined,
    'canned': Icons.inventory_2_outlined,
    'pasta': Icons.ramen_dining_outlined,
    'oil': Icons.water_drop_outlined,
    'drink': Icons.local_bar_outlined,
    'baking': Icons.cake_outlined,
    'sweet': Icons.cookie_outlined,
    'sauce': Icons.local_dining_outlined,
    'nuts': Icons.spa_outlined,
    'other': Icons.inventory_2_outlined,
  };

  static IconData of(String iconId) => _map[iconId] ?? Icons.inventory_2_outlined;
}
