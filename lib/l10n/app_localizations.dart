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
