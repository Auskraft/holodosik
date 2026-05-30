import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/catalog_repository.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState()) {
    _load();
  }

  final CatalogRepository _repository;

  Future<void> _load() async {
    await _repository.ensureSeeded();
    final categories = await _repository.categories();
    final products = await _repository.products();
    emit(state.copyWith(
      isLoading: false,
      categories: categories,
      products: products,
    ));
  }

  void setQuery(String query) => emit(state.copyWith(query: query));
}
