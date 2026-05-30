/// Статус срока годности. Вычисляется, не вводится руками.
enum ExpiryStatus { fresh, soon, expired, none }

/// Результат разбора срока: статус + остаток дней (null, если срока нет).
typedef ExpiryInfo = ({ExpiryStatus status, int? daysLeft});

/// Правило статусов: <0 — просрочено, 0..3 — скоро, >3 — свежее, null — без срока.
ExpiryInfo resolveExpiry(DateTime? expiry, DateTime today) {
  if (expiry == null) return (status: ExpiryStatus.none, daysLeft: null);
  final e = DateTime(expiry.year, expiry.month, expiry.day);
  final t = DateTime(today.year, today.month, today.day);
  final days = e.difference(t).inDays;
  if (days < 0) return (status: ExpiryStatus.expired, daysLeft: days);
  if (days <= 3) return (status: ExpiryStatus.soon, daysLeft: days);
  return (status: ExpiryStatus.fresh, daysLeft: days);
}
