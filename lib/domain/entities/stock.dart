import 'package:equatable/equatable.dart';

import 'expiry.dart';
import 'product.dart';
import 'quantity.dart';
import 'storage.dart';

/// Причина расхода.
enum UsageReason { consumed, cooked, discarded, expired, other }

/// Запись журнала использования. Уменьшает остаток партии, остаётся в истории.
class UsageEvent extends Equatable {
  const UsageEvent({
    required this.id,
    required this.amount,
    required this.reason,
    required this.timestamp,
    this.note,
  });

  final String id;
  final Quantity amount;
  final UsageReason reason;
  final DateTime timestamp;
  final String? note;

  @override
  List<Object?> get props => [id, amount, reason, timestamp, note];
}

/// Партия — конкретная единица в хранилище. Срок и количество — у партии.
class StockBatch extends Equatable {
  const StockBatch({
    required this.id,
    required this.productId,
    required this.location,
    required this.quantity,
    this.purchaseDate,
    this.expiryDate,
    this.openedDate,
    this.note,
    this.history = const [],
  });

  final String id;
  final String productId;
  final StorageLocation location;
  final Quantity quantity;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final DateTime? openedDate;
  final String? note;
  final List<UsageEvent> history;

  @override
  List<Object?> get props =>
      [id, productId, location, quantity, purchaseDate, expiryDate, openedDate, note, history];
}

/// Партия в сборе с продуктом и категорией — то, что показывает UI.
class StockEntry extends Equatable {
  const StockEntry({
    required this.batch,
    required this.product,
    required this.category,
  });

  final StockBatch batch;
  final Product product;
  final ProductCategory category;

  String get id => batch.id;
  String get name => product.name;
  Quantity get quantity => batch.quantity;
  StorageLocation get location => batch.location;

  ExpiryInfo expiryInfo(DateTime today) => resolveExpiry(batch.expiryDate, today);

  @override
  List<Object?> get props => [batch, product, category];
}

/// Способ сортировки ленты запасов.
enum SortMode { byExpiry, byCategory, byName }
