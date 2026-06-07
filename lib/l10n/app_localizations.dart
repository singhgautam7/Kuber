import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'Start my journey'**
  String get startJourney;

  /// No description provided for @yourMoneyYourRules.
  ///
  /// In en, this message translates to:
  /// **'Your money.\nYour rules.'**
  String get yourMoneyYourRules;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'An expense manager that lives on your device. No cloud, no signup, no compromises.'**
  String get onboardingPage1Description;

  /// No description provided for @offlineFirstBadge.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE-FIRST · {version}'**
  String offlineFirstBadge(String version);

  /// No description provided for @privateByDesign.
  ///
  /// In en, this message translates to:
  /// **'Private by design.'**
  String get privateByDesign;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Your money stays on your device. No telemetry, no syncing, no third parties.'**
  String get onboardingPage2Description;

  /// No description provided for @fullyOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Fully offline'**
  String get fullyOfflineTitle;

  /// No description provided for @fullyOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'No cloud servers. Nothing to breach. Works in airplane mode.'**
  String get fullyOfflineBody;

  /// No description provided for @noAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No account needed'**
  String get noAccountTitle;

  /// No description provided for @noAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Open the app and start. Zero signup, zero friction.'**
  String get noAccountBody;

  /// No description provided for @privacyModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode'**
  String get privacyModeTitle;

  /// No description provided for @privacyModeBody.
  ///
  /// In en, this message translates to:
  /// **'One tap hides every balance when you hand over your phone.'**
  String get privacyModeBody;

  /// No description provided for @modulesTitle.
  ///
  /// In en, this message translates to:
  /// **'8+ MODULES · ZERO CLUTTER'**
  String get modulesTitle;

  /// No description provided for @everythingInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'Everything in\none quiet place.'**
  String get everythingInOnePlace;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Track expenses, plan budgets, monitor portfolios, and ask Kuber for answers.'**
  String get onboardingPage3Description;

  /// No description provided for @budgetsModule.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsModule;

  /// No description provided for @analyticsModule.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsModule;

  /// No description provided for @recurringModule.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringModule;

  /// No description provided for @lendBorrowModule.
  ///
  /// In en, this message translates to:
  /// **'Lend &\nborrow'**
  String get lendBorrowModule;

  /// No description provided for @investmentsModule.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsModule;

  /// No description provided for @askKuberModule.
  ///
  /// In en, this message translates to:
  /// **'Ask Kuber AI'**
  String get askKuberModule;

  /// No description provided for @toolsModule.
  ///
  /// In en, this message translates to:
  /// **'Tools &\nCalculators'**
  String get toolsModule;

  /// No description provided for @tagsCategoriesModule.
  ///
  /// In en, this message translates to:
  /// **'Tags &\nCategories'**
  String get tagsCategoriesModule;

  /// No description provided for @andMuchMore.
  ///
  /// In en, this message translates to:
  /// **'••• and much more!'**
  String get andMuchMore;

  /// No description provided for @makeItYours.
  ///
  /// In en, this message translates to:
  /// **'Make it yours.'**
  String get makeItYours;

  /// No description provided for @threeQuickChoices.
  ///
  /// In en, this message translates to:
  /// **'Three quick choices and you\'re in.'**
  String get threeQuickChoices;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get yourName;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get language;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get namePlaceholder;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be 15 characters or fewer'**
  String get nameTooLong;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'LIGHT'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'DARK'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get themeSystem;

  /// No description provided for @justSoYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Just so you know'**
  String get justSoYouKnow;

  /// No description provided for @goToTutorials.
  ///
  /// In en, this message translates to:
  /// **'Go to tutorials'**
  String get goToTutorials;

  /// No description provided for @exploreAtOwnPace.
  ///
  /// In en, this message translates to:
  /// **'You can explore at your own pace'**
  String get exploreAtOwnPace;

  /// No description provided for @exploreAtOwnPaceBody.
  ///
  /// In en, this message translates to:
  /// **'Kuber is built to feel familiar, so you can start logging right away.'**
  String get exploreAtOwnPaceBody;

  /// No description provided for @walkthroughNearby.
  ///
  /// In en, this message translates to:
  /// **'A walkthrough is always nearby'**
  String get walkthroughNearby;

  /// No description provided for @walkthroughNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'Open More, then App Tutorial, whenever you want a quick guided tour.'**
  String get walkthroughNearbyBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize how Kuber looks, feels and behaves for you.'**
  String get settingsSubtitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileSection;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'How Kuber knows you.'**
  String get profileDescription;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourNameLabel;

  /// No description provided for @userNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get userNameUpdated;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceSection;

  /// No description provided for @appearanceDescription.
  ///
  /// In en, this message translates to:
  /// **'How Kuber looks to you.'**
  String get appearanceDescription;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Light, dark, or match your phone'**
  String get themeSubtitle;

  /// No description provided for @bottomNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Bottom Navigation'**
  String get bottomNavLabel;

  /// No description provided for @bottomNavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard bar or floating pill'**
  String get bottomNavSubtitle;

  /// No description provided for @moreTabLayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'More Tab Layout'**
  String get moreTabLayoutLabel;

  /// No description provided for @moreTabLayoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple list or Modern hero layout'**
  String get moreTabLayoutSubtitle;

  /// No description provided for @widgetsSection.
  ///
  /// In en, this message translates to:
  /// **'WIDGETS'**
  String get widgetsSection;

  /// No description provided for @widgetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose what shows on Home and Analytics.'**
  String get widgetsDescription;

  /// No description provided for @homeWidgetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Home Widgets'**
  String get homeWidgetsLabel;

  /// No description provided for @homeWidgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} enabled · drag to reorder'**
  String homeWidgetsSubtitle(String count);

  /// No description provided for @analyticsWidgetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Analytics Widgets'**
  String get analyticsWidgetsLabel;

  /// No description provided for @analyticsWidgetsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} enabled · drag to reorder'**
  String analyticsWidgetsSubtitle(String count);

  /// No description provided for @moneyDisplaySection.
  ///
  /// In en, this message translates to:
  /// **'MONEY DISPLAY'**
  String get moneyDisplaySection;

  /// No description provided for @moneyDisplayDescription.
  ///
  /// In en, this message translates to:
  /// **'How currency and amounts are shown across the app.'**
  String get moneyDisplayDescription;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @currencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Symbol and code shown on amounts'**
  String get currencySubtitle;

  /// No description provided for @numberFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Number Format'**
  String get numberFormatLabel;

  /// No description provided for @numberFormatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Indian (1,23,000) or International (123,000)'**
  String get numberFormatSubtitle;

  /// No description provided for @transactionsSection.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTIONS'**
  String get transactionsSection;

  /// No description provided for @transactionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Your defaults when adding new entries.'**
  String get transactionsDescription;

  /// No description provided for @defaultAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Default Account'**
  String get defaultAccountLabel;

  /// No description provided for @defaultAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-selected when you Quick Add'**
  String get defaultAccountSubtitle;

  /// No description provided for @horizontalSwipeLabel.
  ///
  /// In en, this message translates to:
  /// **'Horizontal Swipe'**
  String get horizontalSwipeLabel;

  /// No description provided for @horizontalSwipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What swiping left or right does'**
  String get horizontalSwipeSubtitle;

  /// No description provided for @privacySecuritySection.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY & SECURITY'**
  String get privacySecuritySection;

  /// No description provided for @privacySecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your numbers private and your app locked.'**
  String get privacySecurityDescription;

  /// No description provided for @privacyModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Mode'**
  String get privacyModeLabel;

  /// No description provided for @privacyModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hide all balances and amounts'**
  String get privacyModeSubtitle;

  /// No description provided for @biometricLockLabel.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get biometricLockLabel;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with FaceID or Fingerprint'**
  String get biometricLockSubtitle;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutSection;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn about Kuber and the person behind it.'**
  String get aboutDescription;

  /// No description provided for @aboutKuberLabel.
  ///
  /// In en, this message translates to:
  /// **'About Kuber'**
  String get aboutKuberLabel;

  /// No description provided for @aboutKuberSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vision, origin, and a letter from the developer'**
  String get aboutKuberSubtitle;

  /// No description provided for @clearDefault.
  ///
  /// In en, this message translates to:
  /// **'Clear Default'**
  String get clearDefault;

  /// No description provided for @defaultAccountCleared.
  ///
  /// In en, this message translates to:
  /// **'Default account cleared'**
  String get defaultAccountCleared;

  /// No description provided for @noAccountsFound.
  ///
  /// In en, this message translates to:
  /// **'No accounts found.'**
  String get noAccountsFound;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Device authentication is not available or set up'**
  String get biometricNotAvailable;

  /// No description provided for @biometricEnabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock enabled'**
  String get biometricEnabledMsg;

  /// No description provided for @biometricDisabledMsg.
  ///
  /// In en, this message translates to:
  /// **'Biometric lock disabled'**
  String get biometricDisabledMsg;

  /// No description provided for @updateNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Name'**
  String get updateNameTitle;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterNameHint;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @themeLightChoice.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLightChoice;

  /// No description provided for @themeDarkChoice.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDarkChoice;

  /// No description provided for @themeSystemChoice.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystemChoice;

  /// No description provided for @themeSubtitleLight.
  ///
  /// In en, this message translates to:
  /// **'Bright surfaces, dark text'**
  String get themeSubtitleLight;

  /// No description provided for @themeSubtitleDark.
  ///
  /// In en, this message translates to:
  /// **'Black surfaces, light text'**
  String get themeSubtitleDark;

  /// No description provided for @themeSubtitleSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow your phone setting'**
  String get themeSubtitleSystem;

  /// No description provided for @navClassicChoice.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get navClassicChoice;

  /// No description provided for @navModernChoice.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get navModernChoice;

  /// No description provided for @navSubtitleClassic.
  ///
  /// In en, this message translates to:
  /// **'Standard bar'**
  String get navSubtitleClassic;

  /// No description provided for @navSubtitleModern.
  ///
  /// In en, this message translates to:
  /// **'Floating pill'**
  String get navSubtitleModern;

  /// No description provided for @numFormatIndian.
  ///
  /// In en, this message translates to:
  /// **'Indian'**
  String get numFormatIndian;

  /// No description provided for @numFormatInternational.
  ///
  /// In en, this message translates to:
  /// **'International'**
  String get numFormatInternational;

  /// No description provided for @swipeChangeTabs.
  ///
  /// In en, this message translates to:
  /// **'Change tabs'**
  String get swipeChangeTabs;

  /// No description provided for @swipeRowActions.
  ///
  /// In en, this message translates to:
  /// **'Row actions'**
  String get swipeRowActions;

  /// No description provided for @swipeSubtitleChangeTabs.
  ///
  /// In en, this message translates to:
  /// **'Quickly switch between main app sections by swiping across the screen'**
  String get swipeSubtitleChangeTabs;

  /// No description provided for @swipeSubtitleRowActions.
  ///
  /// In en, this message translates to:
  /// **'Perform quick actions like edit or delete by swiping on individual history items'**
  String get swipeSubtitleRowActions;

  /// No description provided for @spentTodayInsight.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} today, which is {diff} above your 30-day daily average of {avg}'**
  String spentTodayInsight(String amount, String diff, String avg);

  /// No description provided for @weekdayPatternInsight.
  ///
  /// In en, this message translates to:
  /// **'You typically spend {highest} on {dayName} vs {median} on other days'**
  String weekdayPatternInsight(String highest, String dayName, String median);

  /// No description provided for @topCategoryInsight.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of spending goes to {catName} ({amount})'**
  String topCategoryInsight(String pct, String catName, String amount);

  /// No description provided for @categoryTrendInsight.
  ///
  /// In en, this message translates to:
  /// **'{catName} spending is {change} vs last month'**
  String categoryTrendInsight(String catName, String change);

  /// No description provided for @monthComparisonInsight.
  ///
  /// In en, this message translates to:
  /// **'Spending is {change} vs this point last month'**
  String monthComparisonInsight(String change);

  /// No description provided for @weekendVsWeekdayInsight.
  ///
  /// In en, this message translates to:
  /// **'Weekend transactions average {weekend} vs {weekday} on weekdays'**
  String weekendVsWeekdayInsight(String weekend, String weekday);

  /// No description provided for @biggestExpenseInsight.
  ///
  /// In en, this message translates to:
  /// **'{name} ({amount}) was {ratio}× your typical spend'**
  String biggestExpenseInsight(String name, String amount, String ratio);

  /// No description provided for @savingsTrendPositive.
  ///
  /// In en, this message translates to:
  /// **'You\'re saving money this month. Keep it up!'**
  String get savingsTrendPositive;

  /// No description provided for @savingsTrendInsight.
  ///
  /// In en, this message translates to:
  /// **'Savings are {change} vs last month'**
  String savingsTrendInsight(String change);

  /// No description provided for @savingsTrendDipInsight.
  ///
  /// In en, this message translates to:
  /// **'Savings dipped {change} vs last month'**
  String savingsTrendDipInsight(String change);

  /// No description provided for @recurringBurdenInsight.
  ///
  /// In en, this message translates to:
  /// **'{pct} of spending is from recurring transactions'**
  String recurringBurdenInsight(String pct);

  /// No description provided for @streakInsight.
  ///
  /// In en, this message translates to:
  /// **'{streak}-day spending-free streak before today!'**
  String streakInsight(String streak);

  /// No description provided for @spendingFasterInsight.
  ///
  /// In en, this message translates to:
  /// **'You\'re spending {weekStr}/day this week, which is {diffStr} faster than your usual {baseStr}/day'**
  String spendingFasterInsight(String weekStr, String diffStr, String baseStr);

  /// No description provided for @categoryConcentrationInsight.
  ///
  /// In en, this message translates to:
  /// **'{pctStr} of your spending ({amtStr}) goes to just 3 categories'**
  String categoryConcentrationInsight(String pctStr, String amtStr);

  /// No description provided for @loanEmiTotalInsight.
  ///
  /// In en, this message translates to:
  /// **'Loan EMIs add up to {amount} this month'**
  String loanEmiTotalInsight(String amount);

  /// No description provided for @loanPayoffCountdownInsight.
  ///
  /// In en, this message translates to:
  /// **'{name} is about {months} month{pluralSuffix} from payoff'**
  String loanPayoffCountdownInsight(
    String name,
    String months,
    String pluralSuffix,
  );

  /// No description provided for @loanInterestPaidInsight.
  ///
  /// In en, this message translates to:
  /// **'Total loan interest paid is {amount} so far'**
  String loanInterestPaidInsight(String amount);

  /// No description provided for @ledgerOutstandingInsight.
  ///
  /// In en, this message translates to:
  /// **'Open lend and borrow totals are {receive} owed to you and {owe} owed by you'**
  String ledgerOutstandingInsight(String receive, String owe);

  /// No description provided for @ledgerOldestOpenInsight.
  ///
  /// In en, this message translates to:
  /// **'{personName} has the oldest open entry at {ageDays} days'**
  String ledgerOldestOpenInsight(String personName, String ageDays);

  /// No description provided for @investmentPortfolioChangeInsight.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is {amount} versus invested value'**
  String investmentPortfolioChangeInsight(String amount);

  /// No description provided for @investmentTopPerformerInsight.
  ///
  /// In en, this message translates to:
  /// **'{name} is your top performer at {pct} gain'**
  String investmentTopPerformerInsight(String name, String pct);

  /// No description provided for @investmentPeriodInvestedInsight.
  ///
  /// In en, this message translates to:
  /// **'You invested {amount} this month'**
  String investmentPeriodInvestedInsight(String amount);

  /// No description provided for @fallbackTipInsight.
  ///
  /// In en, this message translates to:
  /// **'Start adding transactions to unlock smart insights'**
  String get fallbackTipInsight;

  /// No description provided for @fallbackTotalInsight.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} in the last 30 days'**
  String fallbackTotalInsight(String amount);

  /// No description provided for @spentLastWeek.
  ///
  /// In en, this message translates to:
  /// **'spent last week'**
  String get spentLastWeek;

  /// No description provided for @spentLastMonth.
  ///
  /// In en, this message translates to:
  /// **'spent in {month}'**
  String spentLastMonth(String month);

  /// No description provided for @spentLastYear.
  ///
  /// In en, this message translates to:
  /// **'spent in {year}'**
  String spentLastYear(String year);

  /// No description provided for @averageDay.
  ///
  /// In en, this message translates to:
  /// **'About {amount} a day on average'**
  String averageDay(String amount);

  /// No description provided for @biggestDay.
  ///
  /// In en, this message translates to:
  /// **'{day} was your biggest day at {amount}'**
  String biggestDay(String day, String amount);

  /// No description provided for @savedEarned.
  ///
  /// In en, this message translates to:
  /// **'You saved {pct}% of what you earned'**
  String savedEarned(String pct);

  /// No description provided for @biggestSingleSpend.
  ///
  /// In en, this message translates to:
  /// **'Biggest single spend was {name} on {category}'**
  String biggestSingleSpend(String name, String category);

  /// No description provided for @spentLess.
  ///
  /// In en, this message translates to:
  /// **'You spent less than before'**
  String get spentLess;

  /// No description provided for @spentMore.
  ///
  /// In en, this message translates to:
  /// **'You spent more than before'**
  String get spentMore;

  /// No description provided for @comparedTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared'**
  String get comparedTitle;

  /// No description provided for @comparedLess.
  ///
  /// In en, this message translates to:
  /// **'You spent less than before'**
  String get comparedLess;

  /// No description provided for @comparedMore.
  ///
  /// In en, this message translates to:
  /// **'You spent more than before'**
  String get comparedMore;

  /// No description provided for @deltaLess.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than {label}'**
  String deltaLess(String amount, String label);

  /// No description provided for @deltaMore.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than {label}'**
  String deltaMore(String amount, String label);

  /// No description provided for @monthlyEmi.
  ///
  /// In en, this message translates to:
  /// **'Monthly EMI'**
  String get monthlyEmi;

  /// No description provided for @principal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principal;

  /// No description provided for @lender.
  ///
  /// In en, this message translates to:
  /// **'Lender'**
  String get lender;

  /// No description provided for @ledgerOwesYou.
  ///
  /// In en, this message translates to:
  /// **'{person} owes you {amount}'**
  String ledgerOwesYou(String person, String amount);

  /// No description provided for @ledgerYouOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe {person} {amount}'**
  String ledgerYouOwe(String person, String amount);

  /// No description provided for @ledgerEntryOpen.
  ///
  /// In en, this message translates to:
  /// **'This entry is still open.'**
  String get ledgerEntryOpen;

  /// No description provided for @portfolioCheck.
  ///
  /// In en, this message translates to:
  /// **'Portfolio check'**
  String get portfolioCheck;

  /// No description provided for @investedLabel.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get investedLabel;

  /// No description provided for @currentValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get currentValueLabel;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kuber'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for installing. Your money, beautifully tracked.'**
  String get welcomeSubtitle;

  /// No description provided for @basicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Track every rupee'**
  String get basicsTitle;

  /// No description provided for @basicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses, income, transfers, and budgets, all in one place.'**
  String get basicsSubtitle;

  /// No description provided for @beyondBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'There is more in here'**
  String get beyondBasicsTitle;

  /// No description provided for @beyondBasicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lend and borrow, EMIs, investments, and handy calculators.'**
  String get beyondBasicsSubtitle;

  /// No description provided for @spaceIsYoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money stories'**
  String get spaceIsYoursTitle;

  /// No description provided for @spaceIsYoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recaps and highlights about your spending will appear right here.'**
  String get spaceIsYoursSubtitle;

  /// No description provided for @spentYesterday.
  ///
  /// In en, this message translates to:
  /// **'spent yesterday'**
  String get spentYesterday;

  /// No description provided for @topSpend.
  ///
  /// In en, this message translates to:
  /// **'Top spend: {name} on {category}'**
  String topSpend(String name, String category);

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top categories'**
  String get topCategories;

  /// No description provided for @noSpendDay.
  ///
  /// In en, this message translates to:
  /// **'A no spend day. Nice.'**
  String get noSpendDay;

  /// No description provided for @noSpendStreak.
  ///
  /// In en, this message translates to:
  /// **'That is a {streak} day no spend streak'**
  String noSpendStreak(String streak);

  /// No description provided for @noSpendStreakEnded.
  ///
  /// In en, this message translates to:
  /// **'Your {streak} day no spend streak ended'**
  String noSpendStreakEnded(String streak);

  /// No description provided for @dailyRecapHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyRecapHeader;

  /// No description provided for @weeklyRecapHeader.
  ///
  /// In en, this message translates to:
  /// **'Weekly recap'**
  String get weeklyRecapHeader;

  /// No description provided for @monthlyRecapHeader.
  ///
  /// In en, this message translates to:
  /// **'Monthly recap'**
  String get monthlyRecapHeader;

  /// No description provided for @yearlyRecapHeader.
  ///
  /// In en, this message translates to:
  /// **'Year in review'**
  String get yearlyRecapHeader;

  /// No description provided for @highlightHeader.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlightHeader;

  /// No description provided for @loansHeader.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansHeader;

  /// No description provided for @ledgerHeader.
  ///
  /// In en, this message translates to:
  /// **'Lend / Borrow'**
  String get ledgerHeader;

  /// No description provided for @investmentsHeader.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsHeader;

  /// No description provided for @averageMonth.
  ///
  /// In en, this message translates to:
  /// **'About {amount} a month on average'**
  String averageMonth(String amount);

  /// No description provided for @biggestMonth.
  ///
  /// In en, this message translates to:
  /// **'{month} was your biggest month at {amount}'**
  String biggestMonth(String month, String amount);

  /// No description provided for @lessLabel.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get lessLabel;

  /// No description provided for @moreLabel.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get moreLabel;

  /// No description provided for @theWeekBefore.
  ///
  /// In en, this message translates to:
  /// **'the week before'**
  String get theWeekBefore;

  /// No description provided for @aboveAverage.
  ///
  /// In en, this message translates to:
  /// **'{amount} above your 30-day average'**
  String aboveAverage(String amount);

  /// No description provided for @belowAverage.
  ///
  /// In en, this message translates to:
  /// **'{amount} below your 30-day average'**
  String belowAverage(String amount);

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toLabel;

  /// No description provided for @throughPeriod.
  ///
  /// In en, this message translates to:
  /// **'Through {date}'**
  String throughPeriod(String date);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @previousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous Week'**
  String get previousWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @previousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous Year'**
  String get previousYear;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @chooseAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get chooseAppLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search language'**
  String get searchLanguage;

  /// No description provided for @noLanguagesFound.
  ///
  /// In en, this message translates to:
  /// **'No languages found'**
  String get noLanguagesFound;

  /// No description provided for @appearanceCategory.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceCategory;

  /// No description provided for @moneyDisplayCategory.
  ///
  /// In en, this message translates to:
  /// **'Money Display'**
  String get moneyDisplayCategory;

  /// No description provided for @transactionsCategory.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsCategory;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @setYourName.
  ///
  /// In en, this message translates to:
  /// **'Set your name'**
  String get setYourName;

  /// No description provided for @simpleLabel.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get simpleLabel;

  /// No description provided for @creditCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCardLabel;

  /// No description provided for @bankCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank / Cash'**
  String get bankCashLabel;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'{name} set as default'**
  String setAsDefault(String name);

  /// No description provided for @nameSheetHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gautam'**
  String get nameSheetHint;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @moreTabSimpleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uniform list of cards. Familiar and predictable.'**
  String get moreTabSimpleSubtitle;

  /// No description provided for @moreTabModernSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hero items, tile grid and compact lists. Differentiated by section.'**
  String get moreTabModernSubtitle;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @searchCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, code or symbol…'**
  String get searchCurrencyHint;

  /// No description provided for @noCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get noCurrenciesFound;

  /// No description provided for @welcomeHeader.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeHeader;

  /// No description provided for @basicsHeader.
  ///
  /// In en, this message translates to:
  /// **'The basics'**
  String get basicsHeader;

  /// No description provided for @beyondBasicsHeader.
  ///
  /// In en, this message translates to:
  /// **'Beyond the basics'**
  String get beyondBasicsHeader;

  /// No description provided for @spaceIsYoursHeader.
  ///
  /// In en, this message translates to:
  /// **'This space is yours'**
  String get spaceIsYoursHeader;

  /// No description provided for @homeSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Let\'s manage your money wisely'**
  String get homeSubtitle1;

  /// No description provided for @homeSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Track every rupee, every day'**
  String get homeSubtitle2;

  /// No description provided for @homeSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your finances'**
  String get homeSubtitle3;

  /// No description provided for @homeSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Your wallet will thank you later'**
  String get homeSubtitle4;

  /// No description provided for @homeSubtitle5.
  ///
  /// In en, this message translates to:
  /// **'Small savings, big results'**
  String get homeSubtitle5;

  /// No description provided for @homeSubtitle6.
  ///
  /// In en, this message translates to:
  /// **'Every transaction counts'**
  String get homeSubtitle6;

  /// No description provided for @homeSubtitle7.
  ///
  /// In en, this message translates to:
  /// **'Building smart money habits'**
  String get homeSubtitle7;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get greetingEvening;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'LAST 7 DAYS'**
  String get last7Days;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get netLabel;

  /// No description provided for @spendingAnalysisEmpty.
  ///
  /// In en, this message translates to:
  /// **'No income or expense transactions in the last 7 days. Add a transaction to see your spending analysis here.\n\nNote: Transfers are not included.'**
  String get spendingAnalysisEmpty;

  /// No description provided for @notificationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTooltip;

  /// No description provided for @askKuber.
  ///
  /// In en, this message translates to:
  /// **'Ask Kuber'**
  String get askKuber;

  /// No description provided for @privacyModeOn.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode: On'**
  String get privacyModeOn;

  /// No description provided for @privacyModeOff.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode: Off'**
  String get privacyModeOff;

  /// No description provided for @accountsLabel.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNTS'**
  String get accountsLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @outstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING'**
  String get outstandingLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE'**
  String get availableLabel;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankLabel;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @cashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashLabel;

  /// No description provided for @usedLabel.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get usedLabel;

  /// No description provided for @limitLabel.
  ///
  /// In en, this message translates to:
  /// **'limit'**
  String get limitLabel;

  /// No description provided for @recurringHeader.
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get recurringHeader;

  /// No description provided for @statusProcessed.
  ///
  /// In en, this message translates to:
  /// **'PROCESSED'**
  String get statusProcessed;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get statusScheduled;

  /// No description provided for @quickAddInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount (e.g. 200 on coffee)'**
  String get quickAddInvalidAmount;

  /// No description provided for @quickAddNoAccountNamed.
  ///
  /// In en, this message translates to:
  /// **'No account named \"{name}\" found'**
  String quickAddNoAccountNamed(String name);

  /// No description provided for @quickAddCouldNotResolveCategory.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve category'**
  String get quickAddCouldNotResolveCategory;

  /// No description provided for @quickAddAdded.
  ///
  /// In en, this message translates to:
  /// **'{amount} added to {category}'**
  String quickAddAdded(String amount, String category);

  /// No description provided for @noAccountFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No account found'**
  String get noAccountFoundTitle;

  /// No description provided for @noAccountMatchedBody.
  ///
  /// In en, this message translates to:
  /// **'No account matched \"{hint}\" and no default account is set. Set a default account in Settings to use Quick Add.'**
  String noAccountMatchedBody(String hint);

  /// No description provided for @noDefaultAccountBody.
  ///
  /// In en, this message translates to:
  /// **'No default account is set. Set one in Settings to use Quick Add.'**
  String get noDefaultAccountBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'QUICK ADD (BETA)'**
  String get quickAddTitle;

  /// No description provided for @quickAddInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAddInfoTitle;

  /// No description provided for @quickAddInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Record an expense instantly using natural language. No forms, no tapping. Just type what you spent and Kuber figures out the rest.'**
  String get quickAddInfoDesc;

  /// No description provided for @quickAddBasicAmount.
  ///
  /// In en, this message translates to:
  /// **'Basic Amount'**
  String get quickAddBasicAmount;

  /// No description provided for @quickAddBasicAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'\"250\" or \"₹250\" adds ₹250 to the General category.'**
  String get quickAddBasicAmountDesc;

  /// No description provided for @quickAddWithCategory.
  ///
  /// In en, this message translates to:
  /// **'With Category'**
  String get quickAddWithCategory;

  /// No description provided for @quickAddWithCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'\"250 on food\", \"150 in gaming\", \"300 for rent\" links to an existing category or creates one.'**
  String get quickAddWithCategoryDesc;

  /// No description provided for @quickAddWithAccount.
  ///
  /// In en, this message translates to:
  /// **'With Account'**
  String get quickAddWithAccount;

  /// No description provided for @quickAddWithAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'\"150 for uber from hdfc\" matches your HDFC account by name.'**
  String get quickAddWithAccountDesc;

  /// No description provided for @quickAddActionWords.
  ///
  /// In en, this message translates to:
  /// **'Action Words'**
  String get quickAddActionWords;

  /// No description provided for @quickAddActionWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'\"Add 200 on coffee\", \"Log 500 for groceries\", \"Create 1000 in savings\" - leading action words are stripped automatically.'**
  String get quickAddActionWordsDesc;

  /// No description provided for @quickAddDefaultAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Default Account'**
  String get quickAddDefaultAccountInfo;

  /// No description provided for @quickAddDefaultAccountInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a default account in Settings to skip typing \"from ...\" every time.'**
  String get quickAddDefaultAccountInfoDesc;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 250 on groceries from HDFC'**
  String get quickAddHint;

  /// No description provided for @spendingPattern.
  ///
  /// In en, this message translates to:
  /// **'SPENDING PATTERN'**
  String get spendingPattern;

  /// No description provided for @avgDaily.
  ///
  /// In en, this message translates to:
  /// **'AVG DAILY'**
  String get avgDaily;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'last 90 days'**
  String get last90Days;

  /// No description provided for @statThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get statThisMonth;

  /// No description provided for @statDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String statDays(String days);

  /// No description provided for @projectedLabel.
  ///
  /// In en, this message translates to:
  /// **'PROJECTED'**
  String get projectedLabel;

  /// No description provided for @endOfMonth.
  ///
  /// In en, this message translates to:
  /// **'end of month'**
  String get endOfMonth;

  /// No description provided for @budgetSnapshot.
  ///
  /// In en, this message translates to:
  /// **'BUDGET SNAPSHOT'**
  String get budgetSnapshot;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get budgetExceeded;

  /// No description provided for @budgetHighUsage.
  ///
  /// In en, this message translates to:
  /// **'High usage'**
  String get budgetHighUsage;

  /// No description provided for @budgetNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get budgetNearLimit;

  /// No description provided for @budgetOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get budgetOnTrack;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String budgetRemaining(String amount);

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'RECENT TRANSACTIONS'**
  String get recentTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @smartInsights.
  ///
  /// In en, this message translates to:
  /// **'SMART INSIGHTS'**
  String get smartInsights;

  /// No description provided for @smartInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Keep adding transactions to unlock\ninsights about your finances.'**
  String get smartInsightsEmpty;

  /// No description provided for @insightLabelWeekdayPattern.
  ///
  /// In en, this message translates to:
  /// **'WEEKDAY PATTERN'**
  String get insightLabelWeekdayPattern;

  /// No description provided for @insightLabelTopCategory.
  ///
  /// In en, this message translates to:
  /// **'TOP CATEGORY'**
  String get insightLabelTopCategory;

  /// No description provided for @insightLabelCategoryTrend.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY TREND'**
  String get insightLabelCategoryTrend;

  /// No description provided for @insightLabelMonthTrend.
  ///
  /// In en, this message translates to:
  /// **'MONTH TREND'**
  String get insightLabelMonthTrend;

  /// No description provided for @insightLabelWeekendPattern.
  ///
  /// In en, this message translates to:
  /// **'WEEKEND PATTERN'**
  String get insightLabelWeekendPattern;

  /// No description provided for @insightLabelBigExpense.
  ///
  /// In en, this message translates to:
  /// **'BIG EXPENSE'**
  String get insightLabelBigExpense;

  /// No description provided for @insightLabelSavings.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS'**
  String get insightLabelSavings;

  /// No description provided for @insightLabelRecurring.
  ///
  /// In en, this message translates to:
  /// **'RECURRING'**
  String get insightLabelRecurring;

  /// No description provided for @insightLabelStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get insightLabelStreak;

  /// No description provided for @insightLabelToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get insightLabelToday;

  /// No description provided for @insightLabelThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get insightLabelThisWeek;

  /// No description provided for @insightLabelDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'DID YOU KNOW'**
  String get insightLabelDidYouKnow;

  /// No description provided for @insightLabelLoans.
  ///
  /// In en, this message translates to:
  /// **'LOANS'**
  String get insightLabelLoans;

  /// No description provided for @insightLabelLoanInterest.
  ///
  /// In en, this message translates to:
  /// **'LOAN INTEREST'**
  String get insightLabelLoanInterest;

  /// No description provided for @insightLabelLendBorrow.
  ///
  /// In en, this message translates to:
  /// **'LEND / BORROW'**
  String get insightLabelLendBorrow;

  /// No description provided for @insightLabelInvestments.
  ///
  /// In en, this message translates to:
  /// **'INVESTMENTS'**
  String get insightLabelInvestments;

  /// No description provided for @insightLabelTopInvestment.
  ///
  /// In en, this message translates to:
  /// **'TOP INVESTMENT'**
  String get insightLabelTopInvestment;

  /// No description provided for @insightLabelSummary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get insightLabelSummary;

  /// No description provided for @insightLabelTip.
  ///
  /// In en, this message translates to:
  /// **'TIP'**
  String get insightLabelTip;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction\nHistory'**
  String get historyTitle;

  /// No description provided for @historyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your past expenses, incomes and transfers'**
  String get historyDescription;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @expLabel.
  ///
  /// In en, this message translates to:
  /// **'EXP'**
  String get expLabel;

  /// No description provided for @incLabel.
  ///
  /// In en, this message translates to:
  /// **'INC'**
  String get incLabel;

  /// No description provided for @showingLabel.
  ///
  /// In en, this message translates to:
  /// **'SHOWING'**
  String get showingLabel;

  /// No description provided for @transactionsLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTIONS'**
  String get transactionsLabel;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// No description provided for @startTrackingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses'**
  String get startTrackingExpenses;

  /// No description provided for @adjustSearchFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get adjustSearchFilters;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(String count);

  /// No description provided for @deleteTransactionsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} transactions?'**
  String deleteTransactionsConfirm(String count);

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @transactionsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions deleted'**
  String transactionsDeleted(String count);

  /// No description provided for @tagsMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String tagsMoreCount(String count);

  /// No description provided for @accountCorrectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account correction · excluded from analytics'**
  String get accountCorrectionSubtitle;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @transferLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferLabel;

  /// No description provided for @adjustmentLabel.
  ///
  /// In en, this message translates to:
  /// **'ADJUSTMENT'**
  String get adjustmentLabel;

  /// No description provided for @editTransfer.
  ///
  /// In en, this message translates to:
  /// **'Edit Transfer'**
  String get editTransfer;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @saveAndAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Another'**
  String get saveAndAddAnother;

  /// No description provided for @fromAccount.
  ///
  /// In en, this message translates to:
  /// **'FROM ACCOUNT'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In en, this message translates to:
  /// **'TO ACCOUNT'**
  String get toAccount;

  /// No description provided for @transactionNameHint.
  ///
  /// In en, this message translates to:
  /// **'Transaction name'**
  String get transactionNameHint;

  /// No description provided for @categoryUpper.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get categoryUpper;

  /// No description provided for @selectLabel.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectLabel;

  /// No description provided for @updateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get updateExpense;

  /// No description provided for @updateIncome.
  ///
  /// In en, this message translates to:
  /// **'Update Income'**
  String get updateIncome;

  /// No description provided for @updateTransferBtn.
  ///
  /// In en, this message translates to:
  /// **'Update Transfer'**
  String get updateTransferBtn;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save Income'**
  String get saveIncome;

  /// No description provided for @saveTransferBtn.
  ///
  /// In en, this message translates to:
  /// **'Save Transfer'**
  String get saveTransferBtn;

  /// No description provided for @enterTransactionName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a transaction name'**
  String get enterTransactionName;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @selectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get selectCategoryError;

  /// No description provided for @selectAccountError.
  ///
  /// In en, this message translates to:
  /// **'Please select an account'**
  String get selectAccountError;

  /// No description provided for @selectSourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select a source account'**
  String get selectSourceAccount;

  /// No description provided for @selectDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination account'**
  String get selectDestinationAccount;

  /// No description provided for @accountsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Source and destination accounts must be different'**
  String get accountsMustDiffer;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @addAnotherPrompt.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved! Add another?'**
  String get addAnotherPrompt;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// No description provided for @transactionSaved.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get transactionSaved;

  /// No description provided for @transferUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transfer updated'**
  String get transferUpdated;

  /// No description provided for @transferSaved.
  ///
  /// In en, this message translates to:
  /// **'Transfer saved'**
  String get transferSaved;

  /// No description provided for @creditCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Payment'**
  String get creditCardPayment;

  /// No description provided for @creditCardWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Withdrawal'**
  String get creditCardWithdrawal;

  /// No description provided for @creditCardTransfer.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Transfer'**
  String get creditCardTransfer;

  /// No description provided for @selectCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategoryTitle;

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategories;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// No description provided for @ungrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get ungrouped;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'Add new category'**
  String get addNewCategory;

  /// No description provided for @budgetExists.
  ///
  /// In en, this message translates to:
  /// **'BUDGET EXISTS'**
  String get budgetExists;

  /// No description provided for @selectAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccountTitle;

  /// No description provided for @chooseAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the account for this transaction'**
  String get chooseAccountSubtitle;

  /// No description provided for @noAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get noAccountsYet;

  /// No description provided for @addNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Add new account'**
  String get addNewAccount;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteHint;

  /// No description provided for @tagsUpper.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get tagsUpper;

  /// No description provided for @noTagsSelected.
  ///
  /// In en, this message translates to:
  /// **'No tags selected'**
  String get noTagsSelected;

  /// No description provided for @tagsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} tags selected'**
  String tagsSelectedCount(String count);

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE & TIME'**
  String get dateTimeLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetLabel;

  /// No description provided for @attachmentsLabel.
  ///
  /// In en, this message translates to:
  /// **'ATTACHMENTS'**
  String get attachmentsLabel;

  /// No description provided for @addImageOrPdf.
  ///
  /// In en, this message translates to:
  /// **'Add image or PDF'**
  String get addImageOrPdf;

  /// No description provided for @filesAttached.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file attached} other{{count} files attached}}'**
  String filesAttached(int count);

  /// No description provided for @addAttachments.
  ///
  /// In en, this message translates to:
  /// **'Add Attachments'**
  String get addAttachments;

  /// No description provided for @max5mb.
  ///
  /// In en, this message translates to:
  /// **'Max 5MB per file'**
  String get max5mb;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @galleryLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryLabel;

  /// No description provided for @fileExceeds5mb.
  ///
  /// In en, this message translates to:
  /// **'File exceeds 5MB limit'**
  String get fileExceeds5mb;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @transferDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer deleted'**
  String get transferDeleted;

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undoLabel;

  /// No description provided for @transactionAmount.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION AMOUNT'**
  String get transactionAmount;

  /// No description provided for @accountUpper.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountUpper;

  /// No description provided for @notesUpper.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get notesUpper;

  /// No description provided for @addedUsingPrompt.
  ///
  /// In en, this message translates to:
  /// **'ADDED USING PROMPT'**
  String get addedUsingPrompt;

  /// No description provided for @attachedTags.
  ///
  /// In en, this message translates to:
  /// **'ATTACHED TAGS'**
  String get attachedTags;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @filtersUpper.
  ///
  /// In en, this message translates to:
  /// **'FILTERS'**
  String get filtersUpper;

  /// No description provided for @filterExpensesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter expenses'**
  String get filterExpensesTooltip;

  /// No description provided for @filterExp.
  ///
  /// In en, this message translates to:
  /// **'Exp'**
  String get filterExp;

  /// No description provided for @filterIncomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter income'**
  String get filterIncomeTooltip;

  /// No description provided for @filterInc.
  ///
  /// In en, this message translates to:
  /// **'Inc'**
  String get filterInc;

  /// No description provided for @advancedFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get advancedFiltersTooltip;

  /// No description provided for @clearFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFiltersTooltip;

  /// No description provided for @searchTransactionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactionsTooltip;

  /// No description provided for @searchTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactionsHint;

  /// No description provided for @applySearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Apply search'**
  String get applySearchTooltip;

  /// No description provided for @selectRange.
  ///
  /// In en, this message translates to:
  /// **'Select Range'**
  String get selectRange;

  /// No description provided for @advancedFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFiltersTitle;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @dateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE RANGE'**
  String get dateRangeLabel;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @transactionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION NAME'**
  String get transactionNameLabel;

  /// No description provided for @searchViaName.
  ///
  /// In en, this message translates to:
  /// **'Search via name.'**
  String get searchViaName;

  /// No description provided for @typeFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get typeFilterLabel;

  /// No description provided for @amountRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT RANGE'**
  String get amountRangeLabel;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get maxLabel;

  /// No description provided for @errorLoadingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Error loading accounts'**
  String get errorLoadingAccounts;

  /// No description provided for @categoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get categoriesLabel;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @errorLoadingTags.
  ///
  /// In en, this message translates to:
  /// **'Error loading tags'**
  String get errorLoadingTags;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'APPLY FILTERS'**
  String get applyFilters;

  /// No description provided for @creditShort.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get creditShort;

  /// No description provided for @bucketDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn'**
  String get bucketDawn;

  /// No description provided for @bucketMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get bucketMorning;

  /// No description provided for @bucketNoon.
  ///
  /// In en, this message translates to:
  /// **'Noon'**
  String get bucketNoon;

  /// No description provided for @bucketEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get bucketEvening;

  /// No description provided for @bucketNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get bucketNight;

  /// No description provided for @weekLabel.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekLabel;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending\nAnalytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Visualize your spending patterns'**
  String get analyticsDescription;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noTransactionsForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this period'**
  String get noTransactionsForPeriod;

  /// No description provided for @biggestTransactions.
  ///
  /// In en, this message translates to:
  /// **'Biggest Transactions'**
  String get biggestTransactions;

  /// No description provided for @spendingTrend.
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get spendingTrend;

  /// No description provided for @activeSelection.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE SELECTION'**
  String get activeSelection;

  /// No description provided for @quickFilters.
  ///
  /// In en, this message translates to:
  /// **'QUICK FILTERS'**
  String get quickFilters;

  /// No description provided for @jumpTo.
  ///
  /// In en, this message translates to:
  /// **'Jump To'**
  String get jumpTo;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get invalidFormat;

  /// No description provided for @startBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'Start must be before End'**
  String get startBeforeEnd;

  /// No description provided for @futureDatesNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Future dates not allowed'**
  String get futureDatesNotAllowed;

  /// No description provided for @manualDateRange.
  ///
  /// In en, this message translates to:
  /// **'Manual Date Range'**
  String get manualDateRange;

  /// No description provided for @manualDateRangeDesc.
  ///
  /// In en, this message translates to:
  /// **'Specify a custom period for your financial analysis.'**
  String get manualDateRangeDesc;

  /// No description provided for @fromDateLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM DATE (DD/MM/YYYY)'**
  String get fromDateLabel;

  /// No description provided for @toDateLabel.
  ///
  /// In en, this message translates to:
  /// **'TO DATE (DD/MM/YYYY)'**
  String get toDateLabel;

  /// No description provided for @doneUpper.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneUpper;

  /// No description provided for @cancelUpper.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelUpper;

  /// No description provided for @thresholdSettings.
  ///
  /// In en, this message translates to:
  /// **'Threshold Settings'**
  String get thresholdSettings;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @thresholdSmallDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount below which transactions are marked as Small.'**
  String get thresholdSmallDesc;

  /// No description provided for @thresholdLargeDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount above which transactions are marked as Large.'**
  String get thresholdLargeDesc;

  /// No description provided for @previewLogic.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW LOGIC'**
  String get previewLogic;

  /// No description provided for @sizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get sizeLarge;

  /// No description provided for @budgetVsActual.
  ///
  /// In en, this message translates to:
  /// **'Budget vs Actual'**
  String get budgetVsActual;

  /// No description provided for @errorLoadingBudgets.
  ///
  /// In en, this message translates to:
  /// **'Error loading budgets'**
  String get errorLoadingBudgets;

  /// No description provided for @noActiveBudgets.
  ///
  /// In en, this message translates to:
  /// **'No active budgets'**
  String get noActiveBudgets;

  /// No description provided for @tagWiseAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Tag-wise Analytics'**
  String get tagWiseAnalytics;

  /// No description provided for @spendingByTag.
  ///
  /// In en, this message translates to:
  /// **'Spending by Tag'**
  String get spendingByTag;

  /// No description provided for @topTagsContribution.
  ///
  /// In en, this message translates to:
  /// **'TOP TAGS CONTRIBUTION'**
  String get topTagsContribution;

  /// No description provided for @noTagsInRange.
  ///
  /// In en, this message translates to:
  /// **'There are no tag-related transactions in your selected date range'**
  String get noTagsInRange;

  /// No description provided for @spendingDistribution.
  ///
  /// In en, this message translates to:
  /// **'Spending Distribution'**
  String get spendingDistribution;

  /// No description provided for @groupLabel.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get groupLabel;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @transactionSizeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Transaction Size Distribution'**
  String get transactionSizeDistribution;

  /// No description provided for @frequencyByTicketSize.
  ///
  /// In en, this message translates to:
  /// **'Frequency by ticket size'**
  String get frequencyByTicketSize;

  /// No description provided for @avgWeeklyHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Avg Weekly Heatmap'**
  String get avgWeeklyHeatmap;

  /// No description provided for @basedOnSelectedFilter.
  ///
  /// In en, this message translates to:
  /// **'Based on your selected filter'**
  String get basedOnSelectedFilter;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'INTENSITY'**
  String get intensity;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// No description provided for @thresholdFloorHeading.
  ///
  /// In en, this message translates to:
  /// **'Small/Medium Boundary (Floor)'**
  String get thresholdFloorHeading;

  /// No description provided for @thresholdCeilingHeading.
  ///
  /// In en, this message translates to:
  /// **'Medium/Large Boundary (Ceiling)'**
  String get thresholdCeilingHeading;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage\nAccounts'**
  String get manageAccounts;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @addFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Add your first account to start tracking'**
  String get addFirstAccount;

  /// No description provided for @addAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Add another account'**
  String get addAnotherAccount;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get availableBalance;

  /// No description provided for @limitUpper.
  ///
  /// In en, this message translates to:
  /// **'LIMIT'**
  String get limitUpper;

  /// No description provided for @defaultUpper.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get defaultUpper;

  /// No description provided for @addTransactionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransactionTooltip;

  /// No description provided for @savingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Savings Account'**
  String get savingsAccount;

  /// No description provided for @viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View Transactions'**
  String get viewTransactions;

  /// No description provided for @errorLoadingBalance.
  ///
  /// In en, this message translates to:
  /// **'Error loading balance'**
  String get errorLoadingBalance;

  /// No description provided for @editLimitSpent.
  ///
  /// In en, this message translates to:
  /// **'Edit limit spent'**
  String get editLimitSpent;

  /// No description provided for @editBalance.
  ///
  /// In en, this message translates to:
  /// **'Edit balance'**
  String get editBalance;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @removeDefault.
  ///
  /// In en, this message translates to:
  /// **'Remove Default'**
  String get removeDefault;

  /// No description provided for @setAsDefaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefaultLabel;

  /// No description provided for @currentAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'CURRENT AVAILABLE BALANCE'**
  String get currentAvailableBalance;

  /// No description provided for @limitSpent.
  ///
  /// In en, this message translates to:
  /// **'LIMIT SPENT'**
  String get limitSpent;

  /// No description provided for @totalLimit.
  ///
  /// In en, this message translates to:
  /// **'TOTAL LIMIT'**
  String get totalLimit;

  /// No description provided for @cannotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete account'**
  String get cannotDeleteAccount;

  /// No description provided for @cannotDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This account has transactions linked to it. To delete this account, delete the linked transactions first.'**
  String get cannotDeleteAccountBody;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountConfirm;

  /// No description provided for @limitSpentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Limit spent updated successfully'**
  String get limitSpentUpdated;

  /// No description provided for @balanceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Balance updated successfully'**
  String get balanceUpdated;

  /// No description provided for @currentLimitSpent.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LIMIT SPENT'**
  String get currentLimitSpent;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BALANCE'**
  String get currentBalance;

  /// No description provided for @newLimitSpent.
  ///
  /// In en, this message translates to:
  /// **'New Limit Spent'**
  String get newLimitSpent;

  /// No description provided for @newBalance.
  ///
  /// In en, this message translates to:
  /// **'New Balance'**
  String get newBalance;

  /// No description provided for @enterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter an account name'**
  String get enterAccountName;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @creditCardName.
  ///
  /// In en, this message translates to:
  /// **'Credit card name'**
  String get creditCardName;

  /// No description provided for @cashName.
  ///
  /// In en, this message translates to:
  /// **'Cash name'**
  String get cashName;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get bankName;

  /// No description provided for @iconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get iconLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @last4DigitsHint.
  ///
  /// In en, this message translates to:
  /// **'Last 4 digits (optional)'**
  String get last4DigitsHint;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial balance'**
  String get initialBalance;

  /// No description provided for @limitSpentField.
  ///
  /// In en, this message translates to:
  /// **'Limit spent'**
  String get limitSpentField;

  /// No description provided for @totalLimitField.
  ///
  /// In en, this message translates to:
  /// **'Total limit'**
  String get totalLimitField;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get saveAccount;

  /// No description provided for @totalNetWorth.
  ///
  /// In en, this message translates to:
  /// **'TOTAL NET WORTH'**
  String get totalNetWorth;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @debt.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt;

  /// No description provided for @cardLast4Note.
  ///
  /// In en, this message translates to:
  /// **'Card\'s last 4 digits · not shared anywhere'**
  String get cardLast4Note;

  /// No description provided for @lastTransaction.
  ///
  /// In en, this message translates to:
  /// **'Last transaction {time}'**
  String lastTransaction(String time);

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String deleteAccountBody(String name);

  /// No description provided for @adjustmentNote.
  ///
  /// In en, this message translates to:
  /// **'adjustment will be recorded as a transaction (analytics won\'t be affected)'**
  String get adjustmentNote;

  /// No description provided for @trackBudgets.
  ///
  /// In en, this message translates to:
  /// **'Track\nBudgets'**
  String get trackBudgets;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @createBudgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create budgets to control your spending per category'**
  String get createBudgetsDesc;

  /// No description provided for @disabledUpper.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get disabledUpper;

  /// No description provided for @expiredUpper.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get expiredUpper;

  /// No description provided for @budgetPeriodEnded.
  ///
  /// In en, this message translates to:
  /// **'BUDGET PERIOD ENDED'**
  String get budgetPeriodEnded;

  /// No description provided for @budgetPaused.
  ///
  /// In en, this message translates to:
  /// **'BUDGET IS CURRENTLY PAUSED'**
  String get budgetPaused;

  /// No description provided for @budgetResetsIn.
  ///
  /// In en, this message translates to:
  /// **'RESETS IN {count, plural, =1{1 DAY} other{{count} DAYS}}'**
  String budgetResetsIn(int count);

  /// No description provided for @budgetExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES IN {count, plural, =1{1 DAY} other{{count} DAYS}}'**
  String budgetExpiresIn(int count);

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @selectCategoryUpper.
  ///
  /// In en, this message translates to:
  /// **'SELECT CATEGORY'**
  String get selectCategoryUpper;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'BUDGET AMOUNT'**
  String get budgetAmount;

  /// No description provided for @appliesTo.
  ///
  /// In en, this message translates to:
  /// **'APPLIES TO'**
  String get appliesTo;

  /// No description provided for @thisMonthOnly.
  ///
  /// In en, this message translates to:
  /// **'This month\nonly'**
  String get thisMonthOnly;

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every\nmonth'**
  String get everyMonth;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'BUDGET ALERTS'**
  String get budgetAlerts;

  /// No description provided for @addAlert.
  ///
  /// In en, this message translates to:
  /// **'ADD ALERT'**
  String get addAlert;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'SAVE BUDGET'**
  String get saveBudget;

  /// No description provided for @tapToChangeCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap to change category'**
  String get tapToChangeCategory;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose category'**
  String get chooseCategory;

  /// No description provided for @monthlyBudgetPlan.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET PLAN'**
  String get monthlyBudgetPlan;

  /// No description provided for @currentSpending.
  ///
  /// In en, this message translates to:
  /// **'CURRENT SPENDING'**
  String get currentSpending;

  /// No description provided for @utilization.
  ///
  /// In en, this message translates to:
  /// **'UTILIZATION'**
  String get utilization;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'BUDGET DETAILS'**
  String get budgetDetails;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'CREATED ON'**
  String get createdOn;

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'RENEWS ON'**
  String get renewsOn;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES ON'**
  String get expiresOn;

  /// No description provided for @startedOn.
  ///
  /// In en, this message translates to:
  /// **'STARTED ON'**
  String get startedOn;

  /// No description provided for @statusUpper.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get statusUpper;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @pausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE ALERTS'**
  String get activeAlerts;

  /// No description provided for @noAlertsSet.
  ///
  /// In en, this message translates to:
  /// **'No alerts set'**
  String get noAlertsSet;

  /// No description provided for @actionsUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actionsUpper;

  /// No description provided for @pauseLabel.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseLabel;

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeLabel;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete budget?'**
  String get deleteBudgetConfirm;

  /// No description provided for @budgetHistory.
  ///
  /// In en, this message translates to:
  /// **'Budget History'**
  String get budgetHistory;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No History Yet'**
  String get noHistoryYet;

  /// No description provided for @budgetHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your spending history for this budget will appear here once transactions are recorded.'**
  String get budgetHistoryEmptyDesc;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'OVER BUDGET'**
  String get overBudget;

  /// No description provided for @underBudget.
  ///
  /// In en, this message translates to:
  /// **'UNDER BUDGET'**
  String get underBudget;

  /// No description provided for @enterValidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid value'**
  String get enterValidValue;

  /// No description provided for @amountExceedsBudget.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed budget limit'**
  String get amountExceedsBudget;

  /// No description provided for @alertAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An alert for this value already exists'**
  String get alertAlreadyExists;

  /// No description provided for @addAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Alert'**
  String get addAlertTitle;

  /// No description provided for @selectAlertType.
  ///
  /// In en, this message translates to:
  /// **'SELECT ALERT TYPE'**
  String get selectAlertType;

  /// No description provided for @percentageType.
  ///
  /// In en, this message translates to:
  /// **'Percentage (%)'**
  String get percentageType;

  /// No description provided for @pushNotification.
  ///
  /// In en, this message translates to:
  /// **'Push Notification'**
  String get pushNotification;

  /// No description provided for @exceededBy.
  ///
  /// In en, this message translates to:
  /// **'EXCEEDED BY {amount}'**
  String exceededBy(String amount);

  /// No description provided for @budgetAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A budget already exists for this category'**
  String get budgetAlreadyExists;

  /// No description provided for @deleteBudgetBody.
  ///
  /// In en, this message translates to:
  /// **'The budget for \"{name}\" will be permanently deleted.'**
  String deleteBudgetBody(String name);

  /// No description provided for @alertDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert me when spending reaches {value} of my monthly budget.'**
  String alertDesc(String value);

  /// No description provided for @percentageCannotExceed.
  ///
  /// In en, this message translates to:
  /// **'Percentage cannot exceed 100%'**
  String get percentageCannotExceed;

  /// No description provided for @alertAmountType.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount ({symbol})'**
  String alertAmountType(String symbol);

  /// No description provided for @loansTitle.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get loansTitle;

  /// No description provided for @addLoan.
  ///
  /// In en, this message translates to:
  /// **'Add Loan'**
  String get addLoan;

  /// No description provided for @noLoansAdded.
  ///
  /// In en, this message translates to:
  /// **'No loans added'**
  String get noLoansAdded;

  /// No description provided for @loansEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap + to track your first loan EMI'**
  String get loansEmptyDesc;

  /// No description provided for @activeLoans.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE LOANS'**
  String get activeLoans;

  /// No description provided for @editLoan.
  ///
  /// In en, this message translates to:
  /// **'Edit loan'**
  String get editLoan;

  /// No description provided for @newLoan.
  ///
  /// In en, this message translates to:
  /// **'New loan'**
  String get newLoan;

  /// No description provided for @loanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan amount'**
  String get loanAmount;

  /// No description provided for @totalPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Total principal'**
  String get totalPrincipal;

  /// No description provided for @loanType.
  ///
  /// In en, this message translates to:
  /// **'Loan type'**
  String get loanType;

  /// No description provided for @loanTypeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get loanTypeVehicle;

  /// No description provided for @loanTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get loanTypePersonal;

  /// No description provided for @loanTypeEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get loanTypeEducation;

  /// No description provided for @loanTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get loanTypeOther;

  /// No description provided for @loanName.
  ///
  /// In en, this message translates to:
  /// **'Loan name'**
  String get loanName;

  /// No description provided for @loanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Maruti Brezza'**
  String get loanNameHint;

  /// No description provided for @lenderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. HDFC Bank'**
  String get lenderHint;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get referenceNumber;

  /// No description provided for @referenceNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Sanction / loan ID'**
  String get referenceNumberHint;

  /// No description provided for @termsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get termsLabel;

  /// No description provided for @interestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get interestRate;

  /// No description provided for @rateFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get rateFixed;

  /// No description provided for @rateFloating.
  ///
  /// In en, this message translates to:
  /// **'Floating'**
  String get rateFloating;

  /// No description provided for @payEmi.
  ///
  /// In en, this message translates to:
  /// **'Pay EMI'**
  String get payEmi;

  /// No description provided for @payExtra.
  ///
  /// In en, this message translates to:
  /// **'Pay Extra'**
  String get payExtra;

  /// No description provided for @closeLoan.
  ///
  /// In en, this message translates to:
  /// **'Close Loan'**
  String get closeLoan;

  /// No description provided for @progressUpper.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progressUpper;

  /// No description provided for @totalUpper.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get totalUpper;

  /// No description provided for @paidUpper.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paidUpper;

  /// No description provided for @remainingUpper.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remainingUpper;

  /// No description provided for @nextEmiDue.
  ///
  /// In en, this message translates to:
  /// **'NEXT EMI DUE'**
  String get nextEmiDue;

  /// No description provided for @interestRateUpper.
  ///
  /// In en, this message translates to:
  /// **'INTEREST RATE'**
  String get interestRateUpper;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT HISTORY'**
  String get paymentHistory;

  /// No description provided for @noPaymentsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded'**
  String get noPaymentsRecorded;

  /// No description provided for @deleteLoanConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Loan?'**
  String get deleteLoanConfirm;

  /// No description provided for @deleteLoanBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the loan and ALL linked payment transactions. This cannot be undone.'**
  String get deleteLoanBody;

  /// No description provided for @emiPaid.
  ///
  /// In en, this message translates to:
  /// **'EMI Paid'**
  String get emiPaid;

  /// No description provided for @extraPayment.
  ///
  /// In en, this message translates to:
  /// **'Extra Payment'**
  String get extraPayment;

  /// No description provided for @loanClosure.
  ///
  /// In en, this message translates to:
  /// **'Loan Closure'**
  String get loanClosure;

  /// No description provided for @confirmClosure.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM CLOSURE'**
  String get confirmClosure;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PAYMENT'**
  String get confirmPayment;

  /// No description provided for @amountUpper.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amountUpper;

  /// No description provided for @dateUpper.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateUpper;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'NOTE (OPTIONAL)'**
  String get noteOptional;

  /// No description provided for @totalOutstandingDebt.
  ///
  /// In en, this message translates to:
  /// **'TOTAL OUTSTANDING DEBT'**
  String get totalOutstandingDebt;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @outstandingTitle.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstandingTitle;

  /// No description provided for @interestLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interestLabel;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next due'**
  String get nextDue;

  /// No description provided for @completedUpper.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completedUpper;

  /// No description provided for @lenderField.
  ///
  /// In en, this message translates to:
  /// **'Lender'**
  String get lenderField;

  /// No description provided for @loanTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get loanTypeHome;

  /// No description provided for @monthlyOutflow.
  ///
  /// In en, this message translates to:
  /// **'Monthly outflow'**
  String get monthlyOutflow;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @tenure.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get tenure;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @loanStartDate.
  ///
  /// In en, this message translates to:
  /// **'Loan start date'**
  String get loanStartDate;

  /// No description provided for @repaymentStart.
  ///
  /// In en, this message translates to:
  /// **'Repayment start'**
  String get repaymentStart;

  /// No description provided for @firstEmiOn.
  ///
  /// In en, this message translates to:
  /// **'First EMI on'**
  String get firstEmiOn;

  /// No description provided for @monthlyBillDate.
  ///
  /// In en, this message translates to:
  /// **'Monthly bill date'**
  String get monthlyBillDate;

  /// No description provided for @sourceAccount.
  ///
  /// In en, this message translates to:
  /// **'Source account'**
  String get sourceAccount;

  /// No description provided for @autoAddTransactions.
  ///
  /// In en, this message translates to:
  /// **'Auto-add transactions'**
  String get autoAddTransactions;

  /// No description provided for @autoAddTransactionsSub.
  ///
  /// In en, this message translates to:
  /// **'Post each EMI to \"Loan EMI\" category on its bill date'**
  String get autoAddTransactionsSub;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @loanNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Documentation · sanction letter ref · anything'**
  String get loanNotesHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @confirmAddLoan.
  ///
  /// In en, this message translates to:
  /// **'Confirm & add loan'**
  String get confirmAddLoan;

  /// No description provided for @percentPaid.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Paid'**
  String percentPaid(String pct);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @speedDialRecurring.
  ///
  /// In en, this message translates to:
  /// **'Add a Recurring Transaction'**
  String get speedDialRecurring;

  /// No description provided for @speedDialLoan.
  ///
  /// In en, this message translates to:
  /// **'Add a Loan'**
  String get speedDialLoan;

  /// No description provided for @speedDialInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add an Investment'**
  String get speedDialInvestment;

  /// No description provided for @speedDialLendBorrow.
  ///
  /// In en, this message translates to:
  /// **'Lend / Borrow Money'**
  String get speedDialLendBorrow;

  /// No description provided for @moneyStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'MONEY STORIES'**
  String get moneyStoriesTitle;

  /// No description provided for @moneyStoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Keep spending to see your money stories soon.'**
  String get moneyStoriesEmpty;

  /// No description provided for @bubbleWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get bubbleWelcome;

  /// No description provided for @bubbleDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get bubbleDaily;

  /// No description provided for @bubbleWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get bubbleWeekly;

  /// No description provided for @bubbleMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get bubbleMonthly;

  /// No description provided for @bubbleYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get bubbleYearly;

  /// No description provided for @bubbleLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get bubbleLoans;

  /// No description provided for @bubbleInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get bubbleInvestments;

  /// No description provided for @bubbleLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get bubbleLedger;

  /// No description provided for @bubbleInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get bubbleInsights;

  /// No description provided for @storiesArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Stories Archive'**
  String get storiesArchiveTitle;

  /// No description provided for @storiesArchiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Every recap Kuber has made for you, newest first.'**
  String get storiesArchiveDesc;

  /// No description provided for @noStoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No stories yet'**
  String get noStoriesYet;

  /// No description provided for @keepUsingToSeeRecaps.
  ///
  /// In en, this message translates to:
  /// **'Keep using Kuber to see your recaps here.'**
  String get keepUsingToSeeRecaps;

  /// No description provided for @earlierThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Earlier this week'**
  String get earlierThisWeek;

  /// No description provided for @earlierThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Earlier this month'**
  String get earlierThisMonth;

  /// No description provided for @olderLabel.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get olderLabel;

  /// No description provided for @loadingOlderStories.
  ///
  /// In en, this message translates to:
  /// **'Loading older stories'**
  String get loadingOlderStories;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 min ago} other{{count} mins ago}}'**
  String minsAgo(num count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(num count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day ago} other{{count} days ago}}'**
  String daysAgo(num count);

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String relativeToday(Object time);

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String relativeYesterday(Object time);

  /// No description provided for @utilizedLabel.
  ///
  /// In en, this message translates to:
  /// **'utilized'**
  String get utilizedLabel;

  /// No description provided for @utilizedPct.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Utilized'**
  String utilizedPct(Object pct);

  /// No description provided for @editWidgets.
  ///
  /// In en, this message translates to:
  /// **'Edit Widgets'**
  String get editWidgets;

  /// No description provided for @editHomeWidgets.
  ///
  /// In en, this message translates to:
  /// **'Edit Home Widgets'**
  String get editHomeWidgets;

  /// No description provided for @editHomeWidgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose and reorder Home widgets'**
  String get editHomeWidgetsDesc;

  /// No description provided for @editAnalyticsWidgets.
  ///
  /// In en, this message translates to:
  /// **'Edit Analytics Widgets'**
  String get editAnalyticsWidgets;

  /// No description provided for @editAnalyticsWidgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose and reorder Analytics widgets'**
  String get editAnalyticsWidgetsDesc;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get filterThisWeek;

  /// No description provided for @filterLastWeek.
  ///
  /// In en, this message translates to:
  /// **'LAST WEEK'**
  String get filterLastWeek;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get filterThisMonth;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'LAST MONTH'**
  String get filterLastMonth;

  /// No description provided for @filterThisYear.
  ///
  /// In en, this message translates to:
  /// **'THIS YEAR'**
  String get filterThisYear;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get filterCustom;

  /// No description provided for @moreManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get moreManageTitle;

  /// No description provided for @moreToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get moreToolsTitle;

  /// No description provided for @moreAppTitle.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get moreAppTitle;

  /// No description provided for @moreTutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get moreTutorialTitle;

  /// No description provided for @moreHelpUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Us'**
  String get moreHelpUsTitle;

  /// No description provided for @moreAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get moreAboutTitle;

  /// No description provided for @moreSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get moreSearchTooltip;

  /// No description provided for @moreManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your settings, tools and data'**
  String get moreManageSubtitle;

  /// No description provided for @menuAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get menuAccounts;

  /// No description provided for @menuAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your wallets and bank accounts'**
  String get menuAccountsDesc;

  /// No description provided for @menuCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get menuCategories;

  /// No description provided for @menuCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your transactions'**
  String get menuCategoriesDesc;

  /// No description provided for @menuTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get menuTags;

  /// No description provided for @menuTagsDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize the labels for your transactions'**
  String get menuTagsDesc;

  /// No description provided for @menuBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get menuBudgets;

  /// No description provided for @menuBudgetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track and control your monthly spending'**
  String get menuBudgetsDesc;

  /// No description provided for @menuRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get menuRecurring;

  /// No description provided for @menuRecurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Automated scheduled transactions'**
  String get menuRecurringDesc;

  /// No description provided for @menuLedger.
  ///
  /// In en, this message translates to:
  /// **'Lend / Borrow'**
  String get menuLedger;

  /// No description provided for @menuLedgerDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money you lent or borrowed'**
  String get menuLedgerDesc;

  /// No description provided for @menuLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get menuLoans;

  /// No description provided for @menuLoansDesc.
  ///
  /// In en, this message translates to:
  /// **'Track EMIs and repayment progress'**
  String get menuLoansDesc;

  /// No description provided for @menuInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get menuInvestments;

  /// No description provided for @menuInvestmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track portfolio value and growth'**
  String get menuInvestmentsDesc;

  /// No description provided for @menuAskKuber.
  ///
  /// In en, this message translates to:
  /// **'Ask Kuber (Beta)'**
  String get menuAskKuber;

  /// No description provided for @menuAskKuberDesc.
  ///
  /// In en, this message translates to:
  /// **'On-device smart assistant'**
  String get menuAskKuberDesc;

  /// No description provided for @menuCalculators.
  ///
  /// In en, this message translates to:
  /// **'Calculators & Tools'**
  String get menuCalculators;

  /// No description provided for @menuCalculatorsDesc.
  ///
  /// In en, this message translates to:
  /// **'EMI, SIP, salary, GST, split & more'**
  String get menuCalculatorsDesc;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, currency, and profile'**
  String get menuSettingsDesc;

  /// No description provided for @menuData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get menuData;

  /// No description provided for @menuDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export, import, automatic backups'**
  String get menuDataDesc;

  /// No description provided for @menuStoriesArchive.
  ///
  /// In en, this message translates to:
  /// **'Money Stories Archive'**
  String get menuStoriesArchive;

  /// No description provided for @menuStoriesArchiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Every recap, newest first'**
  String get menuStoriesArchiveDesc;

  /// No description provided for @menuTroubleshoot.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot'**
  String get menuTroubleshoot;

  /// No description provided for @menuTroubleshootDesc.
  ///
  /// In en, this message translates to:
  /// **'Fix data and suggestion issues'**
  String get menuTroubleshootDesc;

  /// No description provided for @menuTutorial.
  ///
  /// In en, this message translates to:
  /// **'App Tutorial (Beta)'**
  String get menuTutorial;

  /// No description provided for @menuTutorialDesc.
  ///
  /// In en, this message translates to:
  /// **'Replay the feature walkthrough'**
  String get menuTutorialDesc;

  /// No description provided for @menuWelcomeTour.
  ///
  /// In en, this message translates to:
  /// **'Welcome Tour'**
  String get menuWelcomeTour;

  /// No description provided for @menuWelcomeTourDesc.
  ///
  /// In en, this message translates to:
  /// **'Replay the welcome and setup screens'**
  String get menuWelcomeTourDesc;

  /// No description provided for @menuRateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us on Play Store'**
  String get menuRateUs;

  /// No description provided for @menuRateUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoying Kuber? Leave a review'**
  String get menuRateUsDesc;

  /// No description provided for @menuShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share This App'**
  String get menuShareApp;

  /// No description provided for @menuShareAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Recommend Kuber to friends and family'**
  String get menuShareAppDesc;

  /// No description provided for @menuFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit a Feedback'**
  String get menuFeedback;

  /// No description provided for @menuFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or suggest a feature'**
  String get menuFeedbackDesc;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About Kuber'**
  String get menuAbout;

  /// No description provided for @menuAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Vision, origin, and developer'**
  String get menuAboutDesc;

  /// No description provided for @menuPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get menuPermissions;

  /// No description provided for @menuPermissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'App limits and security'**
  String get menuPermissionsDesc;

  /// No description provided for @menuDevTools.
  ///
  /// In en, this message translates to:
  /// **'Dev Tools'**
  String get menuDevTools;

  /// No description provided for @menuDevToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Developer-only tools'**
  String get menuDevToolsDesc;

  /// No description provided for @madeInIndia.
  ///
  /// In en, this message translates to:
  /// **'Made with {heart} in India'**
  String madeInIndia(Object heart);

  /// No description provided for @madeInIndiaVersion.
  ///
  /// In en, this message translates to:
  /// **'Made with {heart} in India · v{version}'**
  String madeInIndiaVersion(Object heart, Object version);

  /// No description provided for @shareMessage.
  ///
  /// In en, this message translates to:
  /// **'Manage your expenses like never before. Kuber is a beautifully simple expense manager, made with love in India. Download it here: https://play.google.com/store/apps/details?id=com.grs.kuber'**
  String get shareMessage;

  /// No description provided for @menuManageSpaces.
  ///
  /// In en, this message translates to:
  /// **'8 spaces'**
  String get menuManageSpaces;

  /// No description provided for @menuHelpUsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to support'**
  String get menuHelpUsHint;

  /// No description provided for @menuRateKuber.
  ///
  /// In en, this message translates to:
  /// **'Rate Kuber'**
  String get menuRateKuber;

  /// No description provided for @menuShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get menuShare;

  /// No description provided for @menuFeedbackShort.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get menuFeedbackShort;

  /// No description provided for @menuAppTutorialShort.
  ///
  /// In en, this message translates to:
  /// **'App Tutorial'**
  String get menuAppTutorialShort;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @menuNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Recent alerts and reminders'**
  String get menuNotificationsDesc;

  /// No description provided for @manageCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage\nCategories'**
  String get manageCategoriesTitle;

  /// No description provided for @addCategoryGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Category/Group'**
  String get addCategoryGroup;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @createCategoriesToOrganize.
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize your expenses'**
  String get createCategoriesToOrganize;

  /// No description provided for @searchCategoriesGroups.
  ///
  /// In en, this message translates to:
  /// **'Search categories and groups...'**
  String get searchCategoriesGroups;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @noCategoriesGroupsMatch.
  ///
  /// In en, this message translates to:
  /// **'No categories or groups match \"{query}\".'**
  String noCategoriesGroupsMatch(Object query);

  /// No description provided for @ungroupedLabel.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get ungroupedLabel;

  /// No description provided for @categoryGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Category group'**
  String get categoryGroupLabel;

  /// No description provided for @editGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroupLabel;

  /// No description provided for @deleteGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete group'**
  String get deleteGroupLabel;

  /// No description provided for @groupAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This group already exists'**
  String get groupAlreadyExists;

  /// No description provided for @groupNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Group name cannot be empty'**
  String get groupNameEmpty;

  /// No description provided for @addNewHeader.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNewHeader;

  /// No description provided for @addClassifyDesc.
  ///
  /// In en, this message translates to:
  /// **'Classify your transactions for better tracking'**
  String get addClassifyDesc;

  /// No description provided for @addGroupHeader.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroupHeader;

  /// No description provided for @addGroupDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize categories into sections for better clarity'**
  String get addGroupDesc;

  /// No description provided for @manageTagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage\nTags'**
  String get manageTagsTitle;

  /// No description provided for @addTagLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTagLabel;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @createTagsToLabel.
  ///
  /// In en, this message translates to:
  /// **'Create tags to label transactions (e.g. #trip, #work)'**
  String get createTagsToLabel;

  /// No description provided for @searchTags.
  ///
  /// In en, this message translates to:
  /// **'Search tags...'**
  String get searchTags;

  /// No description provided for @noTagsMatch.
  ///
  /// In en, this message translates to:
  /// **'No tags match \"{query}\".'**
  String noTagsMatch(Object query);

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit Tag'**
  String get editTag;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTag;

  /// No description provided for @tagNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tag name cannot be empty'**
  String get tagNameEmpty;

  /// No description provided for @tagAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This tag already exists'**
  String get tagAlreadyExists;

  /// No description provided for @recurringTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring\nTransactions'**
  String get recurringTitle;

  /// No description provided for @recurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Automate your regular income and expenses'**
  String get recurringDesc;

  /// No description provided for @addRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get addRule;

  /// No description provided for @noRulesYet.
  ///
  /// In en, this message translates to:
  /// **'No recurring rules yet'**
  String get noRulesYet;

  /// No description provided for @createRulesToAutomate.
  ///
  /// In en, this message translates to:
  /// **'Create a rule to automate rent, salary, SIPs etc.'**
  String get createRulesToAutomate;

  /// No description provided for @activeRules.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE RULES'**
  String get activeRules;

  /// No description provided for @pausedRules.
  ///
  /// In en, this message translates to:
  /// **'PAUSED RULES'**
  String get pausedRules;

  /// No description provided for @editRule.
  ///
  /// In en, this message translates to:
  /// **'Edit Rule'**
  String get editRule;

  /// No description provided for @ruleName.
  ///
  /// In en, this message translates to:
  /// **'Rule name'**
  String get ruleName;

  /// No description provided for @ruleAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ruleAmount;

  /// No description provided for @ruleFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get ruleFrequency;

  /// No description provided for @nextProcessDate.
  ///
  /// In en, this message translates to:
  /// **'Next process date'**
  String get nextProcessDate;

  /// No description provided for @deleteRuleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule?'**
  String get deleteRuleConfirm;

  /// No description provided for @deleteRuleBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the recurring rule. Existing transactions created by this rule will not be deleted.'**
  String get deleteRuleBody;

  /// No description provided for @rulePaused.
  ///
  /// In en, this message translates to:
  /// **'Rule paused'**
  String get rulePaused;

  /// No description provided for @ruleResumed.
  ///
  /// In en, this message translates to:
  /// **'Rule resumed'**
  String get ruleResumed;

  /// No description provided for @ledgerTitle.
  ///
  /// In en, this message translates to:
  /// **'Lend / Borrow'**
  String get ledgerTitle;

  /// No description provided for @ledgerDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money you lent to or borrowed from others'**
  String get ledgerDesc;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntry;

  /// No description provided for @noLedgerYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noLedgerYet;

  /// No description provided for @createLedgerToTrack.
  ///
  /// In en, this message translates to:
  /// **'Tap + to track money you lend or borrow'**
  String get createLedgerToTrack;

  /// No description provided for @whoOwes.
  ///
  /// In en, this message translates to:
  /// **'WHO OWES'**
  String get whoOwes;

  /// No description provided for @youOweLabel.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get youOweLabel;

  /// No description provided for @owesYouLabel.
  ///
  /// In en, this message translates to:
  /// **'Owes you'**
  String get owesYouLabel;

  /// No description provided for @settledLabel.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get settledLabel;

  /// No description provided for @settleUp.
  ///
  /// In en, this message translates to:
  /// **'Settle Up'**
  String get settleUp;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry?'**
  String get deleteEntryConfirm;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete this entry and all its payments. This cannot be undone.'**
  String get deleteEntryBody;

  /// No description provided for @investmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsTitle;

  /// No description provided for @investmentsDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your portfolio value, contributions and growth'**
  String get investmentsDesc;

  /// No description provided for @addInvestment.
  ///
  /// In en, this message translates to:
  /// **'Add Investment'**
  String get addInvestment;

  /// No description provided for @noInvestmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No investments yet'**
  String get noInvestmentsYet;

  /// No description provided for @createInvestmentToTrack.
  ///
  /// In en, this message translates to:
  /// **'Tap + to track your SIPs, mutual funds, stocks etc.'**
  String get createInvestmentToTrack;

  /// No description provided for @portfolioValue.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO VALUE'**
  String get portfolioValue;

  /// No description provided for @totalInvested.
  ///
  /// In en, this message translates to:
  /// **'TOTAL INVESTED'**
  String get totalInvested;

  /// No description provided for @gainLoss.
  ///
  /// In en, this message translates to:
  /// **'GAIN / LOSS'**
  String get gainLoss;

  /// No description provided for @deleteInvestmentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Investment?'**
  String get deleteInvestmentConfirm;

  /// No description provided for @deleteInvestmentBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the investment record and all its transactions.'**
  String get deleteInvestmentBody;

  /// No description provided for @troubleshootTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot'**
  String get troubleshootTitle;

  /// No description provided for @troubleshootDesc.
  ///
  /// In en, this message translates to:
  /// **'Fix data inconsistency and suggestion issues.'**
  String get troubleshootDesc;

  /// No description provided for @rebuildSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Rebuild Suggestions'**
  String get rebuildSuggestions;

  /// No description provided for @rebuildSuggestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Regenerates transaction autocompletes based on your history.'**
  String get rebuildSuggestionsDesc;

  /// No description provided for @suggestionsRebuilt.
  ///
  /// In en, this message translates to:
  /// **'Suggestions rebuilt successfully'**
  String get suggestionsRebuilt;

  /// No description provided for @cleanOrphans.
  ///
  /// In en, this message translates to:
  /// **'Clean Orphaned Data'**
  String get cleanOrphans;

  /// No description provided for @cleanOrphansDesc.
  ///
  /// In en, this message translates to:
  /// **'Removes transactions linked to deleted categories or accounts.'**
  String get cleanOrphansDesc;

  /// No description provided for @orphansCleaned.
  ///
  /// In en, this message translates to:
  /// **'Orphaned data cleaned up'**
  String get orphansCleaned;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear App Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Clears temporary files and rebuilds internal database indexes.'**
  String get clearCacheDesc;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @aboutKuberHeader.
  ///
  /// In en, this message translates to:
  /// **'About Kuber'**
  String get aboutKuberHeader;

  /// No description provided for @aboutKuberDesc.
  ///
  /// In en, this message translates to:
  /// **'Kuber is a beautifully simple, offline-first personal finance tracker.'**
  String get aboutKuberDesc;

  /// No description provided for @privacyPromise.
  ///
  /// In en, this message translates to:
  /// **'Privacy Promise'**
  String get privacyPromise;

  /// No description provided for @privacyPromiseDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data never leaves your device. No analytics, no tracking, no cloud sync.'**
  String get privacyPromiseDesc;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// No description provided for @openSourceDesc.
  ///
  /// In en, this message translates to:
  /// **'Built with open technologies, fully transparent and auditable.'**
  String get openSourceDesc;

  /// No description provided for @developerNote.
  ///
  /// In en, this message translates to:
  /// **'Note from the Developer'**
  String get developerNote;

  /// No description provided for @developerNoteDesc.
  ///
  /// In en, this message translates to:
  /// **'Kuber is built with love to solve personal finance tracking. Thank you for using it!'**
  String get developerNoteDesc;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'App access requirements and security limits.'**
  String get permissionsDesc;

  /// No description provided for @storagePermission.
  ///
  /// In en, this message translates to:
  /// **'Storage Access'**
  String get storagePermission;

  /// No description provided for @storagePermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Required to pick attachment images, PDFs and write backups to your device.'**
  String get storagePermissionDesc;

  /// No description provided for @biometricPermission.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricPermission;

  /// No description provided for @biometricPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional. Used for unlocking Kuber securely using Face ID or fingerprint.'**
  String get biometricPermissionDesc;

  /// No description provided for @networkPermission.
  ///
  /// In en, this message translates to:
  /// **'Network Access'**
  String get networkPermission;

  /// No description provided for @networkPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Only used to fetch live currency conversion rates. App works 100% offline.'**
  String get networkPermissionDesc;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Report issues, suggest features, or say hi!'**
  String get feedbackDesc;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK TYPE'**
  String get feedbackType;

  /// No description provided for @feedbackTypeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get feedbackTypeBug;

  /// No description provided for @feedbackTypeFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get feedbackTypeFeature;

  /// No description provided for @feedbackTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get feedbackTypeOther;

  /// No description provided for @feedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'YOUR MESSAGE'**
  String get feedbackMessage;

  /// No description provided for @feedbackMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the issue or your suggestion in detail...'**
  String get feedbackMessageHint;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @feedbackThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThankYou;

  /// No description provided for @feedbackMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message first'**
  String get feedbackMessageRequired;

  /// No description provided for @dataManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagementTitle;

  /// No description provided for @dataManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Export, import, and manage your data.'**
  String get dataManagementDesc;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @exportDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all transactions, accounts and settings to JSON.'**
  String get exportDataDesc;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @importDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Import a previously exported JSON backup file.'**
  String get importDataDesc;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently deletes all transactions, accounts and settings from this device. Cannot be undone.'**
  String get clearAllDataDesc;

  /// No description provided for @clearDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data?'**
  String get clearDataConfirm;

  /// No description provided for @clearDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your transactions, accounts, budgets, and settings. This action is irreversible. Type DELETE to confirm.'**
  String get clearDataConfirmBody;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get backupTitle;

  /// No description provided for @backupDesc.
  ///
  /// In en, this message translates to:
  /// **'Create manual backups or schedule automatic backups.'**
  String get backupDesc;

  /// No description provided for @lentBorrowedTitle.
  ///
  /// In en, this message translates to:
  /// **'Lent &\nBorrowed'**
  String get lentBorrowedTitle;

  /// No description provided for @noLedgerEntries.
  ///
  /// In en, this message translates to:
  /// **'No ledger entries yet'**
  String get noLedgerEntries;

  /// No description provided for @ledgerEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record a lend or borrow'**
  String get ledgerEmptyDesc;

  /// No description provided for @settledUpper.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get settledUpper;

  /// No description provided for @lentLabel.
  ///
  /// In en, this message translates to:
  /// **'Lent'**
  String get lentLabel;

  /// No description provided for @borrowedLabel.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowedLabel;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntry;

  /// No description provided for @amountLent.
  ///
  /// In en, this message translates to:
  /// **'Amount lent'**
  String get amountLent;

  /// No description provided for @amountBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Amount borrowed'**
  String get amountBorrowed;

  /// No description provided for @personLabel.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get personLabel;

  /// No description provided for @whoHint.
  ///
  /// In en, this message translates to:
  /// **'Who?'**
  String get whoHint;

  /// No description provided for @fromAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get fromAccountLabel;

  /// No description provided for @toAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get toAccountLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @lentOn.
  ///
  /// In en, this message translates to:
  /// **'Lent on'**
  String get lentOn;

  /// No description provided for @borrowedOn.
  ///
  /// In en, this message translates to:
  /// **'Borrowed on'**
  String get borrowedOn;

  /// No description provided for @expectedReturn.
  ///
  /// In en, this message translates to:
  /// **'Expected return'**
  String get expectedReturn;

  /// No description provided for @ledgerNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Context, IOU ref, anything'**
  String get ledgerNotesHint;

  /// No description provided for @addToLedger.
  ///
  /// In en, this message translates to:
  /// **'Add to ledger'**
  String get addToLedger;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @expectedOn.
  ///
  /// In en, this message translates to:
  /// **'Expected on'**
  String get expectedOn;

  /// No description provided for @lentTransaction.
  ///
  /// In en, this message translates to:
  /// **'LENT TRANSACTION'**
  String get lentTransaction;

  /// No description provided for @borrowedTransaction.
  ///
  /// In en, this message translates to:
  /// **'BORROWED TRANSACTION'**
  String get borrowedTransaction;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @markSettled.
  ///
  /// In en, this message translates to:
  /// **'Mark Settled'**
  String get markSettled;

  /// No description provided for @repaymentProgress.
  ///
  /// In en, this message translates to:
  /// **'REPAYMENT PROGRESS'**
  String get repaymentProgress;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE'**
  String get dueDate;

  /// No description provided for @markSettledConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark as Settled?'**
  String get markSettledConfirm;

  /// No description provided for @markSettledBody.
  ///
  /// In en, this message translates to:
  /// **'This will record the remaining amount as a payment and mark this entry as settled.'**
  String get markSettledBody;

  /// No description provided for @settleLabel.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get settleLabel;

  /// No description provided for @deleteLedgerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Ledger Entry?'**
  String get deleteLedgerConfirm;

  /// No description provided for @deleteLedgerBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the entry and ALL linked transactions. This cannot be undone.'**
  String get deleteLedgerBody;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @paymentMade.
  ///
  /// In en, this message translates to:
  /// **'Payment Made'**
  String get paymentMade;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @recordPaymentUpper.
  ///
  /// In en, this message translates to:
  /// **'RECORD PAYMENT'**
  String get recordPaymentUpper;

  /// No description provided for @netPosition.
  ///
  /// In en, this message translates to:
  /// **'NET POSITION'**
  String get netPosition;

  /// No description provided for @youWillReceive.
  ///
  /// In en, this message translates to:
  /// **'You will receive'**
  String get youWillReceive;

  /// No description provided for @youOwe.
  ///
  /// In en, this message translates to:
  /// **'You owe'**
  String get youOwe;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'NO DUE DATE'**
  String get noDueDate;

  /// No description provided for @lentUpper.
  ///
  /// In en, this message translates to:
  /// **'LENT'**
  String get lentUpper;

  /// No description provided for @borrowedUpper.
  ///
  /// In en, this message translates to:
  /// **'BORROWED'**
  String get borrowedUpper;

  /// No description provided for @ledgerDuplicateWarningLent.
  ///
  /// In en, this message translates to:
  /// **'An active lent entry for {person} already exists. Are you sure you want to create a new one?'**
  String ledgerDuplicateWarningLent(String person);

  /// No description provided for @ledgerDuplicateWarningBorrow.
  ///
  /// In en, this message translates to:
  /// **'An active borrow entry for {person} already exists. Are you sure you want to create a new one?'**
  String ledgerDuplicateWarningBorrow(String person);

  /// No description provided for @ledgerEvensOut.
  ///
  /// In en, this message translates to:
  /// **'evens out'**
  String get ledgerEvensOut;

  /// No description provided for @ledgerInYourFavour.
  ///
  /// In en, this message translates to:
  /// **'in your favour'**
  String get ledgerInYourFavour;

  /// No description provided for @ledgerOwedToOthers.
  ///
  /// In en, this message translates to:
  /// **'owed to others'**
  String get ledgerOwedToOthers;

  /// No description provided for @ledgerActiveEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active entry} other{{count} active entries}}'**
  String ledgerActiveEntries(int count);

  /// No description provided for @ledgerNoOne.
  ///
  /// In en, this message translates to:
  /// **'no one'**
  String get ledgerNoOne;

  /// No description provided for @ledgerAcrossPeople.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{across 1 person} other{across {count} people}}'**
  String ledgerAcrossPeople(int count);

  /// No description provided for @settledOnUpper.
  ///
  /// In en, this message translates to:
  /// **'SETTLED {date}'**
  String settledOnUpper(String date);

  /// No description provided for @dueOnUpper.
  ///
  /// In en, this message translates to:
  /// **'DUE {date}'**
  String dueOnUpper(String date);

  /// No description provided for @overdueLower.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get overdueLower;

  /// No description provided for @pctReceived.
  ///
  /// In en, this message translates to:
  /// **'{pct}% received'**
  String pctReceived(String pct);

  /// No description provided for @pctPaidBack.
  ///
  /// In en, this message translates to:
  /// **'{pct}% paid back'**
  String pctPaidBack(String pct);

  /// No description provided for @amountRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} remaining'**
  String amountRemaining(String amount);

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(String details);

  /// No description provided for @notSetTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Not set · tap to add'**
  String get notSetTapToAdd;

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 day} other{in {count} days}}'**
  String inDays(int count);

  /// No description provided for @createdOnUpper.
  ///
  /// In en, this message translates to:
  /// **'CREATED {date}'**
  String createdOnUpper(String date);

  /// No description provided for @noInvestments.
  ///
  /// In en, this message translates to:
  /// **'No investments tracked'**
  String get noInvestments;

  /// No description provided for @investmentsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first investment'**
  String get investmentsEmptyDesc;

  /// No description provided for @allInvestmentsUpper.
  ///
  /// In en, this message translates to:
  /// **'ALL INVESTMENTS'**
  String get allInvestmentsUpper;

  /// No description provided for @invTypeSip.
  ///
  /// In en, this message translates to:
  /// **'SIP'**
  String get invTypeSip;

  /// No description provided for @invTypeMutualFund.
  ///
  /// In en, this message translates to:
  /// **'Mutual Fund'**
  String get invTypeMutualFund;

  /// No description provided for @invTypeStocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get invTypeStocks;

  /// No description provided for @invTypeGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get invTypeGold;

  /// No description provided for @invTypeFd.
  ///
  /// In en, this message translates to:
  /// **'FD'**
  String get invTypeFd;

  /// No description provided for @invTypeRd.
  ///
  /// In en, this message translates to:
  /// **'RD'**
  String get invTypeRd;

  /// No description provided for @invTypeCrypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get invTypeCrypto;

  /// No description provided for @invTypeTrading.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get invTypeTrading;

  /// No description provided for @invTypeRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get invTypeRealEstate;

  /// No description provided for @invTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get invTypeOther;

  /// No description provided for @editInvestment.
  ///
  /// In en, this message translates to:
  /// **'Edit investment'**
  String get editInvestment;

  /// No description provided for @newInvestment.
  ///
  /// In en, this message translates to:
  /// **'New investment'**
  String get newInvestment;

  /// No description provided for @investmentName.
  ///
  /// In en, this message translates to:
  /// **'Investment name'**
  String get investmentName;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @totalInvestedInclNew.
  ///
  /// In en, this message translates to:
  /// **'Total invested (incl. new contribution)'**
  String get totalInvestedInclNew;

  /// No description provided for @investedAmountInitial.
  ///
  /// In en, this message translates to:
  /// **'Invested amount (initial)'**
  String get investedAmountInitial;

  /// No description provided for @autoDebitSip.
  ///
  /// In en, this message translates to:
  /// **'Auto-debit SIP'**
  String get autoDebitSip;

  /// No description provided for @enableAutoDebitSip.
  ///
  /// In en, this message translates to:
  /// **'Enable auto-debit SIP'**
  String get enableAutoDebitSip;

  /// No description provided for @automateMonthlyContrib.
  ///
  /// In en, this message translates to:
  /// **'Automate your monthly contributions'**
  String get automateMonthlyContrib;

  /// No description provided for @monthlySipAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly SIP amount'**
  String get monthlySipAmount;

  /// No description provided for @sipDate.
  ///
  /// In en, this message translates to:
  /// **'SIP date'**
  String get sipDate;

  /// No description provided for @debitedFrom.
  ///
  /// In en, this message translates to:
  /// **'Debited from'**
  String get debitedFrom;

  /// No description provided for @optionalContext.
  ///
  /// In en, this message translates to:
  /// **'Optional context'**
  String get optionalContext;

  /// No description provided for @addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add Contribution'**
  String get addContribution;

  /// No description provided for @updateValue.
  ///
  /// In en, this message translates to:
  /// **'Update Value'**
  String get updateValue;

  /// No description provided for @investedUpper.
  ///
  /// In en, this message translates to:
  /// **'INVESTED'**
  String get investedUpper;

  /// No description provided for @currentUpper.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get currentUpper;

  /// No description provided for @gainLossUpper.
  ///
  /// In en, this message translates to:
  /// **'GAIN/LOSS'**
  String get gainLossUpper;

  /// No description provided for @sipConfiguration.
  ///
  /// In en, this message translates to:
  /// **'SIP CONFIGURATION'**
  String get sipConfiguration;

  /// No description provided for @monthlySip.
  ///
  /// In en, this message translates to:
  /// **'Monthly SIP'**
  String get monthlySip;

  /// No description provided for @strategyNotes.
  ///
  /// In en, this message translates to:
  /// **'STRATEGY NOTES'**
  String get strategyNotes;

  /// No description provided for @contributionHistory.
  ///
  /// In en, this message translates to:
  /// **'CONTRIBUTION HISTORY'**
  String get contributionHistory;

  /// No description provided for @noContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions recorded'**
  String get noContributions;

  /// No description provided for @updateCurrentValue.
  ///
  /// In en, this message translates to:
  /// **'Update Current Value'**
  String get updateCurrentValue;

  /// No description provided for @updateLabel.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateLabel;

  /// No description provided for @contributionLabel.
  ///
  /// In en, this message translates to:
  /// **'Contribution'**
  String get contributionLabel;

  /// No description provided for @recordContributionUpper.
  ///
  /// In en, this message translates to:
  /// **'RECORD CONTRIBUTION'**
  String get recordContributionUpper;

  /// No description provided for @noteOptionalUpper.
  ///
  /// In en, this message translates to:
  /// **'NOTE (OPTIONAL)'**
  String get noteOptionalUpper;

  /// No description provided for @assetAllocation.
  ///
  /// In en, this message translates to:
  /// **'ASSET ALLOCATION'**
  String get assetAllocation;

  /// No description provided for @investmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nifty 50 Index Fund'**
  String get investmentNameHint;

  /// No description provided for @sipAmountPrefix.
  ///
  /// In en, this message translates to:
  /// **'SIP {amount}'**
  String sipAmountPrefix(String amount);

  /// No description provided for @monthlySipValue.
  ///
  /// In en, this message translates to:
  /// **'{amount} on {day}th'**
  String monthlySipValue(String amount, String day);

  /// No description provided for @addRecurring.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring'**
  String get addRecurring;

  /// No description provided for @noRecurring.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get noRecurring;

  /// No description provided for @recurringEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Automate subscriptions and repeated payments'**
  String get recurringEmptyDesc;

  /// No description provided for @rulesUpper.
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get rulesUpper;

  /// No description provided for @recentlyProcessed.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY PROCESSED'**
  String get recentlyProcessed;

  /// No description provided for @freqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqDaily;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @freqBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get freqBiweekly;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get freqQuarterly;

  /// No description provided for @freqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get freqYearly;

  /// No description provided for @freqCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get freqCustom;

  /// No description provided for @editRecurring.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring'**
  String get editRecurring;

  /// No description provided for @newRecurring.
  ///
  /// In en, this message translates to:
  /// **'New recurring'**
  String get newRecurring;

  /// No description provided for @transactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transactionLabel;

  /// No description provided for @amountTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountTitle;

  /// No description provided for @recurringNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Netflix, Rent)'**
  String get recurringNameHint;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @scheduleSublabel.
  ///
  /// In en, this message translates to:
  /// **'When this transaction repeats'**
  String get scheduleSublabel;

  /// No description provided for @frequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequencyLabel;

  /// No description provided for @everyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get everyLabel;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startsOn;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsLabel;

  /// No description provided for @neverLabel.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverLabel;

  /// No description provided for @afterN.
  ///
  /// In en, this message translates to:
  /// **'After N'**
  String get afterN;

  /// No description provided for @onDate.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get onDate;

  /// No description provided for @afterLabel.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get afterLabel;

  /// No description provided for @occurrencesLabel.
  ///
  /// In en, this message translates to:
  /// **'occurrences'**
  String get occurrencesLabel;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @recurringNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional · context, reference, anything'**
  String get recurringNotesHint;

  /// No description provided for @saveRecurring.
  ///
  /// In en, this message translates to:
  /// **'Save recurring'**
  String get saveRecurring;

  /// No description provided for @nextOccurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Next occurrence'**
  String get nextOccurrenceLabel;

  /// No description provided for @cadenceDaily.
  ///
  /// In en, this message translates to:
  /// **'then every day'**
  String get cadenceDaily;

  /// No description provided for @cadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'then every week'**
  String get cadenceWeekly;

  /// No description provided for @cadenceBiweekly.
  ///
  /// In en, this message translates to:
  /// **'then every 2 weeks'**
  String get cadenceBiweekly;

  /// No description provided for @cadenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'then every month'**
  String get cadenceMonthly;

  /// No description provided for @cadenceYearly.
  ///
  /// In en, this message translates to:
  /// **'then every year'**
  String get cadenceYearly;

  /// No description provided for @cadenceCustom.
  ///
  /// In en, this message translates to:
  /// **'then every custom interval'**
  String get cadenceCustom;

  /// No description provided for @activeUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeUpper;

  /// No description provided for @activeCustomUpper.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE • CUSTOM'**
  String get activeCustomUpper;

  /// No description provided for @pausedUpper.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get pausedUpper;

  /// No description provided for @freqEveryNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {count} days'**
  String freqEveryNDays(String count);

  /// No description provided for @recurringAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'RECURRING {type} AMOUNT'**
  String recurringAmountLabel(String type);

  /// No description provided for @frequencyUpper.
  ///
  /// In en, this message translates to:
  /// **'FREQUENCY'**
  String get frequencyUpper;

  /// No description provided for @deleteAutomationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete automation?'**
  String get deleteAutomationConfirm;

  /// No description provided for @deleteAutomationBody.
  ///
  /// In en, this message translates to:
  /// **'The recurring rule for \"{name}\" will be permanently deleted.'**
  String deleteAutomationBody(String name);

  /// No description provided for @monthlyAutomationCost.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY AUTOMATION COST'**
  String get monthlyAutomationCost;

  /// No description provided for @upcomingCharges.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING CHARGES'**
  String get upcomingCharges;

  /// No description provided for @todayUpper.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayUpper;

  /// No description provided for @tomorrowUpper.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW'**
  String get tomorrowUpper;

  /// No description provided for @yesterdayUpper.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get yesterdayUpper;

  /// No description provided for @inDaysUpper.
  ///
  /// In en, this message translates to:
  /// **'IN {count} DAYS'**
  String inDaysUpper(String count);

  /// No description provided for @nextChargeLabel.
  ///
  /// In en, this message translates to:
  /// **'Next charge'**
  String get nextChargeLabel;

  /// No description provided for @backingUpAuto.
  ///
  /// In en, this message translates to:
  /// **'Backing up automatically'**
  String get backingUpAuto;

  /// No description provided for @processingRecurring.
  ///
  /// In en, this message translates to:
  /// **'Processing Recurring'**
  String get processingRecurring;

  /// No description provided for @savingCopyToFolder.
  ///
  /// In en, this message translates to:
  /// **'Saving a copy to your chosen folder.'**
  String get savingCopyToFolder;

  /// No description provided for @creatingMissedTxns.
  ///
  /// In en, this message translates to:
  /// **'Creating missed transactions.'**
  String get creatingMissedTxns;

  /// No description provided for @folderUpper.
  ///
  /// In en, this message translates to:
  /// **'FOLDER'**
  String get folderUpper;

  /// No description provided for @processedUpper.
  ///
  /// In en, this message translates to:
  /// **'PROCESSED'**
  String get processedUpper;

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedLabel;

  /// No description provided for @nTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String nTransactions(int count);

  /// No description provided for @networkUpper.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get networkUpper;

  /// No description provided for @localOnly.
  ///
  /// In en, this message translates to:
  /// **'Local Only'**
  String get localOnly;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {details}'**
  String errorLoadingHistory(String details);

  /// No description provided for @recurringHistoryEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Transactions generated by this automation will appear here.'**
  String get recurringHistoryEmptyDesc;

  /// No description provided for @todayLower.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get todayLower;

  /// No description provided for @tomorrowLower.
  ///
  /// In en, this message translates to:
  /// **'tomorrow'**
  String get tomorrowLower;

  /// No description provided for @betaBadge.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get betaBadge;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategories;

  /// No description provided for @categoriesEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize your expenses'**
  String get categoriesEmptyDesc;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @searchCategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories and groups...'**
  String get searchCategoriesHint;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @addCategoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Classify your transactions for better tracking'**
  String get addCategoryDesc;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get editGroup;

  /// No description provided for @categoryGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Category group'**
  String get categoryGroupSubtitle;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name (e.g. Food, Transport)'**
  String get groupNameHint;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Group?'**
  String get deleteGroupConfirm;

  /// No description provided for @deleteGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Categories in \"{name}\" will be moved to \"Ungrouped\".'**
  String deleteGroupBody(String name);

  /// No description provided for @categoryDetail.
  ///
  /// In en, this message translates to:
  /// **'Category Detail'**
  String get categoryDetail;

  /// No description provided for @groupUpper.
  ///
  /// In en, this message translates to:
  /// **'GROUP'**
  String get groupUpper;

  /// No description provided for @typeUpper.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get typeUpper;

  /// No description provided for @incomeAndExpense.
  ///
  /// In en, this message translates to:
  /// **'Income & Expense'**
  String get incomeAndExpense;

  /// No description provided for @cannotDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category'**
  String get cannotDeleteCategory;

  /// No description provided for @cannotDeleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'This category has transactions linked to it. To delete this category, delete the linked transactions first.'**
  String get cannotDeleteCategoryBody;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @bothLabel.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothLabel;

  /// No description provided for @saveCategory.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get saveCategory;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added'**
  String get categoryAdded;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryNameLabel;

  /// No description provided for @livePreview.
  ///
  /// In en, this message translates to:
  /// **'LIVE PREVIEW'**
  String get livePreview;

  /// No description provided for @selectGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Group'**
  String get selectGroup;

  /// No description provided for @groupNameShortHint.
  ///
  /// In en, this message translates to:
  /// **'Group name...'**
  String get groupNameShortHint;

  /// No description provided for @addNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Add New Group'**
  String get addNewGroup;

  /// No description provided for @noBudgetSet.
  ///
  /// In en, this message translates to:
  /// **'No budget set'**
  String get noBudgetSet;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage\nCategories'**
  String get categoriesTitle;

  /// No description provided for @noCategoryMatches.
  ///
  /// In en, this message translates to:
  /// **'No categories or groups match \"{query}\".'**
  String noCategoryMatches(String query);

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryConfirm;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be permanently deleted.'**
  String deleteCategoryBody(String name);

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Groceries, Rent, Salary'**
  String get categoryNameHint;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage\nTags'**
  String get tagsTitle;

  /// No description provided for @tagsHeaderDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize transactions with custom labels.'**
  String get tagsHeaderDesc;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTag;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTags;

  /// No description provided for @tagsEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create hashtags to track specific expenses.'**
  String get tagsEmptyDesc;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get newTag;

  /// No description provided for @updateTag.
  ///
  /// In en, this message translates to:
  /// **'Update Tag'**
  String get updateTag;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create Tag'**
  String get createTag;

  /// No description provided for @enableLabel.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enableLabel;

  /// No description provided for @disableLabel.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableLabel;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get deleteTagConfirm;

  /// No description provided for @deleteTagBody.
  ///
  /// In en, this message translates to:
  /// **'The tag \"#{name}\" will be permanently deleted.'**
  String deleteTagBody(String name);

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: weekend, trip-to-goa'**
  String get tagNameHint;

  /// No description provided for @searchOrCreateTagHint.
  ///
  /// In en, this message translates to:
  /// **'Search or create tag...'**
  String get searchOrCreateTagHint;

  /// No description provided for @tagDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Tag is disabled. Enable it from More → Tags.'**
  String get tagDisabledMessage;

  /// No description provided for @exportHistory.
  ///
  /// In en, this message translates to:
  /// **'Export History'**
  String get exportHistory;

  /// No description provided for @exportAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Export Analytics'**
  String get exportAnalytics;

  /// No description provided for @selectFormat.
  ///
  /// In en, this message translates to:
  /// **'SELECT FORMAT'**
  String get selectFormat;

  /// No description provided for @formatUpper.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get formatUpper;

  /// No description provided for @spreadsheetLabel.
  ///
  /// In en, this message translates to:
  /// **'SPREADSHEET'**
  String get spreadsheetLabel;

  /// No description provided for @documentLabel.
  ///
  /// In en, this message translates to:
  /// **'DOCUMENT'**
  String get documentLabel;

  /// No description provided for @pdfDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF Document'**
  String get pdfDocument;

  /// No description provided for @pdfDocumentDesc.
  ///
  /// In en, this message translates to:
  /// **'Universal format for high-fidelity printing.'**
  String get pdfDocumentDesc;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @applyCurrentFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply current filters'**
  String get applyCurrentFilters;

  /// No description provided for @applyFiltersDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate report using the active filters from the history page.'**
  String get applyFiltersDesc;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// No description provided for @selectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'SELECTED PERIOD'**
  String get selectedPeriod;

  /// No description provided for @analyticsDateFilterInfo.
  ///
  /// In en, this message translates to:
  /// **'Date filters from your current analytics view are automatically applied to this report.'**
  String get analyticsDateFilterInfo;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Export Successful'**
  String get exportSuccessful;

  /// No description provided for @reportReady.
  ///
  /// In en, this message translates to:
  /// **'Your report is ready.'**
  String get reportReady;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @savingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingEllipsis;

  /// No description provided for @saveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Save to Folder'**
  String get saveToFolder;

  /// No description provided for @shareLabel.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// No description provided for @noAppToOpen.
  ///
  /// In en, this message translates to:
  /// **'No app found to open this file type.'**
  String get noAppToOpen;

  /// No description provided for @fileSaved.
  ///
  /// In en, this message translates to:
  /// **'File saved successfully.'**
  String get fileSaved;

  /// No description provided for @couldNotShareFile.
  ///
  /// In en, this message translates to:
  /// **'Could not share file: {details}'**
  String couldNotShareFile(String details);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export Failed'**
  String get exportFailed;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @exportGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate file. Please try again.'**
  String get exportGenerateFailed;

  /// No description provided for @failedToSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save file.'**
  String get failedToSaveFile;

  /// No description provided for @chartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get chartsTitle;

  /// No description provided for @chartsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visualise your spending patterns over time.'**
  String get chartsSubtitle;

  /// No description provided for @wipBadge.
  ///
  /// In en, this message translates to:
  /// **'WIP'**
  String get wipBadge;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @tapBarForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar to see details'**
  String get tapBarForDetails;

  /// No description provided for @incomeUpper.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get incomeUpper;

  /// No description provided for @expenseUpper.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expenseUpper;

  /// No description provided for @netUpper.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get netUpper;

  /// No description provided for @noExpenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No expense breakdown available.'**
  String get noExpenseBreakdown;

  /// No description provided for @byCategoryUpper.
  ///
  /// In en, this message translates to:
  /// **'BY CATEGORY'**
  String get byCategoryUpper;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqAddTxnQ.
  ///
  /// In en, this message translates to:
  /// **'How do I add a transaction?'**
  String get faqAddTxnQ;

  /// No description provided for @faqAddTxnA.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button on the bottom right to add a new transaction. Fill in the amount, select a category and account, then save.'**
  String get faqAddTxnA;

  /// No description provided for @faqAccountsQ.
  ///
  /// In en, this message translates to:
  /// **'How do I manage accounts?'**
  String get faqAccountsQ;

  /// No description provided for @faqAccountsA.
  ///
  /// In en, this message translates to:
  /// **'Go to More → Accounts to see all your wallets and bank accounts. You can add new accounts or edit existing ones from there.'**
  String get faqAccountsA;

  /// No description provided for @faqTransfersQ.
  ///
  /// In en, this message translates to:
  /// **'How do transfers work?'**
  String get faqTransfersQ;

  /// No description provided for @faqTransfersA.
  ///
  /// In en, this message translates to:
  /// **'When adding a transaction, select \"Transfer\" as the type. Pick the source and destination accounts and the amount will be moved between them.'**
  String get faqTransfersA;

  /// No description provided for @faqCategoriesQ.
  ///
  /// In en, this message translates to:
  /// **'Can I customize categories?'**
  String get faqCategoriesQ;

  /// No description provided for @faqCategoriesA.
  ///
  /// In en, this message translates to:
  /// **'Yes! Go to More → Categories to view all categories. Default categories cannot be deleted, but you can add your own custom categories.'**
  String get faqCategoriesA;

  /// No description provided for @dataExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get dataExportTitle;

  /// No description provided for @backupUpper.
  ///
  /// In en, this message translates to:
  /// **'BACKUP'**
  String get backupUpper;

  /// No description provided for @exportCsvDesc.
  ///
  /// In en, this message translates to:
  /// **'Exports transactions, categories, accounts and tags. Does not include recurring automations, budgets, loans, investments, or attachments.'**
  String get exportCsvDesc;

  /// No description provided for @exportJsonDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete app backup (excluding attachments). Can be used to restore all your data on a new device or after reinstalling.'**
  String get exportJsonDesc;

  /// No description provided for @fileReady.
  ///
  /// In en, this message translates to:
  /// **'Your file is ready.'**
  String get fileReady;

  /// No description provided for @saveACopy.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get saveACopy;

  /// No description provided for @dataImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get dataImportTitle;

  /// No description provided for @selectFileImport.
  ///
  /// In en, this message translates to:
  /// **'Select File & Import'**
  String get selectFileImport;

  /// No description provided for @overrideExistingData.
  ///
  /// In en, this message translates to:
  /// **'Override existing data'**
  String get overrideExistingData;

  /// No description provided for @importWipeDesc.
  ///
  /// In en, this message translates to:
  /// **'All existing data will be wiped before import.'**
  String get importWipeDesc;

  /// No description provided for @importMergeDesc.
  ///
  /// In en, this message translates to:
  /// **'New records will be merged with existing data.'**
  String get importMergeDesc;

  /// No description provided for @importWipeWarning.
  ///
  /// In en, this message translates to:
  /// **'All existing data will be permanently deleted before import.'**
  String get importWipeWarning;

  /// No description provided for @importMergeChip.
  ///
  /// In en, this message translates to:
  /// **'New records will be merged with your existing data.'**
  String get importMergeChip;

  /// No description provided for @importReplaceWarning.
  ///
  /// In en, this message translates to:
  /// **'All existing data will be permanently deleted and replaced with the backup.'**
  String get importReplaceWarning;

  /// No description provided for @downloadTemplate.
  ///
  /// In en, this message translates to:
  /// **'Download Template'**
  String get downloadTemplate;

  /// No description provided for @downloadTemplateDesc.
  ///
  /// In en, this message translates to:
  /// **'Get a CSV with the correct column headers to format your data.'**
  String get downloadTemplateDesc;

  /// No description provided for @backupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic\nBackups'**
  String get backupsTitle;

  /// No description provided for @backupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep a fresh copy of your data saved to your device, on a schedule.'**
  String get backupsSubtitle;

  /// No description provided for @statusSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusSectionLabel;

  /// No description provided for @configurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configurationLabel;

  /// No description provided for @actionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsLabel;

  /// No description provided for @backupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup now'**
  String get backupNow;

  /// No description provided for @alreadyBackedUpToday.
  ///
  /// In en, this message translates to:
  /// **'Already backed up today'**
  String get alreadyBackedUpToday;

  /// No description provided for @lastBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Last backup failed'**
  String get lastBackupFailed;

  /// No description provided for @backupFolderErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t access your backup folder. It may have moved or permission may have been revoked.'**
  String get backupFolderErrorDesc;

  /// No description provided for @attemptedOn.
  ///
  /// In en, this message translates to:
  /// **'Attempted {label}'**
  String attemptedOn(String label);

  /// No description provided for @chooseNewFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose new folder'**
  String get chooseNewFolder;

  /// No description provided for @backedUp.
  ///
  /// In en, this message translates to:
  /// **'Backed up'**
  String get backedUp;

  /// No description provided for @backedUpOn.
  ///
  /// In en, this message translates to:
  /// **'Backed up {label}'**
  String backedUpOn(String label);

  /// No description provided for @lastCopySaved.
  ///
  /// In en, this message translates to:
  /// **'Last copy saved successfully. Keeping your most recent {count} backups.'**
  String lastCopySaved(String count);

  /// No description provided for @neverLoseData.
  ///
  /// In en, this message translates to:
  /// **'Never lose your data'**
  String get neverLoseData;

  /// No description provided for @neverLoseDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn on automatic backups and Kuber will save a copy to a folder you choose when an app open is due.'**
  String get neverLoseDataDesc;

  /// No description provided for @automaticBackups.
  ///
  /// In en, this message translates to:
  /// **'Automatic Backups'**
  String get automaticBackups;

  /// No description provided for @saveCopyOnSchedule.
  ///
  /// In en, this message translates to:
  /// **'Save a copy on a schedule'**
  String get saveCopyOnSchedule;

  /// No description provided for @keepLast.
  ///
  /// In en, this message translates to:
  /// **'Keep last'**
  String get keepLast;

  /// No description provided for @backupFolder.
  ///
  /// In en, this message translates to:
  /// **'Backup folder'**
  String get backupFolder;

  /// No description provided for @exportingData.
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportingData;

  /// No description provided for @preparingFile.
  ///
  /// In en, this message translates to:
  /// **'Preparing your file'**
  String get preparingFile;

  /// No description provided for @dataExportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get dataExportedSuccess;

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export Complete'**
  String get exportComplete;

  /// No description provided for @savedToDownloads.
  ///
  /// In en, this message translates to:
  /// **'Saved to Downloads/{fileName}'**
  String savedToDownloads(String fileName);

  /// No description provided for @exportFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailedMsg(String error);

  /// No description provided for @downloadingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Downloading template...'**
  String get downloadingTemplate;

  /// No description provided for @preparingCsvTemplate.
  ///
  /// In en, this message translates to:
  /// **'Preparing CSV template'**
  String get preparingCsvTemplate;

  /// No description provided for @templateDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Template downloaded successfully'**
  String get templateDownloadedSuccess;

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete'**
  String get downloadComplete;

  /// No description provided for @downloadFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailedMsg(String error);

  /// No description provided for @downloadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Failed'**
  String get downloadFailedTitle;

  /// No description provided for @importFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailedMsg(String error);

  /// No description provided for @mockDataGenerated.
  ///
  /// In en, this message translates to:
  /// **'Mock data generated successfully'**
  String get mockDataGenerated;

  /// No description provided for @generationFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Generation failed: {error}'**
  String generationFailedMsg(String error);

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get allDataCleared;

  /// No description provided for @clearFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Clear failed: {error}'**
  String clearFailedMsg(String error);

  /// No description provided for @rebuildFailedMsg.
  ///
  /// In en, this message translates to:
  /// **'Rebuild failed: {error}'**
  String rebuildFailedMsg(String error);

  /// No description provided for @notifNewRecurring.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{New recurring transaction} other{{count} recurring transactions added}}'**
  String notifNewRecurring(int count);

  /// No description provided for @notifRecurringBody.
  ///
  /// In en, this message translates to:
  /// **'{name} - added while you were away'**
  String notifRecurringBody(String name);

  /// No description provided for @notifLoanEmiTitle.
  ///
  /// In en, this message translates to:
  /// **'Loan EMI deducted'**
  String get notifLoanEmiTitle;

  /// No description provided for @notifLoanEmiBody.
  ///
  /// In en, this message translates to:
  /// **'{name} - EMI added to your transactions'**
  String notifLoanEmiBody(String name);

  /// No description provided for @notifInvestmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Investment contribution added'**
  String get notifInvestmentTitle;

  /// No description provided for @notifInvestmentBody.
  ///
  /// In en, this message translates to:
  /// **'{name} - SIP contribution recorded'**
  String notifInvestmentBody(String name);

  /// No description provided for @notifMoneyToCollect.
  ///
  /// In en, this message translates to:
  /// **'Money to collect'**
  String get notifMoneyToCollect;

  /// No description provided for @notifMoneyToRepay.
  ///
  /// In en, this message translates to:
  /// **'Money to repay'**
  String get notifMoneyToRepay;

  /// No description provided for @notifLedgerReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{person} - due today} =1{{person} - 1 day overdue} other{{person} - {count} days overdue}}'**
  String notifLedgerReminderBody(String person, int count);

  /// No description provided for @notifBudgetAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Alert'**
  String get notifBudgetAlertTitle;

  /// No description provided for @notifBudgetReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached {pct}% of your {category} budget'**
  String notifBudgetReachedBody(String pct, String category);

  /// No description provided for @notifBudgetSpentBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve spent {amount} in {category} category'**
  String notifBudgetSpentBody(String amount, String category);

  /// No description provided for @wgtBalanceHeroName.
  ///
  /// In en, this message translates to:
  /// **'Balance Card'**
  String get wgtBalanceHeroName;

  /// No description provided for @wgtBalanceHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Current-month net with income / expense split'**
  String get wgtBalanceHeroDesc;

  /// No description provided for @wgtInsightStoriesName.
  ///
  /// In en, this message translates to:
  /// **'Money Stories'**
  String get wgtInsightStoriesName;

  /// No description provided for @wgtInsightStoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Recaps and highlights about your money'**
  String get wgtInsightStoriesDesc;

  /// No description provided for @wgtQuickAddName.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get wgtQuickAddName;

  /// No description provided for @wgtQuickAddDesc.
  ///
  /// In en, this message translates to:
  /// **'One-tap expense / income / transfer entry'**
  String get wgtQuickAddDesc;

  /// No description provided for @wgtSpendingStatsName.
  ///
  /// In en, this message translates to:
  /// **'Spending Stats'**
  String get wgtSpendingStatsName;

  /// No description provided for @wgtSpendingStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Spent vs received this month'**
  String get wgtSpendingStatsDesc;

  /// No description provided for @wgtHomeAccountsName.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get wgtHomeAccountsName;

  /// No description provided for @wgtHomeAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'All accounts and balances'**
  String get wgtHomeAccountsDesc;

  /// No description provided for @wgtSevenDayChartName.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days Chart'**
  String get wgtSevenDayChartName;

  /// No description provided for @wgtSevenDayChartDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily income vs expense for the past week'**
  String get wgtSevenDayChartDesc;

  /// No description provided for @wgtBudgetSnapshotName.
  ///
  /// In en, this message translates to:
  /// **'Budget Snapshot'**
  String get wgtBudgetSnapshotName;

  /// No description provided for @wgtBudgetSnapshotDesc.
  ///
  /// In en, this message translates to:
  /// **'Progress against active budgets'**
  String get wgtBudgetSnapshotDesc;

  /// No description provided for @wgtUpcomingRecurringName.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Recurring'**
  String get wgtUpcomingRecurringName;

  /// No description provided for @wgtUpcomingRecurringDesc.
  ///
  /// In en, this message translates to:
  /// **'Next recurring transactions due'**
  String get wgtUpcomingRecurringDesc;

  /// No description provided for @wgtRecentTransactionsName.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get wgtRecentTransactionsName;

  /// No description provided for @wgtRecentTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Latest activity at a glance'**
  String get wgtRecentTransactionsDesc;

  /// No description provided for @wgtSummaryCardName.
  ///
  /// In en, this message translates to:
  /// **'Summary Card'**
  String get wgtSummaryCardName;

  /// No description provided for @wgtSummaryCardDesc.
  ///
  /// In en, this message translates to:
  /// **'Income, expense and net for the period'**
  String get wgtSummaryCardDesc;

  /// No description provided for @wgtSpendingTrendName.
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get wgtSpendingTrendName;

  /// No description provided for @wgtSpendingTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Bar / line chart with bucket dropdown'**
  String get wgtSpendingTrendDesc;

  /// No description provided for @wgtWeeklyHeatmapName.
  ///
  /// In en, this message translates to:
  /// **'Weekly Heatmap'**
  String get wgtWeeklyHeatmapName;

  /// No description provided for @wgtWeeklyHeatmapDesc.
  ///
  /// In en, this message translates to:
  /// **'Average expense by day of week'**
  String get wgtWeeklyHeatmapDesc;

  /// No description provided for @wgtSizeDistributionName.
  ///
  /// In en, this message translates to:
  /// **'Transaction Sizes'**
  String get wgtSizeDistributionName;

  /// No description provided for @wgtSizeDistributionDesc.
  ///
  /// In en, this message translates to:
  /// **'Small / medium / large breakdown'**
  String get wgtSizeDistributionDesc;

  /// No description provided for @wgtCategoryBreakdownName.
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get wgtCategoryBreakdownName;

  /// No description provided for @wgtCategoryBreakdownDesc.
  ///
  /// In en, this message translates to:
  /// **'Spending grouped by category'**
  String get wgtCategoryBreakdownDesc;

  /// No description provided for @wgtTagAnalyticsName.
  ///
  /// In en, this message translates to:
  /// **'Tag Analytics'**
  String get wgtTagAnalyticsName;

  /// No description provided for @wgtTagAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Totals grouped by tag'**
  String get wgtTagAnalyticsDesc;

  /// No description provided for @wgtBiggestTransactionsName.
  ///
  /// In en, this message translates to:
  /// **'Biggest Transactions'**
  String get wgtBiggestTransactionsName;

  /// No description provided for @wgtBiggestTransactionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Top 5 by amount, expense or income'**
  String get wgtBiggestTransactionsDesc;

  /// No description provided for @atLeastOneWidget.
  ///
  /// In en, this message translates to:
  /// **'At least one widget must be enabled'**
  String get atLeastOneWidget;

  /// No description provided for @discardChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesConfirm;

  /// No description provided for @discardChangesBody.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes to your widgets. Leaving now will discard them.'**
  String get discardChangesBody;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discardLabel.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardLabel;

  /// No description provided for @unlockToContinue.
  ///
  /// In en, this message translates to:
  /// **'Unlock to continue'**
  String get unlockToContinue;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your personal money diary'**
  String get splashTagline;

  /// No description provided for @tutCh0Title.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get tutCh0Title;

  /// No description provided for @tutCh0Desc.
  ///
  /// In en, this message translates to:
  /// **'Add income, expenses, transfers, notes, receipts and tags.'**
  String get tutCh0Desc;

  /// No description provided for @tutCh0St0Title.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get tutCh0St0Title;

  /// No description provided for @tutCh0St0Desc.
  ///
  /// In en, this message translates to:
  /// **'Type the amount directly. Tap the calculator icon to open the built-in expression calculator.'**
  String get tutCh0St0Desc;

  /// No description provided for @tutCh0St1Title.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get tutCh0St1Title;

  /// No description provided for @tutCh0St1Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose Income, Expense, or Transfer between your accounts.'**
  String get tutCh0St1Desc;

  /// No description provided for @tutCh0St2Title.
  ///
  /// In en, this message translates to:
  /// **'Pick a category'**
  String get tutCh0St2Title;

  /// No description provided for @tutCh0St2Desc.
  ///
  /// In en, this message translates to:
  /// **'Categories organize your spending. Tap to choose an existing one or create your own.'**
  String get tutCh0St2Desc;

  /// No description provided for @tutCh0St3Title.
  ///
  /// In en, this message translates to:
  /// **'Pick an account'**
  String get tutCh0St3Title;

  /// No description provided for @tutCh0St3Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose which wallet or bank account this belongs to.'**
  String get tutCh0St3Desc;

  /// No description provided for @tutCh0St4Title.
  ///
  /// In en, this message translates to:
  /// **'Name it'**
  String get tutCh0St4Title;

  /// No description provided for @tutCh0St4Desc.
  ///
  /// In en, this message translates to:
  /// **'Start typing and Kuber will suggest from your past transactions automatically.'**
  String get tutCh0St4Desc;

  /// No description provided for @tutCh0St5Title.
  ///
  /// In en, this message translates to:
  /// **'Smart suggestions'**
  String get tutCh0St5Title;

  /// No description provided for @tutCh0St5Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap a suggestion to auto-fill the name, category, and account in one tap.'**
  String get tutCh0St5Desc;

  /// No description provided for @tutCh0St6Title.
  ///
  /// In en, this message translates to:
  /// **'Notes & attachments'**
  String get tutCh0St6Title;

  /// No description provided for @tutCh0St6Desc.
  ///
  /// In en, this message translates to:
  /// **'Add context or attach a photo of your receipt.'**
  String get tutCh0St6Desc;

  /// No description provided for @tutCh0St7Title.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get tutCh0St7Title;

  /// No description provided for @tutCh0St7Desc.
  ///
  /// In en, this message translates to:
  /// **'Tags are custom labels that group transactions across categories.'**
  String get tutCh0St7Desc;

  /// No description provided for @tutCh1Title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tutCh1Title;

  /// No description provided for @tutCh1Desc.
  ///
  /// In en, this message translates to:
  /// **'Read your monthly snapshot and use quick actions.'**
  String get tutCh1Desc;

  /// No description provided for @tutCh1St0Title.
  ///
  /// In en, this message translates to:
  /// **'Your monthly snapshot'**
  String get tutCh1St0Title;

  /// No description provided for @tutCh1St0Desc.
  ///
  /// In en, this message translates to:
  /// **'Net flow for this month at a glance. Green is income, red is expense. Tap to drill down.'**
  String get tutCh1St0Desc;

  /// No description provided for @tutCh1St1Title.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode'**
  String get tutCh1St1Title;

  /// No description provided for @tutCh1St1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the eye icon to instantly hide every balance. Perfect for public places.'**
  String get tutCh1St1Desc;

  /// No description provided for @tutCh1St2Title.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get tutCh1St2Title;

  /// No description provided for @tutCh1St2Desc.
  ///
  /// In en, this message translates to:
  /// **'Log a transaction in seconds without opening the full form. Just type and go.'**
  String get tutCh1St2Desc;

  /// No description provided for @tutCh1St3Title.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get tutCh1St3Title;

  /// No description provided for @tutCh1St3Desc.
  ///
  /// In en, this message translates to:
  /// **'Your last few transactions appear below the balance card. Tap any to view or edit.'**
  String get tutCh1St3Desc;

  /// No description provided for @tutCh1St4Title.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get tutCh1St4Title;

  /// No description provided for @tutCh1St4Desc.
  ///
  /// In en, this message translates to:
  /// **'Use the bottom bar to switch between Home, History, Analytics, and More.'**
  String get tutCh1St4Desc;

  /// No description provided for @tutCh2Title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tutCh2Title;

  /// No description provided for @tutCh2Desc.
  ///
  /// In en, this message translates to:
  /// **'Find, filter, inspect and edit past transactions.'**
  String get tutCh2Desc;

  /// No description provided for @tutCh2St0Title.
  ///
  /// In en, this message translates to:
  /// **'Transaction timeline'**
  String get tutCh2St0Title;

  /// No description provided for @tutCh2St0Desc.
  ///
  /// In en, this message translates to:
  /// **'All your transactions, grouped by date. Most recent at the top.'**
  String get tutCh2St0Desc;

  /// No description provided for @tutCh2St1Title.
  ///
  /// In en, this message translates to:
  /// **'Quick filters'**
  String get tutCh2St1Title;

  /// No description provided for @tutCh2St1Desc.
  ///
  /// In en, this message translates to:
  /// **'Filter by Income, Expense, or Transfer instantly using these chips.'**
  String get tutCh2St1Desc;

  /// No description provided for @tutCh2St2Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get tutCh2St2Title;

  /// No description provided for @tutCh2St2Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the filter icon to search by date range, account, category, or tags simultaneously.'**
  String get tutCh2St2Desc;

  /// No description provided for @tutCh2St3Title.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get tutCh2St3Title;

  /// No description provided for @tutCh2St3Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap any transaction to view full details, edit fields, or delete it.'**
  String get tutCh2St3Desc;

  /// No description provided for @tutCh3Title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get tutCh3Title;

  /// No description provided for @tutCh3Desc.
  ///
  /// In en, this message translates to:
  /// **'Spot trends and understand where your money goes.'**
  String get tutCh3Desc;

  /// No description provided for @tutCh3St0Title.
  ///
  /// In en, this message translates to:
  /// **'Set the date range first'**
  String get tutCh3St0Title;

  /// No description provided for @tutCh3St0Desc.
  ///
  /// In en, this message translates to:
  /// **'By default only today\'s data is shown. Tap this pill and pick \"All time\" so the charts below have something to graph.'**
  String get tutCh3St0Desc;

  /// No description provided for @tutCh3St1Title.
  ///
  /// In en, this message translates to:
  /// **'Your financial snapshot'**
  String get tutCh3St1Title;

  /// No description provided for @tutCh3St1Desc.
  ///
  /// In en, this message translates to:
  /// **'Visual breakdowns of where your money goes each month.'**
  String get tutCh3St1Desc;

  /// No description provided for @tutCh3St2Title.
  ///
  /// In en, this message translates to:
  /// **'Spending trends'**
  String get tutCh3St2Title;

  /// No description provided for @tutCh3St2Desc.
  ///
  /// In en, this message translates to:
  /// **'A bar chart showing daily spending. Switch between 7-day and custom time ranges.'**
  String get tutCh3St2Desc;

  /// No description provided for @tutCh3St3Title.
  ///
  /// In en, this message translates to:
  /// **'Category breakdown'**
  String get tutCh3St3Title;

  /// No description provided for @tutCh3St3Desc.
  ///
  /// In en, this message translates to:
  /// **'See which categories consume the most of your budget at a glance.'**
  String get tutCh3St3Desc;

  /// No description provided for @tutCh3St4Title.
  ///
  /// In en, this message translates to:
  /// **'Filters carry over'**
  String get tutCh3St4Title;

  /// No description provided for @tutCh3St4Desc.
  ///
  /// In en, this message translates to:
  /// **'Any filters you set on the History page also update your analytics view.'**
  String get tutCh3St4Desc;

  /// No description provided for @tutCh4Title.
  ///
  /// In en, this message translates to:
  /// **'More & Settings'**
  String get tutCh4Title;

  /// No description provided for @tutCh4Desc.
  ///
  /// In en, this message translates to:
  /// **'Customize Kuber, manage data and explore deeper tools.'**
  String get tutCh4Desc;

  /// No description provided for @tutCh4St0Title.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get tutCh4St0Title;

  /// No description provided for @tutCh4St0Desc.
  ///
  /// In en, this message translates to:
  /// **'Set monthly spending limits per category. Kuber tracks your progress automatically.'**
  String get tutCh4St0Desc;

  /// No description provided for @tutCh4St1Title.
  ///
  /// In en, this message translates to:
  /// **'Ask Kuber'**
  String get tutCh4St1Title;

  /// No description provided for @tutCh4St1Desc.
  ///
  /// In en, this message translates to:
  /// **'Your on-device AI assistant. Ask questions about your spending privately.'**
  String get tutCh4St1Desc;

  /// No description provided for @tutCh4St2Title.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get tutCh4St2Title;

  /// No description provided for @tutCh4St2Desc.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV, import from backup, or generate sample data. Everything stays on your device.'**
  String get tutCh4St2Desc;

  /// No description provided for @tutorialUpper.
  ///
  /// In en, this message translates to:
  /// **'TUTORIAL'**
  String get tutorialUpper;

  /// No description provided for @pickChapter.
  ///
  /// In en, this message translates to:
  /// **'Pick a chapter.'**
  String get pickChapter;

  /// No description provided for @pickChapterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Five quick chapters, about 2 minutes each. Jump in anywhere.'**
  String get pickChapterSubtitle;

  /// No description provided for @startFromBeginning.
  ///
  /// In en, this message translates to:
  /// **'Start from beginning →'**
  String get startFromBeginning;

  /// No description provided for @skipTutorialConfirm.
  ///
  /// In en, this message translates to:
  /// **'Skip tutorial?'**
  String get skipTutorialConfirm;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @skipLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// No description provided for @replayHint.
  ///
  /// In en, this message translates to:
  /// **'You can always replay it from More → Tutorial.'**
  String get replayHint;

  /// No description provided for @replayHintApp.
  ///
  /// In en, this message translates to:
  /// **'You can always replay it from More → App Tutorial.'**
  String get replayHintApp;

  /// No description provided for @tutStepsAndMin.
  ///
  /// In en, this message translates to:
  /// **'{count} steps · ~{mins} min'**
  String tutStepsAndMin(String count, String mins);

  /// No description provided for @chapterDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter {num} done! 🎉'**
  String chapterDoneTitle(String num);

  /// No description provided for @endTutorial.
  ///
  /// In en, this message translates to:
  /// **'End tutorial'**
  String get endTutorial;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to start \"{title}\"?'**
  String readyToStart(String title);

  /// No description provided for @exitTutorialConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit tutorial?'**
  String get exitTutorialConfirm;

  /// No description provided for @exitLabel.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitLabel;

  /// No description provided for @chapterXofY.
  ///
  /// In en, this message translates to:
  /// **'Chapter {current} of {total}'**
  String chapterXofY(String current, String total);

  /// No description provided for @skipTour.
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get skipTour;

  /// No description provided for @nextArrow.
  ///
  /// In en, this message translates to:
  /// **'Next ›'**
  String get nextArrow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'kn',
    'ml',
    'mr',
    'pa',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
