import '../../domain/entities/stock.dart';
import '../../l10n/app_localizations.dart';

/// Локализованные подписи причин расхода.
extension UsageReasonLabel on UsageReason {
  String label(AppL10n l) => switch (this) {
        UsageReason.cooked => l.reasonCooked,
        UsageReason.consumed => l.reasonConsumed,
        UsageReason.expired => l.reasonSpoiled,
        UsageReason.discarded => l.reasonThrown,
        UsageReason.other => l.reasonConsumed,
      };
}
