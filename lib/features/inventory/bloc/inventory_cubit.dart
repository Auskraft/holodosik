import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../domain/repositories/stock_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repository) : super(const InventoryState()) {
    _load();
  }

  final StockRepository _repository;

  Future<void> _load() async {
    final items = await _repository.loadInventory();
    emit(state.copyWith(isLoading: false, all: items));
  }

  void setLocation(LocationFilter location) =>
      emit(state.copyWith(location: location));

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setSort(SortMode sort) => emit(state.copyWith(sort: sort));
}
