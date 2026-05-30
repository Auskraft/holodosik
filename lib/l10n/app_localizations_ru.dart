// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'холодос';

  @override
  String get navInventory => 'Запасы';

  @override
  String get navUrgent => 'Срочное';

  @override
  String get navCatalog => 'Справочник';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeWarm => 'Тёплая';

  @override
  String get statusFresh => 'Свежее';

  @override
  String get statusSoon => 'Скоро испортится';

  @override
  String get statusExpired => 'Просрочено';

  @override
  String get statusLow => 'Заканчивается';

  @override
  String get actionUse => 'Использовать';
}
