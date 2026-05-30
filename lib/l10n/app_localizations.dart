import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// Бренд-логотип приложения (шрифт Unbounded)
  ///
  /// In ru, this message translates to:
  /// **'Холодосик'**
  String get appName;

  /// No description provided for @navInventory.
  ///
  /// In ru, this message translates to:
  /// **'Запасы'**
  String get navInventory;

  /// No description provided for @navUrgent.
  ///
  /// In ru, this message translates to:
  /// **'Срочное'**
  String get navUrgent;

  /// No description provided for @navCatalog.
  ///
  /// In ru, this message translates to:
  /// **'Справочник'**
  String get navCatalog;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @inventoryProductsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} продукт} few{{count} продукта} many{{count} продуктов} other{{count} продукта}}'**
  String inventoryProductsCount(int count);

  /// No description provided for @inventoryAttentionCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} требует внимания} few{{count} требуют внимания} many{{count} требуют внимания} other{{count} требуют внимания}}'**
  String inventoryAttentionCount(int count);

  /// No description provided for @searchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию'**
  String get searchHint;

  /// No description provided for @locAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get locAll;

  /// No description provided for @locFridge.
  ///
  /// In ru, this message translates to:
  /// **'Холодильник'**
  String get locFridge;

  /// No description provided for @locFreezer.
  ///
  /// In ru, this message translates to:
  /// **'Морозилка'**
  String get locFreezer;

  /// No description provided for @locPantry.
  ///
  /// In ru, this message translates to:
  /// **'Шкаф'**
  String get locPantry;

  /// No description provided for @sortExpiry.
  ///
  /// In ru, this message translates to:
  /// **'По сроку'**
  String get sortExpiry;

  /// No description provided for @sortCategory.
  ///
  /// In ru, this message translates to:
  /// **'По категории'**
  String get sortCategory;

  /// No description provided for @sortName.
  ///
  /// In ru, this message translates to:
  /// **'По названию'**
  String get sortName;

  /// No description provided for @emptyStockTitle.
  ///
  /// In ru, this message translates to:
  /// **'Здесь пусто'**
  String get emptyStockTitle;

  /// No description provided for @emptyStockAction.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первый продукт'**
  String get emptyStockAction;

  /// No description provided for @emptySearch.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не нашлось'**
  String get emptySearch;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @langRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get langRu;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeWarm.
  ///
  /// In ru, this message translates to:
  /// **'Тёплая'**
  String get themeWarm;

  /// No description provided for @statusFresh.
  ///
  /// In ru, this message translates to:
  /// **'Свежее'**
  String get statusFresh;

  /// No description provided for @statusSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get statusSoon;

  /// No description provided for @statusExpired.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get statusExpired;

  /// No description provided for @statusLow.
  ///
  /// In ru, this message translates to:
  /// **'Заканчивается'**
  String get statusLow;

  /// No description provided for @statusNoExpiry.
  ///
  /// In ru, this message translates to:
  /// **'Без срока'**
  String get statusNoExpiry;

  /// No description provided for @expiryToday.
  ///
  /// In ru, this message translates to:
  /// **'годен сегодня'**
  String get expiryToday;

  /// No description provided for @expiryTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'годен до завтра'**
  String get expiryTomorrow;

  /// No description provided for @expiryDaysLeft.
  ///
  /// In ru, this message translates to:
  /// **'ещё {days} дн.'**
  String expiryDaysLeft(int days);

  /// No description provided for @expiredDaysAgo.
  ///
  /// In ru, this message translates to:
  /// **'просрочено на {days} дн.'**
  String expiredDaysAgo(int days);

  /// No description provided for @qtyTotal.
  ///
  /// In ru, this message translates to:
  /// **'итого {value}'**
  String qtyTotal(String value);

  /// No description provided for @actionUse.
  ///
  /// In ru, this message translates to:
  /// **'Использовать'**
  String get actionUse;

  /// No description provided for @detailInStock.
  ///
  /// In ru, this message translates to:
  /// **'В наличии'**
  String get detailInStock;

  /// No description provided for @detailExpiry.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности'**
  String get detailExpiry;

  /// No description provided for @detailPurchased.
  ///
  /// In ru, this message translates to:
  /// **'Куплено'**
  String get detailPurchased;

  /// No description provided for @detailOpened.
  ///
  /// In ru, this message translates to:
  /// **'Вскрыто'**
  String get detailOpened;

  /// No description provided for @detailLocation.
  ///
  /// In ru, this message translates to:
  /// **'Место хранения'**
  String get detailLocation;

  /// No description provided for @detailHistory.
  ///
  /// In ru, this message translates to:
  /// **'История использования'**
  String get detailHistory;

  /// No description provided for @detailNoHistory.
  ///
  /// In ru, this message translates to:
  /// **'Пока ничего не брали'**
  String get detailNoHistory;

  /// No description provided for @actionEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get actionEdit;

  /// No description provided for @actionDiscard.
  ///
  /// In ru, this message translates to:
  /// **'Списать'**
  String get actionDiscard;

  /// No description provided for @actionAddBatch.
  ///
  /// In ru, this message translates to:
  /// **'Ещё партию'**
  String get actionAddBatch;

  /// No description provided for @useAmountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сколько берём'**
  String get useAmountLabel;

  /// No description provided for @useQuarter.
  ///
  /// In ru, this message translates to:
  /// **'Четверть'**
  String get useQuarter;

  /// No description provided for @useHalf.
  ///
  /// In ru, this message translates to:
  /// **'Половина'**
  String get useHalf;

  /// No description provided for @useAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get useAll;

  /// No description provided for @useRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Останется {value}'**
  String useRemaining(String value);

  /// No description provided for @useWillBeUsedUp.
  ///
  /// In ru, this message translates to:
  /// **'Запас уйдёт в использованные'**
  String get useWillBeUsedUp;

  /// No description provided for @useConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get useConfirm;

  /// No description provided for @reasonCooked.
  ///
  /// In ru, this message translates to:
  /// **'Приготовили'**
  String get reasonCooked;

  /// No description provided for @reasonConsumed.
  ///
  /// In ru, this message translates to:
  /// **'Съели'**
  String get reasonConsumed;

  /// No description provided for @reasonSpoiled.
  ///
  /// In ru, this message translates to:
  /// **'Испортилось'**
  String get reasonSpoiled;

  /// No description provided for @reasonThrown.
  ///
  /// In ru, this message translates to:
  /// **'Выбросили'**
  String get reasonThrown;

  /// No description provided for @toastUsed.
  ///
  /// In ru, this message translates to:
  /// **'Использовали'**
  String get toastUsed;

  /// No description provided for @toastDiscarded.
  ///
  /// In ru, this message translates to:
  /// **'Списано'**
  String get toastDiscarded;

  /// No description provided for @toastAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в запасы'**
  String get toastAdded;

  /// No description provided for @addTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый запас'**
  String get addTitle;

  /// No description provided for @editTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить запас'**
  String get editTitle;

  /// No description provided for @saveEdit.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get saveEdit;

  /// No description provided for @toastSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get toastSaved;

  /// No description provided for @addSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Найдите продукт'**
  String get addSearchHint;

  /// No description provided for @addManually.
  ///
  /// In ru, this message translates to:
  /// **'Добавить «{name}» вручную'**
  String addManually(String name);

  /// No description provided for @fieldAmount.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get fieldAmount;

  /// No description provided for @fieldUnit.
  ///
  /// In ru, this message translates to:
  /// **'Единица измерения'**
  String get fieldUnit;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Прочее'**
  String get categoryOther;

  /// No description provided for @recentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ранее добавленные'**
  String get recentTitle;

  /// No description provided for @searchPromptEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Начните вводить название продукта'**
  String get searchPromptEmpty;

  /// No description provided for @addLocationChip.
  ///
  /// In ru, this message translates to:
  /// **'Своё место'**
  String get addLocationChip;

  /// No description provided for @addLocationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое место хранения'**
  String get addLocationTitle;

  /// No description provided for @addLocationHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Балкон'**
  String get addLocationHint;

  /// No description provided for @locationRename.
  ///
  /// In ru, this message translates to:
  /// **'Изменить название'**
  String get locationRename;

  /// No description provided for @locationDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get locationDelete;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @fieldName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get fieldName;

  /// No description provided for @fieldNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например, Молоко'**
  String get fieldNameHint;

  /// No description provided for @qtyModeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как считаем количество'**
  String get qtyModeTitle;

  /// No description provided for @qtyModeCount.
  ///
  /// In ru, this message translates to:
  /// **'Поштучно'**
  String get qtyModeCount;

  /// No description provided for @qtyModeWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес и объём'**
  String get qtyModeWeight;

  /// No description provided for @qtyModePacks.
  ///
  /// In ru, this message translates to:
  /// **'Упаковки'**
  String get qtyModePacks;

  /// No description provided for @packsCountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Упаковок'**
  String get packsCountLabel;

  /// No description provided for @perPackLabel.
  ///
  /// In ru, this message translates to:
  /// **'В каждой'**
  String get perPackLabel;

  /// No description provided for @fieldCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get fieldCategory;

  /// No description provided for @fieldLocation.
  ///
  /// In ru, this message translates to:
  /// **'Место хранения'**
  String get fieldLocation;

  /// No description provided for @fieldExpiry.
  ///
  /// In ru, this message translates to:
  /// **'Срок годности'**
  String get fieldExpiry;

  /// No description provided for @pickDate.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать дату'**
  String get pickDate;

  /// No description provided for @saveAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в запасы'**
  String get saveAdd;

  /// No description provided for @validationName.
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get validationName;

  /// No description provided for @validationCategory.
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get validationCategory;

  /// No description provided for @usedUpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Использованные'**
  String get usedUpTitle;

  /// No description provided for @usedUpEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Здесь пока пусто'**
  String get usedUpEmpty;

  /// No description provided for @usedUpLabel.
  ///
  /// In ru, this message translates to:
  /// **'Израсходовано'**
  String get usedUpLabel;

  /// No description provided for @urgentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Срочное'**
  String get urgentTitle;

  /// No description provided for @urgentEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Всё под контролем'**
  String get urgentEmpty;

  /// No description provided for @urgentExpired.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get urgentExpired;

  /// No description provided for @urgentToday.
  ///
  /// In ru, this message translates to:
  /// **'Годен сегодня'**
  String get urgentToday;

  /// No description provided for @urgentUpcoming.
  ///
  /// In ru, this message translates to:
  /// **'В ближайшие дни'**
  String get urgentUpcoming;

  /// No description provided for @catalogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Справочник'**
  String get catalogTitle;

  /// No description provided for @comingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get comingSoon;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
