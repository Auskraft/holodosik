// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Холодосик';

  @override
  String get navInventory => 'Запасы';

  @override
  String get navUrgent => 'Срочное';

  @override
  String get navCatalog => 'Справочник';

  @override
  String get navSettings => 'Настройки';

  @override
  String inventoryProductsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продукта',
      many: '$count продуктов',
      few: '$count продукта',
      one: '$count продукт',
    );
    return '$_temp0';
  }

  @override
  String inventoryAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count требуют внимания',
      many: '$count требуют внимания',
      few: '$count требуют внимания',
      one: '$count требует внимания',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Поиск по названию';

  @override
  String get locAll => 'Все';

  @override
  String get locFridge => 'Холодильник';

  @override
  String get locFreezer => 'Морозилка';

  @override
  String get locPantry => 'Шкаф';

  @override
  String get sortExpiry => 'По сроку';

  @override
  String get sortCategory => 'По категории';

  @override
  String get sortName => 'По названию';

  @override
  String get emptyStockTitle => 'Здесь пусто';

  @override
  String get emptyStockAction => 'Добавьте первый продукт';

  @override
  String get emptySearch => 'Ничего не нашлось';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get langRu => 'Русский';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeWarm => 'Тёплая';

  @override
  String get statusFresh => 'Свежее';

  @override
  String get statusSoon => 'Скоро';

  @override
  String get statusExpired => 'Просрочено';

  @override
  String get statusLow => 'Заканчивается';

  @override
  String get statusNoExpiry => 'Без срока';

  @override
  String get expiryToday => 'годен сегодня';

  @override
  String get expiryTomorrow => 'годен до завтра';

  @override
  String expiryDaysLeft(int days) {
    return 'ещё $days дн.';
  }

  @override
  String expiredDaysAgo(int days) {
    return 'просрочено на $days дн.';
  }

  @override
  String qtyTotal(String value) {
    return 'итого $value';
  }

  @override
  String get actionUse => 'Использовать';

  @override
  String get detailInStock => 'В наличии';

  @override
  String get detailExpiry => 'Срок годности';

  @override
  String get detailPurchased => 'Куплено';

  @override
  String get detailOpened => 'Вскрыто';

  @override
  String get detailLocation => 'Место хранения';

  @override
  String get detailHistory => 'История использования';

  @override
  String get detailNoHistory => 'Пока ничего не брали';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionDiscard => 'Списать';

  @override
  String get actionAddBatch => 'Ещё партию';

  @override
  String get useAmountLabel => 'Сколько берём';

  @override
  String get useQuarter => 'Четверть';

  @override
  String get useHalf => 'Половина';

  @override
  String get useAll => 'Всё';

  @override
  String useRemaining(String value) {
    return 'Останется $value';
  }

  @override
  String get useWillBeUsedUp => 'Запас уйдёт в использованные';

  @override
  String get useConfirm => 'Подтвердить';

  @override
  String get reasonCooked => 'Приготовили';

  @override
  String get reasonConsumed => 'Съели';

  @override
  String get reasonSpoiled => 'Испортилось';

  @override
  String get reasonThrown => 'Выбросили';

  @override
  String get toastUsed => 'Использовали';

  @override
  String get toastDiscarded => 'Списано';

  @override
  String get urgentTitle => 'Срочное';

  @override
  String get urgentEmpty => 'Всё под контролем';

  @override
  String get catalogTitle => 'Справочник';

  @override
  String get comingSoon => 'Скоро';
}
