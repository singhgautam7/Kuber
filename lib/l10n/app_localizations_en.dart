// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get saveLabel => 'Save';

  @override
  String get editLabel => 'Edit';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get gotIt => 'Got it';

  @override
  String get skip => 'Skip';

  @override
  String get search => 'Search';

  @override
  String get getStarted => 'Get started';

  @override
  String get starting => 'Starting...';

  @override
  String get startJourney => 'Start my journey';

  @override
  String get yourMoneyYourRules => 'Your money.\nYour rules.';

  @override
  String get onboardingPage1Description =>
      'An expense manager that lives on your device. No cloud, no signup, no compromises.';

  @override
  String offlineFirstBadge(String version) {
    return 'OFFLINE-FIRST · $version';
  }

  @override
  String get privateByDesign => 'Private by design.';

  @override
  String get onboardingPage2Description =>
      'Your money stays on your device. No telemetry, no syncing, no third parties.';

  @override
  String get fullyOfflineTitle => 'Fully offline';

  @override
  String get fullyOfflineBody =>
      'No cloud servers. Nothing to breach. Works in airplane mode.';

  @override
  String get noAccountTitle => 'No account needed';

  @override
  String get noAccountBody =>
      'Open the app and start. Zero signup, zero friction.';

  @override
  String get privacyModeTitle => 'Privacy mode';

  @override
  String get privacyModeBody =>
      'One tap hides every balance when you hand over your phone.';

  @override
  String get modulesTitle => '8+ MODULES · ZERO CLUTTER';

  @override
  String get everythingInOnePlace => 'Everything in\none quiet place.';

  @override
  String get onboardingPage3Description =>
      'Track expenses, plan budgets, monitor portfolios, and ask Kuber for answers.';

  @override
  String get budgetsModule => 'Budgets';

  @override
  String get analyticsModule => 'Analytics';

  @override
  String get recurringModule => 'Recurring';

  @override
  String get lendBorrowModule => 'Lend &\nborrow';

  @override
  String get investmentsModule => 'Investments';

  @override
  String get askKuberModule => 'Ask Kuber AI';

  @override
  String get toolsModule => 'Tools &\nCalculators';

  @override
  String get tagsCategoriesModule => 'Tags &\nCategories';

  @override
  String get andMuchMore => '••• and much more!';

  @override
  String get makeItYours => 'Make it yours.';

  @override
  String get threeQuickChoices => 'Three quick choices and you\'re in.';

  @override
  String get yourName => 'YOUR NAME';

  @override
  String get currency => 'CURRENCY';

  @override
  String get theme => 'THEME';

  @override
  String get language => 'LANGUAGE';

  @override
  String get namePlaceholder => 'Your name';

  @override
  String get nameRequired => 'Please enter your name';

  @override
  String get nameTooLong => 'Name must be 15 characters or fewer';

  @override
  String get themeLight => 'LIGHT';

  @override
  String get themeDark => 'DARK';

  @override
  String get themeSystem => 'SYSTEM';

  @override
  String get justSoYouKnow => 'Just so you know';

  @override
  String get goToTutorials => 'Go to tutorials';

  @override
  String get exploreAtOwnPace => 'You can explore at your own pace';

  @override
  String get exploreAtOwnPaceBody =>
      'Kuber is built to feel familiar, so you can start logging right away.';

  @override
  String get walkthroughNearby => 'A walkthrough is always nearby';

  @override
  String get walkthroughNearbyBody =>
      'Open More, then App Tutorial, whenever you want a quick guided tour.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle =>
      'Customize how Kuber looks, feels and behaves for you.';

  @override
  String get profileSection => 'PROFILE';

  @override
  String get profileDescription => 'How Kuber knows you.';

  @override
  String get yourNameLabel => 'Your Name';

  @override
  String get userNameUpdated => 'Name updated';

  @override
  String get appearanceSection => 'APPEARANCE';

  @override
  String get appearanceDescription => 'How Kuber looks to you.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSubtitle => 'Light, dark, or match your phone';

  @override
  String get bottomNavLabel => 'Bottom Navigation';

  @override
  String get bottomNavSubtitle => 'Standard bar or floating pill';

  @override
  String get moreTabLayoutLabel => 'More Tab Layout';

  @override
  String get moreTabLayoutSubtitle => 'Simple list or Modern hero layout';

  @override
  String get widgetsSection => 'WIDGETS';

  @override
  String get widgetsDescription => 'Choose what shows on Home and Analytics.';

  @override
  String get homeWidgetsLabel => 'Home Widgets';

  @override
  String homeWidgetsSubtitle(String count) {
    return '$count enabled · drag to reorder';
  }

  @override
  String get analyticsWidgetsLabel => 'Analytics Widgets';

  @override
  String analyticsWidgetsSubtitle(String count) {
    return '$count enabled · drag to reorder';
  }

  @override
  String get moneyDisplaySection => 'MONEY DISPLAY';

  @override
  String get moneyDisplayDescription =>
      'How currency and amounts are shown across the app.';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get currencySubtitle => 'Symbol and code shown on amounts';

  @override
  String get numberFormatLabel => 'Number Format';

  @override
  String get numberFormatSubtitle =>
      'Indian (1,23,000) or International (123,000)';

  @override
  String get transactionsSection => 'TRANSACTIONS';

  @override
  String get transactionsDescription =>
      'Your defaults when adding new entries.';

  @override
  String get defaultAccountLabel => 'Default Account';

  @override
  String get defaultAccountSubtitle => 'Pre-selected when you Quick Add';

  @override
  String get horizontalSwipeLabel => 'Horizontal Swipe';

  @override
  String get horizontalSwipeSubtitle => 'What swiping left or right does';

  @override
  String get privacySecuritySection => 'PRIVACY & SECURITY';

  @override
  String get privacySecurityDescription =>
      'Keep your numbers private and your app locked.';

  @override
  String get privacyModeLabel => 'Privacy Mode';

  @override
  String get privacyModeSubtitle => 'Hide all balances and amounts';

  @override
  String get biometricLockLabel => 'Biometric Lock';

  @override
  String get biometricLockSubtitle => 'Unlock with FaceID or Fingerprint';

  @override
  String get aboutSection => 'ABOUT';

  @override
  String get aboutDescription => 'Learn about Kuber and the person behind it.';

  @override
  String get aboutKuberLabel => 'About Kuber';

  @override
  String get aboutKuberSubtitle =>
      'Vision, origin, and a letter from the developer';

  @override
  String get clearDefault => 'Clear Default';

  @override
  String get defaultAccountCleared => 'Default account cleared';

  @override
  String get noAccountsFound => 'No accounts found.';

  @override
  String get biometricNotAvailable =>
      'Device authentication is not available or set up';

  @override
  String get biometricEnabledMsg => 'Biometric lock enabled';

  @override
  String get biometricDisabledMsg => 'Biometric lock disabled';

  @override
  String get updateNameTitle => 'Update Name';

  @override
  String get enterNameHint => 'Enter name';

  @override
  String get saveBtn => 'Save';

  @override
  String get themeLightChoice => 'Light';

  @override
  String get themeDarkChoice => 'Dark';

  @override
  String get themeSystemChoice => 'System';

  @override
  String get themeSubtitleLight => 'Bright surfaces, dark text';

  @override
  String get themeSubtitleDark => 'Black surfaces, light text';

  @override
  String get themeSubtitleSystem => 'Follow your phone setting';

  @override
  String get navClassicChoice => 'Classic';

  @override
  String get navModernChoice => 'Modern';

  @override
  String get navSubtitleClassic => 'Standard bar';

  @override
  String get navSubtitleModern => 'Floating pill';

  @override
  String get numFormatIndian => 'Indian';

  @override
  String get numFormatInternational => 'International';

  @override
  String get swipeChangeTabs => 'Change tabs';

  @override
  String get swipeRowActions => 'Row actions';

  @override
  String get swipeSubtitleChangeTabs =>
      'Quickly switch between main app sections by swiping across the screen';

  @override
  String get swipeSubtitleRowActions =>
      'Perform quick actions like edit or delete by swiping on individual history items';

  @override
  String spentTodayInsight(String amount, String diff, String avg) {
    return 'You spent $amount today, which is $diff above your 30-day daily average of $avg';
  }

  @override
  String weekdayPatternInsight(String highest, String dayName, String median) {
    return 'You typically spend $highest on $dayName vs $median on other days';
  }

  @override
  String topCategoryInsight(String pct, String catName, String amount) {
    return '$pct% of spending goes to $catName ($amount)';
  }

  @override
  String categoryTrendInsight(String catName, String change) {
    return '$catName spending is $change vs last month';
  }

  @override
  String monthComparisonInsight(String change) {
    return 'Spending is $change vs this point last month';
  }

  @override
  String weekendVsWeekdayInsight(String weekend, String weekday) {
    return 'Weekend transactions average $weekend vs $weekday on weekdays';
  }

  @override
  String biggestExpenseInsight(String name, String amount, String ratio) {
    return '$name ($amount) was $ratio× your typical spend';
  }

  @override
  String get savingsTrendPositive =>
      'You\'re saving money this month. Keep it up!';

  @override
  String savingsTrendInsight(String change) {
    return 'Savings are $change vs last month';
  }

  @override
  String savingsTrendDipInsight(String change) {
    return 'Savings dipped $change vs last month';
  }

  @override
  String recurringBurdenInsight(String pct) {
    return '$pct of spending is from recurring transactions';
  }

  @override
  String streakInsight(String streak) {
    return '$streak-day spending-free streak before today!';
  }

  @override
  String spendingFasterInsight(String weekStr, String diffStr, String baseStr) {
    return 'You\'re spending $weekStr/day this week, which is $diffStr faster than your usual $baseStr/day';
  }

  @override
  String categoryConcentrationInsight(String pctStr, String amtStr) {
    return '$pctStr of your spending ($amtStr) goes to just 3 categories';
  }

  @override
  String loanEmiTotalInsight(String amount) {
    return 'Loan EMIs add up to $amount this month';
  }

  @override
  String loanPayoffCountdownInsight(
    String name,
    String months,
    String pluralSuffix,
  ) {
    return '$name is about $months month$pluralSuffix from payoff';
  }

  @override
  String loanInterestPaidInsight(String amount) {
    return 'Total loan interest paid is $amount so far';
  }

  @override
  String ledgerOutstandingInsight(String receive, String owe) {
    return 'Open lend and borrow totals are $receive owed to you and $owe owed by you';
  }

  @override
  String ledgerOldestOpenInsight(String personName, String ageDays) {
    return '$personName has the oldest open entry at $ageDays days';
  }

  @override
  String investmentPortfolioChangeInsight(String amount) {
    return 'Your portfolio is $amount versus invested value';
  }

  @override
  String investmentTopPerformerInsight(String name, String pct) {
    return '$name is your top performer at $pct gain';
  }

  @override
  String investmentPeriodInvestedInsight(String amount) {
    return 'You invested $amount this month';
  }

  @override
  String get fallbackTipInsight =>
      'Start adding transactions to unlock smart insights';

  @override
  String fallbackTotalInsight(String amount) {
    return 'You\'ve spent $amount in the last 30 days';
  }

  @override
  String get spentLastWeek => 'spent last week';

  @override
  String spentLastMonth(String month) {
    return 'spent in $month';
  }

  @override
  String spentLastYear(String year) {
    return 'spent in $year';
  }

  @override
  String averageDay(String amount) {
    return 'About $amount a day on average';
  }

  @override
  String biggestDay(String day, String amount) {
    return '$day was your biggest day at $amount';
  }

  @override
  String savedEarned(String pct) {
    return 'You saved $pct% of what you earned';
  }

  @override
  String biggestSingleSpend(String name, String category) {
    return 'Biggest single spend was $name on $category';
  }

  @override
  String get spentLess => 'You spent less than before';

  @override
  String get spentMore => 'You spent more than before';

  @override
  String get comparedTitle => 'Compared';

  @override
  String get comparedLess => 'You spent less than before';

  @override
  String get comparedMore => 'You spent more than before';

  @override
  String deltaLess(String amount, String label) {
    return '$amount less than $label';
  }

  @override
  String deltaMore(String amount, String label) {
    return '$amount more than $label';
  }

  @override
  String get monthlyEmi => 'Monthly EMI';

  @override
  String get principal => 'Principal';

  @override
  String get lender => 'Lender';

  @override
  String ledgerOwesYou(String person, String amount) {
    return '$person owes you $amount';
  }

  @override
  String ledgerYouOwe(String person, String amount) {
    return 'You owe $person $amount';
  }

  @override
  String get ledgerEntryOpen => 'This entry is still open.';

  @override
  String get portfolioCheck => 'Portfolio check';

  @override
  String get investedLabel => 'Invested';

  @override
  String get currentValueLabel => 'Current value';

  @override
  String get welcomeTitle => 'Welcome to Kuber';

  @override
  String get welcomeSubtitle =>
      'Thanks for installing. Your money, beautifully tracked.';

  @override
  String get basicsTitle => 'Track every rupee';

  @override
  String get basicsSubtitle =>
      'Expenses, income, transfers, and budgets, all in one place.';

  @override
  String get beyondBasicsTitle => 'There is more in here';

  @override
  String get beyondBasicsSubtitle =>
      'Lend and borrow, EMIs, investments, and handy calculators.';

  @override
  String get spaceIsYoursTitle => 'Your money stories';

  @override
  String get spaceIsYoursSubtitle =>
      'Recaps and highlights about your spending will appear right here.';

  @override
  String get spentYesterday => 'spent yesterday';

  @override
  String topSpend(String name, String category) {
    return 'Top spend: $name on $category';
  }

  @override
  String get topCategories => 'Top categories';

  @override
  String get noSpendDay => 'A no spend day. Nice.';

  @override
  String noSpendStreak(String streak) {
    return 'That is a $streak day no spend streak';
  }

  @override
  String noSpendStreakEnded(String streak) {
    return 'Your $streak day no spend streak ended';
  }

  @override
  String get dailyRecapHeader => 'Daily';

  @override
  String get weeklyRecapHeader => 'Weekly recap';

  @override
  String get monthlyRecapHeader => 'Monthly recap';

  @override
  String get yearlyRecapHeader => 'Year in review';

  @override
  String get highlightHeader => 'Highlight';

  @override
  String get loansHeader => 'Loans';

  @override
  String get ledgerHeader => 'Lend / Borrow';

  @override
  String get investmentsHeader => 'Investments';

  @override
  String averageMonth(String amount) {
    return 'About $amount a month on average';
  }

  @override
  String biggestMonth(String month, String amount) {
    return '$month was your biggest month at $amount';
  }

  @override
  String get lessLabel => 'less';

  @override
  String get moreLabel => 'more';

  @override
  String get theWeekBefore => 'the week before';

  @override
  String aboveAverage(String amount) {
    return '$amount above your 30-day average';
  }

  @override
  String belowAverage(String amount) {
    return '$amount below your 30-day average';
  }

  @override
  String get toLabel => 'to';

  @override
  String throughPeriod(String date) {
    return 'Through $date';
  }

  @override
  String get thisWeek => 'This Week';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get previousMonth => 'Previous Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get previousYear => 'Previous Year';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get chooseAppLanguage => 'Choose app language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get searchLanguage => 'Search language';

  @override
  String get noLanguagesFound => 'No languages found';

  @override
  String get appearanceCategory => 'Appearance';

  @override
  String get moneyDisplayCategory => 'Money Display';

  @override
  String get transactionsCategory => 'Transactions';

  @override
  String get notSet => 'Not set';

  @override
  String get setYourName => 'Set your name';

  @override
  String get simpleLabel => 'Simple';

  @override
  String get creditCardLabel => 'Credit Card';

  @override
  String get bankCashLabel => 'Bank / Cash';

  @override
  String setAsDefault(String name) {
    return '$name set as default';
  }

  @override
  String get nameSheetHint => 'e.g. Gautam';

  @override
  String get doneLabel => 'Done';

  @override
  String get moreTabSimpleSubtitle =>
      'Uniform list of cards. Familiar and predictable.';

  @override
  String get moreTabModernSubtitle =>
      'Hero items, tile grid and compact lists. Differentiated by section.';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get searchCurrencyHint => 'Search by name, code or symbol…';

  @override
  String get noCurrenciesFound => 'No currencies found';

  @override
  String get welcomeHeader => 'Welcome';

  @override
  String get basicsHeader => 'The basics';

  @override
  String get beyondBasicsHeader => 'Beyond the basics';

  @override
  String get spaceIsYoursHeader => 'This space is yours';

  @override
  String get homeSubtitle1 => 'Let\'s manage your money wisely';

  @override
  String get homeSubtitle2 => 'Track every rupee, every day';

  @override
  String get homeSubtitle3 => 'Stay on top of your finances';

  @override
  String get homeSubtitle4 => 'Your wallet will thank you later';

  @override
  String get homeSubtitle5 => 'Small savings, big results';

  @override
  String get homeSubtitle6 => 'Every transaction counts';

  @override
  String get homeSubtitle7 => 'Building smart money habits';

  @override
  String get greetingMorning => 'Morning';

  @override
  String get greetingAfternoon => 'Afternoon';

  @override
  String get greetingEvening => 'Evening';

  @override
  String get errorLabel => 'Error';

  @override
  String get last7Days => 'LAST 7 DAYS';

  @override
  String get netLabel => 'NET';

  @override
  String get spendingAnalysisEmpty =>
      'No income or expense transactions in the last 7 days. Add a transaction to see your spending analysis here.\n\nNote: Transfers are not included.';

  @override
  String get notificationsTooltip => 'Notifications';

  @override
  String get askKuber => 'Ask Kuber';

  @override
  String get privacyModeOn => 'Privacy mode: On';

  @override
  String get privacyModeOff => 'Privacy mode: Off';

  @override
  String get accountsLabel => 'ACCOUNTS';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get outstandingLabel => 'OUTSTANDING';

  @override
  String get availableLabel => 'AVAILABLE';

  @override
  String get bankLabel => 'Bank';

  @override
  String get walletLabel => 'Wallet';

  @override
  String get cashLabel => 'Cash';

  @override
  String get usedLabel => 'used';

  @override
  String get limitLabel => 'limit';

  @override
  String get recurringHeader => 'RECURRING';

  @override
  String get statusProcessed => 'PROCESSED';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusScheduled => 'SCHEDULED';

  @override
  String get quickAddInvalidAmount =>
      'Enter a valid amount (e.g. 200 on coffee)';

  @override
  String quickAddNoAccountNamed(String name) {
    return 'No account named \"$name\" found';
  }

  @override
  String get quickAddCouldNotResolveCategory => 'Could not resolve category';

  @override
  String quickAddAdded(String amount, String category) {
    return '$amount added to $category';
  }

  @override
  String get noAccountFoundTitle => 'No account found';

  @override
  String noAccountMatchedBody(String hint) {
    return 'No account matched \"$hint\" and no default account is set. Set a default account in Settings to use Quick Add.';
  }

  @override
  String get noDefaultAccountBody =>
      'No default account is set. Set one in Settings to use Quick Add.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get quickAddTitle => 'QUICK ADD (BETA)';

  @override
  String get quickAddInfoTitle => 'Quick Add';

  @override
  String get quickAddInfoDesc =>
      'Record an expense instantly using natural language. No forms, no tapping. Just type what you spent and Kuber figures out the rest.';

  @override
  String get quickAddBasicAmount => 'Basic Amount';

  @override
  String get quickAddBasicAmountDesc =>
      '\"250\" or \"₹250\" adds ₹250 to the General category.';

  @override
  String get quickAddWithCategory => 'With Category';

  @override
  String get quickAddWithCategoryDesc =>
      '\"250 on food\", \"150 in gaming\", \"300 for rent\" links to an existing category or creates one.';

  @override
  String get quickAddWithAccount => 'With Account';

  @override
  String get quickAddWithAccountDesc =>
      '\"150 for uber from hdfc\" matches your HDFC account by name.';

  @override
  String get quickAddActionWords => 'Action Words';

  @override
  String get quickAddActionWordsDesc =>
      '\"Add 200 on coffee\", \"Log 500 for groceries\", \"Create 1000 in savings\" - leading action words are stripped automatically.';

  @override
  String get quickAddDefaultAccountInfo => 'Default Account';

  @override
  String get quickAddDefaultAccountInfoDesc =>
      'Set a default account in Settings to skip typing \"from ...\" every time.';

  @override
  String get quickAddHint => 'e.g. 250 on groceries from HDFC';

  @override
  String get spendingPattern => 'SPENDING PATTERN';

  @override
  String get avgDaily => 'AVG DAILY';

  @override
  String get last90Days => 'last 90 days';

  @override
  String get statThisMonth => 'THIS MONTH';

  @override
  String statDays(String days) {
    return '$days days';
  }

  @override
  String get projectedLabel => 'PROJECTED';

  @override
  String get endOfMonth => 'end of month';

  @override
  String get budgetSnapshot => 'BUDGET SNAPSHOT';

  @override
  String get budgetExceeded => 'Exceeded';

  @override
  String get budgetHighUsage => 'High usage';

  @override
  String get budgetNearLimit => 'Near limit';

  @override
  String get budgetOnTrack => 'On track';

  @override
  String get categoryLabel => 'Category';

  @override
  String budgetRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String get recentTransactions => 'RECENT TRANSACTIONS';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get smartInsights => 'SMART INSIGHTS';

  @override
  String get smartInsightsEmpty =>
      'Keep adding transactions to unlock\ninsights about your finances.';

  @override
  String get insightLabelWeekdayPattern => 'WEEKDAY PATTERN';

  @override
  String get insightLabelTopCategory => 'TOP CATEGORY';

  @override
  String get insightLabelCategoryTrend => 'CATEGORY TREND';

  @override
  String get insightLabelMonthTrend => 'MONTH TREND';

  @override
  String get insightLabelWeekendPattern => 'WEEKEND PATTERN';

  @override
  String get insightLabelBigExpense => 'BIG EXPENSE';

  @override
  String get insightLabelSavings => 'SAVINGS';

  @override
  String get insightLabelRecurring => 'RECURRING';

  @override
  String get insightLabelStreak => 'STREAK';

  @override
  String get insightLabelToday => 'TODAY';

  @override
  String get insightLabelThisWeek => 'THIS WEEK';

  @override
  String get insightLabelDidYouKnow => 'DID YOU KNOW';

  @override
  String get insightLabelLoans => 'LOANS';

  @override
  String get insightLabelLoanInterest => 'LOAN INTEREST';

  @override
  String get insightLabelLendBorrow => 'LEND / BORROW';

  @override
  String get insightLabelInvestments => 'INVESTMENTS';

  @override
  String get insightLabelTopInvestment => 'TOP INVESTMENT';

  @override
  String get insightLabelSummary => 'SUMMARY';

  @override
  String get insightLabelTip => 'TIP';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get historyTitle => 'Transaction\nHistory';

  @override
  String get historyDescription => 'Your past expenses, incomes and transfers';

  @override
  String get exportLabel => 'Export';

  @override
  String get expLabel => 'EXP';

  @override
  String get incLabel => 'INC';

  @override
  String get showingLabel => 'SHOWING';

  @override
  String get transactionsLabel => 'TRANSACTIONS';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get startTrackingExpenses => 'Start tracking your expenses';

  @override
  String get adjustSearchFilters => 'Try adjusting your search or filters';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String selectedCount(String count) {
    return '$count selected';
  }

  @override
  String deleteTransactionsConfirm(String count) {
    return 'Delete $count transactions?';
  }

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String transactionsDeleted(String count) {
    return '$count transactions deleted';
  }

  @override
  String tagsMoreCount(String count) {
    return '+$count more';
  }

  @override
  String get accountCorrectionSubtitle =>
      'Account correction · excluded from analytics';

  @override
  String get unknownLabel => 'Unknown';

  @override
  String get transferLabel => 'Transfer';

  @override
  String get adjustmentLabel => 'ADJUSTMENT';

  @override
  String get editTransfer => 'Edit Transfer';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get saveAndAddAnother => 'Save & Add Another';

  @override
  String get fromAccount => 'FROM ACCOUNT';

  @override
  String get toAccount => 'TO ACCOUNT';

  @override
  String get transactionNameHint => 'Transaction name';

  @override
  String get categoryUpper => 'CATEGORY';

  @override
  String get selectLabel => 'Select';

  @override
  String get updateExpense => 'Update Expense';

  @override
  String get updateIncome => 'Update Income';

  @override
  String get updateTransferBtn => 'Update Transfer';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get saveIncome => 'Save Income';

  @override
  String get saveTransferBtn => 'Save Transfer';

  @override
  String get enterTransactionName => 'Please enter a transaction name';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get selectCategoryError => 'Please select a category';

  @override
  String get selectAccountError => 'Please select an account';

  @override
  String get selectSourceAccount => 'Please select a source account';

  @override
  String get selectDestinationAccount => 'Please select a destination account';

  @override
  String get accountsMustDiffer =>
      'Source and destination accounts must be different';

  @override
  String failedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get addAnotherPrompt => 'Transaction saved! Add another?';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionSaved => 'Transaction saved';

  @override
  String get transferUpdated => 'Transfer updated';

  @override
  String get transferSaved => 'Transfer saved';

  @override
  String get creditCardPayment => 'Credit Card Payment';

  @override
  String get creditCardWithdrawal => 'Credit Card Withdrawal';

  @override
  String get creditCardTransfer => 'Credit Card Transfer';

  @override
  String get selectCategoryTitle => 'Select Category';

  @override
  String get searchCategories => 'Search categories';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get ungrouped => 'Ungrouped';

  @override
  String get addNewCategory => 'Add new category';

  @override
  String get budgetExists => 'BUDGET EXISTS';

  @override
  String get selectAccountTitle => 'Select Account';

  @override
  String get chooseAccountSubtitle => 'Choose the account for this transaction';

  @override
  String get noAccountsYet => 'No accounts yet';

  @override
  String get addNewAccount => 'Add new account';

  @override
  String get addNoteHint => 'Add a note (optional)';

  @override
  String get tagsUpper => 'TAGS';

  @override
  String get noTagsSelected => 'No tags selected';

  @override
  String tagsSelectedCount(String count) {
    return '$count tags selected';
  }

  @override
  String get dateTimeLabel => 'DATE & TIME';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get incomeLabel => 'Income';

  @override
  String get budgetLabel => 'Budget';

  @override
  String get attachmentsLabel => 'ATTACHMENTS';

  @override
  String get addImageOrPdf => 'Add image or PDF';

  @override
  String filesAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files attached',
      one: '1 file attached',
    );
    return '$_temp0';
  }

  @override
  String get addAttachments => 'Add Attachments';

  @override
  String get max5mb => 'Max 5MB per file';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get galleryLabel => 'Gallery';

  @override
  String get fileExceeds5mb => 'File exceeds 5MB limit';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get transferDeleted => 'Transfer deleted';

  @override
  String get undoLabel => 'UNDO';

  @override
  String get transactionAmount => 'TRANSACTION AMOUNT';

  @override
  String get accountUpper => 'ACCOUNT';

  @override
  String get notesUpper => 'NOTES';

  @override
  String get addedUsingPrompt => 'ADDED USING PROMPT';

  @override
  String get attachedTags => 'ATTACHED TAGS';

  @override
  String get noneLabel => 'None';

  @override
  String get filtersUpper => 'FILTERS';

  @override
  String get filterExpensesTooltip => 'Filter expenses';

  @override
  String get filterExp => 'Exp';

  @override
  String get filterIncomeTooltip => 'Filter income';

  @override
  String get filterInc => 'Inc';

  @override
  String get advancedFiltersTooltip => 'Advanced filters';

  @override
  String get clearFiltersTooltip => 'Clear filters';

  @override
  String get searchTransactionsTooltip => 'Search transactions';

  @override
  String get searchTransactionsHint => 'Search transactions...';

  @override
  String get applySearchTooltip => 'Apply search';

  @override
  String get selectRange => 'Select Range';

  @override
  String get advancedFiltersTitle => 'Advanced Filters';

  @override
  String get clearAll => 'CLEAR ALL';

  @override
  String get dateRangeLabel => 'DATE RANGE';

  @override
  String get selectDateRange => 'Select date range';

  @override
  String get transactionNameLabel => 'TRANSACTION NAME';

  @override
  String get searchViaName => 'Search via name.';

  @override
  String get typeFilterLabel => 'TYPE';

  @override
  String get amountRangeLabel => 'AMOUNT RANGE';

  @override
  String get minLabel => 'min';

  @override
  String get maxLabel => 'max';

  @override
  String get errorLoadingAccounts => 'Error loading accounts';

  @override
  String get categoriesLabel => 'CATEGORIES';

  @override
  String get errorLoadingCategories => 'Error loading categories';

  @override
  String get errorLoadingTags => 'Error loading tags';

  @override
  String get applyFilters => 'APPLY FILTERS';

  @override
  String get creditShort => 'Credit';

  @override
  String get bucketDawn => 'Dawn';

  @override
  String get bucketMorning => 'Morning';

  @override
  String get bucketNoon => 'Noon';

  @override
  String get bucketEvening => 'Evening';

  @override
  String get bucketNight => 'Night';

  @override
  String get weekLabel => 'Week';

  @override
  String get analyticsTitle => 'Spending\nAnalytics';

  @override
  String get analyticsDescription => 'Visualize your spending patterns';

  @override
  String get noData => 'No data';

  @override
  String get noTransactionsForPeriod => 'No transactions found for this period';

  @override
  String get biggestTransactions => 'Biggest Transactions';

  @override
  String get spendingTrend => 'Spending Trend';

  @override
  String get activeSelection => 'ACTIVE SELECTION';

  @override
  String get quickFilters => 'QUICK FILTERS';

  @override
  String get jumpTo => 'Jump To';

  @override
  String get invalidFormat => 'Invalid format';

  @override
  String get startBeforeEnd => 'Start must be before End';

  @override
  String get futureDatesNotAllowed => 'Future dates not allowed';

  @override
  String get manualDateRange => 'Manual Date Range';

  @override
  String get manualDateRangeDesc =>
      'Specify a custom period for your financial analysis.';

  @override
  String get fromDateLabel => 'FROM DATE (DD/MM/YYYY)';

  @override
  String get toDateLabel => 'TO DATE (DD/MM/YYYY)';

  @override
  String get doneUpper => 'DONE';

  @override
  String get cancelUpper => 'CANCEL';

  @override
  String get thresholdSettings => 'Threshold Settings';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get thresholdSmallDesc =>
      'Amount below which transactions are marked as Small.';

  @override
  String get thresholdLargeDesc =>
      'Amount above which transactions are marked as Large.';

  @override
  String get previewLogic => 'PREVIEW LOGIC';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get budgetVsActual => 'Budget vs Actual';

  @override
  String get errorLoadingBudgets => 'Error loading budgets';

  @override
  String get noActiveBudgets => 'No active budgets';

  @override
  String get tagWiseAnalytics => 'Tag-wise Analytics';

  @override
  String get spendingByTag => 'Spending by Tag';

  @override
  String get topTagsContribution => 'TOP TAGS CONTRIBUTION';

  @override
  String get noTagsInRange =>
      'There are no tag-related transactions in your selected date range';

  @override
  String get spendingDistribution => 'Spending Distribution';

  @override
  String get groupLabel => 'Group';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get transactionSizeDistribution => 'Transaction Size Distribution';

  @override
  String get frequencyByTicketSize => 'Frequency by ticket size';

  @override
  String get avgWeeklyHeatmap => 'Avg Weekly Heatmap';

  @override
  String get basedOnSelectedFilter => 'Based on your selected filter';

  @override
  String get intensity => 'INTENSITY';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get thresholdFloorHeading => 'Small/Medium Boundary (Floor)';

  @override
  String get thresholdCeilingHeading => 'Medium/Large Boundary (Ceiling)';

  @override
  String get manageAccounts => 'Manage\nAccounts';

  @override
  String get addAccount => 'Add Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get addFirstAccount => 'Add your first account to start tracking';

  @override
  String get addAnotherAccount => 'Add another account';

  @override
  String get availableBalance => 'AVAILABLE BALANCE';

  @override
  String get limitUpper => 'LIMIT';

  @override
  String get defaultUpper => 'DEFAULT';

  @override
  String get addTransactionTooltip => 'Add transaction';

  @override
  String get savingsAccount => 'Savings Account';

  @override
  String get viewTransactions => 'View Transactions';

  @override
  String get errorLoadingBalance => 'Error loading balance';

  @override
  String get editLimitSpent => 'Edit limit spent';

  @override
  String get editBalance => 'Edit balance';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get removeDefault => 'Remove Default';

  @override
  String get setAsDefaultLabel => 'Set as Default';

  @override
  String get currentAvailableBalance => 'CURRENT AVAILABLE BALANCE';

  @override
  String get limitSpent => 'LIMIT SPENT';

  @override
  String get totalLimit => 'TOTAL LIMIT';

  @override
  String get cannotDeleteAccount => 'Cannot delete account';

  @override
  String get cannotDeleteAccountBody =>
      'This account has transactions linked to it. To delete this account, delete the linked transactions first.';

  @override
  String get okLabel => 'OK';

  @override
  String get deleteAccountConfirm => 'Delete Account?';

  @override
  String get limitSpentUpdated => 'Limit spent updated successfully';

  @override
  String get balanceUpdated => 'Balance updated successfully';

  @override
  String get currentLimitSpent => 'CURRENT LIMIT SPENT';

  @override
  String get currentBalance => 'CURRENT BALANCE';

  @override
  String get newLimitSpent => 'New Limit Spent';

  @override
  String get newBalance => 'New Balance';

  @override
  String get enterAccountName => 'Please enter an account name';

  @override
  String get identity => 'Identity';

  @override
  String get creditCardName => 'Credit card name';

  @override
  String get cashName => 'Cash name';

  @override
  String get bankName => 'Bank name';

  @override
  String get iconLabel => 'Icon';

  @override
  String get colorLabel => 'Color';

  @override
  String get typeLabel => 'Type';

  @override
  String get last4DigitsHint => 'Last 4 digits (optional)';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get initialBalance => 'Initial balance';

  @override
  String get limitSpentField => 'Limit spent';

  @override
  String get totalLimitField => 'Total limit';

  @override
  String get saveAccount => 'Save account';

  @override
  String get totalNetWorth => 'TOTAL NET WORTH';

  @override
  String get assets => 'Assets';

  @override
  String get debt => 'Debt';

  @override
  String get cardLast4Note => 'Card\'s last 4 digits · not shared anywhere';

  @override
  String lastTransaction(String time) {
    return 'Last transaction $time';
  }

  @override
  String deleteAccountBody(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get adjustmentNote =>
      'adjustment will be recorded as a transaction (analytics won\'t be affected)';

  @override
  String get trackBudgets => 'Track\nBudgets';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get createBudgetsDesc =>
      'Create budgets to control your spending per category';

  @override
  String get disabledUpper => 'DISABLED';

  @override
  String get expiredUpper => 'EXPIRED';

  @override
  String get budgetPeriodEnded => 'BUDGET PERIOD ENDED';

  @override
  String get budgetPaused => 'BUDGET IS CURRENTLY PAUSED';

  @override
  String budgetResetsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DAYS',
      one: '1 DAY',
    );
    return 'RESETS IN $_temp0';
  }

  @override
  String budgetExpiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DAYS',
      one: '1 DAY',
    );
    return 'EXPIRES IN $_temp0';
  }

  @override
  String get progressLabel => 'Progress';

  @override
  String get selectCategoryUpper => 'SELECT CATEGORY';

  @override
  String get budgetAmount => 'BUDGET AMOUNT';

  @override
  String get appliesTo => 'APPLIES TO';

  @override
  String get thisMonthOnly => 'This month\nonly';

  @override
  String get everyMonth => 'Every\nmonth';

  @override
  String get budgetAlerts => 'BUDGET ALERTS';

  @override
  String get addAlert => 'ADD ALERT';

  @override
  String get saveBudget => 'SAVE BUDGET';

  @override
  String get tapToChangeCategory => 'Tap to change category';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get monthlyBudgetPlan => 'MONTHLY BUDGET PLAN';

  @override
  String get currentSpending => 'CURRENT SPENDING';

  @override
  String get utilization => 'UTILIZATION';

  @override
  String get budgetDetails => 'BUDGET DETAILS';

  @override
  String get createdOn => 'CREATED ON';

  @override
  String get renewsOn => 'RENEWS ON';

  @override
  String get expiresOn => 'EXPIRES ON';

  @override
  String get startedOn => 'STARTED ON';

  @override
  String get statusUpper => 'STATUS';

  @override
  String get activeLabel => 'Active';

  @override
  String get pausedLabel => 'Paused';

  @override
  String get activeAlerts => 'ACTIVE ALERTS';

  @override
  String get noAlertsSet => 'No alerts set';

  @override
  String get actionsUpper => 'ACTIONS';

  @override
  String get pauseLabel => 'Pause';

  @override
  String get resumeLabel => 'Resume';

  @override
  String get historyLabel => 'History';

  @override
  String get deleteBudgetConfirm => 'Delete budget?';

  @override
  String get budgetHistory => 'Budget History';

  @override
  String get noHistoryYet => 'No History Yet';

  @override
  String get budgetHistoryEmptyDesc =>
      'Your spending history for this budget will appear here once transactions are recorded.';

  @override
  String get overBudget => 'OVER BUDGET';

  @override
  String get underBudget => 'UNDER BUDGET';

  @override
  String get enterValidValue => 'Enter a valid value';

  @override
  String get amountExceedsBudget => 'Amount cannot exceed budget limit';

  @override
  String get alertAlreadyExists => 'An alert for this value already exists';

  @override
  String get addAlertTitle => 'Add Alert';

  @override
  String get selectAlertType => 'SELECT ALERT TYPE';

  @override
  String get percentageType => 'Percentage (%)';

  @override
  String get pushNotification => 'Push Notification';

  @override
  String exceededBy(String amount) {
    return 'EXCEEDED BY $amount';
  }

  @override
  String get budgetAlreadyExists => 'A budget already exists for this category';

  @override
  String deleteBudgetBody(String name) {
    return 'The budget for \"$name\" will be permanently deleted.';
  }

  @override
  String alertDesc(String value) {
    return 'Alert me when spending reaches $value of my monthly budget.';
  }

  @override
  String get percentageCannotExceed => 'Percentage cannot exceed 100%';

  @override
  String alertAmountType(String symbol) {
    return 'Fixed Amount ($symbol)';
  }

  @override
  String get loansTitle => 'Loans';

  @override
  String get addLoan => 'Add Loan';

  @override
  String get noLoansAdded => 'No loans added';

  @override
  String get loansEmptyDesc => 'Tap + to track your first loan EMI';

  @override
  String get activeLoans => 'ACTIVE LOANS';

  @override
  String get editLoan => 'Edit loan';

  @override
  String get newLoan => 'New loan';

  @override
  String get loanAmount => 'Loan amount';

  @override
  String get totalPrincipal => 'Total principal';

  @override
  String get loanType => 'Loan type';

  @override
  String get loanTypeVehicle => 'Vehicle';

  @override
  String get loanTypePersonal => 'Personal';

  @override
  String get loanTypeEducation => 'Education';

  @override
  String get loanTypeOther => 'Other';

  @override
  String get loanName => 'Loan name';

  @override
  String get loanNameHint => 'e.g. Maruti Brezza';

  @override
  String get lenderHint => 'e.g. HDFC Bank';

  @override
  String get referenceNumber => 'Reference number';

  @override
  String get referenceNumberHint => 'Sanction / loan ID';

  @override
  String get termsLabel => 'Terms';

  @override
  String get interestRate => 'Interest rate';

  @override
  String get rateFixed => 'Fixed';

  @override
  String get rateFloating => 'Floating';

  @override
  String get payEmi => 'Pay EMI';

  @override
  String get payExtra => 'Pay Extra';

  @override
  String get closeLoan => 'Close Loan';

  @override
  String get progressUpper => 'PROGRESS';

  @override
  String get totalUpper => 'TOTAL';

  @override
  String get paidUpper => 'PAID';

  @override
  String get remainingUpper => 'REMAINING';

  @override
  String get nextEmiDue => 'NEXT EMI DUE';

  @override
  String get interestRateUpper => 'INTEREST RATE';

  @override
  String get paymentHistory => 'PAYMENT HISTORY';

  @override
  String get noPaymentsRecorded => 'No payments recorded';

  @override
  String get deleteLoanConfirm => 'Delete Loan?';

  @override
  String get deleteLoanBody =>
      'This will delete the loan and ALL linked payment transactions. This cannot be undone.';

  @override
  String get emiPaid => 'EMI Paid';

  @override
  String get extraPayment => 'Extra Payment';

  @override
  String get loanClosure => 'Loan Closure';

  @override
  String get confirmClosure => 'CONFIRM CLOSURE';

  @override
  String get confirmPayment => 'CONFIRM PAYMENT';

  @override
  String get amountUpper => 'AMOUNT';

  @override
  String get dateUpper => 'DATE';

  @override
  String get noteOptional => 'NOTE (OPTIONAL)';

  @override
  String get totalOutstandingDebt => 'TOTAL OUTSTANDING DEBT';

  @override
  String get paidLabel => 'Paid';

  @override
  String get outstandingTitle => 'Outstanding';

  @override
  String get interestLabel => 'Interest';

  @override
  String get nextDue => 'Next due';

  @override
  String get completedUpper => 'COMPLETED';

  @override
  String get lenderField => 'Lender';

  @override
  String get loanTypeHome => 'Home';

  @override
  String get monthlyOutflow => 'Monthly outflow';

  @override
  String get perMonth => 'per month';

  @override
  String get tenure => 'Tenure';

  @override
  String get schedule => 'Schedule';

  @override
  String get loanStartDate => 'Loan start date';

  @override
  String get repaymentStart => 'Repayment start';

  @override
  String get firstEmiOn => 'First EMI on';

  @override
  String get monthlyBillDate => 'Monthly bill date';

  @override
  String get sourceAccount => 'Source account';

  @override
  String get autoAddTransactions => 'Auto-add transactions';

  @override
  String get autoAddTransactionsSub =>
      'Post each EMI to \"Loan EMI\" category on its bill date';

  @override
  String get notesLabel => 'Notes';

  @override
  String get loanNotesHint => 'Documentation · sanction letter ref · anything';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get confirmAddLoan => 'Confirm & add loan';

  @override
  String percentPaid(String pct) {
    return '$pct% Paid';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navMore => 'More';

  @override
  String get speedDialRecurring => 'Add a Recurring Transaction';

  @override
  String get speedDialLoan => 'Add a Loan';

  @override
  String get speedDialInvestment => 'Add an Investment';

  @override
  String get speedDialLendBorrow => 'Lend / Borrow Money';

  @override
  String get moneyStoriesTitle => 'MONEY STORIES';

  @override
  String get moneyStoriesEmpty =>
      'Keep spending to see your money stories soon.';

  @override
  String get bubbleWelcome => 'Welcome';

  @override
  String get bubbleDaily => 'Daily';

  @override
  String get bubbleWeekly => 'Weekly';

  @override
  String get bubbleMonthly => 'Monthly';

  @override
  String get bubbleYearly => 'Yearly';

  @override
  String get bubbleLoans => 'Loans';

  @override
  String get bubbleInvestments => 'Investments';

  @override
  String get bubbleLedger => 'Ledger';

  @override
  String get bubbleInsights => 'Insights';

  @override
  String get storiesArchiveTitle => 'Stories Archive';

  @override
  String get storiesArchiveDesc =>
      'Every recap Kuber has made for you, newest first.';

  @override
  String get noStoriesYet => 'No stories yet';

  @override
  String get keepUsingToSeeRecaps =>
      'Keep using Kuber to see your recaps here.';

  @override
  String get earlierThisWeek => 'Earlier this week';

  @override
  String get earlierThisMonth => 'Earlier this month';

  @override
  String get olderLabel => 'Older';

  @override
  String get loadingOlderStories => 'Loading older stories';

  @override
  String get justNow => 'Just now';

  @override
  String minsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mins ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeToday(Object time) {
    return 'Today, $time';
  }

  @override
  String relativeYesterday(Object time) {
    return 'Yesterday, $time';
  }

  @override
  String get utilizedLabel => 'utilized';

  @override
  String utilizedPct(Object pct) {
    return '$pct% Utilized';
  }

  @override
  String get editWidgets => 'Edit Widgets';

  @override
  String get editHomeWidgets => 'Edit Home Widgets';

  @override
  String get editHomeWidgetsDesc => 'Choose and reorder Home widgets';

  @override
  String get editAnalyticsWidgets => 'Edit Analytics Widgets';

  @override
  String get editAnalyticsWidgetsDesc => 'Choose and reorder Analytics widgets';

  @override
  String get filterAll => 'ALL';

  @override
  String get filterToday => 'TODAY';

  @override
  String get filterThisWeek => 'THIS WEEK';

  @override
  String get filterLastWeek => 'LAST WEEK';

  @override
  String get filterThisMonth => 'THIS MONTH';

  @override
  String get filterLastMonth => 'LAST MONTH';

  @override
  String get filterThisYear => 'THIS YEAR';

  @override
  String get filterCustom => 'CUSTOM';

  @override
  String get moreManageTitle => 'Manage';

  @override
  String get moreToolsTitle => 'Tools';

  @override
  String get moreAppTitle => 'App';

  @override
  String get moreTutorialTitle => 'Tutorial';

  @override
  String get moreHelpUsTitle => 'Help Us';

  @override
  String get moreAboutTitle => 'About';

  @override
  String get moreSearchTooltip => 'Search';

  @override
  String get moreManageSubtitle => 'Manage your settings, tools and data';

  @override
  String get menuAccounts => 'Accounts';

  @override
  String get menuAccountsDesc => 'Your wallets and bank accounts';

  @override
  String get menuCategories => 'Categories';

  @override
  String get menuCategoriesDesc => 'Organize your transactions';

  @override
  String get menuTags => 'Tags';

  @override
  String get menuTagsDesc => 'Organize the labels for your transactions';

  @override
  String get menuBudgets => 'Budgets';

  @override
  String get menuBudgetsDesc => 'Track and control your monthly spending';

  @override
  String get menuRecurring => 'Recurring Transactions';

  @override
  String get menuRecurringDesc => 'Automated scheduled transactions';

  @override
  String get menuLedger => 'Lend / Borrow';

  @override
  String get menuLedgerDesc => 'Track money you lent or borrowed';

  @override
  String get menuLoans => 'Loans';

  @override
  String get menuLoansDesc => 'Track EMIs and repayment progress';

  @override
  String get menuInvestments => 'Investments';

  @override
  String get menuInvestmentsDesc => 'Track portfolio value and growth';

  @override
  String get menuAskKuber => 'Ask Kuber (Beta)';

  @override
  String get menuAskKuberDesc => 'On-device smart assistant';

  @override
  String get menuCalculators => 'Calculators & Tools';

  @override
  String get menuCalculatorsDesc => 'EMI, SIP, salary, GST, split & more';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuSettingsDesc => 'Theme, currency, and profile';

  @override
  String get menuData => 'Data';

  @override
  String get menuDataDesc => 'Export, import, automatic backups';

  @override
  String get menuStoriesArchive => 'Money Stories Archive';

  @override
  String get menuStoriesArchiveDesc => 'Every recap, newest first';

  @override
  String get menuTroubleshoot => 'Troubleshoot';

  @override
  String get menuTroubleshootDesc => 'Fix data and suggestion issues';

  @override
  String get menuTutorial => 'App Tutorial (Beta)';

  @override
  String get menuTutorialDesc => 'Replay the feature walkthrough';

  @override
  String get menuWelcomeTour => 'Welcome Tour';

  @override
  String get menuWelcomeTourDesc => 'Replay the welcome and setup screens';

  @override
  String get menuRateUs => 'Rate Us on Play Store';

  @override
  String get menuRateUsDesc => 'Enjoying Kuber? Leave a review';

  @override
  String get menuShareApp => 'Share This App';

  @override
  String get menuShareAppDesc => 'Recommend Kuber to friends and family';

  @override
  String get menuFeedback => 'Submit a Feedback';

  @override
  String get menuFeedbackDesc => 'Report a bug or suggest a feature';

  @override
  String get menuAbout => 'About Kuber';

  @override
  String get menuAboutDesc => 'Vision, origin, and developer';

  @override
  String get menuPermissions => 'Permissions';

  @override
  String get menuPermissionsDesc => 'App limits and security';

  @override
  String get menuDevTools => 'Dev Tools';

  @override
  String get menuDevToolsDesc => 'Developer-only tools';

  @override
  String madeInIndia(Object heart) {
    return 'Made with $heart in India';
  }

  @override
  String madeInIndiaVersion(Object heart, Object version) {
    return 'Made with $heart in India · v$version';
  }

  @override
  String get shareMessage =>
      'Manage your expenses like never before. Kuber is a beautifully simple expense manager, made with love in India. Download it here: https://play.google.com/store/apps/details?id=com.grs.kuber';

  @override
  String get menuManageSpaces => '8 spaces';

  @override
  String get menuHelpUsHint => 'Tap to support';

  @override
  String get menuRateKuber => 'Rate Kuber';

  @override
  String get menuShare => 'Share';

  @override
  String get menuFeedbackShort => 'Feedback';

  @override
  String get menuAppTutorialShort => 'App Tutorial';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuNotificationsDesc => 'Recent alerts and reminders';

  @override
  String get manageCategoriesTitle => 'Manage\nCategories';

  @override
  String get addCategoryGroup => 'Add Category/Group';

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get createCategoriesToOrganize =>
      'Create categories to organize your expenses';

  @override
  String get searchCategoriesGroups => 'Search categories and groups...';

  @override
  String get noMatches => 'No matches';

  @override
  String noCategoriesGroupsMatch(Object query) {
    return 'No categories or groups match \"$query\".';
  }

  @override
  String get ungroupedLabel => 'Ungrouped';

  @override
  String get categoryGroupLabel => 'Category group';

  @override
  String get editGroupLabel => 'Edit group';

  @override
  String get deleteGroupLabel => 'Delete group';

  @override
  String get groupAlreadyExists => 'This group already exists';

  @override
  String get groupNameEmpty => 'Group name cannot be empty';

  @override
  String get addNewHeader => 'Add New';

  @override
  String get addClassifyDesc =>
      'Classify your transactions for better tracking';

  @override
  String get addGroupHeader => 'Add Group';

  @override
  String get addGroupDesc =>
      'Organize categories into sections for better clarity';

  @override
  String get manageTagsTitle => 'Manage\nTags';

  @override
  String get addTagLabel => 'Add Tag';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get createTagsToLabel =>
      'Create tags to label transactions (e.g. #trip, #work)';

  @override
  String get searchTags => 'Search tags...';

  @override
  String noTagsMatch(Object query) {
    return 'No tags match \"$query\".';
  }

  @override
  String get editTag => 'Edit Tag';

  @override
  String get deleteTag => 'Delete Tag';

  @override
  String get tagNameEmpty => 'Tag name cannot be empty';

  @override
  String get tagAlreadyExists => 'This tag already exists';

  @override
  String get recurringTitle => 'Recurring\nTransactions';

  @override
  String get recurringDesc => 'Automate your regular income and expenses';

  @override
  String get addRule => 'Add Rule';

  @override
  String get noRulesYet => 'No recurring rules yet';

  @override
  String get createRulesToAutomate =>
      'Create a rule to automate rent, salary, SIPs etc.';

  @override
  String get activeRules => 'ACTIVE RULES';

  @override
  String get pausedRules => 'PAUSED RULES';

  @override
  String get editRule => 'Edit Rule';

  @override
  String get ruleName => 'Rule name';

  @override
  String get ruleAmount => 'Amount';

  @override
  String get ruleFrequency => 'Frequency';

  @override
  String get nextProcessDate => 'Next process date';

  @override
  String get deleteRuleConfirm => 'Delete Rule?';

  @override
  String get deleteRuleBody =>
      'This will delete the recurring rule. Existing transactions created by this rule will not be deleted.';

  @override
  String get rulePaused => 'Rule paused';

  @override
  String get ruleResumed => 'Rule resumed';

  @override
  String get ledgerTitle => 'Lend / Borrow';

  @override
  String get ledgerDesc => 'Track money you lent to or borrowed from others';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get noLedgerYet => 'No entries yet';

  @override
  String get createLedgerToTrack => 'Tap + to track money you lend or borrow';

  @override
  String get whoOwes => 'WHO OWES';

  @override
  String get youOweLabel => 'You owe';

  @override
  String get owesYouLabel => 'Owes you';

  @override
  String get settledLabel => 'Settled';

  @override
  String get settleUp => 'Settle Up';

  @override
  String get deleteEntryConfirm => 'Delete Entry?';

  @override
  String get deleteEntryBody =>
      'This will delete this entry and all its payments. This cannot be undone.';

  @override
  String get investmentsTitle => 'Investments';

  @override
  String get investmentsDesc =>
      'Track your portfolio value, contributions and growth';

  @override
  String get addInvestment => 'Add Investment';

  @override
  String get noInvestmentsYet => 'No investments yet';

  @override
  String get createInvestmentToTrack =>
      'Tap + to track your SIPs, mutual funds, stocks etc.';

  @override
  String get portfolioValue => 'PORTFOLIO VALUE';

  @override
  String get totalInvested => 'TOTAL INVESTED';

  @override
  String get gainLoss => 'GAIN / LOSS';

  @override
  String get deleteInvestmentConfirm => 'Delete Investment?';

  @override
  String get deleteInvestmentBody =>
      'This will delete the investment record and all its transactions.';

  @override
  String get troubleshootTitle => 'Troubleshoot';

  @override
  String get troubleshootDesc =>
      'Fix data inconsistency and suggestion issues.';

  @override
  String get rebuildSuggestions => 'Rebuild Suggestions';

  @override
  String get rebuildSuggestionsDesc =>
      'Regenerates transaction autocompletes based on your history.';

  @override
  String get suggestionsRebuilt => 'Suggestions rebuilt successfully';

  @override
  String get cleanOrphans => 'Clean Orphaned Data';

  @override
  String get cleanOrphansDesc =>
      'Removes transactions linked to deleted categories or accounts.';

  @override
  String get orphansCleaned => 'Orphaned data cleaned up';

  @override
  String get clearCache => 'Clear App Cache';

  @override
  String get clearCacheDesc =>
      'Clears temporary files and rebuilds internal database indexes.';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get aboutKuberHeader => 'About Kuber';

  @override
  String get aboutKuberDesc =>
      'Kuber is a beautifully simple, offline-first personal finance tracker.';

  @override
  String get privacyPromise => 'Privacy Promise';

  @override
  String get privacyPromiseDesc =>
      'Your data never leaves your device. No analytics, no tracking, no cloud sync.';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDesc =>
      'Built with open technologies, fully transparent and auditable.';

  @override
  String get developerNote => 'Note from the Developer';

  @override
  String get developerNoteDesc =>
      'Kuber is built with love to solve personal finance tracking. Thank you for using it!';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsDesc => 'App access requirements and security limits.';

  @override
  String get storagePermission => 'Storage Access';

  @override
  String get storagePermissionDesc =>
      'Required to pick attachment images, PDFs and write backups to your device.';

  @override
  String get biometricPermission => 'Biometric Authentication';

  @override
  String get biometricPermissionDesc =>
      'Optional. Used for unlocking Kuber securely using Face ID or fingerprint.';

  @override
  String get networkPermission => 'Network Access';

  @override
  String get networkPermissionDesc =>
      'Only used to fetch live currency conversion rates. App works 100% offline.';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackDesc => 'Report issues, suggest features, or say hi!';

  @override
  String get feedbackType => 'FEEDBACK TYPE';

  @override
  String get feedbackTypeBug => 'Bug Report';

  @override
  String get feedbackTypeFeature => 'Feature Request';

  @override
  String get feedbackTypeOther => 'Other';

  @override
  String get feedbackMessage => 'YOUR MESSAGE';

  @override
  String get feedbackMessageHint =>
      'Explain the issue or your suggestion in detail...';

  @override
  String get submitFeedback => 'Submit Feedback';

  @override
  String get feedbackThankYou => 'Thank you for your feedback!';

  @override
  String get feedbackMessageRequired => 'Please enter your message first';

  @override
  String get dataManagementTitle => 'Data Management';

  @override
  String get dataManagementDesc => 'Export, import, and manage your data.';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDesc =>
      'Export all transactions, accounts and settings to JSON.';

  @override
  String get importData => 'Import Data';

  @override
  String get importDataDesc => 'Import a previously exported JSON backup file.';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataDesc =>
      'Permanently deletes all transactions, accounts and settings from this device. Cannot be undone.';

  @override
  String get clearDataConfirm => 'Clear All Data?';

  @override
  String get clearDataConfirmBody =>
      'This will permanently delete all your transactions, accounts, budgets, and settings. This action is irreversible. Type DELETE to confirm.';

  @override
  String get backupTitle => 'Backups';

  @override
  String get backupDesc =>
      'Create manual backups or schedule automatic backups.';

  @override
  String get lentBorrowedTitle => 'Lent &\nBorrowed';

  @override
  String get noLedgerEntries => 'No ledger entries yet';

  @override
  String get ledgerEmptyDesc => 'Tap + to record a lend or borrow';

  @override
  String get settledUpper => 'SETTLED';

  @override
  String get lentLabel => 'Lent';

  @override
  String get borrowedLabel => 'Borrowed';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get newEntry => 'New entry';

  @override
  String get amountLent => 'Amount lent';

  @override
  String get amountBorrowed => 'Amount borrowed';

  @override
  String get personLabel => 'Person';

  @override
  String get whoHint => 'Who?';

  @override
  String get fromAccountLabel => 'From account';

  @override
  String get toAccountLabel => 'To account';

  @override
  String get dateLabel => 'Date';

  @override
  String get lentOn => 'Lent on';

  @override
  String get borrowedOn => 'Borrowed on';

  @override
  String get expectedReturn => 'Expected return';

  @override
  String get ledgerNotesHint => 'Context, IOU ref, anything';

  @override
  String get addToLedger => 'Add to ledger';

  @override
  String get accountTitle => 'Account';

  @override
  String get expectedOn => 'Expected on';

  @override
  String get lentTransaction => 'LENT TRANSACTION';

  @override
  String get borrowedTransaction => 'BORROWED TRANSACTION';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get markSettled => 'Mark Settled';

  @override
  String get repaymentProgress => 'REPAYMENT PROGRESS';

  @override
  String get dueDate => 'DUE DATE';

  @override
  String get markSettledConfirm => 'Mark as Settled?';

  @override
  String get markSettledBody =>
      'This will record the remaining amount as a payment and mark this entry as settled.';

  @override
  String get settleLabel => 'Settle';

  @override
  String get deleteLedgerConfirm => 'Delete Ledger Entry?';

  @override
  String get deleteLedgerBody =>
      'This will delete the entry and ALL linked transactions. This cannot be undone.';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get paymentMade => 'Payment Made';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get recordPaymentUpper => 'RECORD PAYMENT';

  @override
  String get netPosition => 'NET POSITION';

  @override
  String get youWillReceive => 'You will receive';

  @override
  String get youOwe => 'You owe';

  @override
  String get noDueDate => 'NO DUE DATE';

  @override
  String get lentUpper => 'LENT';

  @override
  String get borrowedUpper => 'BORROWED';

  @override
  String ledgerDuplicateWarningLent(String person) {
    return 'An active lent entry for $person already exists. Are you sure you want to create a new one?';
  }

  @override
  String ledgerDuplicateWarningBorrow(String person) {
    return 'An active borrow entry for $person already exists. Are you sure you want to create a new one?';
  }

  @override
  String get ledgerEvensOut => 'evens out';

  @override
  String get ledgerInYourFavour => 'in your favour';

  @override
  String get ledgerOwedToOthers => 'owed to others';

  @override
  String ledgerActiveEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active entries',
      one: '1 active entry',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNoOne => 'no one';

  @override
  String ledgerAcrossPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'across $count people',
      one: 'across 1 person',
    );
    return '$_temp0';
  }

  @override
  String settledOnUpper(String date) {
    return 'SETTLED $date';
  }

  @override
  String dueOnUpper(String date) {
    return 'DUE $date';
  }

  @override
  String get overdueLower => 'overdue';

  @override
  String pctReceived(String pct) {
    return '$pct% received';
  }

  @override
  String pctPaidBack(String pct) {
    return '$pct% paid back';
  }

  @override
  String amountRemaining(String amount) {
    return '$amount remaining';
  }

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get notSetTapToAdd => 'Not set · tap to add';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String createdOnUpper(String date) {
    return 'CREATED $date';
  }

  @override
  String get noInvestments => 'No investments tracked';

  @override
  String get investmentsEmptyDesc => 'Tap + to add your first investment';

  @override
  String get allInvestmentsUpper => 'ALL INVESTMENTS';

  @override
  String get invTypeSip => 'SIP';

  @override
  String get invTypeMutualFund => 'Mutual Fund';

  @override
  String get invTypeStocks => 'Stocks';

  @override
  String get invTypeGold => 'Gold';

  @override
  String get invTypeFd => 'FD';

  @override
  String get invTypeRd => 'RD';

  @override
  String get invTypeCrypto => 'Crypto';

  @override
  String get invTypeTrading => 'Trading';

  @override
  String get invTypeRealEstate => 'Real Estate';

  @override
  String get invTypeOther => 'Other';

  @override
  String get editInvestment => 'Edit investment';

  @override
  String get newInvestment => 'New investment';

  @override
  String get investmentName => 'Investment name';

  @override
  String get valueLabel => 'Value';

  @override
  String get totalInvestedInclNew => 'Total invested (incl. new contribution)';

  @override
  String get investedAmountInitial => 'Invested amount (initial)';

  @override
  String get autoDebitSip => 'Auto-debit SIP';

  @override
  String get enableAutoDebitSip => 'Enable auto-debit SIP';

  @override
  String get automateMonthlyContrib => 'Automate your monthly contributions';

  @override
  String get monthlySipAmount => 'Monthly SIP amount';

  @override
  String get sipDate => 'SIP date';

  @override
  String get debitedFrom => 'Debited from';

  @override
  String get optionalContext => 'Optional context';

  @override
  String get addContribution => 'Add Contribution';

  @override
  String get updateValue => 'Update Value';

  @override
  String get investedUpper => 'INVESTED';

  @override
  String get currentUpper => 'CURRENT';

  @override
  String get gainLossUpper => 'GAIN/LOSS';

  @override
  String get sipConfiguration => 'SIP CONFIGURATION';

  @override
  String get monthlySip => 'Monthly SIP';

  @override
  String get strategyNotes => 'STRATEGY NOTES';

  @override
  String get contributionHistory => 'CONTRIBUTION HISTORY';

  @override
  String get noContributions => 'No contributions recorded';

  @override
  String get updateCurrentValue => 'Update Current Value';

  @override
  String get updateLabel => 'Update';

  @override
  String get contributionLabel => 'Contribution';

  @override
  String get recordContributionUpper => 'RECORD CONTRIBUTION';

  @override
  String get noteOptionalUpper => 'NOTE (OPTIONAL)';

  @override
  String get assetAllocation => 'ASSET ALLOCATION';

  @override
  String get investmentNameHint => 'e.g. Nifty 50 Index Fund';

  @override
  String sipAmountPrefix(String amount) {
    return 'SIP $amount';
  }

  @override
  String monthlySipValue(String amount, String day) {
    return '$amount on ${day}th';
  }

  @override
  String get addRecurring => 'Add Recurring';

  @override
  String get noRecurring => 'No recurring transactions';

  @override
  String get recurringEmptyDesc =>
      'Automate subscriptions and repeated payments';

  @override
  String get rulesUpper => 'RULES';

  @override
  String get recentlyProcessed => 'RECENTLY PROCESSED';

  @override
  String get freqDaily => 'Daily';

  @override
  String get freqWeekly => 'Weekly';

  @override
  String get freqBiweekly => 'Biweekly';

  @override
  String get freqMonthly => 'Monthly';

  @override
  String get freqQuarterly => 'Quarterly';

  @override
  String get freqYearly => 'Yearly';

  @override
  String get freqCustom => 'Custom';

  @override
  String get editRecurring => 'Edit recurring';

  @override
  String get newRecurring => 'New recurring';

  @override
  String get transactionLabel => 'Transaction';

  @override
  String get amountTitle => 'Amount';

  @override
  String get recurringNameHint => 'Name (e.g. Netflix, Rent)';

  @override
  String get whereLabel => 'Where';

  @override
  String get scheduleSublabel => 'When this transaction repeats';

  @override
  String get frequencyLabel => 'Frequency';

  @override
  String get everyLabel => 'Every';

  @override
  String get daysLabel => 'days';

  @override
  String get startsOn => 'Starts on';

  @override
  String get startDate => 'Start date';

  @override
  String get endsLabel => 'Ends';

  @override
  String get neverLabel => 'Never';

  @override
  String get afterN => 'After N';

  @override
  String get onDate => 'On date';

  @override
  String get afterLabel => 'After';

  @override
  String get occurrencesLabel => 'occurrences';

  @override
  String get endDate => 'End date';

  @override
  String get recurringNotesHint => 'Optional · context, reference, anything';

  @override
  String get saveRecurring => 'Save recurring';

  @override
  String get nextOccurrenceLabel => 'Next occurrence';

  @override
  String get cadenceDaily => 'then every day';

  @override
  String get cadenceWeekly => 'then every week';

  @override
  String get cadenceBiweekly => 'then every 2 weeks';

  @override
  String get cadenceMonthly => 'then every month';

  @override
  String get cadenceYearly => 'then every year';

  @override
  String get cadenceCustom => 'then every custom interval';

  @override
  String get activeUpper => 'ACTIVE';

  @override
  String get activeCustomUpper => 'ACTIVE • CUSTOM';

  @override
  String get pausedUpper => 'PAUSED';

  @override
  String freqEveryNDays(String count) {
    return 'Every $count days';
  }

  @override
  String recurringAmountLabel(String type) {
    return 'RECURRING $type AMOUNT';
  }

  @override
  String get frequencyUpper => 'FREQUENCY';

  @override
  String get deleteAutomationConfirm => 'Delete automation?';

  @override
  String deleteAutomationBody(String name) {
    return 'The recurring rule for \"$name\" will be permanently deleted.';
  }

  @override
  String get monthlyAutomationCost => 'MONTHLY AUTOMATION COST';

  @override
  String get upcomingCharges => 'UPCOMING CHARGES';

  @override
  String get todayUpper => 'TODAY';

  @override
  String get tomorrowUpper => 'TOMORROW';

  @override
  String get yesterdayUpper => 'YESTERDAY';

  @override
  String inDaysUpper(String count) {
    return 'IN $count DAYS';
  }

  @override
  String get nextChargeLabel => 'Next charge';

  @override
  String get backingUpAuto => 'Backing up automatically';

  @override
  String get processingRecurring => 'Processing Recurring';

  @override
  String get savingCopyToFolder => 'Saving a copy to your chosen folder.';

  @override
  String get creatingMissedTxns => 'Creating missed transactions.';

  @override
  String get folderUpper => 'FOLDER';

  @override
  String get processedUpper => 'PROCESSED';

  @override
  String get selectedLabel => 'Selected';

  @override
  String nTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get networkUpper => 'NETWORK';

  @override
  String get localOnly => 'Local Only';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String errorLoadingHistory(String details) {
    return 'Error loading history: $details';
  }

  @override
  String get recurringHistoryEmptyDesc =>
      'Transactions generated by this automation will appear here.';

  @override
  String get todayLower => 'today';

  @override
  String get tomorrowLower => 'tomorrow';

  @override
  String get betaBadge => 'BETA';

  @override
  String get noCategories => 'No categories yet';

  @override
  String get categoriesEmptyDesc =>
      'Create categories to organize your expenses';

  @override
  String get addCategory => 'Add Category';

  @override
  String get searchCategoriesHint => 'Search categories and groups...';

  @override
  String get addNew => 'Add New';

  @override
  String get addCategoryDesc =>
      'Classify your transactions for better tracking';

  @override
  String get addGroup => 'Add Group';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get categoryGroupSubtitle => 'Category group';

  @override
  String get groupNameHint => 'Group name (e.g. Food, Transport)';

  @override
  String get deleteGroupConfirm => 'Delete Group?';

  @override
  String deleteGroupBody(String name) {
    return 'Categories in \"$name\" will be moved to \"Ungrouped\".';
  }

  @override
  String get categoryDetail => 'Category Detail';

  @override
  String get groupUpper => 'GROUP';

  @override
  String get typeUpper => 'TYPE';

  @override
  String get incomeAndExpense => 'Income & Expense';

  @override
  String get cannotDeleteCategory => 'Cannot delete category';

  @override
  String get cannotDeleteCategoryBody =>
      'This category has transactions linked to it. To delete this category, delete the linked transactions first.';

  @override
  String get editCategory => 'Edit category';

  @override
  String get newCategory => 'New category';

  @override
  String get optionalLabel => 'Optional';

  @override
  String get appearance => 'Appearance';

  @override
  String get bothLabel => 'Both';

  @override
  String get saveCategory => 'Save category';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryAdded => 'Category added';

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get livePreview => 'LIVE PREVIEW';

  @override
  String get selectGroup => 'Select Group';

  @override
  String get groupNameShortHint => 'Group name...';

  @override
  String get addNewGroup => 'Add New Group';

  @override
  String get noBudgetSet => 'No budget set';

  @override
  String get categoriesTitle => 'Manage\nCategories';

  @override
  String noCategoryMatches(String query) {
    return 'No categories or groups match \"$query\".';
  }

  @override
  String get deleteCategoryConfirm => 'Delete category?';

  @override
  String deleteCategoryBody(String name) {
    return '\"$name\" will be permanently deleted.';
  }

  @override
  String get categoryNameHint => 'e.g. Groceries, Rent, Salary';

  @override
  String get tagsTitle => 'Manage\nTags';

  @override
  String get tagsHeaderDesc => 'Organize transactions with custom labels.';

  @override
  String get addTag => 'Add Tag';

  @override
  String get noTags => 'No tags yet';

  @override
  String get tagsEmptyDesc => 'Create hashtags to track specific expenses.';

  @override
  String get disabledLabel => 'Disabled';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get newTag => 'New Tag';

  @override
  String get updateTag => 'Update Tag';

  @override
  String get createTag => 'Create Tag';

  @override
  String get enableLabel => 'Enable';

  @override
  String get disableLabel => 'Disable';

  @override
  String get deleteTagConfirm => 'Delete tag?';

  @override
  String deleteTagBody(String name) {
    return 'The tag \"#$name\" will be permanently deleted.';
  }

  @override
  String get selectTags => 'Select Tags';

  @override
  String get tagNameHint => 'Example: weekend, trip-to-goa';

  @override
  String get searchOrCreateTagHint => 'Search or create tag...';

  @override
  String get tagDisabledMessage =>
      'Tag is disabled. Enable it from More → Tags.';

  @override
  String get exportHistory => 'Export History';

  @override
  String get exportAnalytics => 'Export Analytics';

  @override
  String get selectFormat => 'SELECT FORMAT';

  @override
  String get formatUpper => 'FORMAT';

  @override
  String get spreadsheetLabel => 'SPREADSHEET';

  @override
  String get documentLabel => 'DOCUMENT';

  @override
  String get pdfDocument => 'PDF Document';

  @override
  String get pdfDocumentDesc => 'Universal format for high-fidelity printing.';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get applyCurrentFilters => 'Apply current filters';

  @override
  String get applyFiltersDesc =>
      'Generate report using the active filters from the history page.';

  @override
  String get periodAllTime => 'All Time';

  @override
  String get selectedPeriod => 'SELECTED PERIOD';

  @override
  String get analyticsDateFilterInfo =>
      'Date filters from your current analytics view are automatically applied to this report.';

  @override
  String get exportSuccessful => 'Export Successful';

  @override
  String get reportReady => 'Your report is ready.';

  @override
  String get openFile => 'Open File';

  @override
  String get savingEllipsis => 'Saving…';

  @override
  String get saveToFolder => 'Save to Folder';

  @override
  String get shareLabel => 'Share';

  @override
  String get noAppToOpen => 'No app found to open this file type.';

  @override
  String get fileSaved => 'File saved successfully.';

  @override
  String couldNotShareFile(String details) {
    return 'Could not share file: $details';
  }

  @override
  String get exportFailed => 'Export Failed';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get exportGenerateFailed =>
      'Unable to generate file. Please try again.';

  @override
  String get failedToSaveFile => 'Failed to save file.';

  @override
  String get chartsTitle => 'Charts';

  @override
  String get chartsSubtitle => 'Visualise your spending patterns over time.';

  @override
  String get wipBadge => 'WIP';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get tapBarForDetails => 'Tap a bar to see details';

  @override
  String get incomeUpper => 'INCOME';

  @override
  String get expenseUpper => 'EXPENSE';

  @override
  String get netUpper => 'NET';

  @override
  String get noExpenseBreakdown => 'No expense breakdown available.';

  @override
  String get byCategoryUpper => 'BY CATEGORY';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqAddTxnQ => 'How do I add a transaction?';

  @override
  String get faqAddTxnA =>
      'Tap the + button on the bottom right to add a new transaction. Fill in the amount, select a category and account, then save.';

  @override
  String get faqAccountsQ => 'How do I manage accounts?';

  @override
  String get faqAccountsA =>
      'Go to More → Accounts to see all your wallets and bank accounts. You can add new accounts or edit existing ones from there.';

  @override
  String get faqTransfersQ => 'How do transfers work?';

  @override
  String get faqTransfersA =>
      'When adding a transaction, select \"Transfer\" as the type. Pick the source and destination accounts and the amount will be moved between them.';

  @override
  String get faqCategoriesQ => 'Can I customize categories?';

  @override
  String get faqCategoriesA =>
      'Yes! Go to More → Categories to view all categories. Default categories cannot be deleted, but you can add your own custom categories.';

  @override
  String get dataExportTitle => 'Export Data';

  @override
  String get backupUpper => 'BACKUP';

  @override
  String get exportCsvDesc =>
      'Exports transactions, categories, accounts and tags. Does not include recurring automations, budgets, loans, investments, or attachments.';

  @override
  String get exportJsonDesc =>
      'Complete app backup (excluding attachments). Can be used to restore all your data on a new device or after reinstalling.';

  @override
  String get fileReady => 'Your file is ready.';

  @override
  String get saveACopy => 'Save a copy';

  @override
  String get dataImportTitle => 'Import Data';

  @override
  String get selectFileImport => 'Select File & Import';

  @override
  String get overrideExistingData => 'Override existing data';

  @override
  String get importWipeDesc => 'All existing data will be wiped before import.';

  @override
  String get importMergeDesc =>
      'New records will be merged with existing data.';

  @override
  String get importWipeWarning =>
      'All existing data will be permanently deleted before import.';

  @override
  String get importMergeChip =>
      'New records will be merged with your existing data.';

  @override
  String get importReplaceWarning =>
      'All existing data will be permanently deleted and replaced with the backup.';

  @override
  String get downloadTemplate => 'Download Template';

  @override
  String get downloadTemplateDesc =>
      'Get a CSV with the correct column headers to format your data.';

  @override
  String get backupsTitle => 'Automatic\nBackups';

  @override
  String get backupsSubtitle =>
      'Keep a fresh copy of your data saved to your device, on a schedule.';

  @override
  String get statusSectionLabel => 'Status';

  @override
  String get configurationLabel => 'Configuration';

  @override
  String get actionsLabel => 'Actions';

  @override
  String get backupNow => 'Backup now';

  @override
  String get alreadyBackedUpToday => 'Already backed up today';

  @override
  String get lastBackupFailed => 'Last backup failed';

  @override
  String get backupFolderErrorDesc =>
      'We couldn\'t access your backup folder. It may have moved or permission may have been revoked.';

  @override
  String attemptedOn(String label) {
    return 'Attempted $label';
  }

  @override
  String get chooseNewFolder => 'Choose new folder';

  @override
  String get backedUp => 'Backed up';

  @override
  String backedUpOn(String label) {
    return 'Backed up $label';
  }

  @override
  String lastCopySaved(String count) {
    return 'Last copy saved successfully. Keeping your most recent $count backups.';
  }

  @override
  String get neverLoseData => 'Never lose your data';

  @override
  String get neverLoseDataDesc =>
      'Turn on automatic backups and Kuber will save a copy to a folder you choose when an app open is due.';

  @override
  String get automaticBackups => 'Automatic Backups';

  @override
  String get saveCopyOnSchedule => 'Save a copy on a schedule';

  @override
  String get keepLast => 'Keep last';

  @override
  String get backupFolder => 'Backup folder';

  @override
  String get exportingData => 'Exporting data...';

  @override
  String get preparingFile => 'Preparing your file';

  @override
  String get dataExportedSuccess => 'Data exported successfully';

  @override
  String get exportComplete => 'Export Complete';

  @override
  String savedToDownloads(String fileName) {
    return 'Saved to Downloads/$fileName';
  }

  @override
  String exportFailedMsg(String error) {
    return 'Export failed: $error';
  }

  @override
  String get downloadingTemplate => 'Downloading template...';

  @override
  String get preparingCsvTemplate => 'Preparing CSV template';

  @override
  String get templateDownloadedSuccess => 'Template downloaded successfully';

  @override
  String get downloadComplete => 'Download Complete';

  @override
  String downloadFailedMsg(String error) {
    return 'Download failed: $error';
  }

  @override
  String get downloadFailedTitle => 'Download Failed';

  @override
  String importFailedMsg(String error) {
    return 'Import failed: $error';
  }

  @override
  String get mockDataGenerated => 'Mock data generated successfully';

  @override
  String generationFailedMsg(String error) {
    return 'Generation failed: $error';
  }

  @override
  String get allDataCleared => 'All data cleared successfully';

  @override
  String clearFailedMsg(String error) {
    return 'Clear failed: $error';
  }

  @override
  String rebuildFailedMsg(String error) {
    return 'Rebuild failed: $error';
  }

  @override
  String notifNewRecurring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring transactions added',
      one: 'New recurring transaction',
    );
    return '$_temp0';
  }

  @override
  String notifRecurringBody(String name) {
    return '$name - added while you were away';
  }

  @override
  String get notifLoanEmiTitle => 'Loan EMI deducted';

  @override
  String notifLoanEmiBody(String name) {
    return '$name - EMI added to your transactions';
  }

  @override
  String get notifInvestmentTitle => 'Investment contribution added';

  @override
  String notifInvestmentBody(String name) {
    return '$name - SIP contribution recorded';
  }

  @override
  String get notifMoneyToCollect => 'Money to collect';

  @override
  String get notifMoneyToRepay => 'Money to repay';

  @override
  String notifLedgerReminderBody(String person, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$person - $count days overdue',
      one: '$person - 1 day overdue',
      zero: '$person - due today',
    );
    return '$_temp0';
  }

  @override
  String get notifBudgetAlertTitle => 'Budget Alert';

  @override
  String notifBudgetReachedBody(String pct, String category) {
    return 'You\'ve reached $pct% of your $category budget';
  }

  @override
  String notifBudgetSpentBody(String amount, String category) {
    return 'You\'ve spent $amount in $category category';
  }

  @override
  String get wgtBalanceHeroName => 'Balance Card';

  @override
  String get wgtBalanceHeroDesc =>
      'Current-month net with income / expense split';

  @override
  String get wgtInsightStoriesName => 'Money Stories';

  @override
  String get wgtInsightStoriesDesc => 'Recaps and highlights about your money';

  @override
  String get wgtQuickAddName => 'Quick Add';

  @override
  String get wgtQuickAddDesc => 'One-tap expense / income / transfer entry';

  @override
  String get wgtSpendingStatsName => 'Spending Stats';

  @override
  String get wgtSpendingStatsDesc => 'Spent vs received this month';

  @override
  String get wgtHomeAccountsName => 'Bank Accounts';

  @override
  String get wgtHomeAccountsDesc => 'All accounts and balances';

  @override
  String get wgtSevenDayChartName => 'Last 7 Days Chart';

  @override
  String get wgtSevenDayChartDesc =>
      'Daily income vs expense for the past week';

  @override
  String get wgtBudgetSnapshotName => 'Budget Snapshot';

  @override
  String get wgtBudgetSnapshotDesc => 'Progress against active budgets';

  @override
  String get wgtUpcomingRecurringName => 'Upcoming Recurring';

  @override
  String get wgtUpcomingRecurringDesc => 'Next recurring transactions due';

  @override
  String get wgtRecentTransactionsName => 'Recent Transactions';

  @override
  String get wgtRecentTransactionsDesc => 'Latest activity at a glance';

  @override
  String get wgtSummaryCardName => 'Summary Card';

  @override
  String get wgtSummaryCardDesc => 'Income, expense and net for the period';

  @override
  String get wgtSpendingTrendName => 'Spending Trend';

  @override
  String get wgtSpendingTrendDesc => 'Bar / line chart with bucket dropdown';

  @override
  String get wgtWeeklyHeatmapName => 'Weekly Heatmap';

  @override
  String get wgtWeeklyHeatmapDesc => 'Average expense by day of week';

  @override
  String get wgtSizeDistributionName => 'Transaction Sizes';

  @override
  String get wgtSizeDistributionDesc => 'Small / medium / large breakdown';

  @override
  String get wgtCategoryBreakdownName => 'Category Breakdown';

  @override
  String get wgtCategoryBreakdownDesc => 'Spending grouped by category';

  @override
  String get wgtTagAnalyticsName => 'Tag Analytics';

  @override
  String get wgtTagAnalyticsDesc => 'Totals grouped by tag';

  @override
  String get wgtBiggestTransactionsName => 'Biggest Transactions';

  @override
  String get wgtBiggestTransactionsDesc => 'Top 5 by amount, expense or income';

  @override
  String get atLeastOneWidget => 'At least one widget must be enabled';

  @override
  String get discardChangesConfirm => 'Discard changes?';

  @override
  String get discardChangesBody =>
      'You have unsaved changes to your widgets. Leaving now will discard them.';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discardLabel => 'Discard';

  @override
  String get unlockToContinue => 'Unlock to continue';

  @override
  String get splashTagline => 'Your personal money diary';
}
