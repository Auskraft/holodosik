import 'package:equatable/equatable.dart';

/// Категория продукта. `iconId` — имя иконки, маппится на IconData в UI
/// (домен не зависит от Flutter).
class ProductCategory extends Equatable {
  const ProductCategory({
    required this.id,
    required this.name,
    required this.iconId,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String iconId;
  final int sortOrder;

  @override
  List<Object?> get props => [id, name, iconId, sortOrder];
}

/// Продукт из справочника — «что вообще бывает», а не конкретная партия.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  final String id;
  final String name;
  final String categoryId;

  @override
  List<Object?> get props => [id, name, categoryId];
}
