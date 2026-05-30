import '../../domain/entities/expiry.dart';
import '../../l10n/app_localizations.dart';

/// Локализованные подписи статуса срока.
abstract final class ExpiryPresenter {
  static String label(AppL10n l, ExpiryStatus status) => switch (status) {
        ExpiryStatus.fresh => l.statusFresh,
        ExpiryStatus.soon => l.statusSoon,
        ExpiryStatus.expired => l.statusExpired,
        ExpiryStatus.none => l.statusNoExpiry,
      };

  /// Хинт под количеством: «ещё 5 дн.», «годен сегодня», «просрочено на 2 дн.».
  static String? hint(AppL10n l, ExpiryInfo info) {
    final days = info.daysLeft;
    return switch (info.status) {
      ExpiryStatus.none => null,
      ExpiryStatus.expired => l.expiredDaysAgo(days!.abs()),
      ExpiryStatus.soon when days == 0 => l.expiryToday,
      ExpiryStatus.soon when days == 1 => l.expiryTomorrow,
      ExpiryStatus.soon => l.expiryDaysLeft(days!),
      ExpiryStatus.fresh => l.expiryDaysLeft(days!),
    };
  }
}
