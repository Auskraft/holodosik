import 'package:equatable/equatable.dart';

import '../../../domain/entities/expiry.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';

class InventoryState extends Equatable {
  const InventoryState({
    this.isLoading = true,
    this.all = const [],
    this.location = LocationFilter.all,
    this.query = '',
    this.sort = SortMode.byExpiry,
  });

  final bool isLoading;
  final List<StockEntry> all;
  final LocationFilter location;
  final String query;
  final SortMode sort;

  /// Сколько продуктов требует внимания (просрочено или скоро испортится).
  int get attentionCount {
    final today = DateTime.now();
    return all.where((e) {
      final s = e.expiryInfo(today).status;
      return s == ExpiryStatus.expired || s == ExpiryStatus.soon;
    }).length;
  }

  /// Отфильтрованный и отсортированный список для ленты.
  List<StockEntry> get visible {
    final today = DateTime.now();
    final q = query.trim().toLowerCase();

    final filtered = all.where((e) {
      if (!location.matches(e.location)) return false;
      if (q.isEmpty) return true;
      return e.name.toLowerCase().contains(q) ||
          e.category.name.toLowerCase().contains(q);
    }).toList();

    int expiryKey(StockEntry e) => e.expiryInfo(today).daysLeft ?? 1 << 30;

    filtered.sort(switch (sort) {
      SortMode.byExpiry => (a, b) => expiryKey(a).compareTo(expiryKey(b)),
      SortMode.byCategory => (a, b) {
          final c = a.category.name.compareTo(b.category.name);
          return c != 0 ? c : a.name.compareTo(b.name);
        },
      SortMode.byName => (a, b) => a.name.compareTo(b.name),
    });
    return filtered;
  }

  InventoryState copyWith({
    bool? isLoading,
    List<StockEntry>? all,
    LocationFilter? location,
    String? query,
    SortMode? sort,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      all: all ?? this.all,
      location: location ?? this.location,
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [isLoading, all, location, query, sort];
}
