import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/stock.dart';
import '../../../domain/repositories/stock_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit(this._repository) : super(const InventoryState()) {
    _sub = _repository.watchInventory().listen((items) {
      emit(state.copyWith(isLoading: false, all: items));
    });
  }

  final StockRepository _repository;
  late final StreamSubscription<List<StockEntry>> _sub;

  void setLocation(String location) =>
      emit(state.copyWith(location: location));

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setSort(SortMode sort) => emit(state.copyWith(sort: sort));

  StockEntry? entryById(String id) {
    for (final e in state.all) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> addBatch(StockEntry entry) => _repository.addBatch(entry);

  Future<void> updateBatch(StockEntry entry) => _repository.updateBatch(entry);

  Future<void> use(String batchId, UsageEvent event) =>
      _repository.applyUsage(batchId, event);

  Future<void> discard(String batchId) => _repository.discard(batchId);

  Future<List<StockEntry>> loadUsedUp() => _repository.loadUsedUp();

  Future<List<String>> loadCustomLocations() =>
      _repository.loadCustomLocations();

  Future<void> addLocation(String name) => _repository.addLocation(name);

  Future<void> renameLocation(String from, String to) =>
      _repository.renameLocation(from, to);

  Future<void> deleteLocation(String name) => _repository.deleteLocation(name);

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
