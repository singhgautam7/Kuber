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
  String get recurringModule => 'Recurring';

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
  String get language => 'Language';

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
  String get navFuturisticChoice => 'Futuristic';

  @override
  String get navSubtitleFuturistic => 'Label on active';

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
  String get moreToolsTitle => 'Signature';

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
  String get menuWidgets => 'Widgets';

  @override
  String get menuWidgetsDesc => 'Home screen widgets to keep Kuber in view';

  @override
  String get menuTroubleshoot => 'Troubleshoot';

  @override
  String get menuTroubleshootDesc => 'Fix data and suggestion issues';

  @override
  String get menuTutorial => 'App Tutorial (Beta)';

  @override
  String get menuTutorialDesc => 'Replay the feature walkthrough';

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
  String get invTypeGold => 'Gold/Silver';

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
  String get invTypeEtf => 'ETF';

  @override
  String get invTypeBonds => 'Bonds';

  @override
  String get invTypeCollectible => 'Collectible';

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

  @override
  String get tutCh0Title => 'Transactions';

  @override
  String get tutCh0Desc =>
      'Add income, expenses, transfers, notes, receipts and tags.';

  @override
  String get tutCh0St0Title => 'Enter amount';

  @override
  String get tutCh0St0Desc =>
      'Type the amount directly. Tap the calculator icon to open the built-in expression calculator.';

  @override
  String get tutCh0St1Title => 'Transaction type';

  @override
  String get tutCh0St1Desc =>
      'Choose Income, Expense, or Transfer between your accounts.';

  @override
  String get tutCh0St2Title => 'Pick a category';

  @override
  String get tutCh0St2Desc =>
      'Categories organize your spending. Tap to choose an existing one or create your own.';

  @override
  String get tutCh0St3Title => 'Pick an account';

  @override
  String get tutCh0St3Desc =>
      'Choose which wallet or bank account this belongs to.';

  @override
  String get tutCh0St4Title => 'Name it';

  @override
  String get tutCh0St4Desc =>
      'Start typing and Kuber will suggest from your past transactions automatically.';

  @override
  String get tutCh0St5Title => 'Smart suggestions';

  @override
  String get tutCh0St5Desc =>
      'Tap a suggestion to auto-fill the name, category, and account in one tap.';

  @override
  String get tutCh0St6Title => 'Notes & attachments';

  @override
  String get tutCh0St6Desc => 'Add context or attach a photo of your receipt.';

  @override
  String get tutCh0St7Title => 'Add tags';

  @override
  String get tutCh0St7Desc =>
      'Tags are custom labels that group transactions across categories.';

  @override
  String get tutCh1Title => 'Home';

  @override
  String get tutCh1Desc => 'Read your monthly snapshot and use quick actions.';

  @override
  String get tutCh1St0Title => 'Your monthly snapshot';

  @override
  String get tutCh1St0Desc =>
      'Net flow for this month at a glance. Green is income, red is expense. Tap to drill down.';

  @override
  String get tutCh1St1Title => 'Privacy mode';

  @override
  String get tutCh1St1Desc =>
      'Tap the eye icon to instantly hide every balance. Perfect for public places.';

  @override
  String get tutCh1St2Title => 'Quick Add';

  @override
  String get tutCh1St2Desc =>
      'Log a transaction in seconds without opening the full form. Just type and go.';

  @override
  String get tutCh1St3Title => 'Recent transactions';

  @override
  String get tutCh1St3Desc =>
      'Your last few transactions appear below the balance card. Tap any to view or edit.';

  @override
  String get tutCh1St4Title => 'Navigation';

  @override
  String get tutCh1St4Desc =>
      'Use the bottom bar to switch between Home, History, Analytics, and More.';

  @override
  String get tutCh2Title => 'History';

  @override
  String get tutCh2Desc => 'Find, filter, inspect and edit past transactions.';

  @override
  String get tutCh2St0Title => 'Transaction timeline';

  @override
  String get tutCh2St0Desc =>
      'All your transactions, grouped by date. Most recent at the top.';

  @override
  String get tutCh2St1Title => 'Quick filters';

  @override
  String get tutCh2St1Desc =>
      'Filter by Income, Expense, or Transfer instantly using these chips.';

  @override
  String get tutCh2St2Title => 'Advanced filters';

  @override
  String get tutCh2St2Desc =>
      'Tap the filter icon to search by date range, account, category, or tags simultaneously.';

  @override
  String get tutCh2St3Title => 'Tap to edit';

  @override
  String get tutCh2St3Desc =>
      'Tap any transaction to view full details, edit fields, or delete it.';

  @override
  String get tutCh3Title => 'Analytics';

  @override
  String get tutCh3Desc => 'Spot trends and understand where your money goes.';

  @override
  String get tutCh3St0Title => 'Set the date range first';

  @override
  String get tutCh3St0Desc =>
      'By default only today\'s data is shown. Tap this pill and pick \"All time\" so the charts below have something to graph.';

  @override
  String get tutCh3St1Title => 'Your financial snapshot';

  @override
  String get tutCh3St1Desc =>
      'Visual breakdowns of where your money goes each month.';

  @override
  String get tutCh3St2Title => 'Spending trends';

  @override
  String get tutCh3St2Desc =>
      'A bar chart showing daily spending. Switch between 7-day and custom time ranges.';

  @override
  String get tutCh3St3Title => 'Category breakdown';

  @override
  String get tutCh3St3Desc =>
      'See which categories consume the most of your budget at a glance.';

  @override
  String get tutCh3St4Title => 'Filters carry over';

  @override
  String get tutCh3St4Desc =>
      'Any filters you set on the History page also update your analytics view.';

  @override
  String get tutCh4Title => 'More & Settings';

  @override
  String get tutCh4Desc =>
      'Customize Kuber, manage data and explore deeper tools.';

  @override
  String get tutCh4St0Title => 'Budgets';

  @override
  String get tutCh4St0Desc =>
      'Set monthly spending limits per category. Kuber tracks your progress automatically.';

  @override
  String get tutCh4St1Title => 'Ask Kuber';

  @override
  String get tutCh4St1Desc =>
      'Your on-device AI assistant. Ask questions about your spending privately.';

  @override
  String get tutCh4St2Title => 'Your data';

  @override
  String get tutCh4St2Desc =>
      'Export as CSV, import from backup, or generate sample data. Everything stays on your device.';

  @override
  String get tutorialUpper => 'TUTORIAL';

  @override
  String get pickChapter => 'Pick a chapter.';

  @override
  String get pickChapterSubtitle =>
      'Five quick chapters, about 2 minutes each. Jump in anywhere.';

  @override
  String get startFromBeginning => 'Start from beginning →';

  @override
  String get skipTutorialConfirm => 'Skip tutorial?';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get skipLabel => 'Skip';

  @override
  String get replayHint => 'You can always replay it from More → Tutorial.';

  @override
  String get replayHintApp =>
      'You can always replay it from More → App Tutorial.';

  @override
  String tutStepsAndMin(String count, String mins) {
    return '$count steps · ~$mins min';
  }

  @override
  String chapterDoneTitle(String num) {
    return 'Chapter $num done! 🎉';
  }

  @override
  String get endTutorial => 'End tutorial';

  @override
  String readyToStart(String title) {
    return 'Ready to start \"$title\"?';
  }

  @override
  String get exitTutorialConfirm => 'Exit tutorial?';

  @override
  String get exitLabel => 'Exit';

  @override
  String chapterXofY(String current, String total) {
    return 'Chapter $current of $total';
  }

  @override
  String get skipTour => 'Skip tour';

  @override
  String get nextArrow => 'Next ›';

  @override
  String get incShort => 'INC';

  @override
  String get expShort => 'EXP';

  @override
  String get disbursedOn => 'Disbursed on';

  @override
  String get emiDebitedFrom => 'EMI debited from';

  @override
  String get searchAccountsHint => 'Search accounts...';

  @override
  String noAccountsMatch(String query) {
    return 'No accounts match \'$query\'';
  }

  @override
  String get monthlyNetAutomation => 'MONTHLY NET';

  @override
  String get disableAccount => 'Disable account';

  @override
  String get enableAccount => 'Enable account';

  @override
  String get accountHidden => 'Account hidden';

  @override
  String get accountRestored => 'Account restored';

  @override
  String get disableAccountConfirm =>
      'This account will be hidden from pickers and home cards. You can re-enable it anytime.';

  @override
  String get hiddenChip => 'Hidden';

  @override
  String get shareStory => 'Share story';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get confirmLabel => 'Confirm';

  @override
  String get sourceLabel => 'Source';

  @override
  String get sourceSms => 'SMS import';

  @override
  String get sourceRecurring => 'Recurring';

  @override
  String get sourceLentBorrowed => 'Lent or Borrowed';

  @override
  String get sourceLoan => 'Loan';

  @override
  String get sourceInvestment => 'Investment / SIP';

  @override
  String get sourceQuickAdd => 'Quick add';

  @override
  String get sourceManual => 'Entered by you';

  @override
  String get sourceBalanceAdjustment => 'Balance adjustment';

  @override
  String get viewOriginalSms => 'View original SMS';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get accountNumberLabel => 'Account Number';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get lastTransactionLabel => 'Last Transaction';

  @override
  String get budgetStatusLabel => 'Budget Status';

  @override
  String get setBudgetForCategory => 'Set a budget for this category';

  @override
  String get usageCountLabel => 'Usage Count';

  @override
  String get firstUsedLabel => 'First Used';

  @override
  String get lastUsedLabel => 'Last Used';

  @override
  String get viewTaggedTransactions => 'View Tagged Transactions';

  @override
  String get accountLabel => 'Account';

  @override
  String get dateTimeTitle => 'Date & Time';

  @override
  String get originalSmsLabel => 'Original SMS';

  @override
  String transactionsCountValue(int count) {
    return '$count transactions';
  }

  @override
  String get editAccountSubtitle => 'Update account details';

  @override
  String get accountNameLabel => 'Account Name';

  @override
  String get accountNameHint => 'Account name';

  @override
  String get accountTypeBank => 'Bank';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeCreditCard => 'Credit Card';

  @override
  String get accountTypeLockedTitle => 'Account type is fixed';

  @override
  String get accountTypeLockedBody =>
      'Account type cannot be changed after creation. To use a different type, create a new account.';

  @override
  String get accountTypeLockedTooltip => 'Why is this locked?';

  @override
  String get accountIdentifierLabel => 'Account Number / Identifier';

  @override
  String get accountIdentifierHint => 'Last 4 digits or full number';

  @override
  String get accountIdentifierHelper =>
      'Last 4 digits or full number. Used to match SMS imports.';

  @override
  String get makeDefaultAccount => 'Make this the default account';

  @override
  String get makeDefaultAccountSub =>
      'Pre-selected when adding transactions via Quick Add, Voice Add or Ask Kuber.';

  @override
  String get currentBalanceLabel => 'Current Balance';

  @override
  String get limitSpentLabel => 'Limit Spent';

  @override
  String get totalLimitLabel => 'Total Limit';

  @override
  String get totalLimitHelper =>
      'The card\'s overall credit limit. Editing this won\'t create an adjustment.';

  @override
  String get balanceAdjustHelper =>
      'Changing this will create a balance adjustment transaction for the difference.';

  @override
  String adjustmentWillBeCredited(String amount) {
    return 'A balance adjustment of $amount will be credited.';
  }

  @override
  String adjustmentWillBeDebited(String amount) {
    return 'A balance adjustment of $amount will be debited.';
  }

  @override
  String get disableAccountToggle => 'Disable Account';

  @override
  String get disableAccountHelper =>
      'Hidden from pickers and home cards. Existing transactions remain.';

  @override
  String get accountDisabledToggle => 'Account disabled';

  @override
  String get accountDisabledHelper =>
      'This account is hidden. Turn off to show it again.';

  @override
  String get accountUpdated => 'Account updated';

  @override
  String get couldntLoadBalance => 'Couldn\'t load balance';

  @override
  String get pickNewDefaultTitle => 'Pick a new default account';

  @override
  String get pickNewDefaultBody =>
      'This is your default account. Choose a replacement before deleting it.';

  @override
  String get adjustmentModalTitle => 'Create adjustment transaction?';

  @override
  String adjustmentModalBody(String noun, String from, String to, String diff) {
    return 'The $noun is changing from $from to $to. A balance adjustment transaction for $diff will be created.';
  }

  @override
  String adjustmentModalChip(String nounCap, String direction, String diff) {
    return '$nounCap $direction $diff. This won\'t count as income or expense.';
  }

  @override
  String get adjustmentCreateAndSave => 'Create and save';

  @override
  String get valueNounBalance => 'balance';

  @override
  String get valueNounLimitSpent => 'limit spent';

  @override
  String get valueNounBalanceCap => 'Balance';

  @override
  String get valueNounLimitSpentCap => 'Limit spent';

  @override
  String get adjustmentIncreasedBy => 'increased by';

  @override
  String get adjustmentDecreasedBy => 'decreased by';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get themeModeSectionLabel => 'Mode';

  @override
  String get themeFamilyDescSignature => 'The classic Kuber look.';

  @override
  String get themeFamilyDescFlewtube => 'Loud and playful.';

  @override
  String get themeFamilyDescWoofsapp => 'Friendly and familiar.';

  @override
  String get themeFamilyDescPurrhub => 'Bold yellow on inky black.';

  @override
  String get themeFamilyDescHonkpe => 'Rich and transactional.';

  @override
  String get themeFamilyDescSqueakdin => 'Buttoned-up and work-first.';

  @override
  String get themeFamilyDescOinkzon => 'Warm and shoppy.';

  @override
  String get applyLabel => 'Apply';

  @override
  String get speedDialNote => 'Add Kuber Notes';

  @override
  String get billingCycle => 'Billing cycle';

  @override
  String get billGenerationDaySection => 'Bill generation day';

  @override
  String get paymentDueDaySection => 'Payment due day';

  @override
  String get remindMe => 'Remind me';

  @override
  String get billReminderSub => 'Notify on the day the bill is generated';

  @override
  String get dueReminderSub => 'Notify on the payment due date';

  @override
  String get billGenerationLabel => 'Bill generation';

  @override
  String get paymentDueLabel => 'Payment due';

  @override
  String dayOfEveryMonth(String ordinal) {
    return '$ordinal of every month';
  }

  @override
  String billDueCrossMonthHint(String billOrdinal, String dueOrdinal) {
    return 'The bill generates on the $billOrdinal and payment is due on the $dueOrdinal, so payment falls in the next month.';
  }

  @override
  String get rangeFrom => 'From';

  @override
  String get rangeTo => 'To';

  @override
  String get changeView => 'Change view';

  @override
  String get iconAndColour => 'Icon & colour';

  @override
  String get chooseIcon => 'Choose icon';

  @override
  String get chooseColour => 'Choose colour';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get activeBudgetsSection => 'Active';

  @override
  String get pausedAndEnded => 'Paused and ended';

  @override
  String get gainLabel => 'Gain';

  @override
  String get returnLabel => 'Return';

  @override
  String moreCountAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String moreCountCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count categories',
      one: '1 category',
    );
    return '$_temp0';
  }

  @override
  String moreCountTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tags',
      one: '1 tag',
    );
    return '$_temp0';
  }

  @override
  String moreCountActive(int count) {
    return '$count active';
  }

  @override
  String moreCountRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
    );
    return '$_temp0';
  }

  @override
  String moreCountOpen(int count) {
    return '$count open';
  }

  @override
  String moreCountHoldings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count holdings',
      one: '1 holding',
    );
    return '$_temp0';
  }

  @override
  String get netBalanceUpper => 'NET BALANCE';

  @override
  String get netWorthUpper => 'NET WORTH';

  @override
  String nothingMatchesQuery(Object query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get searchBudgetsHint => 'Search budgets';

  @override
  String get searchRecurringHint => 'Search recurring';

  @override
  String get searchLoansHint => 'Search loans';

  @override
  String get searchLedgerHint => 'Search people';

  @override
  String get searchInvestmentsHint => 'Search investments';

  @override
  String get textSizeTitle => 'Text size';

  @override
  String get textSizeDesc => 'Make text bigger or smaller';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeCompact => 'Compact';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get textSizePreviewUpper => 'PREVIEW';

  @override
  String get textSizePreviewBody =>
      'Track your daily expenses, manage budgets, and reach your goals with Kuber.';

  @override
  String get textSizePreviewMeta => 'Groceries · Today';

  @override
  String get homeV2GsTitle => 'Let\'s set up Kuber';

  @override
  String get homeV2GsBodyTwoDone => 'Almost there. One more step to go.';

  @override
  String get homeV2GsStep2 => 'Add a transaction yourself';

  @override
  String get homeV2GsStep3 => 'Set your starting balance';

  @override
  String get homeV2GsDoneTitle => 'You\'re all set';

  @override
  String get homeV2GsDoneBody =>
      'Kuber will add more to your Home as you use it.';

  @override
  String get homeV2GsActAdd => 'Add transaction';

  @override
  String get homeV2GsActBalance => 'Set balance';

  @override
  String get homeV2GsCloseA11y => 'Close Get started';

  @override
  String get homeV2GsClosedSnack =>
      'Get started is hidden. You can show it again from Settings.';

  @override
  String get homeV2ActUndo => 'Undo';

  @override
  String get homeV2SetGsTitle => 'Get started card';

  @override
  String get homeV2SetGsSub => 'Show setup steps on Home';

  @override
  String get homeV2SetSgTitle => 'Suggestions on Home';

  @override
  String get homeV2SetSgSub => 'Tips based on your own transactions';

  @override
  String homeV2WBalanceEmpty(String month) {
    return 'Money in and money out for $month will show here.';
  }

  @override
  String get homeV2WBalanceEmptyAct => 'Add transaction';

  @override
  String get homeV2WRecentEmptyBody =>
      'Your latest transactions will show here.';

  @override
  String get homeV2WRecentEmptyAct => 'Import from SMS';

  @override
  String homeV2WEditMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more widgets available.',
      one: '1 more widget available.',
    );
    return '$_temp0';
  }

  @override
  String get homeV2EdSecOn => 'On your Home';

  @override
  String get homeV2EdSgTitle => 'Suggestions';

  @override
  String get homeV2EdSgSub =>
      'Tips from your own transactions. Always at the top.';

  @override
  String get homeV2EdSecAuto => 'Turns on when you add transactions';

  @override
  String get homeV2EdSecMore => 'More widgets';

  @override
  String get homeV2EdAutoNote =>
      'These show up by themselves once they have something to show. Turn one on to show it now.';

  @override
  String get homeV2EdAutoStories =>
      'Turns on when your first money story is ready';

  @override
  String get homeV2EdAutoStats => 'Turns on after a week of spending';

  @override
  String get homeV2EdAutoAccounts => 'Turns on when you add a bank account';

  @override
  String get homeV2EdAutoChart => 'Turns on after spending on 3 different days';

  @override
  String get homeV2EdAutoSms => 'Turns on when bank SMS are waiting';

  @override
  String get homeV2EdAutoEvents =>
      'Turns on with your first reminder, EMI, SIP or recurring payment';

  @override
  String get homeV2EdAutoBudget => 'Turns on with your first budget';

  @override
  String get homeV2EdAutoNotes => 'Turns on with your first note';

  @override
  String get homeV2SgNotNow => 'Not now';

  @override
  String get homeV2SgDismissA11y => 'Don\'t suggest this again';

  @override
  String get homeV2SgDismissedSnack => 'Okay. Kuber won\'t suggest this again.';

  @override
  String homeV2SgRecTitle(String merchant) {
    return '$merchant shows up every month';
  }

  @override
  String homeV2SgRecBody(String amount, int months) {
    return '$amount around the same date for $months months. Add it as recurring to see it before it\'s due.';
  }

  @override
  String get homeV2SgRecAct => 'Add as recurring';

  @override
  String homeV2SgRecDone(String merchant) {
    return '$merchant is now a recurring payment.';
  }

  @override
  String get homeV2SgLoanTitle => 'Paying an EMI?';

  @override
  String homeV2SgLoanBody(String lender) {
    return 'Your SMS show EMI payments to $lender. Add the loan to see what\'s left to pay.';
  }

  @override
  String get homeV2SgLoanAct => 'Add loan';

  @override
  String get homeV2SgLoanDone => 'Loan added.';

  @override
  String get homeV2SgInvTitle => 'Investing through a SIP?';

  @override
  String homeV2SgInvBody(String amount) {
    return 'Your SMS show a SIP of $amount a month. Add it to see all your investments in one place.';
  }

  @override
  String get homeV2SgInvAct => 'Add investment';

  @override
  String get homeV2SgInvDone => 'Investment added.';

  @override
  String homeV2SgLedTitle(String name) {
    return 'Did you lend money to $name?';
  }

  @override
  String homeV2SgLedBody(String name, String amount) {
    return 'You sent $name $amount this month. Keep track of it in Lend and borrow.';
  }

  @override
  String get homeV2SgLedNoteTitle => 'Keep track of money you lent?';

  @override
  String homeV2SgLedNoteBody(String note) {
    return 'Your note \"$note\" mentions lending money. Add it to Lend and borrow so you don\'t forget.';
  }

  @override
  String get homeV2SgLedAct => 'Track it';

  @override
  String get homeV2SgLedDone => 'Added to Lend and borrow.';

  @override
  String homeV2SgBudTitle(String category) {
    return 'Set a budget for $category?';
  }

  @override
  String homeV2SgBudBody(String amount, String category) {
    return 'You spent $amount on $category in the last 30 days. A budget tells you when you\'re close.';
  }

  @override
  String get homeV2SgBudAct => 'Set budget';

  @override
  String homeV2SgBudDone(String category) {
    return 'Budget set for $category.';
  }

  @override
  String homeV2SgCcTitle(String card) {
    return 'Add the billing date for $card';
  }

  @override
  String get homeV2SgCcBody =>
      'Kuber can then show this cycle\'s spending and when the bill is due.';

  @override
  String get homeV2SgCcAct => 'Set billing date';

  @override
  String get homeV2SgCcDone => 'Billing date saved.';

  @override
  String get homeV2SgAskTitle => 'Ask Kuber about your money';

  @override
  String get homeV2SgAskBody =>
      'Try a question like \"How much did I spend on food last month?\"';

  @override
  String get homeV2SgAskAct => 'Ask Kuber';

  @override
  String get homeV2SgVoiceTitle => 'Add transactions by voice';

  @override
  String get homeV2SgVoiceBody =>
      'Tap the mic in Quick Add and say something like \"200 for lunch\".';

  @override
  String get homeV2SgVoiceAct => 'Try it';

  @override
  String get homeV2SgWidgetTitle => 'Put Kuber on your home screen';

  @override
  String get homeV2SgWidgetBody =>
      'See this month\'s spending and add a transaction without opening the app.';

  @override
  String get homeV2SgWidgetAct => 'Add widget';

  @override
  String get homeV2SgCardsTitle => 'Keep your cards in Kuber Cards';

  @override
  String get homeV2SgCardsBody =>
      'Save card details behind your PIN or fingerprint. They stay on this phone.';

  @override
  String get homeV2SgCardsAct => 'Set up Kuber Cards';

  @override
  String get homeV33TourName => 'Why Kuber?';

  @override
  String get homeV33TourMoreSub =>
      'How expense tracking works, and how Kuber helps';

  @override
  String get homeV33TourCardBody =>
      'How tracking every expense helps, and what Kuber can do.';

  @override
  String get homeV33TourCardAct => 'Show me';

  @override
  String get homeV33TourCardHideA11y => 'Hide this card';

  @override
  String get homeV33TourCardHidden => 'You can find `Why Kuber` in More.';

  @override
  String get homeV33TourNext => 'Next';

  @override
  String get homeV33TourDone => 'Done';

  @override
  String homeV33TourPageA11y(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get homeV33P1Title => 'Make noting every expense a habit.';

  @override
  String get homeV33P1SubSms =>
      'Small expenses count too. Noting is easy, and bank SMS add most of them.';

  @override
  String get homeV33P1Sub =>
      'Small expenses count too. Kuber makes noting them easy.';

  @override
  String get homeV33P1Try => 'Add a transaction';

  @override
  String get homeV33P1ColDate => 'Date';

  @override
  String get homeV33P1ColAmount => 'Amount';

  @override
  String get homeV33P1ColSpent => 'Spent on';

  @override
  String get homeV33P1ColCat => 'Category';

  @override
  String get homeV33P1A11y =>
      'Three expenses written in a notebook turn into Kuber transactions, each with a category and an account.';

  @override
  String get homeV33DFood => 'Food delivery';

  @override
  String get homeV33DAuto => 'Auto ride';

  @override
  String get homeV33DMovie => 'Movie tickets';

  @override
  String get homeV33DCoffee => 'Coffee';

  @override
  String get homeV33DGroc => 'Groceries';

  @override
  String get homeV33CFood => 'Food';

  @override
  String get homeV33CTransport => 'Transport';

  @override
  String get homeV33CFun => 'Entertainment';

  @override
  String get homeV33CShopping => 'Shopping';

  @override
  String get homeV33ABank => 'Bank';

  @override
  String get homeV33ACash => 'Cash';

  @override
  String get homeV33ACard => 'Credit card';

  @override
  String get homeV33DBankName => 'Your Bank';

  @override
  String get homeV33P2Title => 'Every account. Even credit cards.';

  @override
  String get homeV33P2Sub =>
      'Bank, cash and cards, with billing cycles and due dates. Add any category.';

  @override
  String get homeV33P2Try => 'Open Accounts';

  @override
  String get homeV33P2Balance => 'Balance';

  @override
  String get homeV33P2Due => 'Due';

  @override
  String homeV33P2Cycle(String start, String end) {
    return 'Billing cycle $start to $end';
  }

  @override
  String homeV33P2DueOn(String date) {
    return 'Due $date';
  }

  @override
  String get homeV33P2PetCare => 'Pet care';

  @override
  String get homeV33P2A11y =>
      'A bank account, cash and a credit card show their balances. The card shows its billing cycle and due date. A new category, Pet care, joins the others.';

  @override
  String get homeV33P3Title => 'Track more than spending.';

  @override
  String get homeV33P3Sub =>
      'Budgets, investments, loans, money lent or borrowed, and subscriptions.';

  @override
  String get homeV33P3Try => 'Open Upcoming events';

  @override
  String get homeV33P3Budget => 'Food budget';

  @override
  String homeV33P3BudgetOf(String spent, String limit) {
    return '$spent of $limit';
  }

  @override
  String get homeV33P3Inv => 'Investments';

  @override
  String get homeV33P3InvTypes => 'SIPs, stocks, FDs and more';

  @override
  String get homeV33P3Loan => 'Home loan';

  @override
  String homeV33P3LoanSub(String amount, int paid, int total) {
    return 'EMI $amount · $paid of $total';
  }

  @override
  String homeV33P3Lent(String name) {
    return '$name owes you';
  }

  @override
  String homeV33P3Borrowed(String name) {
    return 'You owe $name';
  }

  @override
  String get homeV33P3Subs => 'Streaming plan';

  @override
  String homeV33P3SubsSub(String amount) {
    return '$amount a month';
  }

  @override
  String homeV33P3Renews(String date) {
    return 'Renews $date';
  }

  @override
  String homeV33P3Next(String date) {
    return 'Next $date';
  }

  @override
  String get homeV33P3A11y =>
      'A budget fills, an investment grows, a loan EMI is paid, money lent and borrowed shows up, and a subscription renews.';

  @override
  String get homeV33P4Title => 'Your spending, at a glance.';

  @override
  String get homeV33P4Sub =>
      'Every transaction in one searchable history, with many ways to analyze it.';

  @override
  String get homeV33P4Try => 'Open Analytics';

  @override
  String get homeV33P4Search => 'Search';

  @override
  String get homeV33P4Query => 'food';

  @override
  String get homeV33P4Today => 'Today';

  @override
  String get homeV33P4Yesterday => 'Yesterday';

  @override
  String get homeV33P4ByCat => 'By category';

  @override
  String get homeV33P4Monthly => 'Monthly';

  @override
  String get homeV33P4Compare => 'Compare';

  @override
  String get homeV33P4A11y =>
      'A searchable history narrows to food. Then charts show spending by category, by month, and this month against last month.';

  @override
  String get homeV33P5Title => 'Go further when you want.';

  @override
  String get homeV33P5Ask => 'Ask Kuber';

  @override
  String get homeV33P5AskLine =>
      'Ask about your money, answered on your phone.';

  @override
  String get homeV33P5Cards => 'Kuber Cards';

  @override
  String get homeV33P5CardsLine =>
      'Your cards, encrypted and kept on your phone.';

  @override
  String get homeV33P5Notes => 'Kuber Notes';

  @override
  String get homeV33P5NotesLine =>
      'Notes that do the math and add transactions.';

  @override
  String get homeV33P5Calc => 'Calculators and tools';

  @override
  String get homeV33P5CalcLine => 'EMI, SIP, tax and more.';

  @override
  String get homeV33P5Rem => 'Reminders';

  @override
  String get homeV33P5RemLine => 'Never miss a bill.';

  @override
  String get homeV33P5Try => 'Open Signature tools';

  @override
  String get homeV33P5AskQ => 'How much on food this month?';

  @override
  String homeV33P5AskA(String amount) {
    return '$amount so far, 70% of your Food budget.';
  }

  @override
  String get homeV33P5NoteName => 'Goa trip';

  @override
  String get homeV33P5Hotel => 'Hotel';

  @override
  String get homeV33P5Taxi => 'Taxi';

  @override
  String get homeV33P5Travel => 'Travel';

  @override
  String get homeV33P5SipCalc => 'SIP calculator';

  @override
  String homeV33P5PerMonth(String amount) {
    return '$amount a month';
  }

  @override
  String homeV33P5Rate(int rate) {
    return '$rate% a year';
  }

  @override
  String homeV33P5Years(int n) {
    return '$n years';
  }

  @override
  String get homeV33P5RemTitle => 'Electricity bill';

  @override
  String homeV33P5RemDue(String amount) {
    return 'Due tomorrow · $amount';
  }

  @override
  String get homeV33P5A11y =>
      'Ask Kuber answers a question, a card turns over, a note adds up and becomes a transaction, a calculator shows a result, and a bill reminder arrives.';

  @override
  String get homeV3TrkTitle => 'What do you want to track?';

  @override
  String get homeV3TrkBody =>
      'Pick as many as you like. Kuber adds the matching widgets to your Home. You can change this later.';

  @override
  String get homeV31TrkBudgets => 'Budgets';

  @override
  String get homeV3TrkLoans => 'Loans and EMIs';

  @override
  String get homeV3TrkInvest => 'Investments and SIPs';

  @override
  String get homeV3TrkLedger => 'Money lent or borrowed';

  @override
  String get homeV3TrkSubs => 'Subscriptions';

  @override
  String get homeV33EdNeedsTxn => 'Appears after your first transaction';

  @override
  String get homeV33SgQuickTitle => 'Add in one line with Quick Add';

  @override
  String get homeV33SgQuickBody =>
      'Type something like \"250 lunch\" or tap the mic and say it. Kuber turns it into a transaction.';

  @override
  String get homeV33SgQuickAct => 'Try Quick Add';

  @override
  String get homeV33SgSmsTitle => 'Let bank SMS add your expenses';

  @override
  String get homeV33SgSmsBody =>
      'Kuber can read bank SMS on this phone and add most transactions for you. They never leave your phone.';

  @override
  String get homeV33SgSmsAct => 'Import from SMS';

  @override
  String get homeV33GsBodyFresh =>
      'Check your accounts, then add your first transaction. It takes a minute.';

  @override
  String homeV33GsProgress(int done) {
    return '$done of 2 done';
  }

  @override
  String get homeV33GsActAccounts => 'View accounts';

  @override
  String get homeV33GsStepAccounts => 'Set up accounts';

  @override
  String freqEveryNWeeks(String count) {
    return 'Every $count weeks';
  }

  @override
  String freqEveryNMonths(String count) {
    return 'Every $count months';
  }

  @override
  String freqEveryNYears(String count) {
    return 'Every $count years';
  }

  @override
  String get weeksLabel => 'weeks';

  @override
  String get monthsLabel => 'months';

  @override
  String get yearsLabel => 'years';

  @override
  String get intervalInvalid => 'Enter a whole number of 1 or more';

  @override
  String cadenceThen(String interval) {
    return 'then $interval';
  }

  @override
  String get notifItemMissing => 'This item no longer exists.';

  @override
  String nextBackupOn(String date) {
    return 'Next: $date, on app open';
  }

  @override
  String get nextBackupNextOpen => 'Next: on next app open';

  @override
  String get backupsAreOn => 'Backups are on';

  @override
  String get backupsAreOnDesc =>
      'Your first scheduled backup runs on your next app open. Or back up now to save a copy immediately.';

  @override
  String get msWhenTitle => 'When';

  @override
  String get msWhenTitleEmi => 'EMI schedule';

  @override
  String get msWhenTitleReminder => 'Repeat';

  @override
  String get msWhenDaily => 'Daily';

  @override
  String get msWhenWeekly => 'Weekly';

  @override
  String get msWhenMonthly => 'Monthly';

  @override
  String get msWhenQuarterly => 'Quarterly';

  @override
  String get msWhenHalfYearly => 'Every 6 months';

  @override
  String get msWhenYearly => 'Yearly';

  @override
  String get msWhenCustom => 'Custom';

  @override
  String get msWhenOnce => 'Once';

  @override
  String get msWhenEvery => 'Every';

  @override
  String get msWhenUnitDays => 'Days';

  @override
  String get msWhenUnitWeeks => 'Weeks';

  @override
  String get msWhenUnitMonths => 'Months';

  @override
  String get msWhenUnitYears => 'Years';

  @override
  String get msWhenStartsOn => 'Starts on';

  @override
  String get msWhenOnDay => 'On day';

  @override
  String msWhenOnDayValue(String ordinal) {
    return '$ordinal of the month';
  }

  @override
  String get msWhenOn => 'On';

  @override
  String get msWhenEnds => 'Ends';

  @override
  String get msWhenEndsNever => 'Never';

  @override
  String get msWhenEndsOnDate => 'On a date';

  @override
  String get msWhenEndsAfter => 'After';

  @override
  String get msWhenEndDate => 'End date';

  @override
  String get msWhenTimes => 'times';

  @override
  String get msWhenLockedMonthly => 'Repeats every month';

  @override
  String get msWhenLockedHint => 'EMIs are monthly';

  @override
  String get msWhenFirstEmi => 'First EMI';

  @override
  String get msWhenEmiDay => 'EMI day';

  @override
  String msWhenEmiDayValue(String ordinal) {
    return '$ordinal of every month';
  }

  @override
  String get msWhenNumberOfEmis => 'Number of EMIs';

  @override
  String get msWhenLastEmi => 'Last EMI';

  @override
  String get msWhenEveryUnitDay => 'Every day';

  @override
  String get msWhenEveryUnitWeek => 'Every week';

  @override
  String get msWhenEveryUnitMonth => 'Every month';

  @override
  String get msWhenEveryUnitYear => 'Every year';

  @override
  String msWhenEveryNDays(String n) {
    return 'Every $n days';
  }

  @override
  String msWhenEveryNWeeks(String n) {
    return 'Every $n weeks';
  }

  @override
  String msWhenEveryNMonths(String n) {
    return 'Every $n months';
  }

  @override
  String msWhenEveryNYears(String n) {
    return 'Every $n years';
  }

  @override
  String msWhenAnchorWeekday(String weekday) {
    return 'on $weekday';
  }

  @override
  String msWhenAnchorDay(String ordinal) {
    return 'on the $ordinal';
  }

  @override
  String msWhenAnchorDate(String date) {
    return 'on $date';
  }

  @override
  String msWhenSentence(
    String interval,
    String anchor,
    String start,
    String end,
  ) {
    return '$interval$anchor, from $start, $end.';
  }

  @override
  String get msWhenEndNever => 'no end';

  @override
  String msWhenEndUntil(String date) {
    return 'until $date';
  }

  @override
  String msWhenEndTimes(String n) {
    return '$n times';
  }

  @override
  String msWhenEndEmis(String n) {
    return '$n EMIs';
  }

  @override
  String msWhenOnceSentence(String date) {
    return 'On $date.';
  }

  @override
  String msWhenLastOn(String date) {
    return 'Last on $date';
  }

  @override
  String msWhenLastEmiOn(String date) {
    return 'Last EMI $date';
  }

  @override
  String msWhenCountTotal(String n) {
    return '$n times in all';
  }

  @override
  String get msWhenFlagNext => 'next';

  @override
  String get msWhenFlagToday => 'due today';

  @override
  String get msWhenFlagLastDay => 'last day';

  @override
  String get msWhenMonthEnd => 'In shorter months, this falls on the last day.';

  @override
  String get msWhenErrEndBeforeStart =>
      'End date must be after the start date.';

  @override
  String get msWhenErrCount => 'Enter 1 or more.';

  @override
  String get msWhenErrCountPreview => 'Enter how many times, 1 or more.';

  @override
  String get msCalculated => 'Calculated';

  @override
  String get msViewDetails => 'View details';

  @override
  String get msOpenInCalculator => 'Open in a calculator';

  @override
  String get msAdvanced => 'Advanced options';

  @override
  String get msAdvancedSubLoan =>
      'Interest type, loan numbers, already running, spending';

  @override
  String get msAlreadyRunning => 'Already running?';

  @override
  String get msAlreadyRunningSubLoan => 'This loan started before today';

  @override
  String get msAlreadyRunningSubInv => 'I invested before today';

  @override
  String get msOpeningNote =>
      'Opening values never change any account balance.';

  @override
  String get msFromLoans => 'From Loans';

  @override
  String get msFromInvestments => 'From Investments';

  @override
  String msSource(String name) {
    return 'From $name';
  }

  @override
  String msSourceRule(String name) {
    return 'From $name · Recurring';
  }

  @override
  String msFilledFrom(String name) {
    return 'Filled from $name';
  }

  @override
  String msFromCalculator(String calculator) {
    return 'From $calculator';
  }

  @override
  String get msPaused => 'Paused';

  @override
  String get msEnded => 'Ended';

  @override
  String get msClosed => 'Closed';

  @override
  String get msExample => 'Example';

  @override
  String get msBusy => 'Processing, try again in a moment';

  @override
  String get msLoansTotalOutstanding => 'Total outstanding';

  @override
  String get msLoansMonthlyEmis => 'Monthly EMIs';

  @override
  String msLoansNextEmiLine(String date, String name, String amount) {
    return 'Next EMI $date · $name · $amount';
  }

  @override
  String get msLoansActive => 'Active';

  @override
  String msLoansRowSub(String amount, String date) {
    return '$amount EMI · next $date';
  }

  @override
  String get msLoansLeft => 'left';

  @override
  String msLoansProgress(String paid, String total) {
    return '$paid of $total EMIs paid';
  }

  @override
  String msLoansPaidCount(String paid) {
    return '$paid EMIs paid';
  }

  @override
  String get msLoansEmptyTitle => 'No loans yet';

  @override
  String get msLoansEmptyBody =>
      'Add a loan to track its EMIs, what you still owe, and the interest you pay.';

  @override
  String get msLoansFab => 'Add loan';

  @override
  String get msLoansAdd => 'Add loan';

  @override
  String get msLoansEdit => 'Edit loan';

  @override
  String get msLoansType => 'Loan type';

  @override
  String get msLoansName => 'Loan name';

  @override
  String get msLoansLender => 'Lender';

  @override
  String get msLoansEmiAmount => 'EMI amount';

  @override
  String get msLoansPayFrom => 'Pay from';

  @override
  String get msLoansRecordEmis => 'Record EMIs';

  @override
  String get msLoansRecordAuto => 'Automatically';

  @override
  String msLoansRecordAutoHelp(String account) {
    return 'On the EMI day, Kuber records the EMI from $account.';
  }

  @override
  String get msLoansRecordManual => 'I record them myself';

  @override
  String get msLoansSave => 'Save loan';

  @override
  String get msLoansSaveChanges => 'Save changes';

  @override
  String get msLoansInterestType => 'Interest type';

  @override
  String get msLoansReducing => 'Reducing balance';

  @override
  String get msLoansReducingSub => 'Most bank loans';

  @override
  String get msLoansFlat => 'Flat rate';

  @override
  String get msLoansFlatSub => 'Many car, personal and consumer loans';

  @override
  String get msLoansIo => 'Interest-only period first';

  @override
  String get msLoansIoSub => 'Pre-EMI, then regular EMIs';

  @override
  String get msLoansIoMonths => 'Interest-only months';

  @override
  String msLoansIoNotice(String io, String date, String emi, String n) {
    return '$io a month until $date, then $emi a month for $n months.';
  }

  @override
  String get msLoansNumbers => 'Loan numbers';

  @override
  String get msLoansPrincipal => 'Principal';

  @override
  String get msLoansRate => 'Interest rate';

  @override
  String get msLoansTenure => 'Tenure';

  @override
  String get msLoansEmi => 'EMI';

  @override
  String get msLoansYears => 'Years';

  @override
  String get msLoansMonths => 'Months';

  @override
  String get msLoansTotalPayable => 'Total payable · optional';

  @override
  String get msLoansTotalPayableHint => 'Use instead of the rate';

  @override
  String msLoansOrderHelp(String a, String b, String c) {
    return 'Filled in order: $a, $b, $c.';
  }

  @override
  String msLoansSwapHelp(String field, String other) {
    return 'You typed the $field, so $other (filled first) is now calculated.';
  }

  @override
  String msLoansPreview(String emi, String month, String interest) {
    return 'EMI $emi · ends $month · total interest $interest';
  }

  @override
  String msLoansPreviewZero(String emi, String month) {
    return 'EMI $emi · ends $month · no interest';
  }

  @override
  String msLoansMismatchMore(String diff) {
    return 'Your EMI is $diff more than calculated. We\'ll use your EMI.';
  }

  @override
  String msLoansMismatchLess(String diff) {
    return 'Your EMI is $diff less than calculated. We\'ll use your EMI.';
  }

  @override
  String get msLoansErrNeverEnds =>
      'This EMI doesn\'t cover the interest, so the loan would never end.';

  @override
  String msLoansErrNeverEndsPreview(String interest) {
    return 'Monthly interest is $interest. Enter an EMI above that.';
  }

  @override
  String get msLoansErrTotalLow =>
      'This is less than the principal. Check the numbers.';

  @override
  String get msLoansRun1 => 'I know the original loan details';

  @override
  String get msLoansRun1Sub => 'Kuber works out what you\'ve paid';

  @override
  String get msLoansRun2 => 'I know what\'s outstanding today';

  @override
  String get msLoansRun2Sub => 'From a bank statement';

  @override
  String get msLoansRun3 => 'Just track the EMI';

  @override
  String get msLoansRun3Sub => 'No principal and interest split';

  @override
  String get msLoansEmisPaid => 'EMIs paid';

  @override
  String get msLoansPrincipalPaid => 'Principal paid';

  @override
  String get msLoansInterestPaid => 'Interest paid';

  @override
  String get msLoansOutstandingToday => 'Outstanding today';

  @override
  String msLoansRun1Help(String date) {
    return 'Worked out from the loan numbers and your first EMI, $date. Tap any value to change it.';
  }

  @override
  String msLoansAdjustment(String diff) {
    return 'We\'ll use your figure and add the difference as an adjustment: $diff.';
  }

  @override
  String get msLoansEmisLeft => 'EMIs left';

  @override
  String msLoansEmisLeftValue(String n, String month) {
    return '$n · last in $month';
  }

  @override
  String get msLoansPastTotals => 'Past totals · optional';

  @override
  String get msLoansPastTotalsSub => 'Principal and interest paid';

  @override
  String msLoansRun3Notice(String emi, String ordinal) {
    return 'Kuber records each $emi EMI on the $ordinal. You won\'t see principal, interest or what you owe until you add the loan numbers.';
  }

  @override
  String get msLoansSpending => 'Spending';

  @override
  String get msLoansOnlyInterest => 'Count only interest as expense';

  @override
  String get msLoansOnlyInterestHelp =>
      'Principal is counted as a transfer to this loan. Your bank balance still goes down by the full EMI.';

  @override
  String get msLoansFutureOnly =>
      'This applies to future EMIs only. EMIs already recorded keep the way they were counted.';

  @override
  String get msLoansOutstanding => 'Outstanding';

  @override
  String msLoansEndsOn(String month) {
    return 'Ends $month';
  }

  @override
  String msLoansNextEmi(String date) {
    return 'Next EMI · $date';
  }

  @override
  String get msLoansSplit => 'EMI split';

  @override
  String get msLoansPrincipalL => 'Principal';

  @override
  String get msLoansInterestL => 'Interest';

  @override
  String get msLoansTotalInterest => 'Total interest';

  @override
  String get msLoansRecordExtra => 'Record extra payment';

  @override
  String get msLoansChangeRate => 'Change interest rate';

  @override
  String get msLoansCloseLoan => 'Close loan';

  @override
  String get msLoansOutstandingTab => 'Outstanding';

  @override
  String get msLoansSplitTab => 'Principal vs interest';

  @override
  String get msLoansMonth => 'Month';

  @override
  String get msLoansYear => 'Year';

  @override
  String get msLoansBeforeKuber => 'Before Kuber';

  @override
  String get msLoansNext => 'Next';

  @override
  String msLoansRowSplit(String principal, String interest) {
    return 'P $principal · I $interest';
  }

  @override
  String msLoansRowBal(String balance) {
    return 'Bal $balance';
  }

  @override
  String get msLoansInterestOnly => 'Interest only';

  @override
  String msLoansEventExtra(String amount, String date) {
    return 'Extra payment $amount · $date';
  }

  @override
  String msLoansEventExtraSubTenure(String balance) {
    return 'Reduce tenure · balance after $balance';
  }

  @override
  String msLoansEventExtraSubEmi(String balance) {
    return 'Reduce EMI · balance after $balance';
  }

  @override
  String msLoansEventRate(String oldRate, String newRate, String date) {
    return 'Rate $oldRate → $newRate · from $date';
  }

  @override
  String msLoansEventRateSubTenure(String emi) {
    return 'Adjust tenure · EMI stays $emi';
  }

  @override
  String msLoansEventRateSubEmi(String emi) {
    return 'Adjust EMI · new EMI $emi';
  }

  @override
  String msLoansEventCharge(String amount, String date) {
    return 'Charge $amount · $date';
  }

  @override
  String msLoansEventRegular(String date) {
    return 'Regular EMIs start · $date';
  }

  @override
  String msLoansYearSub(String n, String paid) {
    return '$n EMIs · $paid paid';
  }

  @override
  String get msLoansYearEnd => 'balance at year end';

  @override
  String msLoansChartNote(String year, String amount) {
    return 'The drop in $year is your $amount extra payment.';
  }

  @override
  String msLoansIoBanner(String month, String io, String emi, String date) {
    return 'Interest only until $month: $io a month. Regular EMIs of $emi start on $date.';
  }

  @override
  String get msLoansExtraTitle => 'Extra payment';

  @override
  String get msLoansExtraQ => 'Does this go toward principal?';

  @override
  String get msLoansExtraYes => 'Yes';

  @override
  String get msLoansExtraNo => 'No, it\'s a fee or charge';

  @override
  String get msLoansReduceTenure => 'Reduce tenure';

  @override
  String get msLoansReduceTenureSub => 'Same EMI, loan ends sooner';

  @override
  String get msLoansReduceEmi => 'Reduce EMI';

  @override
  String get msLoansReduceEmiSub => 'Same end date, lower EMI';

  @override
  String get msLoansSavesMore => 'Saves more interest';

  @override
  String msLoansExtraPreviewTenure(String amount, String n) {
    return 'Saves $amount interest · ends $n months earlier';
  }

  @override
  String msLoansExtraPreviewEmi(String amount, String emi) {
    return 'Saves $amount interest · EMI becomes $emi';
  }

  @override
  String get msLoansPrepayCharge => 'Prepayment charge · optional';

  @override
  String get msLoansPrepayChargeHint => 'Amount or %';

  @override
  String msLoansFeeNotice(String outstanding) {
    return 'Recorded as an expense in Loan charges. What you owe stays $outstanding.';
  }

  @override
  String get msLoansLoanCharges => 'Loan charges';

  @override
  String get msLoansNoNumbersPreview =>
      'Add the loan numbers to see what this saves.';

  @override
  String get msLoansNewRate => 'New rate';

  @override
  String get msLoansEffectiveFrom => 'Effective from';

  @override
  String get msLoansThen => 'Then';

  @override
  String get msLoansAdjustEmi => 'Adjust EMI';

  @override
  String get msLoansAdjustTenure => 'Adjust tenure';

  @override
  String msLoansRatePreviewEmi(String emi, String date) {
    return 'New EMI $emi from $date';
  }

  @override
  String msLoansRatePreviewEmiSub(String month, String amount) {
    return 'Ends $month as before · saves $amount interest';
  }

  @override
  String msLoansRatePreviewTenure(String emi, String month) {
    return 'EMI stays $emi · ends $month';
  }

  @override
  String msLoansRatePreviewTenureSub(String n, String amount) {
    return '$n months earlier · saves $amount interest';
  }

  @override
  String msLoansRatePreviewTenureSubLater(String n, String amount) {
    return '$n months later · costs $amount more interest';
  }

  @override
  String get msLoansFloatingHelp =>
      'Floating-rate loans change with the lender\'s benchmark. Record each change here.';

  @override
  String msLoansPaidOff(String name) {
    return '$name is fully paid';
  }

  @override
  String msLoansCloseTitle(String name) {
    return 'Close $name?';
  }

  @override
  String get msLoansCloseBody =>
      'It moves to Closed. Its EMIs stop and its history stays.';

  @override
  String msLoansExtraName(String name) {
    return 'Extra payment · $name';
  }

  @override
  String msLoansChargeName(String name) {
    return 'Loan charge · $name';
  }

  @override
  String get msLoansSaved => 'Loan saved';

  @override
  String get msLoansRateSaved => 'Rate change saved';

  @override
  String get msLoansExtraSaved => 'Extra payment recorded';

  @override
  String get msInvPortfolio => 'Portfolio value';

  @override
  String get msInvInvested => 'Invested';

  @override
  String get msInvGain => 'Gain';

  @override
  String get msInvXirr => 'XIRR';

  @override
  String msInvOverall(String pct) {
    return '$pct overall';
  }

  @override
  String get msInvUpdateValues => 'Update values';

  @override
  String get msInvGroupMutualFunds => 'Mutual funds';

  @override
  String get msInvGroupStocks => 'Stocks';

  @override
  String get msInvGroupGold => 'Gold';

  @override
  String get msInvGroupCrypto => 'Crypto';

  @override
  String get msInvGroupFixed => 'Fixed return';

  @override
  String get msInvGroupOther => 'Property and other';

  @override
  String msInvStale(String n) {
    return 'Updated $n days ago';
  }

  @override
  String msInvUpdatedOn(String month) {
    return 'Updated $month';
  }

  @override
  String get msInvEmptyTitle => 'No investments yet';

  @override
  String get msInvEmptyBody =>
      'Add a fund, stock, FD or anything else you own. Kuber shows what it\'s worth and how much you\'ve gained.';

  @override
  String get msInvFab => 'Add investment';

  @override
  String get msInvAdd => 'Add investment';

  @override
  String get msInvEdit => 'Edit investment';

  @override
  String get msInvSave => 'Save investment';

  @override
  String get msInvPickIntro =>
      'What kind of investment is it? The form adapts to how its value changes.';

  @override
  String get msInvPickMarket => 'Value changes with the market';

  @override
  String get msInvPickMarketSub => 'You update the value now and then';

  @override
  String get msInvPickFixed => 'Fixed return';

  @override
  String get msInvPickFixedSub => 'Kuber calculates the value for you';

  @override
  String get msInvPickOther => 'Other';

  @override
  String get msInvPickOtherSub => 'You update the value rarely';

  @override
  String get msInvTypeMutualFund => 'Mutual fund';

  @override
  String get msInvTypeStocks => 'Stocks';

  @override
  String get msInvTypeEtf => 'ETF';

  @override
  String get msInvTypeGold => 'Gold';

  @override
  String get msInvTypeCrypto => 'Crypto';

  @override
  String get msInvTypeFd => 'Fixed deposit';

  @override
  String get msInvTypeRd => 'Recurring deposit';

  @override
  String get msInvTypePpf => 'PPF';

  @override
  String get msInvTypeBonds => 'Bonds';

  @override
  String get msInvTypeProperty => 'Property';

  @override
  String get msInvTypeCollectibles => 'Collectibles';

  @override
  String get msInvTypeCustom => 'Custom';

  @override
  String get msInvName => 'Name';

  @override
  String get msInvHow => 'How do you invest?';

  @override
  String get msInvOneTime => 'One time';

  @override
  String get msInvSip => 'SIP';

  @override
  String get msInvAmountInvested => 'Amount invested';

  @override
  String get msInvCurrentValue => 'Current value';

  @override
  String get msInvUnits => 'Units · optional';

  @override
  String get msInvUnitsHint => 'e.g. 612.4';

  @override
  String get msInvSipAmount => 'SIP amount';

  @override
  String get msInvFromAccount => 'From account';

  @override
  String get msInvStepUp => 'Yearly step-up';

  @override
  String get msInvStepUpSwitch => 'Increase every year';

  @override
  String get msInvStepUpField => 'Step-up';

  @override
  String msInvStepUpNotice(
    String a,
    String b,
    String date1,
    String c,
    String date2,
  ) {
    return '$a now, $b from $date1, $c from $date2.';
  }

  @override
  String get msInvPrincipal => 'Principal';

  @override
  String get msInvInstallment => 'Installment';

  @override
  String get msInvTerms => 'Terms';

  @override
  String get msInvRate => 'Interest rate';

  @override
  String get msInvStartDate => 'Start date';

  @override
  String get msInvTenure => 'Tenure';

  @override
  String get msInvCompounding => 'Compounding';

  @override
  String get msInvCompMonthly => 'Monthly';

  @override
  String get msInvCompQuarterly => 'Quarterly';

  @override
  String get msInvCompHalfYearly => 'Half-yearly';

  @override
  String get msInvCompYearly => 'Yearly';

  @override
  String get msInvPayout => 'Payout type';

  @override
  String get msInvPayCumulative => 'Cumulative';

  @override
  String get msInvPayMonthly => 'Monthly';

  @override
  String get msInvPayQuarterly => 'Quarterly';

  @override
  String get msInvPayYearly => 'Yearly';

  @override
  String get msInvAtMaturity => 'At maturity';

  @override
  String msInvMaturityLine(String date, String amount) {
    return 'on $date · interest $amount';
  }

  @override
  String msInvMaturityLineRd(String date, String amount) {
    return 'on $date · you deposit $amount';
  }

  @override
  String get msInvAutoValue =>
      'Kuber calculates the value every day. You never need to update it.';

  @override
  String get msInvInvestedSoFar => 'Invested so far';

  @override
  String get msInvUnrealized => 'Unrealized';

  @override
  String get msInvRealized => 'Realized gain';

  @override
  String get msInvWithdrawn => 'Withdrawn';

  @override
  String get msInvLastUpdated => 'Last updated';

  @override
  String msInvSipLine(String amount, String ordinal) {
    return '$amount on the $ordinal';
  }

  @override
  String msInvSipLineStep(String amount, String ordinal, String pct) {
    return '$amount on the $ordinal · +$pct yearly';
  }

  @override
  String get msInvUpdateValue => 'Update value';

  @override
  String get msInvAddMoney => 'Add money';

  @override
  String get msInvWithdraw => 'Withdraw';

  @override
  String get msInvValueToday => 'Value today';

  @override
  String msInvMatures(String date) {
    return 'Matures $date';
  }

  @override
  String get msInvWithdrawEarly => 'Withdraw early';

  @override
  String get msInvLegendValue => 'Current value';

  @override
  String get msInvLegendInvested => 'Amount invested';

  @override
  String get msInvLegendGain => 'Gain';

  @override
  String get msInvActivity => 'Activity';

  @override
  String get msInvActValue => 'Value updated';

  @override
  String get msInvActSip => 'SIP installment';

  @override
  String get msInvActTopUp => 'Top-up';

  @override
  String get msInvActWithdrawal => 'Withdrawal';

  @override
  String get msInvActOpening => 'Opening value';

  @override
  String get msInvActInterest => 'Interest added';

  @override
  String get msInvActOpened => 'Deposit opened';

  @override
  String get msInvTransaction => 'Transaction';

  @override
  String get msInvAddPast => 'Add a value for a past date';

  @override
  String get msInvAddPastTitle => 'Add a past value';

  @override
  String get msInvValueOnDate => 'Value on that date';

  @override
  String get msInvPastHelp =>
      'Past values fill in the chart. They don\'t change the current value or any balance.';

  @override
  String get msInvInterestLocked =>
      'Interest entries are calculated and can\'t be edited.';

  @override
  String msInvUpdSub(String n) {
    return '$n holdings · about 30 seconds';
  }

  @override
  String get msInvUpdHelp =>
      'Fixed deposits and PPF update themselves, so they aren\'t listed.';

  @override
  String get msInvNewValue => 'New value';

  @override
  String msInvSaveN(String n) {
    return 'Save $n values';
  }

  @override
  String get msInvSaveEmpty => 'Save';

  @override
  String msInvSaved(String n, String amount) {
    return '$n values updated. Portfolio $amount.';
  }

  @override
  String get msInvWithdrawAll => 'Withdraw everything';

  @override
  String msInvValueLine(String amount) {
    return 'Value $amount';
  }

  @override
  String get msInvRedeemed => 'Amount redeemed';

  @override
  String get msInvExitLoad => 'Exit load · optional';

  @override
  String get msInvTax => 'Tax · optional';

  @override
  String get msInvReceived => 'Amount received';

  @override
  String get msInvToAccount => 'To account';

  @override
  String get msInvDate => 'Date';

  @override
  String get msInvAfter => 'After this withdrawal';

  @override
  String msInvCloseTitle(String name) {
    return 'Close $name?';
  }

  @override
  String msInvCloseBody(String amount) {
    return 'You received $amount. Here\'s how it did.';
  }

  @override
  String get msInvCloseInvested => 'Invested';

  @override
  String get msInvCloseReceived => 'Received';

  @override
  String get msInvCloseReturn => 'Final return';

  @override
  String get msInvCloseXirr => 'XIRR';

  @override
  String get msInvCloseHeld => 'Held';

  @override
  String msInvHeldValue(String n) {
    return '$n months';
  }

  @override
  String get msInvCloseHelp =>
      'It moves to Closed. You can still open it and see its history.';

  @override
  String get msInvCloseCta => 'Close holding';

  @override
  String get msInvBack => 'Back';

  @override
  String get msInvPenalty => 'Penalty rate';

  @override
  String get msInvPenaltySupport =>
      'Your bank\'s penalty for withdrawing before maturity';

  @override
  String get msInvRateAfterPenalty => 'Rate after penalty';

  @override
  String get msInvInterestEarned => 'Interest earned';

  @override
  String get msInvLessThanToday => 'Less than value today';

  @override
  String get msInvWithdrawClose => 'Withdraw and close';

  @override
  String msInvMatured(String amount, String account) {
    return 'Your FD matured: $amount. Move it to $account?';
  }

  @override
  String msInvMaturedSub(String name, String date) {
    return '$name · matured $date';
  }

  @override
  String get msInvRenew => 'Renew';

  @override
  String msInvMove(String account) {
    return 'Move to $account';
  }

  @override
  String msInvNotifTitle(String amount) {
    return 'Your FD matured: $amount';
  }

  @override
  String msInvNotifBody(String account) {
    return 'Move it to $account?';
  }

  @override
  String get msInvNotifLater => 'Not now';

  @override
  String msInvWithdrawName(String name) {
    return 'Withdrawal · $name';
  }

  @override
  String msInvMaturityName(String name) {
    return 'Maturity · $name';
  }

  @override
  String msInvTopUpName(String name) {
    return 'Top-up · $name';
  }

  @override
  String get msInvValuesUpdated => 'Value updated';

  @override
  String msInvClosedSnack(String name) {
    return '$name moved to Closed';
  }

  @override
  String get msRecEveryMonth => 'Every month';

  @override
  String get msRecOut => 'out';

  @override
  String get msRecIn => 'in';

  @override
  String get msRecBills => 'Bills and subscriptions';

  @override
  String get msRecEmis => 'EMIs';

  @override
  String get msRecSips => 'SIPs';

  @override
  String get msRecIncome => 'Income';

  @override
  String get msRecActive => 'Active';

  @override
  String get msRecPaused => 'Paused';

  @override
  String get msRecProcessed => 'Recently processed';

  @override
  String get msRecEnded => 'Ended';

  @override
  String msRecRowSub(String interval, String date) {
    return '$interval · next $date';
  }

  @override
  String msRecNextOnly(String date) {
    return 'next $date';
  }

  @override
  String msRecDue(String interval, String account) {
    return '$interval · due today · $account';
  }

  @override
  String msRecPausedSince(String interval, String month) {
    return '$interval · paused since $month';
  }

  @override
  String get msRecViewHistory => 'View in History';

  @override
  String get msRecEmptyTitle => 'Nothing repeats yet';

  @override
  String get msRecEmptyBody =>
      'Add rent, bills, subscriptions or income that repeats. Loan EMIs and SIPs show up here on their own.';

  @override
  String get msRecFab => 'Add recurring';

  @override
  String get msRecNew => 'New recurring';

  @override
  String get msRecEdit => 'Edit recurring';

  @override
  String get msRecExpense => 'Expense';

  @override
  String get msRecIncomeType => 'Income';

  @override
  String get msRecAmount => 'Amount';

  @override
  String get msRecName => 'Name';

  @override
  String get msRecCategory => 'Category';

  @override
  String get msRecAccount => 'Account';

  @override
  String msRecSkipNext(String date) {
    return 'Skip next · $date';
  }

  @override
  String get msRecSkipNextShort => 'Skip next';

  @override
  String get msRecPause => 'Pause';

  @override
  String get msRecResume => 'Resume';

  @override
  String get msRecSave => 'Save recurring';

  @override
  String get msRecSaveChanges => 'Save changes';

  @override
  String get msRecFutureTitle => 'Apply changes to future occurrences only?';

  @override
  String msRecFutureBody(String name, String n) {
    return '$name has run $n times. Those transactions stay as they are. The new amount and schedule start from the next occurrence.';
  }

  @override
  String get msRecFutureCta => 'Apply to future';

  @override
  String msRecSkipped(String date, String date2) {
    return 'Skipped $date. Next on $date2.';
  }

  @override
  String msRecSkippedEnd(String date) {
    return 'Skipped $date.';
  }

  @override
  String get msRecUsually => 'Usually';

  @override
  String get msRecLast12 => 'Last 12 months';

  @override
  String get msRecMonthlyAvg => 'Monthly avg';

  @override
  String get msRecProcessedKv => 'Processed';

  @override
  String msRecProcessedN(String n) {
    return '$n times';
  }

  @override
  String get msRecMonthlyTotal => 'Monthly total';

  @override
  String msRecAvgCaption(String amount) {
    return 'last 12 months · avg $amount';
  }

  @override
  String get msRecSkippedRow => 'Skipped';

  @override
  String get msRecRange12 => '12 months';

  @override
  String get msRecRangeAll => 'All';

  @override
  String msRecDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get msRecDeleteBody =>
      'It stops repeating. Transactions it already added stay in History.';

  @override
  String msRecPausedSnack(String name) {
    return '$name paused';
  }

  @override
  String msRecResumedSnack(String name, String date) {
    return '$name resumed. Next on $date.';
  }

  @override
  String get msRecSaved => 'Recurring saved';

  @override
  String get msCalcSave => 'Save';

  @override
  String get msCalcAddLoan => 'Add as loan';

  @override
  String get msCalcStartSip => 'Start this SIP';

  @override
  String get msCalcAddFd => 'Add this FD';

  @override
  String get msCalcAddRd => 'Add this RD';

  @override
  String get msCalcAddInvestments => 'Add to investments';

  @override
  String get msCalcEmi => 'EMI calculator';

  @override
  String get msCalcPrepay => 'Loan Prepayment';

  @override
  String get msCalcSipAmount => 'SIP Amount';

  @override
  String get msCalcGoal => 'Goal Planner';

  @override
  String get msCalcReturns => 'Investment Returns';

  @override
  String get msCalcInflation => 'Inflation';

  @override
  String get msCalcFdRd => 'FD / RD';

  @override
  String get msCalcPpf => 'PPF Calculator';

  @override
  String get msTxnSourceAuto => 'Recorded automatically';

  @override
  String get msTxnSourceSip => 'SIP installment';

  @override
  String get msTxnSourceLabel => 'Source';

  @override
  String get msTxnSplit => 'EMI split';

  @override
  String get msTxnDeletedLoan => 'From a deleted loan';

  @override
  String get msTxnDeletedInvestment => 'From a deleted investment';

  @override
  String get msTxnDeletedRule => 'From a deleted recurring rule';

  @override
  String bgStepProcessing(String n) {
    return 'Adding $n recurring transactions…';
  }

  @override
  String get bgStepProcessingOne => 'Adding 1 recurring transaction…';

  @override
  String get bgStepMaturity => 'Checking deposits…';

  @override
  String get bgStepBackup => 'Backing up…';

  @override
  String get bgStepStarting => 'Catching up…';

  @override
  String get bgContinues => 'Continues in the background';

  @override
  String bgResultRecurring(String n) {
    return '$n recurring added';
  }

  @override
  String get bgResultRecurringOne => '1 recurring added';

  @override
  String get bgResultBackup => 'Backup done';

  @override
  String bgResultMatured(String n) {
    return '$n deposits matured';
  }

  @override
  String get bgFailBackup => 'Backup failed';

  @override
  String bgFailRecurring(String n) {
    return 'Couldn\'t add $n recurring transactions';
  }

  @override
  String get bgFailRecurringOne => 'Couldn\'t add 1 recurring transaction';

  @override
  String get bgRetry => 'Retry';

  @override
  String get bgView => 'View';

  @override
  String get bgChannelName => 'Background tasks';

  @override
  String get bgChannelDesc =>
      'Recurring transactions, EMIs, SIPs and backups added in the background';

  @override
  String get bgNotifTitle => 'Kuber is catching up';

  @override
  String get bgNotifFailedTitle => 'A background task failed';

  @override
  String get numFormatAutomatic => 'Automatic';

  @override
  String get numFormatAutomaticSub =>
      'Lakh for rupees, standard for other currencies';

  @override
  String get showCurrencyCode => 'Show currency code instead of symbol';

  @override
  String get showCurrencyCodeSub =>
      'Useful when currencies share a symbol, like C\$ and A\$';

  @override
  String get currencySuggested => 'Suggested';

  @override
  String get currencyAll => 'All currencies';

  @override
  String get currencySearchHint => 'Search by name, code or country';

  @override
  String get currencyNoMatch => 'No currency matches';

  @override
  String converterUnavailable(String code) {
    return '$code isn\'t in the converter. Its rates come from the European Central Bank list, which doesn\'t include it.';
  }

  @override
  String get msInfoReducingTitle => 'Reducing balance';

  @override
  String get msInfoReducingLine =>
      'Most bank loans. Interest is charged only on what you still owe, so each EMI pays off a little more principal than the last.';

  @override
  String msInfoReducingEx(String p, String r, String y, String emi) {
    return '$p at $r for $y years has an EMI of $emi.';
  }

  @override
  String get msInfoReducingRow1 => 'Month 1 interest';

  @override
  String get msInfoReducingRow2 => 'Month 1 principal';

  @override
  String get msInfoReducingAfter =>
      'By the end, almost all of the EMI is principal.';

  @override
  String get msInfoFlatTitle => 'Flat rate';

  @override
  String get msInfoFlatLine =>
      'Many car, personal and consumer loans. Interest is charged on the original amount for the whole tenure, even as you repay.';

  @override
  String msInfoFlatEx(String p, String r, String y) {
    return '$p at $r flat for $y years.';
  }

  @override
  String get msInfoFlatRow1 => 'Interest every year';

  @override
  String get msInfoFlatRow2 => 'Total interest';

  @override
  String get msInfoFlatRow3 => 'EMI';

  @override
  String msInfoFlatAfter(String r, String amount) {
    return 'At $r reducing balance, the same loan would cost $amount in interest.';
  }

  @override
  String get msInfoIoTitle => 'With an interest-only period first';

  @override
  String get msInfoIoLine =>
      'Also called pre-EMI. For the first few months you pay only the interest. Regular EMIs start after that.';

  @override
  String msInfoIoEx(String p, String r, String n) {
    return '$p at $r with $n interest-only months.';
  }

  @override
  String msInfoIoRow1(String n) {
    return 'Months 1 to $n';
  }

  @override
  String msInfoIoRow2(String n) {
    return 'Then, for $n months';
  }

  @override
  String msInfoIoRowValue(String amount) {
    return '$amount a month';
  }

  @override
  String get msInfoIoAfter =>
      'The interest-only months don\'t reduce what you owe.';

  @override
  String get msInfoCalculatedTitle => 'Calculated fields';

  @override
  String get msInfoCalculatedLine =>
      'Fill in any 3 of principal, rate, tenure and EMI. Kuber works out the 4th and marks it Calculated.';

  @override
  String get msInfoCalculatedAfter =>
      'Type over a calculated field to use your own figure. The field you filled in first then becomes the calculated one.';

  @override
  String get msInfoMismatchTitle => 'Why your EMI is different';

  @override
  String get msInfoMismatchLine =>
      'Banks often round the EMI, add loan insurance to it, or charge interest for the days before your first EMI. Kuber always uses the EMI you enter.';

  @override
  String get msInfoMismatchRow1 => 'Calculated EMI';

  @override
  String get msInfoMismatchRow2 => 'Your EMI';

  @override
  String get msInfoMismatchRow3 => 'Difference';

  @override
  String get msInfoRun1Title => 'I know the original loan details';

  @override
  String get msInfoRun1Line =>
      'Enter the loan as it was sanctioned. Kuber works out everything you\'ve paid until today.';

  @override
  String get msInfoRun2Title => 'I know what\'s outstanding today';

  @override
  String get msInfoRun2Line =>
      'Use the outstanding amount from your latest bank statement. Kuber works out how many EMIs are left.';

  @override
  String get msInfoRun2After =>
      'Past totals are optional. Add them if you want lifetime interest to be complete.';

  @override
  String get msInfoRun3Title => 'Just track the EMI';

  @override
  String get msInfoRun3Line =>
      'Kuber records each EMI on its day without splitting it into principal and interest. You can add the loan numbers later.';

  @override
  String get msInfoAdjustmentTitle => 'Adjustment';

  @override
  String get msInfoAdjustmentLine =>
      'When your figure is different from Kuber\'s, Kuber keeps yours and records the difference as an opening adjustment on the loan.';

  @override
  String get msInfoAdjustmentRow1 => 'Kuber calculated';

  @override
  String get msInfoAdjustmentRow2 => 'You entered';

  @override
  String get msInfoAdjustmentAfter =>
      'Adjustments only change the loan. No account balance changes.';

  @override
  String get msInfoInterestOnlyTitle => 'Count only interest as expense';

  @override
  String get msInfoInterestOnlyLine =>
      'Only the interest part of each EMI counts as spending in Analytics and Budgets. The principal is counted as a transfer to this loan.';

  @override
  String get msInfoInterestOnlyRow1 => 'Interest, counted as expense';

  @override
  String get msInfoInterestOnlyRow2 => 'Principal, counted as transfer';

  @override
  String get msInfoInterestOnlyAfter =>
      'Your bank balance goes down by the full EMI either way. Changing this applies to future EMIs only.';

  @override
  String get msInfoTenureEmiTitle => 'Reduce tenure or reduce EMI';

  @override
  String get msInfoTenureEmiLine =>
      'Reduce tenure keeps your EMI the same and ends the loan sooner. Reduce EMI keeps the end date and lowers each EMI. Reducing tenure saves more interest.';

  @override
  String get msInfoPrepayChargeTitle => 'Prepayment charge';

  @override
  String get msInfoPrepayChargeLine =>
      'Some lenders charge a fee when you pay extra. Kuber records it as an expense. It doesn\'t reduce what you owe. Floating-rate home loans usually have none.';

  @override
  String get msInfoPrepayRow1 => 'Goes to principal';

  @override
  String get msInfoPrepayRow2 => 'Charge, recorded as expense';

  @override
  String get msInfoPrepayRow3 => 'Leaves your account';

  @override
  String get msInfoFloatingTitle => 'Floating rate';

  @override
  String get msInfoFloatingLine =>
      'A floating rate moves with the lender\'s benchmark, so it can change during the loan. When your lender changes it, record it here so the schedule stays right.';

  @override
  String get msInfoXirrTitle => 'XIRR';

  @override
  String get msInfoXirrLine =>
      'Your yearly return, taking into account when each amount went in and came out. It lets you compare a SIP with an FD fairly.';

  @override
  String msInfoXirrEx(String amount, String invested, String value) {
    return '$amount every month for 3 years is $invested invested. It\'s worth $value today.';
  }

  @override
  String get msInfoXirrRow1 => 'Total gain';

  @override
  String get msInfoXirrRow2 => 'XIRR';

  @override
  String msInfoXirrValue(String pct) {
    return '$pct a year';
  }

  @override
  String get msInfoRealizedTitle => 'Unrealized and realized gain';

  @override
  String get msInfoRealizedLine =>
      'Unrealized gain is on paper: what you would gain if you sold everything today. Realized gain is what you actually made on money you\'ve already withdrawn.';

  @override
  String get msInfoProportionalTitle => 'How withdrawals are counted';

  @override
  String get msInfoProportionalLine =>
      'When you withdraw part of a holding, the invested amount goes down in the same proportion as the value you took out.';

  @override
  String msInfoProportionalEx(String value, String invested, String amount) {
    return 'Value $value with $invested invested. You withdraw $amount, which is 20% of the value.';
  }

  @override
  String get msInfoProportionalRow1 => 'Invested goes down by';

  @override
  String get msInfoProportionalRow2 => 'Realized gain';

  @override
  String get msInfoProportionalRow3 => 'Left invested';

  @override
  String get msInfoStepupTitle => 'Yearly step-up';

  @override
  String get msInfoStepupLine =>
      'Your SIP grows by a fixed percentage or amount once a year, usually in line with your salary.';

  @override
  String msInfoStepupEx(String amount) {
    return '$amount a month with a 10% step-up.';
  }

  @override
  String msInfoStepupRow(String n) {
    return 'Year $n';
  }

  @override
  String get msInfoCompoundingTitle => 'Compounding';

  @override
  String get msInfoCompoundingLine =>
      'How often interest is added to your deposit so that it starts earning interest too. More often means a little more.';

  @override
  String msInfoCompoundingEx(String amount) {
    return '$amount at 7% for 5 years.';
  }

  @override
  String get msInfoPayoutTitle => 'Payout type';

  @override
  String get msInfoPayoutLine =>
      'Cumulative adds the interest to the deposit and pays everything at maturity. Payout sends the interest to your bank account every month, quarter or year.';

  @override
  String get msInfoPayoutRow1 => 'Cumulative, at maturity';

  @override
  String get msInfoPayoutRow2 => 'Quarterly payout';

  @override
  String msInfoPayoutRow2Value(String amount) {
    return '$amount every quarter';
  }

  @override
  String get msInfoPayoutRow3 => 'Quarterly payout, at maturity';

  @override
  String get msInfoAccruedTitle => 'Value today';

  @override
  String get msInfoAccruedLine =>
      'What a fixed deposit is worth today, including interest earned so far that hasn\'t been paid yet. Kuber works it out every day, so you never update it.';

  @override
  String get msInfoUpdatedTitle => 'Last updated';

  @override
  String get msInfoUpdatedLine =>
      'Market prices change every day, but Kuber only knows the value you last entered. Values older than 30 days are marked so you know which ones to update.';

  @override
  String get msInfoMonthlyTitle => 'How the monthly amount works';

  @override
  String get msInfoMonthlyLine =>
      'Anything that isn\'t monthly is converted to what it costs per month. Each item is counted once, even if it also appears in Loans or Investments.';

  @override
  String msInfoMonthlyRow1(String amount) {
    return '$amount every year';
  }

  @override
  String msInfoMonthlyRow2(String amount) {
    return '$amount every 3 months';
  }

  @override
  String msInfoMonthlyRow3(String amount) {
    return '$amount every week';
  }

  @override
  String get msInfoMonthlyAfter =>
      'Weeks use 52 weeks ÷ 12. Daily items use 30 days a month.';

  @override
  String get msRecUndo => 'Undo';

  @override
  String get msLoansFirstEmiDate => 'First EMI date';

  @override
  String get msLoansNextEmiDate => 'Next EMI date';

  @override
  String get appDrawerSection => 'App drawer';

  @override
  String get appDrawerDescription =>
      'Give Kuber Cards, Notes or Reminders their own icon in your phone\'s app list.';

  @override
  String get appDrawerAdd => 'Add to app drawer';

  @override
  String get appDrawerRemove => 'Remove from app drawer';

  @override
  String get appDrawerCards => 'Kuber Cards';

  @override
  String get appDrawerNotes => 'Kuber Notes';

  @override
  String get appDrawerReminders => 'Reminders';

  @override
  String appDrawerAdded(String name) {
    return '$name added to your app drawer. It can take a moment to show up.';
  }

  @override
  String appDrawerRemoved(String name) {
    return '$name removed from your app drawer';
  }

  @override
  String get appDrawerFailed => 'Could not change the app drawer. Try again.';

  @override
  String get msLoansChangeRateShort => 'Change rate';

  @override
  String msLoansPageOf(String n, String total) {
    return 'Year $n of $total';
  }

  @override
  String get msLoansPrevYear => 'Previous year';

  @override
  String get msLoansNextYear => 'Next year';

  @override
  String get msLoansRecordAutoHelpNoAccount =>
      'On the EMI day, Kuber records the EMI from the account you pay from.';

  @override
  String get betaTag => 'Beta';

  @override
  String get appDrawerCardsSub => 'Add Kuber Cards to your app drawer';

  @override
  String get appDrawerNotesSub => 'Add Kuber Notes to your app drawer';

  @override
  String get appDrawerRemindersSub => 'Add Reminders to your app drawer';

  @override
  String get msLoansViewSchedule => 'View EMI schedule';

  @override
  String get msLoansExtraChoose => 'What should change?';

  @override
  String get msLoansExtraHelp =>
      'Paying extra lowers what you owe, so you pay less interest from now on. Pick how you want that saving.';

  @override
  String msLoansReduceTenureHow(String emi) {
    return 'Keep paying $emi a month. The loan ends sooner.';
  }

  @override
  String get msLoansReduceEmiHow =>
      'Keep the same end date. Each EMI gets smaller.';

  @override
  String msLoansReduceTenureResult(String emi, String month, String n) {
    return 'EMI stays $emi · ends $month, $n months sooner';
  }

  @override
  String msLoansReduceEmiResult(String month, String emi) {
    return 'Ends $month as now · EMI becomes $emi';
  }

  @override
  String get communityTelegramTitle => 'Join the Kuber community';

  @override
  String get communityTelegramSubtitle =>
      'Official Telegram channel for news, tips and help';

  @override
  String get ueTitle => 'Upcoming events';

  @override
  String get ueViewList => 'List';

  @override
  String get ueViewCalendar => 'Calendar';

  @override
  String get ueFilter => 'Filter';

  @override
  String get ueFilterHint => 'Applies to List and Calendar.';

  @override
  String get ueFilterShow => 'Show';

  @override
  String get ueFilterType => 'Type';

  @override
  String get ueFilterReset => 'Reset';

  @override
  String ueA11yFilter(int count) {
    return 'Filter, $count applied';
  }

  @override
  String get ueRange7 => 'Next 7 days';

  @override
  String get ueRange30 => 'Next 30 days';

  @override
  String get ueRange90 => 'Next 90 days';

  @override
  String get ueTypeAll => 'All';

  @override
  String get ueTypeReminders => 'Reminders';

  @override
  String get ueTypeEmis => 'EMIs';

  @override
  String get ueTypeSips => 'SIPs';

  @override
  String get ueTypeRecurring => 'Recurring';

  @override
  String get ueTypeLedger => 'Ledger';

  @override
  String get uePillReminder => 'Reminder';

  @override
  String get uePillEmi => 'EMI';

  @override
  String get uePillSip => 'SIP';

  @override
  String get uePillFd => 'FD';

  @override
  String get uePillRecurring => 'Recurring';

  @override
  String get uePillLedger => 'Ledger';

  @override
  String get uePillCard => 'Credit card';

  @override
  String ueEmptyList(int days) {
    return 'No upcoming events in the next $days days';
  }

  @override
  String get ueEmptyListHint =>
      'Reminders, EMIs, SIPs, recurring and ledger dates show up here.';

  @override
  String ueOutAmount(String amount) {
    return '$amount out';
  }

  @override
  String ueInAmount(String amount) {
    return '$amount in';
  }

  @override
  String ueCardBills(String amount) {
    return 'Card bills $amount';
  }

  @override
  String ueDayToday(String date) {
    return 'Today, $date';
  }

  @override
  String get ueCardNote =>
      'Card bills are not in the total. That spending was recorded when you used the card.';

  @override
  String get ueEmptyDay => 'Nothing scheduled for this day';

  @override
  String get ueEmptyMonth => 'Nothing scheduled this month';

  @override
  String get ueStatusUpcoming => 'Upcoming';

  @override
  String get ueStatusConfirm => 'Needs confirmation';

  @override
  String get ueStatusDone => 'Done';

  @override
  String get ueStatusSkipped => 'Skipped';

  @override
  String get ueStatusOverdue => 'Overdue';

  @override
  String get ueLegendTitle => 'About the calendar';

  @override
  String get ueLegendIntro =>
      'Each dot is one event. Up to 3 dots show, then a count.';

  @override
  String get ueLegendReminders => 'Reminders';

  @override
  String get ueLegendEmis => 'EMIs';

  @override
  String get ueLegendSips => 'SIPs and FDs';

  @override
  String get ueLegendRecurring => 'Recurring';

  @override
  String get ueLegendLedger => 'Lent and borrowed';

  @override
  String get ueLegendCards => 'Credit cards';

  @override
  String get ueLegendDays => 'Days';

  @override
  String get ueLegendToday => 'Today';

  @override
  String get ueLegendSelected => 'Selected';

  @override
  String get ueLegendOverdue => 'Overdue';

  @override
  String get ueLegendSkipped => 'Skipped';

  @override
  String get ueLegendOtherMonth => 'Other month';

  @override
  String get ueLegendTotals =>
      'Out and in add up the month, without skipped items and reminders that have no amount. Card bills are shown on their own, because that spending was recorded when you used the card.';

  @override
  String ueA11yToday(String date) {
    return 'Today, $date';
  }

  @override
  String get ueA11ySelected => 'selected';

  @override
  String ueA11yEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events',
      one: '1 event',
      zero: 'no events',
    );
    return '$_temp0';
  }

  @override
  String ueA11yDue(String amount) {
    return '$amount due';
  }

  @override
  String ueA11yCardBill(String amount) {
    return 'card bill $amount';
  }

  @override
  String ueA11yOverdue(int count) {
    return '$count overdue';
  }

  @override
  String ueA11yConfirm(int count) {
    return '$count needs confirmation';
  }

  @override
  String get ueA11yHidden => 'amounts hidden';

  @override
  String ueA11yOtherMonthNext(String date) {
    return '$date, next month';
  }

  @override
  String ueA11yOtherMonthPrev(String date) {
    return '$date, previous month';
  }

  @override
  String ueA11yPrevMonth(String month) {
    return 'Previous month, $month';
  }

  @override
  String ueA11yNextMonth(String month) {
    return 'Next month, $month';
  }

  @override
  String ueA11yWeekCollapsed(String date) {
    return 'Week of $date, collapsed. Double tap to show the month.';
  }

  @override
  String get ueA11yHandle => 'Show the whole month';

  @override
  String get themeExpressiveTitle => 'Expressive colours';

  @override
  String get themeExpressiveSubtitle =>
      'Tint backgrounds with your theme colour';

  @override
  String get themePureBlackTitle => 'Pure black';

  @override
  String get themePureBlackSubtitle =>
      'Black background in dark mode. Saves battery on OLED screens.';

  @override
  String get themePureBlackHelperSystem =>
      'Applies when your phone is in dark mode';

  @override
  String get themePureBlackDisabledA11y =>
      'Pure black. Off. Works in dark mode.';

  @override
  String get msLoansReopen => 'Re-open loan';

  @override
  String msLoansReopenTitle(String name) {
    return 'Re-open $name?';
  }

  @override
  String get msLoansReopenBody =>
      'Its EMIs start again from the next due date. Nothing is added for the time it was closed.';

  @override
  String get msLoansUpdateOutstanding => 'Update outstanding';

  @override
  String get msLoansOutstandingPrincipal => 'Outstanding principal';

  @override
  String get msLoansAsOn => 'As on';

  @override
  String get msLoansAdjReason => 'Reason';

  @override
  String get msLoansAdjMatchBank => 'Match bank statement';

  @override
  String get msLoansAdjMatchBankSub =>
      'Your bank shows a different amount owed.';

  @override
  String get msLoansAdjInterestAdded => 'Unpaid interest added to loan';

  @override
  String get msLoansAdjInterestAddedSub =>
      'Your bank added interest to what you owe, like during a moratorium.';

  @override
  String msLoansKuberOutstandingOn(String date) {
    return 'Kuber\'s outstanding on $date';
  }

  @override
  String get msLoansAdjDifference => 'Difference';

  @override
  String get msLoansKeepEmiChangeEnd => 'Keep EMI, change end date';

  @override
  String get msLoansKeepEndChangeEmi => 'Keep end date, change EMI';

  @override
  String msLoansKeepEmiResult(String emi, String month) {
    return 'EMI stays $emi · ends $month';
  }

  @override
  String msLoansKeepEndResult(String month, String emi) {
    return 'Ends $month · EMI becomes $emi';
  }

  @override
  String get msLoansRemainingInterest => 'Remaining interest';

  @override
  String get msLoansAdjErrNegative => 'Outstanding can\'t be less than 0.';

  @override
  String get msLoansAdjZeroTitle => 'Nothing left to pay?';

  @override
  String get msLoansAdjZeroBody =>
      'An outstanding of 0 means this loan is paid off. Mark it as closed?';

  @override
  String get msLoansAdjSaveOnly => 'Just save';

  @override
  String get msLoansAdjSaved => 'Outstanding updated';

  @override
  String msLoansEventAdjusted(String amount, String date) {
    return 'Outstanding updated $amount · $date';
  }

  @override
  String msLoansEventInterestAdded(String amount, String date) {
    return 'Interest added to loan $amount · $date';
  }

  @override
  String get msLoansEventAdjSubTenure => 'EMI unchanged, end date moves';

  @override
  String get msLoansEventAdjSubEmi => 'End date unchanged, EMI changes';

  @override
  String get msLoansEventDeleted => 'Deleted';

  @override
  String get msLoansInterestAdded => 'Interest added to loan';

  @override
  String msLoansRecalcTitle(int count) {
    return 'Recalculate the split of $count later EMIs you haven\'t edited?';
  }

  @override
  String msLoansRecalcBody(String before, String after) {
    return 'Interest in those EMIs is $before now and $after after recalculating. EMIs you edited stay as they are.';
  }

  @override
  String get msLoansRecalc => 'Recalculate';

  @override
  String get msLoansKeepAsIs => 'Keep as is';

  @override
  String msLoansRecalcDone(int count) {
    return 'Updated $count EMIs';
  }

  @override
  String get msLoansDeleteExtraTitle => 'Delete this extra payment?';

  @override
  String get msLoansDeleteExtraBody =>
      'Its transactions are deleted too, and the outstanding goes back up.';

  @override
  String get msLoansDeleteAdjTitle => 'Delete this update?';

  @override
  String get msLoansDeleteAdjBody =>
      'The outstanding goes back to Kuber\'s figure.';

  @override
  String get msTxnEdited => 'Edited';

  @override
  String get msTxnSplitHelper =>
      'Change these to match your bank. They always add up to the EMI.';

  @override
  String get msTxnSplitErr => 'Principal and interest can\'t be less than 0.';

  @override
  String get msInfoSplitEditedTitle => 'Edited split';

  @override
  String get msInfoSplitEditedLine =>
      'You changed this split to match your bank. Kuber uses your figures for the outstanding amount and projects future EMIs from there.';

  @override
  String get msInfoAdjustBankLine =>
      'Use this when your bank statement shows a different amount owed than Kuber. Kuber starts from your figure on that date.';

  @override
  String get msInfoAdjustInterestLine =>
      'Some banks add interest you didn\'t pay, like during a moratorium or before EMIs start, to what you owe. It counts toward the loan\'s total interest. It is not spending, because no money left your account.';

  @override
  String get msInfoRemainingLine =>
      'Remaining interest depends on what you owe, the rate and your EMI, so Kuber calculates it. Update the outstanding amount or the rate instead.';

  @override
  String get msLoansPastEmis => 'Add past EMIs as transactions';

  @override
  String get msInfoPastEmisLine =>
      'Kuber adds one EMI transaction for every month the loan has already run, with its principal and interest. Your account balance goes down by the total, like any payment. Leave it off to start from today without past transactions.';

  @override
  String get msLoansPastEmisHelp =>
      'Creates every EMI from the first EMI date until today as a transaction.';

  @override
  String msLoansPastEmisPreview(
    int count,
    String from,
    String to,
    String account,
    String amount,
  ) {
    return 'Adds $count EMIs from $from to $to and lowers $account\'s balance by $amount.';
  }

  @override
  String msLoansPastEmisPreviewNoAccount(
    int count,
    String from,
    String to,
    String amount,
  ) {
    return 'Adds $count EMIs from $from to $to, $amount in all.';
  }

  @override
  String msLoansPastEmisRemoveTitle(int count) {
    return 'Remove the $count past EMIs added by this switch?';
  }

  @override
  String get msLoansPastEmisRemoveBody =>
      'EMIs you edited are kept. The account balance goes back up by the ones removed.';

  @override
  String get msLoansKeep => 'Keep';

  @override
  String get msLoansRemove => 'Remove';

  @override
  String msLoansPastEmisRemoved(int removed, int kept) {
    return 'Removed $removed past EMIs. Kept $kept you edited.';
  }

  @override
  String get bgStepPastEmis => 'Adding past EMIs…';

  @override
  String bgJobPercent(String text, int percent) {
    return '$text $percent%';
  }

  @override
  String bgJobsRunning(String text, int count) {
    return '$text ($count tasks)';
  }

  @override
  String get bgJobFailed => 'Something went wrong';

  @override
  String get bgDetails => 'Details';

  @override
  String get bgDetailsTitle => 'What went wrong';

  @override
  String get bgAddedOne => 'Added 1 transaction';

  @override
  String bgAdded(int count) {
    return 'Added $count transactions';
  }

  @override
  String get bgBackupSaved => 'Backup saved';

  @override
  String get accountTypeOverdraft => 'Overdraft';

  @override
  String get accountOverdraftHint => 'e.g. HDFC overdraft';

  @override
  String get accountOverdraftSub => 'For money you owe, like an overdraft.';

  @override
  String get accountOverdraftInfoLine =>
      'Use this for money you owe, like an overdraft or a credit line. EMIs you track in Loans still come from the account you pick there.';

  @override
  String get accountAmountOwed => 'Amount owed';

  @override
  String get accountLimitOptional => 'Limit (optional)';

  @override
  String accountAvailable(String amount) {
    return 'Available $amount';
  }

  @override
  String get accountOwedLabel => 'Owed';

  @override
  String accountOverLimit(String amount) {
    return 'This goes over the limit by $amount.';
  }

  @override
  String get smsTodayLabel => 'Untracked today';

  @override
  String get smsTodaySpentLabel => 'Spent';

  @override
  String get smsTodayReceivedLabel => 'Received';

  @override
  String smsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS not added yet',
      one: '1 SMS not added yet',
    );
    return '$_temp0';
  }

  @override
  String smsTodayCountNoAmount(int count, int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS not added yet',
      one: '1 SMS not added yet',
    );
    String _temp1 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: '$missing without an amount',
      one: '1 without an amount',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get smsTodayCaughtTitle => 'All caught up for today';

  @override
  String get smsTodayCaughtBody => 'Every SMS today is sorted.';

  @override
  String get smsTodayNoneBody => 'No bank SMS today so far.';

  @override
  String get smsRowNoAmount => 'No amount';

  @override
  String smsWidgetSpentUntracked(String amount) {
    return '$amount spends untracked from SMS';
  }

  @override
  String smsWidgetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS from today not yet added',
      one: '1 SMS from today not yet added',
    );
    return '$_temp0';
  }

  @override
  String get smsMenuDismissAll => 'Dismiss all';

  @override
  String smsDismissAllTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dismiss all $count messages?',
      one: 'Dismiss 1 message?',
    );
    return '$_temp0';
  }

  @override
  String get smsDismissAllBody =>
      'They will move to the Dismissed tab. You can still add them from there.';

  @override
  String get smsDismissAllBodyOne =>
      'It will move to the Dismissed tab. You can still add it from there.';

  @override
  String smsDismissAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dismiss all',
      one: 'Dismiss',
    );
    return '$_temp0';
  }

  @override
  String smsDismissedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages dismissed',
      one: '1 message dismissed',
    );
    return '$_temp0';
  }
}
