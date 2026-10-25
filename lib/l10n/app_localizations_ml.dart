// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get continueLabel => 'തുടരുക';

  @override
  String get cancelLabel => 'റദ്ദാക്കുക';

  @override
  String get saveLabel => 'സൂക്ഷിക്കുക';

  @override
  String get editLabel => 'തിരുത്തുക';

  @override
  String get deleteLabel => 'ഇല്ലാതാക്കുക';

  @override
  String get gotIt => 'മനസ്സിലായി';

  @override
  String get skip => 'ഒഴിവാക്കുക';

  @override
  String get search => 'തിരയുക';

  @override
  String get getStarted => 'ആരംഭിക്കുക';

  @override
  String get starting => 'ആരംഭിക്കുന്നു...';

  @override
  String get startJourney => 'എന്റെ യാത്ര ആരംഭിക്കുക';

  @override
  String get yourMoneyYourRules => 'നിങ്ങളുടെ പണം.\nനിങ്ങളുടെ നിയമങ്ങൾ.';

  @override
  String get onboardingPage1Description =>
      'നിങ്ങളുടെ ഉപകരണത്തിൽ പ്രവർത്തിക്കുന്ന ഒരു ചിലവ് മാനേജർ. ക്ലൗഡ് ഇല്ല, സൈൻഅപ്പ് ഇല്ല, വിട്ടുവീഴ്ചകളില്ല.';

  @override
  String offlineFirstBadge(String version) {
    return 'ഓഫ്‌ലൈൻ-ഫസ്റ്റ് · $version';
  }

  @override
  String get recurringModule => 'ആവർത്തിക്കുന്നത്';

  @override
  String get makeItYours => 'ഇത് നിങ്ങളുടേതാക്കൂ.';

  @override
  String get threeQuickChoices => 'മൂന്ന് ദ്രുത ചോയിസുകൾ, നിങ്ങൾ തയ്യാറാണ്.';

  @override
  String get yourName => 'നിങ്ങളുടെ പേര്';

  @override
  String get currency => 'കറൻസി';

  @override
  String get theme => 'തീം';

  @override
  String get language => 'ഭാഷ';

  @override
  String get namePlaceholder => 'നിങ്ങളുടെ പേര്';

  @override
  String get nameRequired => 'ദയവായി നിങ്ങളുടെ പേര് നൽകുക';

  @override
  String get nameTooLong => 'പേര് 15 അക്ഷരങ്ങളിൽ കൂടരുത്';

  @override
  String get themeLight => 'ലൈറ്റ്';

  @override
  String get themeDark => 'ഡാർക്ക്';

  @override
  String get themeSystem => 'സിസ്റ്റം';

  @override
  String get settingsTitle => 'ക്രമീകരണങ്ങൾ';

  @override
  String get settingsSubtitle =>
      'കുബേർ എങ്ങനെയുള്ളതായിരിക്കണമെന്നും എങ്ങനെ പ്രവർത്തിക്കണമെന്നും ക്രമീകരിക്കുക.';

  @override
  String get profileSection => 'പ്രൊഫൈൽ';

  @override
  String get profileDescription => 'കുബേർ നിങ്ങളെ എങ്ങനെ അറിയുന്നു.';

  @override
  String get yourNameLabel => 'നിങ്ങളുടെ പേര്';

  @override
  String get userNameUpdated => 'പേര് അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get appearanceSection => 'രൂപഭാവം';

  @override
  String get appearanceDescription => 'കുബേർ നിങ്ങൾക്ക് എങ്ങനെ കാണപ്പെടുന്നു.';

  @override
  String get themeLabel => 'തീം';

  @override
  String get themeSubtitle =>
      'ലൈറ്റ്, ഡാർക്ക്, അല്ലെങ്കിൽ നിങ്ങളുടെ ഫോണിന് അനുയോജ്യമായത്';

  @override
  String get bottomNavLabel => 'ചുവടെയുള്ള നാവിഗേഷൻ';

  @override
  String get bottomNavSubtitle => 'സാധാരണ ബാർ അല്ലെങ്കിൽ ഫ്ലോട്ടിംഗ് പിൽ';

  @override
  String get moreTabLayoutLabel => 'കൂടുതൽ ടാബ് ലേഔട്ട്';

  @override
  String get moreTabLayoutSubtitle =>
      'ലളിതമായ ലിസ്റ്റ് അല്ലെങ്കിൽ ആധുനിക ഹീറോ ലേഔട്ട്';

  @override
  String get widgetsSection => 'വിഡ്ജറ്റുകൾ';

  @override
  String get widgetsDescription =>
      'ഹോം, അനലിറ്റിക്സ് പേജുകളിൽ എന്തൊക്കെ കാണിക്കണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get homeWidgetsLabel => 'Home വിഡ്ജറ്റുകൾ';

  @override
  String homeWidgetsSubtitle(String count) {
    return '$count എണ്ണം സജീവമാക്കി · പുനഃക്രമീകരിക്കാൻ വലിച്ചിടുക';
  }

  @override
  String get analyticsWidgetsLabel => 'Analytics വിഡ്ജറ്റുകൾ';

  @override
  String analyticsWidgetsSubtitle(String count) {
    return '$count എണ്ണം സജീവമാക്കി · പുനഃക്രമീകരിക്കാൻ വലിച്ചിടുക';
  }

  @override
  String get moneyDisplaySection => 'പണത്തിന്റെ ഡിസ്‌പ്ലേ';

  @override
  String get moneyDisplayDescription =>
      'ആപ്പിലുടനീളം കറൻസിയും തുകകളും എങ്ങനെ കാണിക്കുന്നു.';

  @override
  String get currencyLabel => 'കറൻസി';

  @override
  String get currencySubtitle => 'തുകയ്ക്കൊപ്പം കാണിക്കുന്ന ചിഹ്നവും കോഡും';

  @override
  String get numberFormatLabel => 'സംഖ്യാ ഫോർമാറ്റ്';

  @override
  String get numberFormatSubtitle =>
      'ഇന്ത്യൻ (1,23,000) അല്ലെങ്കിൽ ഇന്റർനാഷണൽ (123,000)';

  @override
  String get transactionsSection => 'ഇടപാടുകൾ';

  @override
  String get transactionsDescription =>
      'പുതിയ എൻട്രികൾ ചേർക്കുമ്പോഴുള്ള നിങ്ങളുടെ ഡിഫോൾട്ടുകൾ.';

  @override
  String get defaultAccountLabel => 'ഡിഫോൾട്ട് അക്കൗണ്ട്';

  @override
  String get defaultAccountSubtitle =>
      'പെട്ടെന്ന് ചേർക്കുമ്പോൾ മുൻകൂട്ടി തിരഞ്ഞെടുത്തത്';

  @override
  String get horizontalSwipeLabel => 'ഹൊറിസോണ്ടൽ സ്വൈപ്പ്';

  @override
  String get horizontalSwipeSubtitle =>
      'ഇടത്തോട്ടോ വലത്തോട്ടോ സ്വൈപ്പ് ചെയ്യുമ്പോൾ എന്ത് സംഭവിക്കുന്നു';

  @override
  String get privacySecuritySection => 'സ്വകാര്യതയും സുരക്ഷയും';

  @override
  String get privacySecurityDescription =>
      'നിങ്ങളുടെ നമ്പറുകൾ സ്വകാര്യമായി സൂക്ഷിക്കുകയും ആപ്പ് ലോക്ക് ചെയ്യുകയും ചെയ്യുക.';

  @override
  String get privacyModeLabel => 'സ്വകാര്യതാ മോഡ്';

  @override
  String get privacyModeSubtitle => 'എല്ലാ ബാലൻസുകളും തുകകളും മറയ്ക്കുക';

  @override
  String get biometricLockLabel => 'ബയോമെട്രിക് ലോക്ക്';

  @override
  String get biometricLockSubtitle =>
      'FaceID അല്ലെങ്കിൽ വിരലടയാളം ഉപയോഗിച്ച് അൺലോക്ക് ചെയ്യുക';

  @override
  String get aboutSection => 'വിവരങ്ങൾ';

  @override
  String get aboutDescription =>
      'കുബേറിനെ കുറിച്ചും അതിന് പിന്നിലെ വ്യക്തിയെ കുറിച്ചും അറിയുക.';

  @override
  String get aboutKuberLabel => 'കുബേറിനെ കുറിച്ച്';

  @override
  String get aboutKuberSubtitle => 'കാഴ്ചപ്പാട്, ഉത്ഭവം, ഡെവലപ്പറുടെ കത്ത്';

  @override
  String get clearDefault => 'ഡിഫോൾട്ട് ഒഴിവാക്കുക';

  @override
  String get defaultAccountCleared => 'ഡിഫോൾട്ട് അക്കൗണ്ട് ഒഴിവാക്കി';

  @override
  String get noAccountsFound => 'അക്കൗണ്ടുകളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get biometricNotAvailable =>
      'ഉപകരണ പ്രാമാണീകരണം ലഭ്യവുമല്ല അല്ലെങ്കിൽ സജ്ജീകരിച്ചിട്ടുമില്ല';

  @override
  String get biometricEnabledMsg => 'ബയോമെട്രിക് ലോക്ക് സജീവമാക്കി';

  @override
  String get biometricDisabledMsg => 'ബയോമെട്രിക് ലോക്ക് നിർജ്ജീവമാക്കി';

  @override
  String get updateNameTitle => 'പേര് മാറ്റുക';

  @override
  String get enterNameHint => 'പേര് നൽകുക';

  @override
  String get saveBtn => 'സൂക്ഷിക്കുക';

  @override
  String get themeLightChoice => 'ലൈറ്റ്';

  @override
  String get themeDarkChoice => 'ഡാർക്ക്';

  @override
  String get themeSystemChoice => 'സിസ്റ്റം';

  @override
  String get themeSubtitleLight =>
      'വെളിച്ചമുള്ള പശ്ചാത്തലം, കടും നിറത്തിലുള്ള ടെക്സ്റ്റ്';

  @override
  String get themeSubtitleDark => 'കറുത്ത പശ്ചാത്തലം, വെളിച്ചമുള്ള ടെക്സ്റ്റ്';

  @override
  String get themeSubtitleSystem => 'നിങ്ങളുടെ ഫോണിന്റെ ക്രമീകരണം പിന്തുടരുക';

  @override
  String get navClassicChoice => 'ക്ലാസിക്';

  @override
  String get navModernChoice => 'മോഡേൺ';

  @override
  String get navSubtitleClassic => 'സാധാരണ ബാർ';

  @override
  String get navSubtitleModern => 'ഫ്ലോട്ടിംഗ് പിൽ';

  @override
  String get navFuturisticChoice => 'ഫ്യൂച്ചറിസ്റ്റിക്';

  @override
  String get navSubtitleFuturistic => 'സജീവമായതിൽ ലേബൽ';

  @override
  String get numFormatIndian => 'ഇന്ത്യൻ';

  @override
  String get numFormatInternational => 'ഇന്റർനാഷണൽ';

  @override
  String get swipeChangeTabs => 'ടാബുകൾ മാറ്റുക';

  @override
  String get swipeRowActions => 'വരിയിലെ പ്രവർത്തനങ്ങൾ';

  @override
  String get swipeSubtitleChangeTabs =>
      'സ്ക്രീനിലുടനീളം സ്വൈപ്പ് ചെയ്തുകൊണ്ട് പ്രധാന ആപ്പ് സെക്ഷനുകൾക്കിടയിൽ വേഗത്തിൽ മാറുക';

  @override
  String get swipeSubtitleRowActions =>
      'ഓരോ ഹിസ്റ്ററി ഐറ്റങ്ങളിലും സ്വൈപ്പ് ചെയ്തുകൊണ്ട് തിരുത്തുകയോ ഇല്ലാതാക്കുകയോ പോലുള്ള പ്രവർത്തനങ്ങൾ പെട്ടെന്ന് ചെയ്യുക';

  @override
  String spentTodayInsight(String amount, String diff, String avg) {
    return 'നിങ്ങൾ ഇന്ന് $amount ചിലവഴിച്ചു, ഇത് നിങ്ങളുടെ 30 ദിവസത്തെ ശരാശരിയായ $avg-നേക്കാൾ $diff കൂടുതലാണ്';
  }

  @override
  String weekdayPatternInsight(String highest, String dayName, String median) {
    return 'മറ്റു ദിവസങ്ങളിലെ $median-നെ അപേക്ഷിച്ച് $dayName ദിവസങ്ങളിൽ നിങ്ങൾ സാധാരണയായി $highest ചിലവഴിക്കുന്നു';
  }

  @override
  String topCategoryInsight(String pct, String catName, String amount) {
    return 'ചിലവിന്റെ $pct% $catName-ലേക്കാണ് പോകുന്നത് ($amount)';
  }

  @override
  String categoryTrendInsight(String catName, String change) {
    return '$catName ചിലവ് കഴിഞ്ഞ മാസത്തെ അപേക്ഷിച്ച് $change ആണ്';
  }

  @override
  String monthComparisonInsight(String change) {
    return 'കഴിഞ്ഞ മാസം ഈ സമയം വരെയുള്ള ചിലവുമായി താരതമ്യം ചെയ്യുമ്പോൾ ഇപ്പോൾ ചിലവ് $change ആണ്';
  }

  @override
  String weekendVsWeekdayInsight(String weekend, String weekday) {
    return 'പ്രവൃത്തിദിനങ്ങളിലെ ശരാശരി $weekday-മായി താരതമ്യം ചെയ്യുമ്പോൾ വാരാന്ത്യ ഇടപാടുകളുടെ ശരാശരി $weekend ആണ്';
  }

  @override
  String biggestExpenseInsight(String name, String amount, String ratio) {
    return '$name ($amount) നിങ്ങളുടെ സാധാരണ ചിലവിന്റെ $ratio മടങ്ങായിരുന്നു';
  }

  @override
  String get savingsTrendPositive =>
      'ഈ മാസം നിങ്ങൾ പണം ലാഭിക്കുന്നുണ്ട്. ഇത് തുടരുക!';

  @override
  String savingsTrendInsight(String change) {
    return 'കഴിഞ്ഞ മാസത്തെ അപേക്ഷിച്ച് സമ്പാദ്യം $change ആണ്';
  }

  @override
  String savingsTrendDipInsight(String change) {
    return 'കഴിഞ്ഞ മാസത്തെ അപേക്ഷിച്ച് സമ്പാദ്യത്തിൽ $change കുറവുണ്ടായി';
  }

  @override
  String recurringBurdenInsight(String pct) {
    return 'ചിലവിന്റെ $pct ആവർത്തിച്ചുള്ള ഇടപാടുകളിൽ നിന്നാണ്';
  }

  @override
  String streakInsight(String streak) {
    return 'ഇന്നത്തെ ദിവസത്തിന് മുൻപ് ചിലവുകളില്ലാത്ത $streak ദിവസങ്ങൾ!';
  }

  @override
  String spendingFasterInsight(String weekStr, String diffStr, String baseStr) {
    return 'നിങ്ങൾ ഈ ആഴ്ച ദിവസം $weekStr ചിലവഴിക്കുന്നു, ഇത് നിങ്ങളുടെ സാധാരണ ചിലവായ $baseStr/ദിവസത്തെ അപേക്ഷിച്ച് $diffStr വേഗത്തിലാണ്';
  }

  @override
  String categoryConcentrationInsight(String pctStr, String amtStr) {
    return 'നിങ്ങളുടെ ചിലവിന്റെ $pctStr ($amtStr) വെറും 3 വിഭാഗങ്ങളിലേക്കാണ് പോകുന്നത്';
  }

  @override
  String loanEmiTotalInsight(String amount) {
    return 'ഈ മാസത്തെ ലോൺ ഇഎംഐകൾ ആകെ $amount വരുന്നു';
  }

  @override
  String loanPayoffCountdownInsight(
    String name,
    String months,
    String pluralSuffix,
  ) {
    return '$name പൂർണ്ണമായും അടച്ചുതീർക്കാൻ ഏകദേശം $months മാസം$pluralSuffix കൂടിയുണ്ട്';
  }

  @override
  String loanInterestPaidInsight(String amount) {
    return 'ഇതുവരെ അടച്ച ആകെ ലോൺ പലിശ $amount ആണ്';
  }

  @override
  String ledgerOutstandingInsight(String receive, String owe) {
    return 'നിങ്ങൾക്ക് ലഭിക്കാനുള്ളത് ആകെ $receive ഉം നിങ്ങൾ നൽകാനുള്ളത് $owe ഉം ആണ്';
  }

  @override
  String ledgerOldestOpenInsight(String personName, String ageDays) {
    return '$personName-ന്റെ പേരിൽ $ageDays ദിവസമായി തീർപ്പാക്കാത്ത ഏറ്റവും പഴയ എൻട്രിയുണ്ട്';
  }

  @override
  String investmentPortfolioChangeInsight(String amount) {
    return 'നിങ്ങൾ നിക്ഷേപിച്ച മൂല്യവുമായി താരതമ്യം ചെയ്യുമ്പോൾ നിങ്ങളുടെ പോർട്ട്‌ഫോളിയോ $amount ആണ്';
  }

  @override
  String investmentTopPerformerInsight(String name, String pct) {
    return '$pct നേട്ടത്തോടെ $name ആണ് നിങ്ങളുടെ മികച്ച പ്രകടനം കാഴ്ചവെക്കുന്നത്';
  }

  @override
  String investmentPeriodInvestedInsight(String amount) {
    return 'ഈ മാസം നിങ്ങൾ $amount നിക്ഷേപിച്ചു';
  }

  @override
  String get fallbackTipInsight =>
      'സ്മാർട്ട് സ്ഥിതിവിവരക്കണക്കുകൾ ലഭിക്കാൻ ഇടപാടുകൾ ചേർക്കാൻ ആരംഭിക്കുക';

  @override
  String fallbackTotalInsight(String amount) {
    return 'കഴിഞ്ഞ 30 ദിവസത്തിനുള്ളിൽ നിങ്ങൾ $amount ചിലവഴിച്ചു';
  }

  @override
  String get spentLastWeek => 'കഴിഞ്ഞ ആഴ്ച ചിലവഴിച്ചത്';

  @override
  String spentLastMonth(String month) {
    return '$month-ൽ ചിലവഴിച്ചത്';
  }

  @override
  String spentLastYear(String year) {
    return '$year-ൽ ചിലവഴിച്ചത്';
  }

  @override
  String averageDay(String amount) {
    return 'ശരാശരി ഒരു ദിവസം ഏകദേശം $amount';
  }

  @override
  String biggestDay(String day, String amount) {
    return 'ഏറ്റവും കൂടുതൽ ചിലവഴിച്ച ദിവസം $day ആണ് ($amount)';
  }

  @override
  String savedEarned(String pct) {
    return 'നിങ്ങൾ സമ്പാദിച്ചതിന്റെ $pct% ലാഭിച്ചു';
  }

  @override
  String biggestSingleSpend(String name, String category) {
    return 'ഏറ്റവും വലിയ ഒറ്റ ചിലവ് $category-ൽ $name ആയിരുന്നു';
  }

  @override
  String get spentLess => 'നിങ്ങൾ മുൻപത്തേതിനേക്കാൾ കുറവ് ചിലവഴിച്ചു';

  @override
  String get spentMore => 'നിങ്ങൾ മുൻപത്തേതിനേക്കാൾ കൂടുതൽ ചിലവഴിച്ചു';

  @override
  String get comparedTitle => 'താരതമ്യം ചെയ്യുമ്പോൾ';

  @override
  String get comparedLess => 'നിങ്ങൾ മുൻപത്തേതിനേക്കാൾ കുറവ് ചിലവഴിച്ചു';

  @override
  String get comparedMore => 'നിങ്ങൾ മുൻപത്തേതിനേക്കാൾ കൂടുതൽ ചിലവഴിച്ചു';

  @override
  String deltaLess(String amount, String label) {
    return '$label-നേക്കാൾ $amount കുറവ്';
  }

  @override
  String deltaMore(String amount, String label) {
    return '$label-നേക്കാൾ $amount കൂടുതൽ';
  }

  @override
  String get monthlyEmi => 'പ്രതിമാസ EMI';

  @override
  String get principal => 'പ്രധാന തുക';

  @override
  String get lender => 'വായ്പ നൽകിയയാൾ';

  @override
  String ledgerOwesYou(String person, String amount) {
    return '$person നിങ്ങൾക്ക് $amount തരാനുണ്ട്';
  }

  @override
  String ledgerYouOwe(String person, String amount) {
    return 'നിങ്ങൾ $person-ന് $amount കൊടുക്കാനുണ്ട്';
  }

  @override
  String get ledgerEntryOpen => 'ഈ എൻട്രി ഇപ്പോഴും തീർപ്പാക്കിയിട്ടില്ല.';

  @override
  String get portfolioCheck => 'പോർട്ട്‌ഫോളിയോ പരിശോധന';

  @override
  String get investedLabel => 'നിക്ഷേപിച്ചത്';

  @override
  String get currentValueLabel => 'നിലവിലെ മൂല്യം';

  @override
  String get welcomeTitle => 'കുബേറിലേക്ക് സ്വാഗതം';

  @override
  String get welcomeSubtitle =>
      'ഇൻസ്റ്റാൾ ചെയ്തതിന് നന്ദി. നിങ്ങളുടെ പണം മനോഹരമായി ട്രാക്ക് ചെയ്യാം.';

  @override
  String get basicsTitle => 'ഓരോ രൂപയും ട്രാക്ക് ചെയ്യുക';

  @override
  String get basicsSubtitle =>
      'ചിലവുകൾ, വരുമാനം, ട്രാൻസ്ഫറുകൾ, ബജറ്റുകൾ എന്നിവയെല്ലാം ഒരിടത്ത്.';

  @override
  String get beyondBasicsTitle => 'കൂടുതൽ കാര്യങ്ങൾ ഇവിടെയുണ്ട്';

  @override
  String get beyondBasicsSubtitle =>
      'വായ്പ നൽകലും വാങ്ങലും, ഇഎംഐകൾ, നിക്ഷേപങ്ങൾ, ഉപകാരപ്രദമായ കാൽക്കുലേറ്ററുകൾ.';

  @override
  String get spaceIsYoursTitle => 'നിങ്ങളുടെ പണത്തിന്റെ കഥകൾ';

  @override
  String get spaceIsYoursSubtitle =>
      'നിങ്ങളുടെ ചിലവുകളെക്കുറിച്ചുള്ള വിവരങ്ങളും പ്രധാന ഹൈലൈറ്റുകളും ഇവിടെ ദൃശ്യമാകും.';

  @override
  String get spentYesterday => 'ഇന്നലെ ചിലവഴിച്ചത്';

  @override
  String topSpend(String name, String category) {
    return 'കൂടിയ ചിലവ്: $category-ൽ $name';
  }

  @override
  String get topCategories => 'പ്രധാന വിഭാഗങ്ങൾ';

  @override
  String get noSpendDay => 'ചിലവുകളൊന്നുമില്ലാത്ത ദിവസം. കൊള്ളാം.';

  @override
  String noSpendStreak(String streak) {
    return 'അത് ചിലവുകളൊന്നുമില്ലാത്ത തുടർച്ചയായ $streak ദിവസങ്ങളാണ്';
  }

  @override
  String noSpendStreakEnded(String streak) {
    return 'ചിലവുകളൊന്നുമില്ലാത്ത തുടർച്ചയായ $streak ദിവസങ്ങൾ അവസാനിച്ചു';
  }

  @override
  String get dailyRecapHeader => 'ദിനംപ്രതി';

  @override
  String get weeklyRecapHeader => 'വാരഫലം';

  @override
  String get monthlyRecapHeader => 'പ്രതിമാസ വിവരങ്ങൾ';

  @override
  String get yearlyRecapHeader => 'വർഷാവലോകനം';

  @override
  String get highlightHeader => 'ഹൈലൈറ്റ്';

  @override
  String get loansHeader => 'വായ്പകൾ';

  @override
  String get ledgerHeader => 'വായ്പ നൽകൽ / വാങ്ങൽ';

  @override
  String get investmentsHeader => 'നിക്ഷേപങ്ങൾ';

  @override
  String averageMonth(String amount) {
    return 'ശരാശരി ഒരു മാസം ഏകദേശം $amount';
  }

  @override
  String biggestMonth(String month, String amount) {
    return 'ഏറ്റവും കൂടുതൽ ചിലവഴിച്ച മാസം $month ആണ് ($amount)';
  }

  @override
  String get lessLabel => 'കുറവ്';

  @override
  String get moreLabel => 'കൂടുതൽ';

  @override
  String get theWeekBefore => 'തൊട്ടുമുമ്പത്തെ ആഴ്ച';

  @override
  String aboveAverage(String amount) {
    return 'നിങ്ങളുടെ 30 ദിവസത്തെ ശരാശരിയേക്കാൾ $amount കൂടുതൽ';
  }

  @override
  String belowAverage(String amount) {
    return 'നിങ്ങളുടെ 30 ദിവസത്തെ ശരാശരിയേക്കാൾ $amount കുറവ്';
  }

  @override
  String get toLabel => 'ലേക്ക്';

  @override
  String throughPeriod(String date) {
    return '$date വരെ';
  }

  @override
  String get thisWeek => 'ഈ ആഴ്ച';

  @override
  String get previousWeek => 'കഴിഞ്ഞ ആഴ്ച';

  @override
  String get thisMonth => 'ഈ മാസം';

  @override
  String get previousMonth => 'കഴിഞ്ഞ മാസം';

  @override
  String get thisYear => 'ഈ വർഷം';

  @override
  String get previousYear => 'കഴിഞ്ഞ വർഷം';

  @override
  String get uncategorized => 'വിഭാഗത്തിൽ പെടുത്താത്തത്';

  @override
  String get chooseAppLanguage => 'ആപ്പ് ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get selectLanguage => 'ഭാഷ തിരഞ്ഞെടുക്കുക';

  @override
  String get searchLanguage => 'ഭാഷ തിരയുക';

  @override
  String get noLanguagesFound => 'ഭാഷകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get appearanceCategory => 'രൂപഭാവം';

  @override
  String get moneyDisplayCategory => 'പണത്തിന്റെ ഡിസ്‌പ്ലേ';

  @override
  String get transactionsCategory => 'ഇടപാടുകൾ';

  @override
  String get notSet => 'ക്രമീകരിച്ചിട്ടില്ല';

  @override
  String get setYourName => 'നിങ്ങളുടെ പേര് നൽകുക';

  @override
  String get simpleLabel => 'ലളിതം';

  @override
  String get creditCardLabel => 'ക്രെഡിറ്റ് കാർഡ്';

  @override
  String get bankCashLabel => 'ബാങ്ക് / ക്യാഷ്';

  @override
  String setAsDefault(String name) {
    return '$name ഡിഫോൾട്ട് ആയി ക്രമീകരിച്ചു';
  }

  @override
  String get nameSheetHint => 'ഉദാ. Gautam';

  @override
  String get doneLabel => 'കഴിഞ്ഞു';

  @override
  String get moreTabSimpleSubtitle =>
      'കാർഡുകളുടെ സമാനമായ ലിസ്റ്റ്. പരിചിതവും എളുപ്പമുള്ളതുമാണ്.';

  @override
  String get moreTabModernSubtitle =>
      'ഹീറോ ഇനങ്ങൾ, ടൈൽ ഗ്രിഡ്, ചെറിയ ലിസ്റ്റുകൾ. ഓരോ സെക്ഷൻ അനുസരിച്ച് തിരിച്ചിരിക്കുന്നു.';

  @override
  String get selectCurrency => 'കറൻസി തിരഞ്ഞെടുക്കുക';

  @override
  String get searchCurrencyHint =>
      'പേര്, കോഡ് അല്ലെങ്കിൽ ചിഹ്നം ഉപയോഗിച്ച് തിരയുക…';

  @override
  String get noCurrenciesFound => 'കറൻസികളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get welcomeHeader => 'സ്വാഗതം';

  @override
  String get basicsHeader => 'അടിസ്ഥാന കാര്യങ്ങൾ';

  @override
  String get beyondBasicsHeader => 'അടിസ്ഥാന കാര്യങ്ങൾക്ക് അപ്പുറം';

  @override
  String get spaceIsYoursHeader => 'ഈ സ്ഥലം നിങ്ങളുടേതാണ്';

  @override
  String get homeSubtitle1 => 'നമുക്ക് പണം ബുദ്ധിപൂർവ്വം കൈകാര്യം ചെയ്യാം';

  @override
  String get homeSubtitle2 => 'എല്ലാ ദിവസവും ഓരോ രൂപയും ട്രാക്ക് ചെയ്യുക';

  @override
  String get homeSubtitle3 =>
      'നിങ്ങളുടെ സാമ്പത്തിക സ്ഥിതി മികച്ചതായി സൂക്ഷിക്കുക';

  @override
  String get homeSubtitle4 => 'നിങ്ങളുടെ വാലറ്റ് പിന്നീട് നന്ദി പറയും';

  @override
  String get homeSubtitle5 => 'ചെറിയ സമ്പാദ്യം, വലിയ ഫലം';

  @override
  String get homeSubtitle6 => 'ഓരോ ഇടപാടും പ്രധാനപ്പെട്ടതാണ്';

  @override
  String get homeSubtitle7 => 'മികച്ച സാമ്പത്തിക ശീലങ്ങൾ വളർത്തിയെടുക്കുക';

  @override
  String get greetingMorning => 'സുപ്രഭാതം';

  @override
  String get greetingAfternoon => 'മദ്ധ്യാഹ്ന വന്ദനം';

  @override
  String get greetingEvening => 'ശുഭസായാഹ്നം';

  @override
  String get errorLabel => 'പിശക്';

  @override
  String get last7Days => 'കഴിഞ്ഞ 7 ദിവസങ്ങൾ';

  @override
  String get netLabel => 'ആകെ';

  @override
  String get spendingAnalysisEmpty =>
      'കഴിഞ്ഞ 7 ദിവസങ്ങളിൽ വരുമാനമോ ചിലവോ ഉള്ള ഇടപാടുകളൊന്നുമില്ല. നിങ്ങളുടെ ചിലവുകളുടെ വിശകലനം ഇവിടെ കാണാൻ ഒരു ഇടപാട് ചേർക്കുക.\n\nശ്രദ്ധിക്കുക: ട്രാൻസ്ഫറുകൾ ഇതിൽ ഉൾപ്പെടുന്നില്ല.';

  @override
  String get notificationsTooltip => 'അറിയിപ്പുകൾ';

  @override
  String get askKuber => 'കുബേറിനോട് ചോദിക്കുക';

  @override
  String get privacyModeOn => 'സ്വകാര്യതാ മോഡ്: ഓൺ';

  @override
  String get privacyModeOff => 'സ്വകാര്യതാ മോഡ്: ഓഫ്';

  @override
  String get accountsLabel => 'അക്കൗണ്ടുകൾ';

  @override
  String get viewAll => 'എല്ലാം കാണുക';

  @override
  String get outstandingLabel => 'ബാക്കിയുള്ളത്';

  @override
  String get availableLabel => 'ലഭ്യമായത്';

  @override
  String get bankLabel => 'ബാങ്ക്';

  @override
  String get walletLabel => 'വാലറ്റ്';

  @override
  String get cashLabel => 'ക്യാഷ്';

  @override
  String get usedLabel => 'ഉപയോഗിച്ചത്';

  @override
  String get limitLabel => 'പരിധി';

  @override
  String get recurringHeader => 'ആവർത്തിക്കുന്നത്';

  @override
  String get statusProcessed => 'പ്രോസസ്സ് ചെയ്തത്';

  @override
  String get statusPending => 'പെൻഡിംഗ്';

  @override
  String get statusScheduled => 'ഷെഡ്യൂൾ ചെയ്തത്';

  @override
  String get quickAddInvalidAmount =>
      'സാധുവായ ഒരു തുക നൽകുക (ഉദാ. \"200 on coffee\")';

  @override
  String quickAddNoAccountNamed(String name) {
    return '\"$name\" എന്ന പേരിൽ അക്കൗണ്ട് ഒന്നും കണ്ടെത്തിയില്ല';
  }

  @override
  String get quickAddCouldNotResolveCategory => 'വിഭാഗം കണ്ടെത്താൻ കഴിഞ്ഞില്ല';

  @override
  String quickAddAdded(String amount, String category) {
    return '$amount $category-ലേക്ക് ചേർത്തു';
  }

  @override
  String get noAccountFoundTitle => 'അക്കൗണ്ട് ഒന്നും കണ്ടെത്തിയില്ല';

  @override
  String noAccountMatchedBody(String hint) {
    return '\"$hint\"-ലേക്ക് പൊരുത്തപ്പെടുന്ന അക്കൗണ്ടുകളൊന്നും കണ്ടെത്തിയില്ല, ഡിഫോൾട്ട് അക്കൗണ്ടും സജ്ജീകരിച്ചിട്ടില്ല. Quick Add ഉപയോഗിക്കാൻ ക്രമീകരണങ്ങളിൽ ഒരു ഡിഫോൾട്ട് അക്കൗണ്ട് സജ്ജീകരിക്കുക.';
  }

  @override
  String get noDefaultAccountBody =>
      'ഡിഫോൾട്ട് അക്കൗണ്ട് സജ്ജീകരിച്ചിട്ടില്ല. Quick Add ഉപയോഗിക്കാൻ ക്രമീകരണങ്ങളിൽ ഒന്ന് സജ്ജീകരിക്കുക.';

  @override
  String get openSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get quickAddTitle => 'ക്വിക്ക് ആഡ് (ബീറ്റ)';

  @override
  String get quickAddInfoTitle => 'ക്വിക്ക് ആഡ്';

  @override
  String get quickAddInfoDesc =>
      'സാധാരണ ഭാഷ ഉപയോഗിച്ച് ഒരു ചിലവ് തൽക്ഷണം രേഖപ്പെടുത്തുക. ഫോമുകളോ ടാപ്പിംഗോ ഇല്ല. നിങ്ങൾ ചിലവഴിച്ച തുക ടൈപ്പ് ചെയ്താൽ മാത്രം മതി, ബാക്കി കുബേർ കണ്ടെത്തും.';

  @override
  String get quickAddBasicAmount => 'അടിസ്ഥാന തുക';

  @override
  String get quickAddBasicAmountDesc =>
      '\"250\" അല്ലെങ്കിൽ \"₹250\" എന്നത് General വിഭാഗത്തിലേക്ക് ₹250 ചേർക്കുന്നു.';

  @override
  String get quickAddWithCategory => 'വിഭാഗത്തോടൊപ്പം';

  @override
  String get quickAddWithCategoryDesc =>
      '\"250 on food\", \"150 in gaming\", \"300 for rent\" എന്നത് നിലവിലുള്ള ഒരു വിഭാഗത്തിലേക്ക് ബന്ധിപ്പിക്കുകയോ പുതിയൊരെണ്ണം സൃഷ്ടിക്കുകയോ ചെയ്യുന്നു.';

  @override
  String get quickAddWithAccount => 'അക്കൗണ്ടിനൊപ്പം';

  @override
  String get quickAddWithAccountDesc =>
      '\"150 for uber from hdfc\" എന്നത് നിങ്ങളുടെ HDFC അക്കൗണ്ടുമായി പേര് പൊരുത്തപ്പെടുത്തുന്നു.';

  @override
  String get quickAddActionWords => 'പ്രവർത്തന വാക്കുകൾ';

  @override
  String get quickAddActionWordsDesc =>
      '\"Add 200 on coffee\", \"Log 500 for groceries\", \"Create 1000 in savings\" - ആദ്യത്തെ പ്രവർത്തന വാക്കുകൾ സ്വയമേവ നീക്കം ചെയ്യപ്പെടും.';

  @override
  String get quickAddDefaultAccountInfo => 'ഡിഫോൾട്ട് അക്കൗണ്ട്';

  @override
  String get quickAddDefaultAccountInfoDesc =>
      'ഓരോ തവണയും \"from ...\" എന്ന് ടൈപ്പ് ചെയ്യുന്നത് ഒഴിവാക്കാൻ ക്രമീകരണങ്ങളിൽ ഒരു ഡിഫോൾട്ട് അക്കൗണ്ട് സജ്ജീകരിക്കുക.';

  @override
  String get quickAddHint => 'ഉദാ. \"250 on groceries from HDFC\"';

  @override
  String get spendingPattern => 'ചിലവ് രീതി';

  @override
  String get avgDaily => 'പ്രതിദിന ശരാശരി';

  @override
  String get last90Days => 'കഴിഞ്ഞ 90 ദിവസങ്ങൾ';

  @override
  String get statThisMonth => 'ഈ മാസം';

  @override
  String statDays(String days) {
    return '$days ദിവസങ്ങൾ';
  }

  @override
  String get projectedLabel => 'പ്രതീക്ഷിക്കുന്നത്';

  @override
  String get endOfMonth => 'മാസാവസാനം';

  @override
  String get budgetSnapshot => 'ബജറ്റ് വിവരങ്ങൾ';

  @override
  String get budgetExceeded => 'പരിധി കഴിഞ്ഞു';

  @override
  String get budgetHighUsage => 'ഉയർന്ന ഉപയോഗം';

  @override
  String get budgetNearLimit => 'പരിധിയോട് അടുത്തു';

  @override
  String get budgetOnTrack => 'ശരിയായ ദിശയിൽ';

  @override
  String get categoryLabel => 'വിഭാഗം';

  @override
  String budgetRemaining(String amount) {
    return '$amount ബാക്കിയുണ്ട്';
  }

  @override
  String get recentTransactions => 'സമീപകാല ഇടപാടുകൾ';

  @override
  String get noTransactionsYet => 'ഇടപാടുകളൊന്നുമില്ല';

  @override
  String get smartInsights => 'സ്മാർട്ട് സ്ഥിതിവിവരക്കണക്കുകൾ';

  @override
  String get smartInsightsEmpty =>
      'നിങ്ങളുടെ സാമ്പത്തിക സ്ഥിതിയെക്കുറിച്ചുള്ള സ്ഥിതിവിവരക്കണക്കുകൾ കാണാൻ ഇടപാടുകൾ ചേർക്കുന്നത് തുടരുക.';

  @override
  String get insightLabelWeekdayPattern => 'പ്രവൃത്തിദിനങ്ങളിലെ രീതി';

  @override
  String get insightLabelTopCategory => 'പ്രധാന വിഭാഗം';

  @override
  String get insightLabelCategoryTrend => 'വിഭാഗത്തിന്റെ ട്രെൻഡ്';

  @override
  String get insightLabelMonthTrend => 'പ്രതിമാസ ട്രെൻഡ്';

  @override
  String get insightLabelWeekendPattern => 'വാരാന്ത്യങ്ങളിലെ രീതി';

  @override
  String get insightLabelBigExpense => 'വലിയ ചിലവ്';

  @override
  String get insightLabelSavings => 'സമ്പാദ്യം';

  @override
  String get insightLabelRecurring => 'ആവർത്തിക്കുന്നത്';

  @override
  String get insightLabelStreak => 'തുടർച്ചയായ ദിവസങ്ങൾ';

  @override
  String get insightLabelToday => 'ഇന്ന്';

  @override
  String get insightLabelThisWeek => 'ഈ ആഴ്ച';

  @override
  String get insightLabelDidYouKnow => 'നിങ്ങൾക്ക് അറിയാമോ';

  @override
  String get insightLabelLoans => 'വായ്പകൾ';

  @override
  String get insightLabelLoanInterest => 'ലോൺ പലിശ';

  @override
  String get insightLabelLendBorrow => 'വായ്പ നൽകൽ / വാങ്ങൽ';

  @override
  String get insightLabelInvestments => 'നിക്ഷേപങ്ങൾ';

  @override
  String get insightLabelTopInvestment => 'മികച്ച നിക്ഷേപം';

  @override
  String get insightLabelSummary => 'ചുരുക്കം';

  @override
  String get insightLabelTip => 'തിപ്പ്';

  @override
  String get weekdayMonday => 'തിങ്കളാഴ്ച';

  @override
  String get weekdayTuesday => 'ചൊവ്വാഴ്ച';

  @override
  String get weekdayWednesday => 'ബുധനാഴ്ച';

  @override
  String get weekdayThursday => 'വ്യാഴാഴ്ച';

  @override
  String get weekdayFriday => 'വെള്ളിയാഴ്ച';

  @override
  String get weekdaySaturday => 'ശനിയാഴ്ച';

  @override
  String get weekdaySunday => 'ഞായറാഴ്ച';

  @override
  String get historyTitle => 'ഇടപാട്\nചരിത്രം';

  @override
  String get historyDescription =>
      'നിങ്ങളുടെ മുൻകാല ചിലവുകൾ, വരുമാനങ്ങൾ, ട്രാൻസ്ഫറുകൾ';

  @override
  String get exportLabel => 'എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get expLabel => 'ചിലവ്';

  @override
  String get incLabel => 'വരുമാനം';

  @override
  String get showingLabel => 'കാണിക്കുന്നത്';

  @override
  String get transactionsLabel => 'ഇടപാടുകൾ';

  @override
  String get noTransactionsFound => 'ഇടപാടുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get startTrackingExpenses =>
      'നിങ്ങളുടെ ചിലവുകൾ ട്രാക്ക് ചെയ്യാൻ ആരംഭിക്കുക';

  @override
  String get adjustSearchFilters =>
      'നിങ്ങളുടെ തിരച്ചിലോ ഫിൽട്ടറുകളോ ക്രമീകരിക്കാൻ ശ്രമിക്കുക';

  @override
  String get addTransaction => 'ഇടപാട് ചേർക്കുക';

  @override
  String selectedCount(String count) {
    return '$count എണ്ണം തിരഞ്ഞെടുത്തു';
  }

  @override
  String deleteTransactionsConfirm(String count) {
    return '$count ഇടപാടുകൾ ഇല്ലാതാക്കണോ?';
  }

  @override
  String get actionCannotBeUndone => 'ഈ പ്രവർത്തനം പഴയപടിയാക്കാൻ കഴിയില്ല.';

  @override
  String transactionsDeleted(String count) {
    return '$count ഇടപാടുകൾ ഇല്ലാതാക്കി';
  }

  @override
  String tagsMoreCount(String count) {
    return '+$count കൂടുതൽ';
  }

  @override
  String get accountCorrectionSubtitle =>
      'അക്കൗണ്ട് തിരുത്തൽ · അനലിറ്റിക്സിൽ നിന്ന് ഒഴിവാക്കി';

  @override
  String get unknownLabel => 'അജ്ഞാതം';

  @override
  String get transferLabel => 'ട്രാൻസ്ഫർ';

  @override
  String get adjustmentLabel => 'ക്രമീകരണം';

  @override
  String get editTransfer => 'ട്രാൻസ്ഫർ തിരുത്തുക';

  @override
  String get editTransaction => 'ഇടപാട് തിരുത്തുക';

  @override
  String get saveAndAddAnother => 'സൂക്ഷിക്കുക & മറ്റൊന്ന് ചേർക്കുക';

  @override
  String get fromAccount => 'ഏത് അക്കൗണ്ടിൽ നിന്ന്';

  @override
  String get toAccount => 'ഏത് അക്കൗണ്ടിലേക്ക്';

  @override
  String get transactionNameHint => 'ഇടപാടിന്റെ പേര്';

  @override
  String get categoryUpper => 'വിഭാഗം';

  @override
  String get selectLabel => 'തിരഞ്ഞെടുക്കുക';

  @override
  String get updateExpense => 'ചിലവ് അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get updateIncome => 'വരുമാനം അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get updateTransferBtn => 'ട്രാൻസ്ഫർ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get saveExpense => 'ചിലവ് സൂക്ഷിക്കുക';

  @override
  String get saveIncome => 'വരുമാനം സൂക്ഷിക്കുക';

  @override
  String get saveTransferBtn => 'ട്രാൻസ്ഫർ സൂക്ഷിക്കുക';

  @override
  String get enterTransactionName => 'ദയവായി ഇടപാടിന്റെ പേര് നൽകുക';

  @override
  String get enterValidAmount => 'ദയവായി സാധുവായ ഒരു തുക നൽകുക';

  @override
  String get selectCategoryError => 'ദയവായി ഒരു വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get selectAccountError => 'ദയവായി ഒരു അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get selectSourceAccount => 'ദയവായി സ്രോതസ്സ് അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get selectDestinationAccount =>
      'ദയവായി ലക്ഷ്യസ്ഥാന അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get accountsMustDiffer =>
      'സ്രോതസ്സ്, ലക്ഷ്യസ്ഥാന അക്കൗണ്ടുകൾ വ്യത്യസ്തമായിരിക്കണം';

  @override
  String failedToSave(String error) {
    return 'സൂക്ഷിക്കാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get addAnotherPrompt => 'ഇടപാട് സൂക്ഷിച്ചു! മറ്റൊന്ന് ചേർക്കണോ?';

  @override
  String get transactionUpdated => 'ഇടപാട് അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get transactionSaved => 'ഇടപാട് സൂക്ഷിച്ചു';

  @override
  String get transferUpdated => 'ട്രാൻസ്ഫർ അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get transferSaved => 'ട്രാൻസ്ഫർ സൂക്ഷിച്ചു';

  @override
  String get creditCardPayment => 'ക്രെഡിറ്റ് കാർഡ് പേയ്‌മെന്റ്';

  @override
  String get creditCardWithdrawal => 'ക്രെഡിറ്റ് കാർഡ് പിൻവലിക്കൽ';

  @override
  String get creditCardTransfer => 'ക്രെഡിറ്റ് കാർഡ് ട്രാൻസ്ഫർ';

  @override
  String get selectCategoryTitle => 'വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get searchCategories => 'വിഭാഗങ്ങൾ തിരയുക';

  @override
  String get noCategoriesFound => 'വിഭാഗങ്ങളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get ungrouped => 'ഗ്രൂപ്പ് ചെയ്യാത്തവ';

  @override
  String get addNewCategory => 'പുതിയ വിഭാഗം ചേർക്കുക';

  @override
  String get budgetExists => 'ബജറ്റ് നിലവിലുണ്ട്';

  @override
  String get selectAccountTitle => 'അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseAccountSubtitle =>
      'ഈ ഇടപാടിനായുള്ള അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get noAccountsYet => 'അക്കൗണ്ടുകളൊന്നുമില്ല';

  @override
  String get addNewAccount => 'പുതിയ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get addNoteHint => 'ഒരു കുറിപ്പ് ചേർക്കുക (ഓപ്ഷണൽ)';

  @override
  String get tagsUpper => 'ടാഗുകൾ';

  @override
  String get noTagsSelected => 'ടാഗുകളൊന്നും തിരഞ്ഞെടുത്തിട്ടില്ല';

  @override
  String tagsSelectedCount(String count) {
    return '$count ടാഗുകൾ തിരഞ്ഞെടുത്തു';
  }

  @override
  String get dateTimeLabel => 'തീയതിയും സമയവും';

  @override
  String get todayLabel => 'ഇന്ന്';

  @override
  String get yesterdayLabel => 'ഇന്നലെ';

  @override
  String get expenseLabel => 'ചിലവ്';

  @override
  String get incomeLabel => 'വരുമാനം';

  @override
  String get budgetLabel => 'ബജറ്റ്';

  @override
  String get attachmentsLabel => 'അറ്റാച്ച്‌മെന്റുകൾ';

  @override
  String get addImageOrPdf => 'ചിത്രം അല്ലെങ്കിൽ PDF ചേർക്കുക';

  @override
  String filesAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഫയലുകൾ അറ്റാച്ച് ചെയ്തു',
      one: '1 ഫയൽ അറ്റാച്ച് ചെയ്തു',
    );
    return '$_temp0';
  }

  @override
  String get addAttachments => 'അറ്റാച്ച്‌മെന്റുകൾ ചേർക്കുക';

  @override
  String get max5mb => 'ഒരു ഫയലിന് പരമാവധി 5MB';

  @override
  String get cameraLabel => 'ക്യാമറ';

  @override
  String get galleryLabel => 'ഗാലറി';

  @override
  String get fileExceeds5mb => 'ഫയൽ 5MB പരിധി കവിയുന്നു';

  @override
  String failedToPickImage(String error) {
    return 'ചിത്രം തിരഞ്ഞെടുക്കാൻ കഴിഞ്ഞില്ല: $error';
  }

  @override
  String get transactionDeleted => 'ഇടപാട് ഇല്ലാതാക്കി';

  @override
  String get transferDeleted => 'ട്രാൻസ്ഫർ ഇല്ലാതാക്കി';

  @override
  String get undoLabel => 'പഴയപടിയാക്കുക';

  @override
  String get transactionAmount => 'ഇടപാട് തുക';

  @override
  String get accountUpper => 'അക്കൗണ്ട്';

  @override
  String get notesUpper => 'കുറിപ്പുകൾ';

  @override
  String get addedUsingPrompt => 'പ്രോംപ്റ്റ് ഉപയോഗിച്ച് ചേർത്തത്';

  @override
  String get attachedTags => 'ബന്ധിപ്പിച്ച ടാഗുകൾ';

  @override
  String get noneLabel => 'ഒന്നുമില്ല';

  @override
  String get filtersUpper => 'ഫിൽട്ടറുകൾ';

  @override
  String get filterExpensesTooltip => 'ചിലവുകൾ ഫിൽട്ടർ ചെയ്യുക';

  @override
  String get filterExp => 'ചിലവ്';

  @override
  String get filterIncomeTooltip => 'വരുമാനം ഫിൽട്ടർ ചെയ്യുക';

  @override
  String get filterInc => 'വരുമാനം';

  @override
  String get advancedFiltersTooltip => 'വിപുലമായ ഫിൽട്ടറുകൾ';

  @override
  String get clearFiltersTooltip => 'ഫിൽട്ടറുകൾ ഒഴിവാക്കുക';

  @override
  String get searchTransactionsTooltip => 'ഇടപാടുകൾ തിരയുക';

  @override
  String get searchTransactionsHint => 'ഇടപാടുകൾ തിരയുക...';

  @override
  String get applySearchTooltip => 'തിരച്ചിൽ പ്രയോഗിക്കുക';

  @override
  String get selectRange => 'പരിധി തിരഞ്ഞെടുക്കുക';

  @override
  String get advancedFiltersTitle => 'വിപുലമായ ഫിൽട്ടറുകൾ';

  @override
  String get clearAll => 'എല്ലാം ഒഴിവാക്കുക';

  @override
  String get dateRangeLabel => 'തീയതി പരിധി';

  @override
  String get selectDateRange => 'തീയതി പരിധി തിരഞ്ഞെടുക്കുക';

  @override
  String get transactionNameLabel => 'ഇടപാടിന്റെ പേര്';

  @override
  String get searchViaName => 'പേര് ഉപയോഗിച്ച് തിരയുക.';

  @override
  String get typeFilterLabel => 'തരം';

  @override
  String get amountRangeLabel => 'തുക പരിധി';

  @override
  String get minLabel => 'കുറഞ്ഞത്';

  @override
  String get maxLabel => 'കൂടിയത്';

  @override
  String get errorLoadingAccounts => 'അക്കൗണ്ടുകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get categoriesLabel => 'വിഭാഗങ്ങൾ';

  @override
  String get errorLoadingCategories => 'വിഭാഗങ്ങൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get errorLoadingTags => 'ടാഗുകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get applyFilters => 'ഫിൽട്ടറുകൾ പ്രയോഗിക്കുക';

  @override
  String get creditShort => 'ക്രെഡിറ്റ്';

  @override
  String get bucketDawn => 'പ്രഭാതം';

  @override
  String get bucketMorning => 'രാവിലെ';

  @override
  String get bucketNoon => 'ഉച്ചയ്ക്ക്';

  @override
  String get bucketEvening => 'വൈകുന്നേരം';

  @override
  String get bucketNight => 'രാത്രി';

  @override
  String get weekLabel => 'ആഴ്ച';

  @override
  String get analyticsTitle => 'ചിലവ്\nഅനലിറ്റിക്സ്';

  @override
  String get analyticsDescription => 'നിങ്ങളുടെ ചിലവ് രീതികൾ ദൃശ്യവൽക്കരിക്കുക';

  @override
  String get noData => 'വിവരങ്ങളൊന്നുമില്ല';

  @override
  String get noTransactionsForPeriod =>
      'ഈ കാലയളവിൽ ഇടപാടുകളൊന്നും കണ്ടെത്തിയില്ല';

  @override
  String get biggestTransactions => 'വലിയ ഇടപാടുകൾ';

  @override
  String get spendingTrend => 'ചിലവ് രീതികൾ';

  @override
  String get activeSelection => 'സജീവമായ സെലക്ഷൻ';

  @override
  String get quickFilters => 'ക്വിക്ക് ഫിൽട്ടറുകൾ';

  @override
  String get jumpTo => 'ഇതിലേക്ക് പോവുക';

  @override
  String get invalidFormat => 'തെറ്റായ ഫോർമാറ്റ്';

  @override
  String get startBeforeEnd => 'ആരംഭ തീയതി അവസാന തീയതിക്ക് മുൻപായിരിക്കണം';

  @override
  String get futureDatesNotAllowed => 'ഭാവി തീയതികൾ അനുവദനീയമല്ല';

  @override
  String get manualDateRange => 'സ്വന്തമായി തീയതി തിരഞ്ഞെടുക്കൽ';

  @override
  String get manualDateRangeDesc =>
      'നിങ്ങളുടെ സാമ്പത്തിക വിശകലനത്തിനായി ഒരു പ്രത്യേക കാലയളവ് വ്യക്തമാക്കുക.';

  @override
  String get fromDateLabel => 'തീയതി മുതൽ (DD/MM/YYYY)';

  @override
  String get toDateLabel => 'തീയതി വരെ (DD/MM/YYYY)';

  @override
  String get doneUpper => 'കഴിഞ്ഞു';

  @override
  String get cancelUpper => 'റദ്ദാക്കുക';

  @override
  String get thresholdSettings => 'പരിധി ക്രമീകരണങ്ങൾ';

  @override
  String get resetToDefaults => 'ഡിഫോൾട്ടിലേക്ക് പുനഃക്രമീകരിക്കുക';

  @override
  String get thresholdSmallDesc =>
      'ഇടപാടുകൾ \"Small\" എന്ന് അടയാളപ്പെടുത്താനുള്ള പരിധി തുക.';

  @override
  String get thresholdLargeDesc =>
      'ഇടപാടുകൾ \"Large\" എന്ന് അടയാളപ്പെടുത്താനുള്ള പരിധി തുക.';

  @override
  String get previewLogic => 'പ്രിവ്യൂ ലോജിക്';

  @override
  String get sizeSmall => 'ചെറുത്';

  @override
  String get sizeMedium => 'ഇടത്തരം';

  @override
  String get sizeLarge => 'വലുത്';

  @override
  String get budgetVsActual => 'ബജറ്റും യഥാർത്ഥ ചിലവും';

  @override
  String get errorLoadingBudgets => 'ബജറ്റുകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get noActiveBudgets => 'സജീവമായ ബജറ്റുകളൊന്നുമില്ല';

  @override
  String get tagWiseAnalytics => 'ടാഗ് തിരിച്ചുള്ള അനലിറ്റിക്സ്';

  @override
  String get spendingByTag => 'ടാഗ് തിരിച്ചുള്ള ചിലവ്';

  @override
  String get topTagsContribution => 'പ്രധാന ടാഗുകളുടെ സംഭാവന';

  @override
  String get noTagsInRange =>
      'നിങ്ങൾ തിരഞ്ഞെടുത്ത തീയതി പരിധിയിൽ ടാഗുകളുള്ള ഇടപാടുകളൊന്നുമില്ല';

  @override
  String get spendingDistribution => 'ചിലവ് വിതരണം';

  @override
  String get groupLabel => 'ഗ്രൂപ്പ്';

  @override
  String get errorLoadingData => 'വിവരങ്ങൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get noDataAvailable => 'വിവരങ്ങൾ ലഭ്യമല്ല';

  @override
  String get transactionSizeDistribution => 'ഇടപാട് വലുപ്പത്തിന്റെ വിതരണം';

  @override
  String get frequencyByTicketSize => 'ഇടപാടുകളുടെ ആവൃത്തി';

  @override
  String get avgWeeklyHeatmap => 'ശരാശരി പ്രതിവാര ഹീറ്റ്‌മാപ്പ്';

  @override
  String get basedOnSelectedFilter =>
      'നിങ്ങൾ തിരഞ്ഞെടുത്ത ഫിൽട്ടർ അടിസ്ഥാനമാക്കി';

  @override
  String get intensity => 'തീവ്രത';

  @override
  String get applyFilter => 'ഫിൽട്ടർ പ്രയോഗിക്കുക';

  @override
  String get thresholdFloorHeading => 'Small/Medium അതിർത്തി (Floor)';

  @override
  String get thresholdCeilingHeading => 'Medium/Large അതിർത്തി (Ceiling)';

  @override
  String get manageAccounts => 'അക്കൗണ്ടുകൾ\nകൈകാര്യം ചെയ്യുക';

  @override
  String get addAccount => 'അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get editAccount => 'അക്കൗണ്ട് തിരുത്തുക';

  @override
  String get addFirstAccount =>
      'ട്രാക്കിംഗ് ആരംഭിക്കാൻ നിങ്ങളുടെ ആദ്യ അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get addAnotherAccount => 'മറ്റൊരു അക്കൗണ്ട് ചേർക്കുക';

  @override
  String get availableBalance => 'ലഭ്യമായ ബാലൻസ്';

  @override
  String get limitUpper => 'പരിധി';

  @override
  String get defaultUpper => 'ഡിഫോൾട്ട്';

  @override
  String get addTransactionTooltip => 'ഇടപാട് ചേർക്കുക';

  @override
  String get savingsAccount => 'സേവിംഗ്സ് അക്കൗണ്ട്';

  @override
  String get viewTransactions => 'ഇടപാടുകൾ കാണുക';

  @override
  String get errorLoadingBalance => 'ബാലൻസ് ലോഡ് ചെയ്യുന്നതിൽ പിശക്';

  @override
  String get editLimitSpent => 'ഉപയോഗിച്ച പരിധി തിരുത്തുക';

  @override
  String get editBalance => 'ബാലൻസ് തിരുത്തുക';

  @override
  String get deleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കുക';

  @override
  String get removeDefault => 'ഡിഫോൾട്ട് നീക്കം ചെയ്യുക';

  @override
  String get setAsDefaultLabel => 'ഡിഫോൾട്ട് ആയി സജ്ജീകരിക്കുക';

  @override
  String get currentAvailableBalance => 'നിലവിലെ ലഭ്യമായ ബാലൻസ്';

  @override
  String get limitSpent => 'ഉപയോഗിച്ച പരിധി';

  @override
  String get totalLimit => 'ആകെ പരിധി';

  @override
  String get cannotDeleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കാൻ കഴിയില്ല';

  @override
  String get cannotDeleteAccountBody =>
      'ഈ അക്കൗണ്ടുമായി ബന്ധിപ്പിച്ച ഇടപാടുകളുണ്ട്. അക്കൗണ്ട് ഇല്ലാതാക്കാൻ, ആദ്യം ബന്ധിപ്പിച്ച ഇടപാടുകൾ ഇല്ലാതാക്കുക.';

  @override
  String get okLabel => 'ശരി';

  @override
  String get deleteAccountConfirm => 'അക്കൗണ്ട് ഇല്ലാതാക്കണോ?';

  @override
  String get limitSpentUpdated => 'ഉപയോഗിച്ച പരിധി വിജയകരമായി അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get balanceUpdated => 'ബാലൻസ് വിജയകരമായി അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get currentLimitSpent => 'നിലവിൽ ഉപയോഗിച്ച പരിധി';

  @override
  String get currentBalance => 'നിലവിലെ ബാലൻസ്';

  @override
  String get newLimitSpent => 'പുതിയ ഉപയോഗിച്ച പരിധി';

  @override
  String get newBalance => 'പുതിയ ബാലൻസ്';

  @override
  String get enterAccountName => 'ദയവായി അക്കൗണ്ടിന്റെ പേര് നൽകുക';

  @override
  String get identity => 'ഐഡന്റിറ്റി';

  @override
  String get creditCardName => 'ക്രെഡിറ്റ് കാർഡിന്റെ പേര്';

  @override
  String get cashName => 'ക്യാഷിന്റെ പേര്';

  @override
  String get bankName => 'ബാങ്കിന്റെ പേര്';

  @override
  String get iconLabel => 'ഐക്കൺ';

  @override
  String get colorLabel => 'നിറം';

  @override
  String get typeLabel => 'തരം';

  @override
  String get last4DigitsHint => 'അവസാന 4 അക്കങ്ങൾ (ഓപ്ഷണൽ)';

  @override
  String get balanceLabel => 'ബാലൻസ്';

  @override
  String get initialBalance => 'തുടക്കത്തിലെ ബാലൻസ്';

  @override
  String get limitSpentField => 'ഉപയോഗിച്ച പരിധി';

  @override
  String get totalLimitField => 'ആകെ പരിധി';

  @override
  String get saveAccount => 'അക്കൗണ്ട് സൂക്ഷിക്കുക';

  @override
  String get totalNetWorth => 'ആകെ അറ്റമൂല്യം';

  @override
  String get assets => 'ആസ്തികൾ';

  @override
  String get debt => 'കടബാധ്യത';

  @override
  String get cardLast4Note =>
      'കാർഡിന്റെ അവസാന 4 അക്കങ്ങൾ · എവിടെയും പങ്കിടില്ല';

  @override
  String lastTransaction(String time) {
    return 'അവസാന ഇടപാട് $time';
  }

  @override
  String deleteAccountBody(String name) {
    return 'നിങ്ങൾക്ക് $name ഇല്ലാതാക്കണമെന്ന് ഉറപ്പാണോ? ഈ പ്രവർത്തനം പഴയപടിയാക്കാൻ കഴിയില്ല.';
  }

  @override
  String get adjustmentNote =>
      'ക്രമീകരണം ഒരു ഇടപാടായി രേഖപ്പെടുത്തും (അനലിറ്റിക്സിനെ ബാധിക്കില്ല)';

  @override
  String get trackBudgets => 'ബജറ്റുകൾ\nട്രാക്ക് ചെയ്യുക';

  @override
  String get createBudget => 'ബജറ്റ് സൃഷ്ടിക്കുക';

  @override
  String get editBudget => 'ബജറ്റ് തിരുത്തുക';

  @override
  String get noBudgetsYet => 'ബജറ്റുകളൊന്നുമില്ല';

  @override
  String get createBudgetsDesc =>
      'ഓരോ വിഭാഗത്തിലെയും ചിലവുകൾ നിയന്ത്രിക്കാൻ ബജറ്റുകൾ സൃഷ്ടിക്കുക';

  @override
  String get disabledUpper => 'നിർജ്ജീവമാക്കി';

  @override
  String get expiredUpper => 'കാലാവധി കഴിഞ്ഞു';

  @override
  String get budgetPeriodEnded => 'ബജറ്റ് കാലാവധി അവസാനിച്ചു';

  @override
  String get budgetPaused =>
      'ബജറ്റ് ഇപ്പോൾ താൽക്കാലികമായി നിർത്തിവച്ചിരിക്കുകയാണ്';

  @override
  String budgetResetsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസങ്ങൾക്കുള്ളിൽ',
      one: '1 ദിവസത്തിനുള്ളിൽ',
    );
    return '$_temp0 പുനഃക്രമീകരിക്കപ്പെടും';
  }

  @override
  String budgetExpiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസങ്ങൾക്കുള്ളിൽ',
      one: '1 ദിവസത്തിനുള്ളിൽ',
    );
    return '$_temp0 കാലാവധി തീരും';
  }

  @override
  String get progressLabel => 'പുരോഗതി';

  @override
  String get selectCategoryUpper => 'വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get budgetAmount => 'ബജറ്റ് തുക';

  @override
  String get appliesTo => 'ബാധകമാകുന്നത്';

  @override
  String get thisMonthOnly => 'ഈ മാസത്തേക്ക്\nമാത്രം';

  @override
  String get everyMonth => 'എല്ലാ\nമാസവും';

  @override
  String get budgetAlerts => 'ബജറ്റ് അറിയിപ്പുകൾ';

  @override
  String get addAlert => 'അറിയിപ്പ് ചേർക്കുക';

  @override
  String get saveBudget => 'ബജറ്റ് സൂക്ഷിക്കുക';

  @override
  String get tapToChangeCategory => 'വിഭാഗം മാറ്റാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get chooseCategory => 'വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get monthlyBudgetPlan => 'പ്രതിമാസ ബജറ്റ് പ്ലാൻ';

  @override
  String get currentSpending => 'നിലവിലെ ചിലവ്';

  @override
  String get utilization => 'ഉപയോഗം';

  @override
  String get budgetDetails => 'ബജറ്റ് വിവരങ്ങൾ';

  @override
  String get createdOn => 'സൃഷ്ടിച്ച തീയതി';

  @override
  String get renewsOn => 'പുതുക്കുന്ന തീയതി';

  @override
  String get expiresOn => 'കാലാവധി തീരുന്ന തീയതി';

  @override
  String get startedOn => 'ആരംഭിച്ച തീയതി';

  @override
  String get statusUpper => 'നിലവിലെ സ്ഥിതി';

  @override
  String get activeLabel => 'സജീവം';

  @override
  String get pausedLabel => 'നിർത്തിവച്ചിരിക്കുന്നു';

  @override
  String get activeAlerts => 'സജീവമായ അറിയിപ്പുകൾ';

  @override
  String get noAlertsSet => 'അറിയിപ്പുകളൊന്നും സജ്ജീകരിച്ചിട്ടില്ല';

  @override
  String get actionsUpper => 'പ്രവർത്തനങ്ങൾ';

  @override
  String get pauseLabel => 'താൽക്കാലികമായി നിർത്തുക';

  @override
  String get resumeLabel => 'തുടരുക';

  @override
  String get historyLabel => 'ചരിത്രം';

  @override
  String get deleteBudgetConfirm => 'ബജറ്റ് ഇല്ലാതാക്കണോ?';

  @override
  String get budgetHistory => 'ബജറ്റ് ചരിത്രം';

  @override
  String get noHistoryYet => 'ചരിത്രമൊന്നുമില്ല';

  @override
  String get budgetHistoryEmptyDesc =>
      'ഇടപാടുകൾ രേഖപ്പെടുത്തുമ്പോൾ ഈ ബജറ്റിനായുള്ള നിങ്ങളുടെ ചിലവ് ചരിത്രം ഇവിടെ കാണാം.';

  @override
  String get overBudget => 'ബജറ്റ് കവിഞ്ഞു';

  @override
  String get underBudget => 'ബജറ്റിനുള്ളിൽ';

  @override
  String get enterValidValue => 'സാധുവായ ഒരു മൂല്യം നൽകുക';

  @override
  String get amountExceedsBudget => 'തുക ബജറ്റ് പരിധിയേക്കാൾ കൂടാൻ പാടില്ല';

  @override
  String get alertAlreadyExists => 'ഈ മൂല്യത്തിനായി ഒരു അലേർട്ട് നിലവിലുണ്ട്';

  @override
  String get addAlertTitle => 'അലേർട്ട് ചേർക്കുക';

  @override
  String get selectAlertType => 'അലേർട്ട് തരം തിരഞ്ഞെടുക്കുക';

  @override
  String get percentageType => 'ശതമാനം (%)';

  @override
  String get pushNotification => 'പുഷ് നോട്ടിഫിക്കേഷൻ';

  @override
  String exceededBy(String amount) {
    return '$amount കവിഞ്ഞു';
  }

  @override
  String get budgetAlreadyExists => 'ഈ വിഭാഗത്തിനായി ഒരു ബജറ്റ് നിലവിലുണ്ട്';

  @override
  String deleteBudgetBody(String name) {
    return '\"$name\"-നുള്ള ബജറ്റ് ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';
  }

  @override
  String alertDesc(String value) {
    return 'ചിലവ് എൻ്റെ പ്രതിമാസ ബജറ്റിൻ്റെ $value ലേക്ക് എത്തുമ്പോൾ എന്നെ അറിയിക്കുക.';
  }

  @override
  String get percentageCannotExceed => 'ശതമാനം 100% കവിയാൻ പാടില്ല';

  @override
  String alertAmountType(String symbol) {
    return 'സ്ഥിരമായ തുക ($symbol)';
  }

  @override
  String get loansTitle => 'വായ്പകൾ';

  @override
  String get addLoan => 'ലോൺ ചേർക്കുക';

  @override
  String get noLoansAdded => 'ലോണുകളൊന്നും ചേർത്തിട്ടില്ല';

  @override
  String get loansEmptyDesc =>
      'നിങ്ങളുടെ ആദ്യത്തെ ലോൺ ഇഎംഐ ട്രാക്ക് ചെയ്യാൻ + ടാപ്പ് ചെയ്യുക';

  @override
  String get activeLoans => 'സജീവമായ ലോണുകൾ';

  @override
  String get editLoan => 'ലോൺ തിരുത്തുക';

  @override
  String get newLoan => 'പുതിയ ലോൺ';

  @override
  String get loanAmount => 'ലോൺ തുക';

  @override
  String get totalPrincipal => 'ആകെ പ്രിൻസിപ്പൽ';

  @override
  String get loanType => 'ലോൺ തരം';

  @override
  String get loanTypeVehicle => 'വാഹനം';

  @override
  String get loanTypePersonal => 'വ്യക്തിഗതം';

  @override
  String get loanTypeEducation => 'വിദ്യാഭ്യാസം';

  @override
  String get loanTypeOther => 'മറ്റുള്ളവ';

  @override
  String get loanName => 'ലോണിന്റെ പേര്';

  @override
  String get loanNameHint => 'ഉദാ. Maruti Brezza';

  @override
  String get lenderHint => 'ഉദാ. HDFC Bank';

  @override
  String get referenceNumber => 'റഫറൻസ് നമ്പർ';

  @override
  String get referenceNumberHint => 'അനുമതി / വായ്പ ഐഡി';

  @override
  String get termsLabel => 'വ്യവസ്ഥകൾ';

  @override
  String get interestRate => 'പലിശ നിരക്ക്';

  @override
  String get rateFixed => 'സ്ഥിരമായത്';

  @override
  String get rateFloating => 'മാറിക്കൊണ്ടിരിക്കുന്നത്';

  @override
  String get payEmi => 'EMI അടയ്ക്കുക';

  @override
  String get payExtra => 'അധിക തുക അടയ്ക്കുക';

  @override
  String get closeLoan => 'ലോൺ ക്ലോസ് ചെയ്യുക';

  @override
  String get progressUpper => 'പുരോഗതി';

  @override
  String get totalUpper => 'ആകെ';

  @override
  String get paidUpper => 'അടച്ചത്';

  @override
  String get remainingUpper => 'ബാക്കിയുള്ളത്';

  @override
  String get nextEmiDue => 'അടുത്ത EMI അടയ്ക്കേണ്ടത്';

  @override
  String get interestRateUpper => 'പലിശ നിരക്ക്';

  @override
  String get paymentHistory => 'പേയ്‌മെന്റ് ചരിത്രം';

  @override
  String get noPaymentsRecorded => 'പേയ്‌മെന്റുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get deleteLoanConfirm => 'ലോൺ ഇല്ലാതാക്കണോ?';

  @override
  String get deleteLoanBody =>
      'ഇത് ഈ ലോണും അതുമായി ബന്ധിപ്പിച്ച എല്ലാ പേയ്‌മെന്റ് ഇടപാടുകളും ഇല്ലാതാക്കും. ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';

  @override
  String get emiPaid => 'EMI അടച്ചു';

  @override
  String get extraPayment => 'അധിക പേയ്‌മെന്റ്';

  @override
  String get loanClosure => 'ലോൺ ക്ലോസ് ചെയ്യൽ';

  @override
  String get confirmClosure => 'ക്ലോസ് ചെയ്യുന്നത് സ്ഥിരീകരിക്കുക';

  @override
  String get confirmPayment => 'പേയ്‌മെന്റ് സ്ഥിരീകരിക്കുക';

  @override
  String get amountUpper => 'തുക';

  @override
  String get dateUpper => 'തീയതി';

  @override
  String get noteOptional => 'കുറിപ്പ് (ഓപ്ഷണൽ)';

  @override
  String get totalOutstandingDebt => 'ആകെ കടബാധ്യത';

  @override
  String get paidLabel => 'അടച്ചത്';

  @override
  String get outstandingTitle => 'കടബാധ്യതയുള്ളത്';

  @override
  String get interestLabel => 'പലിശ';

  @override
  String get nextDue => 'അടുത്ത തവണ';

  @override
  String get completedUpper => 'പൂർത്തിയായി';

  @override
  String get lenderField => 'വായ്പ നൽകിയയാൾ';

  @override
  String get loanTypeHome => 'ഭവനം';

  @override
  String get monthlyOutflow => 'പ്രതിമാസ ചിലവ്';

  @override
  String get perMonth => 'പ്രതിമാസം';

  @override
  String get tenure => 'കാലാവധി';

  @override
  String get schedule => 'ഷെഡ്യൂൾ';

  @override
  String get loanStartDate => 'ലോൺ ആരംഭ തീയതി';

  @override
  String get repaymentStart => 'തിരിച്ചടവ് ആരംഭം';

  @override
  String get firstEmiOn => 'ആദ്യ EMI തീയതി';

  @override
  String get monthlyBillDate => 'പ്രതിമാസ ബിൽ തീയതി';

  @override
  String get sourceAccount => 'സ്രോതസ്സ് അക്കൗണ്ട്';

  @override
  String get autoAddTransactions => 'ഇടപാടുകൾ സ്വയമേവ ചേർക്കുക';

  @override
  String get autoAddTransactionsSub =>
      'ഓരോ ബിൽ തീയതിയിലും ഓരോ EMI-യും \"Loan EMI\" വിഭാഗത്തിലേക്ക് സ്വയമേവ ചേർക്കുക';

  @override
  String get notesLabel => 'കുറിപ്പുകൾ';

  @override
  String get loanNotesHint => 'രേഖകൾ · അനുമതി പത്രം · മറ്റെന്തെങ്കിലും';

  @override
  String get saveChanges => 'മാറ്റങ്ങൾ സൂക്ഷിക്കുക';

  @override
  String get confirmAddLoan => 'സ്ഥിരീകരിച്ച് ലോൺ ചേർക്കുക';

  @override
  String percentPaid(String pct) {
    return '$pct% അടച്ചു';
  }

  @override
  String get navHome => 'ഹോം';

  @override
  String get navHistory => 'ചരിത്രം';

  @override
  String get navAnalytics => 'വിശകലനം';

  @override
  String get navMore => 'കൂടുതൽ';

  @override
  String get speedDialRecurring => 'ആവർത്തിച്ചുള്ള ഇടപാട് ചേർക്കുക';

  @override
  String get speedDialLoan => 'വായ്പ ചേർക്കുക';

  @override
  String get speedDialInvestment => 'നിക്ഷേപം ചേർക്കുക';

  @override
  String get speedDialLendBorrow => 'വായ്പ നൽകൽ / വാങ്ങൽ ചേർക്കുക';

  @override
  String get moneyStoriesTitle => 'മണി സ്റ്റോറീസ്';

  @override
  String get moneyStoriesEmpty =>
      'നിങ്ങളുടെ മണി സ്റ്റോറീസ് കാണാൻ ഇടപാടുകൾ തുടരുക.';

  @override
  String get bubbleWelcome => 'സ്വാഗതം';

  @override
  String get bubbleDaily => 'ദിനപത്രം';

  @override
  String get bubbleWeekly => 'പ്രതിവാര';

  @override
  String get bubbleMonthly => 'പ്രതിമാസ';

  @override
  String get bubbleYearly => 'വാർഷികം';

  @override
  String get bubbleLoans => 'വായ്പകൾ';

  @override
  String get bubbleInvestments => 'നിക്ഷേപങ്ങൾ';

  @override
  String get bubbleLedger => 'കടം രജിസ്റ്റർ';

  @override
  String get bubbleInsights => 'വിവരങ്ങൾ';

  @override
  String get storiesArchiveTitle => 'കഥകളുടെ ശേഖരം';

  @override
  String get storiesArchiveDesc =>
      'നിങ്ങൾക്കായി തയ്യാറാക്കിയ ഓരോ കഥയുടെയും ചുരുക്കം, ഏറ്റവും പുതിയത് ആദ്യം.';

  @override
  String get noStoriesYet => 'ഇതുവരെ കഥകളൊന്നുമില്ല';

  @override
  String get keepUsingToSeeRecaps =>
      'നിങ്ങളുടെ ചുരുക്കങ്ങൾ ഇവിടെ കാണാൻ കുബേർ ഉപയോഗിക്കുന്നത് തുടരുക.';

  @override
  String get earlierThisWeek => 'ഈ ആഴ്ച ആദ്യം';

  @override
  String get earlierThisMonth => 'ഈ മാസം ആദ്യം';

  @override
  String get olderLabel => 'പഴയവ';

  @override
  String get loadingOlderStories => 'പഴയ കഥകൾ ലോഡ് ചെയ്യുന്നു';

  @override
  String get justNow => 'ഇപ്പോൾ തന്നെ';

  @override
  String minsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count മിനിറ്റ് മുമ്പ്',
      one: '1 മിനിറ്റ് മുമ്പ്',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count മണിക്കൂർ മുമ്പ്',
      one: '1 മണിക്കൂർ മുമ്പ്',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസം മുമ്പ്',
      one: '1 ദിവസം മുമ്പ്',
    );
    return '$_temp0';
  }

  @override
  String relativeToday(Object time) {
    return 'ഇന്ന്, $time';
  }

  @override
  String relativeYesterday(Object time) {
    return 'ഇന്നലെ, $time';
  }

  @override
  String get utilizedLabel => 'ഉപയോഗിച്ചത്';

  @override
  String utilizedPct(Object pct) {
    return '$pct% ഉപയോഗിച്ചു';
  }

  @override
  String get editWidgets => 'വിഡ്ജറ്റുകൾ മാറ്റുക';

  @override
  String get editHomeWidgets => 'ഹോം വിഡ്ജറ്റുകൾ മാറ്റുക';

  @override
  String get editHomeWidgetsDesc =>
      'ഹോം വിഡ്ജറ്റുകൾ തിരഞ്ഞെടുത്ത് ക്രമീകരിക്കുക';

  @override
  String get editAnalyticsWidgets => 'വിശകലന വിഡ്ജറ്റുകൾ മാറ്റുക';

  @override
  String get editAnalyticsWidgetsDesc =>
      'വിശകലന വിഡ്ജറ്റുകൾ തിരഞ്ഞെടുത്ത് ക്രമീകരിക്കുക';

  @override
  String get filterAll => 'എല്ലാം';

  @override
  String get filterToday => 'ഇന്ന്';

  @override
  String get filterThisWeek => 'ഈ ആഴ്ച';

  @override
  String get filterLastWeek => 'കഴിഞ്ഞ ആഴ്ച';

  @override
  String get filterThisMonth => 'ഈ മാസം';

  @override
  String get filterLastMonth => 'കഴിഞ്ഞ മാസം';

  @override
  String get filterThisYear => 'ഈ വർഷം';

  @override
  String get filterCustom => 'ഇഷ്ടാനുസരണം';

  @override
  String get moreManageTitle => 'മാനേജ്മെന്റ്';

  @override
  String get moreToolsTitle => 'സിഗ്നേച്ചർ';

  @override
  String get moreAppTitle => 'ആപ്പ്';

  @override
  String get moreTutorialTitle => 'ട്യൂട്ടോറിയൽ';

  @override
  String get moreHelpUsTitle => 'ഞങ്ങളെ സഹായിക്കൂ';

  @override
  String get moreAboutTitle => 'കുറിച്ച്';

  @override
  String get moreSearchTooltip => 'തിരയുക';

  @override
  String get moreManageSubtitle =>
      'നിങ്ങളുടെ ക്രമീകരണങ്ങൾ, ഉപകരണങ്ങൾ, ഡാറ്റ എന്നിവ കൈകാര്യം ചെയ്യുക';

  @override
  String get menuAccounts => 'അക്കൗണ്ടുകൾ';

  @override
  String get menuAccountsDesc => 'നിങ്ങളുടെ വാലറ്റുകളും ബാങ്ക് അക്കൗണ്ടുകളും';

  @override
  String get menuCategories => 'വിഭാഗങ്ങൾ';

  @override
  String get menuCategoriesDesc => 'ഇടപാടുകൾ തരംതിരിക്കുക';

  @override
  String get menuTags => 'ടാഗുകൾ';

  @override
  String get menuTagsDesc => 'ഇടപാടുകളുടെ ലേബലുകൾ ക്രമീകരിക്കുക';

  @override
  String get menuBudgets => 'ബഡ്ജറ്റുകൾ';

  @override
  String get menuBudgetsDesc =>
      'പ്രതിമാസ ചിലവുകൾ നിരീക്ഷിക്കുകയും നിയന്ത്രിക്കുകയും ചെയ്യുക';

  @override
  String get menuRecurring => 'ആവർത്തിച്ചുള്ള ഇടപാടുകൾ';

  @override
  String get menuRecurringDesc => 'ക്രമീകരിച്ച ആവർത്തിച്ചുള്ള ഇടപാടുകൾ';

  @override
  String get menuLedger => 'കടങ്ങൾ (വാങ്ങൽ / നൽകൽ)';

  @override
  String get menuLedgerDesc => 'നൽകിയതോ വാങ്ങിയതോ ആയ പണം ട്രാക്ക് ചെയ്യുക';

  @override
  String get menuLoans => 'വായ്പകൾ (ലോണുകൾ)';

  @override
  String get menuLoansDesc => 'ഇഎംഐയും തിരിച്ചടവ് പുരോഗതിയും ട്രാക്ക് ചെയ്യുക';

  @override
  String get menuInvestments => 'നിക്ഷേപങ്ങൾ';

  @override
  String get menuInvestmentsDesc =>
      'നിക്ഷേപങ്ങളുടെ മൂല്യവും വളർച്ചയും ട്രാക്ക് ചെയ്യുക';

  @override
  String get menuAskKuber => 'കുബേറിനോട് ചോദിക്കുക (ബീറ്റ)';

  @override
  String get menuAskKuberDesc =>
      'ഫോണിൽ പ്രവർത്തിക്കുന്ന സ്മാർട്ട് അസിസ്റ്റന്റ്';

  @override
  String get menuCalculators => 'കാൽക്കുലേറ്ററുകളും ടൂളുകളും';

  @override
  String get menuCalculatorsDesc =>
      'ഇഎംഐ, എസ്ഐപി, ശമ്പളം, ജിഎസ്ടി, സ്പ്ലിറ്റ് എന്നിവയും അതിലേറെയും';

  @override
  String get menuSettings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get menuSettingsDesc => 'തീം, കറൻസി, പ്രൊഫൈൽ എന്നിവ';

  @override
  String get menuData => 'ഡാറ്റ';

  @override
  String get menuDataDesc =>
      'ഡാറ്റ എക്സ്പോർട്ട്, ഇമ്പോർട്ട്, ഓട്ടോമാറ്റിക് ബാക്കപ്പ്';

  @override
  String get menuStoriesArchive => 'മണി സ്റ്റോറീസ് ശേഖരം';

  @override
  String get menuStoriesArchiveDesc => 'ഓരോ ചുരുക്കങ്ങളും, പുതിയത് ആദ്യം';

  @override
  String get menuWidgets => 'വിജറ്റുകൾ';

  @override
  String get menuWidgetsDesc =>
      'Kuber കൺമുന്നിൽ നിർത്താൻ ഹോം സ്ക്രീൻ വിജറ്റുകൾ';

  @override
  String get menuTroubleshoot => 'ട്രബിൾഷൂട്ട്';

  @override
  String get menuTroubleshootDesc =>
      'ഡാറ്റയും നിർദ്ദേശങ്ങളിലെ തെറ്റുകളും പരിഹരിക്കുക';

  @override
  String get menuTutorial => 'ആപ്പ് ട്യൂട്ടോറിയൽ (ബീറ്റ)';

  @override
  String get menuTutorialDesc => 'ഫീച്ചറുകളുടെ ഗൈഡ് വീണ്ടും കാണുക';

  @override
  String get menuRateUs => 'പ്ലേ സ്റ്റോറിൽ ഞങ്ങളെ റേറ്റുചെയ്യുക';

  @override
  String get menuRateUsDesc => 'കുബേർ ഇഷ്ടമായോ? ഒരു റിവ്യൂ എഴുതുക';

  @override
  String get menuShareApp => 'ആപ്പ് ഷെയർ ചെയ്യുക';

  @override
  String get menuShareAppDesc =>
      'കൂട്ടുകാർക്കും കുടുംബത്തിനും കുബേർ നിർദ്ദേശിക്കുക';

  @override
  String get menuFeedback => 'അഭിപ്രായം അറിയിക്കുക';

  @override
  String get menuFeedbackDesc =>
      'പ്രശ്നങ്ങൾ റിപ്പോർട്ട് ചെയ്യുകയോ പുതിയ ഫീച്ചറുകൾ നിർദ്ദേശിക്കുകയോ ചെയ്യുക';

  @override
  String get menuAbout => 'കുബേറിനെക്കുറിച്ച്';

  @override
  String get menuAboutDesc => 'ലക്ഷ്യം, തുടക്കം, ഡെവലപ്പർ വിവരങ്ങൾ';

  @override
  String get menuPermissions => 'അനുമതികൾ';

  @override
  String get menuPermissionsDesc => 'ആപ്പ് പരിധികളും സുരക്ഷയും';

  @override
  String get menuDevTools => 'ഡെവലപ്പർ ടൂളുകൾ';

  @override
  String get menuDevToolsDesc => 'ഡെവലപ്പർമാർക്ക് മാത്രമുള്ള ഉപകരണങ്ങൾ';

  @override
  String madeInIndia(Object heart) {
    return 'ഇന്ത്യയിൽ $heart-ഓടെ നിർമ്മിച്ചത്';
  }

  @override
  String madeInIndiaVersion(Object heart, Object version) {
    return 'ഇന്ത്യയിൽ $heart-ഓടെ നിർമ്മിച്ചത് · v$version';
  }

  @override
  String get shareMessage =>
      'നിങ്ങളുടെ ചിലവുകൾ മുമ്പെന്നത്തേക്കാളും എളുപ്പത്തിൽ കൈകാര്യം ചെയ്യുക. ഇന്ത്യയിൽ സ്നേഹത്തോടെ നിർമ്മിച്ച ഒരു ലളിതമായ ചിലവ് നിയന്ത്രണ ആപ്പാണ് കുബേർ. ഇവിടെ ഡൗൺലോഡ് ചെയ്യുക: https://play.google.com/store/apps/details?id=com.grs.kuber';

  @override
  String get menuManageSpaces => '8 വിഭാഗങ്ങൾ';

  @override
  String get menuHelpUsHint => 'സഹായിക്കാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get menuRateKuber => 'കുബേർ റേറ്റുചെയ്യുക';

  @override
  String get menuShare => 'ഷെയർ ചെയ്യുക';

  @override
  String get menuFeedbackShort => 'അഭിപ്രായം';

  @override
  String get menuAppTutorialShort => 'ആപ്പ് ട്യൂട്ടോറിയൽ';

  @override
  String get menuNotifications => 'അറിയിപ്പുകൾ';

  @override
  String get menuNotificationsDesc =>
      'സമീപകാല അലേർട്ടുകളും ഓർമ്മപ്പെടുത്തലുകളും';

  @override
  String get manageCategoriesTitle => 'വിഭാഗങ്ങൾ\nക്രമീകരിക്കുക';

  @override
  String get addCategoryGroup => 'വിഭാഗം/ഗ്രൂപ്പ് ചേർക്കുക';

  @override
  String get noCategoriesYet => 'ഇതുവരെ വിഭാഗങ്ങളൊന്നുമില്ല';

  @override
  String get createCategoriesToOrganize =>
      'ചിലവുകൾ ക്രമീകരിക്കാൻ വിഭാഗങ്ങൾ നിർമ്മിക്കുക';

  @override
  String get searchCategoriesGroups => 'വിഭാഗങ്ങളും ഗ്രൂപ്പുകളും തിരയുക...';

  @override
  String get noMatches => 'അനുയോജ്യമായവയില്ല';

  @override
  String noCategoriesGroupsMatch(Object query) {
    return '\"$query\"-മായി പൊരുത്തപ്പെടുന്ന വിഭാഗങ്ങളോ ഗ്രൂപ്പുകളോ ഇല്ല.';
  }

  @override
  String get ungroupedLabel => 'തരംതിരിക്കാത്തവ';

  @override
  String get categoryGroupLabel => 'വിഭാഗം ഗ്രൂപ്പ്';

  @override
  String get editGroupLabel => 'ഗ്രൂപ്പ് തിരുത്തുക';

  @override
  String get deleteGroupLabel => 'ഗ്രൂപ്പ് ഇല്ലാതാക്കുക';

  @override
  String get groupAlreadyExists => 'ഈ ഗ്രൂപ്പ് നിലവിലുണ്ട്';

  @override
  String get groupNameEmpty => 'ഗ്രൂപ്പ് പേര് ശൂന്യമാകരുത്';

  @override
  String get addNewHeader => 'പുതിയത് ചേർക്കുക';

  @override
  String get addClassifyDesc =>
      'ഇടപാടുകൾ എളുപ്പത്തിൽ ട്രാക്ക് ചെയ്യാൻ വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get addGroupHeader => 'ഗ്രൂപ്പ് ചേർക്കുക';

  @override
  String get addGroupDesc => 'വിഭാഗങ്ങളെ വ്യത്യസ്ത ഗ്രൂപ്പുകളായി തിരിക്കുക';

  @override
  String get manageTagsTitle => 'ടാഗുകൾ\nക്രമീകരിക്കുക';

  @override
  String get addTagLabel => 'ടാഗ് ചേർക്കുക';

  @override
  String get noTagsYet => 'ഇതുവരെ ടാഗുകളൊന്നുമില്ല';

  @override
  String get createTagsToLabel =>
      'ഇടപാടുകളെ അടയാളപ്പെടുത്താൻ ടാഗുകൾ നിർമ്മിക്കുക (ഉദാ. #trip, #work)';

  @override
  String get searchTags => 'ടാഗുകൾ തിരയുക...';

  @override
  String noTagsMatch(Object query) {
    return '\"$query\"-മായി പൊരുത്തപ്പെടുന്ന ടാഗുകളില്ല.';
  }

  @override
  String get editTag => 'ടാഗ് തിരുത്തുക';

  @override
  String get deleteTag => 'ടാഗ് ഇല്ലാതാക്കുക';

  @override
  String get tagNameEmpty => 'ടാഗ് പേര് ശൂന്യമാകരുത്';

  @override
  String get tagAlreadyExists => 'ഈ ടാഗ് നിലവിലുണ്ട്';

  @override
  String get recurringTitle => 'ആവർത്തിച്ചുള്ള\nഇടപാടുകൾ';

  @override
  String get recurringDesc => 'നിങ്ങളുടെ വരുമാനവും ചിലവുകളും സ്വയമേവയാക്കുക';

  @override
  String get addRule => 'റൂൾ ചേർക്കുക';

  @override
  String get noRulesYet => 'ഇതുവരെ ആവർത്തിച്ചുള്ള റൂളുകളൊന്നുമില്ല';

  @override
  String get createRulesToAutomate =>
      'വാടക, ശമ്പളം, എസ്ഐപി എന്നിവ സ്വയമേവയാക്കാൻ ഒരു റൂൾ നിർമ്മിക്കുക.';

  @override
  String get activeRules => 'സജീവ റൂളുകൾ';

  @override
  String get pausedRules => 'നിർത്തിവെച്ച റൂളുകൾ';

  @override
  String get editRule => 'റൂൾ തിരുത്തുക';

  @override
  String get ruleName => 'റൂൾ പേര്';

  @override
  String get ruleAmount => 'തുക';

  @override
  String get ruleFrequency => 'ആവർത്തനം';

  @override
  String get nextProcessDate => 'അടുത്ത പ്രോസസ് തീയതി';

  @override
  String get deleteRuleConfirm => 'റൂൾ ഇല്ലാതാക്കണോ?';

  @override
  String get deleteRuleBody =>
      'ഇത് ആവർത്തിച്ചുള്ള റൂൾ ഇല്ലാതാക്കും. ഇതുവഴി നിർമ്മിക്കപ്പെട്ട മുൻ ഇടപാടുകൾ ഇല്ലാതാകില്ല.';

  @override
  String get rulePaused => 'റൂൾ നിർത്തിവെച്ചു';

  @override
  String get ruleResumed => 'റൂൾ വീണ്ടും സജീവമാക്കി';

  @override
  String get ledgerTitle => 'കടങ്ങൾ (വാങ്ങൽ / നൽകൽ)';

  @override
  String get ledgerDesc =>
      'മറ്റുള്ളവർക്ക് നൽകിയതോ വാങ്ങിയതോ ആയ പണം ട്രാക്ക് ചെയ്യുക';

  @override
  String get addEntry => 'എൻട്രി ചേർക്കുക';

  @override
  String get noLedgerYet => 'ഇതുവരെ എൻട്രികളൊന്നുമില്ല';

  @override
  String get createLedgerToTrack =>
      'പണം കൊടുക്കൽ വാങ്ങലുകൾ രേഖപ്പെടുത്താൻ + ടാപ്പ് ചെയ്യുക';

  @override
  String get whoOwes => 'ആരാണ് തരാനുള്ളത്';

  @override
  String get youOweLabel => 'നിങ്ങൾ നൽകാനുള്ളത്';

  @override
  String get owesYouLabel => 'നിങ്ങൾക്ക് തരാനുള്ളത്';

  @override
  String get settledLabel => 'തീർത്തവ';

  @override
  String get settleUp => 'തീർപ്പാക്കുക';

  @override
  String get deleteEntryConfirm => 'എൻട്രി ഇല്ലാതാക്കണോ?';

  @override
  String get deleteEntryBody =>
      'ഇത് ഈ എൻട്രിയും അതിന്റെ എല്ലാ പേയ്മെന്റുകളും ഇല്ലാതാക്കും. ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';

  @override
  String get investmentsTitle => 'നിക്ഷേപങ്ങൾ';

  @override
  String get investmentsDesc =>
      'നിക്ഷേപങ്ങളുടെ മൂല്യം, അംശദായം, വളർച്ച എന്നിവ ട്രാക്ക് ചെയ്യുക';

  @override
  String get addInvestment => 'നിക്ഷേപം ചേർക്കുക';

  @override
  String get noInvestmentsYet => 'ഇതുവരെ നിക്ഷേപങ്ങളൊന്നുമില്ല';

  @override
  String get createInvestmentToTrack =>
      'നിങ്ങളുടെ എസ്ഐപികൾ, മ്യൂച്വൽ ഫണ്ടുകൾ, ഓഹരികൾ എന്നിവ ട്രാക്ക് ചെയ്യാൻ + ടാപ്പ് ചെയ്യുക.';

  @override
  String get portfolioValue => 'പോർട്ട്ഫോളിയോ മൂല്യം';

  @override
  String get totalInvested => 'ആകെ നിക്ഷേപിച്ചത്';

  @override
  String get gainLoss => 'ലാഭം / നഷ്ടം';

  @override
  String get deleteInvestmentConfirm => 'നിക്ഷേപം ഇല്ലാതാക്കണോ?';

  @override
  String get deleteInvestmentBody =>
      'ഇത് നിക്ഷേപ വിവരങ്ങളും അതിന്റെ എല്ലാ ഇടപാടുകളും ഇല്ലാതാക്കും.';

  @override
  String get troubleshootTitle => 'ട്രബിൾഷൂട്ട്';

  @override
  String get troubleshootDesc =>
      'ഡാറ്റാ വൈരുദ്ധ്യങ്ങളും നിർദ്ദേശങ്ങളിലെ തെറ്റുകളും പരിഹരിക്കുക.';

  @override
  String get rebuildSuggestions => 'നിർദ്ദേശങ്ങൾ പുതുക്കുക';

  @override
  String get rebuildSuggestionsDesc =>
      'നിങ്ങളുടെ മുൻ ചരിത്രമനുസരിച്ച് ഇടപാടുകളുടെ നിർദ്ദേശങ്ങൾ വീണ്ടും തയ്യാറാക്കുന്നു.';

  @override
  String get suggestionsRebuilt => 'നിർദ്ദേശങ്ങൾ വിജയകരമായി പുതുക്കി';

  @override
  String get cleanOrphans => 'അനാഥ ഡാറ്റകൾ ഒഴിവാക്കുക';

  @override
  String get cleanOrphansDesc =>
      'ഇല്ലാതാക്കിയ വിഭാഗങ്ങളുമായോ അക്കൗണ്ടുകളുമായോ ബന്ധപ്പെട്ട ഇടപാടുകൾ നീക്കം ചെയ്യുന്നു.';

  @override
  String get orphansCleaned => 'അനാഥ ഡാറ്റകൾ ഒഴിവാക്കി';

  @override
  String get clearCache => 'ആപ്പ് കാഷ് ഒഴിവാക്കുക';

  @override
  String get clearCacheDesc =>
      'താത്കാലിക ഫയലുകൾ ഒഴിവാക്കി ഡാറ്റാബേസ് സൂചികകൾ പുതുക്കുന്നു.';

  @override
  String get cacheCleared => 'കാഷ് വിജയകരമായി ഒഴിവാക്കി';

  @override
  String get aboutKuberHeader => 'കുബേറിനെക്കുറിച്ച്';

  @override
  String get aboutKuberDesc =>
      'ലളിതവും മനോഹരവുമായ ഒരു ഓഫ്‌ലൈൻ-ആദ്യ വ്യക്തിഗത സാമ്പത്തിക ട്രാക്കറാണ് കുബേർ.';

  @override
  String get privacyPromise => 'സ്വകാര്യതാ ഉറപ്പ്';

  @override
  String get privacyPromiseDesc =>
      'നിങ്ങളുടെ വിവരങ്ങൾ നിങ്ങളുടെ ഫോണിൽ സുരക്ഷിതമായിരിക്കും. യാതൊരുവിധ ട്രാക്കിംഗും പരസ്യങ്ങളും ഉണ്ടായിരിക്കുന്നതല്ല.';

  @override
  String get openSource => 'ഓപ്പൺ സോഴ്സ്';

  @override
  String get openSourceDesc =>
      'സുതാര്യവും സുരക്ഷിതവുമായ ഓപ്പൺ സാങ്കേതികവിദ്യയിൽ നിർമ്മിച്ചത്.';

  @override
  String get developerNote => 'ഡെവലപ്പർ കുറിപ്പ്';

  @override
  String get developerNoteDesc =>
      'വ്യക്തിഗത സാമ്പത്തിക ട്രാക്കിംഗ് എളുപ്പമാക്കാൻ നിർമ്മിച്ചതാണ് കുബേർ. ഉപയോഗിച്ചതിന് നന്ദി!';

  @override
  String get permissionsTitle => 'അനുമതികൾ';

  @override
  String get permissionsDesc => 'ആപ്പ് ആവശ്യപ്പെടുന്ന അനുമതികളും പരിധികളും.';

  @override
  String get storagePermission => 'സ്റ്റോറേജ് അനുമതി';

  @override
  String get storagePermissionDesc =>
      'ചിത്രങ്ങൾ, പിഡിഎഫ് ഫയലുകൾ ബാക്കപ്പ് എന്നിവ തിരഞ്ഞെടുക്കാൻ ആവശ്യമാണ്.';

  @override
  String get biometricPermission => 'ബയോമെട്രിക് പൂട്ട്';

  @override
  String get biometricPermissionDesc =>
      'ഓപ്ഷണൽ. വിരലടയാളം അല്ലെങ്കിൽ മുഖം തിരിച്ചറിയൽ വഴി ആപ്പ് പൂട്ടി വെക്കാൻ സഹായിക്കുന്നു.';

  @override
  String get networkPermission => 'നെറ്റ്‌വർക്ക് അനുമതി';

  @override
  String get networkPermissionDesc =>
      'ലൈവ് കറൻസി നിരക്കുകൾ അറിയാൻ മാത്രം ഉപയോഗിക്കുന്നു. ആപ്പ് 100% ഓഫ്‌ലൈനിലും പ്രവർത്തിക്കും.';

  @override
  String get feedbackTitle => 'അഭിപ്രായങ്ങൾ';

  @override
  String get feedbackDesc =>
      'പ്രശ്നങ്ങൾ അറിയിക്കുകയോ പുതിയ ഫീച്ചറുകൾ നിർദ്ദേശിക്കുകയോ ചെയ്യുക!';

  @override
  String get feedbackType => 'അഭിപ്രായ വിഭാഗം';

  @override
  String get feedbackTypeBug => 'ബഗ് റിപ്പോർട്ട്';

  @override
  String get feedbackTypeFeature => 'പുതിയ നിർദ്ദേശം';

  @override
  String get feedbackTypeOther => 'മറ്റു വിവരങ്ങൾ';

  @override
  String get feedbackMessage => 'നിങ്ങളുടെ സന്ദേശം';

  @override
  String get feedbackMessageHint =>
      'പ്രശ്നം അല്ലെങ്കിൽ നിർദ്ദേശം വിശദമായി എഴുതുക...';

  @override
  String get submitFeedback => 'അഭിപ്രായം അറിയിക്കുക';

  @override
  String get feedbackThankYou => 'നിങ്ങളുടെ വിലയേറിയ അഭിപ്രായത്തിന് നന്ദി!';

  @override
  String get feedbackMessageRequired => 'ദയവായി ആദ്യം നിങ്ങളുടെ സന്ദേശം എഴുതുക';

  @override
  String get dataManagementTitle => 'ഡാറ്റ മാനേജ്മെന്റ്';

  @override
  String get dataManagementDesc =>
      'ഡാറ്റ എക്സ്പോർട്ട്, ഇമ്പോർട്ട്, നിയന്ത്രണം എന്നിവ.';

  @override
  String get exportData => 'ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get exportDataDesc =>
      'ഇടപാടുകളും അക്കൗണ്ട് വിവരങ്ങളും JSON ഫയലിലേക്ക് മാറ്റുക.';

  @override
  String get importData => 'ഡാറ്റ ഇമ്പോർട്ട് ചെയ്യുക';

  @override
  String get importDataDesc =>
      'മുമ്പ് എക്സ്പോർട്ട് ചെയ്ത JSON ബാക്കപ്പ് ഫയൽ തിരികെ ലോഡ് ചെയ്യുക.';

  @override
  String get clearAllData => 'ഡാറ്റകൾ പൂർണ്ണമായി ഒഴിവാക്കുക';

  @override
  String get clearAllDataDesc =>
      'ഫോണിലുള്ള എല്ലാ ഇടപാടുകളും വിവരങ്ങളും എന്നെന്നേക്കുമായി ഇല്ലാതാക്കുന്നു. ഇത് തിരികെ ലഭിക്കില്ല.';

  @override
  String get clearDataConfirm => 'എല്ലാ വിവരങ്ങളും ഒഴിവാക്കണോ?';

  @override
  String get clearDataConfirmBody =>
      'ഇത് നിങ്ങളുടെ എല്ലാ ഇടപാടുകളും അക്കൗണ്ടുകളും ക്രമീകരണങ്ങളും എന്നെന്നേക്കുമായി ഇല്ലാതാക്കും. ഇത് തിരികെ ലഭിക്കില്ല. സ്ഥിരീകരിക്കാൻ DELETE എന്ന് എഴുതുക.';

  @override
  String get backupTitle => 'ബാക്കപ്പ്';

  @override
  String get backupDesc =>
      'സ്വയമേവയോ അല്ലെങ്കിൽ നേരിട്ടോ വിവരങ്ങൾ ബാക്കപ്പ് ചെയ്യുക.';

  @override
  String get lentBorrowedTitle => 'നൽകിയത് &\nവാങ്ങിയത്';

  @override
  String get noLedgerEntries => 'ഇതുവരെ ലെഡ്ജർ എൻട്രികളില്ല';

  @override
  String get ledgerEmptyDesc =>
      'കൊടുക്കലോ വാങ്ങലോ രേഖപ്പെടുത്താൻ + ടാപ്പ് ചെയ്യുക';

  @override
  String get settledUpper => 'സെറ്റിൽ ചെയ്തു';

  @override
  String get lentLabel => 'കടം നൽകിയത്';

  @override
  String get borrowedLabel => 'കടം വാങ്ങിയത്';

  @override
  String get editEntry => 'എൻട്രി എഡിറ്റ് ചെയ്യുക';

  @override
  String get newEntry => 'പുതിയ എൻട്രി';

  @override
  String get amountLent => 'നൽകിയ തുക';

  @override
  String get amountBorrowed => 'വാങ്ങിയ തുക';

  @override
  String get personLabel => 'വ്യക്തി';

  @override
  String get whoHint => 'ആര്?';

  @override
  String get fromAccountLabel => 'ഏത് അക്കൗണ്ടിൽ നിന്ന്';

  @override
  String get toAccountLabel => 'ഏത് അക്കൗണ്ടിലേക്ക്';

  @override
  String get dateLabel => 'തീയതി';

  @override
  String get lentOn => 'നൽകിയ തീയതി';

  @override
  String get borrowedOn => 'വാങ്ങിയ തീയതി';

  @override
  String get expectedReturn => 'തിരികെ പ്രതീക്ഷിക്കുന്നത്';

  @override
  String get ledgerNotesHint => 'സന്ദർഭം, IOU റഫറൻസ്, എന്തും';

  @override
  String get addToLedger => 'ലെഡ്ജറിലേക്ക് ചേർക്കുക';

  @override
  String get accountTitle => 'അക്കൗണ്ട്';

  @override
  String get expectedOn => 'പ്രതീക്ഷിക്കുന്ന തീയതി';

  @override
  String get lentTransaction => 'കടം നൽകിയ ഇടപാട്';

  @override
  String get borrowedTransaction => 'കടം വാങ്ങിയ ഇടപാട്';

  @override
  String get addPayment => 'പേയ്മെന്റ് ചേർക്കുക';

  @override
  String get markSettled => 'സെറ്റിൽ ചെയ്തതായി അടയാളപ്പെടുത്തുക';

  @override
  String get repaymentProgress => 'തിരിച്ചടവ് പുരോഗതി';

  @override
  String get dueDate => 'അവസാന തീയതി';

  @override
  String get markSettledConfirm => 'സെറ്റിൽ ചെയ്തതായി അടയാളപ്പെടുത്തണോ?';

  @override
  String get markSettledBody =>
      'ഇത് ബാക്കിയുള്ള തുക പേയ്‌മെൻ്റായി രേഖപ്പെടുത്തുകയും ഈ എൻട്രി സെറ്റിൽ ചെയ്തതായി അടയാളപ്പെടുത്തുകയും ചെയ്യും.';

  @override
  String get settleLabel => 'സെറ്റിൽ ചെയ്യുക';

  @override
  String get deleteLedgerConfirm => 'ലെഡ്ജർ എൻട്രി ഇല്ലാതാക്കണോ?';

  @override
  String get deleteLedgerBody =>
      'ഇത് ഈ എൻട്രിയും ലിങ്ക് ചെയ്‌തിരിക്കുന്ന എല്ലാ ഇടപാടുകളും ഇല്ലാതാക്കും. ഇത് പഴയപടിയാക്കാനാകില്ല.';

  @override
  String get paymentReceived => 'പേയ്മെന്റ് ലഭിച്ചു';

  @override
  String get paymentMade => 'പേയ്മെന്റ് നൽകി';

  @override
  String get recordPayment => 'പേയ്‌മെന്റ് രേഖപ്പെടുത്തുക';

  @override
  String get recordPaymentUpper => 'പേയ്‌മെന്റ് രേഖപ്പെടുത്തുക';

  @override
  String get netPosition => 'നെറ്റ് പൊസിഷൻ';

  @override
  String get youWillReceive => 'നിങ്ങൾക്ക് ലഭിക്കും';

  @override
  String get youOwe => 'നിങ്ങൾ നൽകാനുള്ളത്';

  @override
  String get noDueDate => 'അവസാന തീയതിയില്ല';

  @override
  String get lentUpper => 'കടം നൽകിയത്';

  @override
  String get borrowedUpper => 'കടം വാങ്ങിയത്';

  @override
  String ledgerDuplicateWarningLent(String person) {
    return '$person എന്നയാൾക്ക് കടം നൽകിയ സജീവമായ ഒരു എൻട്രി ഇതിനകം തന്നെയുണ്ട്. പുതിയ ഒരെണ്ണം സൃഷ്ടിക്കണമെന്ന് നിങ്ങൾക്ക് ഉറപ്പാണോ?';
  }

  @override
  String ledgerDuplicateWarningBorrow(String person) {
    return '$person എന്നയാളിൽ നിന്ന് കടം വാങ്ങിയ സജീവമായ ഒരു എൻട്രി ഇതിനകം തന്നെയുണ്ട്. പുതിയ ഒരെണ്ണം സൃഷ്ടിക്കണമെന്ന് നിങ്ങൾക്ക് ഉറപ്പാണോ?';
  }

  @override
  String get ledgerEvensOut => 'തുല്യമായി';

  @override
  String get ledgerInYourFavour => 'നിങ്ങൾക്ക് അനുകൂലമായി';

  @override
  String get ledgerOwedToOthers => 'മറ്റുള്ളവർക്ക് നൽകാനുള്ളത്';

  @override
  String ledgerActiveEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count സജീവ എൻട്രികൾ',
      one: '1 സജീവ എൻട്രി',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNoOne => 'ആരുമില്ല';

  @override
  String ledgerAcrossPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ആളുകൾക്കിടയിൽ',
      one: '1 വ്യക്തിക്കിടയിൽ',
    );
    return '$_temp0';
  }

  @override
  String settledOnUpper(String date) {
    return '$date-ൽ സെറ്റിൽ ചെയ്തു';
  }

  @override
  String dueOnUpper(String date) {
    return 'അവസാന തീയതി $date';
  }

  @override
  String get overdueLower => 'കാലാവധി കഴിഞ്ഞത്';

  @override
  String pctReceived(String pct) {
    return '$pct% ലഭിച്ചു';
  }

  @override
  String pctPaidBack(String pct) {
    return '$pct% തിരികെ നൽകി';
  }

  @override
  String amountRemaining(String amount) {
    return '$amount ബാക്കിയുണ്ട്';
  }

  @override
  String errorWithDetails(String details) {
    return 'പിശക്: $details';
  }

  @override
  String get notSetTapToAdd => 'സജ്ജീകരിച്ചിട്ടില്ല · ചേർക്കാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ദിവസങ്ങൾക്കുള്ളിൽ',
      one: '1 ദിവസത്തിനുള്ളിൽ',
    );
    return '$_temp0';
  }

  @override
  String createdOnUpper(String date) {
    return '$date-ൽ നിർമ്മിച്ചു';
  }

  @override
  String get noInvestments => 'നിക്ഷേപങ്ങളൊന്നും ട്രാക്ക് ചെയ്തിട്ടില്ല';

  @override
  String get investmentsEmptyDesc =>
      'നിങ്ങളുടെ ആദ്യ നിക്ഷേപം ചേർക്കാൻ + ടാപ്പ് ചെയ്യുക';

  @override
  String get allInvestmentsUpper => 'എല്ലാ നിക്ഷേപങ്ങളും';

  @override
  String get invTypeSip => 'SIP';

  @override
  String get invTypeMutualFund => 'മ്യൂച്വൽ ഫണ്ട്';

  @override
  String get invTypeStocks => 'സ്റ്റോക്കുകൾ';

  @override
  String get invTypeGold => 'സ്വർണ്ണം';

  @override
  String get invTypeFd => 'FD';

  @override
  String get invTypeRd => 'RD';

  @override
  String get invTypeCrypto => 'ക്രിപ്റ്റോ';

  @override
  String get invTypeTrading => 'ട്രേഡിംഗ്';

  @override
  String get invTypeRealEstate => 'റിയൽ എസ്റ്റേറ്റ്';

  @override
  String get invTypeEtf => 'ETF';

  @override
  String get invTypeBonds => 'ബോണ്ടുകൾ';

  @override
  String get invTypeCollectible => 'ശേഖരണ വസ്തു';

  @override
  String get invTypeOther => 'മറ്റുള്ളവ';

  @override
  String get editInvestment => 'നിക്ഷേപം എഡിറ്റ് ചെയ്യുക';

  @override
  String get newInvestment => 'പുതിയ നിക്ഷേപം';

  @override
  String get investmentName => 'നിക്ഷേപത്തിന്റെ പേര്';

  @override
  String get valueLabel => 'മൂല്യം';

  @override
  String get totalInvestedInclNew =>
      'ആകെ നിക്ഷേപിച്ചത് (പുതിയ സംഭാവന ഉൾപ്പെടെ)';

  @override
  String get investedAmountInitial => 'നിക്ഷേപിച്ച തുക (പ്രാരംഭം)';

  @override
  String get autoDebitSip => 'ഓട്ടോ-ഡെബിറ്റ് SIP';

  @override
  String get enableAutoDebitSip => 'ഓട്ടോ-ഡെബിറ്റ് SIP പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get automateMonthlyContrib =>
      'നിങ്ങളുടെ പ്രതിമാസ സംഭാവനകൾ ഓട്ടോമേറ്റ് ചെയ്യുക';

  @override
  String get monthlySipAmount => 'പ്രതിമാസ SIP തുക';

  @override
  String get sipDate => 'SIP തീയതി';

  @override
  String get debitedFrom => 'ഇതിൽ നിന്ന് ഡെബിറ്റ് ചെയ്യും';

  @override
  String get optionalContext => 'ഓപ്ഷണൽ സന്ദർഭം';

  @override
  String get addContribution => 'സംഭാവന ചേർക്കുക';

  @override
  String get updateValue => 'മൂല്യം അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get investedUpper => 'നിക്ഷേപിച്ചത്';

  @override
  String get currentUpper => 'നിലവിലെ';

  @override
  String get gainLossUpper => 'ലാഭം/നഷ്ടം';

  @override
  String get sipConfiguration => 'SIP കോൺഫിഗറേഷൻ';

  @override
  String get monthlySip => 'പ്രതിമാസ SIP';

  @override
  String get strategyNotes => 'സ്ട്രാറ്റജി നോട്ടുകൾ';

  @override
  String get contributionHistory => 'സംഭാവനകളുടെ ചരിത്രം';

  @override
  String get noContributions => 'സംഭാവനകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല';

  @override
  String get updateCurrentValue => 'നിലവിലെ മൂല്യം അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get updateLabel => 'അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get contributionLabel => 'സംഭാവന';

  @override
  String get recordContributionUpper => 'സംഭാവന രേഖപ്പെടുത്തുക';

  @override
  String get noteOptionalUpper => 'കുറിപ്പ് (ഓപ്ഷണൽ)';

  @override
  String get assetAllocation => 'അസറ്റ് അലോക്കേഷൻ';

  @override
  String get investmentNameHint => 'ഉദാ. Nifty 50 Index Fund';

  @override
  String sipAmountPrefix(String amount) {
    return 'SIP $amount';
  }

  @override
  String monthlySipValue(String amount, String day) {
    return '$day-ാം തീയതി $amount';
  }

  @override
  String get addRecurring => 'റിക്കറിംഗ് ചേർക്കുക';

  @override
  String get noRecurring => 'റിക്കറിംഗ് ഇടപാടുകളൊന്നുമില്ല';

  @override
  String get recurringEmptyDesc =>
      'സബ്സ്ക്രിപ്ഷനുകളും ആവർത്തിച്ചുള്ള പേയ്‌മെന്റുകളും ഓട്ടോമേറ്റ് ചെയ്യുക';

  @override
  String get rulesUpper => 'നിയമങ്ങൾ';

  @override
  String get recentlyProcessed => 'അടുത്തിടെ പ്രോസസ്സ് ചെയ്തവ';

  @override
  String get freqDaily => 'ദിവസവും';

  @override
  String get freqWeekly => 'ആഴ്ചതോറും';

  @override
  String get freqBiweekly => 'രണ്ടാഴ്ചയിലൊരിക്കൽ';

  @override
  String get freqMonthly => 'പ്രതിമാസം';

  @override
  String get freqQuarterly => 'ത്രൈമാസികം';

  @override
  String get freqYearly => 'വർഷം തോറും';

  @override
  String get freqCustom => 'കസ്റ്റം';

  @override
  String get editRecurring => 'റിക്കറിംഗ് എഡിറ്റ് ചെയ്യുക';

  @override
  String get newRecurring => 'പുതിയ റിക്കറിംഗ്';

  @override
  String get transactionLabel => 'ഇടപാട്';

  @override
  String get amountTitle => 'തുക';

  @override
  String get recurringNameHint => 'പേര് (ഉദാ. Netflix, വാടക)';

  @override
  String get whereLabel => 'എവിടെ';

  @override
  String get scheduleSublabel => 'ഈ ഇടപാട് എപ്പോൾ ആവർത്തിക്കും';

  @override
  String get frequencyLabel => 'ആവൃത്തി';

  @override
  String get everyLabel => 'ഓരോ';

  @override
  String get daysLabel => 'ദിവസങ്ങൾ';

  @override
  String get startsOn => 'ആരംഭിക്കുന്നത്';

  @override
  String get startDate => 'ആരംഭിക്കുന്ന തീയതി';

  @override
  String get endsLabel => 'അവസാനിക്കുന്നു';

  @override
  String get neverLabel => 'ഒരിക്കലുമില്ല';

  @override
  String get afterN => 'N-ന് ശേഷം';

  @override
  String get onDate => 'ഈ തീയതിയിൽ';

  @override
  String get afterLabel => 'ശേഷം';

  @override
  String get occurrencesLabel => 'തവണ';

  @override
  String get endDate => 'അവസാനിക്കുന്ന തീയതി';

  @override
  String get recurringNotesHint => 'ഓപ്ഷണൽ · സന്ദർഭം, റഫറൻസ്, എന്തും';

  @override
  String get saveRecurring => 'റിക്കറിംഗ് സേവ് ചെയ്യുക';

  @override
  String get nextOccurrenceLabel => 'അടുത്ത തവണ';

  @override
  String get cadenceDaily => 'പിന്നെ എല്ലാ ദിവസവും';

  @override
  String get cadenceWeekly => 'പിന്നെ എല്ലാ ആഴ്ചയും';

  @override
  String get cadenceBiweekly => 'പിന്നെ ഓരോ 2 ആഴ്ചയിലും';

  @override
  String get cadenceMonthly => 'പിന്നെ എല്ലാ മാസവും';

  @override
  String get cadenceYearly => 'പിന്നെ എല്ലാ വർഷവും';

  @override
  String get cadenceCustom => 'പിന്നെ ഓരോ കസ്റ്റം ഇടവേളയിലും';

  @override
  String get activeUpper => 'സജീവം';

  @override
  String get activeCustomUpper => 'സജീവം • കസ്റ്റം';

  @override
  String get pausedUpper => 'താൽക്കാലികമായി നിർത്തിയിരിക്കുന്നു';

  @override
  String freqEveryNDays(String count) {
    return 'ഓരോ $count ദിവസത്തിലും';
  }

  @override
  String recurringAmountLabel(String type) {
    return 'റിക്കറിംഗ് $type തുക';
  }

  @override
  String get frequencyUpper => 'ആവൃത്തി';

  @override
  String get deleteAutomationConfirm => 'ഓട്ടോമേഷൻ ഇല്ലാതാക്കണോ?';

  @override
  String deleteAutomationBody(String name) {
    return '\"$name\"-നായുള്ള റിക്കറിംഗ് നിയമം ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';
  }

  @override
  String get monthlyAutomationCost => 'പ്രതിമാസ ഓട്ടോമേഷൻ ചിലവ്';

  @override
  String get upcomingCharges => 'വരാനിരിക്കുന്ന നിരക്കുകൾ';

  @override
  String get todayUpper => 'ഇന്ന്';

  @override
  String get tomorrowUpper => 'നാളെ';

  @override
  String get yesterdayUpper => 'ഇന്നലെ';

  @override
  String inDaysUpper(String count) {
    return '$count ദിവസങ്ങൾക്കുള്ളിൽ';
  }

  @override
  String get nextChargeLabel => 'അടുത്ത നിരക്ക്';

  @override
  String get backingUpAuto => 'യാന്ത്രികമായി ബാക്കപ്പ് ചെയ്യുന്നു';

  @override
  String get processingRecurring => 'റിക്കറിംഗ് പ്രോസസ്സ് ചെയ്യുന്നു';

  @override
  String get savingCopyToFolder =>
      'നിങ്ങൾ തിരഞ്ഞെടുത്ത ഫോൾഡറിലേക്ക് ഒരു പകർപ്പ് സംരക്ഷിക്കുന്നു.';

  @override
  String get creatingMissedTxns => 'നഷ്‌ടമായ ഇടപാടുകൾ സൃഷ്ടിക്കുന്നു.';

  @override
  String get folderUpper => 'ഫോൾഡർ';

  @override
  String get processedUpper => 'പ്രോസസ്സ് ചെയ്തു';

  @override
  String get selectedLabel => 'തിരഞ്ഞെടുത്തത്';

  @override
  String nTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഇടപാടുകൾ',
      one: '1 ഇടപാട്',
    );
    return '$_temp0';
  }

  @override
  String get networkUpper => 'നെറ്റ്‌വർക്ക്';

  @override
  String get localOnly => 'ലോക്കൽ മാത്രം';

  @override
  String get transactionHistory => 'ഇടപാട് ചരിത്രം';

  @override
  String errorLoadingHistory(String details) {
    return 'ചരിത്രം ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $details';
  }

  @override
  String get recurringHistoryEmptyDesc =>
      'ഈ ഓട്ടോമേഷൻ സൃഷ്ടിക്കുന്ന ഇടപാടുകൾ ഇവിടെ ദൃശ്യമാകും.';

  @override
  String get todayLower => 'ഇന്ന്';

  @override
  String get tomorrowLower => 'നാളെ';

  @override
  String get betaBadge => 'ബീറ്റ';

  @override
  String get noCategories => 'ഇതുവരെ വിഭാഗങ്ങളില്ല';

  @override
  String get categoriesEmptyDesc =>
      'നിങ്ങളുടെ ചിലവുകൾ ക്രമീകരിക്കാൻ വിഭാഗങ്ങൾ ഉണ്ടാക്കുക';

  @override
  String get addCategory => 'വിഭാഗം ചേർക്കുക';

  @override
  String get searchCategoriesHint => 'വിഭാഗങ്ങളും ഗ്രൂപ്പുകളും തിരയുക...';

  @override
  String get addNew => 'പുതിയത് ചേർക്കുക';

  @override
  String get addCategoryDesc =>
      'കൂടുതൽ നന്നായി ട്രാക്ക് ചെയ്യാൻ നിങ്ങളുടെ ഇടപാടുകൾ തരംതിരിക്കുക';

  @override
  String get addGroup => 'ഗ്രൂപ്പ് ചേർക്കുക';

  @override
  String get editGroup => 'ഗ്രൂപ്പ് എഡിറ്റ് ചെയ്യുക';

  @override
  String get categoryGroupSubtitle => 'വിഭാഗം ഗ്രൂപ്പ്';

  @override
  String get groupNameHint => 'ഗ്രൂപ്പിന്റെ പേര് (ഉദാ. ഭക്ഷണം, ഗതാഗതം)';

  @override
  String get deleteGroupConfirm => 'ഗ്രൂപ്പ് ഇല്ലാതാക്കണോ?';

  @override
  String deleteGroupBody(String name) {
    return '\"$name\" ലെ വിഭാഗങ്ങൾ \"ഗ്രൂപ്പ് ചെയ്യാത്തവ\" എന്നതിലേക്ക് മാറ്റും.';
  }

  @override
  String get categoryDetail => 'വിഭാഗത്തിന്റെ വിശദാംശങ്ങൾ';

  @override
  String get groupUpper => 'ഗ്രൂപ്പ്';

  @override
  String get typeUpper => 'തരം';

  @override
  String get incomeAndExpense => 'വരുമാനവും ചിലവും';

  @override
  String get cannotDeleteCategory => 'വിഭാഗം ഇല്ലാതാക്കാൻ കഴിയില്ല';

  @override
  String get cannotDeleteCategoryBody =>
      'ഈ വിഭാഗവുമായി ഇടപാടുകൾ ബന്ധിപ്പിച്ചിട്ടുണ്ട്. ഈ വിഭാഗം ഇല്ലാതാക്കാൻ, ആദ്യം ബന്ധിപ്പിച്ച ഇടപാടുകൾ ഇല്ലാതാക്കുക.';

  @override
  String get editCategory => 'വിഭാഗം എഡിറ്റ് ചെയ്യുക';

  @override
  String get newCategory => 'പുതിയ വിഭാഗം';

  @override
  String get optionalLabel => 'ഓപ്ഷണൽ';

  @override
  String get appearance => 'രൂപഭാവം';

  @override
  String get bothLabel => 'രണ്ടും';

  @override
  String get saveCategory => 'വിഭാഗം സേവ് ചെയ്യുക';

  @override
  String get categoryUpdated => 'വിഭാഗം അപ്‌ഡേറ്റ് ചെയ്തു';

  @override
  String get categoryAdded => 'വിഭാഗം ചേർത്തു';

  @override
  String get categoryNameLabel => 'വിഭാഗത്തിന്റെ പേര്';

  @override
  String get livePreview => 'ലൈവ് പ്രിവ്യൂ';

  @override
  String get selectGroup => 'ഗ്രൂപ്പ് തിരഞ്ഞെടുക്കുക';

  @override
  String get groupNameShortHint => 'ഗ്രൂപ്പിന്റെ പേര്...';

  @override
  String get addNewGroup => 'പുതിയ ഗ്രൂപ്പ് ചേർക്കുക';

  @override
  String get noBudgetSet => 'ബജറ്റ് സെറ്റ് ചെയ്തിട്ടില്ല';

  @override
  String get categoriesTitle => 'വിഭാഗങ്ങൾ\nമാനേജ് ചെയ്യുക';

  @override
  String noCategoryMatches(String query) {
    return '\"$query\" എന്നതുമായി വിഭാഗങ്ങളോ ഗ്രൂപ്പുകളോ പൊരുത്തപ്പെടുന്നില്ല.';
  }

  @override
  String get deleteCategoryConfirm => 'വിഭാഗം ഇല്ലാതാക്കണോ?';

  @override
  String deleteCategoryBody(String name) {
    return '\"$name\" ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';
  }

  @override
  String get categoryNameHint => 'ഉദാ. പലചരക്ക്, വാടക, ശമ്പളം';

  @override
  String get tagsTitle => 'ടാഗുകൾ\nമാനേജ് ചെയ്യുക';

  @override
  String get tagsHeaderDesc =>
      'കസ്റ്റം ലേബലുകൾ ഉപയോഗിച്ച് ഇടപാടുകൾ ക്രമീകരിക്കുക.';

  @override
  String get addTag => 'ടാഗ് ചേർക്കുക';

  @override
  String get noTags => 'ഇതുവരെ ടാഗുകളില്ല';

  @override
  String get tagsEmptyDesc =>
      'പ്രത്യേക ചിലവുകൾ ട്രാക്ക് ചെയ്യാൻ ഹാഷ്‌ടാഗുകൾ ഉണ്ടാക്കുക.';

  @override
  String get disabledLabel => 'പ്രവർത്തനരഹിതം';

  @override
  String get noTransactions => 'ഇടപാടുകൾ ഇല്ല';

  @override
  String get newTag => 'പുതിയ ടാഗ്';

  @override
  String get updateTag => 'ടാഗ് അപ്‌ഡേറ്റ് ചെയ്യുക';

  @override
  String get createTag => 'ടാഗ് ഉണ്ടാക്കുക';

  @override
  String get enableLabel => 'പ്രവർത്തിപ്പിക്കുക';

  @override
  String get disableLabel => 'പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get deleteTagConfirm => 'ടാഗ് ഇല്ലാതാക്കണോ?';

  @override
  String deleteTagBody(String name) {
    return '\"#$name\" ടാഗ് ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';
  }

  @override
  String get selectTags => 'ടാഗുകൾ തിരഞ്ഞെടുക്കുക';

  @override
  String get tagNameHint => 'ഉദാഹരണം: വീക്കെൻഡ്, ട്രിപ്പ്-ടു-ഗോവ';

  @override
  String get searchOrCreateTagHint => 'തിരയുക അല്ലെങ്കിൽ ടാഗ് ഉണ്ടാക്കുക...';

  @override
  String get tagDisabledMessage =>
      'ടാഗ് പ്രവർത്തനരഹിതമാണ്. കൂടുതൽ → ടാഗുകൾ എന്നതിൽ നിന്ന് ഇത് പ്രവർത്തിപ്പിക്കുക.';

  @override
  String get exportHistory => 'ചരിത്രം എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get exportAnalytics => 'അനലിറ്റിക്സ് എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get selectFormat => 'ഫോർമാറ്റ് തിരഞ്ഞെടുക്കുക';

  @override
  String get formatUpper => 'ഫോർമാറ്റ്';

  @override
  String get spreadsheetLabel => 'സ്പ്രെഡ്ഷീറ്റ്';

  @override
  String get documentLabel => 'ഡോക്യുമെന്റ്';

  @override
  String get pdfDocument => 'PDF ഡോക്യുമെന്റ്';

  @override
  String get pdfDocumentDesc =>
      'ഹൈ-ക്വാളിറ്റി പ്രിന്റിംഗിനുള്ള യൂണിവേഴ്സൽ ഫോർമാറ്റ്.';

  @override
  String get generateReport => 'റിപ്പോർട്ട് ഉണ്ടാക്കുക';

  @override
  String get applyCurrentFilters => 'നിലവിലെ ഫിൽറ്ററുകൾ ഉപയോഗിക്കുക';

  @override
  String get applyFiltersDesc =>
      'ചരിത്ര പേജിലെ സജീവ ഫിൽറ്ററുകൾ ഉപയോഗിച്ച് റിപ്പോർട്ട് ഉണ്ടാക്കുക.';

  @override
  String get periodAllTime => 'എല്ലായ്പ്പോഴും';

  @override
  String get selectedPeriod => 'തിരഞ്ഞെടുത്ത കാലയളവ്';

  @override
  String get analyticsDateFilterInfo =>
      'നിങ്ങളുടെ നിലവിലെ അനലിറ്റിക്സ് കാഴ്ചയിൽ നിന്നുള്ള തീയതി ഫിൽറ്ററുകൾ ഈ റിപ്പോർട്ടിൽ സ്വയമേവ ഉപയോഗിക്കുന്നു.';

  @override
  String get exportSuccessful => 'എക്സ്പോർട്ട് വിജയകരം';

  @override
  String get reportReady => 'നിങ്ങളുടെ റിപ്പോർട്ട് തയ്യാറാണ്.';

  @override
  String get openFile => 'ഫയൽ തുറക്കുക';

  @override
  String get savingEllipsis => 'സേവ് ചെയ്യുന്നു...';

  @override
  String get saveToFolder => 'ഫോൾഡറിലേക്ക് സേവ് ചെയ്യുക';

  @override
  String get shareLabel => 'ഷെയർ ചെയ്യുക';

  @override
  String get noAppToOpen => 'ഈ ഫയൽ തരം തുറക്കാൻ ആപ്പുകളൊന്നും കണ്ടെത്തിയില്ല.';

  @override
  String get fileSaved => 'ഫയൽ വിജയകരമായി സേവ് ചെയ്തു.';

  @override
  String couldNotShareFile(String details) {
    return 'ഫയൽ ഷെയർ ചെയ്യാൻ കഴിഞ്ഞില്ല: $details';
  }

  @override
  String get exportFailed => 'എക്സ്പോർട്ട് പരാജയപ്പെട്ടു';

  @override
  String get tryAgain => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get exportGenerateFailed =>
      'ഫയൽ ഉണ്ടാക്കാൻ കഴിഞ്ഞില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get failedToSaveFile => 'ഫയൽ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല.';

  @override
  String get chartsTitle => 'ചാർട്ടുകൾ';

  @override
  String get chartsSubtitle =>
      'കാലക്രമേണ നിങ്ങളുടെ ചിലവ് രീതികൾ വിഷ്വലൈസ് ചെയ്യുക.';

  @override
  String get wipBadge => 'WIP';

  @override
  String get failedToLoadData => 'ഡാറ്റ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല';

  @override
  String get noDataForPeriod => 'ഈ കാലയളവിൽ ഡാറ്റയില്ല';

  @override
  String get tapBarForDetails => 'വിശദാംശങ്ങൾ കാണാൻ ഒരു ബാറിൽ ടാപ്പ് ചെയ്യുക';

  @override
  String get incomeUpper => 'വരുമാനം';

  @override
  String get expenseUpper => 'ചിലവ്';

  @override
  String get netUpper => 'നെറ്റ്';

  @override
  String get noExpenseBreakdown => 'ചിലവ് വിവരങ്ങൾ ലഭ്യമല്ല.';

  @override
  String get byCategoryUpper => 'വിഭാഗം അനുസരിച്ച്';

  @override
  String get faqTitle => 'പതിവ് ചോദ്യങ്ങൾ';

  @override
  String get faqAddTxnQ => 'ഞാൻ എങ്ങനെ ഒരു ഇടപാട് ചേർക്കും?';

  @override
  String get faqAddTxnA =>
      'ഒരു പുതിയ ഇടപാട് ചേർക്കാൻ താഴെ വലതുവശത്തുള്ള + ബട്ടൺ ടാപ്പ് ചെയ്യുക. തുക പൂരിപ്പിക്കുക, ഒരു വിഭാഗവും അക്കൗണ്ടും തിരഞ്ഞെടുക്കുക, തുടർന്ന് സേവ് ചെയ്യുക.';

  @override
  String get faqAccountsQ => 'ഞാൻ എങ്ങനെ അക്കൗണ്ടുകൾ മാനേജ് ചെയ്യും?';

  @override
  String get faqAccountsA =>
      'നിങ്ങളുടെ എല്ലാ വാലറ്റുകളും ബാങ്ക് അക്കൗണ്ടുകളും കാണാൻ കൂടുതൽ → അക്കൗണ്ടുകൾ എന്നതിലേക്ക് പോകുക. നിങ്ങൾക്ക് അവിടെ നിന്ന് പുതിയ അക്കൗണ്ടുകൾ ചേർക്കുകയോ നിലവിലുള്ളവ എഡിറ്റ് ചെയ്യുകയോ ചെയ്യാം.';

  @override
  String get faqTransfersQ => 'ട്രാൻസ്ഫറുകൾ എങ്ങനെ പ്രവർത്തിക്കുന്നു?';

  @override
  String get faqTransfersA =>
      'ഒരു ഇടപാട് ചേർക്കുമ്പോൾ, തരം ആയി \"ട്രാൻസ്ഫർ\" തിരഞ്ഞെടുക്കുക. ഉറവിടവും ലക്ഷ്യസ്ഥാനവും അക്കൗണ്ടുകൾ തിരഞ്ഞെടുക്കുക, അവയ്ക്കിടയിൽ തുക മാറ്റപ്പെടും.';

  @override
  String get faqCategoriesQ => 'എനിക്ക് വിഭാഗങ്ങൾ കസ്റ്റമൈസ് ചെയ്യാൻ കഴിയുമോ?';

  @override
  String get faqCategoriesA =>
      'അതെ! എല്ലാ വിഭാഗങ്ങളും കാണാൻ കൂടുതൽ → വിഭാഗങ്ങൾ എന്നതിലേക്ക് പോകുക. ഡിഫോൾട്ട് വിഭാഗങ്ങൾ ഇല്ലാതാക്കാൻ കഴിയില്ല, എന്നാൽ നിങ്ങൾക്ക് നിങ്ങളുടേതായ കസ്റ്റം വിഭാഗങ്ങൾ ചേർക്കാം.';

  @override
  String get dataExportTitle => 'ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുക';

  @override
  String get backupUpper => 'ബാക്കപ്പ്';

  @override
  String get exportCsvDesc =>
      'ഇടപാടുകൾ, വിഭാഗങ്ങൾ, അക്കൗണ്ടുകൾ, ടാഗുകൾ എന്നിവ എക്സ്പോർട്ട് ചെയ്യുന്നു. ആവർത്തിക്കുന്ന ഓട്ടോമേഷനുകൾ, ബജറ്റുകൾ, ലോണുകൾ, നിക്ഷേപങ്ങൾ അല്ലെങ്കിൽ അറ്റാച്ച്‌മെന്റുകൾ ഉൾപ്പെടുന്നില്ല.';

  @override
  String get exportJsonDesc =>
      'സമ്പൂർണ്ണ ആപ്പ് ബാക്കപ്പ് (അറ്റാച്ച്‌മെന്റുകൾ ഒഴികെ). ഒരു പുതിയ ഉപകരണത്തിലോ വീണ്ടും ഇൻസ്റ്റാൾ ചെയ്തതിന് ശേഷമോ നിങ്ങളുടെ എല്ലാ ഡാറ്റയും റീസ്റ്റോർ ചെയ്യാൻ ഉപയോഗിക്കാം.';

  @override
  String get fileReady => 'നിങ്ങളുടെ ഫയൽ തയ്യാറാണ്.';

  @override
  String get saveACopy => 'ഒരു പകർപ്പ് സേവ് ചെയ്യുക';

  @override
  String get dataImportTitle => 'ഡാറ്റ ഇംപോർട്ട് ചെയ്യുക';

  @override
  String get selectFileImport => 'ഫയൽ തിരഞ്ഞെടുത്ത് ഇംപോർട്ട് ചെയ്യുക';

  @override
  String get overrideExistingData => 'നിലവിലുള്ള ഡാറ്റ ഓവർറൈഡ് ചെയ്യുക';

  @override
  String get importWipeDesc =>
      'ഇംപോർട്ട് ചെയ്യുന്നതിന് മുമ്പ് നിലവിലുള്ള എല്ലാ ഡാറ്റയും മായ്ക്കും.';

  @override
  String get importMergeDesc =>
      'പുതിയ രേഖകൾ നിലവിലുള്ള ഡാറ്റയുമായി ലയിപ്പിക്കും.';

  @override
  String get importWipeWarning =>
      'ഇംപോർട്ട് ചെയ്യുന്നതിന് മുമ്പ് നിലവിലുള്ള എല്ലാ ഡാറ്റയും ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടും.';

  @override
  String get importMergeChip =>
      'പുതിയ രേഖകൾ നിങ്ങളുടെ നിലവിലുള്ള ഡാറ്റയുമായി ലയിപ്പിക്കും.';

  @override
  String get importReplaceWarning =>
      'നിലവിലുള്ള എല്ലാ ഡാറ്റയും ശാശ്വതമായി ഇല്ലാതാക്കുകയും ബാക്കപ്പ് ഉപയോഗിച്ച് മാറ്റിസ്ഥാപിക്കുകയും ചെയ്യും.';

  @override
  String get downloadTemplate => 'ടെംപ്ലേറ്റ് ഡൗൺലോഡ് ചെയ്യുക';

  @override
  String get downloadTemplateDesc =>
      'നിങ്ങളുടെ ഡാറ്റ ഫോർമാറ്റ് ചെയ്യുന്നതിന് ശരിയായ കോളം തലക്കെട്ടുകളുള്ള ഒരു CSV നേടുക.';

  @override
  String get backupsTitle => 'ഓട്ടോമാറ്റിക്\nബാക്കപ്പുകൾ';

  @override
  String get backupsSubtitle =>
      'ഒരു ഷെഡ്യൂൾ അനുസരിച്ച്, നിങ്ങളുടെ ഉപകരണത്തിൽ സേവ് ചെയ്ത ഡാറ്റയുടെ ഒരു പുതിയ പകർപ്പ് സൂക്ഷിക്കുക.';

  @override
  String get statusSectionLabel => 'സ്റ്റാറ്റസ്';

  @override
  String get configurationLabel => 'കോൺഫിഗറേഷൻ';

  @override
  String get actionsLabel => 'പ്രവർത്തനങ്ങൾ';

  @override
  String get backupNow => 'ഇപ്പോൾ ബാക്കപ്പ് ചെയ്യുക';

  @override
  String get alreadyBackedUpToday => 'ഇന്ന് ഇതിനകം ബാക്കപ്പ് ചെയ്തു';

  @override
  String get lastBackupFailed => 'അവസാന ബാക്കപ്പ് പരാജയപ്പെട്ടു';

  @override
  String get backupFolderErrorDesc =>
      'ഞങ്ങൾക്ക് നിങ്ങളുടെ ബാക്കപ്പ് ഫോൾഡർ ആക്സസ് ചെയ്യാൻ കഴിഞ്ഞില്ല. അത് മാറ്റിയിരിക്കാം അല്ലെങ്കിൽ അനുമതി പിൻവലിച്ചിരിക്കാം.';

  @override
  String attemptedOn(String label) {
    return '$label ശ്രമിച്ചു';
  }

  @override
  String get chooseNewFolder => 'പുതിയ ഫോൾഡർ തിരഞ്ഞെടുക്കുക';

  @override
  String get backedUp => 'ബാക്കപ്പ് ചെയ്തു';

  @override
  String backedUpOn(String label) {
    return '$label ബാക്കപ്പ് ചെയ്തു';
  }

  @override
  String lastCopySaved(String count) {
    return 'അവസാന പകർപ്പ് വിജയകരമായി സേവ് ചെയ്തു. നിങ്ങളുടെ ഏറ്റവും പുതിയ $count ബാക്കപ്പുകൾ സൂക്ഷിക്കുന്നു.';
  }

  @override
  String get neverLoseData => 'നിങ്ങളുടെ ഡാറ്റ ഒരിക്കലും നഷ്ടപ്പെടുത്തരുത്';

  @override
  String get neverLoseDataDesc =>
      'ഓട്ടോമാറ്റിക് ബാക്കപ്പുകൾ ഓണാക്കുക, നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന ഫോൾഡറിലേക്ക് Kuber ഒരു പകർപ്പ് സേവ് ചെയ്യും.';

  @override
  String get automaticBackups => 'ഓട്ടോമാറ്റിക് ബാക്കപ്പുകൾ';

  @override
  String get saveCopyOnSchedule => 'ഒരു ഷെഡ്യൂളിൽ ഒരു പകർപ്പ് സേവ് ചെയ്യുക';

  @override
  String get keepLast => 'അവസാനത്തേത് സൂക്ഷിക്കുക';

  @override
  String get backupFolder => 'ബാക്കപ്പ് ഫോൾഡർ';

  @override
  String get exportingData => 'ഡാറ്റ എക്സ്പോർട്ട് ചെയ്യുന്നു...';

  @override
  String get preparingFile => 'നിങ്ങളുടെ ഫയൽ തയ്യാറാക്കുന്നു';

  @override
  String get dataExportedSuccess => 'ഡാറ്റ വിജയകരമായി എക്സ്പോർട്ട് ചെയ്തു';

  @override
  String get exportComplete => 'എക്സ്പോർട്ട് പൂർത്തിയായി';

  @override
  String savedToDownloads(String fileName) {
    return 'Downloads/$fileName എന്നതിലേക്ക് സേവ് ചെയ്തു';
  }

  @override
  String exportFailedMsg(String error) {
    return 'എക്സ്പോർട്ട് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get downloadingTemplate => 'ടെംപ്ലേറ്റ് ഡൗൺലോഡ് ചെയ്യുന്നു...';

  @override
  String get preparingCsvTemplate => 'CSV ടെംപ്ലേറ്റ് തയ്യാറാക്കുന്നു';

  @override
  String get templateDownloadedSuccess =>
      'ടെംപ്ലേറ്റ് വിജയകരമായി ഡൗൺലോഡ് ചെയ്തു';

  @override
  String get downloadComplete => 'ഡൗൺലോഡ് പൂർത്തിയായി';

  @override
  String downloadFailedMsg(String error) {
    return 'ഡൗൺലോഡ് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get downloadFailedTitle => 'ഡൗൺലോഡ് പരാജയപ്പെട്ടു';

  @override
  String importFailedMsg(String error) {
    return 'ഇംപോർട്ട് പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get mockDataGenerated => 'മോക്ക് ഡാറ്റ വിജയകരമായി സൃഷ്ടിച്ചു';

  @override
  String generationFailedMsg(String error) {
    return 'സൃഷ്ടിക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String get allDataCleared => 'എല്ലാ ഡാറ്റയും വിജയകരമായി മായ്ച്ചു';

  @override
  String clearFailedMsg(String error) {
    return 'മായ്ക്കൽ പരാജയപ്പെട്ടു: $error';
  }

  @override
  String rebuildFailedMsg(String error) {
    return 'പുനർനിർമ്മാണം പരാജയപ്പെട്ടു: $error';
  }

  @override
  String notifNewRecurring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ആവർത്തന ഇടപാടുകൾ ചേർത്തു',
      one: 'പുതിയ ആവർത്തന ഇടപാട്',
    );
    return '$_temp0';
  }

  @override
  String notifRecurringBody(String name) {
    return '$name - നിങ്ങൾ ഇല്ലാതിരുന്നപ്പോൾ ചേർത്തത്';
  }

  @override
  String get notifLoanEmiTitle => 'ലോൺ EMI കുറച്ചു';

  @override
  String notifLoanEmiBody(String name) {
    return '$name - നിങ്ങളുടെ ഇടപാടുകളിലേക്ക് EMI ചേർത്തു';
  }

  @override
  String get notifInvestmentTitle => 'നിക്ഷേപ വിഹിതം ചേർത്തു';

  @override
  String notifInvestmentBody(String name) {
    return '$name - SIP വിഹിതം രേഖപ്പെടുത്തി';
  }

  @override
  String get notifMoneyToCollect => 'ലഭിക്കാനുള്ള പണം';

  @override
  String get notifMoneyToRepay => 'തിരികെ നൽകാനുള്ള പണം';

  @override
  String notifLedgerReminderBody(String person, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$person - $count ദിവസങ്ങൾ വൈകി',
      one: '$person - 1 ദിവസം വൈകി',
      zero: '$person - ഇന്ന് നൽകണം',
    );
    return '$_temp0';
  }

  @override
  String get notifBudgetAlertTitle => 'ബജറ്റ് മുന്നറിയിപ്പ്';

  @override
  String notifBudgetReachedBody(String pct, String category) {
    return 'നിങ്ങളുടെ $category ബജറ്റിന്റെ $pct% നിങ്ങൾ ഉപയോഗിച്ചു';
  }

  @override
  String notifBudgetSpentBody(String amount, String category) {
    return '$category വിഭാഗത്തിൽ നിങ്ങൾ $amount ചെലവഴിച്ചു';
  }

  @override
  String get wgtBalanceHeroName => 'ബാലൻസ് കാർഡ്';

  @override
  String get wgtBalanceHeroDesc =>
      'വരുമാനം / ചെലവ് എന്നിവ സഹിതം ഈ മാസത്തെ നെറ്റ്';

  @override
  String get wgtInsightStoriesName => 'മണി സ്റ്റോറീസ്';

  @override
  String get wgtInsightStoriesDesc =>
      'നിങ്ങളുടെ പണത്തെക്കുറിച്ചുള്ള വിവരങ്ങളും ഹൈലൈറ്റുകളും';

  @override
  String get wgtQuickAddName => 'വേഗത്തിൽ ചേർക്കുക';

  @override
  String get wgtQuickAddDesc =>
      'ഒറ്റ ടാപ്പിൽ ചെലവ് / വരുമാനം / ട്രാൻസ്ഫർ ചേർക്കാം';

  @override
  String get wgtSpendingStatsName => 'ചെലവ് കണക്കുകൾ';

  @override
  String get wgtSpendingStatsDesc => 'ഈ മാസം ചെലവഴിച്ചതും ലഭിച്ചതും';

  @override
  String get wgtHomeAccountsName => 'ബാങ്ക് അക്കൗണ്ടുകൾ';

  @override
  String get wgtHomeAccountsDesc => 'എല്ലാ അക്കൗണ്ടുകളും ബാലൻസുകളും';

  @override
  String get wgtSevenDayChartName => 'കഴിഞ്ഞ 7 ദിവസത്തെ ചാർട്ട്';

  @override
  String get wgtSevenDayChartDesc =>
      'കഴിഞ്ഞ ആഴ്‌ചയിലെ പ്രതിദിന വരുമാനവും ചെലവും';

  @override
  String get wgtBudgetSnapshotName => 'ബജറ്റ് സ്നാപ്പ്ഷോട്ട്';

  @override
  String get wgtBudgetSnapshotDesc => 'സജീവ ബജറ്റുകളുടെ പുരോഗതി';

  @override
  String get wgtUpcomingRecurringName => 'വരാനിരിക്കുന്ന ആവർത്തന ഇടപാടുകൾ';

  @override
  String get wgtUpcomingRecurringDesc => 'അടുത്തതായി നൽകേണ്ട ആവർത്തന ഇടപാടുകൾ';

  @override
  String get wgtRecentTransactionsName => 'സമീപകാല ഇടപാടുകൾ';

  @override
  String get wgtRecentTransactionsDesc =>
      'ഏറ്റവും പുതിയ പ്രവർത്തനങ്ങൾ ഒറ്റനോട്ടത്തിൽ';

  @override
  String get wgtSummaryCardName => 'സമ്മറി കാർഡ്';

  @override
  String get wgtSummaryCardDesc => 'ഈ കാലയളവിലെ വരുമാനം, ചെലവ്, നെറ്റ് എന്നിവ';

  @override
  String get wgtSpendingTrendName => 'ചെലവിന്റെ ട്രെൻഡ്';

  @override
  String get wgtSpendingTrendDesc =>
      'ബക്കറ്റ് ഡ്രോപ്പ്ഡൗൺ ഉള്ള ബാർ / ലൈൻ ചാർട്ട്';

  @override
  String get wgtWeeklyHeatmapName => 'പ്രതിവാര ഹീറ്റ്മാപ്പ്';

  @override
  String get wgtWeeklyHeatmapDesc => 'ആഴ്‌ചയിലെ ഓരോ ദിവസത്തെയും ശരാശരി ചെലവ്';

  @override
  String get wgtSizeDistributionName => 'ഇടപാട് വലുപ്പങ്ങൾ';

  @override
  String get wgtSizeDistributionDesc =>
      'ചെറുത് / ഇടത്തരം / വലുത് എന്നിങ്ങനെ തരംതിരിക്കുന്നത്';

  @override
  String get wgtCategoryBreakdownName => 'വിഭാഗം തിരിച്ച്';

  @override
  String get wgtCategoryBreakdownDesc =>
      'വിഭാഗം തിരിച്ച് ഗ്രൂപ്പ് ചെയ്ത ചെലവുകൾ';

  @override
  String get wgtTagAnalyticsName => 'ടാഗ് അനലിറ്റിക്‌സ്';

  @override
  String get wgtTagAnalyticsDesc => 'ടാഗ് തിരിച്ച് ഗ്രൂപ്പ് ചെയ്ത ആകെത്തുക';

  @override
  String get wgtBiggestTransactionsName => 'ഏറ്റവും വലിയ ഇടപാടുകൾ';

  @override
  String get wgtBiggestTransactionsDesc =>
      'തുക, ചെലവ് അല്ലെങ്കിൽ വരുമാനം അനുസരിച്ചുള്ള ആദ്യ 5 എണ്ണം';

  @override
  String get atLeastOneWidget =>
      'കുറഞ്ഞത് ഒരു വിഡ്ജറ്റെങ്കിലും ഓൺ ആക്കിയിരിക്കണം';

  @override
  String get discardChangesConfirm => 'മാറ്റങ്ങൾ ഒഴിവാക്കണോ?';

  @override
  String get discardChangesBody =>
      'നിങ്ങളുടെ വിഡ്ജറ്റുകളിൽ സേവ് ചെയ്യാത്ത മാറ്റങ്ങളുണ്ട്. ഇപ്പോൾ പുറത്തുപോയാൽ അവ ഒഴിവാക്കപ്പെടും.';

  @override
  String get keepEditing => 'എഡിറ്റ് ചെയ്യുന്നത് തുടരുക';

  @override
  String get discardLabel => 'ഒഴിവാക്കുക';

  @override
  String get unlockToContinue => 'തുടരാൻ അൺലോക്ക് ചെയ്യുക';

  @override
  String get splashTagline => 'നിങ്ങളുടെ വ്യക്തിഗത മണി ഡയറി';

  @override
  String get tutCh0Title => 'ഇടപാടുകൾ';

  @override
  String get tutCh0Desc =>
      'വരുമാനം, ചെലവുകൾ, ട്രാൻസ്ഫറുകൾ, നോട്ട്സ്, രസീതുകൾ, ടാഗുകൾ എന്നിവ ചേർക്കുക.';

  @override
  String get tutCh0St0Title => 'തുക നൽകുക';

  @override
  String get tutCh0St0Desc =>
      'തുക നേരിട്ട് ടൈപ്പ് ചെയ്യുക. ബിൽറ്റ്-ഇൻ എക്സ്പ്രഷൻ കാൽക്കുലേറ്റർ തുറക്കാൻ കാൽക്കുലേറ്റർ ഐക്കണിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh0St1Title => 'ഇടപാടിന്റെ തരം';

  @override
  String get tutCh0St1Desc =>
      'വരുമാനം, ചെലവ് അല്ലെങ്കിൽ നിങ്ങളുടെ അക്കൗണ്ടുകൾക്കിടയിലുള്ള ട്രാൻസ്ഫർ തിരഞ്ഞെടുക്കുക.';

  @override
  String get tutCh0St2Title => 'ഒരു വിഭാഗം തിരഞ്ഞെടുക്കുക';

  @override
  String get tutCh0St2Desc =>
      'വിഭാഗങ്ങൾ നിങ്ങളുടെ ചെലവുകൾ ക്രമീകരിക്കുന്നു. നിലവിലുള്ളത് തിരഞ്ഞെടുക്കാനോ നിങ്ങളുടേതായ ഒന്ന് നിർമ്മിക്കാനോ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh0St3Title => 'ഒരു അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get tutCh0St3Desc =>
      'ഇത് ഏത് വാലറ്റിലേക്കോ ബാങ്ക് അക്കൗണ്ടിലേക്കോ ആണെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String get tutCh0St4Title => 'പേര് നൽകുക';

  @override
  String get tutCh0St4Desc =>
      'ടൈപ്പ് ചെയ്യാൻ തുടങ്ങുക, നിങ്ങളുടെ മുൻകാല ഇടപാടുകളിൽ നിന്ന് Kuber സ്വയമേവ നിർദ്ദേശങ്ങൾ നൽകും.';

  @override
  String get tutCh0St5Title => 'സ്മാർട്ട് നിർദ്ദേശങ്ങൾ';

  @override
  String get tutCh0St5Desc =>
      'ഒറ്റ ടാപ്പിൽ പേര്, വിഭാഗം, അക്കൗണ്ട് എന്നിവ ഓട്ടോ-ഫിൽ ചെയ്യാൻ ഒരു നിർദ്ദേശത്തിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh0St6Title => 'കുറിപ്പുകളും അറ്റാച്ച്മെന്റുകളും';

  @override
  String get tutCh0St6Desc =>
      'കൂടുതൽ വിവരങ്ങൾ ചേർക്കുക അല്ലെങ്കിൽ നിങ്ങളുടെ രസീതീന്റെ ഫോട്ടോ അറ്റാച്ചുചെയ്യുക.';

  @override
  String get tutCh0St7Title => 'ടാഗുകൾ ചേർക്കുക';

  @override
  String get tutCh0St7Desc =>
      'വിവിധ വിഭാഗങ്ങളിലുടനീളമുള്ള ഇടപാടുകളെ ഗ്രൂപ്പുചെയ്യുന്ന കസ്റ്റം ലേബലുകളാണ് ടാഗുകൾ.';

  @override
  String get tutCh1Title => 'ഹോം';

  @override
  String get tutCh1Desc =>
      'നിങ്ങളുടെ പ്രതിമാസ സ്നാപ്പ്ഷോട്ട് വായിച്ച് വേഗത്തിലുള്ള പ്രവർത്തനങ്ങൾ ഉപയോഗിക്കുക.';

  @override
  String get tutCh1St0Title => 'നിങ്ങളുടെ പ്രതിമാസ സ്നാപ്പ്ഷോട്ട്';

  @override
  String get tutCh1St0Desc =>
      'ഈ മാസത്തെ നെറ്റ് ഫ്ലോ ഒറ്റനോട്ടത്തിൽ. പച്ച നിറം വരുമാനവും ചുവപ്പ് നിറം ചെലവുമാണ്. വിശദാംശങ്ങൾക്കായി ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh1St1Title => 'പ്രൈവസി മോഡ്';

  @override
  String get tutCh1St1Desc =>
      'ഓരോ ബാലൻസും ഉടനടി മറയ്‌ക്കാൻ കണ്ണ് ഐക്കണിൽ ടാപ്പ് ചെയ്യുക. പൊതു ഇടങ്ങൾക്ക് അനുയോജ്യമാണ്.';

  @override
  String get tutCh1St2Title => 'വേഗത്തിൽ ചേർക്കുക';

  @override
  String get tutCh1St2Desc =>
      'മുഴുവൻ ഫോമും തുറക്കാതെ തന്നെ നിമിഷങ്ങൾക്കുള്ളിൽ ഒരു ഇടപാട് രേഖപ്പെടുത്തുക. ടൈപ്പ് ചെയ്ത് മുന്നോട്ട് പോകുക.';

  @override
  String get tutCh1St3Title => 'സമീപകാല ഇടപാടുകൾ';

  @override
  String get tutCh1St3Desc =>
      'നിങ്ങളുടെ അവസാനത്തെ ചില ഇടപാടുകൾ ബാലൻസ് കാർഡിന് താഴെ കാണാം. കാണാനോ എഡിറ്റ് ചെയ്യാനോ ഏതിലെങ്കിലും ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh1St4Title => 'നാവിഗേഷൻ';

  @override
  String get tutCh1St4Desc =>
      'ഹോം, ഹിസ്റ്ററി, അനലിറ്റിക്സ്, കൂടുതൽ എന്നിവയ്ക്കിടയിൽ മാറാൻ താഴെയുള്ള ബാർ ഉപയോഗിക്കുക.';

  @override
  String get tutCh2Title => 'ഹിസ്റ്ററി';

  @override
  String get tutCh2Desc =>
      'മുൻകാല ഇടപാടുകൾ കണ്ടെത്തുക, ഫിൽട്ടർ ചെയ്യുക, പരിശോധിക്കുക, എഡിറ്റ് ചെയ്യുക.';

  @override
  String get tutCh2St0Title => 'ഇടപാട് ടൈംലൈൻ';

  @override
  String get tutCh2St0Desc =>
      'നിങ്ങളുടെ എല്ലാ ഇടപാടുകളും തീയതി തിരിച്ച് നൽകിയിരിക്കുന്നു. ഏറ്റവും പുതിയത് മുകളിൽ.';

  @override
  String get tutCh2St1Title => 'ക്വിക്ക് ഫിൽറ്ററുകൾ';

  @override
  String get tutCh2St1Desc =>
      'ഈ ചിപ്പുകൾ ഉപയോഗിച്ച് വരുമാനം, ചെലവ് അല്ലെങ്കിൽ ട്രാൻസ്ഫർ എന്നിവ വേഗത്തിൽ ഫിൽട്ടർ ചെയ്യുക.';

  @override
  String get tutCh2St2Title => 'വിപുലമായ ഫിൽറ്ററുകൾ';

  @override
  String get tutCh2St2Desc =>
      'തീയതി പരിധി, അക്കൗണ്ട്, വിഭാഗം അല്ലെങ്കിൽ ടാഗുകൾ എന്നിവ ഉപയോഗിച്ച് ഒരേസമയം തിരയാൻ ഫിൽട്ടർ ഐക്കണിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh2St3Title => 'എഡിറ്റ് ചെയ്യാൻ ടാപ്പ് ചെയ്യുക';

  @override
  String get tutCh2St3Desc =>
      'മുഴുവൻ വിവരങ്ങളും കാണാനോ എഡിറ്റ് ചെയ്യാനോ ഇല്ലാതാക്കാനോ ഏതെങ്കിലും ഇടപാടിൽ ടാപ്പ് ചെയ്യുക.';

  @override
  String get tutCh3Title => 'അനലിറ്റിക്സ്';

  @override
  String get tutCh3Desc =>
      'ട്രെൻഡുകൾ മനസ്സിലാക്കി നിങ്ങളുടെ പണം എവിടെയാണ് ചിലവാകുന്നതെന്ന് അറിയുക.';

  @override
  String get tutCh3St0Title => 'ആദ്യം തീയതി പരിധി സജ്ജമാക്കുക';

  @override
  String get tutCh3St0Desc =>
      'ഡിഫോൾട്ടായി ഇന്നത്തെ ഡാറ്റ മാത്രമാണ് കാണിക്കുന്നത്. താഴെയുള്ള ചാർട്ടുകളിൽ ഗ്രാഫ് വരാൻ ഈ പില്ലിൽ ടാപ്പ് ചെയ്ത് \"All time\" തിരഞ്ഞെടുക്കുക.';

  @override
  String get tutCh3St1Title => 'നിങ്ങളുടെ സാമ്പത്തിക സ്നാപ്പ്ഷോട്ട്';

  @override
  String get tutCh3St1Desc =>
      'ഓരോ മാസവും നിങ്ങളുടെ പണം എവിടെയാണ് പോകുന്നതെന്ന് കാണിക്കുന്ന വിഷ്വൽ ബ്രേക്ക്ഡൗൺ.';

  @override
  String get tutCh3St2Title => 'ചെലവിന്റെ ട്രെൻഡുകൾ';

  @override
  String get tutCh3St2Desc =>
      'പ്രതിദിന ചെലവ് കാണിക്കുന്ന ഒരു ബാർ ചാർട്ട്. 7 ദിവസത്തിനും കസ്റ്റം സമയ പരിധിക്കുമിടയിൽ മാറ്റുക.';

  @override
  String get tutCh3St3Title => 'വിഭാഗം തിരിച്ച്';

  @override
  String get tutCh3St3Desc =>
      'ഏത് വിഭാഗങ്ങളിലാണ് നിങ്ങളുടെ ബജറ്റിന്റെ ഭൂരിഭാഗവും ചെലവാകുന്നതെന്ന് ഒറ്റനോട്ടത്തിൽ കാണുക.';

  @override
  String get tutCh3St4Title => 'ഫിൽറ്ററുകൾ തുടരും';

  @override
  String get tutCh3St4Desc =>
      'ഹിസ്റ്ററി പേജിൽ നിങ്ങൾ സജ്ജമാക്കുന്ന ഏത് ഫിൽറ്ററുകളും നിങ്ങളുടെ അനലിറ്റിക്സ് കാഴ്ചയെയും അപ്ഡേറ്റ് ചെയ്യുന്നു.';

  @override
  String get tutCh4Title => 'കൂടുതൽ വിവരങ്ങളും ക്രമീകരണങ്ങളും';

  @override
  String get tutCh4Desc =>
      'Kuber കസ്റ്റമൈസ് ചെയ്യുക, ഡാറ്റ മാനേജ് ചെയ്യുക, കൂടുതൽ ടൂളുകൾ പര്യവേക്ഷണം ചെയ്യുക.';

  @override
  String get tutCh4St0Title => 'ബജറ്റുകൾ';

  @override
  String get tutCh4St0Desc =>
      'ഓരോ വിഭാഗത്തിനും പ്രതിമാസ ചെലവ് പരിധികൾ സജ്ജമാക്കുക. Kuber സ്വയമേവ നിങ്ങളുടെ പുരോഗതി ട്രാക്ക് ചെയ്യുന്നു.';

  @override
  String get tutCh4St1Title => 'Kuber-നോട് ചോദിക്കുക';

  @override
  String get tutCh4St1Desc =>
      'നിങ്ങളുടെ ഓൺ-ഡിവൈസ് AI അസിസ്റ്റന്റ്. നിങ്ങളുടെ ചെലവുകളെക്കുറിച്ച് സ്വകാര്യമായി ചോദ്യങ്ങൾ ചോദിക്കുക.';

  @override
  String get tutCh4St2Title => 'നിങ്ങളുടെ ഡാറ്റ';

  @override
  String get tutCh4St2Desc =>
      'CSV ആയി എക്സ്പോർട്ട് ചെയ്യുക, ബാക്കപ്പിൽ നിന്ന് ഇംപോർട്ട് ചെയ്യുക, അല്ലെങ്കിൽ സാമ്പിൾ ഡാറ്റ സൃഷ്ടിക്കുക. എല്ലാം നിങ്ങളുടെ ഉപകരണത്തിൽ തന്നെ സുരക്ഷിതമായിരിക്കും.';

  @override
  String get tutorialUpper => 'ട്യൂട്ടോറിയൽ';

  @override
  String get pickChapter => 'ഒരു അധ്യായം തിരഞ്ഞെടുക്കുക.';

  @override
  String get pickChapterSubtitle =>
      'അഞ്ച് ചെറിയ അധ്യായങ്ങൾ, ഓരോന്നും ഏകദേശം 2 മിനിറ്റ്. എവിടെനിന്നും ആരംഭിക്കാം.';

  @override
  String get startFromBeginning => 'തുടക്കത്തിൽ നിന്ന് ആരംഭിക്കുക →';

  @override
  String get skipTutorialConfirm => 'ട്യൂട്ടോറിയൽ ഒഴിവാക്കണോ?';

  @override
  String get keepGoing => 'തുടരുക';

  @override
  String get skipLabel => 'ഒഴിവാക്കുക';

  @override
  String get replayHint =>
      'കൂടുതൽ → ട്യൂട്ടോറിയൽ എന്നതിൽ നിന്ന് നിങ്ങൾക്ക് ഇത് എപ്പോഴും വീണ്ടും പ്ലേ ചെയ്യാം.';

  @override
  String get replayHintApp =>
      'കൂടുതൽ → ആപ്പ് ട്യൂട്ടോറിയൽ എന്നതിൽ നിന്ന് നിങ്ങൾക്ക് ഇത് എപ്പോഴും വീണ്ടും പ്ലേ ചെയ്യാം.';

  @override
  String tutStepsAndMin(String count, String mins) {
    return '$count ഘട്ടങ്ങൾ · ~$mins മിനിറ്റ്';
  }

  @override
  String chapterDoneTitle(String num) {
    return 'അധ്യായം $num പൂർത്തിയായി! 🎉';
  }

  @override
  String get endTutorial => 'ട്യൂട്ടോറിയൽ അവസാനിപ്പിക്കുക';

  @override
  String readyToStart(String title) {
    return '\"$title\" ആരംഭിക്കാൻ തയ്യാറാണോ?';
  }

  @override
  String get exitTutorialConfirm => 'ട്യൂട്ടോറിയലിൽ നിന്ന് പുറത്തുകടക്കണോ?';

  @override
  String get exitLabel => 'പുറത്തുകടക്കുക';

  @override
  String chapterXofY(String current, String total) {
    return '$total-ൽ $current-ാമത്തെ അധ്യായം';
  }

  @override
  String get skipTour => 'ടൂർ ഒഴിവാക്കുക';

  @override
  String get nextArrow => 'അടുത്തത് ›';

  @override
  String get incShort => 'വരുമാനം';

  @override
  String get expShort => 'ചെലവ്';

  @override
  String get disbursedOn => 'വിതരണം ചെയ്ത തീയതി';

  @override
  String get emiDebitedFrom => 'ഇതിൽ നിന്നും EMI കുറച്ചു';

  @override
  String get searchAccountsHint => 'അക്കൗണ്ടുകൾ തിരയുക...';

  @override
  String noAccountsMatch(String query) {
    return '\'$query\' എന്നതുമായി ഒരു അക്കൗണ്ടും പൊരുത്തപ്പെടുന്നില്ല';
  }

  @override
  String get monthlyNetAutomation => 'പ്രതിമാസ അറ്റം';

  @override
  String get disableAccount => 'അക്കൗണ്ട് പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get enableAccount => 'അക്കൗണ്ട് പ്രവർത്തനക്ഷമമാക്കുക';

  @override
  String get accountHidden => 'അക്കൗണ്ട് മറച്ചു';

  @override
  String get accountRestored => 'അക്കൗണ്ട് പുനഃസ്ഥാപിച്ചു';

  @override
  String get disableAccountConfirm =>
      'ഈ അക്കൗണ്ട് പിക്കറുകളിൽ നിന്നും ഹോം കാർഡുകളിൽ നിന്നും മറയ്ക്കും. എപ്പോൾ വേണമെങ്കിലും വീണ്ടും പ്രവർത്തനക്ഷമമാക്കാം.';

  @override
  String get hiddenChip => 'മറച്ചത്';

  @override
  String get shareStory => 'സ്റ്റോറി പങ്കിടുക';

  @override
  String get shareAsImage => 'ചിത്രമായി പങ്കിടുക';

  @override
  String get shareAsText => 'ടെക്സ്റ്റായി പങ്കിടുക';

  @override
  String get confirmLabel => 'സ്ഥിരീകരിക്കുക';

  @override
  String get sourceLabel => 'ഉറവിടം';

  @override
  String get sourceSms => 'SMS ഇമ്പോർട്ട്';

  @override
  String get sourceRecurring => 'ആവർത്തിക്കുന്നത്';

  @override
  String get sourceLentBorrowed => 'കടം കൊടുത്തത് അല്ലെങ്കിൽ വാങ്ങിയത്';

  @override
  String get sourceLoan => 'വായ്പ';

  @override
  String get sourceInvestment => 'നിക്ഷേപം / SIP';

  @override
  String get sourceQuickAdd => 'ക്വിക്ക് ആഡ്';

  @override
  String get sourceManual => 'നിങ്ങൾ നൽകിയത്';

  @override
  String get sourceBalanceAdjustment => 'ബാലൻസ് ക്രമീകരണം';

  @override
  String get viewOriginalSms => 'യഥാർത്ഥ SMS കാണുക';

  @override
  String get accountTypeLabel => 'അക്കൗണ്ട് തരം';

  @override
  String get accountNumberLabel => 'അക്കൗണ്ട് നമ്പർ';

  @override
  String get yesLabel => 'അതെ';

  @override
  String get noLabel => 'ഇല്ല';

  @override
  String get lastTransactionLabel => 'അവസാന ഇടപാട്';

  @override
  String get budgetStatusLabel => 'ബജറ്റ് നില';

  @override
  String get setBudgetForCategory => 'ഈ വിഭാഗത്തിന് ബജറ്റ് സജ്ജമാക്കുക';

  @override
  String get usageCountLabel => 'ഉപയോഗ എണ്ണം';

  @override
  String get firstUsedLabel => 'ആദ്യ ഉപയോഗം';

  @override
  String get lastUsedLabel => 'അവസാന ഉപയോഗം';

  @override
  String get viewTaggedTransactions => 'ടാഗ് ചെയ്ത ഇടപാടുകൾ കാണുക';

  @override
  String get accountLabel => 'അക്കൗണ്ട്';

  @override
  String get dateTimeTitle => 'തീയതിയും സമയവും';

  @override
  String get originalSmsLabel => 'യഥാർത്ഥ SMS';

  @override
  String transactionsCountValue(int count) {
    return '$count ഇടപാടുകൾ';
  }

  @override
  String get editAccountSubtitle => 'അക്കൗണ്ട് വിശദാംശങ്ങൾ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get accountNameLabel => 'അക്കൗണ്ട് പേര്';

  @override
  String get accountNameHint => 'അക്കൗണ്ട് പേര്';

  @override
  String get accountTypeBank => 'ബാങ്ക്';

  @override
  String get accountTypeCash => 'പണം';

  @override
  String get accountTypeCreditCard => 'ക്രെഡിറ്റ് കാർഡ്';

  @override
  String get accountTypeLockedTitle => 'അക്കൗണ്ട് തരം നിശ്ചയിച്ചതാണ്';

  @override
  String get accountTypeLockedBody =>
      'സൃഷ്ടിച്ചതിന് ശേഷം അക്കൗണ്ട് തരം മാറ്റാനാകില്ല. മറ്റൊരു തരം ഉപയോഗിക്കാൻ, ഒരു പുതിയ അക്കൗണ്ട് സൃഷ്ടിക്കുക.';

  @override
  String get accountTypeLockedTooltip =>
      'ഇത് എന്തുകൊണ്ട് ലോക്ക് ചെയ്തിരിക്കുന്നു?';

  @override
  String get accountIdentifierLabel => 'അക്കൗണ്ട് നമ്പർ / ഐഡന്റിഫയർ';

  @override
  String get accountIdentifierHint =>
      'അവസാന 4 അക്കങ്ങൾ അല്ലെങ്കിൽ പൂർണ്ണ നമ്പർ';

  @override
  String get accountIdentifierHelper =>
      'അവസാന 4 അക്കങ്ങൾ അല്ലെങ്കിൽ പൂർണ്ണ നമ്പർ. SMS ഇമ്പോർട്ടുകൾ പൊരുത്തപ്പെടുത്താൻ ഉപയോഗിക്കുന്നു.';

  @override
  String get makeDefaultAccount => 'ഇത് ഡിഫോൾട്ട് അക്കൗണ്ട് ആക്കുക';

  @override
  String get makeDefaultAccountSub =>
      'ഇടപാടുകൾ ചേർക്കുമ്പോൾ മുൻകൂട്ടി തിരഞ്ഞെടുത്തത്.';

  @override
  String get currentBalanceLabel => 'നിലവിലെ ബാലൻസ്';

  @override
  String get limitSpentLabel => 'ചെലവഴിച്ച പരിധി';

  @override
  String get totalLimitLabel => 'ആകെ പരിധി';

  @override
  String get totalLimitHelper =>
      'കാർഡിന്റെ മൊത്തം ക്രെഡിറ്റ് പരിധി. ഇത് എഡിറ്റ് ചെയ്യുന്നത് ഒരു ക്രമീകരണവും സൃഷ്ടിക്കില്ല.';

  @override
  String get balanceAdjustHelper =>
      'ഇത് മാറ്റുന്നത് വ്യത്യാസത്തിനായി ഒരു ബാലൻസ് ക്രമീകരണ ഇടപാട് സൃഷ്ടിക്കും.';

  @override
  String adjustmentWillBeCredited(String amount) {
    return '$amount ന്റെ ഒരു ബാലൻസ് ക്രമീകരണം ക്രെഡിറ്റ് ചെയ്യപ്പെടും.';
  }

  @override
  String adjustmentWillBeDebited(String amount) {
    return '$amount ന്റെ ഒരു ബാലൻസ് ക്രമീകരണം ഡെബിറ്റ് ചെയ്യപ്പെടും.';
  }

  @override
  String get disableAccountToggle => 'അക്കൗണ്ട് പ്രവർത്തനരഹിതമാക്കുക';

  @override
  String get disableAccountHelper =>
      'പിക്കറുകളിൽ നിന്നും ഹോം കാർഡുകളിൽ നിന്നും മറച്ചിരിക്കുന്നു. നിലവിലുള്ള ഇടപാടുകൾ നിലനിൽക്കും.';

  @override
  String get accountDisabledToggle => 'അക്കൗണ്ട് പ്രവർത്തനരഹിതമാണ്';

  @override
  String get accountDisabledHelper =>
      'ഈ അക്കൗണ്ട് മറച്ചിരിക്കുന്നു. വീണ്ടും കാണിക്കാൻ ഓഫ് ചെയ്യുക.';

  @override
  String get accountUpdated => 'അക്കൗണ്ട് അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get couldntLoadBalance => 'ബാലൻസ് ലോഡ് ചെയ്യാനായില്ല';

  @override
  String get pickNewDefaultTitle =>
      'ഒരു പുതിയ ഡിഫോൾട്ട് അക്കൗണ്ട് തിരഞ്ഞെടുക്കുക';

  @override
  String get pickNewDefaultBody =>
      'ഇത് നിങ്ങളുടെ ഡിഫോൾട്ട് അക്കൗണ്ടാണ്. ഇത് ഇല്ലാതാക്കുന്നതിന് മുമ്പ് ഒരു പകരക്കാരനെ തിരഞ്ഞെടുക്കുക.';

  @override
  String get adjustmentModalTitle => 'ക്രമീകരണ ഇടപാട് സൃഷ്ടിക്കണോ?';

  @override
  String adjustmentModalBody(String noun, String from, String to, String diff) {
    return '$noun $from ൽ നിന്ന് $to ലേക്ക് മാറുന്നു. $diff നായി ഒരു ബാലൻസ് ക്രമീകരണ ഇടപാട് സൃഷ്ടിക്കപ്പെടും.';
  }

  @override
  String adjustmentModalChip(String nounCap, String direction, String diff) {
    return '$nounCap $diff $direction. ഇത് വരുമാനമോ ചെലവോ ആയി കണക്കാക്കില്ല.';
  }

  @override
  String get adjustmentCreateAndSave => 'സൃഷ്ടിച്ച് സംരക്ഷിക്കുക';

  @override
  String get valueNounBalance => 'ബാലൻസ്';

  @override
  String get valueNounLimitSpent => 'ചെലവഴിച്ച പരിധി';

  @override
  String get valueNounBalanceCap => 'ബാലൻസ്';

  @override
  String get valueNounLimitSpentCap => 'ചെലവഴിച്ച പരിധി';

  @override
  String get adjustmentIncreasedBy => 'വർദ്ധിച്ചു';

  @override
  String get adjustmentDecreasedBy => 'കുറഞ്ഞു';

  @override
  String get dangerZone => 'അപകട മേഖല';

  @override
  String get themeModeSectionLabel => 'മോഡ്';

  @override
  String get themeFamilyDescSignature => 'ക്ലാസിക് കുബേർ ലുക്ക്.';

  @override
  String get themeFamilyDescFlewtube => 'തിളക്കമുള്ളതും രസകരവും.';

  @override
  String get themeFamilyDescWoofsapp => 'സൗഹൃദപരവും പരിചിതവും.';

  @override
  String get themeFamilyDescPurrhub => 'കറുപ്പിൽ ബോൾഡ് മഞ്ഞ.';

  @override
  String get themeFamilyDescHonkpe => 'സമ്പന്നം, പേയ്മെന്റ് ശൈലി.';

  @override
  String get themeFamilyDescSqueakdin =>
      'അടുക്കും ചിട്ടയും, ജോലി കേന്ദ്രീകൃതം.';

  @override
  String get themeFamilyDescOinkzon => 'ഊഷ്മളം, ഷോപ്പിംഗ് ശൈലി.';

  @override
  String get applyLabel => 'പ്രയോഗിക്കുക';

  @override
  String get speedDialNote => 'കുബേർ നോട്ട് ചേർക്കുക';

  @override
  String get billingCycle => 'ബില്ലിംഗ് സൈക്കിൾ';

  @override
  String get billGenerationDaySection => 'ബിൽ ഉണ്ടാകുന്ന ദിവസം';

  @override
  String get paymentDueDaySection => 'പേയ്മെന്റ് അടയ്ക്കേണ്ട ദിവസം';

  @override
  String get remindMe => 'എന്നെ ഓർമ്മിപ്പിക്കുക';

  @override
  String get billReminderSub => 'ബിൽ ഉണ്ടാകുന്ന ദിവസം അറിയിക്കുക';

  @override
  String get dueReminderSub => 'പേയ്മെന്റ് അടയ്ക്കേണ്ട തീയതിയിൽ അറിയിക്കുക';

  @override
  String get billGenerationLabel => 'ബിൽ ഉണ്ടാകൽ';

  @override
  String get paymentDueLabel => 'പേയ്മെന്റ് അടയ്ക്കേണ്ടത്';

  @override
  String dayOfEveryMonth(String ordinal) {
    return 'എല്ലാ മാസത്തിലെയും $ordinal';
  }

  @override
  String billDueCrossMonthHint(String billOrdinal, String dueOrdinal) {
    return 'ബിൽ $billOrdinal-ന് ഉണ്ടാകുന്നു, പേയ്മെന്റ് $dueOrdinal-ന് അടയ്ക്കണം, അതിനാൽ പേയ്മെന്റ് അടുത്ത മാസത്തിലാണ്.';
  }

  @override
  String get rangeFrom => 'മുതൽ';

  @override
  String get rangeTo => 'വരെ';

  @override
  String get changeView => 'കാഴ്ച മാറ്റുക';

  @override
  String get iconAndColour => 'ഐക്കണും നിറവും';

  @override
  String get chooseIcon => 'ഐക്കൺ തിരഞ്ഞെടുക്കുക';

  @override
  String get chooseColour => 'നിറം തിരഞ്ഞെടുക്കുക';

  @override
  String get budgetsTitle => 'ബജറ്റുകൾ';

  @override
  String get activeBudgetsSection => 'സജീവം';

  @override
  String get pausedAndEnded => 'താൽക്കാലികമായി നിർത്തിയതും അവസാനിച്ചതും';

  @override
  String get gainLabel => 'നേട്ടം';

  @override
  String get returnLabel => 'റിട്ടേൺ';

  @override
  String moreCountAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count അക്കൗണ്ടുകൾ',
      one: '1 അക്കൗണ്ട്',
    );
    return '$_temp0';
  }

  @override
  String moreCountCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിഭാഗങ്ങൾ',
      one: '1 വിഭാഗം',
    );
    return '$_temp0';
  }

  @override
  String moreCountTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ടാഗുകൾ',
      one: '1 ടാഗ്',
    );
    return '$_temp0';
  }

  @override
  String moreCountActive(int count) {
    return '$count സജീവം';
  }

  @override
  String moreCountRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count നിയമങ്ങൾ',
      one: '1 നിയമം',
    );
    return '$_temp0';
  }

  @override
  String moreCountOpen(int count) {
    return '$count തുറന്നത്';
  }

  @override
  String moreCountHoldings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count നിക്ഷേപങ്ങൾ',
      one: '1 നിക്ഷേപം',
    );
    return '$_temp0';
  }

  @override
  String get netBalanceUpper => 'അറ്റ ബാക്കി';

  @override
  String get netWorthUpper => 'അറ്റ ആസ്തി';

  @override
  String nothingMatchesQuery(Object query) {
    return '\"$query\" എന്നതുമായി ഒന്നും പൊരുത്തപ്പെടുന്നില്ല.';
  }

  @override
  String get searchBudgetsHint => 'ബജറ്റുകൾ തിരയുക';

  @override
  String get searchRecurringHint => 'ആവർത്തിക്കുന്നവ തിരയുക';

  @override
  String get searchLoansHint => 'വായ്പകൾ തിരയുക';

  @override
  String get searchLedgerHint => 'ആളുകളെ തിരയുക';

  @override
  String get searchInvestmentsHint => 'നിക്ഷേപങ്ങൾ തിരയുക';

  @override
  String get textSizeTitle => 'ടെക്സ്റ്റ് വലുപ്പം';

  @override
  String get textSizeDesc => 'ടെക്സ്റ്റ് വലുതോ ചെറുതോ ആക്കുക';

  @override
  String get textSizeSmall => 'ചെറുത്';

  @override
  String get textSizeCompact => 'കോംപാക്റ്റ്';

  @override
  String get textSizeDefault => 'ഡിഫോൾട്ട്';

  @override
  String get textSizeLarge => 'വലുത്';

  @override
  String get textSizeExtraLarge => 'വളരെ വലുത്';

  @override
  String get textSizePreviewUpper => 'പ്രിവ്യൂ';

  @override
  String get textSizePreviewBody =>
      'Kuber ഉപയോഗിച്ച് ദിവസേനയുള്ള ചെലവുകൾ ട്രാക്ക് ചെയ്യുക, ബജറ്റുകൾ കൈകാര്യം ചെയ്യുക, ലക്ഷ്യങ്ങളിലെത്തുക.';

  @override
  String get textSizePreviewMeta => 'പലചരക്ക് · ഇന്ന്';

  @override
  String get homeV2GsTitle => 'നമുക്ക് Kuber സജ്ജമാക്കാം';

  @override
  String get homeV2GsBodyTwoDone => 'ഏകദേശം കഴിഞ്ഞു. ഇനി ഒരു ഘട്ടം കൂടി.';

  @override
  String get homeV2GsStep2 => 'സ്വയം ഒരു ഇടപാട് ചേർക്കുക';

  @override
  String get homeV2GsStep3 => 'നിങ്ങളുടെ തുടക്ക ബാലൻസ് സജ്ജമാക്കുക';

  @override
  String get homeV2GsDoneTitle => 'നിങ്ങൾ തയ്യാറാണ്';

  @override
  String get homeV2GsDoneBody =>
      'നിങ്ങൾ ഉപയോഗിക്കുന്നതിനനുസരിച്ച് Kuber ഹോമിൽ കൂടുതൽ ചേർക്കും.';

  @override
  String get homeV2GsActAdd => 'ഇടപാട് ചേർക്കുക';

  @override
  String get homeV2GsActBalance => 'ബാലൻസ് സജ്ജമാക്കുക';

  @override
  String get homeV2GsCloseA11y => 'തുടങ്ങാം കാർഡ് അടയ്ക്കുക';

  @override
  String get homeV2GsClosedSnack =>
      'തുടങ്ങാം കാർഡ് മറച്ചു. ക്രമീകരണങ്ങളിൽ നിന്ന് വീണ്ടും കാണിക്കാം.';

  @override
  String get homeV2ActUndo => 'പഴയപടിയാക്കുക';

  @override
  String get homeV2SetGsTitle => 'തുടങ്ങാം കാർഡ്';

  @override
  String get homeV2SetGsSub => 'ഹോമിൽ സജ്ജീകരണ ഘട്ടങ്ങൾ കാണിക്കുക';

  @override
  String get homeV2SetSgTitle => 'ഹോമിൽ നിർദ്ദേശങ്ങൾ';

  @override
  String get homeV2SetSgSub =>
      'നിങ്ങളുടെ സ്വന്തം ഇടപാടുകളെ അടിസ്ഥാനമാക്കിയ നുറുങ്ങുകൾ';

  @override
  String homeV2WBalanceEmpty(String month) {
    return '$month-ലെ വരവും ചെലവും ഇവിടെ കാണാം.';
  }

  @override
  String get homeV2WBalanceEmptyAct => 'ഇടപാട് ചേർക്കുക';

  @override
  String get homeV2WRecentEmptyBody => 'നിങ്ങളുടെ പുതിയ ഇടപാടുകൾ ഇവിടെ കാണാം.';

  @override
  String get homeV2WRecentEmptyAct => 'SMS-ൽ നിന്ന് ഇമ്പോർട്ട്';

  @override
  String homeV2WEditMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count വിജറ്റുകൾ കൂടി ലഭ്യമാണ്.',
      one: '1 വിജറ്റ് കൂടി ലഭ്യമാണ്.',
    );
    return '$_temp0';
  }

  @override
  String get homeV2EdSecOn => 'നിങ്ങളുടെ ഹോമിൽ';

  @override
  String get homeV2EdSgTitle => 'നിർദ്ദേശങ്ങൾ';

  @override
  String get homeV2EdSgSub =>
      'നിങ്ങളുടെ സ്വന്തം ഇടപാടുകളിൽ നിന്നുള്ള നുറുങ്ങുകൾ. എപ്പോഴും മുകളിൽ.';

  @override
  String get homeV2EdSecAuto => 'ഇടപാടുകൾ ചേർക്കുമ്പോൾ ഓണാകും';

  @override
  String get homeV2EdSecMore => 'കൂടുതൽ വിജറ്റുകൾ';

  @override
  String get homeV2EdAutoNote =>
      'കാണിക്കാൻ എന്തെങ്കിലും ആകുമ്പോൾ ഇവ സ്വയം കാണും. ഇപ്പോൾ കാണിക്കാൻ ഒന്ന് ഓണാക്കുക.';

  @override
  String get homeV2EdAutoStories => 'ആദ്യ മണി സ്റ്റോറി തയ്യാറാകുമ്പോൾ ഓണാകും';

  @override
  String get homeV2EdAutoStats => 'ഒരാഴ്ചത്തെ ചെലവിന് ശേഷം ഓണാകും';

  @override
  String get homeV2EdAutoAccounts => 'ബാങ്ക് അക്കൗണ്ട് ചേർക്കുമ്പോൾ ഓണാകും';

  @override
  String get homeV2EdAutoChart => '3 വ്യത്യസ്ത ദിവസത്തെ ചെലവിന് ശേഷം ഓണാകും';

  @override
  String get homeV2EdAutoSms => 'ബാങ്ക് SMS കാത്തിരിക്കുമ്പോൾ ഓണാകും';

  @override
  String get homeV2EdAutoEvents =>
      'ആദ്യ ഓർമ്മപ്പെടുത്തൽ, EMI, SIP അല്ലെങ്കിൽ ആവർത്തിക്കുന്ന പേയ്മെന്റിനൊപ്പം ഓണാകും';

  @override
  String get homeV2EdAutoBudget => 'ആദ്യ ബജറ്റിനൊപ്പം ഓണാകും';

  @override
  String get homeV2EdAutoNotes => 'ആദ്യ കുറിപ്പിനൊപ്പം ഓണാകും';

  @override
  String get homeV2SgNotNow => 'ഇപ്പോൾ വേണ്ട';

  @override
  String get homeV2SgDismissA11y => 'ഇത് വീണ്ടും നിർദ്ദേശിക്കരുത്';

  @override
  String get homeV2SgDismissedSnack =>
      'ശരി. Kuber ഇത് വീണ്ടും നിർദ്ദേശിക്കില്ല.';

  @override
  String homeV2SgRecTitle(String merchant) {
    return '$merchant എല്ലാ മാസവും കാണുന്നു';
  }

  @override
  String homeV2SgRecBody(String amount, int months) {
    return '$months മാസമായി ഏകദേശം ഒരേ തീയതിയിൽ $amount. അടയ്ക്കേണ്ടതിന് മുമ്പ് കാണാൻ ആവർത്തിക്കുന്നതായി ചേർക്കുക.';
  }

  @override
  String get homeV2SgRecAct => 'ആവർത്തിക്കുന്നതായി ചേർക്കുക';

  @override
  String homeV2SgRecDone(String merchant) {
    return '$merchant ഇപ്പോൾ ആവർത്തിക്കുന്ന പേയ്മെന്റാണ്.';
  }

  @override
  String get homeV2SgLoanTitle => 'EMI അടയ്ക്കുന്നുണ്ടോ?';

  @override
  String homeV2SgLoanBody(String lender) {
    return 'നിങ്ങളുടെ SMS-ൽ $lender-ന് EMI പേയ്മെന്റുകൾ കാണുന്നു. ബാക്കി അറിയാൻ വായ്പ ചേർക്കുക.';
  }

  @override
  String get homeV2SgLoanAct => 'വായ്പ ചേർക്കുക';

  @override
  String get homeV2SgLoanDone => 'വായ്പ ചേർത്തു.';

  @override
  String get homeV2SgInvTitle => 'SIP വഴി നിക്ഷേപിക്കുന്നുണ്ടോ?';

  @override
  String homeV2SgInvBody(String amount) {
    return 'നിങ്ങളുടെ SMS-ൽ മാസം $amount SIP കാണുന്നു. എല്ലാ നിക്ഷേപങ്ങളും ഒരിടത്ത് കാണാൻ ചേർക്കുക.';
  }

  @override
  String get homeV2SgInvAct => 'നിക്ഷേപം ചേർക്കുക';

  @override
  String get homeV2SgInvDone => 'നിക്ഷേപം ചേർത്തു.';

  @override
  String homeV2SgLedTitle(String name) {
    return '$name-ന് പണം കടം കൊടുത്തോ?';
  }

  @override
  String homeV2SgLedBody(String name, String amount) {
    return 'ഈ മാസം $name-ന് $amount അയച്ചു. കടം കൊടുക്കൽ വാങ്ങലിൽ ഇത് രേഖപ്പെടുത്തുക.';
  }

  @override
  String get homeV2SgLedNoteTitle => 'കടം കൊടുത്ത പണം രേഖപ്പെടുത്തണോ?';

  @override
  String homeV2SgLedNoteBody(String note) {
    return 'നിങ്ങളുടെ കുറിപ്പ് \"$note\" പണം കടം കൊടുത്തതിനെക്കുറിച്ച് പറയുന്നു. മറക്കാതിരിക്കാൻ കടം കൊടുക്കൽ വാങ്ങലിൽ ചേർക്കുക.';
  }

  @override
  String get homeV2SgLedAct => 'രേഖപ്പെടുത്തുക';

  @override
  String get homeV2SgLedDone => 'കടം കൊടുക്കൽ വാങ്ങലിൽ ചേർത്തു.';

  @override
  String homeV2SgBudTitle(String category) {
    return '$category-ന് ബജറ്റ് സജ്ജമാക്കണോ?';
  }

  @override
  String homeV2SgBudBody(String amount, String category) {
    return 'കഴിഞ്ഞ 30 ദിവസം $category-ൽ $amount ചെലവഴിച്ചു. പരിധിയോട് അടുക്കുമ്പോൾ ബജറ്റ് അറിയിക്കും.';
  }

  @override
  String get homeV2SgBudAct => 'ബജറ്റ് സജ്ജമാക്കുക';

  @override
  String homeV2SgBudDone(String category) {
    return '$category-ന് ബജറ്റ് സജ്ജമാക്കി.';
  }

  @override
  String homeV2SgCcTitle(String card) {
    return '$card-ന്റെ ബില്ലിംഗ് തീയതി ചേർക്കുക';
  }

  @override
  String get homeV2SgCcBody =>
      'അപ്പോൾ ഈ സൈക്കിളിലെ ചെലവും ബിൽ അടയ്ക്കേണ്ട തീയതിയും Kuber കാണിക്കും.';

  @override
  String get homeV2SgCcAct => 'ബില്ലിംഗ് തീയതി സജ്ജമാക്കുക';

  @override
  String get homeV2SgCcDone => 'ബില്ലിംഗ് തീയതി സംരക്ഷിച്ചു.';

  @override
  String get homeV2SgAskTitle =>
      'നിങ്ങളുടെ പണത്തെക്കുറിച്ച് Kuber-നോട് ചോദിക്കൂ';

  @override
  String get homeV2SgAskBody =>
      'ഇതുപോലെ ചോദിച്ചു നോക്കൂ: \"കഴിഞ്ഞ മാസം ഭക്ഷണത്തിന് എത്ര ചെലവഴിച്ചു?\"';

  @override
  String get homeV2SgAskAct => 'Kuber-നോട് ചോദിക്കൂ';

  @override
  String get homeV2SgVoiceTitle => 'ശബ്ദത്തിലൂടെ ഇടപാടുകൾ ചേർക്കുക';

  @override
  String get homeV2SgVoiceBody =>
      'ക്വിക്ക് ആഡിൽ മൈക്ക് ടാപ്പ് ചെയ്ത് ഇങ്ങനെ പറയൂ: \"200 ഉച്ചഭക്ഷണത്തിന്\".';

  @override
  String get homeV2SgVoiceAct => 'പരീക്ഷിക്കൂ';

  @override
  String get homeV2SgWidgetTitle => 'Kuber നിങ്ങളുടെ ഹോം സ്ക്രീനിൽ വയ്ക്കൂ';

  @override
  String get homeV2SgWidgetBody =>
      'ആപ്പ് തുറക്കാതെ ഈ മാസത്തെ ചെലവ് കാണുകയും ഇടപാട് ചേർക്കുകയും ചെയ്യാം.';

  @override
  String get homeV2SgWidgetAct => 'വിജറ്റ് ചേർക്കുക';

  @override
  String get homeV2SgCardsTitle => 'നിങ്ങളുടെ കാർഡുകൾ Kuber Cards-ൽ സൂക്ഷിക്കൂ';

  @override
  String get homeV2SgCardsBody =>
      'കാർഡ് വിവരങ്ങൾ PIN അല്ലെങ്കിൽ വിരലടയാളത്തിന് പിന്നിൽ സൂക്ഷിക്കൂ. അവ ഈ ഫോണിൽ തന്നെ നിൽക്കും.';

  @override
  String get homeV2SgCardsAct => 'Kuber Cards സജ്ജമാക്കുക';

  @override
  String get homeV33TourName => 'എന്തിന് Kuber?';

  @override
  String get homeV33TourMoreSub =>
      'ചെലവ് ട്രാക്ക് ചെയ്യുന്നത് എങ്ങനെ, Kuber എങ്ങനെ സഹായിക്കുന്നു';

  @override
  String get homeV33TourCardBody =>
      'ഓരോ ചെലവും ട്രാക്ക് ചെയ്യുന്നത് എങ്ങനെ സഹായിക്കും, Kuber-ന് എന്ത് ചെയ്യാനാകും.';

  @override
  String get homeV33TourCardAct => 'കാണിക്കൂ';

  @override
  String get homeV33TourCardHideA11y => 'ഈ കാർഡ് മറയ്ക്കുക';

  @override
  String get homeV33TourCardHidden => 'എന്തിന് Kuber? More-ൽ കാണാം.';

  @override
  String get homeV33TourNext => 'അടുത്തത്';

  @override
  String get homeV33TourDone => 'കഴിഞ്ഞു';

  @override
  String homeV33TourPageA11y(int page, int total) {
    return 'പേജ് $page / $total';
  }

  @override
  String get homeV33P1Title => 'ഓരോ ചെലവും കുറിക്കുന്നത് ശീലമാക്കൂ.';

  @override
  String get homeV33P1SubSms =>
      'ചെറിയ ചെലവുകളും പ്രധാനമാണ്. കുറിക്കാൻ എളുപ്പമാണ്, മിക്കതും ബാങ്ക് SMS ചേർക്കും.';

  @override
  String get homeV33P1Sub =>
      'ചെറിയ ചെലവുകളും പ്രധാനമാണ്. Kuber അവ കുറിക്കുന്നത് എളുപ്പമാക്കുന്നു.';

  @override
  String get homeV33P1Try => 'ഇടപാട് ചേർക്കുക';

  @override
  String get homeV33P1ColDate => 'തീയതി';

  @override
  String get homeV33P1ColAmount => 'തുക';

  @override
  String get homeV33P1ColSpent => 'എന്തിന്';

  @override
  String get homeV33P1ColCat => 'വിഭാഗം';

  @override
  String get homeV33P1A11y =>
      'നോട്ട്ബുക്കിൽ എഴുതിയ മൂന്ന് ചെലവുകൾ Kuber ഇടപാടുകളാകുന്നു, ഓരോന്നും ഒരു വിഭാഗവും അക്കൗണ്ടുമായി.';

  @override
  String get homeV33DFood => 'ഫുഡ് ഡെലിവറി';

  @override
  String get homeV33DAuto => 'ഓട്ടോ യാത്ര';

  @override
  String get homeV33DMovie => 'സിനിമ ടിക്കറ്റ്';

  @override
  String get homeV33DCoffee => 'കാപ്പി';

  @override
  String get homeV33DGroc => 'പലചരക്ക്';

  @override
  String get homeV33CFood => 'ഭക്ഷണം';

  @override
  String get homeV33CTransport => 'യാത്ര';

  @override
  String get homeV33CFun => 'വിനോദം';

  @override
  String get homeV33CShopping => 'ഷോപ്പിംഗ്';

  @override
  String get homeV33ABank => 'ബാങ്ക്';

  @override
  String get homeV33ACash => 'പണം';

  @override
  String get homeV33ACard => 'ക്രെഡിറ്റ് കാർഡ്';

  @override
  String get homeV33DBankName => 'നിങ്ങളുടെ ബാങ്ക്';

  @override
  String get homeV33P2Title => 'എല്ലാ അക്കൗണ്ടും. ക്രെഡിറ്റ് കാർഡുകളും.';

  @override
  String get homeV33P2Sub =>
      'ബാങ്ക്, പണം, കാർഡുകൾ, ബില്ലിംഗ് സൈക്കിളും അടയ്ക്കേണ്ട തീയതികളും സഹിതം. ഏത് വിഭാഗവും ചേർക്കാം.';

  @override
  String get homeV33P2Try => 'അക്കൗണ്ടുകൾ തുറക്കുക';

  @override
  String get homeV33P2Balance => 'ബാലൻസ്';

  @override
  String get homeV33P2Due => 'അടയ്ക്കാനുള്ളത്';

  @override
  String homeV33P2Cycle(String start, String end) {
    return 'ബില്ലിംഗ് സൈക്കിൾ $start മുതൽ $end വരെ';
  }

  @override
  String homeV33P2DueOn(String date) {
    return 'അടയ്ക്കേണ്ടത് $date';
  }

  @override
  String get homeV33P2PetCare => 'വളർത്തുമൃഗ പരിചരണം';

  @override
  String get homeV33P2A11y =>
      'ഒരു ബാങ്ക് അക്കൗണ്ട്, പണം, ഒരു ക്രെഡിറ്റ് കാർഡ് എന്നിവ ബാലൻസ് കാണിക്കുന്നു. കാർഡ് അതിന്റെ ബില്ലിംഗ് സൈക്കിളും അടയ്ക്കേണ്ട തീയതിയും കാണിക്കുന്നു. പുതിയ വിഭാഗം, വളർത്തുമൃഗ പരിചരണം, മറ്റുള്ളവയോടൊപ്പം ചേരുന്നു.';

  @override
  String get homeV33P3Title => 'ചെലവിനപ്പുറം ട്രാക്ക് ചെയ്യൂ.';

  @override
  String get homeV33P3Sub =>
      'ബജറ്റുകൾ, നിക്ഷേപങ്ങൾ, വായ്പകൾ, കൊടുത്തതോ വാങ്ങിയതോ ആയ പണം, സബ്സ്ക്രിപ്ഷനുകൾ.';

  @override
  String get homeV33P3Try => 'വരാനിരിക്കുന്ന ഇവന്റുകൾ തുറക്കുക';

  @override
  String get homeV33P3Budget => 'ഭക്ഷണ ബജറ്റ്';

  @override
  String homeV33P3BudgetOf(String spent, String limit) {
    return '$limit-ൽ $spent';
  }

  @override
  String get homeV33P3Inv => 'നിക്ഷേപങ്ങൾ';

  @override
  String get homeV33P3InvTypes => 'SIP, ഓഹരി, FD എന്നിവയും മറ്റും';

  @override
  String get homeV33P3Loan => 'ഭവന വായ്പ';

  @override
  String homeV33P3LoanSub(String amount, int paid, int total) {
    return 'EMI $amount · $total-ൽ $paid';
  }

  @override
  String homeV33P3Lent(String name) {
    return '$name നിങ്ങൾക്ക് തരാനുണ്ട്';
  }

  @override
  String homeV33P3Borrowed(String name) {
    return 'നിങ്ങൾ $name-ന് കൊടുക്കാനുണ്ട്';
  }

  @override
  String get homeV33P3Subs => 'സ്ട്രീമിംഗ് പ്ലാൻ';

  @override
  String homeV33P3SubsSub(String amount) {
    return 'മാസം $amount';
  }

  @override
  String homeV33P3Renews(String date) {
    return '$date-ന് പുതുക്കും';
  }

  @override
  String homeV33P3Next(String date) {
    return 'അടുത്തത് $date';
  }

  @override
  String get homeV33P3A11y =>
      'ഒരു ബജറ്റ് നിറയുന്നു, ഒരു നിക്ഷേപം വളരുന്നു, വായ്പയുടെ EMI അടയ്ക്കുന്നു, കൊടുത്തതും വാങ്ങിയതുമായ പണം കാണുന്നു, ഒരു സബ്സ്ക്രിപ്ഷൻ പുതുക്കുന്നു.';

  @override
  String get homeV33P4Title => 'നിങ്ങളുടെ ചെലവ്, ഒറ്റനോട്ടത്തിൽ.';

  @override
  String get homeV33P4Sub =>
      'ഓരോ ഇടപാടും തിരയാവുന്ന ഒരു ചരിത്രത്തിൽ, വിശകലനം ചെയ്യാൻ പല വഴികളോടെ.';

  @override
  String get homeV33P4Try => 'അനലിറ്റിക്സ് തുറക്കുക';

  @override
  String get homeV33P4Search => 'തിരയുക';

  @override
  String get homeV33P4Query => 'ഭക്ഷണം';

  @override
  String get homeV33P4Today => 'ഇന്ന്';

  @override
  String get homeV33P4Yesterday => 'ഇന്നലെ';

  @override
  String get homeV33P4ByCat => 'വിഭാഗം അനുസരിച്ച്';

  @override
  String get homeV33P4Monthly => 'മാസംതോറും';

  @override
  String get homeV33P4Compare => 'താരതമ്യം';

  @override
  String get homeV33P4A11y =>
      'തിരയാവുന്ന ചരിത്രം ഭക്ഷണത്തിലേക്ക് ചുരുങ്ങുന്നു. പിന്നെ ചാർട്ടുകൾ വിഭാഗം, മാസം, ഈ മാസവും കഴിഞ്ഞ മാസവും തമ്മിലുള്ള ചെലവ് കാണിക്കുന്നു.';

  @override
  String get homeV33P5Title => 'വേണമെങ്കിൽ കൂടുതൽ മുന്നോട്ട്.';

  @override
  String get homeV33P5Ask => 'Ask Kuber';

  @override
  String get homeV33P5AskLine =>
      'നിങ്ങളുടെ പണത്തെക്കുറിച്ച് ചോദിക്കൂ, ഉത്തരം നിങ്ങളുടെ ഫോണിൽ തന്നെ.';

  @override
  String get homeV33P5Cards => 'Kuber Cards';

  @override
  String get homeV33P5CardsLine =>
      'നിങ്ങളുടെ കാർഡുകൾ, എൻക്രിപ്റ്റ് ചെയ്ത് നിങ്ങളുടെ ഫോണിൽ.';

  @override
  String get homeV33P5Notes => 'Kuber Notes';

  @override
  String get homeV33P5NotesLine =>
      'കണക്കുകൂട്ടുകയും ഇടപാടുകൾ ചേർക്കുകയും ചെയ്യുന്ന നോട്ടുകൾ.';

  @override
  String get homeV33P5Calc => 'കാൽക്കുലേറ്ററുകളും ടൂളുകളും';

  @override
  String get homeV33P5CalcLine => 'EMI, SIP, നികുതി എന്നിവയും മറ്റും.';

  @override
  String get homeV33P5Rem => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get homeV33P5RemLine => 'ഒരു ബില്ലും മറക്കില്ല.';

  @override
  String get homeV33P5Try => 'Signature ടൂളുകൾ തുറക്കുക';

  @override
  String get homeV33P5AskQ => 'ഈ മാസം ഭക്ഷണത്തിന് എത്ര ചെലവായി?';

  @override
  String homeV33P5AskA(String amount) {
    return 'ഇതുവരെ $amount, നിങ്ങളുടെ ഭക്ഷണ ബജറ്റിന്റെ 70%.';
  }

  @override
  String get homeV33P5NoteName => 'ഗോവ യാത്ര';

  @override
  String get homeV33P5Hotel => 'ഹോട്ടൽ';

  @override
  String get homeV33P5Taxi => 'ടാക്സി';

  @override
  String get homeV33P5Travel => 'യാത്ര';

  @override
  String get homeV33P5SipCalc => 'SIP കാൽക്കുലേറ്റർ';

  @override
  String homeV33P5PerMonth(String amount) {
    return 'മാസം $amount';
  }

  @override
  String homeV33P5Rate(int rate) {
    return 'വർഷം $rate%';
  }

  @override
  String homeV33P5Years(int n) {
    return '$n വർഷം';
  }

  @override
  String get homeV33P5RemTitle => 'വൈദ്യുതി ബിൽ';

  @override
  String homeV33P5RemDue(String amount) {
    return 'നാളെ അടയ്ക്കണം · $amount';
  }

  @override
  String get homeV33P5A11y =>
      'Ask Kuber ഒരു ചോദ്യത്തിന് ഉത്തരം നൽകുന്നു, ഒരു കാർഡ് മറിയുന്നു, ഒരു നോട്ട് കൂട്ടി ഇടപാടാകുന്നു, ഒരു കാൽക്കുലേറ്റർ ഫലം കാണിക്കുന്നു, ഒരു ബിൽ ഓർമ്മപ്പെടുത്തൽ എത്തുന്നു.';

  @override
  String get homeV3TrkTitle =>
      'നിങ്ങൾ എന്താണ് ട്രാക്ക് ചെയ്യാൻ ആഗ്രഹിക്കുന്നത്?';

  @override
  String get homeV3TrkBody =>
      'ഇഷ്ടമുള്ളത്ര തിരഞ്ഞെടുക്കൂ. Kuber പൊരുത്തമുള്ള വിജറ്റുകൾ നിങ്ങളുടെ ഹോമിൽ ചേർക്കും. പിന്നീട് മാറ്റാം.';

  @override
  String get homeV31TrkBudgets => 'ബജറ്റുകൾ';

  @override
  String get homeV3TrkLoans => 'വായ്പകളും EMI-യും';

  @override
  String get homeV3TrkInvest => 'നിക്ഷേപങ്ങളും SIP-ഉം';

  @override
  String get homeV3TrkLedger => 'കൊടുത്തതോ വാങ്ങിയതോ ആയ പണം';

  @override
  String get homeV3TrkSubs => 'സബ്സ്ക്രിപ്ഷനുകൾ';

  @override
  String get homeV33EdNeedsTxn => 'നിങ്ങളുടെ ആദ്യ ഇടപാടിന് ശേഷം കാണിക്കും';

  @override
  String get homeV33SgQuickTitle => 'Quick Add ഉപയോഗിച്ച് ഒറ്റ വരിയിൽ ചേർക്കുക';

  @override
  String get homeV33SgQuickBody =>
      '\"250 lunch\" പോലെ ടൈപ്പ് ചെയ്യുക അല്ലെങ്കിൽ മൈക്ക് തൊട്ട് പറയുക. Kuber അത് ഇടപാടാക്കും.';

  @override
  String get homeV33SgQuickAct => 'Quick Add പരീക്ഷിക്കുക';

  @override
  String get homeV33SgSmsTitle => 'ബാങ്ക് SMS നിങ്ങളുടെ ചെലവുകൾ ചേർക്കട്ടെ';

  @override
  String get homeV33SgSmsBody =>
      'ഈ ഫോണിലെ ബാങ്ക് SMS വായിച്ച് മിക്ക ഇടപാടുകളും Kuber നിങ്ങൾക്കായി ചേർക്കും. അവ നിങ്ങളുടെ ഫോൺ വിട്ടുപോകില്ല.';

  @override
  String get homeV33SgSmsAct => 'SMS-ൽ നിന്ന് ഇംപോർട്ട് ചെയ്യുക';

  @override
  String get homeV33GsBodyFresh =>
      'നിങ്ങളുടെ അക്കൗണ്ടുകൾ നോക്കൂ, പിന്നെ ആദ്യ ഇടപാട് ചേർക്കൂ. ഒരു മിനിറ്റ് മതി.';

  @override
  String homeV33GsProgress(int done) {
    return '2-ൽ $done പൂർത്തിയായി';
  }

  @override
  String get homeV33GsActAccounts => 'അക്കൗണ്ടുകൾ കാണുക';

  @override
  String get homeV33GsStepAccounts => 'അക്കൗണ്ടുകൾ സജ്ജമാക്കുക';

  @override
  String freqEveryNWeeks(String count) {
    return 'ഓരോ $count ആഴ്ചയിലും';
  }

  @override
  String freqEveryNMonths(String count) {
    return 'ഓരോ $count മാസത്തിലും';
  }

  @override
  String freqEveryNYears(String count) {
    return 'ഓരോ $count വർഷത്തിലും';
  }

  @override
  String get weeksLabel => 'ആഴ്ചകൾ';

  @override
  String get monthsLabel => 'മാസങ്ങൾ';

  @override
  String get yearsLabel => 'വർഷങ്ങൾ';

  @override
  String get intervalInvalid =>
      '1 അല്ലെങ്കിൽ അതിൽ കൂടുതലുള്ള പൂർണ്ണസംഖ്യ നൽകുക';

  @override
  String cadenceThen(String interval) {
    return 'പിന്നെ $interval';
  }

  @override
  String get notifItemMissing => 'ഈ ഇനം ഇപ്പോൾ നിലവിലില്ല.';

  @override
  String nextBackupOn(String date) {
    return 'അടുത്തത്: $date, ആപ്പ് തുറക്കുമ്പോൾ';
  }

  @override
  String get nextBackupNextOpen => 'അടുത്തത്: അടുത്ത തവണ ആപ്പ് തുറക്കുമ്പോൾ';

  @override
  String get backupsAreOn => 'ബാക്കപ്പ് ഓണാണ്';

  @override
  String get backupsAreOnDesc =>
      'ആദ്യ ഷെഡ്യൂൾ ചെയ്ത ബാക്കപ്പ് അടുത്ത തവണ ആപ്പ് തുറക്കുമ്പോൾ നടക്കും. അല്ലെങ്കിൽ ഇപ്പോൾ തന്നെ ബാക്കപ്പ് ചെയ്യുക.';

  @override
  String get msWhenTitle => 'എപ്പോൾ';

  @override
  String get msWhenTitleEmi => 'EMI ഷെഡ്യൂൾ';

  @override
  String get msWhenTitleReminder => 'ആവർത്തനം';

  @override
  String get msWhenDaily => 'ദിവസവും';

  @override
  String get msWhenWeekly => 'ആഴ്ചതോറും';

  @override
  String get msWhenMonthly => 'മാസംതോറും';

  @override
  String get msWhenQuarterly => 'ത്രൈമാസത്തിൽ';

  @override
  String get msWhenHalfYearly => 'ഓരോ 6 മാസത്തിലും';

  @override
  String get msWhenYearly => 'വർഷംതോറും';

  @override
  String get msWhenCustom => 'ഇഷ്ടാനുസൃതം';

  @override
  String get msWhenOnce => 'ഒരിക്കൽ';

  @override
  String get msWhenEvery => 'ഓരോ';

  @override
  String get msWhenUnitDays => 'ദിവസം';

  @override
  String get msWhenUnitWeeks => 'ആഴ്ച';

  @override
  String get msWhenUnitMonths => 'മാസം';

  @override
  String get msWhenUnitYears => 'വർഷം';

  @override
  String get msWhenStartsOn => 'തുടക്കം';

  @override
  String get msWhenOnDay => 'തീയതി';

  @override
  String msWhenOnDayValue(String ordinal) {
    return 'മാസത്തിലെ $ordinal-ാം തീയതി';
  }

  @override
  String get msWhenOn => 'ദിവസം';

  @override
  String get msWhenEnds => 'അവസാനം';

  @override
  String get msWhenEndsNever => 'ഒരിക്കലും ഇല്ല';

  @override
  String get msWhenEndsOnDate => 'ഒരു തീയതിയിൽ';

  @override
  String get msWhenEndsAfter => 'ഇത്ര തവണയ്ക്ക് ശേഷം';

  @override
  String get msWhenEndDate => 'അവസാന തീയതി';

  @override
  String get msWhenTimes => 'തവണ';

  @override
  String get msWhenLockedMonthly => 'എല്ലാ മാസവും ആവർത്തിക്കും';

  @override
  String get msWhenLockedHint => 'EMI മാസംതോറുമാണ്';

  @override
  String get msWhenFirstEmi => 'ആദ്യ EMI';

  @override
  String get msWhenEmiDay => 'EMI തീയതി';

  @override
  String msWhenEmiDayValue(String ordinal) {
    return 'എല്ലാ മാസവും $ordinal-ാം തീയതി';
  }

  @override
  String get msWhenNumberOfEmis => 'EMI കളുടെ എണ്ണം';

  @override
  String get msWhenLastEmi => 'അവസാന EMI';

  @override
  String get msWhenEveryUnitDay => 'ദിവസവും';

  @override
  String get msWhenEveryUnitWeek => 'ആഴ്ചതോറും';

  @override
  String get msWhenEveryUnitMonth => 'മാസംതോറും';

  @override
  String get msWhenEveryUnitYear => 'വർഷംതോറും';

  @override
  String msWhenEveryNDays(String n) {
    return 'ഓരോ $n ദിവസത്തിലും';
  }

  @override
  String msWhenEveryNWeeks(String n) {
    return 'ഓരോ $n ആഴ്ചയിലും';
  }

  @override
  String msWhenEveryNMonths(String n) {
    return 'ഓരോ $n മാസത്തിലും';
  }

  @override
  String msWhenEveryNYears(String n) {
    return 'ഓരോ $n വർഷത്തിലും';
  }

  @override
  String msWhenAnchorWeekday(String weekday) {
    return '$weekday ദിവസം';
  }

  @override
  String msWhenAnchorDay(String ordinal) {
    return '$ordinal-ാം തീയതി';
  }

  @override
  String msWhenAnchorDate(String date) {
    return '$date ന്';
  }

  @override
  String msWhenSentence(
    String interval,
    String anchor,
    String start,
    String end,
  ) {
    return '$interval$anchor, $start മുതൽ, $end.';
  }

  @override
  String get msWhenEndNever => 'അവസാനമില്ല';

  @override
  String msWhenEndUntil(String date) {
    return '$date വരെ';
  }

  @override
  String msWhenEndTimes(String n) {
    return '$n തവണ';
  }

  @override
  String msWhenEndEmis(String n) {
    return '$n EMI';
  }

  @override
  String msWhenOnceSentence(String date) {
    return '$date ന്.';
  }

  @override
  String msWhenLastOn(String date) {
    return 'അവസാനം $date ന്';
  }

  @override
  String msWhenLastEmiOn(String date) {
    return 'അവസാന EMI $date';
  }

  @override
  String msWhenCountTotal(String n) {
    return 'ആകെ $n തവണ';
  }

  @override
  String get msWhenFlagNext => 'അടുത്തത്';

  @override
  String get msWhenFlagToday => 'ഇന്ന് അടയ്ക്കണം';

  @override
  String get msWhenFlagLastDay => 'അവസാന ദിവസം';

  @override
  String get msWhenMonthEnd =>
      'കുറവ് ദിവസങ്ങളുള്ള മാസങ്ങളിൽ ഇത് അവസാന ദിവസം വരും.';

  @override
  String get msWhenErrEndBeforeStart =>
      'അവസാന തീയതി തുടക്ക തീയതിക്ക് ശേഷമായിരിക്കണം.';

  @override
  String get msWhenErrCount => '1 അല്ലെങ്കിൽ അതിൽ കൂടുതൽ നൽകുക.';

  @override
  String get msWhenErrCountPreview =>
      'എത്ര തവണ എന്ന് നൽകുക (1 അല്ലെങ്കിൽ കൂടുതൽ).';

  @override
  String get msCalculated => 'കണക്കാക്കിയത്';

  @override
  String get msViewDetails => 'വിശദാംശങ്ങൾ കാണുക';

  @override
  String get msOpenInCalculator => 'കാൽക്കുലേറ്ററിൽ തുറക്കുക';

  @override
  String get msAdvanced => 'വിപുലമായ ഓപ്ഷനുകൾ';

  @override
  String get msAdvancedSubLoan =>
      'പലിശ തരം, വായ്പാ സംഖ്യകൾ, ഇതിനകം നടക്കുന്നു, ചെലവ്';

  @override
  String get msAlreadyRunning => 'ഇതിനകം നടക്കുന്നുണ്ടോ?';

  @override
  String get msAlreadyRunningSubLoan => 'ഈ വായ്പ ഇന്നേക്ക് മുമ്പ് തുടങ്ങി';

  @override
  String get msAlreadyRunningSubInv => 'ഞാൻ ഇന്നേക്ക് മുമ്പ് നിക്ഷേപിച്ചു';

  @override
  String get msOpeningNote =>
      'പ്രാരംഭ മൂല്യങ്ങൾ ഒരു അക്കൗണ്ടിന്റെയും ബാലൻസ് മാറ്റില്ല.';

  @override
  String get msFromLoans => 'വായ്പകളിൽ നിന്ന്';

  @override
  String get msFromInvestments => 'നിക്ഷേപങ്ങളിൽ നിന്ന്';

  @override
  String msSource(String name) {
    return '$name ൽ നിന്ന്';
  }

  @override
  String msSourceRule(String name) {
    return '$name ൽ നിന്ന് · ആവർത്തനം';
  }

  @override
  String msFilledFrom(String name) {
    return '$name ൽ നിന്ന് പൂരിപ്പിച്ചത്';
  }

  @override
  String msFromCalculator(String calculator) {
    return '$calculator ൽ നിന്ന്';
  }

  @override
  String get msPaused => 'താൽക്കാലികമായി നിർത്തി';

  @override
  String get msEnded => 'അവസാനിച്ചു';

  @override
  String get msClosed => 'അടച്ചു';

  @override
  String get msExample => 'ഉദാഹരണം';

  @override
  String get msBusy =>
      'പ്രോസസ്സ് ചെയ്യുന്നു, അൽപ്പം കഴിഞ്ഞ് വീണ്ടും ശ്രമിക്കുക';

  @override
  String get msLoansTotalOutstanding => 'ആകെ ബാക്കി';

  @override
  String get msLoansMonthlyEmis => 'പ്രതിമാസ EMI';

  @override
  String msLoansNextEmiLine(String date, String name, String amount) {
    return 'അടുത്ത EMI $date · $name · $amount';
  }

  @override
  String get msLoansActive => 'സജീവം';

  @override
  String msLoansRowSub(String amount, String date) {
    return '$amount EMI · അടുത്തത് $date';
  }

  @override
  String get msLoansLeft => 'ബാക്കി';

  @override
  String msLoansProgress(String paid, String total) {
    return '$total ൽ $paid EMI അടച്ചു';
  }

  @override
  String msLoansPaidCount(String paid) {
    return '$paid EMI അടച്ചു';
  }

  @override
  String get msLoansEmptyTitle => 'ഇതുവരെ വായ്പകളില്ല';

  @override
  String get msLoansEmptyBody =>
      'വായ്പ ചേർത്ത് അതിന്റെ EMI, ബാക്കി തുക, അടച്ച പലിശ എന്നിവ കാണുക.';

  @override
  String get msLoansFab => 'വായ്പ ചേർക്കുക';

  @override
  String get msLoansAdd => 'വായ്പ ചേർക്കുക';

  @override
  String get msLoansEdit => 'വായ്പ എഡിറ്റ് ചെയ്യുക';

  @override
  String get msLoansType => 'വായ്പാ തരം';

  @override
  String get msLoansName => 'വായ്പയുടെ പേര്';

  @override
  String get msLoansLender => 'വായ്പ നൽകുന്നയാൾ';

  @override
  String get msLoansEmiAmount => 'EMI തുക';

  @override
  String get msLoansPayFrom => 'ഏത് അക്കൗണ്ടിൽ നിന്ന്';

  @override
  String get msLoansRecordEmis => 'EMI രേഖപ്പെടുത്തുക';

  @override
  String get msLoansRecordAuto => 'സ്വയമേവ';

  @override
  String msLoansRecordAutoHelp(String account) {
    return 'EMI ദിവസം Kuber $account ൽ നിന്ന് EMI രേഖപ്പെടുത്തും.';
  }

  @override
  String get msLoansRecordManual => 'ഞാൻ തന്നെ രേഖപ്പെടുത്തും';

  @override
  String get msLoansSave => 'വായ്പ സേവ് ചെയ്യുക';

  @override
  String get msLoansSaveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get msLoansInterestType => 'പലിശ തരം';

  @override
  String get msLoansReducing => 'കുറയുന്ന ബാലൻസ്';

  @override
  String get msLoansReducingSub => 'മിക്ക ബാങ്ക് വായ്പകളും';

  @override
  String get msLoansFlat => 'ഫ്ലാറ്റ് നിരക്ക്';

  @override
  String get msLoansFlatSub => 'പല കാർ, വ്യക്തിഗത, ഉപഭോക്തൃ വായ്പകൾ';

  @override
  String get msLoansIo => 'ആദ്യം പലിശ മാത്രം കാലയളവ്';

  @override
  String get msLoansIoSub => 'ആദ്യം പ്രീ-EMI, പിന്നെ സാധാരണ EMI';

  @override
  String get msLoansIoMonths => 'പലിശ മാത്രം മാസങ്ങൾ';

  @override
  String msLoansIoNotice(String io, String date, String emi, String n) {
    return '$date വരെ മാസം $io, പിന്നെ $n മാസം മാസം $emi.';
  }

  @override
  String get msLoansNumbers => 'വായ്പാ സംഖ്യകൾ';

  @override
  String get msLoansPrincipal => 'മുതൽ';

  @override
  String get msLoansRate => 'പലിശ നിരക്ക്';

  @override
  String get msLoansTenure => 'കാലാവധി';

  @override
  String get msLoansEmi => 'EMI';

  @override
  String get msLoansYears => 'വർഷം';

  @override
  String get msLoansMonths => 'മാസം';

  @override
  String get msLoansTotalPayable => 'ആകെ അടയ്ക്കേണ്ടത് · ഓപ്ഷണൽ';

  @override
  String get msLoansTotalPayableHint => 'നിരക്കിന് പകരം ഇത് ഉപയോഗിക്കുക';

  @override
  String msLoansOrderHelp(String a, String b, String c) {
    return 'പൂരിപ്പിച്ച ക്രമം: $a, $b, $c.';
  }

  @override
  String msLoansSwapHelp(String field, String other) {
    return 'നിങ്ങൾ $field നൽകി, അതിനാൽ $other (ആദ്യം പൂരിപ്പിച്ചത്) ഇപ്പോൾ കണക്കാക്കും.';
  }

  @override
  String msLoansPreview(String emi, String month, String interest) {
    return 'EMI $emi · $month ൽ അവസാനിക്കും · ആകെ പലിശ $interest';
  }

  @override
  String msLoansPreviewZero(String emi, String month) {
    return 'EMI $emi · $month ൽ അവസാനിക്കും · പലിശയില്ല';
  }

  @override
  String msLoansMismatchMore(String diff) {
    return 'നിങ്ങളുടെ EMI കണക്കാക്കിയതിനേക്കാൾ $diff കൂടുതലാണ്. ഞങ്ങൾ നിങ്ങളുടെ EMI ഉപയോഗിക്കും.';
  }

  @override
  String msLoansMismatchLess(String diff) {
    return 'നിങ്ങളുടെ EMI കണക്കാക്കിയതിനേക്കാൾ $diff കുറവാണ്. ഞങ്ങൾ നിങ്ങളുടെ EMI ഉപയോഗിക്കും.';
  }

  @override
  String get msLoansErrNeverEnds =>
      'ഈ EMI പലിശ പോലും നികത്തുന്നില്ല, അതിനാൽ വായ്പ ഒരിക്കലും അവസാനിക്കില്ല.';

  @override
  String msLoansErrNeverEndsPreview(String interest) {
    return 'പ്രതിമാസ പലിശ $interest. അതിൽ കൂടുതൽ EMI നൽകുക.';
  }

  @override
  String get msLoansErrTotalLow =>
      'ഇത് മുതലിനേക്കാൾ കുറവാണ്. സംഖ്യകൾ പരിശോധിക്കുക.';

  @override
  String get msLoansRun1 => 'വായ്പയുടെ യഥാർത്ഥ വിവരങ്ങൾ എനിക്കറിയാം';

  @override
  String get msLoansRun1Sub => 'നിങ്ങൾ എത്ര അടച്ചുവെന്ന് Kuber കണക്കാക്കും';

  @override
  String get msLoansRun2 => 'ഇന്നത്തെ ബാക്കി എനിക്കറിയാം';

  @override
  String get msLoansRun2Sub => 'ബാങ്ക് സ്റ്റേറ്റ്മെന്റിൽ നിന്ന്';

  @override
  String get msLoansRun3 => 'EMI മാത്രം ട്രാക്ക് ചെയ്യുക';

  @override
  String get msLoansRun3Sub => 'മുതൽ, പലിശ വിഭജനം ഇല്ല';

  @override
  String get msLoansEmisPaid => 'അടച്ച EMI';

  @override
  String get msLoansPrincipalPaid => 'അടച്ച മുതൽ';

  @override
  String get msLoansInterestPaid => 'അടച്ച പലിശ';

  @override
  String get msLoansOutstandingToday => 'ഇന്നത്തെ ബാക്കി';

  @override
  String msLoansRun1Help(String date) {
    return 'വായ്പാ സംഖ്യകളിൽ നിന്നും നിങ്ങളുടെ ആദ്യ EMI ($date) യിൽ നിന്നും കണക്കാക്കിയത്. മാറ്റാൻ ഏതെങ്കിലും മൂല്യത്തിൽ ടാപ്പ് ചെയ്യുക.';
  }

  @override
  String msLoansAdjustment(String diff) {
    return 'ഞങ്ങൾ നിങ്ങളുടെ സംഖ്യ ഉപയോഗിച്ച് വ്യത്യാസം ക്രമീകരണമായി ചേർക്കും: $diff.';
  }

  @override
  String get msLoansEmisLeft => 'ബാക്കി EMI';

  @override
  String msLoansEmisLeftValue(String n, String month) {
    return '$n · അവസാനത്തേത് $month ൽ';
  }

  @override
  String get msLoansPastTotals => 'മുൻകാല ആകെ · ഓപ്ഷണൽ';

  @override
  String get msLoansPastTotalsSub => 'അടച്ച മുതലും പലിശയും';

  @override
  String msLoansRun3Notice(String emi, String ordinal) {
    return 'Kuber എല്ലാ മാസവും $ordinal-ാം തീയതി $emi EMI രേഖപ്പെടുത്തും. വായ്പാ സംഖ്യകൾ ചേർക്കുന്നത് വരെ മുതൽ, പലിശ, ബാക്കി എന്നിവ കാണില്ല.';
  }

  @override
  String get msLoansSpending => 'ചെലവ്';

  @override
  String get msLoansOnlyInterest => 'പലിശ മാത്രം ചെലവായി കണക്കാക്കുക';

  @override
  String get msLoansOnlyInterestHelp =>
      'മുതൽ ഈ വായ്പയിലേക്കുള്ള ട്രാൻസ്ഫറായി കണക്കാക്കും. നിങ്ങളുടെ ബാങ്ക് ബാലൻസ് എന്നാലും മുഴുവൻ EMI കുറയും.';

  @override
  String get msLoansFutureOnly =>
      'ഇത് ഭാവി EMI കൾക്ക് മാത്രം ബാധകം. ഇതിനകം രേഖപ്പെടുത്തിയ EMI കൾ അതുപോലെ കണക്കാക്കും.';

  @override
  String get msLoansOutstanding => 'ബാക്കി';

  @override
  String msLoansEndsOn(String month) {
    return '$month ൽ അവസാനിക്കും';
  }

  @override
  String msLoansNextEmi(String date) {
    return 'അടുത്ത EMI · $date';
  }

  @override
  String get msLoansSplit => 'EMI വിഭജനം';

  @override
  String get msLoansPrincipalL => 'മുതൽ';

  @override
  String get msLoansInterestL => 'പലിശ';

  @override
  String get msLoansTotalInterest => 'ആകെ പലിശ';

  @override
  String get msLoansRecordExtra => 'അധിക പേയ്മെന്റ് രേഖപ്പെടുത്തുക';

  @override
  String get msLoansChangeRate => 'പലിശ നിരക്ക് മാറ്റുക';

  @override
  String get msLoansCloseLoan => 'വായ്പ അടയ്ക്കുക';

  @override
  String get msLoansOutstandingTab => 'ബാക്കി';

  @override
  String get msLoansSplitTab => 'മുതൽ vs പലിശ';

  @override
  String get msLoansMonth => 'മാസം';

  @override
  String get msLoansYear => 'വർഷം';

  @override
  String get msLoansBeforeKuber => 'Kuber ന് മുമ്പ്';

  @override
  String get msLoansNext => 'അടുത്തത്';

  @override
  String msLoansRowSplit(String principal, String interest) {
    return 'മു $principal · പ $interest';
  }

  @override
  String msLoansRowBal(String balance) {
    return 'ബാക്കി $balance';
  }

  @override
  String get msLoansInterestOnly => 'പലിശ മാത്രം';

  @override
  String msLoansEventExtra(String amount, String date) {
    return 'അധിക പേയ്മെന്റ് $amount · $date';
  }

  @override
  String msLoansEventExtraSubTenure(String balance) {
    return 'കാലാവധി കുറയ്ക്കുക · പിന്നീട് ബാക്കി $balance';
  }

  @override
  String msLoansEventExtraSubEmi(String balance) {
    return 'EMI കുറയ്ക്കുക · പിന്നീട് ബാക്കി $balance';
  }

  @override
  String msLoansEventRate(String oldRate, String newRate, String date) {
    return 'നിരക്ക് $oldRate → $newRate · $date മുതൽ';
  }

  @override
  String msLoansEventRateSubTenure(String emi) {
    return 'കാലാവധി ക്രമീകരിക്കുക · EMI $emi ആയി തുടരും';
  }

  @override
  String msLoansEventRateSubEmi(String emi) {
    return 'EMI ക്രമീകരിക്കുക · പുതിയ EMI $emi';
  }

  @override
  String msLoansEventCharge(String amount, String date) {
    return 'ചാർജ് $amount · $date';
  }

  @override
  String msLoansEventRegular(String date) {
    return 'സാധാരണ EMI തുടക്കം · $date';
  }

  @override
  String msLoansYearSub(String n, String paid) {
    return '$n EMI · $paid അടച്ചു';
  }

  @override
  String get msLoansYearEnd => 'വർഷാവസാന ബാക്കി';

  @override
  String msLoansChartNote(String year, String amount) {
    return '$year ലെ ഇടിവ് നിങ്ങളുടെ $amount അധിക പേയ്മെന്റ് മൂലമാണ്.';
  }

  @override
  String msLoansIoBanner(String month, String io, String emi, String date) {
    return '$month വരെ പലിശ മാത്രം: മാസം $io. $emi സാധാരണ EMI $date മുതൽ തുടങ്ങും.';
  }

  @override
  String get msLoansExtraTitle => 'അധിക പേയ്മെന്റ്';

  @override
  String get msLoansExtraQ => 'ഇത് മുതലിലേക്ക് പോകുമോ?';

  @override
  String get msLoansExtraYes => 'അതെ';

  @override
  String get msLoansExtraNo => 'ഇല്ല, ഇത് ഫീസ് അല്ലെങ്കിൽ ചാർജ്';

  @override
  String get msLoansReduceTenure => 'കാലാവധി കുറയ്ക്കുക';

  @override
  String get msLoansReduceTenureSub => 'അതേ EMI, വായ്പ നേരത്തെ അവസാനിക്കും';

  @override
  String get msLoansReduceEmi => 'EMI കുറയ്ക്കുക';

  @override
  String get msLoansReduceEmiSub => 'അതേ അവസാന തീയതി, കുറഞ്ഞ EMI';

  @override
  String get msLoansSavesMore => 'കൂടുതൽ പലിശ ലാഭിക്കും';

  @override
  String msLoansExtraPreviewTenure(String amount, String n) {
    return '$amount പലിശ ലാഭം · $n മാസം നേരത്തെ അവസാനിക്കും';
  }

  @override
  String msLoansExtraPreviewEmi(String amount, String emi) {
    return '$amount പലിശ ലാഭം · EMI $emi ആകും';
  }

  @override
  String get msLoansPrepayCharge => 'മുൻകൂർ പേയ്മെന്റ് ചാർജ് · ഓപ്ഷണൽ';

  @override
  String get msLoansPrepayChargeHint => 'തുക അല്ലെങ്കിൽ %';

  @override
  String msLoansFeeNotice(String outstanding) {
    return 'വായ്പാ ചാർജുകളിൽ ചെലവായി രേഖപ്പെടുത്തി. നിങ്ങളുടെ ബാക്കി $outstanding ആയി തുടരും.';
  }

  @override
  String get msLoansLoanCharges => 'വായ്പാ ചാർജുകൾ';

  @override
  String get msLoansNoNumbersPreview =>
      'ഇത് എത്ര ലാഭിക്കുമെന്ന് കാണാൻ വായ്പാ സംഖ്യകൾ ചേർക്കുക.';

  @override
  String get msLoansNewRate => 'പുതിയ നിരക്ക്';

  @override
  String get msLoansEffectiveFrom => 'പ്രാബല്യ തീയതി';

  @override
  String get msLoansThen => 'പിന്നെ';

  @override
  String get msLoansAdjustEmi => 'EMI ക്രമീകരിക്കുക';

  @override
  String get msLoansAdjustTenure => 'കാലാവധി ക്രമീകരിക്കുക';

  @override
  String msLoansRatePreviewEmi(String emi, String date) {
    return '$date മുതൽ പുതിയ EMI $emi';
  }

  @override
  String msLoansRatePreviewEmiSub(String month, String amount) {
    return 'മുമ്പത്തെപ്പോലെ $month ൽ അവസാനിക്കും · $amount പലിശ ലാഭം';
  }

  @override
  String msLoansRatePreviewTenure(String emi, String month) {
    return 'EMI $emi ആയി തുടരും · $month ൽ അവസാനിക്കും';
  }

  @override
  String msLoansRatePreviewTenureSub(String n, String amount) {
    return '$n മാസം നേരത്തെ · $amount പലിശ ലാഭം';
  }

  @override
  String msLoansRatePreviewTenureSubLater(String n, String amount) {
    return '$n മാസം വൈകി · $amount അധിക പലിശ';
  }

  @override
  String get msLoansFloatingHelp =>
      'ഫ്ലോട്ടിംഗ് നിരക്ക് വായ്പകൾ വായ്പ നൽകുന്നയാളുടെ ബെഞ്ച്മാർക്കിനൊപ്പം മാറും. ഓരോ മാറ്റവും ഇവിടെ രേഖപ്പെടുത്തുക.';

  @override
  String msLoansPaidOff(String name) {
    return '$name പൂർണ്ണമായി അടച്ചു';
  }

  @override
  String msLoansCloseTitle(String name) {
    return '$name അടയ്ക്കണോ?';
  }

  @override
  String get msLoansCloseBody =>
      'ഇത് അടച്ചവ വിഭാഗത്തിലേക്ക് മാറും. EMI നിൽക്കും, ചരിത്രം നിലനിൽക്കും.';

  @override
  String msLoansExtraName(String name) {
    return 'അധിക പേയ്മെന്റ് · $name';
  }

  @override
  String msLoansChargeName(String name) {
    return 'വായ്പാ ചാർജ് · $name';
  }

  @override
  String get msLoansSaved => 'വായ്പ സേവ് ചെയ്തു';

  @override
  String get msLoansRateSaved => 'നിരക്ക് മാറ്റം സേവ് ചെയ്തു';

  @override
  String get msLoansExtraSaved => 'അധിക പേയ്മെന്റ് രേഖപ്പെടുത്തി';

  @override
  String get msInvPortfolio => 'പോർട്ട്ഫോളിയോ മൂല്യം';

  @override
  String get msInvInvested => 'നിക്ഷേപിച്ചത്';

  @override
  String get msInvGain => 'നേട്ടം';

  @override
  String get msInvXirr => 'XIRR';

  @override
  String msInvOverall(String pct) {
    return 'ആകെ $pct';
  }

  @override
  String get msInvUpdateValues => 'മൂല്യങ്ങൾ അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get msInvGroupMutualFunds => 'മ്യൂച്വൽ ഫണ്ടുകൾ';

  @override
  String get msInvGroupStocks => 'ഓഹരികൾ';

  @override
  String get msInvGroupGold => 'സ്വർണ്ണം';

  @override
  String get msInvGroupCrypto => 'ക്രിപ്റ്റോ';

  @override
  String get msInvGroupFixed => 'സ്ഥിര വരുമാനം';

  @override
  String get msInvGroupOther => 'വസ്തുവും മറ്റുള്ളവയും';

  @override
  String msInvStale(String n) {
    return '$n ദിവസം മുമ്പ് അപ്ഡേറ്റ് ചെയ്തു';
  }

  @override
  String msInvUpdatedOn(String month) {
    return '$month ൽ അപ്ഡേറ്റ് ചെയ്തു';
  }

  @override
  String get msInvEmptyTitle => 'ഇതുവരെ നിക്ഷേപങ്ങളില്ല';

  @override
  String get msInvEmptyBody =>
      'ഫണ്ട്, ഓഹരി, FD അല്ലെങ്കിൽ നിങ്ങളുടെ ഏത് സ്വത്തും ചേർക്കുക. അതിന്റെ മൂല്യവും നേട്ടവും Kuber കാണിക്കും.';

  @override
  String get msInvFab => 'നിക്ഷേപം ചേർക്കുക';

  @override
  String get msInvAdd => 'നിക്ഷേപം ചേർക്കുക';

  @override
  String get msInvEdit => 'നിക്ഷേപം എഡിറ്റ് ചെയ്യുക';

  @override
  String get msInvSave => 'നിക്ഷേപം സേവ് ചെയ്യുക';

  @override
  String get msInvPickIntro =>
      'ഇത് ഏത് തരം നിക്ഷേപമാണ്? മൂല്യം മാറുന്ന രീതിക്കനുസരിച്ച് ഫോം മാറും.';

  @override
  String get msInvPickMarket => 'മൂല്യം വിപണിക്കൊപ്പം മാറും';

  @override
  String get msInvPickMarketSub => 'നിങ്ങൾ ഇടയ്ക്കിടെ മൂല്യം അപ്ഡേറ്റ് ചെയ്യും';

  @override
  String get msInvPickFixed => 'സ്ഥിര വരുമാനം';

  @override
  String get msInvPickFixedSub => 'Kuber നിങ്ങൾക്കായി മൂല്യം കണക്കാക്കും';

  @override
  String get msInvPickOther => 'മറ്റുള്ളവ';

  @override
  String get msInvPickOtherSub => 'നിങ്ങൾ അപൂർവമായി മൂല്യം അപ്ഡേറ്റ് ചെയ്യും';

  @override
  String get msInvTypeMutualFund => 'മ്യൂച്വൽ ഫണ്ട്';

  @override
  String get msInvTypeStocks => 'ഓഹരികൾ';

  @override
  String get msInvTypeEtf => 'ETF';

  @override
  String get msInvTypeGold => 'സ്വർണ്ണം';

  @override
  String get msInvTypeCrypto => 'ക്രിപ്റ്റോ';

  @override
  String get msInvTypeFd => 'സ്ഥിര നിക്ഷേപം';

  @override
  String get msInvTypeRd => 'ആവർത്തന നിക്ഷേപം';

  @override
  String get msInvTypePpf => 'PPF';

  @override
  String get msInvTypeBonds => 'ബോണ്ടുകൾ';

  @override
  String get msInvTypeProperty => 'വസ്തു';

  @override
  String get msInvTypeCollectibles => 'ശേഖരണ വസ്തുക്കൾ';

  @override
  String get msInvTypeCustom => 'ഇഷ്ടാനുസൃതം';

  @override
  String get msInvName => 'പേര്';

  @override
  String get msInvHow => 'നിങ്ങൾ എങ്ങനെ നിക്ഷേപിക്കുന്നു?';

  @override
  String get msInvOneTime => 'ഒരിക്കൽ';

  @override
  String get msInvSip => 'SIP';

  @override
  String get msInvAmountInvested => 'നിക്ഷേപിച്ച തുക';

  @override
  String get msInvCurrentValue => 'നിലവിലെ മൂല്യം';

  @override
  String get msInvUnits => 'യൂണിറ്റുകൾ · ഓപ്ഷണൽ';

  @override
  String get msInvUnitsHint => 'ഉദാ. 612.4';

  @override
  String get msInvSipAmount => 'SIP തുക';

  @override
  String get msInvFromAccount => 'ഏത് അക്കൗണ്ടിൽ നിന്ന്';

  @override
  String get msInvStepUp => 'വാർഷിക സ്റ്റെപ്പ്-അപ്പ്';

  @override
  String get msInvStepUpSwitch => 'എല്ലാ വർഷവും കൂട്ടുക';

  @override
  String get msInvStepUpField => 'സ്റ്റെപ്പ്-അപ്പ്';

  @override
  String msInvStepUpNotice(
    String a,
    String b,
    String date1,
    String c,
    String date2,
  ) {
    return 'ഇപ്പോൾ $a, $date1 മുതൽ $b, $date2 മുതൽ $c.';
  }

  @override
  String get msInvPrincipal => 'മുതൽ';

  @override
  String get msInvInstallment => 'തവണ';

  @override
  String get msInvTerms => 'നിബന്ധനകൾ';

  @override
  String get msInvRate => 'പലിശ നിരക്ക്';

  @override
  String get msInvStartDate => 'തുടക്ക തീയതി';

  @override
  String get msInvTenure => 'കാലാവധി';

  @override
  String get msInvCompounding => 'കൂട്ടുപലിശ';

  @override
  String get msInvCompMonthly => 'പ്രതിമാസം';

  @override
  String get msInvCompQuarterly => 'ത്രൈമാസം';

  @override
  String get msInvCompHalfYearly => 'അർദ്ധവാർഷികം';

  @override
  String get msInvCompYearly => 'വാർഷികം';

  @override
  String get msInvPayout => 'പേഔട്ട് തരം';

  @override
  String get msInvPayCumulative => 'സഞ്ചിതം';

  @override
  String get msInvPayMonthly => 'പ്രതിമാസം';

  @override
  String get msInvPayQuarterly => 'ത്രൈമാസം';

  @override
  String get msInvPayYearly => 'വാർഷികം';

  @override
  String get msInvAtMaturity => 'കാലാവധി പൂർത്തിയാകുമ്പോൾ';

  @override
  String msInvMaturityLine(String date, String amount) {
    return '$date ന് · പലിശ $amount';
  }

  @override
  String msInvMaturityLineRd(String date, String amount) {
    return '$date ന് · നിങ്ങൾ $amount നിക്ഷേപിക്കും';
  }

  @override
  String get msInvAutoValue =>
      'Kuber ദിവസവും മൂല്യം കണക്കാക്കും. നിങ്ങൾ ഇത് ഒരിക്കലും അപ്ഡേറ്റ് ചെയ്യേണ്ടതില്ല.';

  @override
  String get msInvInvestedSoFar => 'ഇതുവരെ നിക്ഷേപം';

  @override
  String get msInvUnrealized => 'യാഥാർത്ഥ്യമാകാത്തത്';

  @override
  String get msInvRealized => 'യാഥാർത്ഥ്യമായ നേട്ടം';

  @override
  String get msInvWithdrawn => 'പിൻവലിച്ചത്';

  @override
  String get msInvLastUpdated => 'അവസാന അപ്ഡേറ്റ്';

  @override
  String msInvSipLine(String amount, String ordinal) {
    return '$ordinal-ാം തീയതി $amount';
  }

  @override
  String msInvSipLineStep(String amount, String ordinal, String pct) {
    return '$ordinal-ാം തീയതി $amount · വർഷം +$pct';
  }

  @override
  String get msInvUpdateValue => 'മൂല്യം അപ്ഡേറ്റ് ചെയ്യുക';

  @override
  String get msInvAddMoney => 'പണം ചേർക്കുക';

  @override
  String get msInvWithdraw => 'പിൻവലിക്കുക';

  @override
  String get msInvValueToday => 'ഇന്നത്തെ മൂല്യം';

  @override
  String msInvMatures(String date) {
    return '$date ന് കാലാവധി';
  }

  @override
  String get msInvWithdrawEarly => 'നേരത്തെ പിൻവലിക്കുക';

  @override
  String get msInvLegendValue => 'നിലവിലെ മൂല്യം';

  @override
  String get msInvLegendInvested => 'നിക്ഷേപിച്ച തുക';

  @override
  String get msInvLegendGain => 'നേട്ടം';

  @override
  String get msInvActivity => 'പ്രവർത്തനം';

  @override
  String get msInvActValue => 'മൂല്യം അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String get msInvActSip => 'SIP തവണ';

  @override
  String get msInvActTopUp => 'ടോപ്പ്-അപ്പ്';

  @override
  String get msInvActWithdrawal => 'പിൻവലിക്കൽ';

  @override
  String get msInvActOpening => 'പ്രാരംഭ മൂല്യം';

  @override
  String get msInvActInterest => 'പലിശ ചേർത്തു';

  @override
  String get msInvActOpened => 'നിക്ഷേപം തുറന്നു';

  @override
  String get msInvTransaction => 'ഇടപാട്';

  @override
  String get msInvAddPast => 'മുൻ തീയതിക്കുള്ള മൂല്യം ചേർക്കുക';

  @override
  String get msInvAddPastTitle => 'മുൻകാല മൂല്യം ചേർക്കുക';

  @override
  String get msInvValueOnDate => 'ആ തീയതിയിലെ മൂല്യം';

  @override
  String get msInvPastHelp =>
      'മുൻകാല മൂല്യങ്ങൾ ചാർട്ട് നിറയ്ക്കും. അവ നിലവിലെ മൂല്യമോ ഒരു ബാലൻസോ മാറ്റില്ല.';

  @override
  String get msInvInterestLocked =>
      'പലിശ എൻട്രികൾ കണക്കാക്കുന്നതാണ്, എഡിറ്റ് ചെയ്യാനാവില്ല.';

  @override
  String msInvUpdSub(String n) {
    return '$n ഹോൾഡിംഗുകൾ · ഏകദേശം 30 സെക്കൻഡ്';
  }

  @override
  String get msInvUpdHelp =>
      'സ്ഥിര നിക്ഷേപങ്ങളും PPF ഉം സ്വയം അപ്ഡേറ്റ് ആകും, അതിനാൽ ഇവിടെ ഇല്ല.';

  @override
  String get msInvNewValue => 'പുതിയ മൂല്യം';

  @override
  String msInvSaveN(String n) {
    return '$n മൂല്യങ്ങൾ സേവ് ചെയ്യുക';
  }

  @override
  String get msInvSaveEmpty => 'സേവ് ചെയ്യുക';

  @override
  String msInvSaved(String n, String amount) {
    return '$n മൂല്യങ്ങൾ അപ്ഡേറ്റ് ചെയ്തു. പോർട്ട്ഫോളിയോ $amount.';
  }

  @override
  String get msInvWithdrawAll => 'എല്ലാം പിൻവലിക്കുക';

  @override
  String msInvValueLine(String amount) {
    return 'മൂല്യം $amount';
  }

  @override
  String get msInvRedeemed => 'പിൻവലിച്ച തുക';

  @override
  String get msInvExitLoad => 'എക്സിറ്റ് ലോഡ് · ഓപ്ഷണൽ';

  @override
  String get msInvTax => 'നികുതി · ഓപ്ഷണൽ';

  @override
  String get msInvReceived => 'ലഭിച്ച തുക';

  @override
  String get msInvToAccount => 'ഏത് അക്കൗണ്ടിലേക്ക്';

  @override
  String get msInvDate => 'തീയതി';

  @override
  String get msInvAfter => 'ഈ പിൻവലിക്കലിന് ശേഷം';

  @override
  String msInvCloseTitle(String name) {
    return '$name അടയ്ക്കണോ?';
  }

  @override
  String msInvCloseBody(String amount) {
    return 'നിങ്ങൾക്ക് $amount ലഭിച്ചു. ഇതിന്റെ പ്രകടനം ഇതാ.';
  }

  @override
  String get msInvCloseInvested => 'നിക്ഷേപിച്ചത്';

  @override
  String get msInvCloseReceived => 'ലഭിച്ചത്';

  @override
  String get msInvCloseReturn => 'അന്തിമ വരുമാനം';

  @override
  String get msInvCloseXirr => 'XIRR';

  @override
  String get msInvCloseHeld => 'കൈവശം വെച്ച കാലം';

  @override
  String msInvHeldValue(String n) {
    return '$n മാസം';
  }

  @override
  String get msInvCloseHelp =>
      'ഇത് അടച്ചവ വിഭാഗത്തിലേക്ക് മാറും. തുറന്ന് ചരിത്രം കാണാം.';

  @override
  String get msInvCloseCta => 'ഹോൾഡിംഗ് അടയ്ക്കുക';

  @override
  String get msInvBack => 'തിരികെ';

  @override
  String get msInvPenalty => 'പിഴ നിരക്ക്';

  @override
  String get msInvPenaltySupport =>
      'കാലാവധിക്ക് മുമ്പ് പിൻവലിച്ചാൽ നിങ്ങളുടെ ബാങ്കിന്റെ പിഴ';

  @override
  String get msInvRateAfterPenalty => 'പിഴയ്ക്ക് ശേഷമുള്ള നിരക്ക്';

  @override
  String get msInvInterestEarned => 'നേടിയ പലിശ';

  @override
  String get msInvLessThanToday => 'ഇന്നത്തെ മൂല്യത്തേക്കാൾ കുറവ്';

  @override
  String get msInvWithdrawClose => 'പിൻവലിച്ച് അടയ്ക്കുക';

  @override
  String msInvMatured(String amount, String account) {
    return 'നിങ്ങളുടെ FD കാലാവധി പൂർത്തിയായി: $amount. ഇത് $account ലേക്ക് മാറ്റണോ?';
  }

  @override
  String msInvMaturedSub(String name, String date) {
    return '$name · $date ന് കാലാവധി പൂർത്തിയായി';
  }

  @override
  String get msInvRenew => 'പുതുക്കുക';

  @override
  String msInvMove(String account) {
    return '$account ലേക്ക് മാറ്റുക';
  }

  @override
  String msInvNotifTitle(String amount) {
    return 'നിങ്ങളുടെ FD കാലാവധി പൂർത്തിയായി: $amount';
  }

  @override
  String msInvNotifBody(String account) {
    return 'ഇത് $account ലേക്ക് മാറ്റണോ?';
  }

  @override
  String get msInvNotifLater => 'ഇപ്പോൾ വേണ്ട';

  @override
  String msInvWithdrawName(String name) {
    return 'പിൻവലിക്കൽ · $name';
  }

  @override
  String msInvMaturityName(String name) {
    return 'കാലാവധി · $name';
  }

  @override
  String msInvTopUpName(String name) {
    return 'ടോപ്പ്-അപ്പ് · $name';
  }

  @override
  String get msInvValuesUpdated => 'മൂല്യം അപ്ഡേറ്റ് ചെയ്തു';

  @override
  String msInvClosedSnack(String name) {
    return '$name അടച്ചവയിലേക്ക് മാറ്റി';
  }

  @override
  String get msRecEveryMonth => 'എല്ലാ മാസവും';

  @override
  String get msRecOut => 'ചെലവ്';

  @override
  String get msRecIn => 'വരവ്';

  @override
  String get msRecBills => 'ബില്ലുകളും സബ്സ്ക്രിപ്ഷനുകളും';

  @override
  String get msRecEmis => 'EMI';

  @override
  String get msRecSips => 'SIP';

  @override
  String get msRecIncome => 'വരുമാനം';

  @override
  String get msRecActive => 'സജീവം';

  @override
  String get msRecPaused => 'നിർത്തിവെച്ചവ';

  @override
  String get msRecProcessed => 'അടുത്തിടെ പ്രോസസ്സ് ചെയ്തവ';

  @override
  String get msRecEnded => 'അവസാനിച്ചവ';

  @override
  String msRecRowSub(String interval, String date) {
    return '$interval · അടുത്തത് $date';
  }

  @override
  String msRecNextOnly(String date) {
    return 'അടുത്തത് $date';
  }

  @override
  String msRecDue(String interval, String account) {
    return '$interval · ഇന്ന് അടയ്ക്കണം · $account';
  }

  @override
  String msRecPausedSince(String interval, String month) {
    return '$interval · $month മുതൽ നിർത്തിവെച്ചു';
  }

  @override
  String get msRecViewHistory => 'ചരിത്രത്തിൽ കാണുക';

  @override
  String get msRecEmptyTitle => 'ഇതുവരെ ഒന്നും ആവർത്തിക്കുന്നില്ല';

  @override
  String get msRecEmptyBody =>
      'വാടക, ബില്ലുകൾ, സബ്സ്ക്രിപ്ഷനുകൾ അല്ലെങ്കിൽ ആവർത്തിക്കുന്ന വരുമാനം ചേർക്കുക. വായ്പാ EMI യും SIP യും ഇവിടെ സ്വയം കാണിക്കും.';

  @override
  String get msRecFab => 'ആവർത്തനം ചേർക്കുക';

  @override
  String get msRecNew => 'പുതിയ ആവർത്തനം';

  @override
  String get msRecEdit => 'ആവർത്തനം എഡിറ്റ് ചെയ്യുക';

  @override
  String get msRecExpense => 'ചെലവ്';

  @override
  String get msRecIncomeType => 'വരുമാനം';

  @override
  String get msRecAmount => 'തുക';

  @override
  String get msRecName => 'പേര്';

  @override
  String get msRecCategory => 'വിഭാഗം';

  @override
  String get msRecAccount => 'അക്കൗണ്ട്';

  @override
  String msRecSkipNext(String date) {
    return 'അടുത്തത് ഒഴിവാക്കുക · $date';
  }

  @override
  String get msRecSkipNextShort => 'അടുത്തത് ഒഴിവാക്കുക';

  @override
  String get msRecPause => 'നിർത്തിവെക്കുക';

  @override
  String get msRecResume => 'പുനരാരംഭിക്കുക';

  @override
  String get msRecSave => 'ആവർത്തനം സേവ് ചെയ്യുക';

  @override
  String get msRecSaveChanges => 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക';

  @override
  String get msRecFutureTitle => 'മാറ്റങ്ങൾ ഭാവിയിലേക്ക് മാത്രം ബാധകമാക്കണോ?';

  @override
  String msRecFutureBody(String name, String n) {
    return '$name $n തവണ പ്രവർത്തിച്ചു. ആ ഇടപാടുകൾ അതുപോലെ നിലനിൽക്കും. പുതിയ തുകയും ഷെഡ്യൂളും അടുത്ത തവണ മുതൽ തുടങ്ങും.';
  }

  @override
  String get msRecFutureCta => 'ഭാവിയിലേക്ക് ബാധകമാക്കുക';

  @override
  String msRecSkipped(String date, String date2) {
    return '$date ഒഴിവാക്കി. അടുത്തത് $date2 ന്.';
  }

  @override
  String msRecSkippedEnd(String date) {
    return '$date ഒഴിവാക്കി.';
  }

  @override
  String get msRecUsually => 'സാധാരണയായി';

  @override
  String get msRecLast12 => 'കഴിഞ്ഞ 12 മാസം';

  @override
  String get msRecMonthlyAvg => 'പ്രതിമാസ ശരാശരി';

  @override
  String get msRecProcessedKv => 'പ്രോസസ്സ് ചെയ്തവ';

  @override
  String msRecProcessedN(String n) {
    return '$n തവണ';
  }

  @override
  String get msRecMonthlyTotal => 'പ്രതിമാസ ആകെ';

  @override
  String msRecAvgCaption(String amount) {
    return 'കഴിഞ്ഞ 12 മാസം · ശരാശരി $amount';
  }

  @override
  String get msRecSkippedRow => 'ഒഴിവാക്കി';

  @override
  String get msRecRange12 => '12 മാസം';

  @override
  String get msRecRangeAll => 'എല്ലാം';

  @override
  String msRecDeleteTitle(String name) {
    return '$name ഇല്ലാതാക്കണോ?';
  }

  @override
  String get msRecDeleteBody =>
      'ഇത് ആവർത്തിക്കുന്നത് നിർത്തും. ഇതിനകം ചേർത്ത ഇടപാടുകൾ ചരിത്രത്തിൽ നിലനിൽക്കും.';

  @override
  String msRecPausedSnack(String name) {
    return '$name നിർത്തിവെച്ചു';
  }

  @override
  String msRecResumedSnack(String name, String date) {
    return '$name പുനരാരംഭിച്ചു. അടുത്തത് $date ന്.';
  }

  @override
  String get msRecSaved => 'ആവർത്തനം സേവ് ചെയ്തു';

  @override
  String get msCalcSave => 'സേവ് ചെയ്യുക';

  @override
  String get msCalcAddLoan => 'വായ്പയായി ചേർക്കുക';

  @override
  String get msCalcStartSip => 'ഈ SIP തുടങ്ങുക';

  @override
  String get msCalcAddFd => 'ഈ FD ചേർക്കുക';

  @override
  String get msCalcAddRd => 'ഈ RD ചേർക്കുക';

  @override
  String get msCalcAddInvestments => 'നിക്ഷേപങ്ങളിൽ ചേർക്കുക';

  @override
  String get msCalcEmi => 'EMI കാൽക്കുലേറ്റർ';

  @override
  String get msCalcPrepay => 'വായ്പ മുൻകൂർ പേയ്മെന്റ്';

  @override
  String get msCalcSipAmount => 'SIP തുക';

  @override
  String get msCalcGoal => 'ലക്ഷ്യ ആസൂത്രണം';

  @override
  String get msCalcReturns => 'നിക്ഷേപ വരുമാനം';

  @override
  String get msCalcInflation => 'പണപ്പെരുപ്പം';

  @override
  String get msCalcFdRd => 'FD / RD';

  @override
  String get msCalcPpf => 'PPF കാൽക്കുലേറ്റർ';

  @override
  String get msTxnSourceAuto => 'സ്വയമേവ രേഖപ്പെടുത്തി';

  @override
  String get msTxnSourceSip => 'SIP തവണ';

  @override
  String get msTxnSourceLabel => 'ഉറവിടം';

  @override
  String get msTxnSplit => 'EMI വിഭജനം';

  @override
  String get msTxnDeletedLoan => 'ഇല്ലാതാക്കിയ വായ്പയിൽ നിന്ന്';

  @override
  String get msTxnDeletedInvestment => 'ഇല്ലാതാക്കിയ നിക്ഷേപത്തിൽ നിന്ന്';

  @override
  String get msTxnDeletedRule => 'ഇല്ലാതാക്കിയ ആവർത്തന നിയമത്തിൽ നിന്ന്';

  @override
  String bgStepProcessing(String n) {
    return '$n ആവർത്തന ഇടപാടുകൾ ചേർക്കുന്നു…';
  }

  @override
  String get bgStepProcessingOne => '1 ആവർത്തന ഇടപാട് ചേർക്കുന്നു…';

  @override
  String get bgStepMaturity => 'നിക്ഷേപങ്ങൾ പരിശോധിക്കുന്നു…';

  @override
  String get bgStepBackup => 'ബാക്കപ്പ് ചെയ്യുന്നു…';

  @override
  String get bgStepStarting => 'അപ്ഡേറ്റ് ചെയ്യുന്നു…';

  @override
  String get bgContinues => 'പശ്ചാത്തലത്തിൽ തുടരും';

  @override
  String bgResultRecurring(String n) {
    return '$n ആവർത്തനങ്ങൾ ചേർത്തു';
  }

  @override
  String get bgResultRecurringOne => '1 ആവർത്തനം ചേർത്തു';

  @override
  String get bgResultBackup => 'ബാക്കപ്പ് പൂർത്തിയായി';

  @override
  String bgResultMatured(String n) {
    return '$n നിക്ഷേപങ്ങളുടെ കാലാവധി പൂർത്തിയായി';
  }

  @override
  String get bgFailBackup => 'ബാക്കപ്പ് പരാജയപ്പെട്ടു';

  @override
  String bgFailRecurring(String n) {
    return '$n ആവർത്തന ഇടപാടുകൾ ചേർക്കാനായില്ല';
  }

  @override
  String get bgFailRecurringOne => '1 ആവർത്തന ഇടപാട് ചേർക്കാനായില്ല';

  @override
  String get bgRetry => 'വീണ്ടും ശ്രമിക്കുക';

  @override
  String get bgView => 'കാണുക';

  @override
  String get bgChannelName => 'പശ്ചാത്തല ജോലികൾ';

  @override
  String get bgChannelDesc =>
      'പശ്ചാത്തലത്തിൽ ചേർത്ത ആവർത്തന ഇടപാടുകൾ, EMI, SIP, ബാക്കപ്പുകൾ';

  @override
  String get bgNotifTitle => 'Kuber അപ്ഡേറ്റ് ആകുന്നു';

  @override
  String get bgNotifFailedTitle => 'ഒരു പശ്ചാത്തല ജോലി പരാജയപ്പെട്ടു';

  @override
  String get numFormatAutomatic => 'സ്വയമേവ';

  @override
  String get numFormatAutomaticSub =>
      'രൂപയ്ക്ക് ലക്ഷം, മറ്റ് കറൻസികൾക്ക് സാധാരണ';

  @override
  String get showCurrencyCode => 'ചിഹ്നത്തിന് പകരം കറൻസി കോഡ് കാണിക്കുക';

  @override
  String get showCurrencyCodeSub =>
      'കറൻസികൾക്ക് ഒരേ ചിഹ്നമുള്ളപ്പോൾ ഉപകാരപ്രദം, ഉദാ. C\$, A\$';

  @override
  String get currencySuggested => 'നിർദ്ദേശിച്ചവ';

  @override
  String get currencyAll => 'എല്ലാ കറൻസികളും';

  @override
  String get currencySearchHint => 'പേര്, കോഡ് അല്ലെങ്കിൽ രാജ്യം വഴി തിരയുക';

  @override
  String get currencyNoMatch => 'ഒരു കറൻസിയും പൊരുത്തപ്പെട്ടില്ല';

  @override
  String converterUnavailable(String code) {
    return '$code കൺവെർട്ടറിൽ ഇല്ല. ഇതിന്റെ നിരക്കുകൾ യൂറോപ്യൻ സെൻട്രൽ ബാങ്കിന്റെ പട്ടികയിൽ നിന്നാണ്, അതിൽ ഇത് ഇല്ല.';
  }

  @override
  String get msInfoReducingTitle => 'കുറയുന്ന ബാലൻസ്';

  @override
  String get msInfoReducingLine =>
      'മിക്ക ബാങ്ക് വായ്പകളും. ബാക്കിയുള്ള തുകയ്ക്ക് മാത്രം പലിശ, അതിനാൽ ഓരോ EMI യും മുമ്പത്തേതിനേക്കാൾ അൽപ്പം കൂടുതൽ മുതൽ അടയ്ക്കും.';

  @override
  String msInfoReducingEx(String p, String r, String y, String emi) {
    return '$p, $r നിരക്കിൽ, $y വർഷത്തേക്ക്, EMI $emi.';
  }

  @override
  String get msInfoReducingRow1 => 'ആദ്യ മാസത്തെ പലിശ';

  @override
  String get msInfoReducingRow2 => 'ആദ്യ മാസത്തെ മുതൽ';

  @override
  String get msInfoReducingAfter =>
      'അവസാനമാകുമ്പോൾ ഏകദേശം മുഴുവൻ EMI യും മുതലാണ്.';

  @override
  String get msInfoFlatTitle => 'ഫ്ലാറ്റ് നിരക്ക്';

  @override
  String get msInfoFlatLine =>
      'പല കാർ, വ്യക്തിഗത, ഉപഭോക്തൃ വായ്പകൾ. നിങ്ങൾ അടച്ചുകൊണ്ടിരുന്നാലും മുഴുവൻ കാലാവധിക്കും യഥാർത്ഥ തുകയ്ക്ക് പലിശ.';

  @override
  String msInfoFlatEx(String p, String r, String y) {
    return '$p, $r ഫ്ലാറ്റ്, $y വർഷത്തേക്ക്.';
  }

  @override
  String get msInfoFlatRow1 => 'ഓരോ വർഷത്തെയും പലിശ';

  @override
  String get msInfoFlatRow2 => 'ആകെ പലിശ';

  @override
  String get msInfoFlatRow3 => 'EMI';

  @override
  String msInfoFlatAfter(String r, String amount) {
    return '$r കുറയുന്ന ബാലൻസിൽ ഇതേ വായ്പയ്ക്ക് പലിശ $amount ആകുമായിരുന്നു.';
  }

  @override
  String get msInfoIoTitle => 'ആദ്യം പലിശ മാത്രം കാലയളവോടെ';

  @override
  String get msInfoIoLine =>
      'ഇതിനെ പ്രീ-EMI എന്നും പറയും. ആദ്യ കുറച്ച് മാസം പലിശ മാത്രം അടയ്ക്കും. അതിന് ശേഷം സാധാരണ EMI തുടങ്ങും.';

  @override
  String msInfoIoEx(String p, String r, String n) {
    return '$p, $r നിരക്കിൽ, $n മാസം പലിശ മാത്രം.';
  }

  @override
  String msInfoIoRow1(String n) {
    return 'മാസം 1 മുതൽ $n വരെ';
  }

  @override
  String msInfoIoRow2(String n) {
    return 'പിന്നെ, $n മാസം';
  }

  @override
  String msInfoIoRowValue(String amount) {
    return 'മാസം $amount';
  }

  @override
  String get msInfoIoAfter => 'പലിശ മാത്രം മാസങ്ങളിൽ ബാക്കി കുറയില്ല.';

  @override
  String get msInfoCalculatedTitle => 'കണക്കാക്കുന്ന ഫീൽഡുകൾ';

  @override
  String get msInfoCalculatedLine =>
      'മുതൽ, നിരക്ക്, കാലാവധി, EMI ഇവയിൽ ഏതെങ്കിലും 3 പൂരിപ്പിക്കുക. Kuber നാലാമത്തേത് കണക്കാക്കി \"കണക്കാക്കിയത്\" എന്ന് അടയാളപ്പെടുത്തും.';

  @override
  String get msInfoCalculatedAfter =>
      'നിങ്ങളുടെ സംഖ്യ ഉപയോഗിക്കാൻ കണക്കാക്കിയ ഫീൽഡിൽ ടൈപ്പ് ചെയ്യുക. അപ്പോൾ നിങ്ങൾ ആദ്യം പൂരിപ്പിച്ച ഫീൽഡ് കണക്കാക്കും.';

  @override
  String get msInfoMismatchTitle =>
      'നിങ്ങളുടെ EMI വ്യത്യസ്തമാകുന്നത് എന്തുകൊണ്ട്';

  @override
  String get msInfoMismatchLine =>
      'ബാങ്കുകൾ പലപ്പോഴും EMI റൗണ്ട് ചെയ്യുകയോ വായ്പാ ഇൻഷുറൻസ് ചേർക്കുകയോ ആദ്യ EMI ക്ക് മുമ്പുള്ള ദിവസങ്ങൾക്ക് പലിശ ഈടാക്കുകയോ ചെയ്യും. Kuber എപ്പോഴും നിങ്ങൾ നൽകിയ EMI ഉപയോഗിക്കും.';

  @override
  String get msInfoMismatchRow1 => 'കണക്കാക്കിയ EMI';

  @override
  String get msInfoMismatchRow2 => 'നിങ്ങളുടെ EMI';

  @override
  String get msInfoMismatchRow3 => 'വ്യത്യാസം';

  @override
  String get msInfoRun1Title => 'വായ്പയുടെ യഥാർത്ഥ വിവരങ്ങൾ എനിക്കറിയാം';

  @override
  String get msInfoRun1Line =>
      'വായ്പ അനുവദിച്ചത് പോലെ നൽകുക. ഇന്ന് വരെ നിങ്ങൾ അടച്ചതെല്ലാം Kuber കണക്കാക്കും.';

  @override
  String get msInfoRun2Title => 'ഇന്നത്തെ ബാക്കി എനിക്കറിയാം';

  @override
  String get msInfoRun2Line =>
      'ഏറ്റവും പുതിയ ബാങ്ക് സ്റ്റേറ്റ്മെന്റിലെ ബാക്കി തുക ഉപയോഗിക്കുക. എത്ര EMI ബാക്കിയുണ്ടെന്ന് Kuber കണക്കാക്കും.';

  @override
  String get msInfoRun2After =>
      'മുൻകാല ആകെ ഓപ്ഷണലാണ്. ആജീവനാന്ത പലിശ പൂർണ്ണമാകണമെങ്കിൽ ചേർക്കുക.';

  @override
  String get msInfoRun3Title => 'EMI മാത്രം ട്രാക്ക് ചെയ്യുക';

  @override
  String get msInfoRun3Line =>
      'Kuber ഓരോ EMI യും അതിന്റെ ദിവസം മുതലും പലിശയുമായി വിഭജിക്കാതെ രേഖപ്പെടുത്തും. വായ്പാ സംഖ്യകൾ പിന്നീട് ചേർക്കാം.';

  @override
  String get msInfoAdjustmentTitle => 'ക്രമീകരണം';

  @override
  String get msInfoAdjustmentLine =>
      'നിങ്ങളുടെ സംഖ്യ Kuber ന്റേതിൽ നിന്ന് വ്യത്യസ്തമാണെങ്കിൽ, Kuber നിങ്ങളുടേത് സൂക്ഷിച്ച് വ്യത്യാസം വായ്പയിൽ പ്രാരംഭ ക്രമീകരണമായി രേഖപ്പെടുത്തും.';

  @override
  String get msInfoAdjustmentRow1 => 'Kuber കണക്കാക്കിയത്';

  @override
  String get msInfoAdjustmentRow2 => 'നിങ്ങൾ നൽകിയത്';

  @override
  String get msInfoAdjustmentAfter =>
      'ക്രമീകരണങ്ങൾ വായ്പയെ മാത്രം മാറ്റും. ഒരു അക്കൗണ്ട് ബാലൻസും മാറില്ല.';

  @override
  String get msInfoInterestOnlyTitle => 'പലിശ മാത്രം ചെലവായി കണക്കാക്കുക';

  @override
  String get msInfoInterestOnlyLine =>
      'Analytics, ബജറ്റുകൾ എന്നിവയിൽ ഓരോ EMI യുടെയും പലിശ ഭാഗം മാത്രം ചെലവായി കണക്കാക്കും. മുതൽ ഈ വായ്പയിലേക്കുള്ള ട്രാൻസ്ഫറായി കണക്കാക്കും.';

  @override
  String get msInfoInterestOnlyRow1 => 'പലിശ, ചെലവായി';

  @override
  String get msInfoInterestOnlyRow2 => 'മുതൽ, ട്രാൻസ്ഫറായി';

  @override
  String get msInfoInterestOnlyAfter =>
      'ഏത് രീതിയിലായാലും ബാങ്ക് ബാലൻസ് മുഴുവൻ EMI കുറയും. ഈ മാറ്റം ഭാവി EMI കൾക്ക് മാത്രം.';

  @override
  String get msInfoTenureEmiTitle => 'കാലാവധി കുറയ്ക്കണോ EMI കുറയ്ക്കണോ';

  @override
  String get msInfoTenureEmiLine =>
      'കാലാവധി കുറച്ചാൽ EMI അതേപടി നിലനിൽക്കും, വായ്പ നേരത്തെ അവസാനിക്കും. EMI കുറച്ചാൽ അവസാന തീയതി അതേപടി, ഓരോ EMI യും കുറയും. കാലാവധി കുറയ്ക്കുന്നത് കൂടുതൽ പലിശ ലാഭിക്കും.';

  @override
  String get msInfoPrepayChargeTitle => 'മുൻകൂർ പേയ്മെന്റ് ചാർജ്';

  @override
  String get msInfoPrepayChargeLine =>
      'ചില വായ്പാദാതാക്കൾ അധിക പേയ്മെന്റിന് ഫീസ് ഈടാക്കും. Kuber അത് ചെലവായി രേഖപ്പെടുത്തും. അത് ബാക്കി കുറയ്ക്കില്ല. ഫ്ലോട്ടിംഗ് നിരക്ക് ഭവന വായ്പകൾക്ക് സാധാരണ ഇത് ഇല്ല.';

  @override
  String get msInfoPrepayRow1 => 'മുതലിലേക്ക് പോകുന്നു';

  @override
  String get msInfoPrepayRow2 => 'ചാർജ്, ചെലവായി രേഖപ്പെടുത്തി';

  @override
  String get msInfoPrepayRow3 => 'നിങ്ങളുടെ അക്കൗണ്ടിൽ നിന്ന് പോകുന്നു';

  @override
  String get msInfoFloatingTitle => 'ഫ്ലോട്ടിംഗ് നിരക്ക്';

  @override
  String get msInfoFloatingLine =>
      'ഫ്ലോട്ടിംഗ് നിരക്ക് വായ്പാദാതാവിന്റെ ബെഞ്ച്മാർക്കിനൊപ്പം മാറും, അതിനാൽ വായ്പക്കാലത്ത് മാറാം. അവർ മാറ്റുമ്പോൾ ഇവിടെ രേഖപ്പെടുത്തിയാൽ ഷെഡ്യൂൾ ശരിയായിരിക്കും.';

  @override
  String get msInfoXirrTitle => 'XIRR';

  @override
  String get msInfoXirrLine =>
      'ഓരോ തുകയും എപ്പോൾ വന്നു, എപ്പോൾ പോയി എന്ന് കണക്കിലെടുത്ത നിങ്ങളുടെ വാർഷിക വരുമാനം. ഇതുവഴി SIP യും FD യും ന്യായമായി താരതമ്യം ചെയ്യാം.';

  @override
  String msInfoXirrEx(String amount, String invested, String value) {
    return '3 വർഷം മാസം $amount എന്നാൽ $invested നിക്ഷേപം. ഇന്ന് ഇതിന്റെ മൂല്യം $value.';
  }

  @override
  String get msInfoXirrRow1 => 'ആകെ നേട്ടം';

  @override
  String get msInfoXirrRow2 => 'XIRR';

  @override
  String msInfoXirrValue(String pct) {
    return 'വർഷം $pct';
  }

  @override
  String get msInfoRealizedTitle =>
      'യാഥാർത്ഥ്യമാകാത്തതും യാഥാർത്ഥ്യമായതുമായ നേട്ടം';

  @override
  String get msInfoRealizedLine =>
      'യാഥാർത്ഥ്യമാകാത്ത നേട്ടം കടലാസിലാണ്: ഇന്ന് എല്ലാം വിറ്റാൽ കിട്ടുന്ന നേട്ടം. യാഥാർത്ഥ്യമായ നേട്ടം ഇതിനകം പിൻവലിച്ച പണത്തിൽ നിങ്ങൾ യഥാർത്ഥത്തിൽ നേടിയതാണ്.';

  @override
  String get msInfoProportionalTitle => 'പിൻവലിക്കലുകൾ എങ്ങനെ കണക്കാക്കുന്നു';

  @override
  String get msInfoProportionalLine =>
      'ഒരു ഹോൾഡിംഗിന്റെ ഭാഗം പിൻവലിക്കുമ്പോൾ, പിൻവലിച്ച മൂല്യത്തിന്റെ അതേ അനുപാതത്തിൽ നിക്ഷേപ തുക കുറയും.';

  @override
  String msInfoProportionalEx(String value, String invested, String amount) {
    return 'മൂല്യം $value, നിക്ഷേപം $invested. നിങ്ങൾ $amount പിൻവലിക്കുന്നു, ഇത് മൂല്യത്തിന്റെ 20% ആണ്.';
  }

  @override
  String get msInfoProportionalRow1 => 'നിക്ഷേപം ഇത്ര കുറയും';

  @override
  String get msInfoProportionalRow2 => 'യാഥാർത്ഥ്യമായ നേട്ടം';

  @override
  String get msInfoProportionalRow3 => 'ബാക്കി നിക്ഷേപം';

  @override
  String get msInfoStepupTitle => 'വാർഷിക സ്റ്റെപ്പ്-അപ്പ്';

  @override
  String get msInfoStepupLine =>
      'നിങ്ങളുടെ SIP വർഷത്തിലൊരിക്കൽ നിശ്ചിത ശതമാനം അല്ലെങ്കിൽ തുക കൂടും, സാധാരണ നിങ്ങളുടെ ശമ്പളത്തോടൊപ്പം.';

  @override
  String msInfoStepupEx(String amount) {
    return 'മാസം $amount, 10% സ്റ്റെപ്പ്-അപ്പോടെ.';
  }

  @override
  String msInfoStepupRow(String n) {
    return 'വർഷം $n';
  }

  @override
  String get msInfoCompoundingTitle => 'കൂട്ടുപലിശ';

  @override
  String get msInfoCompoundingLine =>
      'നിങ്ങളുടെ നിക്ഷേപത്തിൽ പലിശ എത്ര തവണ ചേർക്കുന്നു, അതിനും പലിശ കിട്ടും. കൂടുതൽ തവണ എന്നാൽ അൽപ്പം കൂടുതൽ.';

  @override
  String msInfoCompoundingEx(String amount) {
    return '$amount, 7% നിരക്കിൽ 5 വർഷത്തേക്ക്.';
  }

  @override
  String get msInfoPayoutTitle => 'പേഔട്ട് തരം';

  @override
  String get msInfoPayoutLine =>
      'സഞ്ചിതത്തിൽ പലിശ നിക്ഷേപത്തിൽ ചേർന്ന് എല്ലാം കാലാവധിയിൽ ലഭിക്കും. പേഔട്ടിൽ പലിശ മാസം, ത്രൈമാസം അല്ലെങ്കിൽ വർഷം തോറും ബാങ്ക് അക്കൗണ്ടിലേക്ക് വരും.';

  @override
  String get msInfoPayoutRow1 => 'സഞ്ചിതം, കാലാവധിയിൽ';

  @override
  String get msInfoPayoutRow2 => 'ത്രൈമാസ പേഔട്ട്';

  @override
  String msInfoPayoutRow2Value(String amount) {
    return 'ഓരോ ത്രൈമാസവും $amount';
  }

  @override
  String get msInfoPayoutRow3 => 'ത്രൈമാസ പേഔട്ട്, കാലാവധിയിൽ';

  @override
  String get msInfoAccruedTitle => 'ഇന്നത്തെ മൂല്യം';

  @override
  String get msInfoAccruedLine =>
      'ഇതുവരെ നേടിയെങ്കിലും ഇനിയും നൽകാത്ത പലിശ ഉൾപ്പെടെ സ്ഥിര നിക്ഷേപത്തിന്റെ ഇന്നത്തെ മൂല്യം. Kuber ദിവസവും കണക്കാക്കുന്നതിനാൽ നിങ്ങൾ അപ്ഡേറ്റ് ചെയ്യേണ്ടതില്ല.';

  @override
  String get msInfoUpdatedTitle => 'അവസാന അപ്ഡേറ്റ്';

  @override
  String get msInfoUpdatedLine =>
      'വിപണി വിലകൾ ദിവസവും മാറും, പക്ഷേ നിങ്ങൾ അവസാനം നൽകിയ മൂല്യം മാത്രമേ Kuber ന് അറിയൂ. 30 ദിവസത്തിൽ കൂടുതൽ പഴയ മൂല്യങ്ങൾ അടയാളപ്പെടുത്തും, ഏതൊക്കെ അപ്ഡേറ്റ് ചെയ്യണമെന്ന് അറിയാം.';

  @override
  String get msInfoMonthlyTitle => 'പ്രതിമാസ തുക എങ്ങനെ കണക്കാക്കുന്നു';

  @override
  String get msInfoMonthlyLine =>
      'പ്രതിമാസമല്ലാത്തവ മാസച്ചെലവായി മാറ്റും. വായ്പകളിലോ നിക്ഷേപങ്ങളിലോ കണ്ടാലും ഓരോന്നും ഒരിക്കൽ മാത്രം കണക്കാക്കും.';

  @override
  String msInfoMonthlyRow1(String amount) {
    return 'വർഷം $amount';
  }

  @override
  String msInfoMonthlyRow2(String amount) {
    return 'ഓരോ 3 മാസവും $amount';
  }

  @override
  String msInfoMonthlyRow3(String amount) {
    return 'ആഴ്ചതോറും $amount';
  }

  @override
  String get msInfoMonthlyAfter =>
      'ആഴ്ചകൾക്ക് 52 ആഴ്ച ÷ 12. ദിവസേനയുള്ളവയ്ക്ക് മാസം 30 ദിവസം.';

  @override
  String get msRecUndo => 'പഴയപടിയാക്കുക';

  @override
  String get msLoansFirstEmiDate => 'ആദ്യ EMI തീയതി';

  @override
  String get msLoansNextEmiDate => 'അടുത്ത EMI തീയതി';

  @override
  String get appDrawerSection => 'ആപ്പ് ഡ്രോയർ';

  @override
  String get appDrawerDescription =>
      'Kuber Cards, Notes അല്ലെങ്കിൽ Reminders ന് ഫോണിന്റെ ആപ്പ് പട്ടികയിൽ സ്വന്തം ഐക്കൺ നൽകുക.';

  @override
  String get appDrawerAdd => 'ആപ്പ് ഡ്രോയറിൽ ചേർക്കുക';

  @override
  String get appDrawerRemove => 'ആപ്പ് ഡ്രോയറിൽ നിന്ന് നീക്കുക';

  @override
  String get appDrawerCards => 'Kuber Cards';

  @override
  String get appDrawerNotes => 'Kuber Notes';

  @override
  String get appDrawerReminders => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String appDrawerAdded(String name) {
    return '$name ആപ്പ് ഡ്രോയറിൽ ചേർത്തു. കാണാൻ അൽപ്പം സമയമെടുത്തേക്കാം.';
  }

  @override
  String appDrawerRemoved(String name) {
    return '$name ആപ്പ് ഡ്രോയറിൽ നിന്ന് നീക്കി';
  }

  @override
  String get appDrawerFailed =>
      'ആപ്പ് ഡ്രോയർ മാറ്റാനായില്ല. വീണ്ടും ശ്രമിക്കുക.';

  @override
  String get msLoansChangeRateShort => 'നിരക്ക് മാറ്റുക';

  @override
  String msLoansPageOf(String n, String total) {
    return 'വർഷം $n / $total';
  }

  @override
  String get msLoansPrevYear => 'മുൻ വർഷം';

  @override
  String get msLoansNextYear => 'അടുത്ത വർഷം';

  @override
  String get msLoansRecordAutoHelpNoAccount =>
      'EMI ദിവസം നിങ്ങൾ അടയ്ക്കുന്ന അക്കൗണ്ടിൽ നിന്ന് Kuber EMI രേഖപ്പെടുത്തും.';

  @override
  String get betaTag => 'ബീറ്റ';

  @override
  String get appDrawerCardsSub => 'Kuber Cards ആപ്പ് ഡ്രോയറിൽ ചേർക്കുക';

  @override
  String get appDrawerNotesSub => 'Kuber Notes ആപ്പ് ഡ്രോയറിൽ ചേർക്കുക';

  @override
  String get appDrawerRemindersSub =>
      'ഓർമ്മപ്പെടുത്തലുകൾ ആപ്പ് ഡ്രോയറിൽ ചേർക്കുക';

  @override
  String get msLoansViewSchedule => 'EMI ഷെഡ്യൂൾ കാണുക';

  @override
  String get msLoansExtraChoose => 'എന്താണ് മാറേണ്ടത്?';

  @override
  String get msLoansExtraHelp =>
      'അധിക പേയ്മെന്റ് ബാക്കി കുറയ്ക്കും, അതിനാൽ ഇനി മുതൽ പലിശ കുറവ്. ആ ലാഭം എങ്ങനെ വേണമെന്ന് തിരഞ്ഞെടുക്കുക.';

  @override
  String msLoansReduceTenureHow(String emi) {
    return 'മാസം $emi അടച്ചുകൊണ്ടിരിക്കുക. വായ്പ നേരത്തെ അവസാനിക്കും.';
  }

  @override
  String get msLoansReduceEmiHow => 'അവസാന തീയതി അതേപടി. ഓരോ EMI യും കുറയും.';

  @override
  String msLoansReduceTenureResult(String emi, String month, String n) {
    return 'EMI $emi ആയി തുടരും · $month ൽ അവസാനിക്കും, $n മാസം നേരത്തെ';
  }

  @override
  String msLoansReduceEmiResult(String month, String emi) {
    return 'ഇപ്പോഴത്തെപ്പോലെ $month ൽ അവസാനിക്കും · EMI $emi ആകും';
  }

  @override
  String get communityTelegramTitle => 'Kuber കമ്മ്യൂണിറ്റിയിൽ ചേരൂ';

  @override
  String get communityTelegramSubtitle =>
      'വാർത്തകൾ, ടിപ്പുകൾ, സഹായം എന്നിവയ്ക്കുള്ള ഔദ്യോഗിക Telegram ചാനൽ';

  @override
  String get ueTitle => 'വരാനിരിക്കുന്നവ';

  @override
  String get ueViewList => 'ലിസ്റ്റ്';

  @override
  String get ueViewCalendar => 'കലണ്ടർ';

  @override
  String get ueFilter => 'ഫിൽട്ടർ';

  @override
  String get ueFilterHint => 'ലിസ്റ്റിനും കലണ്ടറിനും ബാധകം.';

  @override
  String get ueFilterShow => 'കാണിക്കുക';

  @override
  String get ueFilterType => 'തരം';

  @override
  String get ueFilterReset => 'റീസെറ്റ്';

  @override
  String ueA11yFilter(int count) {
    return 'ഫിൽട്ടർ, $count പ്രയോഗിച്ചു';
  }

  @override
  String get ueRange7 => 'അടുത്ത 7 ദിവസം';

  @override
  String get ueRange30 => 'അടുത്ത 30 ദിവസം';

  @override
  String get ueRange90 => 'അടുത്ത 90 ദിവസം';

  @override
  String get ueTypeAll => 'എല്ലാം';

  @override
  String get ueTypeReminders => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get ueTypeEmis => 'EMI';

  @override
  String get ueTypeSips => 'SIP';

  @override
  String get ueTypeRecurring => 'ആവർത്തനം';

  @override
  String get ueTypeLedger => 'ലെഡ്ജർ';

  @override
  String get uePillReminder => 'ഓർമ്മപ്പെടുത്തൽ';

  @override
  String get uePillEmi => 'EMI';

  @override
  String get uePillSip => 'SIP';

  @override
  String get uePillFd => 'FD';

  @override
  String get uePillRecurring => 'ആവർത്തനം';

  @override
  String get uePillLedger => 'ലെഡ്ജർ';

  @override
  String get uePillCard => 'ക്രെഡിറ്റ് കാർഡ്';

  @override
  String ueEmptyList(int days) {
    return 'അടുത്ത $days ദിവസത്തിൽ ഒന്നുമില്ല';
  }

  @override
  String get ueEmptyListHint =>
      'ഓർമ്മപ്പെടുത്തലുകൾ, EMI, SIP, ആവർത്തനം, ലെഡ്ജർ തീയതികൾ ഇവിടെ കാണാം.';

  @override
  String ueOutAmount(String amount) {
    return '$amount ചെലവ്';
  }

  @override
  String ueInAmount(String amount) {
    return '$amount വരവ്';
  }

  @override
  String ueCardBills(String amount) {
    return 'കാർഡ് ബില്ലുകൾ $amount';
  }

  @override
  String ueDayToday(String date) {
    return 'ഇന്ന്, $date';
  }

  @override
  String get ueCardNote =>
      'കാർഡ് ബില്ലുകൾ ആകെ തുകയിൽ ഇല്ല. കാർഡ് ഉപയോഗിച്ചപ്പോൾ തന്നെ ആ ചെലവ് രേഖപ്പെടുത്തി.';

  @override
  String get ueEmptyDay => 'ഈ ദിവസം ഒന്നുമില്ല';

  @override
  String get ueEmptyMonth => 'ഈ മാസം ഒന്നുമില്ല';

  @override
  String get ueStatusUpcoming => 'വരാനിരിക്കുന്നു';

  @override
  String get ueStatusConfirm => 'സ്ഥിരീകരിക്കണം';

  @override
  String get ueStatusDone => 'പൂർത്തിയായി';

  @override
  String get ueStatusSkipped => 'ഒഴിവാക്കി';

  @override
  String get ueStatusOverdue => 'കാലാവധി കഴിഞ്ഞു';

  @override
  String get ueLegendTitle => 'കലണ്ടറിനെക്കുറിച്ച്';

  @override
  String get ueLegendIntro =>
      'ഓരോ പുള്ളിയും ഒരു ഇവന്റ്. 3 പുള്ളി വരെ കാണിക്കും, പിന്നെ എണ്ണം.';

  @override
  String get ueLegendReminders => 'ഓർമ്മപ്പെടുത്തലുകൾ';

  @override
  String get ueLegendEmis => 'EMI';

  @override
  String get ueLegendSips => 'SIP, FD';

  @override
  String get ueLegendRecurring => 'ആവർത്തനം';

  @override
  String get ueLegendLedger => 'കൊടുത്തതും വാങ്ങിയതും';

  @override
  String get ueLegendCards => 'ക്രെഡിറ്റ് കാർഡുകൾ';

  @override
  String get ueLegendDays => 'ദിവസങ്ങൾ';

  @override
  String get ueLegendToday => 'ഇന്ന്';

  @override
  String get ueLegendSelected => 'തിരഞ്ഞെടുത്തത്';

  @override
  String get ueLegendOverdue => 'കാലാവധി കഴിഞ്ഞു';

  @override
  String get ueLegendSkipped => 'ഒഴിവാക്കി';

  @override
  String get ueLegendOtherMonth => 'മറ്റ് മാസം';

  @override
  String get ueLegendTotals =>
      'ചെലവും വരവും മാസത്തെ ആകെ തുകയാണ്, ഒഴിവാക്കിയവയും തുകയില്ലാത്ത ഓർമ്മപ്പെടുത്തലുകളും ഒഴികെ. കാർഡ് ബില്ലുകൾ വേറെ കാണിക്കുന്നു, കാരണം കാർഡ് ഉപയോഗിച്ചപ്പോൾ തന്നെ ആ ചെലവ് രേഖപ്പെടുത്തി.';

  @override
  String ueA11yToday(String date) {
    return 'ഇന്ന്, $date';
  }

  @override
  String get ueA11ySelected => 'തിരഞ്ഞെടുത്തു';

  @override
  String ueA11yEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ഇവന്റുകൾ',
      one: '1 ഇവന്റ്',
      zero: 'ഇവന്റ് ഇല്ല',
    );
    return '$_temp0';
  }

  @override
  String ueA11yDue(String amount) {
    return '$amount അടയ്ക്കാനുണ്ട്';
  }

  @override
  String ueA11yCardBill(String amount) {
    return 'കാർഡ് ബിൽ $amount';
  }

  @override
  String ueA11yOverdue(int count) {
    return '$count കാലാവധി കഴിഞ്ഞു';
  }

  @override
  String ueA11yConfirm(int count) {
    return '$count സ്ഥിരീകരിക്കണം';
  }

  @override
  String get ueA11yHidden => 'തുകകൾ മറച്ചിരിക്കുന്നു';

  @override
  String ueA11yOtherMonthNext(String date) {
    return '$date, അടുത്ത മാസം';
  }

  @override
  String ueA11yOtherMonthPrev(String date) {
    return '$date, കഴിഞ്ഞ മാസം';
  }

  @override
  String ueA11yPrevMonth(String month) {
    return 'കഴിഞ്ഞ മാസം, $month';
  }

  @override
  String ueA11yNextMonth(String month) {
    return 'അടുത്ത മാസം, $month';
  }

  @override
  String ueA11yWeekCollapsed(String date) {
    return '$date ആഴ്ച, ചുരുക്കി. മാസം കാണാൻ രണ്ടുതവണ ടാപ്പ് ചെയ്യുക.';
  }

  @override
  String get ueA11yHandle => 'മുഴുവൻ മാസം കാണിക്കുക';

  @override
  String get themeExpressiveTitle => 'എക്സ്പ്രസീവ് നിറങ്ങൾ';

  @override
  String get themeExpressiveSubtitle =>
      'പശ്ചാത്തലത്തിൽ തീം നിറത്തിന്റെ നേരിയ ഛായ';

  @override
  String get themePureBlackTitle => 'പൂർണ്ണ കറുപ്പ്';

  @override
  String get themePureBlackSubtitle =>
      'ഡാർക്ക് മോഡിൽ കറുത്ത പശ്ചാത്തലം. OLED സ്ക്രീനുകളിൽ ബാറ്ററി ലാഭിക്കും.';

  @override
  String get themePureBlackHelperSystem =>
      'ഫോൺ ഡാർക്ക് മോഡിലായിരിക്കുമ്പോൾ ബാധകം';

  @override
  String get themePureBlackDisabledA11y =>
      'പൂർണ്ണ കറുപ്പ്. ഓഫ്. ഡാർക്ക് മോഡിൽ പ്രവർത്തിക്കും.';

  @override
  String get msLoansReopen => 'ലോൺ വീണ്ടും തുറക്കുക';

  @override
  String msLoansReopenTitle(String name) {
    return '$name വീണ്ടും തുറക്കണോ?';
  }

  @override
  String get msLoansReopenBody =>
      'ഇതിന്റെ EMI അടുത്ത തീയതി മുതൽ വീണ്ടും തുടങ്ങും. അടച്ചിരുന്ന സമയത്തേക്ക് ഒന്നും ചേർക്കില്ല.';
}
