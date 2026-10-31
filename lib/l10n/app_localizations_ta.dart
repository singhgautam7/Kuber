// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get continueLabel => 'தொடரவும்';

  @override
  String get cancelLabel => 'ரத்துசெய்';

  @override
  String get saveLabel => 'சேமி';

  @override
  String get editLabel => 'திருத்து';

  @override
  String get deleteLabel => 'நீக்கு';

  @override
  String get gotIt => 'புரிந்தது';

  @override
  String get skip => 'தவிர்';

  @override
  String get search => 'தேடு';

  @override
  String get getStarted => 'தொடங்கு';

  @override
  String get starting => 'தொடங்குகிறது...';

  @override
  String get startJourney => 'என் பயணத்தைத் தொடங்கு';

  @override
  String get yourMoneyYourRules => 'உங்கள் பணம்.\nஉங்கள் விதிகள்.';

  @override
  String get onboardingPage1Description =>
      'உங்கள் சாதனத்திலேயே இருக்கும் ஒரு செலவு மேலாளர். கிளவுட் இல்லை, பதிவுபெறுதல் இல்லை, எந்த சமரசமும் இல்லை.';

  @override
  String offlineFirstBadge(String version) {
    return 'ஆஃப்லைன்-முதன்மையானது · $version';
  }

  @override
  String get recurringModule => 'மீண்டும் நிகழும் செலவுகள்';

  @override
  String get makeItYours => 'உங்களுடையதாக்கிக் கொள்ளுங்கள்.';

  @override
  String get threeQuickChoices =>
      'மூன்று விரைவான தேர்வுகள் மூலம் நீங்கள் உள்ளே நுழையலாம்.';

  @override
  String get yourName => 'உங்கள் பெயர்';

  @override
  String get currency => 'நாணயம்';

  @override
  String get theme => 'தீம்';

  @override
  String get language => 'மொழி';

  @override
  String get namePlaceholder => 'உங்கள் பெயர்';

  @override
  String get nameRequired => 'தயவுசெய்து உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get nameTooLong =>
      'பெயர் 15 எழுத்துகள் அல்லது அதற்கும் குறைவாக இருக்க வேண்டும்';

  @override
  String get themeLight => 'லைட்';

  @override
  String get themeDark => 'டார்க்';

  @override
  String get themeSystem => 'சிஸ்டம்';

  @override
  String get settingsTitle => 'அமைப்புகள்';

  @override
  String get settingsSubtitle =>
      'குபேர் உங்களுக்கு எப்படித் தெரிய வேண்டும், உணரப்பட வேண்டும் மற்றும் செயல்பட வேண்டும் என்பதைத் தனிப்பயனாக்கவும்.';

  @override
  String get profileSection => 'சுயவிவரம்';

  @override
  String get profileDescription => 'குபேர் உங்களை எப்படி அடையாளம் காண்கிறது.';

  @override
  String get yourNameLabel => 'உங்கள் பெயர்';

  @override
  String get userNameUpdated => 'பெயர் புதுப்பிக்கப்பட்டது';

  @override
  String get appearanceSection => 'தோற்றம்';

  @override
  String get appearanceDescription => 'குபேர் உங்களுக்கு எப்படித் தோன்றுகிறது.';

  @override
  String get themeLabel => 'தீம்';

  @override
  String get themeSubtitle => 'லைட், டார்க் அல்லது உங்கள் தொலைபேசிக்கு ஏற்ப';

  @override
  String get bottomNavLabel => 'கீழ் வழிசெலுத்தல்';

  @override
  String get bottomNavSubtitle =>
      'நிலையான பட்டி அல்லது மிதக்கும் மாத்திரை வடிவம்';

  @override
  String get moreTabLayoutLabel => 'மேலும் தாவல் தளவமைப்பு';

  @override
  String get moreTabLayoutSubtitle =>
      'எளிய பட்டியல் அல்லது நவீன ஹீரோ தளவமைப்பு';

  @override
  String get widgetsSection => 'விட்ஜெட்டுகள்';

  @override
  String get widgetsDescription =>
      'முகப்பு மற்றும் பகுப்பாய்வு பக்கங்களில் எவை தோன்ற வேண்டும் என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get homeWidgetsLabel => 'முகப்பு விட்ஜெட்டுகள்';

  @override
  String homeWidgetsSubtitle(String count) {
    return '$count இயக்கப்பட்டது · வரிசைப்படுத்த இழுக்கவும்';
  }

  @override
  String get analyticsWidgetsLabel => 'பகுப்பாய்வு விட்ஜெட்டுகள்';

  @override
  String analyticsWidgetsSubtitle(String count) {
    return '$count இயக்கப்பட்டது · வரிசைப்படுத்த இழுக்கவும்';
  }

  @override
  String get moneyDisplaySection => 'பணக் காட்சி';

  @override
  String get moneyDisplayDescription =>
      'நாணயம் மற்றும் தொகைகள் செயலி முழுவதும் எப்படிக் காட்டப்படுகின்றன.';

  @override
  String get currencyLabel => 'நாணயம்';

  @override
  String get currencySubtitle =>
      'தொகைகளில் காட்டப்படும் குறியீடு மற்றும் குறியீட்டு எண்';

  @override
  String get numberFormatLabel => 'எண் வடிவம்';

  @override
  String get numberFormatSubtitle =>
      'இந்திய முறை (1,23,000) அல்லது சர்வதேச முறை (123,000)';

  @override
  String get transactionsSection => 'பரிவர்த்தனைகள்';

  @override
  String get transactionsDescription =>
      'புதிய உள்ளீடுகளைச் சேர்க்கும்போது உங்கள் இயல்புநிலை அமைப்புகள்.';

  @override
  String get defaultAccountLabel => 'இயல்புநிலை கணக்கு';

  @override
  String get defaultAccountSubtitle =>
      'நீங்கள் விரைவாகச் சேர்க்கும்போது முன்கூட்டியே தேர்ந்தெடுக்கப்படுவது';

  @override
  String get horizontalSwipeLabel => 'கிடைமட்ட ஸ்வைப்';

  @override
  String get horizontalSwipeSubtitle =>
      'இடது அல்லது வலதுபுறமாக ஸ்வைப் செய்வது என்ன செய்கிறது';

  @override
  String get privacySecuritySection => 'தனியுரிமை & பாதுகாப்பு';

  @override
  String get privacySecurityDescription =>
      'உங்கள் எண்களைத் தனியுரிமையாக வைத்திருக்கவும் மற்றும் உங்கள் செயலியைப் பூட்டி வைக்கவும்.';

  @override
  String get privacyModeLabel => 'தனியுரிமை பயன்முறை';

  @override
  String get privacyModeSubtitle =>
      'அனைத்து இருப்புகளையும் தொகைகளையும் மறைக்கவும்';

  @override
  String get biometricLockLabel => 'பயோமெட்ரிக் பூட்டு';

  @override
  String get biometricLockSubtitle => 'FaceID அல்லது கைரேகை மூலம் திறக்கவும்';

  @override
  String get aboutSection => 'பற்றி';

  @override
  String get aboutDescription =>
      'குபேர் மற்றும் அதற்குப் பின்னால் உள்ள நபரைப் பற்றித் தெரிந்துகொள்ளுங்கள்.';

  @override
  String get aboutKuberLabel => 'குபேர் பற்றி';

  @override
  String get aboutKuberSubtitle =>
      'தொலைநோக்கு பார்வை, தோற்றம் மற்றும் உருவாக்குநரிடமிருந்து ஒரு கடிதம்';

  @override
  String get clearDefault => 'இயல்புநிலையை நீக்கு';

  @override
  String get defaultAccountCleared => 'இயல்புநிலை கணக்கு நீக்கப்பட்டது';

  @override
  String get noAccountsFound => 'கணக்குகள் எதுவும் இல்லை.';

  @override
  String get biometricNotAvailable =>
      'சாதன அங்கீகாரம் கிடைக்கவில்லை அல்லது அமைக்கப்படவில்லை';

  @override
  String get biometricEnabledMsg => 'பயோமெட்ரிக் பூட்டு இயக்கப்பட்டது';

  @override
  String get biometricDisabledMsg => 'பயோமெட்ரிக் பூட்டு முடக்கப்பட்டது';

  @override
  String get updateNameTitle => 'பெயரைப் புதுப்பி';

  @override
  String get enterNameHint => 'பெயரை உள்ளிடவும்';

  @override
  String get saveBtn => 'சேமி';

  @override
  String get themeLightChoice => 'லைட்';

  @override
  String get themeDarkChoice => 'டார்க்';

  @override
  String get themeSystemChoice => 'சிஸ்டம்';

  @override
  String get themeSubtitleLight => 'பிரகாசமான பின்னணி, இருண்ட உரை';

  @override
  String get themeSubtitleDark => 'கருப்பு பின்னணி, பிரகாசமான உரை';

  @override
  String get themeSubtitleSystem => 'தொலைபேசி அமைப்பைப் பின்பற்றவும்';

  @override
  String get navClassicChoice => 'கிளாசிக்';

  @override
  String get navModernChoice => 'நவீன';

  @override
  String get navSubtitleClassic => 'நிலையான பட்டி';

  @override
  String get navSubtitleModern => 'மிதக்கும் மாத்திரை வடிவம்';

  @override
  String get navFuturisticChoice => 'ஃப்யூச்சரிஸ்டிக்';

  @override
  String get navSubtitleFuturistic => 'செயலில் உள்ளதில் லேபிள்';

  @override
  String get numFormatIndian => 'இந்திய முறை';

  @override
  String get numFormatInternational => 'சர்வதேச முறை';

  @override
  String get swipeChangeTabs => 'தாவல்களை மாற்றவும்';

  @override
  String get swipeRowActions => 'வரிசைச் செயல்கள்';

  @override
  String get swipeSubtitleChangeTabs =>
      'திரையில் ஸ்வைப் செய்வதன் மூலம் முக்கிய செயலி பிரிவுகளுக்கு இடையே விரைவாக மாறலாம்';

  @override
  String get swipeSubtitleRowActions =>
      'தனிப்பட்ட வரலாற்று உருப்படிகளை ஸ்வைப் செய்வதன் மூலம் திருத்துதல் அல்லது நீக்குதல் போன்ற விரைவான செயல்களைச் செய்யலாம்';

  @override
  String spentTodayInsight(String amount, String diff, String avg) {
    return 'இன்று நீங்கள் $amount செலவழித்துள்ளீர்கள், இது உங்கள் 30-நாள் தினசரி சராசரியான $avg-ஐ விட $diff அதிகமாகும்';
  }

  @override
  String weekdayPatternInsight(String highest, String dayName, String median) {
    return 'நீங்கள் பொதுவாக $dayName அன்று $highest செலவிடுகிறீர்கள், மற்ற நாட்களில் $median செலவிடுகிறீர்கள்';
  }

  @override
  String topCategoryInsight(String pct, String catName, String amount) {
    return 'செலவில் $pct% $catName ($amount) பிரிவுக்குச் செல்கிறது';
  }

  @override
  String categoryTrendInsight(String catName, String change) {
    return '$catName செலவு கடந்த மாதத்துடன் ஒப்பிடும்போது $change ஆக உள்ளது';
  }

  @override
  String monthComparisonInsight(String change) {
    return 'செலவு கடந்த மாதத்தின் இதே காலகட்டத்துடன் ஒப்பிடும்போது $change ஆக உள்ளது';
  }

  @override
  String weekendVsWeekdayInsight(String weekend, String weekday) {
    return 'வார இறுதிப் பரிவர்த்தனைகளின் சராசரி $weekend, வார நாட்களில் $weekday ஆக உள்ளது';
  }

  @override
  String biggestExpenseInsight(String name, String amount, String ratio) {
    return '$name ($amount) என்பது உங்கள் வழக்கமான செலவை விட $ratio மடங்கு அதிகமாக இருந்தது';
  }

  @override
  String get savingsTrendPositive =>
      'இந்த மாதம் நீங்கள் பணத்தைச் சேமிக்கிறீர்கள். தொடருங்கள்!';

  @override
  String savingsTrendInsight(String change) {
    return 'சேமிப்பு கடந்த மாதத்துடன் ஒப்பிடும்போது $change ஆக உள்ளது';
  }

  @override
  String savingsTrendDipInsight(String change) {
    return 'சேமிப்பு கடந்த மாதத்துடன் ஒப்பிடும்போது $change குறைந்துள்ளது';
  }

  @override
  String recurringBurdenInsight(String pct) {
    return 'செலவில் $pct மீண்டும் நிகழும் பரிவர்த்தனைகளில் இருந்து வருகிறது';
  }

  @override
  String streakInsight(String streak) {
    return 'இன்றைக்கு முன்பு $streak-நாட்கள் செலவில்லாத தொடர்!';
  }

  @override
  String spendingFasterInsight(String weekStr, String diffStr, String baseStr) {
    return 'இந்த வாரம் நீங்கள் ஒரு நாளைக்கு $weekStr செலவிடுகிறீர்கள், இது உங்களின் வழக்கமான $baseStr/நாள் சராசரியை விட $diffStr வேகமானது';
  }

  @override
  String categoryConcentrationInsight(String pctStr, String amtStr) {
    return 'உங்கள் செலவில் $pctStr ($amtStr) வெறும் 3 வகைகளுக்கு மட்டுமே செல்கிறது';
  }

  @override
  String loanEmiTotalInsight(String amount) {
    return 'இந்த மாதம் கடன் EMI-கள் மொத்தம் $amount ஆக உள்ளது';
  }

  @override
  String loanPayoffCountdownInsight(
    String name,
    String months,
    String pluralSuffix,
  ) {
    return '$name செலுத்தி முடிக்க இன்னும் சுமார் $months மாதம் $pluralSuffix உள்ளது';
  }

  @override
  String loanInterestPaidInsight(String amount) {
    return 'இதுவரை செலுத்தப்பட்ட மொத்த கடன் வட்டி $amount';
  }

  @override
  String ledgerOutstandingInsight(String receive, String owe) {
    return 'திறந்திருக்கும் கடன் கொடுத்தல் மற்றும் வாங்குதல் தொகைகள்: உங்களுக்கு வர வேண்டியது $receive மற்றும் நீங்கள் செலுத்த வேண்டியது $owe';
  }

  @override
  String ledgerOldestOpenInsight(String personName, String ageDays) {
    return '$personName $ageDays நாட்களாகப் பழமையான திறந்திருக்கும் பதிவைக் கொண்டுள்ளார்';
  }

  @override
  String investmentPortfolioChangeInsight(String amount) {
    return 'முதலீட்டு மதிப்புடன் ஒப்பிடும்போது உங்கள் போர்ட்ஃபோலியோ $amount ஆக உள்ளது';
  }

  @override
  String investmentTopPerformerInsight(String name, String pct) {
    return '$pct லாபத்துடன் $name உங்கள் சிறந்த முதலீடாக உள்ளது';
  }

  @override
  String investmentPeriodInvestedInsight(String amount) {
    return 'இந்த மாதம் நீங்கள் $amount முதலீடு செய்துள்ளீர்கள்';
  }

  @override
  String get fallbackTipInsight =>
      'ஸ்மார்ட் நுண்ணறிவுகளைப் பெற பரிவர்த்தனைகளைச் சேர்க்கத் தொடங்குங்கள்';

  @override
  String fallbackTotalInsight(String amount) {
    return 'கடந்த 30 நாட்களில் நீங்கள் $amount செலவழித்துள்ளீர்கள்';
  }

  @override
  String get spentLastWeek => 'கடந்த வாரம் செலவழிக்கப்பட்டது';

  @override
  String spentLastMonth(String month) {
    return '$month இல் செலவழிக்கப்பட்டது';
  }

  @override
  String spentLastYear(String year) {
    return '$year இல் செலவழிக்கப்பட்டது';
  }

  @override
  String averageDay(String amount) {
    return 'சராசரியாக ஒரு நாளைக்கு சுமார் $amount';
  }

  @override
  String biggestDay(String day, String amount) {
    return '$day உங்கள் அதிகபட்ச செலவு நாளாக $amount-டன் இருந்தது';
  }

  @override
  String savedEarned(String pct) {
    return 'நீங்கள் சம்பாதித்ததில் $pct%-ஐச் சேமித்துள்ளீர்கள்';
  }

  @override
  String biggestSingleSpend(String name, String category) {
    return 'மிகப் பெரிய தனி செலவு $category பிரிவில் $name ஆகும்';
  }

  @override
  String get spentLess => 'நீங்கள் முன்பை விட குறைவாகச் செலவழித்தீர்கள்';

  @override
  String get spentMore => 'நீங்கள் முன்பை விட அதிகமாகச் செலவழித்தீர்கள்';

  @override
  String get comparedTitle => 'ஒப்பீடு';

  @override
  String get comparedLess => 'நீங்கள் முன்பை விட குறைவாகச் செலவழித்தீர்கள்';

  @override
  String get comparedMore => 'நீங்கள் முன்பை விட அதிகமாகச் செலவழித்தீர்கள்';

  @override
  String deltaLess(String amount, String label) {
    return '$label-ஐ விட $amount குறைவு';
  }

  @override
  String deltaMore(String amount, String label) {
    return '$label-ஐ விட $amount அதிகம்';
  }

  @override
  String get monthlyEmi => 'மாதாந்திர EMI';

  @override
  String get principal => 'அசல்';

  @override
  String get lender => 'கடன் வழங்குபவர்';

  @override
  String ledgerOwesYou(String person, String amount) {
    return '$person உங்களுக்கு $amount தர வேண்டும்';
  }

  @override
  String ledgerYouOwe(String person, String amount) {
    return 'நீங்கள் $person-க்கு $amount தர வேண்டும்';
  }

  @override
  String get ledgerEntryOpen => 'இந்தப் பதிவு இன்னும் திறந்தே உள்ளது.';

  @override
  String get portfolioCheck => 'போர்ட்ஃபோலியோ சரிபார்ப்பு';

  @override
  String get investedLabel => 'முதலீடு செய்யப்பட்டது';

  @override
  String get currentValueLabel => 'தற்போதைய மதிப்பு';

  @override
  String get welcomeTitle => 'குபேர்-க்கு வரவேற்கிறோம்';

  @override
  String get welcomeSubtitle =>
      'நிறுவியதற்கு நன்றி. உங்கள் பணம், அழகாகக் கண்காணிக்கப்படும்.';

  @override
  String get basicsTitle => 'ஒவ்வொரு ரூபாயையும் கண்காணியுங்கள்';

  @override
  String get basicsSubtitle =>
      'செலவுகள், வருமானம், பரிமாற்றங்கள் மற்றும் பட்ஜெட்கள் அனைத்தும் ஒரே இடத்தில்.';

  @override
  String get beyondBasicsTitle => 'இதில் இன்னும் பல உள்ளன';

  @override
  String get beyondBasicsSubtitle =>
      'கடன் கொடுத்தல்-வாங்குதல், EMI-கள், முதலீடுகள் மற்றும் பயனுள்ள கால்குலேட்டர்கள்.';

  @override
  String get spaceIsYoursTitle => 'உங்கள் பணக் கதைகள்';

  @override
  String get spaceIsYoursSubtitle =>
      'உங்கள் செலவுகள் பற்றிய சுருக்கங்கள் மற்றும் சிறப்பம்சங்கள் இங்கே தோன்றும்.';

  @override
  String get spentYesterday => 'நேற்று செலவழிக்கப்பட்டது';

  @override
  String topSpend(String name, String category) {
    return 'அதிகபட்ச செலவு: $category பிரிவில் $name';
  }

  @override
  String get topCategories => 'முக்கிய வகைகள்';

  @override
  String get noSpendDay => 'செலவில்லாத நாள். நன்று.';

  @override
  String noSpendStreak(String streak) {
    return 'அது தொடர்ந்து $streak நாட்களாக செலவில்லாத தொடர்';
  }

  @override
  String noSpendStreakEnded(String streak) {
    return 'உங்கள் $streak நாள் செலவில்லாத தொடர் முடிவடைந்தது';
  }

  @override
  String get dailyRecapHeader => 'தினசரி';

  @override
  String get weeklyRecapHeader => 'வாராந்திர சுருக்கம்';

  @override
  String get monthlyRecapHeader => 'மாதாந்திர சுருக்கம்';

  @override
  String get yearlyRecapHeader => 'ஆண்டுக்கான சுருக்கம்';

  @override
  String get highlightHeader => 'சிறப்பம்சம்';

  @override
  String get loansHeader => 'கடன்கள்';

  @override
  String get ledgerHeader => 'கடன் கொடுப்பனவு / கடன் வாங்குதல்';

  @override
  String get investmentsHeader => 'முதலீடுகள்';

  @override
  String averageMonth(String amount) {
    return 'சராசரியாக ஒரு மாதத்திற்கு சுமார் $amount';
  }

  @override
  String biggestMonth(String month, String amount) {
    return '$month உங்கள் அதிகபட்ச செலவு மாதமாக $amount-டன் இருந்தது';
  }

  @override
  String get lessLabel => 'குறைவு';

  @override
  String get moreLabel => 'அதிகம்';

  @override
  String get theWeekBefore => 'முந்தைய வாரம்';

  @override
  String aboveAverage(String amount) {
    return 'உங்கள் 30-நாள் சராசரியை விட $amount அதிகம்';
  }

  @override
  String belowAverage(String amount) {
    return 'உங்கள் 30-நாள் சராசரியை விட $amount குறைவு';
  }

  @override
  String get toLabel => 'இதற்கு';

  @override
  String throughPeriod(String date) {
    return '$date வரை';
  }

  @override
  String get thisWeek => 'இந்த வாரம்';

  @override
  String get previousWeek => 'முந்தைய வாரம்';

  @override
  String get thisMonth => 'இந்த மாதம்';

  @override
  String get previousMonth => 'முந்தைய மாதம்';

  @override
  String get thisYear => 'இந்த ஆண்டு';

  @override
  String get previousYear => 'முந்தைய ஆண்டு';

  @override
  String get uncategorized => 'வகைப்படுத்தப்படாதது';

  @override
  String get chooseAppLanguage => 'செயலி மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get searchLanguage => 'மொழியைத் தேடவும்';

  @override
  String get noLanguagesFound => 'மொழிகள் எதுவும் காணப்படவில்லை';

  @override
  String get appearanceCategory => 'தோற்றம்';

  @override
  String get moneyDisplayCategory => 'பணக் காட்சி';

  @override
  String get transactionsCategory => 'பரிவர்த்தனைகள்';

  @override
  String get notSet => 'அமைக்கப்படவில்லை';

  @override
  String get setYourName => 'உங்கள் பெயரை அமைக்கவும்';

  @override
  String get simpleLabel => 'எளிய';

  @override
  String get creditCardLabel => 'கிரெடிட் கார்டு';

  @override
  String get bankCashLabel => 'வங்கி / ரொக்கம்';

  @override
  String setAsDefault(String name) {
    return '$name இயல்புநிலையாக அமைக்கப்பட்டது';
  }

  @override
  String get nameSheetHint => 'உதா. Gautam';

  @override
  String get doneLabel => 'முடிந்தது';

  @override
  String get moreTabSimpleSubtitle =>
      'அட்டைகளின் சீரான பட்டியல். தெரிந்த மற்றும் கணிக்கக்கூடியது.';

  @override
  String get moreTabModernSubtitle =>
      'ஹீரோ உருப்படிகள், டைல் கட்டம் மற்றும் சிறிய பட்டியல்கள். பிரிவுகளுக்கு ஏற்ப வேறுபட்டது.';

  @override
  String get selectCurrency => 'நாணயத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get searchCurrencyHint =>
      'பெயர், குறியீடு அல்லது சின்னம் மூலம் தேடவும்...';

  @override
  String get noCurrenciesFound => 'நாணயங்கள் எதுவும் காணப்படவில்லை';

  @override
  String get welcomeHeader => 'வரவேற்பு';

  @override
  String get basicsHeader => 'அடிப்படைகள்';

  @override
  String get beyondBasicsHeader => 'அடிப்படைகளுக்கு அப்பால்';

  @override
  String get spaceIsYoursHeader => 'இந்த இடம் உங்களுடையது';

  @override
  String get homeSubtitle1 => 'உங்கள் பணத்தை புத்திசாலித்தனமாக நிர்வகிப்போம்';

  @override
  String get homeSubtitle2 =>
      'ஒவ்வொரு நாளும், ஒவ்வொரு ரூபாயையும் கண்காணியுங்கள்';

  @override
  String get homeSubtitle3 =>
      'உங்கள் நிதி நிலையை எப்போதும் கவனிப்பில் வைத்திருங்கள்';

  @override
  String get homeSubtitle4 => 'உங்கள் பணப்பை பின்னர் உங்களுக்கு நன்றி சொல்லும்';

  @override
  String get homeSubtitle5 => 'சிறிய சேமிப்பு, பெரிய பலன்கள்';

  @override
  String get homeSubtitle6 => 'ஒவ்வொரு பரிவர்த்தனையும் முக்கியமானது';

  @override
  String get homeSubtitle7 => 'புத்திசாலித்தனமான பணப் பழக்கங்களை உருவாக்குதல்';

  @override
  String get greetingMorning => 'காலை வணக்கம்';

  @override
  String get greetingAfternoon => 'மதிய வணக்கம்';

  @override
  String get greetingEvening => 'மாலை வணக்கம்';

  @override
  String get errorLabel => 'பிழை';

  @override
  String get last7Days => 'கடந்த 7 நாட்கள்';

  @override
  String get netLabel => 'நிகர';

  @override
  String get spendingAnalysisEmpty =>
      'கடந்த 7 நாட்களில் எந்தவொரு வருமானம் அல்லது செலவு பரிவர்த்தனையும் இல்லை. உங்கள் செலவு பகுப்பாய்வை இங்கே காண ஒரு பரிவர்த்தனையைச் சேர்க்கவும்.\n\nகுறிப்பு: கணக்கு பரிமாற்றங்கள் இதில் சேர்க்கப்படவில்லை.';

  @override
  String get notificationsTooltip => 'அறிவிப்புகள்';

  @override
  String get askKuber => 'குபேர்-இடம் கேட்கவும்';

  @override
  String get privacyModeOn => 'தனியுரிமை பயன்முறை: ஆன்';

  @override
  String get privacyModeOff => 'தனியுரிமை பயன்முறை: ஆஃப்';

  @override
  String get accountsLabel => 'கணக்குகள்';

  @override
  String get viewAll => 'அனைத்தையும் காட்டு';

  @override
  String get outstandingLabel => 'நிலுவையில் உள்ளவை';

  @override
  String get availableLabel => 'கிடைக்கக்கூடியது';

  @override
  String get bankLabel => 'வங்கி';

  @override
  String get walletLabel => 'பணப்பை';

  @override
  String get cashLabel => 'ரொக்கம்';

  @override
  String get usedLabel => 'பயன்படுத்தப்பட்டது';

  @override
  String get limitLabel => 'வரம்பு';

  @override
  String get recurringHeader => 'மீண்டும் மீண்டும் நிகழ்பவை';

  @override
  String get statusProcessed => 'செயலாக்கப்பட்டது';

  @override
  String get statusPending => 'நிலுவையில் உள்ளது';

  @override
  String get statusScheduled => 'திட்டமிடப்பட்டது';

  @override
  String get quickAddInvalidAmount =>
      'செல்லுபடியாகும் தொகையை உள்ளிடவும் (உதா. 200 on coffee)';

  @override
  String quickAddNoAccountNamed(String name) {
    return '\"$name\" என்ற பெயரில் கணக்கு எதுவும் காணப்படவில்லை';
  }

  @override
  String get quickAddCouldNotResolveCategory =>
      'வகையைத் தீர்மானிக்க முடியவில்லை';

  @override
  String quickAddAdded(String amount, String category) {
    return '$amount $category பிரிவில் சேர்க்கப்பட்டது';
  }

  @override
  String get noAccountFoundTitle => 'கணக்கு எதுவும் காணப்படவில்லை';

  @override
  String noAccountMatchedBody(String hint) {
    return '\"$hint\" உடன் எந்தக் கணக்கும் பொருந்தவில்லை மற்றும் இயல்புநிலை கணக்கு எதுவும் அமைக்கப்படவில்லை. Quick Add-ஐப் பயன்படுத்த அமைப்புகளில் இயல்புநிலை கணக்கை அமைக்கவும்.';
  }

  @override
  String get noDefaultAccountBody =>
      'இயல்புநிலை கணக்கு எதுவும் அமைக்கப்படவில்லை. Quick Add-ஐப் பயன்படுத்த அமைப்புகளில் ஒன்றை அமைக்கவும்.';

  @override
  String get openSettings => 'அமைப்புகளைத் திறக்கவும்';

  @override
  String get quickAddTitle => 'விரைவாகச் சேர் (பீட்டா)';

  @override
  String get quickAddInfoTitle => 'விரைவாகச் சேர்';

  @override
  String get quickAddInfoDesc =>
      'இயல்பான மொழியைப் பயன்படுத்தி ஒரு செலவை உடனடியாகப் பதிவுசெய்யவும். படிவங்களோ, தட்டுதல்களோ இல்லை. நீங்கள் செலவழித்ததைத் தட்டச்சு செய்தால் போதும், மீதியை குபேர் கவனித்துக் கொள்ளும்.';

  @override
  String get quickAddBasicAmount => 'அடிப்படைத் தொகை';

  @override
  String get quickAddBasicAmountDesc =>
      '\"250\" அல்லது \"₹250\" என்பது ₹250-ஐ General பிரிவில் சேர்க்கிறது.';

  @override
  String get quickAddWithCategory => 'வகையுடன்';

  @override
  String get quickAddWithCategoryDesc =>
      '\"250 on food\", \"150 in gaming\", \"300 for rent\" என்பது தற்போதைய வகையுடன் இணைக்கிறது அல்லது புதிய ஒன்றை உருவாக்குகிறது.';

  @override
  String get quickAddWithAccount => 'கணக்குடன்';

  @override
  String get quickAddWithAccountDesc =>
      '\"150 for uber from hdfc\" என்பது உங்கள் HDFC கணக்கின் பெயருடன் ஒப்பிடுகிறது.';

  @override
  String get quickAddActionWords => 'செயல் சொற்கள்';

  @override
  String get quickAddActionWordsDesc =>
      '\"Add 200 on coffee\", \"Log 500 for groceries\", \"Create 1000 in savings\" - தொடக்கத்திலுள்ள செயல் சொற்கள் தானாகவே நீக்கப்படும்.';

  @override
  String get quickAddDefaultAccountInfo => 'இயல்புநிலை கணக்கு';

  @override
  String get quickAddDefaultAccountInfoDesc =>
      'ஒவ்வொரு முறையும் \"from ...\" என்று தட்டச்சு செய்வதைத் தவிர்க்க அமைப்புகளில் இயல்புநிலை கணக்கை அமைக்கவும்.';

  @override
  String get quickAddHint => 'உதா. 250 on groceries from HDFC';

  @override
  String get spendingPattern => 'செலவு முறை';

  @override
  String get avgDaily => 'தினசரி சராசரி';

  @override
  String get last90Days => 'கடந்த 90 நாட்கள்';

  @override
  String get statThisMonth => 'இந்த மாதம்';

  @override
  String statDays(String days) {
    return '$days நாட்கள்';
  }

  @override
  String get projectedLabel => 'திட்டமிடப்பட்டது';

  @override
  String get endOfMonth => 'மாத இறுதிக்குள்';

  @override
  String get budgetSnapshot => 'பட்ஜெட் நிலவரம்';

  @override
  String get budgetExceeded => 'வரம்பை தாண்டியது';

  @override
  String get budgetHighUsage => 'அதிக பயன்பாடு';

  @override
  String get budgetNearLimit => 'வரம்பிற்கு அருகில்';

  @override
  String get budgetOnTrack => 'சரியான பாதையில்';

  @override
  String get categoryLabel => 'வகை';

  @override
  String budgetRemaining(String amount) {
    return '$amount மீதமுள்ளது';
  }

  @override
  String get recentTransactions => 'சமீபத்திய பரிவர்த்தனைகள்';

  @override
  String get noTransactionsYet => 'பரிவர்த்தனைகள் எதுவும் இல்லை';

  @override
  String get smartInsights => 'ஸ்மார்ட் நுண்ணறிவுகள்';

  @override
  String get smartInsightsEmpty =>
      'உங்கள் நிதி பற்றிய நுண்ணறிவுகளைப் பெற\nபரிவர்த்தனைகளைத் தொடர்ந்து சேர்க்கவும்.';

  @override
  String get insightLabelWeekdayPattern => 'வார நாள் முறை';

  @override
  String get insightLabelTopCategory => 'முக்கிய வகை';

  @override
  String get insightLabelCategoryTrend => 'வகை போக்கு';

  @override
  String get insightLabelMonthTrend => 'மாதாந்திர போக்கு';

  @override
  String get insightLabelWeekendPattern => 'வார இறுதி முறை';

  @override
  String get insightLabelBigExpense => 'பெரிய செலவு';

  @override
  String get insightLabelSavings => 'சேமிப்பு';

  @override
  String get insightLabelRecurring => 'மீண்டும் மீண்டும் நிகழ்பவை';

  @override
  String get insightLabelStreak => 'தொடர்';

  @override
  String get insightLabelToday => 'இன்று';

  @override
  String get insightLabelThisWeek => 'இந்த வாரம்';

  @override
  String get insightLabelDidYouKnow => 'உங்களுக்குத் தெரியுமா';

  @override
  String get insightLabelLoans => 'கடன்கள்';

  @override
  String get insightLabelLoanInterest => 'கடன் வட்டி';

  @override
  String get insightLabelLendBorrow => 'கடன் கொடுப்பனவு / கடன் வாங்குதல்';

  @override
  String get insightLabelInvestments => 'முதலீடுகள்';

  @override
  String get insightLabelTopInvestment => 'முக்கிய முதலீடு';

  @override
  String get insightLabelSummary => 'சுருக்கம்';

  @override
  String get insightLabelTip => 'குறிப்பு';

  @override
  String get weekdayMonday => 'திங்கள்';

  @override
  String get weekdayTuesday => 'செவ்வாய்';

  @override
  String get weekdayWednesday => 'புதன்';

  @override
  String get weekdayThursday => 'வியாழன்';

  @override
  String get weekdayFriday => 'வெள்ளி';

  @override
  String get weekdaySaturday => 'சனி';

  @override
  String get weekdaySunday => 'ஞாயிறு';

  @override
  String get historyTitle => 'பரிவர்த்தனை\nவரலாறு';

  @override
  String get historyDescription =>
      'உங்கள் கடந்த கால செலவுகள், வருமானம் மற்றும் கணக்கு மாற்றங்கள்';

  @override
  String get exportLabel => 'ஏற்றுமதி';

  @override
  String get expLabel => 'செலவு';

  @override
  String get incLabel => 'வருமானம்';

  @override
  String get showingLabel => 'காட்டப்படுவது';

  @override
  String get transactionsLabel => 'பரிவர்த்தனைகள்';

  @override
  String get noTransactionsFound => 'பரிவர்த்தனைகள் எதுவும் காணப்படவில்லை';

  @override
  String get startTrackingExpenses =>
      'உங்கள் செலவுகளைக் கண்காணிக்கத் தொடங்குங்கள்';

  @override
  String get adjustSearchFilters =>
      'உங்கள் தேடல் அல்லது வடிப்பான்களை மாற்றி முயற்சிக்கவும்';

  @override
  String get addTransaction => 'பரிவர்த்தனையைச் சேர்';

  @override
  String selectedCount(String count) {
    return '$count தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String deleteTransactionsConfirm(String count) {
    return '$count பரிவர்த்தனைகளை நீக்கவா?';
  }

  @override
  String get actionCannotBeUndone => 'இந்தச் செயலை மாற்றியமைக்க முடியாது.';

  @override
  String transactionsDeleted(String count) {
    return '$count பரிவர்த்தனைகள் நீக்கப்பட்டன';
  }

  @override
  String tagsMoreCount(String count) {
    return '+$count மேலும்';
  }

  @override
  String get accountCorrectionSubtitle =>
      'கணக்கு திருத்தம் · பகுப்பாய்விலிருந்து விலக்கப்பட்டது';

  @override
  String get unknownLabel => 'தெரியாதது';

  @override
  String get transferLabel => 'பரிமாற்றம்';

  @override
  String get adjustmentLabel => 'சரிசெய்தல்';

  @override
  String get editTransfer => 'பரிமாற்றத்தைத் திருத்து';

  @override
  String get editTransaction => 'பரிவர்த்தனையைத் திருத்து';

  @override
  String get saveAndAddAnother => 'சேமித்து மற்றொன்றைச் சேர்';

  @override
  String get fromAccount => 'அனுப்புநர் கணக்கு';

  @override
  String get toAccount => 'பெறுநர் கணக்கு';

  @override
  String get transactionNameHint => 'பரிவர்த்தனை பெயர்';

  @override
  String get categoryUpper => 'வகை';

  @override
  String get selectLabel => 'தேர்ந்தெடு';

  @override
  String get updateExpense => 'செலவைப் புதுப்பி';

  @override
  String get updateIncome => 'வருமானத்தைப் புதுப்பி';

  @override
  String get updateTransferBtn => 'பரிமாற்றத்தைப் புதுப்பி';

  @override
  String get saveExpense => 'செலவைச் சேமி';

  @override
  String get saveIncome => 'வருமானத்தைச் சேமி';

  @override
  String get saveTransferBtn => 'பரிமாற்றத்தைச் சேமி';

  @override
  String get enterTransactionName => 'தயவுசெய்து பரிவர்த்தனை பெயரை உள்ளிடவும்';

  @override
  String get enterValidAmount => 'தயவுசெய்து செல்லுபடியாகும் தொகையை உள்ளிடவும்';

  @override
  String get selectCategoryError => 'தயவுசெய்து ஒரு வகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectAccountError => 'தயவுசெய்து ஒரு கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectSourceAccount =>
      'தயவுசெய்து அனுப்புநர் கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get selectDestinationAccount =>
      'தயவுசெய்து பெறுநர் கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get accountsMustDiffer =>
      'அனுப்புநர் மற்றும் பெறுநர் கணக்குகள் வெவ்வேறாக இருக்க வேண்டும்';

  @override
  String failedToSave(String error) {
    return 'சேமிக்க முடியவில்லை: $error';
  }

  @override
  String get addAnotherPrompt =>
      'பரிவர்த்தனை சேமிக்கப்பட்டது! மற்றொன்றைச் சேர்க்கலாமா?';

  @override
  String get transactionUpdated => 'பரிவர்த்தனை புதுப்பிக்கப்பட்டது';

  @override
  String get transactionSaved => 'பரிவர்த்தனை சேமிக்கப்பட்டது';

  @override
  String get transferUpdated => 'பரிமாற்றம் புதுப்பிக்கப்பட்டது';

  @override
  String get transferSaved => 'பரிமாற்றம் சேமிக்கப்பட்டது';

  @override
  String get creditCardPayment => 'கிரெடிட் கார்டு கட்டணம்';

  @override
  String get creditCardWithdrawal => 'கிரெடிட் கார்டு பணம் எடுத்தல்';

  @override
  String get creditCardTransfer => 'கிரெடிட் கார்டு பரிமாற்றம்';

  @override
  String get selectCategoryTitle => 'வகையைத் தேர்ந்தெடு';

  @override
  String get searchCategories => 'வகைகளைத் தேடு';

  @override
  String get noCategoriesFound => 'வகைகள் எதுவும் காணப்படவில்லை';

  @override
  String get ungrouped => 'குழுவாக்கப்படாதவை';

  @override
  String get addNewCategory => 'புதிய வகையைச் சேர்';

  @override
  String get budgetExists => 'பட்ஜெட் ஏற்கனவே உள்ளது';

  @override
  String get selectAccountTitle => 'கணக்கைத் தேர்ந்தெடு';

  @override
  String get chooseAccountSubtitle =>
      'இந்த பரிவர்த்தனைக்கான கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get noAccountsYet => 'கணக்குகள் எதுவும் இல்லை';

  @override
  String get addNewAccount => 'புதிய கணக்கைச் சேர்';

  @override
  String get addNoteHint => 'குறிப்பு சேர்க்கவும் (விருப்பத்திற்குரியது)';

  @override
  String get tagsUpper => 'குறிச்சொற்கள்';

  @override
  String get noTagsSelected => 'குறிச்சொற்கள் எதுவும் தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String tagsSelectedCount(String count) {
    return '$count குறிச்சொற்கள் தேர்ந்தெடுக்கப்பட்டன';
  }

  @override
  String get dateTimeLabel => 'தேதி & நேரம்';

  @override
  String get todayLabel => 'இன்று';

  @override
  String get yesterdayLabel => 'நேற்று';

  @override
  String get expenseLabel => 'செலவு';

  @override
  String get incomeLabel => 'வருமானம்';

  @override
  String get budgetLabel => 'பட்ஜெட்';

  @override
  String get attachmentsLabel => 'இணைப்புகள்';

  @override
  String get addImageOrPdf => 'படம் அல்லது PDF-ஐச் சேர்';

  @override
  String filesAttached(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கோப்புகள் இணைக்கப்பட்டுள்ளன',
      one: '1 கோப்பு இணைக்கப்பட்டுள்ளது',
    );
    return '$_temp0';
  }

  @override
  String get addAttachments => 'இணைப்புகளைச் சேர்';

  @override
  String get max5mb => 'ஒரு கோப்பிற்கு அதிகபட்சம் 5MB';

  @override
  String get cameraLabel => 'கேமரா';

  @override
  String get galleryLabel => 'கேலரி';

  @override
  String get fileExceeds5mb => 'கோப்பு 5MB வரம்பை விட அதிகமாக உள்ளது';

  @override
  String failedToPickImage(String error) {
    return 'படம் எடுப்பதில் தோல்வி: $error';
  }

  @override
  String get transactionDeleted => 'பரிவர்த்தனை நீக்கப்பட்டது';

  @override
  String get transferDeleted => 'பரிமாற்றம் நீக்கப்பட்டது';

  @override
  String get undoLabel => 'மாற்றியமை';

  @override
  String get transactionAmount => 'பரிவர்த்தனை தொகை';

  @override
  String get accountUpper => 'கணக்கு';

  @override
  String get notesUpper => 'குறிப்புகள்';

  @override
  String get addedUsingPrompt => 'உள்ளீடு மூலம் சேர்க்கப்பட்டது';

  @override
  String get attachedTags => 'இணைக்கப்பட்ட குறிச்சொற்கள்';

  @override
  String get noneLabel => 'எதுவுமில்லை';

  @override
  String get filtersUpper => 'வடிப்பான்கள்';

  @override
  String get filterExpensesTooltip => 'செலவுகளை வடிகட்டவும்';

  @override
  String get filterExp => 'செலவு';

  @override
  String get filterIncomeTooltip => 'வருமானத்தை வடிகட்டவும்';

  @override
  String get filterInc => 'வருமானம்';

  @override
  String get advancedFiltersTooltip => 'உন্নত வடிப்பான்கள்';

  @override
  String get clearFiltersTooltip => 'வடிப்பான்களை நீக்கவும்';

  @override
  String get searchTransactionsTooltip => 'பரிவர்த்தனைகளைத் தேடவும்';

  @override
  String get searchTransactionsHint => 'பரிவர்த்தனைகளைத் தேடவும்...';

  @override
  String get applySearchTooltip => 'தேடலைப் பயன்படுத்து';

  @override
  String get selectRange => 'வரம்பைத் தேர்ந்தெடு';

  @override
  String get advancedFiltersTitle => 'உன்னத வடிப்பான்கள்';

  @override
  String get clearAll => 'அனைத்தையும் நீக்கு';

  @override
  String get dateRangeLabel => 'தேதி வரம்பு';

  @override
  String get selectDateRange => 'தேதி வரம்பைத் தேர்ந்தெடுக்கவும்';

  @override
  String get transactionNameLabel => 'பரிவர்த்தனை பெயர்';

  @override
  String get searchViaName => 'பெயர் மூலம் தேடவும்.';

  @override
  String get typeFilterLabel => 'வகை';

  @override
  String get amountRangeLabel => 'தொகை வரம்பு';

  @override
  String get minLabel => 'குறைந்தபட்சம்';

  @override
  String get maxLabel => 'அதிகபட்சம்';

  @override
  String get errorLoadingAccounts => 'கணக்குகளை ஏற்றுவதில் பிழை';

  @override
  String get categoriesLabel => 'வகைகள்';

  @override
  String get errorLoadingCategories => 'வகைகளை ஏற்றுவதில் பிழை';

  @override
  String get errorLoadingTags => 'குறிச்சொற்களை ஏற்றுவதில் பிழை';

  @override
  String get applyFilters => 'வடிப்பான்களைப் பயன்படுத்து';

  @override
  String get creditShort => 'வரவு';

  @override
  String get bucketDawn => 'அதிகாலை';

  @override
  String get bucketMorning => 'காலை';

  @override
  String get bucketNoon => 'மதியம்';

  @override
  String get bucketEvening => 'மாலை';

  @override
  String get bucketNight => 'இரவு';

  @override
  String get weekLabel => 'வாரம்';

  @override
  String get analyticsTitle => 'செலவு\nபகுப்பாய்வு';

  @override
  String get analyticsDescription =>
      'உங்கள் செலவு முறைகளைக் காட்சிப்படுத்துங்கள்';

  @override
  String get noData => 'தரவு இல்லை';

  @override
  String get noTransactionsForPeriod =>
      'இந்தக் காலகட்டத்திற்குப் பரிவர்த்தனைகள் எதுவும் இல்லை';

  @override
  String get biggestTransactions => 'மிகப் பெரிய பரிவர்த்தனைகள்';

  @override
  String get spendingTrend => 'செலவுப் போக்கு';

  @override
  String get activeSelection => 'செயலில் உள்ள தேர்வு';

  @override
  String get quickFilters => 'விரைவான வடிப்பான்கள்';

  @override
  String get jumpTo => 'இங்கு செல்லவும்';

  @override
  String get invalidFormat => 'தவறான வடிவம்';

  @override
  String get startBeforeEnd =>
      'தொடக்க தேதி இறுதி தேதிக்கு முன்பாக இருக்க வேண்டும்';

  @override
  String get futureDatesNotAllowed => 'எதிர்கால தேதிகள் அனுமதிக்கப்படாது';

  @override
  String get manualDateRange => 'கைமுறை தேதி வரம்பு';

  @override
  String get manualDateRangeDesc =>
      'உங்கள் நிதிப் பகுப்பாய்விற்கான தனிப்பயன் காலத்தைக் குறிப்பிடவும்.';

  @override
  String get fromDateLabel => 'தொடக்க தேதி (DD/MM/YYYY)';

  @override
  String get toDateLabel => 'முடிவு தேதி (DD/MM/YYYY)';

  @override
  String get doneUpper => 'முடிந்தது';

  @override
  String get cancelUpper => 'ரத்துசெய்';

  @override
  String get thresholdSettings => 'வரம்பு அமைப்புகள்';

  @override
  String get resetToDefaults => 'இயல்புநிலைக்கு மீட்டமை';

  @override
  String get thresholdSmallDesc =>
      'பரிவர்த்தனைகள் சிறியவை என குறிக்கப்படுவதற்கான வரம்புத் தொகை.';

  @override
  String get thresholdLargeDesc =>
      'பரிவர்த்தனைகள் பெரியவை என குறிக்கப்படுவதற்கான வரம்புத் தொகை.';

  @override
  String get previewLogic => 'முன்னோட்ட தர்க்கம்';

  @override
  String get sizeSmall => 'சிறியது';

  @override
  String get sizeMedium => 'நடுத்தரம்';

  @override
  String get sizeLarge => 'பெரியது';

  @override
  String get budgetVsActual => 'படஜெட் மற்றும் உண்மையான செலவு';

  @override
  String get errorLoadingBudgets => 'பட்ஜெட்டுகளை ஏற்றுவதில் பிழை';

  @override
  String get noActiveBudgets => 'செயலில் உள்ள பட்ஜெட்டுகள் இல்லை';

  @override
  String get tagWiseAnalytics => 'குறிச்சொல் வாரியான பகுப்பாய்வு';

  @override
  String get spendingByTag => 'குறிச்சொல் வாரியான செலவு';

  @override
  String get topTagsContribution => 'முக்கிய குறிச்சொற்களின் பங்களிப்பு';

  @override
  String get noTagsInRange =>
      'நீங்கள் தேர்ந்தெடுத்த தேதி வரம்பில் குறிச்சொல் சார்ந்த பரிவர்த்தனைகள் எதுவும் இல்லை';

  @override
  String get spendingDistribution => 'செலவுப் பகிர்வு';

  @override
  String get groupLabel => 'குழு';

  @override
  String get errorLoadingData => 'தரவை ஏற்றுவதில் பிழை';

  @override
  String get noDataAvailable => 'தரவு எதுவும் இல்லை';

  @override
  String get transactionSizeDistribution => 'பரிவர்த்தனை அளவுப் பகிர்வு';

  @override
  String get frequencyByTicketSize => 'பரிவர்த்தனை அளவுக்கு ஏற்ப அதிர்வெண்';

  @override
  String get avgWeeklyHeatmap => 'வாராந்திர சராசரி ஹீட்மேப்';

  @override
  String get basedOnSelectedFilter =>
      'நீங்கள் தேர்ந்தெடுத்த வடிப்பானின் அடிப்படையில்';

  @override
  String get intensity => 'அடர்த்தி';

  @override
  String get applyFilter => 'வடிப்பானைப் பயன்படுத்து';

  @override
  String get thresholdFloorHeading => 'சிறிய/நடுத்தர எல்லை (கீழ் வரம்பு)';

  @override
  String get thresholdCeilingHeading => 'நடுத்தர/பெரிய எல்லை (மேல் வரம்பு)';

  @override
  String get manageAccounts => 'கணக்குகளை\nநிர்வகி';

  @override
  String get addAccount => 'கணக்கைச் சேர்';

  @override
  String get editAccount => 'கணக்கைத் திருத்து';

  @override
  String get addFirstAccount =>
      'கண்காணிக்கத் தொடங்க உங்கள் முதல் கணக்கைச் சேர்க்கவும்';

  @override
  String get addAnotherAccount => 'மற்றொரு கணக்கைச் சேர்';

  @override
  String get availableBalance => 'கிடைக்கக்கூடிய இருப்பு';

  @override
  String get limitUpper => 'வரம்பு';

  @override
  String get defaultUpper => 'இயல்புநிலை';

  @override
  String get addTransactionTooltip => 'பரிவர்த்தனையைச் சேர்';

  @override
  String get savingsAccount => 'சேமிப்புக் கணக்கு';

  @override
  String get viewTransactions => 'பரிவர்த்தனைகளைக் காண்க';

  @override
  String get errorLoadingBalance => 'இருப்பை ஏற்றுவதில் பிழை';

  @override
  String get editLimitSpent => 'செலவழித்த வரம்பைத் திருத்து';

  @override
  String get editBalance => 'இருப்பைத் திருத்து';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String get removeDefault => 'இயல்புநிலையை நீக்கு';

  @override
  String get setAsDefaultLabel => 'இயல்புநிலையாக அமை';

  @override
  String get currentAvailableBalance => 'தற்போதைய கிடைக்கக்கூடிய இருப்பு';

  @override
  String get limitSpent => 'செலவழித்த வரம்பு';

  @override
  String get totalLimit => 'மொத்த வரம்பு';

  @override
  String get cannotDeleteAccount => 'கணக்கை நீக்க முடியாது';

  @override
  String get cannotDeleteAccountBody =>
      'இந்தக் கணக்குடன் பரிவர்த்தனைகள் இணைக்கப்பட்டுள்ளன. இந்தக் கணக்கை நீக்க, முதலில் இணைக்கப்பட்ட பரிவர்த்தனைகளை நீக்கவும்.';

  @override
  String get okLabel => 'சரி';

  @override
  String get deleteAccountConfirm => 'கணக்கை நீக்கவா?';

  @override
  String get limitSpentUpdated =>
      'செலவழித்த வரம்பு வெற்றிகரமாகப் புதுப்பிக்கப்பட்டது';

  @override
  String get balanceUpdated => 'இருப்பு வெற்றிகரமாகப் புதுப்பிக்கப்பட்டது';

  @override
  String get currentLimitSpent => 'தற்போதைய செலவழித்த வரம்பு';

  @override
  String get currentBalance => 'தற்போதைய இருப்பு';

  @override
  String get newLimitSpent => 'புதிய செலவழித்த வரம்பு';

  @override
  String get newBalance => 'புதிய இருப்பு';

  @override
  String get enterAccountName => 'தயவுசெய்து கணக்கின் பெயரை உள்ளிடவும்';

  @override
  String get identity => 'அடையாளம்';

  @override
  String get creditCardName => 'கிரெடிட் கார்டு பெயர்';

  @override
  String get cashName => 'ரொக்கப் பெயர்';

  @override
  String get bankName => 'வங்கிப் பெயர்';

  @override
  String get iconLabel => 'சின்னம்';

  @override
  String get colorLabel => 'நிறம்';

  @override
  String get typeLabel => 'வகை';

  @override
  String get last4DigitsHint => 'கடைசி 4 இலக்கங்கள் (விருப்பத்திற்குரியது)';

  @override
  String get balanceLabel => 'இருப்பு';

  @override
  String get initialBalance => 'தொடக்க இருப்பு';

  @override
  String get limitSpentField => 'செலவழித்த வரம்பு';

  @override
  String get totalLimitField => 'மொத்த வரம்பு';

  @override
  String get saveAccount => 'கணக்கைச் சேமி';

  @override
  String get totalNetWorth => 'மொத்த நிகர மதிப்பு';

  @override
  String get assets => 'சொத்துகள்';

  @override
  String get debt => 'கடன்';

  @override
  String get cardLast4Note =>
      'கார்டின் கடைசி 4 இலக்கங்கள் · எங்கும் பகிரப்படாது';

  @override
  String lastTransaction(String time) {
    return 'கடைசி பரிவர்த்தனை $time';
  }

  @override
  String deleteAccountBody(String name) {
    return 'நீங்கள் நிச்சயமாக $name-ஐ நீக்க விரும்புகிறீர்களா? இந்தச் செயலை மாற்றியமைக்க முடியாது.';
  }

  @override
  String get adjustmentNote =>
      'சரிசெய்தல் ஒரு பரிவர்த்தனையாகப் பதிவு செய்யப்படும் (பகுப்பாய்வு பாதிக்கப்படாது)';

  @override
  String get trackBudgets => 'பட்ஜெட்களைக்\nகண்காணி';

  @override
  String get createBudget => 'பட்ஜெட்டை உருவாக்கு';

  @override
  String get editBudget => 'பட்ஜெட்டைத் திருத்து';

  @override
  String get noBudgetsYet => 'பட்ஜெட்கள் எதுவும் இல்லை';

  @override
  String get createBudgetsDesc =>
      'ஒவ்வொரு வகைக்கும் உங்கள் செலவைக் கட்டுப்படுத்த பட்ஜெட்களை உருவாக்குங்கள்';

  @override
  String get disabledUpper => 'முடக்கப்பட்டது';

  @override
  String get expiredUpper => 'காலாவதியானது';

  @override
  String get budgetPeriodEnded => 'பட்ஜெட் காலம் முடிந்தது';

  @override
  String get budgetPaused => 'பட்ஜெட் தற்போது இடைநிறுத்தப்பட்டுள்ளது';

  @override
  String budgetResetsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: '1 நாளில்',
    );
    return '$_temp0 மீட்டமைக்கப்படும்';
  }

  @override
  String budgetExpiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: '1 நாளில்',
    );
    return '$_temp0 காலாவதியாகும்';
  }

  @override
  String get progressLabel => 'முன்னேற்றம்';

  @override
  String get selectCategoryUpper => 'வகையைத் தேர்ந்தெடு';

  @override
  String get budgetAmount => 'பட்ஜெட் தொகை';

  @override
  String get appliesTo => 'இதற்குப் பொருந்தும்';

  @override
  String get thisMonthOnly => 'இந்த மாதம்\nமட்டும்';

  @override
  String get everyMonth => 'ஒவ்வொரு\nமாதமும்';

  @override
  String get budgetAlerts => 'பட்ஜெட் எச்சரிக்கைகள்';

  @override
  String get addAlert => 'எச்சரிக்கையைச் சேர்';

  @override
  String get saveBudget => 'பட்ஜெட்டைச் சேமி';

  @override
  String get tapToChangeCategory => 'வகையை மாற்ற தட்டவும்';

  @override
  String get chooseCategory => 'வகையைத் தேர்ந்தெடு';

  @override
  String get monthlyBudgetPlan => 'மாதாந்திர பட்ஜெட் திட்டம்';

  @override
  String get currentSpending => 'தற்போதைய செலவு';

  @override
  String get utilization => 'பயன்பாடு';

  @override
  String get budgetDetails => 'பட்ஜெட் விவரங்கள்';

  @override
  String get createdOn => 'உருவாக்கப்பட்ட தேதி';

  @override
  String get renewsOn => 'புதுப்பிக்கப்படும் தேதி';

  @override
  String get expiresOn => 'காலாவதியாகும் தேதி';

  @override
  String get startedOn => 'தொடங்கிய தேதி';

  @override
  String get statusUpper => 'நிலை';

  @override
  String get activeLabel => 'செயலில் உள்ளது';

  @override
  String get pausedLabel => 'இடைநிறுத்தப்பட்டுள்ளது';

  @override
  String get activeAlerts => 'செயலில் உள்ள எச்சரிக்கைகள்';

  @override
  String get noAlertsSet => 'எச்சரிக்கைகள் எதுவும் அமைக்கப்படவில்லை';

  @override
  String get actionsUpper => 'செயல்கள்';

  @override
  String get pauseLabel => 'இடைநிறுத்து';

  @override
  String get resumeLabel => 'மீண்டும் தொடங்கு';

  @override
  String get historyLabel => 'வரலாறு';

  @override
  String get deleteBudgetConfirm => 'பட்ஜெட்டை நீக்கவா?';

  @override
  String get budgetHistory => 'பட்ஜெட் வரலாறு';

  @override
  String get noHistoryYet => 'இன்னும் வரலாறு இல்லை';

  @override
  String get budgetHistoryEmptyDesc =>
      'பரிவர்த்தனைகள் பதிவு செய்யப்பட்டதும் இந்த பட்ஜெட்டிற்கான உங்கள் செலவு வரலாறு இங்கே தோன்றும்.';

  @override
  String get overBudget => 'பட்ஜெட்டைத் தாண்டியது';

  @override
  String get underBudget => 'பட்ஜெட்டிற்குள்';

  @override
  String get enterValidValue => 'செல்லுபடியாகும் மதிப்பை உள்ளிடவும்';

  @override
  String get amountExceedsBudget =>
      'தொகை பட்ஜெட் வரம்பை விட அதிகமாக இருக்க முடியாது';

  @override
  String get alertAlreadyExists =>
      'இந்த மதிப்புக்கான எச்சரிக்கை ஏற்கனவே உள்ளது';

  @override
  String get addAlertTitle => 'எச்சரிக்கையைச் சேர்';

  @override
  String get selectAlertType => 'எச்சரிக்கை வகையைத் தேர்ந்தெடு';

  @override
  String get percentageType => 'சதவீதம் (%)';

  @override
  String get pushNotification => 'புஷ் அறிவிப்பு';

  @override
  String exceededBy(String amount) {
    return '$amount தாண்டியது';
  }

  @override
  String get budgetAlreadyExists => 'இந்த வகைக்கு ஏற்கனவே பட்ஜெட் உள்ளது';

  @override
  String deleteBudgetBody(String name) {
    return '\"$name\" பட்ஜெட் நிரந்தரமாக நீக்கப்படும்.';
  }

  @override
  String alertDesc(String value) {
    return 'என் மாதாந்திர பட்ஜெட்டில் செலவு $value-ஐ எட்டும்போது எனக்கு எச்சரிக்கை செய்.';
  }

  @override
  String get percentageCannotExceed =>
      'சதவீதம் 100%-ஐ விட அதிகமாக இருக்க முடியாது';

  @override
  String alertAmountType(String symbol) {
    return 'நிலையான தொகை ($symbol)';
  }

  @override
  String get loansTitle => 'கடன்கள்';

  @override
  String get addLoan => 'கடனைச் சேர்';

  @override
  String get noLoansAdded => 'கடன்கள் எதுவும் சேர்க்கப்படவில்லை';

  @override
  String get loansEmptyDesc =>
      'உங்கள் முதல் கடன் EMI-ஐக் கண்காணிக்க + என்பதைத் தட்டவும்';

  @override
  String get activeLoans => 'செயலில் உள்ள கடன்கள்';

  @override
  String get editLoan => 'கடனைத் திருத்து';

  @override
  String get newLoan => 'புதிய கடன்';

  @override
  String get loanAmount => 'கடன் தொகை';

  @override
  String get totalPrincipal => 'மொத்த அசல்';

  @override
  String get loanType => 'கடன் வகை';

  @override
  String get loanTypeVehicle => 'வாகனம்';

  @override
  String get loanTypePersonal => 'தனிநபர்';

  @override
  String get loanTypeEducation => 'கல்வி';

  @override
  String get loanTypeOther => 'இதர';

  @override
  String get loanName => 'கடன் பெயர்';

  @override
  String get loanNameHint => 'உதா. Maruti Brezza';

  @override
  String get lenderHint => 'உதா. HDFC Bank';

  @override
  String get referenceNumber => 'குறிப்பு எண்';

  @override
  String get referenceNumberHint => 'அனுமதி / கடன் ID';

  @override
  String get termsLabel => 'விதிமுறைகள்';

  @override
  String get interestRate => 'வட்டி விகிதம்';

  @override
  String get rateFixed => 'நிலையானது';

  @override
  String get rateFloating => 'மாறுபடக்கூடியது';

  @override
  String get payEmi => 'EMI செலுத்து';

  @override
  String get payExtra => 'கூடுதல் தொகை செலுத்து';

  @override
  String get closeLoan => 'கடனை மூடு';

  @override
  String get progressUpper => 'முன்னேற்றம்';

  @override
  String get totalUpper => 'மொத்தம்';

  @override
  String get paidUpper => 'செலுத்தப்பட்டது';

  @override
  String get remainingUpper => 'மீதமுள்ளது';

  @override
  String get nextEmiDue => 'அடுத்த EMI செலுத்துவதற்கான தேதி';

  @override
  String get interestRateUpper => 'வட்டி விகிதம்';

  @override
  String get paymentHistory => 'கட்டண வரலாறு';

  @override
  String get noPaymentsRecorded => 'கட்டணங்கள் எதுவும் பதிவு செய்யப்படவில்லை';

  @override
  String get deleteLoanConfirm => 'கடனை நீக்கவா?';

  @override
  String get deleteLoanBody =>
      'இது கடனையும் அதன் இணைக்கப்பட்ட அனைத்து கட்டணப் பரிவர்த்தனைகளையும் நீக்கிவிடும். இதை மாற்றியமைக்க முடியாது.';

  @override
  String get emiPaid => 'EMI செலுத்தப்பட்டது';

  @override
  String get extraPayment => 'கூடுதல் கட்டணம்';

  @override
  String get loanClosure => 'கடன் மூடல்';

  @override
  String get confirmClosure => 'மூடுதலை உறுதிசெய்';

  @override
  String get confirmPayment => 'கட்டணத்தை உறுதிசெய்';

  @override
  String get amountUpper => 'தொகை';

  @override
  String get dateUpper => 'தேதி';

  @override
  String get noteOptional => 'குறிப்பு (விருப்பத்திற்குரியது)';

  @override
  String get totalOutstandingDebt => 'மொத்த நிலுவைக் கடன்';

  @override
  String get paidLabel => 'செலுத்தப்பட்டது';

  @override
  String get outstandingTitle => 'நிலுவையில் உள்ளவை';

  @override
  String get interestLabel => 'வட்டி';

  @override
  String get nextDue => 'அடுத்த தவணை';

  @override
  String get completedUpper => 'முடிவடைந்தது';

  @override
  String get lenderField => 'கடன் வழங்குபவர்';

  @override
  String get loanTypeHome => 'வீடு';

  @override
  String get monthlyOutflow => 'மாதாந்திர செலவு';

  @override
  String get perMonth => 'மாதத்திற்கு';

  @override
  String get tenure => 'கால அளவு';

  @override
  String get schedule => 'அட்டவணை';

  @override
  String get loanStartDate => 'கடன் தொடங்கிய தேதி';

  @override
  String get repaymentStart => 'திருப்பிச் செலுத்துதல் தொடக்கம்';

  @override
  String get firstEmiOn => 'முதல் EMI தேதி';

  @override
  String get monthlyBillDate => 'மாதாந்திர பில் தேதி';

  @override
  String get sourceAccount => 'அனுப்புநர் கணக்கு';

  @override
  String get autoAddTransactions => 'பரிவர்த்தனைகளைத் தானாகச் சேர்';

  @override
  String get autoAddTransactionsSub =>
      'ஒவ்வொரு EMI-ஐயும் அதன் பில் தேதியில் \"Loan EMI\" பிரிவில் சேர்க்கவும்';

  @override
  String get notesLabel => 'குறிப்புகள்';

  @override
  String get loanNotesHint => 'ஆவணங்கள் · அனுமதி கடித குறிப்பு · ஏதேனும் ஒன்று';

  @override
  String get saveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get confirmAddLoan => 'உறுதிசெய்து கடனைச் சேர்';

  @override
  String percentPaid(String pct) {
    return '$pct% செலுத்தப்பட்டது';
  }

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navAnalytics => 'பகுப்பாய்வு';

  @override
  String get navMore => 'மேலும்';

  @override
  String get speedDialRecurring => 'தொடர் பரிவர்த்தனையைச் சேர்';

  @override
  String get speedDialLoan => 'கடனைச் சேர்';

  @override
  String get speedDialInvestment => 'முதலீட்டைச் சேர்';

  @override
  String get speedDialLendBorrow => 'கடன் கொடுத்தல் / வாங்குதல் சேர்';

  @override
  String get moneyStoriesTitle => 'பணக் கதைகள்';

  @override
  String get moneyStoriesEmpty =>
      'உங்கள் பணக் கதைகளை விரைவில் பார்க்க பரிவர்த்தனைகளைச் செய்து கொண்டே இருங்கள்.';

  @override
  String get bubbleWelcome => 'வரவேற்பு';

  @override
  String get bubbleDaily => 'தினசரி';

  @override
  String get bubbleWeekly => 'வாராந்திர';

  @override
  String get bubbleMonthly => 'மாதாந்திர';

  @override
  String get bubbleYearly => 'வருடாந்திர';

  @override
  String get bubbleLoans => 'கடன்கள்';

  @override
  String get bubbleInvestments => 'முதலீடுகள்';

  @override
  String get bubbleLedger => 'கணக்கு புத்தகம்';

  @override
  String get bubbleInsights => 'நுண்ணறிவுகள்';

  @override
  String get storiesArchiveTitle => 'கதைகள் காப்பகம்';

  @override
  String get storiesArchiveDesc =>
      'உங்களுக்காக உருவாக்கப்பட்ட ஒவ்வொரு கதையின் சுருக்கம், புதியது முதலில்.';

  @override
  String get noStoriesYet => 'இன்னும் கதைகள் இல்லை';

  @override
  String get keepUsingToSeeRecaps =>
      'உங்கள் சுருக்கங்களை இங்கே காண குபேரைத் தொடர்ந்து பயன்படுத்துங்கள்.';

  @override
  String get earlierThisWeek => 'இந்த வார தொடக்கத்தில்';

  @override
  String get earlierThisMonth => 'இந்த மாத தொடக்கத்தில்';

  @override
  String get olderLabel => 'பழையவை';

  @override
  String get loadingOlderStories => 'பழைய கதைகள் ஏற்றப்படுகின்றன';

  @override
  String get justNow => 'இப்போதுதான்';

  @override
  String minsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நிமிடங்களுக்கு முன்பு',
      one: '1 நிமிடத்திற்கு முன்பு',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மணிநேரங்களுக்கு முன்பு',
      one: '1 மணிநேரத்திற்கு முன்பு',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களுக்கு முன்பு',
      one: '1 நாளுக்கு முன்பு',
    );
    return '$_temp0';
  }

  @override
  String relativeToday(Object time) {
    return 'இன்று, $time';
  }

  @override
  String relativeYesterday(Object time) {
    return 'நேற்று, $time';
  }

  @override
  String get utilizedLabel => 'பயன்படுத்தப்பட்டது';

  @override
  String utilizedPct(Object pct) {
    return '$pct% பயன்படுத்தப்பட்டது';
  }

  @override
  String get editWidgets => 'விட்ஜெட்டுகளைத் திருத்து';

  @override
  String get editHomeWidgets => 'முகப்பு விட்ஜெட்டுகளைத் திருத்து';

  @override
  String get editHomeWidgetsDesc =>
      'முகப்பு விட்ஜெட்டுகளைத் தேர்ந்தெடுத்து வரிசைப்படுத்துங்கள்';

  @override
  String get editAnalyticsWidgets => 'பகுப்பாய்வு விட்ஜெட்டுகளைத் திருத்து';

  @override
  String get editAnalyticsWidgetsDesc =>
      'பகுப்பாய்வு விட்ஜெட்டுகளைத் தேர்ந்தெடுத்து வரிசைப்படுத்துங்கள்';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get filterToday => 'இன்று';

  @override
  String get filterThisWeek => 'இந்த வாரம்';

  @override
  String get filterLastWeek => 'கடந்த வாரம்';

  @override
  String get filterThisMonth => 'இந்த மாதம்';

  @override
  String get filterLastMonth => 'கடந்த மாதம்';

  @override
  String get filterThisYear => 'இந்த ஆண்டு';

  @override
  String get filterCustom => 'தனிப்பயன்';

  @override
  String get moreManageTitle => 'மேலாண்மை';

  @override
  String get moreToolsTitle => 'சிக்னேச்சர்';

  @override
  String get moreAppTitle => 'செயலி';

  @override
  String get moreTutorialTitle => 'பயிற்சி';

  @override
  String get moreHelpUsTitle => 'உதவி செய்யுங்கள்';

  @override
  String get moreAboutTitle => 'பற்றி';

  @override
  String get moreSearchTooltip => 'தேடு';

  @override
  String get moreManageSubtitle =>
      'உங்கள் அமைப்புகள், கருவிகள் மற்றும் தரவை நிர்வகிக்கவும்';

  @override
  String get menuAccounts => 'கணக்குகள்';

  @override
  String get menuAccountsDesc => 'உங்கள் வாலெட்டுகள் மற்றும் வங்கி கணக்குகள்';

  @override
  String get menuCategories => 'வகைகள்';

  @override
  String get menuCategoriesDesc => 'உங்கள் பரிவர்த்தனைகளை ஒழுங்கமைக்கவும்';

  @override
  String get menuTags => 'குறிச்சொற்கள்';

  @override
  String get menuTagsDesc => 'பரிவர்த்தனைகளுக்கான லேபிள்களை ஒழுங்கமைக்கவும்';

  @override
  String get menuBudgets => 'பட்ஜெட்டுகள்';

  @override
  String get menuBudgetsDesc =>
      'மாதாந்திர செலவைக் கண்காணித்துக் கட்டுப்படுத்துங்கள்';

  @override
  String get menuRecurring => 'தொடர் பரிவர்த்தனைகள்';

  @override
  String get menuRecurringDesc => 'தானியங்கி திட்டமிடப்பட்ட பரிவர்த்தனைகள்';

  @override
  String get menuLedger => 'கடன் கொடுத்தல் / வாங்குதல்';

  @override
  String get menuLedgerDesc =>
      'நீங்கள கொடுத்த அல்லது வாங்கிய பணத்தைக் கண்காணியுங்கள்';

  @override
  String get menuLoans => 'கடன்கள்';

  @override
  String get menuLoansDesc =>
      'இஎம்ஐ மற்றும் திருப்பிச் செலுத்தும் முன்னேற்றத்தைக் கண்காணியுங்கள்';

  @override
  String get menuInvestments => 'முதலீடுகள்';

  @override
  String get menuInvestmentsDesc =>
      'முதலீட்டு மதிப்பு மற்றும் வளர்ச்சியைக் கண்காணியுங்கள்';

  @override
  String get menuAskKuber => 'குபேரிடம் கேளுங்கள் (பீட்டா)';

  @override
  String get menuAskKuberDesc => 'சாதனத்திலேயே இயங்கும் ஸ்மார்ட் உதவியாளர்';

  @override
  String get menuCalculators => 'கணக்கீட்டாளர்கள் & கருவிகள்';

  @override
  String get menuCalculatorsDesc =>
      'இஎம்ஐ, எஸ்ஐபி, சம்பளம், ஜிஎஸ்டி, பகிர்வு மற்றும் பல';

  @override
  String get menuSettings => 'அமைப்புகள்';

  @override
  String get menuSettingsDesc => 'தீம், நாணயம் மற்றும் சுயவிவரம்';

  @override
  String get menuData => 'தரவு';

  @override
  String get menuDataDesc => 'ஏற்றுமதி, இறக்குமதி, தானியங்கி காப்புப்பிரதிகள்';

  @override
  String get menuStoriesArchive => 'பணக் கதைகள் காப்பகம்';

  @override
  String get menuStoriesArchiveDesc => 'ஒவ்வொரு சுருக்கமும், புதியது முதலில்';

  @override
  String get menuWidgets => 'விட்ஜெட்டுகள்';

  @override
  String get menuWidgetsDesc =>
      'Kuber-ஐ கண்முன் வைக்க முகப்புத் திரை விட்ஜெட்டுகள்';

  @override
  String get menuTroubleshoot => 'பழுது நீக்குதல்';

  @override
  String get menuTroubleshootDesc =>
      'தரவு மற்றும் பரிந்துரை சிக்கல்களைச் சரிசெய்யவும்';

  @override
  String get menuTutorial => 'செயலி பயிற்சி (பீட்டா)';

  @override
  String get menuTutorialDesc => 'அம்சங்களின் வழிகாட்டியை மீண்டும் பார்க்கவும்';

  @override
  String get menuRateUs => 'ப்ளே ஸ்டோரில் எங்களை மதிப்பிடுங்கள்';

  @override
  String get menuRateUsDesc => 'குபேர் பிடித்துள்ளதா? மதிப்பாய்வு செய்யுங்கள்';

  @override
  String get menuShareApp => 'செயலியைப் பகிரவும்';

  @override
  String get menuShareAppDesc =>
      'நண்பர்கள் மற்றும் குடும்பத்தினருக்கு குபேரை பரிந்துரைக்கவும்';

  @override
  String get menuFeedback => 'கருத்து தெரிவிக்கவும்';

  @override
  String get menuFeedbackDesc =>
      'பிழையைப் புகாரளிக்கவும் அல்லது புதிய அம்சத்தைப் பரிந்துரைக்கவும்';

  @override
  String get menuAbout => 'குபேர் பற்றி';

  @override
  String get menuAboutDesc => 'நோக்கம், தோற்றம் மற்றும் உருவாக்குநர்';

  @override
  String get menuPermissions => 'அனுமதிகள்';

  @override
  String get menuPermissionsDesc => 'செயலி வரம்புகள் மற்றும் பாதுகாப்பு';

  @override
  String get menuDevTools => 'டெவ் கருவிகள்';

  @override
  String get menuDevToolsDesc => 'டெவலப்பர்களுக்கான கருவிகள் மட்டும்';

  @override
  String madeInIndia(Object heart) {
    return 'இந்தியாவில் $heart உடன் தயாரிக்கப்பட்டது';
  }

  @override
  String madeInIndiaVersion(Object heart, Object version) {
    return 'இந்தியாவில் $heart உடன் தயாரிக்கப்பட்டது · v$version';
  }

  @override
  String get shareMessage =>
      'உங்கள் செலவுகளை முன்னெப்போதையும் விட எளிதாக நிர்வகிக்கவும். குபேர் என்பது இந்தியாவில் அன்போடு உருவாக்கப்பட்ட ஒரு அழகான எளிய செலவு மேலாளர். இங்கே பதிவிறக்கவும்: https://play.google.com/store/apps/details?id=com.grs.kuber';

  @override
  String get menuManageSpaces => '8 பிரிவுகள்';

  @override
  String get menuHelpUsHint => 'ஆதரவளிக்க தட்டவும்';

  @override
  String get menuRateKuber => 'குபேரை மதிப்பிடுங்கள்';

  @override
  String get menuShare => 'பகிர்';

  @override
  String get menuFeedbackShort => 'கருத்து';

  @override
  String get menuAppTutorialShort => 'செயலி பயிற்சி';

  @override
  String get menuNotifications => 'அறிவிப்புகள்';

  @override
  String get menuNotificationsDesc =>
      'சமீபத்திய விழிப்பூட்டல்கள் மற்றும் நினைவூட்டல்கள்';

  @override
  String get manageCategoriesTitle => 'வகைகளை\nநிர்வகி';

  @override
  String get addCategoryGroup => 'வகை/குழுவைச் சேர்';

  @override
  String get noCategoriesYet => 'இன்னும் வகைகள் இல்லை';

  @override
  String get createCategoriesToOrganize =>
      'செலவுகளை ஒழுங்கமைக்க வகைகளை உருவாக்குங்கள்';

  @override
  String get searchCategoriesGroups =>
      'வகைகள் மற்றும் குழுக்களைத் தேடுங்கள்...';

  @override
  String get noMatches => 'பொருத்தம் எதுவுமில்லை';

  @override
  String noCategoriesGroupsMatch(Object query) {
    return '\"$query\" உடன் எந்த வகையும் அல்லது குழுவும் பொருந்தவில்லை.';
  }

  @override
  String get ungroupedLabel => 'குழுவற்றவை';

  @override
  String get categoryGroupLabel => 'வகை குழு';

  @override
  String get editGroupLabel => 'குழுவைத் திருத்து';

  @override
  String get deleteGroupLabel => 'குழுவை நீக்கு';

  @override
  String get groupAlreadyExists => 'இந்த குழு ஏற்கனவே உள்ளது';

  @override
  String get groupNameEmpty => 'குழுவின் பெயர் காலியாக இருக்கக்கூடாது';

  @override
  String get addNewHeader => 'புதியதைச் சேர்';

  @override
  String get addClassifyDesc =>
      'சிறந்த கண்காணிப்புக்கு உங்கள் பரிவர்த்தனைகளை வகைப்படுத்துங்கள்';

  @override
  String get addGroupHeader => 'குழுவைச் சேர்';

  @override
  String get addGroupDesc =>
      'சிறந்த தெளிவுக்கு வகைகளைக் குழுக்களாக ஒழுங்கமைக்கவும்';

  @override
  String get manageTagsTitle => 'குறிச்சொற்களை\nநிர்வகி';

  @override
  String get addTagLabel => 'குறிச்சொல்லைச் சேர்';

  @override
  String get noTagsYet => 'இன்னும் குறிச்சொற்கள் இல்லை';

  @override
  String get createTagsToLabel =>
      'பரிவர்த்தனைகளை லேபிளிட குறிச்சொற்களை உருவாக்குங்கள் (उदा. #trip, #work)';

  @override
  String get searchTags => 'குறிச்சொற்களைத் தேடுங்கள்...';

  @override
  String noTagsMatch(Object query) {
    return '\"$query\" உடன் எந்த குறிச்சொல்லும் பொருந்தவில்லை.';
  }

  @override
  String get editTag => 'குறிச்சொல்லைத் திருத்து';

  @override
  String get deleteTag => 'குறிச்சொல்லை நீக்கு';

  @override
  String get tagNameEmpty => 'குறிச்சொல் பெயர் காலியாக இருக்கக்கூடாது';

  @override
  String get tagAlreadyExists => 'இந்த குறிச்சொல் ஏற்கனவே உள்ளது';

  @override
  String get recurringTitle => 'தொடர்\nபரிவர்த்தனைகள்';

  @override
  String get recurringDesc =>
      'உங்கள் வழக்கமான வருமானம் மற்றும் செலவுகளைத் தானியங்குபடுத்துங்கள்';

  @override
  String get addRule => 'விதியைச் சேர்';

  @override
  String get noRulesYet => 'இன்னும் தொடர் விதிகள் இல்லை';

  @override
  String get createRulesToAutomate =>
      'வாடகை, சம்பளம், எஸ்ஐபி போன்றவற்றைத் தானியங்குபடுத்த விதியை உருவாக்குங்கள்.';

  @override
  String get activeRules => 'செயலில் உள்ள விதிகள்';

  @override
  String get pausedRules => 'நிறுத்தப்பட்ட விதிகள்';

  @override
  String get editRule => 'விதியைத் திருத்து';

  @override
  String get ruleName => 'விதி பெயர்';

  @override
  String get ruleAmount => 'தொகை';

  @override
  String get ruleFrequency => 'அதிர்வெண்';

  @override
  String get nextProcessDate => 'அடுத்த செயலாக்க தேதி';

  @override
  String get deleteRuleConfirm => 'விதியை நீக்கலாமா?';

  @override
  String get deleteRuleBody =>
      'இது தொடர் விதியை நீக்கும். இந்த விதியால் உருவாக்கப்பட்ட தற்போதைய பரிவர்த்தனைகள் நீக்கப்படாது.';

  @override
  String get rulePaused => 'விதி இடைநிறுத்தப்பட்டது';

  @override
  String get ruleResumed => 'விதி மீண்டும் தொடங்கப்பட்டது';

  @override
  String get ledgerTitle => 'கடன் கொடுத்தல் / வாங்குதல்';

  @override
  String get ledgerDesc =>
      'மற்றவர்களுக்கு கொடுத்த அல்லது வாங்கிய பணத்தைக் கண்காணியுங்கள்';

  @override
  String get addEntry => 'பதிவைச் சேர்';

  @override
  String get noLedgerYet => 'இன்னும் பதிவுகள் இல்லை';

  @override
  String get createLedgerToTrack => 'பணம் கடன் கொடுக்க அல்லது வாங்க + தட்டவும்';

  @override
  String get whoOwes => 'யார் தர வேண்டும்';

  @override
  String get youOweLabel => 'நீங்கள் தர வேண்டியது';

  @override
  String get owesYouLabel => 'உங்களுக்கு வரவேண்டியது';

  @override
  String get settledLabel => 'தீர்க்கப்பட்டது';

  @override
  String get settleUp => 'கணக்கை முடி';

  @override
  String get deleteEntryConfirm => 'பதிவை நீக்கலாமா?';

  @override
  String get deleteEntryBody =>
      'இது இந்த பதிவையும் அதன் அனைத்து பரிவர்த்தனைகளையும் நீக்கும். இதை மாற்ற முடியாது.';

  @override
  String get investmentsTitle => 'முதலீடுகள்';

  @override
  String get investmentsDesc =>
      'உங்கள் முதலீட்டு மதிப்பு, பங்களிப்புகள் மற்றும் வளர்ச்சியைக் கண்காணியுங்கள்';

  @override
  String get addInvestment => 'முதலீட்டைச் சேர்';

  @override
  String get noInvestmentsYet => 'இன்னும் முதலீடுகள் இல்லை';

  @override
  String get createInvestmentToTrack =>
      'உங்கள் எஸ்ஐபி, பரஸ்பர நிதிகள், பங்குகள் போன்றவற்றைக் கண்காணிக்க + தட்டவும்.';

  @override
  String get portfolioValue => 'முதலீட்டு மதிப்பு';

  @override
  String get totalInvested => 'மொத்த முதலீடு';

  @override
  String get gainLoss => 'லாபம் / நஷ்டம்';

  @override
  String get deleteInvestmentConfirm => 'முதலீட்டை நீக்கலாமா?';

  @override
  String get deleteInvestmentBody =>
      'இது முதலீட்டு பதிவையும் அதன் அனைத்து பரிவர்த்தனைகளையும் நீக்கும்.';

  @override
  String get troubleshootTitle => 'பழுது நீக்குதல்';

  @override
  String get troubleshootDesc =>
      'தரவு முரண்பாடுகள் மற்றும் பரிந்துரை சிக்கல்களைச் சரிசெய்யவும்.';

  @override
  String get rebuildSuggestions => 'பரிந்துரைகளை மீண்டும் உருவாக்கு';

  @override
  String get rebuildSuggestionsDesc =>
      'உங்கள் வரலாற்றின் அடிப்படையில் பரிவர்த்தனை தானாக நிறைவு செய்யும் பரிந்துரைகளை மீண்டும் உருவாக்குகிறது.';

  @override
  String get suggestionsRebuilt =>
      'பரிந்துரைகள் வெற்றிகரமாக மீண்டும் உருவாக்கப்பட்டன';

  @override
  String get cleanOrphans => 'தனித்த தரவைச் சுத்தம் செய்';

  @override
  String get cleanOrphansDesc =>
      'நீக்கப்பட்ட வகைகள் அல்லது கணக்குகளுடன் இணைக்கப்பட்ட பரிவர்த்தனைகளை நீக்குகிறது.';

  @override
  String get orphansCleaned => 'தனித்த தரவு சுத்தம் செய்யப்பட்டது';

  @override
  String get clearCache => 'செயலி கேச் சுத்தம் செய்';

  @override
  String get clearCacheDesc =>
      'தற்காலிக கோப்புகளை நீக்கி, உள் தரவுத்தள குறியீடுகளை மீண்டும் உருவாக்குகிறது.';

  @override
  String get cacheCleared => 'கேச் வெற்றிகரமாக சுத்தம் செய்யப்பட்டது';

  @override
  String get aboutKuberHeader => 'குபேர் பற்றி';

  @override
  String get aboutKuberDesc =>
      'குபேர் என்பது ஒரு அழகான, எளிமையான, ஆஃப்லைன்-முதன்மை தனிநபர் நிதி கண்காணிப்பான்.';

  @override
  String get privacyPromise => 'தனியுரிமை உறுதிமொழி';

  @override
  String get privacyPromiseDesc =>
      'உங்கள் தரவு உங்கள் சாதனத்தை விட்டு வெளியேறாது. பகுப்பாய்வு, கண்காணிப்பு அல்லது கிளவுட் ஒத்திசைவு இல்லை.';

  @override
  String get openSource => 'திறந்த மூல மென்பொருள் (ஓபன் சோர்ஸ்)';

  @override
  String get openSourceDesc =>
      'முக்கத் தொழில்நுட்பங்களில் உருவாக்கப்பட்டது, முற்றிலும் வெளிப்படையானது மற்றும் தணிக்கைக்கு உட்பட்டது.';

  @override
  String get developerNote => 'உருவாக்குநரின் குறிப்பு';

  @override
  String get developerNoteDesc =>
      'தனிநபர் நிதி கண்காணிப்பை எளிதாக்க குபேர் அன்போடு உருவாக்கப்பட்டது. இதைப் பயன்படுத்தியதற்கு நன்றி!';

  @override
  String get permissionsTitle => 'அனுமதிகள்';

  @override
  String get permissionsDesc =>
      'செயலி அணுகல் தேவைகள் மற்றும் பாதுகாப்பு வரம்புகள்.';

  @override
  String get storagePermission => 'ஸ்டோரேஜ் அணுகல்';

  @override
  String get storagePermissionDesc =>
      'இணைப்பு படங்கள், பிடிஎஃப்களைத் தேர்ந்தெடுக்கவும் உங்கள் சாதனத்தில் காப்புப்பிரதி கோப்புகளை எழுதவும் தேவை.';

  @override
  String get biometricPermission => 'பயோமெட்ரிக் அங்கீகாரம்';

  @override
  String get biometricPermissionDesc =>
      'விருப்பத்திற்குரியது. ஃபேஸ் ஐடி அல்லது கைரேகையைப் பயன்படுத்தி குபேரை பாதுகாப்பாகத் திறக்கப் பயன்படுகிறது.';

  @override
  String get networkPermission => 'நெட்வொர்க் அணுகல்';

  @override
  String get networkPermissionDesc =>
      'நாணய மாற்று விகிதங்களைப் பெற மட்டுமே பயன்படுத்தப்படுகிறது. செயலி 100% ஆஃப்லைனில் வேலை செய்கிறது.';

  @override
  String get feedbackTitle => 'கருத்து';

  @override
  String get feedbackDesc =>
      'சிக்கல்களைப் புகாரளிக்கவும், அம்சங்களைப் பரிந்துரைக்கவும் அல்லது வணக்கம் சொல்லவும்!';

  @override
  String get feedbackType => 'கருத்து வகை';

  @override
  String get feedbackTypeBug => 'பிழை அறிக்கை';

  @override
  String get feedbackTypeFeature => 'அம்ச கோரிக்கை';

  @override
  String get feedbackTypeOther => 'இதர';

  @override
  String get feedbackMessage => 'உங்கள் செய்தி';

  @override
  String get feedbackMessageHint =>
      'சிக்கல் அல்லது உங்கள் பரிந்துரையை விரிவாக விளக்கவும்...';

  @override
  String get submitFeedback => 'கருத்தை சமர்ப்பி';

  @override
  String get feedbackThankYou => 'உங்கள் கருத்துக்கு நன்றி!';

  @override
  String get feedbackMessageRequired =>
      'தயவுசெய்து முதலில் உங்கள் செய்தியை உள்ளிடவும்';

  @override
  String get dataManagementTitle => 'தரவு மேலாண்மை';

  @override
  String get dataManagementDesc =>
      'தரவை ஏற்றுமதி செய்யவும், இறக்குமதி செய்யவும் மற்றும் நிர்வகிக்கவும்.';

  @override
  String get exportData => 'தரவை ஏற்றுமதி செய்';

  @override
  String get exportDataDesc =>
      'அனைத்து பரிவர்த்தனைகள், கணக்குகள் மற்றும் அமைப்புகளை JSON கோப்பிற்கு ஏற்றுமதி செய்யவும்.';

  @override
  String get importData => 'தரவை இறக்குமதி செய்';

  @override
  String get importDataDesc =>
      'முன்பு ஏற்றுமதி செய்த JSON காப்புப்பிரதி கோப்பை இறக்குமதி செய்யவும்.';

  @override
  String get clearAllData => 'அனைத்து தரவையும் நீக்கு';

  @override
  String get clearAllDataDesc =>
      'இந்த சாதனத்திலிருந்து அனைத்து பரிவர்த்தனைகள், கணக்குகள் மற்றும் அமைப்புகளை நிரந்தரமாக நீக்கும். இதை மாற்ற முடியாது.';

  @override
  String get clearDataConfirm => 'அனைத்து தரவையும் நீக்கலாமா?';

  @override
  String get clearDataConfirmBody =>
      'இது உங்கள் அனைத்து பரிவர்த்தனைகள், கணக்குகள், பட்ஜெட்டுகள் மற்றும் அமைப்புகளை நிரந்தரமாக நீக்கும். இந்த நடவடிக்கை மாற்ற முடியாதது. உறுதிப்படுத்த DELETE என தட்டச்சு செய்யவும்.';

  @override
  String get backupTitle => 'காப்புப்பிரதி';

  @override
  String get backupDesc =>
      'கைமுறையாக காப்புப்பிரதி உருவாக்கவும் அல்லது தானியங்கி காப்புப்பிரதி அட்டவணையை அமைக்கவும்.';

  @override
  String get lentBorrowedTitle => 'கொடுத்தது &\nவாங்கியது';

  @override
  String get noLedgerEntries => 'இதுவரை லெட்ஜர் உள்ளீடுகள் இல்லை';

  @override
  String get ledgerEmptyDesc => 'கொடுக்கல் வாங்கலை பதிவு செய்ய + ஐ தட்டவும்';

  @override
  String get settledUpper => 'செட்டில் செய்யப்பட்டது';

  @override
  String get lentLabel => 'கடன் கொடுத்தது';

  @override
  String get borrowedLabel => 'கடன் வாங்கியது';

  @override
  String get editEntry => 'உள்ளீட்டை திருத்து';

  @override
  String get newEntry => 'புதிய உள்ளீடு';

  @override
  String get amountLent => 'கொடுத்த தொகை';

  @override
  String get amountBorrowed => 'வாங்கிய தொகை';

  @override
  String get personLabel => 'நபர்';

  @override
  String get whoHint => 'யார்?';

  @override
  String get fromAccountLabel => 'எந்த கணக்கிலிருந்து';

  @override
  String get toAccountLabel => 'எந்த கணக்கிற்கு';

  @override
  String get dateLabel => 'தேதி';

  @override
  String get lentOn => 'கொடுத்த தேதி';

  @override
  String get borrowedOn => 'வாங்கிய தேதி';

  @override
  String get expectedReturn => 'திரும்ப எதிர்பார்க்கும் தேதி';

  @override
  String get ledgerNotesHint => 'பின்னணி, IOU குறிப்பு, ஏதேனும்';

  @override
  String get addToLedger => 'லெட்ஜரில் சேர்';

  @override
  String get accountTitle => 'கணக்கு';

  @override
  String get expectedOn => 'எதிர்பார்க்கப்படும் தேதி';

  @override
  String get lentTransaction => 'கடன் கொடுத்த பரிவர்த்தனை';

  @override
  String get borrowedTransaction => 'கடன் வாங்கிய பரிவர்த்தனை';

  @override
  String get addPayment => 'பேமெண்ட்டைச் சேர்';

  @override
  String get markSettled => 'செட்டில் ஆனதாக குறி';

  @override
  String get repaymentProgress => 'திருப்பிச் செலுத்தும் நிலை';

  @override
  String get dueDate => 'கெடு தேதி';

  @override
  String get markSettledConfirm => 'செட்டில் ஆனதாக குறிக்கவா?';

  @override
  String get markSettledBody =>
      'இது மீதமுள்ள தொகையை ஒரு பேமெண்ட்டாகப் பதிவுசெய்து, இந்த உள்ளீட்டை செட்டில் ஆனதாகக் குறிக்கும்.';

  @override
  String get settleLabel => 'செட்டில் செய்';

  @override
  String get deleteLedgerConfirm => 'லெட்ஜர் உள்ளீட்டை நீக்கவா?';

  @override
  String get deleteLedgerBody =>
      'இது இந்த உள்ளீட்டையும் இணைக்கப்பட்ட அனைத்து பரிவர்த்தனைகளையும் நீக்கும். இதை மாற்ற முடியாது.';

  @override
  String get paymentReceived => 'பேமெண்ட் பெறப்பட்டது';

  @override
  String get paymentMade => 'பேமெண்ட் செய்யப்பட்டது';

  @override
  String get recordPayment => 'பேமெண்ட்டை பதிவு செய்';

  @override
  String get recordPaymentUpper => 'பேமெண்ட்டை பதிவு செய்';

  @override
  String get netPosition => 'நிகர நிலை';

  @override
  String get youWillReceive => 'நீங்கள் பெறுவீர்கள்';

  @override
  String get youOwe => 'நீங்கள் தர வேண்டியது';

  @override
  String get noDueDate => 'கெடு தேதி இல்லை';

  @override
  String get lentUpper => 'கடன் கொடுத்தது';

  @override
  String get borrowedUpper => 'கடன் வாங்கியது';

  @override
  String ledgerDuplicateWarningLent(String person) {
    return '$person என்பவருக்கு ஏற்கனவே ஒரு ஆக்டிவான கடன் கொடுத்த உள்ளீடு உள்ளது. நிச்சயமாக புதிய ஒன்றை உருவாக்க வேண்டுமா?';
  }

  @override
  String ledgerDuplicateWarningBorrow(String person) {
    return '$person என்பவரிடம் ஏற்கனவே கடன் வாங்கிய ஒரு ஆக்டிவான உள்ளீடு உள்ளது. நிச்சயமாக புதிய ஒன்றை உருவாக்க வேண்டுமா?';
  }

  @override
  String get ledgerEvensOut => 'சரியாகிவிட்டது';

  @override
  String get ledgerInYourFavour => 'உங்களுக்கு சாதகமாக';

  @override
  String get ledgerOwedToOthers => 'மற்றவர்களுக்கு தர வேண்டியது';

  @override
  String ledgerActiveEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ஆக்டிவ் உள்ளீடுகள்',
      one: '1 ஆக்டிவ் உள்ளீடு',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNoOne => 'யாருமில்லை';

  @override
  String ledgerAcrossPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நபர்களிடம்',
      one: '1 நபரிடம்',
    );
    return '$_temp0';
  }

  @override
  String settledOnUpper(String date) {
    return '$date அன்று செட்டில் செய்யப்பட்டது';
  }

  @override
  String dueOnUpper(String date) {
    return 'கெடு தேதி $date';
  }

  @override
  String get overdueLower => 'காலக்கெடு முடிந்தது';

  @override
  String pctReceived(String pct) {
    return '$pct% பெறப்பட்டது';
  }

  @override
  String pctPaidBack(String pct) {
    return '$pct% திருப்பிக் கொடுக்கப்பட்டது';
  }

  @override
  String amountRemaining(String amount) {
    return '$amount மீதமுள்ளது';
  }

  @override
  String errorWithDetails(String details) {
    return 'பிழை: $details';
  }

  @override
  String get notSetTapToAdd => 'அமைக்கப்படவில்லை · சேர்க்க தட்டவும்';

  @override
  String inDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: '1 நாளில்',
    );
    return '$_temp0';
  }

  @override
  String createdOnUpper(String date) {
    return '$date அன்று உருவாக்கப்பட்டது';
  }

  @override
  String get noInvestments => 'முதலீடுகள் ஏதும் கண்காணிக்கப்படவில்லை';

  @override
  String get investmentsEmptyDesc =>
      'உங்கள் முதல் முதலீட்டைச் சேர்க்க + ஐ தட்டவும்';

  @override
  String get allInvestmentsUpper => 'அனைத்து முதலீடுகளும்';

  @override
  String get invTypeSip => 'SIP';

  @override
  String get invTypeMutualFund => 'மியூச்சுவல் ஃபண்ட்';

  @override
  String get invTypeStocks => 'பங்குகள்';

  @override
  String get invTypeGold => 'தங்கம்';

  @override
  String get invTypeFd => 'FD';

  @override
  String get invTypeRd => 'RD';

  @override
  String get invTypeCrypto => 'கிரிப்டோ';

  @override
  String get invTypeTrading => 'டிரேடிங்';

  @override
  String get invTypeRealEstate => 'ரியல் எஸ்டேட்';

  @override
  String get invTypeEtf => 'ETF';

  @override
  String get invTypeBonds => 'பத்திரங்கள்';

  @override
  String get invTypeCollectible => 'சேகரிப்புப் பொருள்';

  @override
  String get invTypeOther => 'மற்றவை';

  @override
  String get editInvestment => 'முதலீட்டைத் திருத்து';

  @override
  String get newInvestment => 'புதிய முதலீடு';

  @override
  String get investmentName => 'முதலீட்டின் பெயர்';

  @override
  String get valueLabel => 'மதிப்பு';

  @override
  String get totalInvestedInclNew => 'மொத்த முதலீடு (புதிய பங்களிப்பு உட்பட)';

  @override
  String get investedAmountInitial => 'முதலீடு செய்த தொகை (தொடக்க)';

  @override
  String get autoDebitSip => 'ஆட்டோ-டெபிட் SIP';

  @override
  String get enableAutoDebitSip => 'ஆட்டோ-டெபிட் SIP ஐ இயக்கு';

  @override
  String get automateMonthlyContrib =>
      'உங்கள் மாதாந்திரப் பங்களிப்பை ஆட்டோமேட் செய்யுங்கள்';

  @override
  String get monthlySipAmount => 'மாதாந்திர SIP தொகை';

  @override
  String get sipDate => 'SIP தேதி';

  @override
  String get debitedFrom => 'இங்கிருந்து எடுக்கப்படும்';

  @override
  String get optionalContext => 'விருப்பப் பின்னணி';

  @override
  String get addContribution => 'பங்களிப்பைச் சேர்';

  @override
  String get updateValue => 'மதிப்பைப் புதுப்பி';

  @override
  String get investedUpper => 'முதலீடு செய்யப்பட்டது';

  @override
  String get currentUpper => 'தற்போதைய';

  @override
  String get gainLossUpper => 'லாபம்/நஷ்டம்';

  @override
  String get sipConfiguration => 'SIP உள்ளமைவு';

  @override
  String get monthlySip => 'மாதாந்திர SIP';

  @override
  String get strategyNotes => 'வியூகக் குறிப்புகள்';

  @override
  String get contributionHistory => 'பங்களிப்பு வரலாறு';

  @override
  String get noContributions => 'பங்களிப்புகள் ஏதும் பதிவு செய்யப்படவில்லை';

  @override
  String get updateCurrentValue => 'தற்போதைய மதிப்பைப் புதுப்பி';

  @override
  String get updateLabel => 'புதுப்பி';

  @override
  String get contributionLabel => 'பங்களிப்பு';

  @override
  String get recordContributionUpper => 'பங்களிப்பைப் பதிவு செய்';

  @override
  String get noteOptionalUpper => 'குறிப்பு (விருப்பத்திற்குரியது)';

  @override
  String get assetAllocation => 'சொத்து ஒதுக்கீடு';

  @override
  String get investmentNameHint => 'எ.கா. Nifty 50 Index Fund';

  @override
  String sipAmountPrefix(String amount) {
    return 'SIP $amount';
  }

  @override
  String monthlySipValue(String amount, String day) {
    return '$day ஆம் தேதி $amount';
  }

  @override
  String get addRecurring => 'ரெக்கரிங்கைச் சேர்';

  @override
  String get noRecurring => 'ரெக்கரிங் பரிவர்த்தனைகள் ஏதுமில்லை';

  @override
  String get recurringEmptyDesc =>
      'சந்தாக்கள் மற்றும் மீண்டும் மீண்டும் செய்யப்படும் பேமெண்ட்டுகளை ஆட்டோமேட் செய்யுங்கள்';

  @override
  String get rulesUpper => 'விதிகள்';

  @override
  String get recentlyProcessed => 'சமீபத்தில் பிராசஸ் செய்யப்பட்டவை';

  @override
  String get freqDaily => 'தினமும்';

  @override
  String get freqWeekly => 'வாரம் தோறும்';

  @override
  String get freqBiweekly => 'இரண்டு வாரங்களுக்கு ஒருமுறை';

  @override
  String get freqMonthly => 'மாதாந்திரம்';

  @override
  String get freqQuarterly => 'காலாண்டுக்கு ஒருமுறை';

  @override
  String get freqYearly => 'வருடாந்திரம்';

  @override
  String get freqCustom => 'பிரத்தியேகமாக';

  @override
  String get editRecurring => 'ரெக்கரிங்கைத் திருத்து';

  @override
  String get newRecurring => 'புதிய ரெக்கரிங்';

  @override
  String get transactionLabel => 'பரிவர்த்தனை';

  @override
  String get amountTitle => 'தொகை';

  @override
  String get recurringNameHint => 'பெயர் (எ.கா. Netflix, வாடகை)';

  @override
  String get whereLabel => 'எங்கே';

  @override
  String get scheduleSublabel => 'இந்த பரிவர்த்தனை எப்போது திரும்ப நிகழும்';

  @override
  String get frequencyLabel => 'அதிர்வெண்';

  @override
  String get everyLabel => 'ஒவ்வொரு';

  @override
  String get daysLabel => 'நாட்கள்';

  @override
  String get startsOn => 'தொடங்கும் தேதி';

  @override
  String get startDate => 'தொடங்கும் தேதி';

  @override
  String get endsLabel => 'முடிவடைகிறது';

  @override
  String get neverLabel => 'எப்போதும் இல்லை';

  @override
  String get afterN => 'N-க்கு பிறகு';

  @override
  String get onDate => 'இந்த தேதியில்';

  @override
  String get afterLabel => 'பிறகு';

  @override
  String get occurrencesLabel => 'நிகழ்வுகள்';

  @override
  String get endDate => 'முடிவடையும் தேதி';

  @override
  String get recurringNotesHint =>
      'விருப்பப் பின்னணி · சூழல், குறிப்பு, ஏதேனும்';

  @override
  String get saveRecurring => 'ரெக்கரிங்கைச் சேமி';

  @override
  String get nextOccurrenceLabel => 'அடுத்த நிகழ்வு';

  @override
  String get cadenceDaily => 'பிறகு ஒவ்வொரு நாளும்';

  @override
  String get cadenceWeekly => 'பிறகு ஒவ்வொரு வாரமும்';

  @override
  String get cadenceBiweekly => 'பிறகு ஒவ்வொரு 2 வாரங்களுக்கும்';

  @override
  String get cadenceMonthly => 'பிறகு ஒவ்வொரு மாதமும்';

  @override
  String get cadenceYearly => 'பிறகு ஒவ்வொரு வருடமும்';

  @override
  String get cadenceCustom => 'பிறகு ஒவ்வொரு பிரத்தியேக இடைவெளியிலும்';

  @override
  String get activeUpper => 'ஆக்டிவ்';

  @override
  String get activeCustomUpper => 'ஆக்டிவ் • கஸ்டம்';

  @override
  String get pausedUpper => 'இடைநிறுத்தப்பட்டது';

  @override
  String freqEveryNDays(String count) {
    return 'ஒவ்வொரு $count நாட்களுக்கும்';
  }

  @override
  String recurringAmountLabel(String type) {
    return 'ரெக்கரிங் $type தொகை';
  }

  @override
  String get frequencyUpper => 'அதிர்வெண்';

  @override
  String get deleteAutomationConfirm => 'ஆட்டோமேஷனை நீக்கவா?';

  @override
  String deleteAutomationBody(String name) {
    return '\"$name\" க்கான ரெக்கரிங் விதி நிரந்தரமாக நீக்கப்படும்.';
  }

  @override
  String get monthlyAutomationCost => 'மாதாந்திர ஆட்டோமேஷன் செலவு';

  @override
  String get upcomingCharges => 'வரவிருக்கும் கட்டணங்கள்';

  @override
  String get todayUpper => 'இன்று';

  @override
  String get tomorrowUpper => 'நாளை';

  @override
  String get yesterdayUpper => 'நேற்று';

  @override
  String inDaysUpper(String count) {
    return '$count நாட்களில்';
  }

  @override
  String get nextChargeLabel => 'அடுத்த கட்டணம்';

  @override
  String get backingUpAuto => 'தானாகவே பேக்கப் எடுக்கப்படுகிறது';

  @override
  String get processingRecurring => 'ரெக்கரிங் பிராசஸ் செய்யப்படுகிறது';

  @override
  String get savingCopyToFolder =>
      'நீங்கள் தேர்ந்தெடுத்த ஃபோல்டரில் ஒரு நகல் சேமிக்கப்படுகிறது.';

  @override
  String get creatingMissedTxns =>
      'தவறவிடப்பட்ட பரிவர்த்தனைகள் உருவாக்கப்படுகின்றன.';

  @override
  String get folderUpper => 'ஃபோல்டர்';

  @override
  String get processedUpper => 'பிராசஸ் செய்யப்பட்டது';

  @override
  String get selectedLabel => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String nTransactions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பரிவர்த்தனைகள்',
      one: '1 பரிவர்த்தனை',
    );
    return '$_temp0';
  }

  @override
  String get networkUpper => 'நெட்வொர்க்';

  @override
  String get localOnly => 'லோக்கல் மட்டுமே';

  @override
  String get transactionHistory => 'பரிவர்த்தனை வரலாறு';

  @override
  String errorLoadingHistory(String details) {
    return 'வரலாற்றை ஏற்றுவதில் பிழை: $details';
  }

  @override
  String get recurringHistoryEmptyDesc =>
      'இந்த ஆட்டோமேஷன் மூலம் உருவாக்கப்படும் பரிவர்த்தனைகள் இங்கே தோன்றும்.';

  @override
  String get todayLower => 'இன்று';

  @override
  String get tomorrowLower => 'நாளை';

  @override
  String get betaBadge => 'பீட்டா';

  @override
  String get noCategories => 'இன்னும் பிரிவுகள் இல்லை';

  @override
  String get categoriesEmptyDesc =>
      'உங்கள் செலவுகளை ஒழுங்கமைக்க பிரிவுகளை உருவாக்கவும்';

  @override
  String get addCategory => 'பிரிவைச் சேர்';

  @override
  String get searchCategoriesHint =>
      'பிரிவுகள் மற்றும் குழுக்களைத் தேடுங்கள்...';

  @override
  String get addNew => 'புதிதாகச் சேர்';

  @override
  String get addCategoryDesc =>
      'சிறந்த கண்காணிப்புக்காக உங்கள் பரிவர்த்தனைகளை வகைப்படுத்தவும்';

  @override
  String get addGroup => 'குழுவைச் சேர்';

  @override
  String get editGroup => 'குழுவைத் திருத்து';

  @override
  String get categoryGroupSubtitle => 'பிரிவு குழு';

  @override
  String get groupNameHint => 'குழுவின் பெயர் (உ-ம்: உணவு, போக்குவரத்து)';

  @override
  String get deleteGroupConfirm => 'குழுவை நீக்கவா?';

  @override
  String deleteGroupBody(String name) {
    return '\"$name\" இல் உள்ள பிரிவுகள் \"குழுவாக்கப்படாதவை\" பகுதிக்கு நகர்த்தப்படும்.';
  }

  @override
  String get categoryDetail => 'பிரிவின் விவரம்';

  @override
  String get groupUpper => 'குழு';

  @override
  String get typeUpper => 'வகை';

  @override
  String get incomeAndExpense => 'வருமானம் & செலவு';

  @override
  String get cannotDeleteCategory => 'பிரிவை நீக்க முடியாது';

  @override
  String get cannotDeleteCategoryBody =>
      'இந்தப் பிரிவுடன் பரிவர்த்தனைகள் இணைக்கப்பட்டுள்ளன. இந்தப் பிரிவை நீக்க, முதலில் இணைக்கப்பட்ட பரிவர்த்தனைகளை நீக்கவும்.';

  @override
  String get editCategory => 'பிரிவைத் திருத்து';

  @override
  String get newCategory => 'புதிய பிரிவு';

  @override
  String get optionalLabel => 'விருப்பத்திற்குரியது';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get bothLabel => 'இரண்டும்';

  @override
  String get saveCategory => 'பிரிவைச் சேமி';

  @override
  String get categoryUpdated => 'பிரிவு புதுப்பிக்கப்பட்டது';

  @override
  String get categoryAdded => 'பிரிவு சேர்க்கப்பட்டது';

  @override
  String get categoryNameLabel => 'பிரிவின் பெயர்';

  @override
  String get livePreview => 'நேரடி முன்னோட்டம்';

  @override
  String get selectGroup => 'குழுவைத் தேர்ந்தெடு';

  @override
  String get groupNameShortHint => 'குழுவின் பெயர்...';

  @override
  String get addNewGroup => 'புதிய குழுவைச் சேர்';

  @override
  String get noBudgetSet => 'பட்ஜெட் அமைக்கப்படவில்லை';

  @override
  String get categoriesTitle => 'பிரிவுகளை\nநிர்வகி';

  @override
  String noCategoryMatches(String query) {
    return '\"$query\" உடன் எந்தப் பிரிவுகளும் அல்லது குழுக்களும் பொருந்தவில்லை.';
  }

  @override
  String get deleteCategoryConfirm => 'பிரிவை நீக்கவா?';

  @override
  String deleteCategoryBody(String name) {
    return '\"$name\" நிரந்தரமாக நீக்கப்படும்.';
  }

  @override
  String get categoryNameHint => 'உ-ம்: மளிகை, வாடகை, சம்பளம்';

  @override
  String get tagsTitle => 'டேக்-களை\nநிர்வகி';

  @override
  String get tagsHeaderDesc =>
      'தனிப்பயன் லேபிள்களுடன் பரிவர்த்தனைகளை ஒழுங்கமைக்கவும்.';

  @override
  String get addTag => 'டேக்-ஐச் சேர்';

  @override
  String get noTags => 'இன்னும் டேக்-கள் இல்லை';

  @override
  String get tagsEmptyDesc =>
      'குறிப்பிட்ட செலவுகளைக் கண்காணிக்க ஹேஷ்டேக்குகளை உருவாக்கவும்.';

  @override
  String get disabledLabel => 'முடக்கப்பட்டது';

  @override
  String get noTransactions => 'பரிவர்த்தனைகள் இல்லை';

  @override
  String get newTag => 'புதிய டேக்';

  @override
  String get updateTag => 'டேக்-ஐப் புதுப்பி';

  @override
  String get createTag => 'டேக்-ஐ உருவாக்கு';

  @override
  String get enableLabel => 'இயக்கு';

  @override
  String get disableLabel => 'முடக்கு';

  @override
  String get deleteTagConfirm => 'டேக்-ஐ நீக்கவா?';

  @override
  String deleteTagBody(String name) {
    return '\"#$name\" டேக் நிரந்தரமாக நீக்கப்படும்.';
  }

  @override
  String get selectTags => 'டேக்-களைத் தேர்ந்தெடு';

  @override
  String get tagNameHint => 'உ-ம்: வாரஇறுதி, கோவா-பயணம்';

  @override
  String get searchOrCreateTagHint =>
      'தேடுங்கள் அல்லது டேக்-ஐ உருவாக்குங்கள்...';

  @override
  String get tagDisabledMessage =>
      'டேக் முடக்கப்பட்டுள்ளது. மேலும் → டேக்-களில் இருந்து இதை இயக்கவும்.';

  @override
  String get exportHistory => 'வரலாற்றை ஏற்றுமதி செய்';

  @override
  String get exportAnalytics => 'பகுப்பாய்வுகளை ஏற்றுமதி செய்';

  @override
  String get selectFormat => 'வடிவமைப்பைத் தேர்ந்தெடு';

  @override
  String get formatUpper => 'வடிவமைப்பு';

  @override
  String get spreadsheetLabel => 'விரிதாள்';

  @override
  String get documentLabel => 'ஆவணம்';

  @override
  String get pdfDocument => 'PDF ஆவணம்';

  @override
  String get pdfDocumentDesc => 'உயர்தர அச்சிடலுக்கான உலகளாவிய வடிவமைப்பு.';

  @override
  String get generateReport => 'அறிக்கையை உருவாக்கு';

  @override
  String get applyCurrentFilters => 'தற்போதைய ஃபில்டர்களைப் பயன்படுத்து';

  @override
  String get applyFiltersDesc =>
      'வரலாற்றுப் பக்கத்தில் உள்ள செயலில் உள்ள ஃபில்டர்களைப் பயன்படுத்தி அறிக்கையை உருவாக்கவும்.';

  @override
  String get periodAllTime => 'எல்லா நேரமும்';

  @override
  String get selectedPeriod => 'தேர்ந்தெடுக்கப்பட்ட காலம்';

  @override
  String get analyticsDateFilterInfo =>
      'உங்கள் தற்போதைய பகுப்பாய்வுப் பார்வையில் உள்ள தேதி ஃபில்டர்கள் இந்த அறிக்கையில் தானாகவே பயன்படுத்தப்படும்.';

  @override
  String get exportSuccessful => 'ஏற்றுமதி வெற்றிகரமாக முடிந்தது';

  @override
  String get reportReady => 'உங்கள் அறிக்கை தயாராக உள்ளது.';

  @override
  String get openFile => 'கோப்பைத் திற';

  @override
  String get savingEllipsis => 'சேமிக்கப்படுகிறது...';

  @override
  String get saveToFolder => 'கோப்புறையில் சேமி';

  @override
  String get shareLabel => 'பகிர்';

  @override
  String get noAppToOpen => 'இந்தக் கோப்பு வகையைத் திறக்க எந்த ஆப்ஸும் இல்லை.';

  @override
  String get fileSaved => 'கோப்பு வெற்றிகரமாகச் சேமிக்கப்பட்டது.';

  @override
  String couldNotShareFile(String details) {
    return 'கோப்பைப் பகிர முடியவில்லை: $details';
  }

  @override
  String get exportFailed => 'ஏற்றுமதி தோல்வியடைந்தது';

  @override
  String get tryAgain => 'மீண்டும் முயல்க';

  @override
  String get exportGenerateFailed =>
      'கோப்பை உருவாக்க முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get failedToSaveFile => 'கோப்பைச் சேமிக்க முடியவில்லை.';

  @override
  String get chartsTitle => 'விளக்கப்படங்கள்';

  @override
  String get chartsSubtitle =>
      'காலப்போக்கில் உங்கள் செலவு முறைகளைக் காட்சிப்படுத்துங்கள்.';

  @override
  String get wipBadge => 'WIP';

  @override
  String get failedToLoadData => 'தரவை ஏற்ற முடியவில்லை';

  @override
  String get noDataForPeriod => 'இந்தக் காலத்திற்கான தரவு இல்லை';

  @override
  String get tapBarForDetails => 'விவரங்களைக் காண ஒரு பட்டியைத் தட்டவும்';

  @override
  String get incomeUpper => 'வருமானம்';

  @override
  String get expenseUpper => 'செலவு';

  @override
  String get netUpper => 'நிகரம்';

  @override
  String get noExpenseBreakdown => 'செலவு விவரங்கள் எதுவும் இல்லை.';

  @override
  String get byCategoryUpper => 'பிரிவு வாரியாக';

  @override
  String get faqTitle => 'அடிக்கடி கேட்கப்படும் கேள்விகள்';

  @override
  String get faqAddTxnQ => 'பரிவர்த்தனையை எவ்வாறு சேர்ப்பது?';

  @override
  String get faqAddTxnA =>
      'புதிய பரிவர்த்தனையைச் சேர்க்க, கீழ் வலதுபுறத்தில் உள்ள + பொத்தானைத் தட்டவும். தொகையை நிரப்பி, பிரிவு மற்றும் கணக்கைத் தேர்ந்தெடுத்து சேமிக்கவும்.';

  @override
  String get faqAccountsQ => 'கணக்குகளை எவ்வாறு நிர்வகிப்பது?';

  @override
  String get faqAccountsA =>
      'உங்கள் எல்லா வேலட்கள் மற்றும் வங்கிக் கணக்குகளைப் பார்க்க, மேலும் → கணக்குகள் என்பதற்குச் செல்லவும். அங்கிருந்து புதிய கணக்குகளைச் சேர்க்கலாம் அல்லது இருப்பவற்றைத் திருத்தலாம்.';

  @override
  String get faqTransfersQ => 'பரிமாற்றங்கள் எவ்வாறு செயல்படுகின்றன?';

  @override
  String get faqTransfersA =>
      'பரிவர்த்தனையைச் சேர்க்கும்போது, வகையாக \"பரிமாற்றம்\" என்பதைத் தேர்ந்தெடுக்கவும். மூல மற்றும் இலக்குக் கணக்குகளைத் தேர்ந்தெடுக்கவும், அவற்றுக்கிடையே தொகை மாற்றப்படும்.';

  @override
  String get faqCategoriesQ => 'பிரிவுகளை நான் தனிப்பயனாக்க முடியுமா?';

  @override
  String get faqCategoriesA =>
      'ஆம்! அனைத்துப் பிரிவுகளையும் பார்க்க மேலும் → பிரிவுகள் என்பதற்குச் செல்லவும். இயல்புநிலைப் பிரிவுகளை நீக்க முடியாது, ஆனால் உங்கள் சொந்த தனிப்பயன் பிரிவுகளைச் சேர்க்கலாம்.';

  @override
  String get dataExportTitle => 'தரவை ஏற்றுமதி செய்';

  @override
  String get backupUpper => 'காப்புப்பிரதி';

  @override
  String get exportCsvDesc =>
      'பரிவர்த்தனைகள், பிரிவுகள், கணக்குகள் மற்றும் டேக்-களை ஏற்றுமதி செய்கிறது. தொடர்ச்சியான ஆட்டோமேஷன்கள், பட்ஜெட்டுகள், கடன்கள், முதலீடுகள் அல்லது இணைப்புகளை உள்ளடக்கவில்லை.';

  @override
  String get exportJsonDesc =>
      'முழுமையான ஆப்ஸ் காப்புப்பிரதி (இணைப்புகள் தவிர). புதிய சாதனத்தில் அல்லது மீண்டும் நிறுவிய பின் உங்கள் எல்லா தரவையும் மீட்டெடுக்க இதைப் பயன்படுத்தலாம்.';

  @override
  String get fileReady => 'உங்கள் கோப்பு தயாராக உள்ளது.';

  @override
  String get saveACopy => 'நகலைச் சேமி';

  @override
  String get dataImportTitle => 'தரவை இறக்குமதி செய்';

  @override
  String get selectFileImport => 'கோப்பைத் தேர்ந்தெடுத்து இறக்குமதி செய்';

  @override
  String get overrideExistingData => 'தற்போதுள்ள தரவை மேலெழுது';

  @override
  String get importWipeDesc =>
      'இறக்குமதி செய்வதற்கு முன் தற்போதுள்ள அனைத்து தரவும் அழிக்கப்படும்.';

  @override
  String get importMergeDesc =>
      'புதிய பதிவுகள் தற்போதுள்ள தரவுகளுடன் இணைக்கப்படும்.';

  @override
  String get importWipeWarning =>
      'இறக்குமதி செய்வதற்கு முன் தற்போதுள்ள அனைத்து தரவும் நிரந்தரமாக நீக்கப்படும்.';

  @override
  String get importMergeChip =>
      'புதிய பதிவுகள் உங்கள் தற்போதைய தரவுகளுடன் இணைக்கப்படும்.';

  @override
  String get importReplaceWarning =>
      'தற்போதுள்ள அனைத்து தரவும் நிரந்தரமாக நீக்கப்பட்டு காப்புப்பிரதியுடன் மாற்றப்படும்.';

  @override
  String get downloadTemplate => 'டெம்ப்ளேட்டைப் பதிவிறக்கு';

  @override
  String get downloadTemplateDesc =>
      'உங்கள் தரவை வடிவமைக்க சரியான நெடுவரிசைத் தலைப்புகளுடன் கூடிய CSV-ஐப் பெறுங்கள்.';

  @override
  String get backupsTitle => 'தானியங்கி\nகாப்புப்பிரதிகள்';

  @override
  String get backupsSubtitle =>
      'ஒரு அட்டவணையில், உங்கள் சாதனத்தில் சேமிக்கப்பட்ட உங்கள் தரவின் புதிய நகலை வைத்திருக்கவும்.';

  @override
  String get statusSectionLabel => 'நிலை';

  @override
  String get configurationLabel => 'கட்டமைப்பு';

  @override
  String get actionsLabel => 'செயல்கள்';

  @override
  String get backupNow => 'இப்போது காப்புப்பிரதி எடு';

  @override
  String get alreadyBackedUpToday =>
      'இன்று ஏற்கனவே காப்புப்பிரதி எடுக்கப்பட்டது';

  @override
  String get lastBackupFailed => 'கடைசி காப்புப்பிரதி தோல்வியடைந்தது';

  @override
  String get backupFolderErrorDesc =>
      'உங்கள் காப்புப் கோப்புறையை எங்களால் அணுக முடியவில்லை. அது நகர்த்தப்பட்டிருக்கலாம் அல்லது அனுமதி ரத்து செய்யப்பட்டிருக்கலாம்.';

  @override
  String attemptedOn(String label) {
    return '$label அன்று முயற்சிக்கப்பட்டது';
  }

  @override
  String get chooseNewFolder => 'புதிய கோப்புறையைத் தேர்ந்தெடு';

  @override
  String get backedUp => 'காப்புப்பிரதி எடுக்கப்பட்டது';

  @override
  String backedUpOn(String label) {
    return '$label அன்று காப்புப்பிரதி எடுக்கப்பட்டது';
  }

  @override
  String lastCopySaved(String count) {
    return 'கடைசி நகல் வெற்றிகரமாகச் சேமிக்கப்பட்டது. உங்கள் மிகச் சமீபத்திய $count காப்புப்பிரதிகள் வைக்கப்பட்டுள்ளன.';
  }

  @override
  String get neverLoseData => 'உங்கள் தரவை ஒருபோதும் இழக்காதீர்கள்';

  @override
  String get neverLoseDataDesc =>
      'தானியங்கி காப்புப்பிரதிகளை இயக்கவும், நீங்கள் தேர்ந்தெடுக்கும் கோப்புறையில் Kuber ஒரு நகலைச் சேமிக்கும்.';

  @override
  String get automaticBackups => 'தானியங்கி காப்புப்பிரதிகள்';

  @override
  String get saveCopyOnSchedule => 'அட்டவணையில் ஒரு நகலைச் சேமி';

  @override
  String get keepLast => 'கடைசியாக வைத்திரு';

  @override
  String get backupFolder => 'காப்புப் கோப்புறை';

  @override
  String get exportingData => 'தரவு ஏற்றுமதி செய்யப்படுகிறது...';

  @override
  String get preparingFile => 'உங்கள் கோப்பு தயாராகிறது';

  @override
  String get dataExportedSuccess => 'தரவு வெற்றிகரமாக ஏற்றுமதி செய்யப்பட்டது';

  @override
  String get exportComplete => 'ஏற்றுமதி முடிந்தது';

  @override
  String savedToDownloads(String fileName) {
    return 'Downloads/$fileName இல் சேமிக்கப்பட்டது';
  }

  @override
  String exportFailedMsg(String error) {
    return 'ஏற்றுமதி தோல்வியடைந்தது: $error';
  }

  @override
  String get downloadingTemplate => 'டெம்ப்ளேட் பதிவிறக்கப்படுகிறது...';

  @override
  String get preparingCsvTemplate => 'CSV டெம்ப்ளேட் தயாராகிறது';

  @override
  String get templateDownloadedSuccess =>
      'டெம்ப்ளேட் வெற்றிகரமாகப் பதிவிறக்கப்பட்டது';

  @override
  String get downloadComplete => 'பதிவிறக்கம் முடிந்தது';

  @override
  String downloadFailedMsg(String error) {
    return 'பதிவிறக்கம் தோல்வியடைந்தது: $error';
  }

  @override
  String get downloadFailedTitle => 'பதிவிறக்கம் தோல்வியடைந்தது';

  @override
  String importFailedMsg(String error) {
    return 'இறக்குமதி தோல்வியடைந்தது: $error';
  }

  @override
  String get mockDataGenerated => 'போலி தரவு வெற்றிகரமாக உருவாக்கப்பட்டது';

  @override
  String generationFailedMsg(String error) {
    return 'உருவாக்கம் தோல்வியடைந்தது: $error';
  }

  @override
  String get allDataCleared => 'அனைத்து தரவும் வெற்றிகரமாக அழிக்கப்பட்டது';

  @override
  String clearFailedMsg(String error) {
    return 'அழித்தல் தோல்வியடைந்தது: $error';
  }

  @override
  String rebuildFailedMsg(String error) {
    return 'மறுகட்டமைப்பு தோல்வியடைந்தது: $error';
  }

  @override
  String notifNewRecurring(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count தொடர் பரிவர்த்தனைகள் சேர்க்கப்பட்டன',
      one: 'புதிய தொடர் பரிவர்த்தனை',
    );
    return '$_temp0';
  }

  @override
  String notifRecurringBody(String name) {
    return '$name - நீங்கள் இல்லாத போது சேர்க்கப்பட்டது';
  }

  @override
  String get notifLoanEmiTitle => 'கடன் EMI கழிக்கப்பட்டது';

  @override
  String notifLoanEmiBody(String name) {
    return '$name - உங்கள் பரிவர்த்தனைகளில் EMI சேர்க்கப்பட்டது';
  }

  @override
  String get notifInvestmentTitle => 'முதலீட்டு பங்களிப்பு சேர்க்கப்பட்டது';

  @override
  String notifInvestmentBody(String name) {
    return '$name - SIP பங்களிப்பு பதிவு செய்யப்பட்டது';
  }

  @override
  String get notifMoneyToCollect => 'வசூலிக்க வேண்டிய பணம்';

  @override
  String get notifMoneyToRepay => 'திருப்பிச் செலுத்த வேண்டிய பணம்';

  @override
  String notifLedgerReminderBody(String person, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$person - $count நாட்கள் தாமதம்',
      one: '$person - 1 நாள் தாமதம்',
      zero: '$person - இன்று செலுத்த வேண்டும்',
    );
    return '$_temp0';
  }

  @override
  String get notifBudgetAlertTitle => 'பட்ஜெட் எச்சரிக்கை';

  @override
  String notifBudgetReachedBody(String pct, String category) {
    return 'உங்கள் $category பட்ஜெட்டில் $pct% ஐ அடைந்துவிட்டீர்கள்';
  }

  @override
  String notifBudgetSpentBody(String amount, String category) {
    return '$category பிரிவில் $amount செலவிட்டுள்ளீர்கள்';
  }

  @override
  String get wgtBalanceHeroName => 'பேலன்ஸ் கார்டு';

  @override
  String get wgtBalanceHeroDesc =>
      'வருமானம் / செலவு பிரிப்புடன் நடப்பு மாத நிகர தொகை';

  @override
  String get wgtInsightStoriesName => 'பணக் கதைகள்';

  @override
  String get wgtInsightStoriesDesc =>
      'உங்கள் பணத்தைப் பற்றிய சுருக்கங்கள் மற்றும் முக்கிய அம்சங்கள்';

  @override
  String get wgtQuickAddName => 'விரைவில் சேர்';

  @override
  String get wgtQuickAddDesc =>
      'ஒரே தட்டலில் செலவு / வருமானம் / பரிமாற்றப் பதிவு';

  @override
  String get wgtSpendingStatsName => 'செலவுப் புள்ளிவிவரங்கள்';

  @override
  String get wgtSpendingStatsDesc => 'இந்த மாதத்தில் செலவழித்தது vs பெற்றது';

  @override
  String get wgtHomeAccountsName => 'வங்கிக் கணக்குகள்';

  @override
  String get wgtHomeAccountsDesc => 'அனைத்துக் கணக்குகள் மற்றும் நிலுவைகள்';

  @override
  String get wgtSevenDayChartName => 'கடந்த 7 நாட்களின் சார்ட்';

  @override
  String get wgtSevenDayChartDesc => 'கடந்த வாரத்தின் தினசரி வருமானம் vs செலவு';

  @override
  String get wgtBudgetSnapshotName => 'பட்ஜெட் ஸ்னாப்ஷாட்';

  @override
  String get wgtBudgetSnapshotDesc =>
      'செயலில் உள்ள பட்ஜெட்டுகளுக்கு எதிரான முன்னேற்றம்';

  @override
  String get wgtUpcomingRecurringName => 'வரவிருக்கும் தொடர் பரிவர்த்தனைகள்';

  @override
  String get wgtUpcomingRecurringDesc =>
      'அடுத்து செலுத்த வேண்டிய தொடர் பரிவர்த்தனைகள்';

  @override
  String get wgtRecentTransactionsName => 'சமீபத்திய பரிவர்த்தனைகள்';

  @override
  String get wgtRecentTransactionsDesc =>
      'சமீபத்திய செயல்பாடுகள் ஒரு பார்வையில்';

  @override
  String get wgtSummaryCardName => 'சுருக்கக் கார்டு';

  @override
  String get wgtSummaryCardDesc =>
      'இந்தக் காலகட்டத்திற்கான வருமானம், செலவு மற்றும் நிகர தொகை';

  @override
  String get wgtSpendingTrendName => 'செலவுப் போக்கு';

  @override
  String get wgtSpendingTrendDesc =>
      'பக்கெட் டிராப்டவுனுடன் கூடிய பார் / லைன் சார்ட்';

  @override
  String get wgtWeeklyHeatmapName => 'வாராந்திர ஹீட்மேப்';

  @override
  String get wgtWeeklyHeatmapDesc => 'வாரத்தின் நாள்படி சராசரி செலவு';

  @override
  String get wgtSizeDistributionName => 'பரிவர்த்தனை அளவுகள்';

  @override
  String get wgtSizeDistributionDesc => 'சிறிய / நடுத்தர / பெரிய பிரிப்பு';

  @override
  String get wgtCategoryBreakdownName => 'பிரிவு வாரியான பிரிப்பு';

  @override
  String get wgtCategoryBreakdownDesc =>
      'பிரிவு வாரியாக தொகுக்கப்பட்ட செலவுகள்';

  @override
  String get wgtTagAnalyticsName => 'டேக் பகுப்பாய்வு';

  @override
  String get wgtTagAnalyticsDesc => 'டேக் வாரியாக தொகுக்கப்பட்ட மொத்தங்கள்';

  @override
  String get wgtBiggestTransactionsName => 'மிகப்பெரிய பரிவர்த்தனைகள்';

  @override
  String get wgtBiggestTransactionsDesc =>
      'தொகை, செலவு அல்லது வருமானத்தின்படி முதல் 5';

  @override
  String get atLeastOneWidget =>
      'குறைந்தபட்சம் ஒரு விட்ஜெட்டாவது இயக்கப்பட்டிருக்க வேண்டும்';

  @override
  String get discardChangesConfirm => 'மாற்றங்களை நிராகரிக்கவா?';

  @override
  String get discardChangesBody =>
      'உங்கள் விட்ஜெட்களில் சேமிக்கப்படாத மாற்றங்கள் உள்ளன. இப்போது வெளியேறினால் அவை நிராகரிக்கப்படும்.';

  @override
  String get keepEditing => 'தொடர்ந்து எடிட் செய்';

  @override
  String get discardLabel => 'நிராகரி';

  @override
  String get unlockToContinue => 'தொடர அன்லாக் செய்யவும்';

  @override
  String get splashTagline => 'உங்கள் தனிப்பட்ட பணக் குறிப்பேடு';

  @override
  String get tutCh0Title => 'பரிவர்த்தனைகள்';

  @override
  String get tutCh0Desc =>
      'வருமானம், செலவுகள், பரிமாற்றங்கள், குறிப்புகள், ரசீதுகள் மற்றும் டேக்களை சேர்க்கவும்.';

  @override
  String get tutCh0St0Title => 'தொகையை உள்ளிடவும்';

  @override
  String get tutCh0St0Desc =>
      'நேரடியாக தொகையை தட்டச்சு செய்யவும். பில்ட்-இன் கால்குலேட்டரை திறக்க கால்குலேட்டர் ஐகானைத் தட்டவும்.';

  @override
  String get tutCh0St1Title => 'பரிவர்த்தனை வகை';

  @override
  String get tutCh0St1Desc =>
      'வருமானம், செலவு அல்லது உங்கள் கணக்குகளுக்கு இடையிலான பரிமாற்றத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get tutCh0St2Title => 'ஒரு பிரிவைத் தேர்ந்தெடுக்கவும்';

  @override
  String get tutCh0St2Desc =>
      'பிரிவுகள் உங்கள் செலவுகளை ஒழுங்கமைக்கின்றன. ஏற்கனவே உள்ளதைத் தேர்ந்தெடுக்க அல்லது உங்களுக்கானதை உருவாக்கத் தட்டவும்.';

  @override
  String get tutCh0St3Title => 'ஒரு கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get tutCh0St3Desc =>
      'இது எந்த வாலட் அல்லது வங்கிக் கணக்கிற்குச் சொந்தமானது என்பதைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get tutCh0St4Title => 'பெயரிடுங்கள்';

  @override
  String get tutCh0St4Desc =>
      'தட்டச்சு செய்யத் தொடங்குங்கள், உங்கள் கடந்தகால பரிவர்த்தனைகளிலிருந்து Kuber தானாகவே பரிந்துரைக்கும்.';

  @override
  String get tutCh0St5Title => 'ஸ்மார்ட் பரிந்துரைகள்';

  @override
  String get tutCh0St5Desc =>
      'ஒரே தட்டலில் பெயர், பிரிவு மற்றும் கணக்கை தானாக நிரப்ப ஒரு பரிந்துரையைத் தட்டவும்.';

  @override
  String get tutCh0St6Title => 'குறிப்புகள் மற்றும் இணைப்புகள்';

  @override
  String get tutCh0St6Desc =>
      'சூழலைச் சேர்க்கவும் அல்லது உங்கள் ரசீதின் புகைப்படத்தை இணைக்கவும்.';

  @override
  String get tutCh0St7Title => 'டேக்களை சேர்க்கவும்';

  @override
  String get tutCh0St7Desc =>
      'டேக்குகள் என்பவை பிரிவுகள் முழுவதும் பரிவர்த்தனைகளைத் தொகுக்கும் தனிப்பயன் லேபிள்கள்.';

  @override
  String get tutCh1Title => 'முகப்பு';

  @override
  String get tutCh1Desc =>
      'உங்கள் மாதாந்திர ஸ்னாப்ஷாட்டைப் பார்த்து, விரைவான செயல்களைப் பயன்படுத்தவும்.';

  @override
  String get tutCh1St0Title => 'உங்கள் மாதாந்திர ஸ்னாப்ஷாட்';

  @override
  String get tutCh1St0Desc =>
      'ஒரு பார்வையில் இந்த மாதத்திற்கான நிகர ஓட்டம். பச்சை நிறம் வருமானம், சிவப்பு நிறம் செலவு. விரிவாகப் பார்க்க தட்டவும்.';

  @override
  String get tutCh1St1Title => 'தனியுரிமை மோட்';

  @override
  String get tutCh1St1Desc =>
      'ஒவ்வொரு பேலன்ஸையும் உடனடியாக மறைக்க கண் ஐகானைத் தட்டவும். பொது இடங்களுக்கு ஏற்றது.';

  @override
  String get tutCh1St2Title => 'விரைவில் சேர்';

  @override
  String get tutCh1St2Desc =>
      'முழுப் படிவத்தையும் திறக்காமல் நொடிகளில் பரிவர்த்தனையைப் பதிவு செய்யுங்கள். தட்டச்சு செய்து தொடரவும்.';

  @override
  String get tutCh1St3Title => 'சமீபத்திய பரிவர்த்தனைகள்';

  @override
  String get tutCh1St3Desc =>
      'உங்கள் கடைசி சில பரிவர்த்தனைகள் பேலன்ஸ் கார்டின் கீழே தோன்றும். பார்க்க அல்லது எடிட் செய்ய எதையேனும் தட்டவும்.';

  @override
  String get tutCh1St4Title => 'நேவிகேஷன்';

  @override
  String get tutCh1St4Desc =>
      'முகப்பு, வரலாறு, பகுப்பாய்வு மற்றும் பலவற்றிற்கு இடையில் மாற கீழ் பட்டியைப் பயன்படுத்தவும்.';

  @override
  String get tutCh2Title => 'வரலாறு';

  @override
  String get tutCh2Desc =>
      'கடந்தகால பரிவர்த்தனைகளைக் கண்டறியவும், ஃபில்டர் செய்யவும், பரிசோதிக்கவும் மற்றும் எடிட் செய்யவும்.';

  @override
  String get tutCh2St0Title => 'பரிவர்த்தனை காலவரிசை';

  @override
  String get tutCh2St0Desc =>
      'உங்கள் பரிவர்த்தனைகள் அனைத்தும் தேதியின் அடிப்படையில் தொகுக்கப்பட்டுள்ளன. மிகச் சமீபத்தியவை மேலே இருக்கும்.';

  @override
  String get tutCh2St1Title => 'விரைவு ஃபில்டர்கள்';

  @override
  String get tutCh2St1Desc =>
      'இந்த சிப்களைப் பயன்படுத்தி வருமானம், செலவு அல்லது பரிமாற்றத்தின்படி உடனடியாக ஃபில்டர் செய்யவும்.';

  @override
  String get tutCh2St2Title => 'மேம்பட்ட ஃபில்டர்கள்';

  @override
  String get tutCh2St2Desc =>
      'தேதி வரம்பு, கணக்கு, பிரிவு அல்லது டேக்கள் மூலம் ஒரே நேரத்தில் தேட ஃபில்டர் ஐகானைத் தட்டவும்.';

  @override
  String get tutCh2St3Title => 'எடிட் செய்யத் தட்டவும்';

  @override
  String get tutCh2St3Desc =>
      'முழு விவரங்களைப் பார்க்க, தகவல்களை எடிட் செய்ய அல்லது நீக்க எந்தப் பரிவர்த்தனையையும் தட்டவும்.';

  @override
  String get tutCh3Title => 'பகுப்பாய்வு';

  @override
  String get tutCh3Desc =>
      'போக்குகள் மற்றும் உங்கள் பணம் எங்கு செலவாகிறது என்பதைப் புரிந்துகொள்ளுங்கள்.';

  @override
  String get tutCh3St0Title => 'முதலில் தேதி வரம்பை அமைக்கவும்';

  @override
  String get tutCh3St0Desc =>
      'இயல்பாக இன்றைய டேட்டா மட்டுமே காட்டப்படும். இந்த மாத்திரையைத் தட்டி \"All time\" என்பதைத் தேர்ந்தெடுக்கவும், அப்போதுதான் கீழே உள்ள சார்ட்களில் வரைவதற்கு ஏதேனும் இருக்கும்.';

  @override
  String get tutCh3St1Title => 'உங்கள் நிதி ஸ்னாப்ஷாட்';

  @override
  String get tutCh3St1Desc =>
      'ஒவ்வொரு மாதமும் உங்கள் பணம் எங்கு செல்கிறது என்பதன் காட்சிப் பிரிப்பு.';

  @override
  String get tutCh3St2Title => 'செலவுப் போக்குகள்';

  @override
  String get tutCh3St2Desc =>
      'தினசரி செலவைக் காட்டும் பார் சார்ட். 7 நாட்கள் மற்றும் தனிப்பயன் நேர வரம்புகளுக்கு இடையே மாறவும்.';

  @override
  String get tutCh3St3Title => 'பிரிவு வாரியான பிரிப்பு';

  @override
  String get tutCh3St3Desc =>
      'உங்கள் பட்ஜெட்டில் எந்தப் பிரிவுகள் அதிகம் செலவாகின்றன என்பதை ஒரு பார்வையில் பாருங்கள்.';

  @override
  String get tutCh3St4Title => 'ஃபில்டர்கள் தொடரும்';

  @override
  String get tutCh3St4Desc =>
      'வரலாறு பக்கத்தில் நீங்கள் அமைக்கும் எந்த ஃபில்டர்களும் உங்கள் பகுப்பாய்வுக் காட்சியையும் புதுப்பிக்கும்.';

  @override
  String get tutCh4Title => 'மேலும் & அமைப்புகள்';

  @override
  String get tutCh4Desc =>
      'Kuber ஐத் தனிப்பயனாக்குங்கள், டேட்டாவை நிர்வகியுங்கள் மற்றும் ஆழமான கருவிகளை ஆராயுங்கள்.';

  @override
  String get tutCh4St0Title => 'பட்ஜெட்டுகள்';

  @override
  String get tutCh4St0Desc =>
      'ஒவ்வொரு பிரிவுக்கும் மாதாந்திர செலவு வரம்புகளை அமைக்கவும். Kuber உங்கள் முன்னேற்றத்தை தானாகவே கண்காணிக்கும்.';

  @override
  String get tutCh4St1Title => 'Kuber ஐக் கேளுங்கள்';

  @override
  String get tutCh4St1Desc =>
      'உங்கள் ஆன்-டிவைஸ் AI அசிஸ்டண்ட். உங்கள் செலவுகள் பற்றிய கேள்விகளை தனிப்பட்ட முறையில் கேளுங்கள்.';

  @override
  String get tutCh4St2Title => 'உங்கள் டேட்டா';

  @override
  String get tutCh4St2Desc =>
      'CSV ஆக எக்ஸ்போர்ட் செய்யவும், பேக்கப்பிலிருந்து இம்போர்ட் செய்யவும் அல்லது மாதிரி டேட்டாவை உருவாக்கவும். அனைத்தும் உங்கள் சாதனத்திலேயே இருக்கும்.';

  @override
  String get tutorialUpper => 'டுடோரியல்';

  @override
  String get pickChapter => 'ஒரு அத்தியாயத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get pickChapterSubtitle =>
      'ஐந்து விரைவான அத்தியாயங்கள், ஒவ்வொன்றும் சுமார் 2 நிமிடங்கள். எங்கிருந்து வேண்டுமானாலும் தொடங்கலாம்.';

  @override
  String get startFromBeginning => 'ஆரம்பத்திலிருந்து தொடங்குங்கள் →';

  @override
  String get skipTutorialConfirm => 'டுடோரியலைத் தவிர்க்கவா?';

  @override
  String get keepGoing => 'தொடரவும்';

  @override
  String get skipLabel => 'தவிர்';

  @override
  String get replayHint =>
      'மேலும் → டுடோரியல் என்பதிலிருந்து இதை நீங்கள் எப்போது வேண்டுமானாலும் மீண்டும் இயக்கலாம்.';

  @override
  String get replayHintApp =>
      'மேலும் → ஆப் டுடோரியல் என்பதிலிருந்து இதை நீங்கள் எப்போது வேண்டுமானாலும் மீண்டும் இயக்கலாம்.';

  @override
  String tutStepsAndMin(String count, String mins) {
    return '$count படிகள் · ~$mins நிமிடம்';
  }

  @override
  String chapterDoneTitle(String num) {
    return 'அத்தியாயம் $num முடிந்தது! 🎉';
  }

  @override
  String get endTutorial => 'டுடோரியலை முடி';

  @override
  String readyToStart(String title) {
    return '\"$title\" என்பதைத் தொடங்க தயாரா?';
  }

  @override
  String get exitTutorialConfirm => 'டுடோரியலிலிருந்து வெளியேறவா?';

  @override
  String get exitLabel => 'வெளியேறு';

  @override
  String chapterXofY(String current, String total) {
    return '$total இல் அத்தியாயம் $current';
  }

  @override
  String get skipTour => 'சுற்றுப்பயணத்தைத் தவிர்';

  @override
  String get nextArrow => 'அடுத்து ›';

  @override
  String get incShort => 'வருமானம்';

  @override
  String get expShort => 'செலவு';

  @override
  String get disbursedOn => 'வழங்கப்பட்ட தேதி';

  @override
  String get emiDebitedFrom => 'இதிலிருந்து EMI கழிக்கப்பட்டது';

  @override
  String get searchAccountsHint => 'கணக்குகளைத் தேடு...';

  @override
  String noAccountsMatch(String query) {
    return '\'$query\' உடன் எந்தக் கணக்கும் பொருந்தவில்லை';
  }

  @override
  String get monthlyNetAutomation => 'மாதாந்திர நிகரம்';

  @override
  String get disableAccount => 'கணக்கை முடக்கு';

  @override
  String get enableAccount => 'கணக்கை இயக்கு';

  @override
  String get accountHidden => 'கணக்கு மறைக்கப்பட்டது';

  @override
  String get accountRestored => 'கணக்கு மீட்டமைக்கப்பட்டது';

  @override
  String get disableAccountConfirm =>
      'இந்தக் கணக்கு தேர்வுப் பட்டியல்கள் மற்றும் முகப்பு அட்டைகளிலிருந்து மறைக்கப்படும். எப்போது வேண்டுமானாலும் மீண்டும் இயக்கலாம்.';

  @override
  String get hiddenChip => 'மறைக்கப்பட்டது';

  @override
  String get shareStory => 'கதையைப் பகிர்';

  @override
  String get shareAsImage => 'படமாகப் பகிர்';

  @override
  String get shareAsText => 'உரையாகப் பகிர்';

  @override
  String get confirmLabel => 'உறுதிசெய்';

  @override
  String get sourceLabel => 'மூலம்';

  @override
  String get sourceSms => 'SMS இறக்குமதி';

  @override
  String get sourceRecurring => 'தொடர்ச்சியானது';

  @override
  String get sourceLentBorrowed => 'கடன் கொடுத்தது அல்லது வாங்கியது';

  @override
  String get sourceLoan => 'கடன்';

  @override
  String get sourceInvestment => 'முதலீடு / SIP';

  @override
  String get sourceQuickAdd => 'விரைவுச் சேர்ப்பு';

  @override
  String get sourceManual => 'நீங்கள் உள்ளிட்டது';

  @override
  String get sourceBalanceAdjustment => 'இருப்புச் சரிசெய்தல்';

  @override
  String get viewOriginalSms => 'அசல் SMS-ஐக் காண்க';

  @override
  String get accountTypeLabel => 'கணக்கு வகை';

  @override
  String get accountNumberLabel => 'கணக்கு எண்';

  @override
  String get yesLabel => 'ஆம்';

  @override
  String get noLabel => 'இல்லை';

  @override
  String get lastTransactionLabel => 'கடைசிப் பரிவர்த்தனை';

  @override
  String get budgetStatusLabel => 'பட்ஜெட் நிலை';

  @override
  String get setBudgetForCategory => 'இந்த வகைக்கு பட்ஜெட் அமை';

  @override
  String get usageCountLabel => 'பயன்பாட்டு எண்ணிக்கை';

  @override
  String get firstUsedLabel => 'முதல் பயன்பாடு';

  @override
  String get lastUsedLabel => 'கடைசிப் பயன்பாடு';

  @override
  String get viewTaggedTransactions => 'குறியிடப்பட்ட பரிவர்த்தனைகளைக் காண்க';

  @override
  String get accountLabel => 'கணக்கு';

  @override
  String get dateTimeTitle => 'தேதி மற்றும் நேரம்';

  @override
  String get originalSmsLabel => 'அசல் SMS';

  @override
  String transactionsCountValue(int count) {
    return '$count பரிவர்த்தனைகள்';
  }

  @override
  String get editAccountSubtitle => 'கணக்கு விவரங்களைப் புதுப்பிக்கவும்';

  @override
  String get accountNameLabel => 'கணக்கு பெயர்';

  @override
  String get accountNameHint => 'கணக்கு பெயர்';

  @override
  String get accountTypeBank => 'வங்கி';

  @override
  String get accountTypeCash => 'பணம்';

  @override
  String get accountTypeCreditCard => 'கிரெடிட் கார்டு';

  @override
  String get accountTypeLockedTitle => 'கணக்கு வகை நிர்ணயிக்கப்பட்டது';

  @override
  String get accountTypeLockedBody =>
      'உருவாக்கிய பிறகு கணக்கு வகையை மாற்ற முடியாது. வேறு வகையைப் பயன்படுத்த, புதிய கணக்கை உருவாக்கவும்.';

  @override
  String get accountTypeLockedTooltip => 'இது ஏன் பூட்டப்பட்டுள்ளது?';

  @override
  String get accountIdentifierLabel => 'கணக்கு எண் / அடையாளங்காட்டி';

  @override
  String get accountIdentifierHint => 'கடைசி 4 இலக்கங்கள் அல்லது முழு எண்';

  @override
  String get accountIdentifierHelper =>
      'கடைசி 4 இலக்கங்கள் அல்லது முழு எண். SMS இறக்குமதிகளைப் பொருத்தப் பயன்படுகிறது.';

  @override
  String get makeDefaultAccount => 'இதை இயல்புநிலை கணக்காக்கவும்';

  @override
  String get makeDefaultAccountSub =>
      'விரைவாகச் சேர், குரல் மூலம் சேர் அல்லது Ask Kuber மூலம் பரிவர்த்தனைகளைச் சேர்க்கும்போது முன்கூட்டியே தேர்ந்தெடுக்கப்பட்டது.';

  @override
  String get currentBalanceLabel => 'தற்போதைய இருப்பு';

  @override
  String get limitSpentLabel => 'செலவழித்த வரம்பு';

  @override
  String get totalLimitLabel => 'மொத்த வரம்பு';

  @override
  String get totalLimitHelper =>
      'கார்டின் ஒட்டுமொத்த கிரெடிட் வரம்பு. இதைத் திருத்துவது எந்த சரிசெய்தலையும் உருவாக்காது.';

  @override
  String get balanceAdjustHelper =>
      'இதை மாற்றுவது வித்தியாசத்திற்கான இருப்பு சரிசெய்தல் பரிவர்த்தனையை உருவாக்கும்.';

  @override
  String adjustmentWillBeCredited(String amount) {
    return '$amount இன் இருப்பு சரிசெய்தல் வரவு வைக்கப்படும்.';
  }

  @override
  String adjustmentWillBeDebited(String amount) {
    return '$amount இன் இருப்பு சரிசெய்தல் பற்று வைக்கப்படும்.';
  }

  @override
  String get disableAccountToggle => 'கணக்கை முடக்கு';

  @override
  String get disableAccountHelper =>
      'தேர்வுகள் மற்றும் முகப்பு கார்டுகளில் இருந்து மறைக்கப்பட்டது. தற்போதுள்ள பரிவர்த்தனைகள் இருக்கும்.';

  @override
  String get accountDisabledToggle => 'கணக்கு முடக்கப்பட்டது';

  @override
  String get accountDisabledHelper =>
      'இந்தக் கணக்கு மறைக்கப்பட்டுள்ளது. மீண்டும் காட்ட அணைக்கவும்.';

  @override
  String get accountUpdated => 'கணக்கு புதுப்பிக்கப்பட்டது';

  @override
  String get couldntLoadBalance => 'இருப்பை ஏற்ற முடியவில்லை';

  @override
  String get pickNewDefaultTitle =>
      'புதிய இயல்புநிலை கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String get pickNewDefaultBody =>
      'இது உங்கள் இயல்புநிலை கணக்கு. இதை நீக்குவதற்கு முன் ஒரு மாற்றைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get adjustmentModalTitle => 'சரிசெய்தல் பரிவர்த்தனையை உருவாக்கவா?';

  @override
  String adjustmentModalBody(String noun, String from, String to, String diff) {
    return '$noun $from இலிருந்து $to ஆக மாறுகிறது. $diff க்கான இருப்பு சரிசெய்தல் பரிவர்த்தனை உருவாக்கப்படும்.';
  }

  @override
  String adjustmentModalChip(String nounCap, String direction, String diff) {
    return '$nounCap $diff $direction. இது வருமானமாகவோ செலவாகவோ கணக்கிடப்படாது.';
  }

  @override
  String get adjustmentCreateAndSave => 'உருவாக்கி சேமிக்கவும்';

  @override
  String get valueNounBalance => 'இருப்பு';

  @override
  String get valueNounLimitSpent => 'செலவழித்த வரம்பு';

  @override
  String get valueNounBalanceCap => 'இருப்பு';

  @override
  String get valueNounLimitSpentCap => 'செலவழித்த வரம்பு';

  @override
  String get adjustmentIncreasedBy => 'அதிகரித்தது';

  @override
  String get adjustmentDecreasedBy => 'குறைந்தது';

  @override
  String get dangerZone => 'ஆபத்து மண்டலம்';

  @override
  String get themeModeSectionLabel => 'பயன்முறை';

  @override
  String get themeFamilyDescSignature => 'கிளாசிக் குபேர் தோற்றம்.';

  @override
  String get themeFamilyDescFlewtube => 'துடிப்பான, விளையாட்டுத்தனமான.';

  @override
  String get themeFamilyDescWoofsapp => 'நட்பான, பழக்கமான.';

  @override
  String get themeFamilyDescPurrhub => 'கருப்பில் அடர் மஞ்சள்.';

  @override
  String get themeFamilyDescHonkpe => 'செழுமையான, பணப்பரிவர்த்தனை உணர்வு.';

  @override
  String get themeFamilyDescSqueakdin => 'ஒழுங்கான, வேலை மையம்.';

  @override
  String get themeFamilyDescOinkzon => 'கதகதப்பான, ஷாப்பிங் பாணி.';

  @override
  String get applyLabel => 'பயன்படுத்து';

  @override
  String get speedDialNote => 'குபேர் நோட் சேர்';

  @override
  String get billingCycle => 'பில்லிங் சுழற்சி';

  @override
  String get billGenerationDaySection => 'பில் உருவாகும் நாள்';

  @override
  String get paymentDueDaySection => 'கட்டண இறுதி நாள்';

  @override
  String get remindMe => 'எனக்கு நினைவூட்டு';

  @override
  String get billReminderSub => 'பில் உருவாகும் நாளில் தெரிவி';

  @override
  String get dueReminderSub => 'கட்டண இறுதி நாளில் தெரிவி';

  @override
  String get billGenerationLabel => 'பில் உருவாக்கம்';

  @override
  String get paymentDueLabel => 'கட்டணம் செலுத்த வேண்டியது';

  @override
  String dayOfEveryMonth(String ordinal) {
    return 'ஒவ்வொரு மாதமும் $ordinal';
  }

  @override
  String billDueCrossMonthHint(String billOrdinal, String dueOrdinal) {
    return 'பில் $billOrdinal அன்று உருவாகிறது, கட்டணம் $dueOrdinal அன்று செலுத்த வேண்டும், எனவே கட்டணம் அடுத்த மாதத்தில் வருகிறது.';
  }

  @override
  String get rangeFrom => 'முதல்';

  @override
  String get rangeTo => 'வரை';

  @override
  String get changeView => 'காட்சியை மாற்று';

  @override
  String get iconAndColour => 'ஐகான் & நிறம்';

  @override
  String get chooseIcon => 'ஐகானைத் தேர்ந்தெடுக்கவும்';

  @override
  String get chooseColour => 'நிறத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get budgetsTitle => 'பட்ஜெட்கள்';

  @override
  String get activeBudgetsSection => 'செயலில்';

  @override
  String get pausedAndEnded => 'இடைநிறுத்தப்பட்டவை & முடிந்தவை';

  @override
  String get gainLabel => 'லாபம்';

  @override
  String get returnLabel => 'வருமானம்';

  @override
  String moreCountAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கணக்குகள்',
      one: '1 கணக்கு',
    );
    return '$_temp0';
  }

  @override
  String moreCountCategories(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count வகைகள்',
      one: '1 வகை',
    );
    return '$_temp0';
  }

  @override
  String moreCountTags(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count குறிச்சொற்கள்',
      one: '1 குறிச்சொல்',
    );
    return '$_temp0';
  }

  @override
  String moreCountActive(int count) {
    return '$count செயலில்';
  }

  @override
  String moreCountRules(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count விதிகள்',
      one: '1 விதி',
    );
    return '$_temp0';
  }

  @override
  String moreCountOpen(int count) {
    return '$count திறந்தவை';
  }

  @override
  String moreCountHoldings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count முதலீடுகள்',
      one: '1 முதலீடு',
    );
    return '$_temp0';
  }

  @override
  String get netBalanceUpper => 'நிகர இருப்பு';

  @override
  String get netWorthUpper => 'நிகர மதிப்பு';

  @override
  String nothingMatchesQuery(Object query) {
    return '\"$query\" உடன் எதுவும் பொருந்தவில்லை.';
  }

  @override
  String get searchBudgetsHint => 'பட்ஜெட்களைத் தேடு';

  @override
  String get searchRecurringHint => 'தொடர்வனவற்றைத் தேடு';

  @override
  String get searchLoansHint => 'கடன்களைத் தேடு';

  @override
  String get searchLedgerHint => 'நபர்களைத் தேடு';

  @override
  String get searchInvestmentsHint => 'முதலீடுகளைத் தேடு';

  @override
  String get textSizeTitle => 'எழுத்து அளவு';

  @override
  String get textSizeDesc => 'எழுத்தைப் பெரிதாக்கவும் அல்லது சிறிதாக்கவும்';

  @override
  String get textSizeSmall => 'சிறியது';

  @override
  String get textSizeCompact => 'கச்சிதமானது';

  @override
  String get textSizeDefault => 'இயல்புநிலை';

  @override
  String get textSizeLarge => 'பெரியது';

  @override
  String get textSizeExtraLarge => 'மிகப் பெரியது';

  @override
  String get textSizePreviewUpper => 'முன்னோட்டம்';

  @override
  String get textSizePreviewBody =>
      'Kuber மூலம் தினசரி செலவுகளைக் கண்காணித்து, பட்ஜெட்டை நிர்வகித்து, இலக்குகளை அடையுங்கள்.';

  @override
  String get textSizePreviewMeta => 'மளிகை · இன்று';

  @override
  String get homeV2GsTitle => 'Kuber-ஐ அமைப்போம்';

  @override
  String get homeV2GsBodyTwoDone =>
      'கிட்டத்தட்ட முடிந்தது. இன்னும் ஒரு படி உள்ளது.';

  @override
  String get homeV2GsStep2 => 'நீங்களே ஒரு பரிவர்த்தனையைச் சேர்க்கவும்';

  @override
  String get homeV2GsStep3 => 'உங்கள் தொடக்க இருப்பை அமைக்கவும்';

  @override
  String get homeV2GsDoneTitle => 'நீங்கள் தயார்';

  @override
  String get homeV2GsDoneBody =>
      'நீங்கள் பயன்படுத்தும்போது Kuber உங்கள் முகப்பில் மேலும் சேர்க்கும்.';

  @override
  String get homeV2GsActAdd => 'பரிவர்த்தனை சேர்';

  @override
  String get homeV2GsActBalance => 'இருப்பை அமை';

  @override
  String get homeV2GsCloseA11y => 'தொடங்குக அட்டையை மூடு';

  @override
  String get homeV2GsClosedSnack =>
      'தொடங்குக அட்டை மறைக்கப்பட்டது. அமைப்புகளிலிருந்து மீண்டும் காட்டலாம்.';

  @override
  String get homeV2ActUndo => 'செயல்தவிர்';

  @override
  String get homeV2SetGsTitle => 'தொடங்குக அட்டை';

  @override
  String get homeV2SetGsSub => 'முகப்பில் அமைவுப் படிகளைக் காட்டு';

  @override
  String get homeV2SetSgTitle => 'முகப்பில் பரிந்துரைகள்';

  @override
  String get homeV2SetSgSub =>
      'உங்கள் சொந்தப் பரிவர்த்தனைகளை வைத்து உதவிக்குறிப்புகள்';

  @override
  String homeV2WBalanceEmpty(String month) {
    return '$month மாதத்தின் வரவும் செலவும் இங்கே தெரியும்.';
  }

  @override
  String get homeV2WBalanceEmptyAct => 'பரிவர்த்தனை சேர்';

  @override
  String get homeV2WRecentEmptyBody =>
      'உங்கள் சமீபத்திய பரிவர்த்தனைகள் இங்கே தெரியும்.';

  @override
  String get homeV2WRecentEmptyAct => 'SMS-இலிருந்து இறக்குமதி';

  @override
  String homeV2WEditMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இன்னும் $count விட்ஜெட்டுகள் உள்ளன.',
      one: 'இன்னும் 1 விட்ஜெட் உள்ளது.',
    );
    return '$_temp0';
  }

  @override
  String get homeV2EdSecOn => 'உங்கள் முகப்பில்';

  @override
  String get homeV2EdSgTitle => 'பரிந்துரைகள்';

  @override
  String get homeV2EdSgSub =>
      'உங்கள் சொந்தப் பரிவர்த்தனைகளிலிருந்து உதவிக்குறிப்புகள். எப்போதும் மேலே.';

  @override
  String get homeV2EdSecAuto => 'பரிவர்த்தனைகளைச் சேர்க்கும்போது இயங்கும்';

  @override
  String get homeV2EdSecMore => 'மேலும் விட்ஜெட்டுகள்';

  @override
  String get homeV2EdAutoNote =>
      'காட்ட ஏதாவது இருக்கும்போது இவை தானாகத் தோன்றும். இப்போதே காட்ட ஒன்றை இயக்குங்கள்.';

  @override
  String get homeV2EdAutoStories => 'முதல் பணக் கதை தயாரானதும் இயங்கும்';

  @override
  String get homeV2EdAutoStats => 'ஒரு வாரச் செலவுக்குப் பிறகு இயங்கும்';

  @override
  String get homeV2EdAutoAccounts => 'வங்கிக் கணக்கைச் சேர்த்ததும் இயங்கும்';

  @override
  String get homeV2EdAutoChart => '3 வெவ்வேறு நாள் செலவுக்குப் பிறகு இயங்கும்';

  @override
  String get homeV2EdAutoSms => 'வங்கி SMS காத்திருக்கும்போது இயங்கும்';

  @override
  String get homeV2EdAutoEvents =>
      'முதல் நினைவூட்டல், EMI, SIP அல்லது தொடர் கட்டணத்துடன் இயங்கும்';

  @override
  String get homeV2EdAutoBudget => 'முதல் பட்ஜெட்டுடன் இயங்கும்';

  @override
  String get homeV2EdAutoNotes => 'முதல் குறிப்புடன் இயங்கும்';

  @override
  String get homeV2SgNotNow => 'இப்போது வேண்டாம்';

  @override
  String get homeV2SgDismissA11y => 'இதை மீண்டும் பரிந்துரைக்க வேண்டாம்';

  @override
  String get homeV2SgDismissedSnack =>
      'சரி. Kuber இதை மீண்டும் பரிந்துரைக்காது.';

  @override
  String homeV2SgRecTitle(String merchant) {
    return '$merchant ஒவ்வொரு மாதமும் வருகிறது';
  }

  @override
  String homeV2SgRecBody(String amount, int months) {
    return '$months மாதங்களாக கிட்டத்தட்ட ஒரே தேதியில் $amount. செலுத்த வேண்டிய முன் பார்க்க தொடர்ச்சியாகச் சேர்க்கவும்.';
  }

  @override
  String get homeV2SgRecAct => 'தொடர்ச்சியாகச் சேர்';

  @override
  String homeV2SgRecDone(String merchant) {
    return '$merchant இப்போது தொடர் கட்டணம்.';
  }

  @override
  String get homeV2SgLoanTitle => 'EMI செலுத்துகிறீர்களா?';

  @override
  String homeV2SgLoanBody(String lender) {
    return 'உங்கள் SMS-இல் $lender-க்கு EMI கட்டணங்கள் உள்ளன. மீதத்தைப் பார்க்க கடனைச் சேர்க்கவும்.';
  }

  @override
  String get homeV2SgLoanAct => 'கடன் சேர்';

  @override
  String get homeV2SgLoanDone => 'கடன் சேர்க்கப்பட்டது.';

  @override
  String get homeV2SgInvTitle => 'SIP மூலம் முதலீடு செய்கிறீர்களா?';

  @override
  String homeV2SgInvBody(String amount) {
    return 'உங்கள் SMS-இல் மாதம் $amount SIP உள்ளது. எல்லா முதலீடுகளையும் ஒரே இடத்தில் பார்க்கச் சேர்க்கவும்.';
  }

  @override
  String get homeV2SgInvAct => 'முதலீடு சேர்';

  @override
  String get homeV2SgInvDone => 'முதலீடு சேர்க்கப்பட்டது.';

  @override
  String homeV2SgLedTitle(String name) {
    return '$name-க்குப் பணம் கடன் கொடுத்தீர்களா?';
  }

  @override
  String homeV2SgLedBody(String name, String amount) {
    return 'இந்த மாதம் $name-க்கு $amount அனுப்பினீர்கள். கடன் கொடுக்கல் வாங்கலில் இதைக் கண்காணிக்கவும்.';
  }

  @override
  String get homeV2SgLedNoteTitle => 'கடன் கொடுத்த பணத்தைக் கண்காணிக்கவா?';

  @override
  String homeV2SgLedNoteBody(String note) {
    return 'உங்கள் குறிப்பு \"$note\" பணம் கடன் கொடுத்ததைக் குறிப்பிடுகிறது. மறக்காமல் இருக்க கடன் பகுதியில் சேர்க்கவும்.';
  }

  @override
  String get homeV2SgLedAct => 'கண்காணி';

  @override
  String get homeV2SgLedDone => 'கடன் பகுதியில் சேர்க்கப்பட்டது.';

  @override
  String homeV2SgBudTitle(String category) {
    return '$category-க்கு பட்ஜெட் அமைக்கவா?';
  }

  @override
  String homeV2SgBudBody(String amount, String category) {
    return 'கடந்த 30 நாட்களில் $category-இல் $amount செலவழித்தீர்கள். வரம்பை நெருங்கும்போது பட்ஜெட் சொல்லும்.';
  }

  @override
  String get homeV2SgBudAct => 'பட்ஜெட் அமை';

  @override
  String homeV2SgBudDone(String category) {
    return '$category-க்கு பட்ஜெட் அமைக்கப்பட்டது.';
  }

  @override
  String homeV2SgCcTitle(String card) {
    return '$card-க்கு பில்லிங் தேதியைச் சேர்';
  }

  @override
  String get homeV2SgCcBody =>
      'பின்னர் இந்தச் சுழற்சியின் செலவையும் பில் செலுத்த வேண்டிய நாளையும் Kuber காட்டும்.';

  @override
  String get homeV2SgCcAct => 'பில்லிங் தேதியை அமை';

  @override
  String get homeV2SgCcDone => 'பில்லிங் தேதி சேமிக்கப்பட்டது.';

  @override
  String get homeV2SgAskTitle => 'உங்கள் பணம் பற்றி Kuber-இடம் கேளுங்கள்';

  @override
  String get homeV2SgAskBody =>
      'இப்படி ஒரு கேள்வி கேட்டுப் பாருங்கள்: \"கடந்த மாதம் உணவுக்கு எவ்வளவு செலவழித்தேன்?\"';

  @override
  String get homeV2SgAskAct => 'Kuber-இடம் கேள்';

  @override
  String get homeV2SgVoiceTitle => 'குரல் மூலம் பரிவர்த்தனைகளைச் சேர்';

  @override
  String get homeV2SgVoiceBody =>
      'விரைவுச் சேர்ப்பில் மைக்கைத் தட்டி இப்படிச் சொல்லுங்கள்: \"200 மதிய உணவுக்கு\".';

  @override
  String get homeV2SgVoiceAct => 'முயற்சி செய்';

  @override
  String get homeV2SgWidgetTitle =>
      'Kuber-ஐ உங்கள் முகப்புத் திரையில் வையுங்கள்';

  @override
  String get homeV2SgWidgetBody =>
      'ஆப்பைத் திறக்காமலே இந்த மாதச் செலவைப் பார்த்து பரிவர்த்தனையைச் சேர்க்கலாம்.';

  @override
  String get homeV2SgWidgetAct => 'விட்ஜெட் சேர்';

  @override
  String get homeV2SgCardsTitle => 'உங்கள் கார்டுகளை Kuber Cards-இல் வையுங்கள்';

  @override
  String get homeV2SgCardsBody =>
      'கார்டு விவரங்களை உங்கள் PIN அல்லது கைரேகைக்குப் பின் சேமியுங்கள். அவை இந்த ஃபோனிலேயே இருக்கும்.';

  @override
  String get homeV2SgCardsAct => 'Kuber Cards-ஐ அமை';

  @override
  String get homeV33TourName => 'ஏன் Kuber?';

  @override
  String get homeV33TourMoreSub =>
      'செலவைக் கண்காணிப்பது எப்படி வேலை செய்கிறது, Kuber எப்படி உதவுகிறது';

  @override
  String get homeV33TourCardBody =>
      'ஒவ்வொரு செலவையும் கண்காணிப்பது எப்படி உதவுகிறது, Kuber என்ன செய்ய முடியும்.';

  @override
  String get homeV33TourCardAct => 'காட்டு';

  @override
  String get homeV33TourCardHideA11y => 'இந்த கார்டை மறை';

  @override
  String get homeV33TourCardHidden => 'ஏன் Kuber? More-இல் காணலாம்.';

  @override
  String get homeV33TourNext => 'அடுத்து';

  @override
  String get homeV33TourDone => 'முடிந்தது';

  @override
  String homeV33TourPageA11y(int page, int total) {
    return 'பக்கம் $page / $total';
  }

  @override
  String get homeV33P1Title => 'ஒவ்வொரு செலவையும் எழுதுவதைப் பழக்கமாக்குங்கள்.';

  @override
  String get homeV33P1SubSms =>
      'சிறிய செலவுகளும் முக்கியம். எழுதுவது எளிது, பெரும்பாலானவற்றை வங்கி SMS சேர்க்கும்.';

  @override
  String get homeV33P1Sub =>
      'சிறிய செலவுகளும் முக்கியம். Kuber அவற்றை எழுதுவதை எளிதாக்குகிறது.';

  @override
  String get homeV33P1Try => 'பரிவர்த்தனை சேர்';

  @override
  String get homeV33P1ColDate => 'தேதி';

  @override
  String get homeV33P1ColAmount => 'தொகை';

  @override
  String get homeV33P1ColSpent => 'எதற்கு';

  @override
  String get homeV33P1ColCat => 'வகை';

  @override
  String get homeV33P1A11y =>
      'நோட்டுப் புத்தகத்தில் எழுதிய மூன்று செலவுகள் Kuber பரிவர்த்தனைகளாக மாறுகின்றன, ஒவ்வொன்றும் ஒரு வகை மற்றும் கணக்குடன்.';

  @override
  String get homeV33DFood => 'உணவு டெலிவரி';

  @override
  String get homeV33DAuto => 'ஆட்டோ பயணம்';

  @override
  String get homeV33DMovie => 'சினிமா டிக்கெட்';

  @override
  String get homeV33DCoffee => 'காபி';

  @override
  String get homeV33DGroc => 'மளிகை';

  @override
  String get homeV33CFood => 'உணவு';

  @override
  String get homeV33CTransport => 'போக்குவரத்து';

  @override
  String get homeV33CFun => 'பொழுதுபோக்கு';

  @override
  String get homeV33CShopping => 'ஷாப்பிங்';

  @override
  String get homeV33ABank => 'வங்கி';

  @override
  String get homeV33ACash => 'ரொக்கம்';

  @override
  String get homeV33ACard => 'கிரெடிட் கார்டு';

  @override
  String get homeV33DBankName => 'உங்கள் வங்கி';

  @override
  String get homeV33P2Title => 'ஒவ்வொரு கணக்கும். கிரெடிட் கார்டுகளும்.';

  @override
  String get homeV33P2Sub =>
      'வங்கி, ரொக்கம் மற்றும் கார்டுகள், பில்லிங் சுழற்சி மற்றும் செலுத்த வேண்டிய தேதிகளுடன். எந்த வகையையும் சேர்க்கலாம்.';

  @override
  String get homeV33P2Try => 'கணக்குகளைத் திற';

  @override
  String get homeV33P2Balance => 'இருப்பு';

  @override
  String get homeV33P2Due => 'செலுத்த வேண்டியது';

  @override
  String homeV33P2Cycle(String start, String end) {
    return 'பில்லிங் சுழற்சி $start முதல் $end வரை';
  }

  @override
  String homeV33P2DueOn(String date) {
    return 'செலுத்த வேண்டிய தேதி $date';
  }

  @override
  String get homeV33P2PetCare => 'செல்லப்பிராணி பராமரிப்பு';

  @override
  String get homeV33P2A11y =>
      'ஒரு வங்கிக் கணக்கு, ரொக்கம் மற்றும் ஒரு கிரெடிட் கார்டு தங்கள் இருப்பைக் காட்டுகின்றன. கார்டு அதன் பில்லிங் சுழற்சி மற்றும் செலுத்த வேண்டிய தேதியைக் காட்டுகிறது. புதிய வகை, செல்லப்பிராணி பராமரிப்பு, மற்றவற்றுடன் சேர்கிறது.';

  @override
  String get homeV33P3Title => 'செலவுக்கு மேல் கண்காணியுங்கள்.';

  @override
  String get homeV33P3Sub =>
      'பட்ஜெட்கள், முதலீடுகள், கடன்கள், கொடுத்த அல்லது வாங்கிய பணம், சந்தாக்கள்.';

  @override
  String get homeV33P3Try => 'வரவிருக்கும் நிகழ்வுகளைத் திற';

  @override
  String get homeV33P3Budget => 'உணவு பட்ஜெட்';

  @override
  String homeV33P3BudgetOf(String spent, String limit) {
    return '$limit-இல் $spent';
  }

  @override
  String get homeV33P3Inv => 'முதலீடுகள்';

  @override
  String get homeV33P3InvTypes => 'SIP, பங்குகள், FD மற்றும் பல';

  @override
  String get homeV33P3Loan => 'வீட்டுக் கடன்';

  @override
  String homeV33P3LoanSub(String amount, int paid, int total) {
    return 'EMI $amount · $total-இல் $paid';
  }

  @override
  String homeV33P3Lent(String name) {
    return '$name உங்களுக்குத் தர வேண்டும்';
  }

  @override
  String homeV33P3Borrowed(String name) {
    return 'நீங்கள் $name-க்குத் தர வேண்டும்';
  }

  @override
  String get homeV33P3Subs => 'ஸ்ட்ரீமிங் திட்டம்';

  @override
  String homeV33P3SubsSub(String amount) {
    return 'மாதம் $amount';
  }

  @override
  String homeV33P3Renews(String date) {
    return '$date அன்று புதுப்பிப்பு';
  }

  @override
  String homeV33P3Next(String date) {
    return 'அடுத்து $date';
  }

  @override
  String get homeV33P3A11y =>
      'ஒரு பட்ஜெட் நிரம்புகிறது, ஒரு முதலீடு வளர்கிறது, கடன் EMI செலுத்தப்படுகிறது, கொடுத்த மற்றும் வாங்கிய பணம் தெரிகிறது, ஒரு சந்தா புதுப்பிக்கப்படுகிறது.';

  @override
  String get homeV33P4Title => 'உங்கள் செலவு, ஒரே பார்வையில்.';

  @override
  String get homeV33P4Sub =>
      'ஒவ்வொரு பரிவர்த்தனையும் தேடக்கூடிய ஒரே வரலாற்றில், பகுப்பாய்வு செய்யப் பல வழிகளுடன்.';

  @override
  String get homeV33P4Try => 'அனலிட்டிக்ஸ் திற';

  @override
  String get homeV33P4Search => 'தேடு';

  @override
  String get homeV33P4Query => 'உணவு';

  @override
  String get homeV33P4Today => 'இன்று';

  @override
  String get homeV33P4Yesterday => 'நேற்று';

  @override
  String get homeV33P4ByCat => 'வகை வாரியாக';

  @override
  String get homeV33P4Monthly => 'மாதாந்திரம்';

  @override
  String get homeV33P4Compare => 'ஒப்பீடு';

  @override
  String get homeV33P4A11y =>
      'தேடக்கூடிய வரலாறு உணவுக்குச் சுருங்குகிறது. பிறகு வரைபடங்கள் வகை வாரியாக, மாதம் வாரியாக, இந்த மாதம் கடந்த மாதத்துடன் ஒப்பிட்டு செலவைக் காட்டுகின்றன.';

  @override
  String get homeV33P5Title => 'விரும்பும்போது இன்னும் முன்னேறுங்கள்.';

  @override
  String get homeV33P5Ask => 'Ask Kuber';

  @override
  String get homeV33P5AskLine =>
      'உங்கள் பணம் பற்றிக் கேளுங்கள், பதில் உங்கள் போனிலேயே.';

  @override
  String get homeV33P5Cards => 'Kuber Cards';

  @override
  String get homeV33P5CardsLine =>
      'உங்கள் கார்டுகள், மறைகுறியாக்கப்பட்டு உங்கள் போனிலேயே.';

  @override
  String get homeV33P5Notes => 'Kuber Notes';

  @override
  String get homeV33P5NotesLine =>
      'கணக்கிட்டு பரிவர்த்தனைகளைச் சேர்க்கும் குறிப்புகள்.';

  @override
  String get homeV33P5Calc => 'கால்குலேட்டர்கள் மற்றும் கருவிகள்';

  @override
  String get homeV33P5CalcLine => 'EMI, SIP, வரி மற்றும் பல.';

  @override
  String get homeV33P5Rem => 'நினைவூட்டல்கள்';

  @override
  String get homeV33P5RemLine => 'எந்த பில்லையும் தவறவிடாதீர்கள்.';

  @override
  String get homeV33P5Try => 'Signature கருவிகளைத் திற';

  @override
  String get homeV33P5AskQ => 'இந்த மாதம் உணவுக்கு எவ்வளவு செலவு?';

  @override
  String homeV33P5AskA(String amount) {
    return 'இதுவரை $amount, உங்கள் உணவு பட்ஜெட்டின் 70%.';
  }

  @override
  String get homeV33P5NoteName => 'கோவா பயணம்';

  @override
  String get homeV33P5Hotel => 'ஹோட்டல்';

  @override
  String get homeV33P5Taxi => 'டாக்சி';

  @override
  String get homeV33P5Travel => 'பயணம்';

  @override
  String get homeV33P5SipCalc => 'SIP கால்குலேட்டர்';

  @override
  String homeV33P5PerMonth(String amount) {
    return 'மாதம் $amount';
  }

  @override
  String homeV33P5Rate(int rate) {
    return 'ஆண்டுக்கு $rate%';
  }

  @override
  String homeV33P5Years(int n) {
    return '$n ஆண்டுகள்';
  }

  @override
  String get homeV33P5RemTitle => 'மின்சார பில்';

  @override
  String homeV33P5RemDue(String amount) {
    return 'நாளை செலுத்த வேண்டும் · $amount';
  }

  @override
  String get homeV33P5A11y =>
      'Ask Kuber ஒரு கேள்விக்குப் பதில் தருகிறது, ஒரு கார்டு திரும்புகிறது, ஒரு குறிப்பு கூட்டி பரிவர்த்தனையாகிறது, ஒரு கால்குலேட்டர் முடிவைக் காட்டுகிறது, ஒரு பில் நினைவூட்டல் வருகிறது.';

  @override
  String get homeV3TrkTitle => 'நீங்கள் எதைக் கண்காணிக்க விரும்புகிறீர்கள்?';

  @override
  String get homeV3TrkBody =>
      'விரும்பிய அளவு தேர்ந்தெடுங்கள். Kuber பொருந்தும் விட்ஜெட்களை உங்கள் முகப்பில் சேர்க்கும். பிறகு இதை மாற்றலாம்.';

  @override
  String get homeV31TrkBudgets => 'பட்ஜெட்கள்';

  @override
  String get homeV3TrkLoans => 'கடன்கள் மற்றும் EMI';

  @override
  String get homeV3TrkInvest => 'முதலீடுகள் மற்றும் SIP';

  @override
  String get homeV3TrkLedger => 'கொடுத்த அல்லது வாங்கிய பணம்';

  @override
  String get homeV3TrkSubs => 'சந்தாக்கள்';

  @override
  String get homeV33EdNeedsTxn =>
      'உங்கள் முதல் பரிவர்த்தனைக்குப் பிறகு தெரியும்';

  @override
  String get homeV33SgQuickTitle => 'Quick Add மூலம் ஒரே வரியில் சேர்';

  @override
  String get homeV33SgQuickBody =>
      '\"250 lunch\" போல டைப் செய்யுங்கள் அல்லது மைக்கைத் தொட்டுச் சொல்லுங்கள். Kuber அதைப் பரிவர்த்தனையாக்கும்.';

  @override
  String get homeV33SgQuickAct => 'Quick Add முயற்சிக்கவும்';

  @override
  String get homeV33SgSmsTitle => 'வங்கி SMS உங்கள் செலவுகளைச் சேர்க்கட்டும்';

  @override
  String get homeV33SgSmsBody =>
      'Kuber இந்த போனில் உள்ள வங்கி SMS-ஐப் படித்து பெரும்பாலான பரிவர்த்தனைகளை உங்களுக்காகச் சேர்க்கும். அவை உங்கள் போனை விட்டு வெளியே போகாது.';

  @override
  String get homeV33SgSmsAct => 'SMS-இலிருந்து இறக்கு';

  @override
  String get homeV33GsBodyFresh =>
      'உங்கள் கணக்குகளைப் பாருங்கள், பிறகு முதல் பரிவர்த்தனையைச் சேருங்கள். ஒரு நிமிடம் போதும்.';

  @override
  String homeV33GsProgress(int done) {
    return '2-இல் $done முடிந்தது';
  }

  @override
  String get homeV33GsActAccounts => 'கணக்குகளைப் பார்';

  @override
  String get homeV33GsStepAccounts => 'கணக்குகளை அமை';

  @override
  String freqEveryNWeeks(String count) {
    return 'ஒவ்வொரு $count வாரங்களுக்கும்';
  }

  @override
  String freqEveryNMonths(String count) {
    return 'ஒவ்வொரு $count மாதங்களுக்கும்';
  }

  @override
  String freqEveryNYears(String count) {
    return 'ஒவ்வொரு $count ஆண்டுகளுக்கும்';
  }

  @override
  String get weeksLabel => 'வாரங்கள்';

  @override
  String get monthsLabel => 'மாதங்கள்';

  @override
  String get yearsLabel => 'ஆண்டுகள்';

  @override
  String get intervalInvalid =>
      '1 அல்லது அதற்கு மேற்பட்ட முழு எண்ணை உள்ளிடவும்';

  @override
  String cadenceThen(String interval) {
    return 'பிறகு $interval';
  }

  @override
  String get notifItemMissing => 'இந்த உருப்படி இப்போது இல்லை.';

  @override
  String nextBackupOn(String date) {
    return 'அடுத்தது: $date, ஆப்பைத் திறக்கும்போது';
  }

  @override
  String get nextBackupNextOpen =>
      'அடுத்தது: அடுத்த முறை ஆப்பைத் திறக்கும்போது';

  @override
  String get backupsAreOn => 'காப்புப்பிரதி இயக்கத்தில் உள்ளது';

  @override
  String get backupsAreOnDesc =>
      'முதல் திட்டமிட்ட காப்புப்பிரதி அடுத்த முறை ஆப்பைத் திறக்கும்போது இயங்கும். அல்லது இப்போதே காப்புப்பிரதி எடுக்கவும்.';

  @override
  String get msWhenTitle => 'எப்போது';

  @override
  String get msWhenTitleEmi => 'EMI அட்டவணை';

  @override
  String get msWhenTitleReminder => 'மீண்டும்';

  @override
  String get msWhenDaily => 'தினமும்';

  @override
  String get msWhenWeekly => 'வாரந்தோறும்';

  @override
  String get msWhenMonthly => 'மாதந்தோறும்';

  @override
  String get msWhenQuarterly => 'காலாண்டுதோறும்';

  @override
  String get msWhenHalfYearly => 'ஒவ்வொரு 6 மாதமும்';

  @override
  String get msWhenYearly => 'ஆண்டுதோறும்';

  @override
  String get msWhenCustom => 'தனிப்பயன்';

  @override
  String get msWhenOnce => 'ஒருமுறை';

  @override
  String get msWhenEvery => 'ஒவ்வொரு';

  @override
  String get msWhenUnitDays => 'நாட்கள்';

  @override
  String get msWhenUnitWeeks => 'வாரங்கள்';

  @override
  String get msWhenUnitMonths => 'மாதங்கள்';

  @override
  String get msWhenUnitYears => 'ஆண்டுகள்';

  @override
  String get msWhenStartsOn => 'தொடக்கம்';

  @override
  String get msWhenOnDay => 'தேதி';

  @override
  String msWhenOnDayValue(String ordinal) {
    return 'மாதத்தின் $ordinal ஆம் தேதி';
  }

  @override
  String get msWhenOn => 'நாள்';

  @override
  String get msWhenEnds => 'முடிவு';

  @override
  String get msWhenEndsNever => 'ஒருபோதும் இல்லை';

  @override
  String get msWhenEndsOnDate => 'ஒரு தேதியில்';

  @override
  String get msWhenEndsAfter => 'இத்தனை முறைக்குப் பின்';

  @override
  String get msWhenEndDate => 'முடிவுத் தேதி';

  @override
  String get msWhenTimes => 'முறை';

  @override
  String get msWhenLockedMonthly => 'மாதந்தோறும் மீண்டும் வரும்';

  @override
  String get msWhenLockedHint => 'EMI மாதாந்திரம்';

  @override
  String get msWhenFirstEmi => 'முதல் EMI';

  @override
  String get msWhenEmiDay => 'EMI தேதி';

  @override
  String msWhenEmiDayValue(String ordinal) {
    return 'ஒவ்வொரு மாதமும் $ordinal ஆம் தேதி';
  }

  @override
  String get msWhenNumberOfEmis => 'EMI எண்ணிக்கை';

  @override
  String get msWhenLastEmi => 'கடைசி EMI';

  @override
  String get msWhenEveryUnitDay => 'தினமும்';

  @override
  String get msWhenEveryUnitWeek => 'வாரந்தோறும்';

  @override
  String get msWhenEveryUnitMonth => 'மாதந்தோறும்';

  @override
  String get msWhenEveryUnitYear => 'ஆண்டுதோறும்';

  @override
  String msWhenEveryNDays(String n) {
    return 'ஒவ்வொரு $n நாளும்';
  }

  @override
  String msWhenEveryNWeeks(String n) {
    return 'ஒவ்வொரு $n வாரமும்';
  }

  @override
  String msWhenEveryNMonths(String n) {
    return 'ஒவ்வொரு $n மாதமும்';
  }

  @override
  String msWhenEveryNYears(String n) {
    return 'ஒவ்வொரு $n ஆண்டும்';
  }

  @override
  String msWhenAnchorWeekday(String weekday) {
    return '$weekday அன்று';
  }

  @override
  String msWhenAnchorDay(String ordinal) {
    return '$ordinal ஆம் தேதி';
  }

  @override
  String msWhenAnchorDate(String date) {
    return '$date அன்று';
  }

  @override
  String msWhenSentence(
    String interval,
    String anchor,
    String start,
    String end,
  ) {
    return '$interval$anchor, $start முதல், $end.';
  }

  @override
  String get msWhenEndNever => 'முடிவு இல்லை';

  @override
  String msWhenEndUntil(String date) {
    return '$date வரை';
  }

  @override
  String msWhenEndTimes(String n) {
    return '$n முறை';
  }

  @override
  String msWhenEndEmis(String n) {
    return '$n EMI';
  }

  @override
  String msWhenOnceSentence(String date) {
    return '$date அன்று.';
  }

  @override
  String msWhenLastOn(String date) {
    return 'கடைசியாக $date அன்று';
  }

  @override
  String msWhenLastEmiOn(String date) {
    return 'கடைசி EMI $date';
  }

  @override
  String msWhenCountTotal(String n) {
    return 'மொத்தம் $n முறை';
  }

  @override
  String get msWhenFlagNext => 'அடுத்தது';

  @override
  String get msWhenFlagToday => 'இன்று செலுத்த வேண்டும்';

  @override
  String get msWhenFlagLastDay => 'கடைசி நாள்';

  @override
  String get msWhenMonthEnd =>
      'குறைந்த நாட்கள் உள்ள மாதங்களில் இது கடைசி நாளில் வரும்.';

  @override
  String get msWhenErrEndBeforeStart =>
      'முடிவுத் தேதி தொடக்கத் தேதிக்குப் பின் இருக்க வேண்டும்.';

  @override
  String get msWhenErrCount => '1 அல்லது அதற்கு மேல் உள்ளிடவும்.';

  @override
  String get msWhenErrCountPreview =>
      'எத்தனை முறை என்று உள்ளிடவும் (1 அல்லது மேல்).';

  @override
  String get msCalculated => 'கணக்கிடப்பட்டது';

  @override
  String get msViewDetails => 'விவரங்களைப் பார்';

  @override
  String get msOpenInCalculator => 'கணக்கீட்டியில் திற';

  @override
  String get msAdvanced => 'மேம்பட்ட விருப்பங்கள்';

  @override
  String get msAdvancedSubLoan =>
      'வட்டி வகை, கடன் எண்கள், ஏற்கனவே நடப்பில், செலவு';

  @override
  String get msAlreadyRunning => 'ஏற்கனவே நடப்பில் உள்ளதா?';

  @override
  String get msAlreadyRunningSubLoan => 'இந்தக் கடன் இன்றுக்கு முன் தொடங்கியது';

  @override
  String get msAlreadyRunningSubInv => 'நான் இன்றுக்கு முன் முதலீடு செய்தேன்';

  @override
  String get msOpeningNote =>
      'தொடக்க மதிப்புகள் எந்தக் கணக்கின் இருப்பையும் மாற்றாது.';

  @override
  String get msFromLoans => 'கடன்களிலிருந்து';

  @override
  String get msFromInvestments => 'முதலீடுகளிலிருந்து';

  @override
  String msSource(String name) {
    return '$name இலிருந்து';
  }

  @override
  String msSourceRule(String name) {
    return '$name இலிருந்து · தொடர்';
  }

  @override
  String msFilledFrom(String name) {
    return '$name இலிருந்து நிரப்பப்பட்டது';
  }

  @override
  String msFromCalculator(String calculator) {
    return '$calculator இலிருந்து';
  }

  @override
  String get msPaused => 'இடைநிறுத்தப்பட்டது';

  @override
  String get msEnded => 'முடிந்தது';

  @override
  String get msClosed => 'மூடப்பட்டது';

  @override
  String get msExample => 'எடுத்துக்காட்டு';

  @override
  String get msBusy =>
      'செயலாக்கத்தில் உள்ளது, சற்று நேரத்தில் மீண்டும் முயலவும்';

  @override
  String get msLoansTotalOutstanding => 'மொத்த நிலுவை';

  @override
  String get msLoansMonthlyEmis => 'மாதாந்திர EMI';

  @override
  String msLoansNextEmiLine(String date, String name, String amount) {
    return 'அடுத்த EMI $date · $name · $amount';
  }

  @override
  String get msLoansActive => 'செயலில்';

  @override
  String msLoansRowSub(String amount, String date) {
    return '$amount EMI · அடுத்தது $date';
  }

  @override
  String get msLoansLeft => 'மீதம்';

  @override
  String msLoansProgress(String paid, String total) {
    return '$total இல் $paid EMI செலுத்தப்பட்டன';
  }

  @override
  String msLoansPaidCount(String paid) {
    return '$paid EMI செலுத்தப்பட்டன';
  }

  @override
  String get msLoansEmptyTitle => 'இன்னும் கடன்கள் இல்லை';

  @override
  String get msLoansEmptyBody =>
      'கடனைச் சேர்த்து அதன் EMI, மீதமுள்ள தொகை, செலுத்திய வட்டியைப் பாருங்கள்.';

  @override
  String get msLoansFab => 'கடன் சேர்';

  @override
  String get msLoansAdd => 'கடன் சேர்';

  @override
  String get msLoansEdit => 'கடனைத் திருத்து';

  @override
  String get msLoansType => 'கடன் வகை';

  @override
  String get msLoansName => 'கடன் பெயர்';

  @override
  String get msLoansLender => 'கடன் வழங்குநர்';

  @override
  String get msLoansEmiAmount => 'EMI தொகை';

  @override
  String get msLoansPayFrom => 'எந்தக் கணக்கிலிருந்து';

  @override
  String get msLoansRecordEmis => 'EMI பதிவு';

  @override
  String get msLoansRecordAuto => 'தானாக';

  @override
  String msLoansRecordAutoHelp(String account) {
    return 'EMI நாளில் Kuber $account இலிருந்து EMI ஐப் பதிவு செய்யும்.';
  }

  @override
  String get msLoansRecordManual => 'நானே பதிவு செய்வேன்';

  @override
  String get msLoansSave => 'கடனைச் சேமி';

  @override
  String get msLoansSaveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get msLoansInterestType => 'வட்டி வகை';

  @override
  String get msLoansReducing => 'குறையும் இருப்பு';

  @override
  String get msLoansReducingSub => 'பெரும்பாலான வங்கிக் கடன்கள்';

  @override
  String get msLoansFlat => 'நிலையான வீதம் (Flat)';

  @override
  String get msLoansFlatSub => 'பல கார், தனிநபர், நுகர்வோர் கடன்கள்';

  @override
  String get msLoansIo => 'முதலில் வட்டி மட்டும் காலம்';

  @override
  String get msLoansIoSub => 'முதலில் ப்ரீ-EMI, பின் வழக்கமான EMI';

  @override
  String get msLoansIoMonths => 'வட்டி மட்டும் மாதங்கள்';

  @override
  String msLoansIoNotice(String io, String date, String emi, String n) {
    return '$date வரை மாதம் $io, பின் $n மாதங்களுக்கு மாதம் $emi.';
  }

  @override
  String get msLoansNumbers => 'கடன் எண்கள்';

  @override
  String get msLoansPrincipal => 'அசல்';

  @override
  String get msLoansRate => 'வட்டி வீதம்';

  @override
  String get msLoansTenure => 'காலம்';

  @override
  String get msLoansEmi => 'EMI';

  @override
  String get msLoansYears => 'ஆண்டுகள்';

  @override
  String get msLoansMonths => 'மாதங்கள்';

  @override
  String get msLoansTotalPayable => 'மொத்தம் செலுத்த வேண்டியது · விருப்பம்';

  @override
  String get msLoansTotalPayableHint =>
      'வீதத்துக்குப் பதிலாக இதைப் பயன்படுத்தவும்';

  @override
  String msLoansOrderHelp(String a, String b, String c) {
    return 'நிரப்பிய வரிசை: $a, $b, $c.';
  }

  @override
  String msLoansSwapHelp(String field, String other) {
    return 'நீங்கள் $field உள்ளிட்டீர்கள், எனவே $other (முதலில் நிரப்பியது) இப்போது கணக்கிடப்படும்.';
  }

  @override
  String msLoansPreview(String emi, String month, String interest) {
    return 'EMI $emi · $month இல் முடியும் · மொத்த வட்டி $interest';
  }

  @override
  String msLoansPreviewZero(String emi, String month) {
    return 'EMI $emi · $month இல் முடியும் · வட்டி இல்லை';
  }

  @override
  String msLoansMismatchMore(String diff) {
    return 'உங்கள் EMI கணக்கிட்டதை விட $diff அதிகம். உங்கள் EMI ஐயே பயன்படுத்துவோம்.';
  }

  @override
  String msLoansMismatchLess(String diff) {
    return 'உங்கள் EMI கணக்கிட்டதை விட $diff குறைவு. உங்கள் EMI ஐயே பயன்படுத்துவோம்.';
  }

  @override
  String get msLoansErrNeverEnds =>
      'இந்த EMI வட்டியைக் கூட ஈடுகட்டாது, எனவே கடன் ஒருபோதும் முடியாது.';

  @override
  String msLoansErrNeverEndsPreview(String interest) {
    return 'மாத வட்டி $interest. அதை விட அதிக EMI உள்ளிடவும்.';
  }

  @override
  String get msLoansErrTotalLow =>
      'இது அசலை விடக் குறைவு. எண்களைச் சரிபார்க்கவும்.';

  @override
  String get msLoansRun1 => 'கடனின் அசல் விவரங்கள் எனக்குத் தெரியும்';

  @override
  String get msLoansRun1Sub => 'நீங்கள் செலுத்தியதை Kuber கணக்கிடும்';

  @override
  String get msLoansRun2 => 'இன்றைய நிலுவை எனக்குத் தெரியும்';

  @override
  String get msLoansRun2Sub => 'வங்கி அறிக்கையிலிருந்து';

  @override
  String get msLoansRun3 => 'EMI ஐ மட்டும் கண்காணி';

  @override
  String get msLoansRun3Sub => 'அசல், வட்டி பிரிப்பு இல்லை';

  @override
  String get msLoansEmisPaid => 'செலுத்திய EMI';

  @override
  String get msLoansPrincipalPaid => 'செலுத்திய அசல்';

  @override
  String get msLoansInterestPaid => 'செலுத்திய வட்டி';

  @override
  String get msLoansOutstandingToday => 'இன்றைய நிலுவை';

  @override
  String msLoansRun1Help(String date) {
    return 'கடன் எண்கள் மற்றும் உங்கள் முதல் EMI ($date) இலிருந்து கணக்கிடப்பட்டது. மாற்ற எந்த மதிப்பையும் தட்டவும்.';
  }

  @override
  String msLoansAdjustment(String diff) {
    return 'உங்கள் எண்ணைப் பயன்படுத்தி வேறுபாட்டைச் சரிசெய்தலாகச் சேர்ப்போம்: $diff.';
  }

  @override
  String get msLoansEmisLeft => 'மீதமுள்ள EMI';

  @override
  String msLoansEmisLeftValue(String n, String month) {
    return '$n · கடைசி $month இல்';
  }

  @override
  String get msLoansPastTotals => 'முந்தைய மொத்தங்கள் · விருப்பம்';

  @override
  String get msLoansPastTotalsSub => 'செலுத்திய அசல், வட்டி';

  @override
  String msLoansRun3Notice(String emi, String ordinal) {
    return 'Kuber ஒவ்வொரு மாதமும் $ordinal ஆம் தேதி $emi EMI ஐப் பதிவு செய்யும். கடன் எண்களைச் சேர்க்கும் வரை அசல், வட்டி, நிலுவை தெரியாது.';
  }

  @override
  String get msLoansSpending => 'செலவு';

  @override
  String get msLoansOnlyInterest => 'வட்டியை மட்டும் செலவாகக் கணக்கிடு';

  @override
  String get msLoansOnlyInterestHelp =>
      'அசல் இந்தக் கடனுக்கு மாற்றமாகக் கணக்கிடப்படும். உங்கள் வங்கி இருப்பு முழு EMI அளவு குறையும்.';

  @override
  String get msLoansFutureOnly =>
      'இது இனி வரும் EMI களுக்கு மட்டும் பொருந்தும். ஏற்கனவே பதிவான EMI கள் அப்படியே கணக்கிடப்படும்.';

  @override
  String get msLoansOutstanding => 'நிலுவை';

  @override
  String msLoansEndsOn(String month) {
    return '$month இல் முடியும்';
  }

  @override
  String msLoansNextEmi(String date) {
    return 'அடுத்த EMI · $date';
  }

  @override
  String get msLoansSplit => 'EMI பிரிப்பு';

  @override
  String get msLoansPrincipalL => 'அசல்';

  @override
  String get msLoansInterestL => 'வட்டி';

  @override
  String get msLoansTotalInterest => 'மொத்த வட்டி';

  @override
  String get msLoansRecordExtra => 'கூடுதல் கட்டணம் பதிவு';

  @override
  String get msLoansChangeRate => 'வட்டி வீதத்தை மாற்று';

  @override
  String get msLoansCloseLoan => 'கடனை மூடு';

  @override
  String get msLoansOutstandingTab => 'நிலுவை';

  @override
  String get msLoansSplitTab => 'அசல் vs வட்டி';

  @override
  String get msLoansMonth => 'மாதம்';

  @override
  String get msLoansYear => 'ஆண்டு';

  @override
  String get msLoansBeforeKuber => 'Kuber க்கு முன்';

  @override
  String get msLoansNext => 'அடுத்தது';

  @override
  String msLoansRowSplit(String principal, String interest) {
    return 'அ $principal · வ $interest';
  }

  @override
  String msLoansRowBal(String balance) {
    return 'மீதம் $balance';
  }

  @override
  String get msLoansInterestOnly => 'வட்டி மட்டும்';

  @override
  String msLoansEventExtra(String amount, String date) {
    return 'கூடுதல் கட்டணம் $amount · $date';
  }

  @override
  String msLoansEventExtraSubTenure(String balance) {
    return 'காலத்தைக் குறை · பின் நிலுவை $balance';
  }

  @override
  String msLoansEventExtraSubEmi(String balance) {
    return 'EMI ஐக் குறை · பின் நிலுவை $balance';
  }

  @override
  String msLoansEventRate(String oldRate, String newRate, String date) {
    return 'வீதம் $oldRate → $newRate · $date முதல்';
  }

  @override
  String msLoansEventRateSubTenure(String emi) {
    return 'காலத்தை மாற்று · EMI $emi ஆகவே இருக்கும்';
  }

  @override
  String msLoansEventRateSubEmi(String emi) {
    return 'EMI ஐ மாற்று · புதிய EMI $emi';
  }

  @override
  String msLoansEventCharge(String amount, String date) {
    return 'கட்டணம் $amount · $date';
  }

  @override
  String msLoansEventRegular(String date) {
    return 'வழக்கமான EMI தொடக்கம் · $date';
  }

  @override
  String msLoansYearSub(String n, String paid) {
    return '$n EMI · $paid செலுத்தப்பட்டன';
  }

  @override
  String get msLoansYearEnd => 'ஆண்டு இறுதி நிலுவை';

  @override
  String msLoansChartNote(String year, String amount) {
    return '$year இல் உள்ள சரிவு உங்கள் $amount கூடுதல் கட்டணத்தால்.';
  }

  @override
  String msLoansIoBanner(String month, String io, String emi, String date) {
    return '$month வரை வட்டி மட்டும்: மாதம் $io. $emi வழக்கமான EMI $date முதல் தொடங்கும்.';
  }

  @override
  String get msLoansExtraTitle => 'கூடுதல் கட்டணம்';

  @override
  String get msLoansExtraQ => 'இது அசலுக்குச் செல்லுமா?';

  @override
  String get msLoansExtraYes => 'ஆம்';

  @override
  String get msLoansExtraNo => 'இல்லை, இது கட்டணம்';

  @override
  String get msLoansReduceTenure => 'காலத்தைக் குறை';

  @override
  String get msLoansReduceTenureSub => 'அதே EMI, கடன் விரைவில் முடியும்';

  @override
  String get msLoansReduceEmi => 'EMI ஐக் குறை';

  @override
  String get msLoansReduceEmiSub => 'அதே முடிவுத் தேதி, குறைந்த EMI';

  @override
  String get msLoansSavesMore => 'அதிக வட்டி சேமிக்கும்';

  @override
  String msLoansExtraPreviewTenure(String amount, String n) {
    return '$amount வட்டி சேமிப்பு · $n மாதங்கள் முன்பே முடியும்';
  }

  @override
  String msLoansExtraPreviewEmi(String amount, String emi) {
    return '$amount வட்டி சேமிப்பு · EMI $emi ஆகும்';
  }

  @override
  String get msLoansPrepayCharge => 'முன்கூட்டிய செலுத்தல் கட்டணம் · விருப்பம்';

  @override
  String get msLoansPrepayChargeHint => 'தொகை அல்லது %';

  @override
  String msLoansFeeNotice(String outstanding) {
    return 'கடன் கட்டணங்களில் செலவாகப் பதிவானது. உங்கள் நிலுவை $outstanding ஆகவே இருக்கும்.';
  }

  @override
  String get msLoansLoanCharges => 'கடன் கட்டணங்கள்';

  @override
  String get msLoansNoNumbersPreview =>
      'இது எவ்வளவு சேமிக்கும் என்று பார்க்க கடன் எண்களைச் சேர்க்கவும்.';

  @override
  String get msLoansNewRate => 'புதிய வீதம்';

  @override
  String get msLoansEffectiveFrom => 'அமலுக்கு வரும் தேதி';

  @override
  String get msLoansThen => 'பிறகு';

  @override
  String get msLoansAdjustEmi => 'EMI ஐ மாற்று';

  @override
  String get msLoansAdjustTenure => 'காலத்தை மாற்று';

  @override
  String msLoansRatePreviewEmi(String emi, String date) {
    return '$date முதல் புதிய EMI $emi';
  }

  @override
  String msLoansRatePreviewEmiSub(String month, String amount) {
    return 'முன்பு போல் $month இல் முடியும் · $amount வட்டி சேமிப்பு';
  }

  @override
  String msLoansRatePreviewTenure(String emi, String month) {
    return 'EMI $emi ஆகவே இருக்கும் · $month இல் முடியும்';
  }

  @override
  String msLoansRatePreviewTenureSub(String n, String amount) {
    return '$n மாதங்கள் முன்பே · $amount வட்டி சேமிப்பு';
  }

  @override
  String msLoansRatePreviewTenureSubLater(String n, String amount) {
    return '$n மாதங்கள் தாமதமாக · $amount கூடுதல் வட்டி';
  }

  @override
  String get msLoansFloatingHelp =>
      'மிதக்கும் வீதக் கடன்கள் கடன் வழங்குநரின் அளவுகோலுடன் மாறும். ஒவ்வொரு மாற்றத்தையும் இங்கே பதிவு செய்யவும்.';

  @override
  String msLoansPaidOff(String name) {
    return '$name முழுவதும் செலுத்தப்பட்டது';
  }

  @override
  String msLoansCloseTitle(String name) {
    return '$name ஐ மூடவா?';
  }

  @override
  String get msLoansCloseBody =>
      'இது மூடப்பட்டவை பகுதிக்குச் செல்லும். EMI நிற்கும், வரலாறு இருக்கும்.';

  @override
  String msLoansExtraName(String name) {
    return 'கூடுதல் கட்டணம் · $name';
  }

  @override
  String msLoansChargeName(String name) {
    return 'கடன் கட்டணம் · $name';
  }

  @override
  String get msLoansSaved => 'கடன் சேமிக்கப்பட்டது';

  @override
  String get msLoansRateSaved => 'வீத மாற்றம் சேமிக்கப்பட்டது';

  @override
  String get msLoansExtraSaved => 'கூடுதல் கட்டணம் பதிவானது';

  @override
  String get msInvPortfolio => 'போர்ட்ஃபோலியோ மதிப்பு';

  @override
  String get msInvInvested => 'முதலீடு';

  @override
  String get msInvGain => 'லாபம்';

  @override
  String get msInvXirr => 'XIRR';

  @override
  String msInvOverall(String pct) {
    return 'மொத்தம் $pct';
  }

  @override
  String get msInvUpdateValues => 'மதிப்புகளைப் புதுப்பி';

  @override
  String get msInvGroupMutualFunds => 'பரஸ்பர நிதிகள்';

  @override
  String get msInvGroupStocks => 'பங்குகள்';

  @override
  String get msInvGroupGold => 'தங்கம்';

  @override
  String get msInvGroupCrypto => 'கிரிப்டோ';

  @override
  String get msInvGroupFixed => 'நிலையான வருமானம்';

  @override
  String get msInvGroupOther => 'சொத்து மற்றும் பிற';

  @override
  String msInvStale(String n) {
    return '$n நாட்களுக்கு முன் புதுப்பிக்கப்பட்டது';
  }

  @override
  String msInvUpdatedOn(String month) {
    return '$month இல் புதுப்பிக்கப்பட்டது';
  }

  @override
  String get msInvEmptyTitle => 'இன்னும் முதலீடுகள் இல்லை';

  @override
  String get msInvEmptyBody =>
      'நிதி, பங்கு, FD அல்லது உங்களுக்குச் சொந்தமான எதையும் சேர்க்கவும். அதன் மதிப்பையும் லாபத்தையும் Kuber காட்டும்.';

  @override
  String get msInvFab => 'முதலீடு சேர்';

  @override
  String get msInvAdd => 'முதலீடு சேர்';

  @override
  String get msInvEdit => 'முதலீட்டைத் திருத்து';

  @override
  String get msInvSave => 'முதலீட்டைச் சேமி';

  @override
  String get msInvPickIntro =>
      'இது எந்த வகை முதலீடு? மதிப்பு மாறும் விதத்துக்கு ஏற்ப படிவம் மாறும்.';

  @override
  String get msInvPickMarket => 'மதிப்பு சந்தையுடன் மாறும்';

  @override
  String get msInvPickMarketSub =>
      'நீங்கள் அவ்வப்போது மதிப்பைப் புதுப்பிப்பீர்கள்';

  @override
  String get msInvPickFixed => 'நிலையான வருமானம்';

  @override
  String get msInvPickFixedSub => 'Kuber உங்களுக்காக மதிப்பைக் கணக்கிடும்';

  @override
  String get msInvPickOther => 'பிற';

  @override
  String get msInvPickOtherSub => 'நீங்கள் அரிதாக மதிப்பைப் புதுப்பிப்பீர்கள்';

  @override
  String get msInvTypeMutualFund => 'பரஸ்பர நிதி';

  @override
  String get msInvTypeStocks => 'பங்குகள்';

  @override
  String get msInvTypeEtf => 'ETF';

  @override
  String get msInvTypeGold => 'தங்கம்';

  @override
  String get msInvTypeCrypto => 'கிரிப்டோ';

  @override
  String get msInvTypeFd => 'நிலை வைப்பு';

  @override
  String get msInvTypeRd => 'தொடர் வைப்பு';

  @override
  String get msInvTypePpf => 'PPF';

  @override
  String get msInvTypeBonds => 'பத்திரங்கள்';

  @override
  String get msInvTypeProperty => 'சொத்து';

  @override
  String get msInvTypeCollectibles => 'சேகரிப்புப் பொருட்கள்';

  @override
  String get msInvTypeCustom => 'தனிப்பயன்';

  @override
  String get msInvName => 'பெயர்';

  @override
  String get msInvHow => 'நீங்கள் எப்படி முதலீடு செய்கிறீர்கள்?';

  @override
  String get msInvOneTime => 'ஒருமுறை';

  @override
  String get msInvSip => 'SIP';

  @override
  String get msInvAmountInvested => 'முதலீடு செய்த தொகை';

  @override
  String get msInvCurrentValue => 'தற்போதைய மதிப்பு';

  @override
  String get msInvUnits => 'யூனிட்கள் · விருப்பம்';

  @override
  String get msInvUnitsHint => 'எ.கா. 612.4';

  @override
  String get msInvSipAmount => 'SIP தொகை';

  @override
  String get msInvFromAccount => 'எந்தக் கணக்கிலிருந்து';

  @override
  String get msInvStepUp => 'ஆண்டு அதிகரிப்பு';

  @override
  String get msInvStepUpSwitch => 'ஒவ்வொரு ஆண்டும் அதிகரி';

  @override
  String get msInvStepUpField => 'அதிகரிப்பு';

  @override
  String msInvStepUpNotice(
    String a,
    String b,
    String date1,
    String c,
    String date2,
  ) {
    return 'இப்போது $a, $date1 முதல் $b, $date2 முதல் $c.';
  }

  @override
  String get msInvPrincipal => 'அசல்';

  @override
  String get msInvInstallment => 'தவணை';

  @override
  String get msInvTerms => 'நிபந்தனைகள்';

  @override
  String get msInvRate => 'வட்டி வீதம்';

  @override
  String get msInvStartDate => 'தொடக்கத் தேதி';

  @override
  String get msInvTenure => 'காலம்';

  @override
  String get msInvCompounding => 'கூட்டு வட்டி';

  @override
  String get msInvCompMonthly => 'மாதாந்திரம்';

  @override
  String get msInvCompQuarterly => 'காலாண்டு';

  @override
  String get msInvCompHalfYearly => 'அரையாண்டு';

  @override
  String get msInvCompYearly => 'ஆண்டு';

  @override
  String get msInvPayout => 'செலுத்தும் வகை';

  @override
  String get msInvPayCumulative => 'திரட்டு';

  @override
  String get msInvPayMonthly => 'மாதாந்திரம்';

  @override
  String get msInvPayQuarterly => 'காலாண்டு';

  @override
  String get msInvPayYearly => 'ஆண்டு';

  @override
  String get msInvAtMaturity => 'முதிர்வில்';

  @override
  String msInvMaturityLine(String date, String amount) {
    return '$date அன்று · வட்டி $amount';
  }

  @override
  String msInvMaturityLineRd(String date, String amount) {
    return '$date அன்று · நீங்கள் $amount செலுத்துவீர்கள்';
  }

  @override
  String get msInvAutoValue =>
      'Kuber தினமும் மதிப்பைக் கணக்கிடும். நீங்கள் அதைப் புதுப்பிக்க வேண்டியதில்லை.';

  @override
  String get msInvInvestedSoFar => 'இதுவரை முதலீடு';

  @override
  String get msInvUnrealized => 'உணரப்படாதது';

  @override
  String get msInvRealized => 'உணரப்பட்ட லாபம்';

  @override
  String get msInvWithdrawn => 'எடுத்தது';

  @override
  String get msInvLastUpdated => 'கடைசிப் புதுப்பிப்பு';

  @override
  String msInvSipLine(String amount, String ordinal) {
    return '$ordinal ஆம் தேதி $amount';
  }

  @override
  String msInvSipLineStep(String amount, String ordinal, String pct) {
    return '$ordinal ஆம் தேதி $amount · ஆண்டுக்கு +$pct';
  }

  @override
  String get msInvUpdateValue => 'மதிப்பைப் புதுப்பி';

  @override
  String get msInvAddMoney => 'பணம் சேர்';

  @override
  String get msInvWithdraw => 'எடு';

  @override
  String get msInvValueToday => 'இன்றைய மதிப்பு';

  @override
  String msInvMatures(String date) {
    return '$date அன்று முதிர்வு';
  }

  @override
  String get msInvWithdrawEarly => 'முன்கூட்டியே எடு';

  @override
  String get msInvLegendValue => 'தற்போதைய மதிப்பு';

  @override
  String get msInvLegendInvested => 'முதலீடு செய்த தொகை';

  @override
  String get msInvLegendGain => 'லாபம்';

  @override
  String get msInvActivity => 'செயல்பாடு';

  @override
  String get msInvActValue => 'மதிப்பு புதுப்பிக்கப்பட்டது';

  @override
  String get msInvActSip => 'SIP தவணை';

  @override
  String get msInvActTopUp => 'கூடுதல் முதலீடு';

  @override
  String get msInvActWithdrawal => 'எடுத்தல்';

  @override
  String get msInvActOpening => 'தொடக்க மதிப்பு';

  @override
  String get msInvActInterest => 'வட்டி சேர்ந்தது';

  @override
  String get msInvActOpened => 'வைப்பு தொடங்கப்பட்டது';

  @override
  String get msInvTransaction => 'பரிவர்த்தனை';

  @override
  String get msInvAddPast => 'முந்தைய தேதிக்கான மதிப்பைச் சேர்';

  @override
  String get msInvAddPastTitle => 'முந்தைய மதிப்பைச் சேர்';

  @override
  String get msInvValueOnDate => 'அந்தத் தேதியின் மதிப்பு';

  @override
  String get msInvPastHelp =>
      'முந்தைய மதிப்புகள் வரைபடத்தை நிரப்பும். அவை தற்போதைய மதிப்பையோ இருப்பையோ மாற்றாது.';

  @override
  String get msInvInterestLocked =>
      'வட்டிப் பதிவுகள் கணக்கிடப்படுபவை, திருத்த முடியாது.';

  @override
  String msInvUpdSub(String n) {
    return '$n முதலீடுகள் · சுமார் 30 விநாடிகள்';
  }

  @override
  String get msInvUpdHelp =>
      'நிலை வைப்புகளும் PPF உம் தானாகப் புதுப்பிக்கப்படும், அதனால் இங்கே இல்லை.';

  @override
  String get msInvNewValue => 'புதிய மதிப்பு';

  @override
  String msInvSaveN(String n) {
    return '$n மதிப்புகளைச் சேமி';
  }

  @override
  String get msInvSaveEmpty => 'சேமி';

  @override
  String msInvSaved(String n, String amount) {
    return '$n மதிப்புகள் புதுப்பிக்கப்பட்டன. போர்ட்ஃபோலியோ $amount.';
  }

  @override
  String get msInvWithdrawAll => 'அனைத்தையும் எடு';

  @override
  String msInvValueLine(String amount) {
    return 'மதிப்பு $amount';
  }

  @override
  String get msInvRedeemed => 'எடுத்த தொகை';

  @override
  String get msInvExitLoad => 'வெளியேறும் கட்டணம் · விருப்பம்';

  @override
  String get msInvTax => 'வரி · விருப்பம்';

  @override
  String get msInvReceived => 'பெற்ற தொகை';

  @override
  String get msInvToAccount => 'எந்தக் கணக்குக்கு';

  @override
  String get msInvDate => 'தேதி';

  @override
  String get msInvAfter => 'இந்த எடுத்தலுக்குப் பின்';

  @override
  String msInvCloseTitle(String name) {
    return '$name ஐ மூடவா?';
  }

  @override
  String msInvCloseBody(String amount) {
    return 'நீங்கள் $amount பெற்றீர்கள். இதன் செயல்திறன் இதோ.';
  }

  @override
  String get msInvCloseInvested => 'முதலீடு';

  @override
  String get msInvCloseReceived => 'பெற்றது';

  @override
  String get msInvCloseReturn => 'இறுதி வருமானம்';

  @override
  String get msInvCloseXirr => 'XIRR';

  @override
  String get msInvCloseHeld => 'வைத்திருந்த காலம்';

  @override
  String msInvHeldValue(String n) {
    return '$n மாதங்கள்';
  }

  @override
  String get msInvCloseHelp =>
      'இது மூடப்பட்டவை பகுதிக்குச் செல்லும். திறந்து வரலாற்றைப் பார்க்கலாம்.';

  @override
  String get msInvCloseCta => 'முதலீட்டை மூடு';

  @override
  String get msInvBack => 'பின்செல்';

  @override
  String get msInvPenalty => 'அபராத வீதம்';

  @override
  String get msInvPenaltySupport =>
      'முதிர்வுக்கு முன் எடுத்தால் உங்கள் வங்கியின் அபராதம்';

  @override
  String get msInvRateAfterPenalty => 'அபராதத்துக்குப் பின் வீதம்';

  @override
  String get msInvInterestEarned => 'ஈட்டிய வட்டி';

  @override
  String get msInvLessThanToday => 'இன்றைய மதிப்பை விடக் குறைவு';

  @override
  String get msInvWithdrawClose => 'எடுத்து மூடு';

  @override
  String msInvMatured(String amount, String account) {
    return 'உங்கள் FD முதிர்ந்தது: $amount. அதை $account க்கு மாற்றவா?';
  }

  @override
  String msInvMaturedSub(String name, String date) {
    return '$name · $date அன்று முதிர்ந்தது';
  }

  @override
  String get msInvRenew => 'புதுப்பி';

  @override
  String msInvMove(String account) {
    return '$account க்கு மாற்று';
  }

  @override
  String msInvNotifTitle(String amount) {
    return 'உங்கள் FD முதிர்ந்தது: $amount';
  }

  @override
  String msInvNotifBody(String account) {
    return 'அதை $account க்கு மாற்றவா?';
  }

  @override
  String get msInvNotifLater => 'இப்போது வேண்டாம்';

  @override
  String msInvWithdrawName(String name) {
    return 'எடுத்தல் · $name';
  }

  @override
  String msInvMaturityName(String name) {
    return 'முதிர்வு · $name';
  }

  @override
  String msInvTopUpName(String name) {
    return 'கூடுதல் முதலீடு · $name';
  }

  @override
  String get msInvValuesUpdated => 'மதிப்பு புதுப்பிக்கப்பட்டது';

  @override
  String msInvClosedSnack(String name) {
    return '$name மூடப்பட்டவைக்கு மாற்றப்பட்டது';
  }

  @override
  String get msRecEveryMonth => 'மாதந்தோறும்';

  @override
  String get msRecOut => 'செலவு';

  @override
  String get msRecIn => 'வரவு';

  @override
  String get msRecBills => 'பில்கள் மற்றும் சந்தாக்கள்';

  @override
  String get msRecEmis => 'EMI';

  @override
  String get msRecSips => 'SIP';

  @override
  String get msRecIncome => 'வருமானம்';

  @override
  String get msRecActive => 'செயலில்';

  @override
  String get msRecPaused => 'இடைநிறுத்தப்பட்டவை';

  @override
  String get msRecProcessed => 'சமீபத்தில் செயலாக்கப்பட்டவை';

  @override
  String get msRecEnded => 'முடிந்தவை';

  @override
  String msRecRowSub(String interval, String date) {
    return '$interval · அடுத்தது $date';
  }

  @override
  String msRecNextOnly(String date) {
    return 'அடுத்தது $date';
  }

  @override
  String msRecDue(String interval, String account) {
    return '$interval · இன்று செலுத்த வேண்டும் · $account';
  }

  @override
  String msRecPausedSince(String interval, String month) {
    return '$interval · $month முதல் இடைநிறுத்தம்';
  }

  @override
  String get msRecViewHistory => 'வரலாற்றில் பார்';

  @override
  String get msRecEmptyTitle => 'இன்னும் எதுவும் மீண்டும் வருவதில்லை';

  @override
  String get msRecEmptyBody =>
      'வாடகை, பில்கள், சந்தாக்கள் அல்லது மீண்டும் வரும் வருமானத்தைச் சேர்க்கவும். கடன் EMI களும் SIP களும் இங்கே தானாகத் தோன்றும்.';

  @override
  String get msRecFab => 'தொடர் சேர்';

  @override
  String get msRecNew => 'புதிய தொடர்';

  @override
  String get msRecEdit => 'தொடரைத் திருத்து';

  @override
  String get msRecExpense => 'செலவு';

  @override
  String get msRecIncomeType => 'வருமானம்';

  @override
  String get msRecAmount => 'தொகை';

  @override
  String get msRecName => 'பெயர்';

  @override
  String get msRecCategory => 'வகை';

  @override
  String get msRecAccount => 'கணக்கு';

  @override
  String msRecSkipNext(String date) {
    return 'அடுத்ததைத் தவிர் · $date';
  }

  @override
  String get msRecSkipNextShort => 'அடுத்ததைத் தவிர்';

  @override
  String get msRecPause => 'இடைநிறுத்து';

  @override
  String get msRecResume => 'மீண்டும் தொடங்கு';

  @override
  String get msRecSave => 'தொடரைச் சேமி';

  @override
  String get msRecSaveChanges => 'மாற்றங்களைச் சேமி';

  @override
  String get msRecFutureTitle =>
      'மாற்றங்களை இனி வருபவற்றுக்கு மட்டும் பயன்படுத்தவா?';

  @override
  String msRecFutureBody(String name, String n) {
    return '$name $n முறை இயங்கியுள்ளது. அந்தப் பரிவர்த்தனைகள் அப்படியே இருக்கும். புதிய தொகையும் அட்டவணையும் அடுத்த முறையிலிருந்து தொடங்கும்.';
  }

  @override
  String get msRecFutureCta => 'இனி வருபவற்றுக்கு';

  @override
  String msRecSkipped(String date, String date2) {
    return '$date தவிர்க்கப்பட்டது. அடுத்தது $date2 அன்று.';
  }

  @override
  String msRecSkippedEnd(String date) {
    return '$date தவிர்க்கப்பட்டது.';
  }

  @override
  String get msRecUsually => 'வழக்கமாக';

  @override
  String get msRecLast12 => 'கடந்த 12 மாதங்கள்';

  @override
  String get msRecMonthlyAvg => 'மாத சராசரி';

  @override
  String get msRecProcessedKv => 'செயலாக்கப்பட்டது';

  @override
  String msRecProcessedN(String n) {
    return '$n முறை';
  }

  @override
  String get msRecMonthlyTotal => 'மாத மொத்தம்';

  @override
  String msRecAvgCaption(String amount) {
    return 'கடந்த 12 மாதங்கள் · சராசரி $amount';
  }

  @override
  String get msRecSkippedRow => 'தவிர்க்கப்பட்டது';

  @override
  String get msRecRange12 => '12 மாதங்கள்';

  @override
  String get msRecRangeAll => 'அனைத்தும்';

  @override
  String msRecDeleteTitle(String name) {
    return '$name ஐ நீக்கவா?';
  }

  @override
  String get msRecDeleteBody =>
      'இது மீண்டும் வருவது நிற்கும். ஏற்கனவே சேர்த்த பரிவர்த்தனைகள் வரலாற்றில் இருக்கும்.';

  @override
  String msRecPausedSnack(String name) {
    return '$name இடைநிறுத்தப்பட்டது';
  }

  @override
  String msRecResumedSnack(String name, String date) {
    return '$name மீண்டும் தொடங்கியது. அடுத்தது $date அன்று.';
  }

  @override
  String get msRecSaved => 'தொடர் சேமிக்கப்பட்டது';

  @override
  String get msCalcSave => 'சேமி';

  @override
  String get msCalcAddLoan => 'கடனாகச் சேர்';

  @override
  String get msCalcStartSip => 'இந்த SIP ஐத் தொடங்கு';

  @override
  String get msCalcAddFd => 'இந்த FD ஐச் சேர்';

  @override
  String get msCalcAddRd => 'இந்த RD ஐச் சேர்';

  @override
  String get msCalcAddInvestments => 'முதலீடுகளில் சேர்';

  @override
  String get msCalcEmi => 'EMI கணக்கீட்டி';

  @override
  String get msCalcPrepay => 'கடன் முன்கூட்டிய செலுத்தல்';

  @override
  String get msCalcSipAmount => 'SIP தொகை';

  @override
  String get msCalcGoal => 'இலக்குத் திட்டம்';

  @override
  String get msCalcReturns => 'முதலீட்டு வருமானம்';

  @override
  String get msCalcInflation => 'பணவீக்கம்';

  @override
  String get msCalcFdRd => 'FD / RD';

  @override
  String get msCalcPpf => 'PPF கணக்கீட்டி';

  @override
  String get msTxnSourceAuto => 'தானாகப் பதிவானது';

  @override
  String get msTxnSourceSip => 'SIP தவணை';

  @override
  String get msTxnSourceLabel => 'மூலம்';

  @override
  String get msTxnSplit => 'EMI பிரிப்பு';

  @override
  String get msTxnDeletedLoan => 'நீக்கப்பட்ட கடனிலிருந்து';

  @override
  String get msTxnDeletedInvestment => 'நீக்கப்பட்ட முதலீட்டிலிருந்து';

  @override
  String get msTxnDeletedRule => 'நீக்கப்பட்ட தொடர் விதியிலிருந்து';

  @override
  String bgStepProcessing(String n) {
    return '$n தொடர் பரிவர்த்தனைகள் சேர்க்கப்படுகின்றன…';
  }

  @override
  String get bgStepProcessingOne => '1 தொடர் பரிவர்த்தனை சேர்க்கப்படுகிறது…';

  @override
  String get bgStepMaturity => 'வைப்புகள் சரிபார்க்கப்படுகின்றன…';

  @override
  String get bgStepBackup => 'காப்புப்பிரதி எடுக்கப்படுகிறது…';

  @override
  String get bgStepStarting => 'புதுப்பிக்கப்படுகிறது…';

  @override
  String get bgContinues => 'பின்னணியில் தொடரும்';

  @override
  String bgResultRecurring(String n) {
    return '$n தொடர் சேர்க்கப்பட்டன';
  }

  @override
  String get bgResultRecurringOne => '1 தொடர் சேர்க்கப்பட்டது';

  @override
  String get bgResultBackup => 'காப்புப்பிரதி முடிந்தது';

  @override
  String bgResultMatured(String n) {
    return '$n வைப்புகள் முதிர்ந்தன';
  }

  @override
  String get bgFailBackup => 'காப்புப்பிரதி தோல்வி';

  @override
  String bgFailRecurring(String n) {
    return '$n தொடர் பரிவர்த்தனைகளைச் சேர்க்க முடியவில்லை';
  }

  @override
  String get bgFailRecurringOne =>
      '1 தொடர் பரிவர்த்தனையைச் சேர்க்க முடியவில்லை';

  @override
  String get bgRetry => 'மீண்டும் முயல்';

  @override
  String get bgView => 'பார்';

  @override
  String get bgChannelName => 'பின்னணிப் பணிகள்';

  @override
  String get bgChannelDesc =>
      'பின்னணியில் சேர்க்கப்பட்ட தொடர் பரிவர்த்தனைகள், EMI, SIP, காப்புப்பிரதிகள்';

  @override
  String get bgNotifTitle => 'Kuber புதுப்பிக்கப்படுகிறது';

  @override
  String get bgNotifFailedTitle => 'ஒரு பின்னணிப் பணி தோல்வியடைந்தது';

  @override
  String get numFormatAutomatic => 'தானியங்கி';

  @override
  String get numFormatAutomaticSub =>
      'ரூபாய்க்கு லட்சம், பிற நாணயங்களுக்கு நிலையான முறை';

  @override
  String get showCurrencyCode =>
      'குறியீட்டுக்குப் பதிலாக நாணயக் குறியீட்டைக் காட்டு';

  @override
  String get showCurrencyCodeSub =>
      'நாணயங்கள் ஒரே குறியைப் பகிரும்போது உதவும், எ.கா. C\$, A\$';

  @override
  String get currencySuggested => 'பரிந்துரைகள்';

  @override
  String get currencyAll => 'அனைத்து நாணயங்களும்';

  @override
  String get currencySearchHint => 'பெயர், குறியீடு அல்லது நாடு மூலம் தேடு';

  @override
  String get currencyNoMatch => 'எந்த நாணயமும் பொருந்தவில்லை';

  @override
  String converterUnavailable(String code) {
    return '$code மாற்றியில் இல்லை. அதன் வீதங்கள் ஐரோப்பிய மத்திய வங்கியின் பட்டியலிலிருந்து வருகின்றன, அதில் இது இல்லை.';
  }

  @override
  String get msInfoReducingTitle => 'குறையும் இருப்பு';

  @override
  String get msInfoReducingLine =>
      'பெரும்பாலான வங்கிக் கடன்கள். மீதமுள்ள தொகைக்கு மட்டுமே வட்டி, எனவே ஒவ்வொரு EMI யும் முந்தையதை விடச் சற்று அதிக அசலைச் செலுத்தும்.';

  @override
  String msInfoReducingEx(String p, String r, String y, String emi) {
    return '$p, $r வீதத்தில், $y ஆண்டுகளுக்கு, EMI $emi.';
  }

  @override
  String get msInfoReducingRow1 => 'முதல் மாத வட்டி';

  @override
  String get msInfoReducingRow2 => 'முதல் மாத அசல்';

  @override
  String get msInfoReducingAfter => 'இறுதியில் கிட்டத்தட்ட முழு EMI யும் அசல்.';

  @override
  String get msInfoFlatTitle => 'நிலையான வீதம் (Flat)';

  @override
  String get msInfoFlatLine =>
      'பல கார், தனிநபர், நுகர்வோர் கடன்கள். நீங்கள் செலுத்தினாலும் முழுக் காலத்துக்கும் அசல் தொகைக்கு வட்டி.';

  @override
  String msInfoFlatEx(String p, String r, String y) {
    return '$p, $r flat, $y ஆண்டுகளுக்கு.';
  }

  @override
  String get msInfoFlatRow1 => 'ஆண்டு வட்டி';

  @override
  String get msInfoFlatRow2 => 'மொத்த வட்டி';

  @override
  String get msInfoFlatRow3 => 'EMI';

  @override
  String msInfoFlatAfter(String r, String amount) {
    return '$r குறையும் இருப்பில் இதே கடனுக்கு வட்டி $amount ஆகும்.';
  }

  @override
  String get msInfoIoTitle => 'முதலில் வட்டி மட்டும் காலத்துடன்';

  @override
  String get msInfoIoLine =>
      'இதை ப்ரீ-EMI என்றும் சொல்வர். முதல் சில மாதங்கள் வட்டி மட்டும் செலுத்துவீர்கள். அதன் பின் வழக்கமான EMI தொடங்கும்.';

  @override
  String msInfoIoEx(String p, String r, String n) {
    return '$p, $r வீதத்தில், $n மாதங்கள் வட்டி மட்டும்.';
  }

  @override
  String msInfoIoRow1(String n) {
    return 'மாதம் 1 முதல் $n வரை';
  }

  @override
  String msInfoIoRow2(String n) {
    return 'பிறகு, $n மாதங்களுக்கு';
  }

  @override
  String msInfoIoRowValue(String amount) {
    return 'மாதம் $amount';
  }

  @override
  String get msInfoIoAfter => 'வட்டி மட்டும் மாதங்களில் நிலுவை குறையாது.';

  @override
  String get msInfoCalculatedTitle => 'கணக்கிடப்படும் புலங்கள்';

  @override
  String get msInfoCalculatedLine =>
      'அசல், வீதம், காலம், EMI இல் ஏதேனும் 3 ஐ நிரப்பவும். Kuber நான்காவதைக் கணக்கிட்டு \"கணக்கிடப்பட்டது\" எனக் குறிக்கும்.';

  @override
  String get msInfoCalculatedAfter =>
      'உங்கள் எண்ணைப் பயன்படுத்த கணக்கிடப்பட்ட புலத்தில் தட்டச்சு செய்யவும். அப்போது நீங்கள் முதலில் நிரப்பிய புலம் கணக்கிடப்படும்.';

  @override
  String get msInfoMismatchTitle => 'உங்கள் EMI ஏன் வேறுபடுகிறது';

  @override
  String get msInfoMismatchLine =>
      'வங்கிகள் EMI ஐ முழுமையாக்கலாம், கடன் காப்பீட்டைச் சேர்க்கலாம் அல்லது முதல் EMI க்கு முந்தைய நாட்களுக்கு வட்டி வசூலிக்கலாம். Kuber எப்போதும் நீங்கள் உள்ளிட்ட EMI ஐயே பயன்படுத்தும்.';

  @override
  String get msInfoMismatchRow1 => 'கணக்கிட்ட EMI';

  @override
  String get msInfoMismatchRow2 => 'உங்கள் EMI';

  @override
  String get msInfoMismatchRow3 => 'வேறுபாடு';

  @override
  String get msInfoRun1Title => 'கடனின் அசல் விவரங்கள் எனக்குத் தெரியும்';

  @override
  String get msInfoRun1Line =>
      'கடன் அனுமதிக்கப்பட்டபடி உள்ளிடவும். இன்று வரை நீங்கள் செலுத்திய அனைத்தையும் Kuber கணக்கிடும்.';

  @override
  String get msInfoRun2Title => 'இன்றைய நிலுவை எனக்குத் தெரியும்';

  @override
  String get msInfoRun2Line =>
      'சமீபத்திய வங்கி அறிக்கையிலிருந்து நிலுவைத் தொகையைப் பயன்படுத்தவும். எத்தனை EMI மீதம் என்று Kuber கணக்கிடும்.';

  @override
  String get msInfoRun2After =>
      'முந்தைய மொத்தங்கள் விருப்பமானவை. வாழ்நாள் வட்டி முழுமையாக வேண்டுமெனில் சேர்க்கவும்.';

  @override
  String get msInfoRun3Title => 'EMI ஐ மட்டும் கண்காணி';

  @override
  String get msInfoRun3Line =>
      'Kuber ஒவ்வொரு EMI யையும் அதன் நாளில் அசல், வட்டி என்று பிரிக்காமல் பதிவு செய்யும். கடன் எண்களைப் பின்னர் சேர்க்கலாம்.';

  @override
  String get msInfoAdjustmentTitle => 'சரிசெய்தல்';

  @override
  String get msInfoAdjustmentLine =>
      'உங்கள் எண் Kuber இன் எண்ணிலிருந்து வேறுபட்டால், Kuber உங்களுடையதை வைத்து வேறுபாட்டைக் கடனில் தொடக்கச் சரிசெய்தலாகப் பதிவு செய்யும்.';

  @override
  String get msInfoAdjustmentRow1 => 'Kuber கணக்கிட்டது';

  @override
  String get msInfoAdjustmentRow2 => 'நீங்கள் உள்ளிட்டது';

  @override
  String get msInfoAdjustmentAfter =>
      'சரிசெய்தல் கடனை மட்டுமே மாற்றும். எந்தக் கணக்கின் இருப்பும் மாறாது.';

  @override
  String get msInfoInterestOnlyTitle => 'வட்டியை மட்டும் செலவாகக் கணக்கிடு';

  @override
  String get msInfoInterestOnlyLine =>
      'Analytics, பட்ஜெட்டுகளில் ஒவ்வொரு EMI யின் வட்டிப் பகுதி மட்டுமே செலவாகக் கணக்கிடப்படும். அசல் இந்தக் கடனுக்கு மாற்றமாகக் கணக்கிடப்படும்.';

  @override
  String get msInfoInterestOnlyRow1 => 'வட்டி, செலவாக';

  @override
  String get msInfoInterestOnlyRow2 => 'அசல், மாற்றமாக';

  @override
  String get msInfoInterestOnlyAfter =>
      'எப்படியிருந்தாலும் உங்கள் வங்கி இருப்பு முழு EMI அளவு குறையும். இந்த மாற்றம் இனி வரும் EMI களுக்கு மட்டும்.';

  @override
  String get msInfoTenureEmiTitle => 'காலத்தைக் குறைப்பதா, EMI ஐக் குறைப்பதா';

  @override
  String get msInfoTenureEmiLine =>
      'காலத்தைக் குறைத்தால் EMI அப்படியே இருக்கும், கடன் விரைவில் முடியும். EMI ஐக் குறைத்தால் முடிவுத் தேதி அப்படியே இருக்கும், ஒவ்வொரு EMI யும் குறையும். காலத்தைக் குறைப்பது அதிக வட்டியைச் சேமிக்கும்.';

  @override
  String get msInfoPrepayChargeTitle => 'முன்கூட்டிய செலுத்தல் கட்டணம்';

  @override
  String get msInfoPrepayChargeLine =>
      'சில கடன் வழங்குநர்கள் கூடுதல் செலுத்தலுக்குக் கட்டணம் வசூலிப்பர். Kuber அதைச் செலவாகப் பதிவு செய்யும். அது நிலுவையைக் குறைக்காது. மிதக்கும் வீத வீட்டுக் கடன்களில் பொதுவாக இது இருக்காது.';

  @override
  String get msInfoPrepayRow1 => 'அசலுக்குச் செல்கிறது';

  @override
  String get msInfoPrepayRow2 => 'கட்டணம், செலவாகப் பதிவு';

  @override
  String get msInfoPrepayRow3 => 'உங்கள் கணக்கிலிருந்து செல்கிறது';

  @override
  String get msInfoFloatingTitle => 'மிதக்கும் வீதம்';

  @override
  String get msInfoFloatingLine =>
      'மிதக்கும் வீதம் கடன் வழங்குநரின் அளவுகோலுடன் மாறும், எனவே கடன் காலத்தில் மாறலாம். அவர்கள் மாற்றும்போது இங்கே பதிவு செய்யவும், அட்டவணை சரியாக இருக்கும்.';

  @override
  String get msInfoXirrTitle => 'XIRR';

  @override
  String get msInfoXirrLine =>
      'ஒவ்வொரு தொகையும் எப்போது உள்ளே வந்தது, எப்போது வெளியே சென்றது என்பதைக் கணக்கில் கொண்ட உங்கள் ஆண்டு வருமானம். இதனால் SIP ஐயும் FD யையும் நியாயமாக ஒப்பிடலாம்.';

  @override
  String msInfoXirrEx(String amount, String invested, String value) {
    return '3 ஆண்டுகள் மாதம் $amount என்றால் $invested முதலீடு. இன்று அதன் மதிப்பு $value.';
  }

  @override
  String get msInfoXirrRow1 => 'மொத்த லாபம்';

  @override
  String get msInfoXirrRow2 => 'XIRR';

  @override
  String msInfoXirrValue(String pct) {
    return 'ஆண்டுக்கு $pct';
  }

  @override
  String get msInfoRealizedTitle => 'உணரப்படாத, உணரப்பட்ட லாபம்';

  @override
  String get msInfoRealizedLine =>
      'உணரப்படாத லாபம் காகிதத்தில் உள்ளது: இன்று அனைத்தையும் விற்றால் கிடைக்கும் லாபம். உணரப்பட்ட லாபம் ஏற்கனவே எடுத்த பணத்தில் நீங்கள் உண்மையில் ஈட்டியது.';

  @override
  String get msInfoProportionalTitle => 'எடுத்தல் எப்படிக் கணக்கிடப்படுகிறது';

  @override
  String get msInfoProportionalLine =>
      'ஒரு முதலீட்டின் ஒரு பகுதியை எடுக்கும்போது, எடுத்த மதிப்பின் அதே விகிதத்தில் முதலீட்டுத் தொகை குறையும்.';

  @override
  String msInfoProportionalEx(String value, String invested, String amount) {
    return 'மதிப்பு $value, முதலீடு $invested. நீங்கள் $amount எடுக்கிறீர்கள், இது மதிப்பின் 20%.';
  }

  @override
  String get msInfoProportionalRow1 => 'முதலீடு இவ்வளவு குறையும்';

  @override
  String get msInfoProportionalRow2 => 'உணரப்பட்ட லாபம்';

  @override
  String get msInfoProportionalRow3 => 'மீதமுள்ள முதலீடு';

  @override
  String get msInfoStepupTitle => 'ஆண்டு அதிகரிப்பு';

  @override
  String get msInfoStepupLine =>
      'உங்கள் SIP ஆண்டுக்கு ஒருமுறை நிலையான சதவீதம் அல்லது தொகையில் அதிகரிக்கும், பொதுவாக உங்கள் சம்பளத்துடன்.';

  @override
  String msInfoStepupEx(String amount) {
    return 'மாதம் $amount, 10% அதிகரிப்புடன்.';
  }

  @override
  String msInfoStepupRow(String n) {
    return 'ஆண்டு $n';
  }

  @override
  String get msInfoCompoundingTitle => 'கூட்டு வட்டி';

  @override
  String get msInfoCompoundingLine =>
      'உங்கள் வைப்பில் எத்தனை முறை வட்டி சேர்க்கப்படுகிறது, அதனால் அதுவும் வட்டி ஈட்டும். அடிக்கடி என்றால் சற்று அதிகம்.';

  @override
  String msInfoCompoundingEx(String amount) {
    return '$amount, 7% வீதத்தில் 5 ஆண்டுகளுக்கு.';
  }

  @override
  String get msInfoPayoutTitle => 'செலுத்தும் வகை';

  @override
  String get msInfoPayoutLine =>
      'திரட்டு முறையில் வட்டி வைப்பில் சேர்ந்து முதிர்வில் அனைத்தும் கிடைக்கும். செலுத்தும் முறையில் வட்டி மாதம், காலாண்டு அல்லது ஆண்டுக்கு ஒருமுறை உங்கள் வங்கிக் கணக்குக்கு வரும்.';

  @override
  String get msInfoPayoutRow1 => 'திரட்டு, முதிர்வில்';

  @override
  String get msInfoPayoutRow2 => 'காலாண்டுச் செலுத்தல்';

  @override
  String msInfoPayoutRow2Value(String amount) {
    return 'ஒவ்வொரு காலாண்டும் $amount';
  }

  @override
  String get msInfoPayoutRow3 => 'காலாண்டுச் செலுத்தல், முதிர்வில்';

  @override
  String get msInfoAccruedTitle => 'இன்றைய மதிப்பு';

  @override
  String get msInfoAccruedLine =>
      'இதுவரை ஈட்டிய ஆனால் இன்னும் செலுத்தப்படாத வட்டியையும் சேர்த்து நிலை வைப்பின் இன்றைய மதிப்பு. Kuber தினமும் கணக்கிடுவதால் நீங்கள் புதுப்பிக்க வேண்டியதில்லை.';

  @override
  String get msInfoUpdatedTitle => 'கடைசிப் புதுப்பிப்பு';

  @override
  String get msInfoUpdatedLine =>
      'சந்தை விலைகள் தினமும் மாறும், ஆனால் நீங்கள் கடைசியாக உள்ளிட்ட மதிப்பு மட்டுமே Kuber க்குத் தெரியும். 30 நாளுக்கு மேல் பழைய மதிப்புகள் குறிக்கப்படும், எதைப் புதுப்பிக்க வேண்டும் என்று தெரியும்.';

  @override
  String get msInfoMonthlyTitle => 'மாதத் தொகை எப்படிக் கணக்கிடப்படுகிறது';

  @override
  String get msInfoMonthlyLine =>
      'மாதாந்திரமில்லாதவை மாதச் செலவாக மாற்றப்படும். கடன்களிலோ முதலீடுகளிலோ தோன்றினாலும் ஒவ்வொன்றும் ஒருமுறை மட்டுமே கணக்கிடப்படும்.';

  @override
  String msInfoMonthlyRow1(String amount) {
    return 'ஆண்டுக்கு $amount';
  }

  @override
  String msInfoMonthlyRow2(String amount) {
    return 'ஒவ்வொரு 3 மாதமும் $amount';
  }

  @override
  String msInfoMonthlyRow3(String amount) {
    return 'வாரந்தோறும் $amount';
  }

  @override
  String get msInfoMonthlyAfter =>
      'வாரங்களுக்கு 52 வாரங்கள் ÷ 12. தினசரிக்கு மாதம் 30 நாட்கள்.';

  @override
  String get msRecUndo => 'செயல்தவிர்';

  @override
  String get msLoansFirstEmiDate => 'முதல் EMI தேதி';

  @override
  String get msLoansNextEmiDate => 'அடுத்த EMI தேதி';

  @override
  String get appDrawerSection => 'ஆப் டிராயர்';

  @override
  String get appDrawerDescription =>
      'Kuber Cards, Notes அல்லது Reminders க்கு உங்கள் ஃபோனின் ஆப் பட்டியலில் தனி ஐகான் கொடுக்கவும்.';

  @override
  String get appDrawerAdd => 'ஆப் டிராயரில் சேர்';

  @override
  String get appDrawerRemove => 'ஆப் டிராயரிலிருந்து நீக்கு';

  @override
  String get appDrawerCards => 'Kuber Cards';

  @override
  String get appDrawerNotes => 'Kuber Notes';

  @override
  String get appDrawerReminders => 'நினைவூட்டல்கள்';

  @override
  String appDrawerAdded(String name) {
    return '$name ஆப் டிராயரில் சேர்க்கப்பட்டது. தோன்றச் சிறிது நேரம் ஆகலாம்.';
  }

  @override
  String appDrawerRemoved(String name) {
    return '$name ஆப் டிராயரிலிருந்து நீக்கப்பட்டது';
  }

  @override
  String get appDrawerFailed =>
      'ஆப் டிராயரை மாற்ற முடியவில்லை. மீண்டும் முயலவும்.';

  @override
  String get msLoansChangeRateShort => 'வீதம் மாற்று';

  @override
  String msLoansPageOf(String n, String total) {
    return 'ஆண்டு $n / $total';
  }

  @override
  String get msLoansPrevYear => 'முந்தைய ஆண்டு';

  @override
  String get msLoansNextYear => 'அடுத்த ஆண்டு';

  @override
  String get msLoansRecordAutoHelpNoAccount =>
      'EMI நாளில் நீங்கள் செலுத்தும் கணக்கிலிருந்து Kuber EMI ஐப் பதிவு செய்யும்.';

  @override
  String get betaTag => 'பீட்டா';

  @override
  String get appDrawerCardsSub => 'Kuber Cards ஐ ஆப் டிராயரில் சேர்';

  @override
  String get appDrawerNotesSub => 'Kuber Notes ஐ ஆப் டிராயரில் சேர்';

  @override
  String get appDrawerRemindersSub => 'நினைவூட்டல்களை ஆப் டிராயரில் சேர்';

  @override
  String get msLoansViewSchedule => 'EMI அட்டவணையைப் பார்';

  @override
  String get msLoansExtraChoose => 'எது மாற வேண்டும்?';

  @override
  String get msLoansExtraHelp =>
      'கூடுதல் கட்டணம் நிலுவையைக் குறைக்கும், எனவே இனி குறைந்த வட்டி. அந்தச் சேமிப்பு எப்படி வேண்டும் என்று தேர்ந்தெடுக்கவும்.';

  @override
  String msLoansReduceTenureHow(String emi) {
    return 'மாதம் $emi செலுத்துவதைத் தொடருங்கள். கடன் விரைவில் முடியும்.';
  }

  @override
  String get msLoansReduceEmiHow =>
      'முடிவுத் தேதி அப்படியே இருக்கும். ஒவ்வொரு EMI யும் குறையும்.';

  @override
  String msLoansReduceTenureResult(String emi, String month, String n) {
    return 'EMI $emi ஆகவே இருக்கும் · $month இல் முடியும், $n மாதங்கள் முன்பே';
  }

  @override
  String msLoansReduceEmiResult(String month, String emi) {
    return 'இப்போது போல் $month இல் முடியும் · EMI $emi ஆகும்';
  }

  @override
  String get communityTelegramTitle => 'Kuber சமூகத்தில் சேருங்கள்';

  @override
  String get communityTelegramSubtitle =>
      'செய்திகள், குறிப்புகள் மற்றும் உதவிக்கான அதிகாரப்பூர்வ Telegram சேனல்';

  @override
  String get ueTitle => 'வரவிருக்கும் நிகழ்வுகள்';

  @override
  String get ueViewList => 'பட்டியல்';

  @override
  String get ueViewCalendar => 'நாட்காட்டி';

  @override
  String get ueFilter => 'வடிகட்டி';

  @override
  String get ueFilterHint => 'பட்டியல், நாட்காட்டி இரண்டுக்கும் பொருந்தும்.';

  @override
  String get ueFilterShow => 'காட்டு';

  @override
  String get ueFilterType => 'வகை';

  @override
  String get ueFilterReset => 'மீட்டமை';

  @override
  String ueA11yFilter(int count) {
    return 'வடிகட்டி, $count பயன்படுத்தப்பட்டது';
  }

  @override
  String get ueRange7 => 'அடுத்த 7 நாட்கள்';

  @override
  String get ueRange30 => 'அடுத்த 30 நாட்கள்';

  @override
  String get ueRange90 => 'அடுத்த 90 நாட்கள்';

  @override
  String get ueTypeAll => 'அனைத்தும்';

  @override
  String get ueTypeReminders => 'நினைவூட்டல்கள்';

  @override
  String get ueTypeEmis => 'EMIகள்';

  @override
  String get ueTypeSips => 'SIPகள்';

  @override
  String get ueTypeRecurring => 'தொடர்ச்சியானவை';

  @override
  String get ueTypeLedger => 'லெட்ஜர்';

  @override
  String get uePillReminder => 'நினைவூட்டல்';

  @override
  String get uePillEmi => 'EMI';

  @override
  String get uePillSip => 'SIP';

  @override
  String get uePillFd => 'FD';

  @override
  String get uePillRecurring => 'தொடர்ச்சி';

  @override
  String get uePillLedger => 'லெட்ஜர்';

  @override
  String get uePillCard => 'கிரெடிட் கார்டு';

  @override
  String ueEmptyList(int days) {
    return 'அடுத்த $days நாட்களில் நிகழ்வுகள் இல்லை';
  }

  @override
  String get ueEmptyListHint =>
      'நினைவூட்டல்கள், EMI, SIP, தொடர்ச்சியானவை, லெட்ஜர் தேதிகள் இங்கே தெரியும்.';

  @override
  String ueOutAmount(String amount) {
    return '$amount செலவு';
  }

  @override
  String ueInAmount(String amount) {
    return '$amount வரவு';
  }

  @override
  String ueCardBills(String amount) {
    return 'கார்டு பில்கள் $amount';
  }

  @override
  String ueDayToday(String date) {
    return 'இன்று, $date';
  }

  @override
  String get ueCardNote =>
      'கார்டு பில்கள் மொத்தத்தில் இல்லை. கார்டைப் பயன்படுத்தியபோதே அந்தச் செலவு பதிவானது.';

  @override
  String get ueEmptyDay => 'இந்த நாளுக்கு எதுவும் திட்டமிடப்படவில்லை';

  @override
  String get ueEmptyMonth => 'இந்த மாதம் எதுவும் திட்டமிடப்படவில்லை';

  @override
  String get ueStatusUpcoming => 'வரவிருக்கிறது';

  @override
  String get ueStatusConfirm => 'உறுதிப்படுத்த வேண்டும்';

  @override
  String get ueStatusDone => 'முடிந்தது';

  @override
  String get ueStatusSkipped => 'தவிர்க்கப்பட்டது';

  @override
  String get ueStatusOverdue => 'நிலுவையில்';

  @override
  String get ueLegendTitle => 'நாட்காட்டி பற்றி';

  @override
  String get ueLegendIntro =>
      'ஒவ்வொரு புள்ளியும் ஒரு நிகழ்வு. 3 புள்ளிகள் வரை, பிறகு எண்ணிக்கை.';

  @override
  String get ueLegendReminders => 'நினைவூட்டல்கள்';

  @override
  String get ueLegendEmis => 'EMIகள்';

  @override
  String get ueLegendSips => 'SIP, FD';

  @override
  String get ueLegendRecurring => 'தொடர்ச்சியானவை';

  @override
  String get ueLegendLedger => 'கொடுத்தது, வாங்கியது';

  @override
  String get ueLegendCards => 'கிரெடிட் கார்டுகள்';

  @override
  String get ueLegendDays => 'நாட்கள்';

  @override
  String get ueLegendToday => 'இன்று';

  @override
  String get ueLegendSelected => 'தேர்ந்தெடுத்தது';

  @override
  String get ueLegendOverdue => 'நிலுவை';

  @override
  String get ueLegendSkipped => 'தவிர்த்தது';

  @override
  String get ueLegendOtherMonth => 'வேறு மாதம்';

  @override
  String get ueLegendTotals =>
      'செலவும் வரவும் மாதத்தின் மொத்தம், தவிர்த்தவையும் தொகை இல்லாத நினைவூட்டல்களும் இன்றி. கார்டு பில்கள் தனியே காட்டப்படும், ஏனெனில் கார்டைப் பயன்படுத்தியபோதே அந்தச் செலவு பதிவானது.';

  @override
  String ueA11yToday(String date) {
    return 'இன்று, $date';
  }

  @override
  String get ueA11ySelected => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String ueA11yEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நிகழ்வுகள்',
      one: '1 நிகழ்வு',
      zero: 'நிகழ்வுகள் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String ueA11yDue(String amount) {
    return '$amount செலுத்த வேண்டும்';
  }

  @override
  String ueA11yCardBill(String amount) {
    return 'கார்டு பில் $amount';
  }

  @override
  String ueA11yOverdue(int count) {
    return '$count நிலுவை';
  }

  @override
  String ueA11yConfirm(int count) {
    return '$count உறுதிப்படுத்த வேண்டும்';
  }

  @override
  String get ueA11yHidden => 'தொகைகள் மறைக்கப்பட்டன';

  @override
  String ueA11yOtherMonthNext(String date) {
    return '$date, அடுத்த மாதம்';
  }

  @override
  String ueA11yOtherMonthPrev(String date) {
    return '$date, முந்தைய மாதம்';
  }

  @override
  String ueA11yPrevMonth(String month) {
    return 'முந்தைய மாதம், $month';
  }

  @override
  String ueA11yNextMonth(String month) {
    return 'அடுத்த மாதம், $month';
  }

  @override
  String ueA11yWeekCollapsed(String date) {
    return '$date வாரம், சுருக்கப்பட்டது. மாதத்தைக் காண இருமுறை தட்டவும்.';
  }

  @override
  String get ueA11yHandle => 'முழு மாதத்தையும் காட்டு';

  @override
  String get themeExpressiveTitle => 'வண்ணமயமான பின்னணி';

  @override
  String get themeExpressiveSubtitle => 'பின்னணிக்கு தீம் நிறச் சாயல்';

  @override
  String get themePureBlackTitle => 'முழு கருப்பு';

  @override
  String get themePureBlackSubtitle =>
      'இருண்ட பயன்முறையில் கருப்பு பின்னணி. OLED திரைகளில் பேட்டரியைச் சேமிக்கும்.';

  @override
  String get themePureBlackHelperSystem =>
      'உங்கள் போன் இருண்ட பயன்முறையில் இருக்கும்போது பொருந்தும்';

  @override
  String get themePureBlackDisabledA11y =>
      'முழு கருப்பு. அணைக்கப்பட்டது. இருண்ட பயன்முறையில் வேலை செய்யும்.';

  @override
  String get msLoansReopen => 'கடனை மீண்டும் திற';

  @override
  String msLoansReopenTitle(String name) {
    return '$name மீண்டும் திறக்கவா?';
  }

  @override
  String get msLoansReopenBody =>
      'இதன் EMI அடுத்த தேதியிலிருந்து மீண்டும் தொடங்கும். மூடியிருந்த காலத்துக்கு எதுவும் சேர்க்கப்படாது.';

  @override
  String get msLoansUpdateOutstanding => 'நிலுவையைப் புதுப்பி';

  @override
  String get msLoansOutstandingPrincipal => 'நிலுவை அசல்';

  @override
  String get msLoansAsOn => 'இந்தத் தேதியில்';

  @override
  String get msLoansAdjReason => 'காரணம்';

  @override
  String get msLoansAdjMatchBank => 'வங்கி அறிக்கையுடன் பொருத்து';

  @override
  String get msLoansAdjMatchBankSub =>
      'உங்கள் வங்கி வேறு நிலுவையைக் காட்டுகிறது.';

  @override
  String get msLoansAdjInterestAdded =>
      'செலுத்தாத வட்டி கடனில் சேர்க்கப்பட்டது';

  @override
  String get msLoansAdjInterestAddedSub =>
      'உங்கள் வங்கி வட்டியை நிலுவையில் சேர்த்தது, மொராட்டோரியம் காலம் போல.';

  @override
  String msLoansKuberOutstandingOn(String date) {
    return '$date அன்று Kuber நிலுவை';
  }

  @override
  String get msLoansAdjDifference => 'வேறுபாடு';

  @override
  String get msLoansKeepEmiChangeEnd => 'EMI அதே, முடிவுத் தேதி மாறும்';

  @override
  String get msLoansKeepEndChangeEmi => 'முடிவுத் தேதி அதே, EMI மாறும்';

  @override
  String msLoansKeepEmiResult(String emi, String month) {
    return 'EMI $emi இருக்கும் · $month-ல் முடியும்';
  }

  @override
  String msLoansKeepEndResult(String month, String emi) {
    return '$month-ல் முடியும் · EMI $emi ஆகும்';
  }

  @override
  String get msLoansRemainingInterest => 'மீதமுள்ள வட்டி';

  @override
  String get msLoansAdjErrNegative =>
      'நிலுவை 0-க்குக் குறைவாக இருக்க முடியாது.';

  @override
  String get msLoansAdjZeroTitle => 'செலுத்த எதுவும் இல்லையா?';

  @override
  String get msLoansAdjZeroBody =>
      '0 நிலுவை என்றால் கடன் முடிந்தது. மூடியதாகக் குறிக்கவா?';

  @override
  String get msLoansAdjSaveOnly => 'சேமி மட்டும்';

  @override
  String get msLoansAdjSaved => 'நிலுவை புதுப்பிக்கப்பட்டது';

  @override
  String msLoansEventAdjusted(String amount, String date) {
    return 'நிலுவை புதுப்பிப்பு $amount · $date';
  }

  @override
  String msLoansEventInterestAdded(String amount, String date) {
    return 'கடனில் வட்டி சேர்ப்பு $amount · $date';
  }

  @override
  String get msLoansEventAdjSubTenure => 'EMI மாறவில்லை, முடிவுத் தேதி மாறியது';

  @override
  String get msLoansEventAdjSubEmi => 'முடிவுத் தேதி அதே, EMI மாறியது';

  @override
  String get msLoansEventDeleted => 'நீக்கப்பட்டது';

  @override
  String get msLoansInterestAdded => 'கடனில் சேர்ந்த வட்டி';

  @override
  String msLoansRecalcTitle(int count) {
    return 'நீங்கள் மாற்றாத அடுத்த $count EMI-களின் பிரிப்பை மீண்டும் கணக்கிடவா?';
  }

  @override
  String msLoansRecalcBody(String before, String after) {
    return 'அந்த EMI-களின் வட்டி இப்போது $before, மீண்டும் கணக்கிட்டால் $after. நீங்கள் மாற்றிய EMI-கள் அப்படியே இருக்கும்.';
  }

  @override
  String get msLoansRecalc => 'மீண்டும் கணக்கிடு';

  @override
  String get msLoansKeepAsIs => 'அப்படியே வை';

  @override
  String msLoansRecalcDone(int count) {
    return '$count EMI-கள் புதுப்பிக்கப்பட்டன';
  }

  @override
  String get msLoansDeleteExtraTitle => 'இந்தக் கூடுதல் கட்டணத்தை நீக்கவா?';

  @override
  String get msLoansDeleteExtraBody =>
      'இதன் பரிவர்த்தனைகளும் நீக்கப்படும், நிலுவை மீண்டும் உயரும்.';

  @override
  String get msLoansDeleteAdjTitle => 'இந்தப் புதுப்பிப்பை நீக்கவா?';

  @override
  String get msLoansDeleteAdjBody =>
      'நிலுவை மீண்டும் Kuber கணக்குக்குத் திரும்பும்.';

  @override
  String get msTxnEdited => 'மாற்றப்பட்டது';

  @override
  String get msTxnSplitHelper =>
      'உங்கள் வங்கியுடன் பொருத்த இவற்றை மாற்றுங்கள். இவை எப்போதும் EMI-க்குச் சமம்.';

  @override
  String get msTxnSplitErr =>
      'அசலும் வட்டியும் 0-க்குக் குறைவாக இருக்க முடியாது.';

  @override
  String get msInfoSplitEditedTitle => 'மாற்றிய பிரிப்பு';

  @override
  String get msInfoSplitEditedLine =>
      'உங்கள் வங்கியுடன் பொருந்த இந்தப் பிரிப்பை மாற்றினீர்கள். Kuber நிலுவைக்கு உங்கள் எண்களைப் பயன்படுத்தி அங்கிருந்து வரும் EMI-களைக் கணிக்கிறது.';

  @override
  String get msInfoAdjustBankLine =>
      'வங்கி அறிக்கையில் நிலுவை Kuber-இலிருந்து வேறுபடும்போது இதைப் பயன்படுத்துங்கள். Kuber அந்தத் தேதியிலிருந்து உங்கள் எண்ணிலிருந்து தொடரும்.';

  @override
  String get msInfoAdjustInterestLine =>
      'சில வங்கிகள் செலுத்தாத வட்டியை, மொராட்டோரியம் அல்லது EMI தொடங்கும் முன் போல, நிலுவையில் சேர்க்கும். இது கடனின் மொத்த வட்டியில் சேரும். உங்கள் கணக்கிலிருந்து பணம் செல்லாததால் இது செலவு அல்ல.';

  @override
  String get msInfoRemainingLine =>
      'மீதமுள்ள வட்டி உங்கள் நிலுவை, விகிதம், EMI ஆகியவற்றைப் பொறுத்தது, எனவே Kuber இதைக் கணக்கிடுகிறது. பதிலாக நிலுவை அல்லது விகிதத்தைப் புதுப்பியுங்கள்.';

  @override
  String get msLoansPastEmis => 'முந்தைய EMI-களைப் பரிவர்த்தனைகளாகச் சேர்';

  @override
  String get msInfoPastEmisLine =>
      'கடன் ஏற்கனவே ஓடிய ஒவ்வொரு மாதத்துக்கும் Kuber ஒரு EMI பரிவர்த்தனையை அசல், வட்டியுடன் சேர்க்கும். எந்தக் கட்டணம் போலவும் உங்கள் கணக்கு இருப்பு மொத்தத் தொகையால் குறையும். முந்தைய பரிவர்த்தனைகள் இல்லாமல் இன்றிலிருந்து தொடங்க இதை அணைத்து வையுங்கள்.';

  @override
  String get msLoansPastEmisHelp =>
      'முதல் EMI தேதியிலிருந்து இன்று வரை ஒவ்வொரு EMI-யையும் பரிவர்த்தனையாக உருவாக்கும்.';

  @override
  String msLoansPastEmisPreview(
    int count,
    String from,
    String to,
    String account,
    String amount,
  ) {
    return '$from முதல் $to வரை $count EMI-களைச் சேர்த்து $account இருப்பை $amount குறைக்கும்.';
  }

  @override
  String msLoansPastEmisPreviewNoAccount(
    int count,
    String from,
    String to,
    String amount,
  ) {
    return '$from முதல் $to வரை $count EMI-களைச் சேர்க்கும், மொத்தம் $amount.';
  }

  @override
  String msLoansPastEmisRemoveTitle(int count) {
    return 'இந்த ஸ்விட்ச் சேர்த்த $count முந்தைய EMI-களை நீக்கவா?';
  }

  @override
  String get msLoansPastEmisRemoveBody =>
      'நீங்கள் மாற்றிய EMI-கள் இருக்கும். நீக்கியவற்றின் அளவு கணக்கு இருப்பு மீண்டும் உயரும்.';

  @override
  String get msLoansKeep => 'வை';

  @override
  String get msLoansRemove => 'நீக்கு';

  @override
  String msLoansPastEmisRemoved(int removed, int kept) {
    return '$removed முந்தைய EMI-கள் நீக்கப்பட்டன. நீங்கள் மாற்றிய $kept வைக்கப்பட்டன.';
  }

  @override
  String get bgStepPastEmis => 'முந்தைய EMI-கள் சேர்க்கப்படுகின்றன…';

  @override
  String bgJobPercent(String text, int percent) {
    return '$text $percent%';
  }

  @override
  String bgJobsRunning(String text, int count) {
    return '$text ($count பணிகள்)';
  }

  @override
  String get bgJobFailed => 'ஏதோ தவறு நடந்தது';

  @override
  String get bgDetails => 'விவரங்கள்';

  @override
  String get bgDetailsTitle => 'என்ன தவறு';

  @override
  String get bgAddedOne => '1 பரிவர்த்தனை சேர்க்கப்பட்டது';

  @override
  String bgAdded(int count) {
    return '$count பரிவர்த்தனைகள் சேர்க்கப்பட்டன';
  }

  @override
  String get bgBackupSaved => 'காப்புப் பிரதி சேமிக்கப்பட்டது';

  @override
  String get accountTypeOverdraft => 'ஓவர்டிராஃப்ட்';

  @override
  String get accountOverdraftHint => 'எ.கா. HDFC ஓவர்டிராஃப்ட்';

  @override
  String get accountOverdraftSub =>
      'நீங்கள் செலுத்த வேண்டிய பணத்துக்கு, ஓவர்டிராஃப்ட் போல.';

  @override
  String get accountOverdraftInfoLine =>
      'நீங்கள் செலுத்த வேண்டிய பணத்துக்கு இதைப் பயன்படுத்துங்கள், ஓவர்டிராஃப்ட் அல்லது கிரெடிட் லைன் போல. Loans-இல் கண்காணிக்கும் EMI-கள் இன்னும் அங்கு தேர்ந்தெடுத்த கணக்கிலிருந்தே செல்லும்.';

  @override
  String get accountAmountOwed => 'நிலுவைத் தொகை';

  @override
  String get accountLimitOptional => 'வரம்பு (விருப்பம்)';

  @override
  String accountAvailable(String amount) {
    return 'கிடைப்பது $amount';
  }

  @override
  String get accountOwedLabel => 'நிலுவை';

  @override
  String accountOverLimit(String amount) {
    return 'இது வரம்பை $amount மீறுகிறது.';
  }

  @override
  String get smsTodayLabel => 'இன்று பதிவாகாதவை';

  @override
  String get smsTodaySpentLabel => 'செலவு';

  @override
  String get smsTodayReceivedLabel => 'வரவு';

  @override
  String smsTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS இன்னும் சேர்க்கப்படவில்லை',
      one: '1 SMS இன்னும் சேர்க்கப்படவில்லை',
    );
    return '$_temp0';
  }

  @override
  String smsTodayCountNoAmount(int count, int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count SMS இன்னும் சேர்க்கப்படவில்லை',
      one: '1 SMS இன்னும் சேர்க்கப்படவில்லை',
    );
    String _temp1 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: '$missing தொகை இல்லாமல்',
      one: '1 தொகை இல்லாமல்',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get smsTodayCaughtTitle => 'இன்றைக்கு எல்லாம் முடிந்தது';

  @override
  String get smsTodayCaughtBody => 'இன்றைய எல்லா SMS-ம் சரிசெய்யப்பட்டன.';

  @override
  String get smsTodayNoneBody => 'இன்று இதுவரை வங்கி SMS இல்லை.';

  @override
  String get smsRowNoAmount => 'தொகை இல்லை';

  @override
  String smsWidgetSpentUntracked(String amount) {
    return 'SMS-இலிருந்து $amount செலவு பதிவாகவில்லை';
  }

  @override
  String smsWidgetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இன்றைய $count SMS இன்னும் சேர்க்கப்படவில்லை',
      one: 'இன்றைய 1 SMS இன்னும் சேர்க்கப்படவில்லை',
    );
    return '$_temp0';
  }

  @override
  String get smsMenuDismissAll => 'அனைத்தையும் நிராகரி';

  @override
  String smsDismissAllTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'அனைத்து $count செய்திகளையும் நிராகரிக்கவா?',
      one: '1 செய்தியை நிராகரிக்கவா?',
    );
    return '$_temp0';
  }

  @override
  String get smsDismissAllBody =>
      'இவை Dismissed தாவலுக்குச் செல்லும். அங்கிருந்து இன்னும் சேர்க்கலாம்.';

  @override
  String get smsDismissAllBodyOne =>
      'இது Dismissed தாவலுக்குச் செல்லும். அங்கிருந்து இன்னும் சேர்க்கலாம்.';

  @override
  String smsDismissAllConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'அனைத்தையும் நிராகரி',
      one: 'நிராகரி',
    );
    return '$_temp0';
  }

  @override
  String smsDismissedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செய்திகள் நிராகரிக்கப்பட்டன',
      one: '1 செய்தி நிராகரிக்கப்பட்டது',
    );
    return '$_temp0';
  }
}
