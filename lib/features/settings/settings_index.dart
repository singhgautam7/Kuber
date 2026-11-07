import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Where a setting lives. [route] is the page, [crumb] the last step of its
/// path ("Settings › Privacy and security"); null crumb = Settings itself.
enum SettingsArea {
  main('/more/settings'),
  pro('/pro'),
  look('/more/settings/look'),
  prefs('/more/settings/preferences'),
  privacy('/more/settings/privacy'),
  drawer('/more/settings/app-drawer'),
  notifications('/more/settings/notifications'),
  activity('/more/settings/activity'),
  data('/more/data');

  const SettingsArea(this.route);
  final String route;

  String? crumb(AppLocalizations l) => switch (this) {
        SettingsArea.main => null,
        SettingsArea.pro => 'Kuber Pro',
        SettingsArea.look => l.setGroupLook,
        SettingsArea.prefs => l.setGroupPrefs,
        SettingsArea.privacy => l.setGroupPrivacy,
        SettingsArea.drawer => l.appDrawerSection,
        SettingsArea.notifications => l.menuNotifications,
        SettingsArea.activity => l.setGroupActivity,
        SettingsArea.data => l.setGroupData,
      };
}

class SettingsEntry {
  /// Same id as the row's `SettingsAnchor`.
  final String id;
  final SettingsArea area;
  final IconData icon;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) keywords;
  const SettingsEntry(this.id, this.area, this.icon, this.title, this.keywords);
}

/// Every setting, for More search. test/features/settings/settings_index_test
/// checks this against the rows each page renders, so one can't go missing.
final List<SettingsEntry> kSettingsIndex = [
  SettingsEntry('pro', SettingsArea.main, Icons.workspace_premium_rounded, (_) => 'Kuber Pro', (l) => l.setKwPro),
  SettingsEntry('name', SettingsArea.main, Icons.person_outline_rounded, (l) => l.yourNameLabel, (l) => l.setKwName),
  SettingsEntry('tutorial', SettingsArea.main, Icons.school_rounded, (l) => l.menuTutorial, (l) => l.setKwTutorial),
  SettingsEntry('about', SettingsArea.main, Icons.info_outline_rounded, (l) => l.aboutKuberLabel, (l) => l.setKwAbout),
  SettingsEntry('redeem', SettingsArea.pro, Icons.redeem_rounded, (_) => 'Redeem promo code', (l) => l.setKwPro),
  SettingsEntry('restore', SettingsArea.pro, Icons.restore_rounded, (_) => 'Restore purchases', (l) => l.setKwPro),
  SettingsEntry('theme', SettingsArea.look, Icons.palette_outlined, (l) => l.themeLabel, (l) => l.setKwTheme),
  SettingsEntry('textSize', SettingsArea.look, Icons.format_size_rounded, (l) => l.textSizeTitle, (l) => l.setKwTextSize),
  SettingsEntry('bottomNav', SettingsArea.look, Icons.space_dashboard_outlined, (l) => l.bottomNavLabel, (l) => l.setKwBottomNav),
  SettingsEntry('moreLayout', SettingsArea.look, Icons.grid_view_outlined, (l) => l.moreTabLayoutLabel, (l) => l.setKwMoreLayout),
  SettingsEntry('homeWidgets', SettingsArea.look, Icons.home_outlined, (l) => l.homeWidgetsLabel, (l) => l.setKwHomeWidgets),
  SettingsEntry('analyticsWidgets', SettingsArea.look, Icons.insert_chart_outlined_rounded, (l) => l.analyticsWidgetsLabel, (l) => l.setKwAnalyticsWidgets),
  SettingsEntry('getStarted', SettingsArea.look, Icons.flag_outlined, (l) => l.homeV2SetGsTitle, (l) => l.setKwGetStarted),
  SettingsEntry('suggestions', SettingsArea.look, Icons.lightbulb_outline_rounded, (l) => l.homeV2SetSgTitle, (l) => l.setKwSuggestions),
  SettingsEntry('gallery', SettingsArea.look, Icons.widgets_outlined, (l) => l.setHomeScreenWidgets, (l) => l.setKwGallery),
  SettingsEntry('quickActions', SettingsArea.prefs, Icons.bolt_outlined, (_) => 'Quick Actions', (l) => l.setKwQuickActions),
  SettingsEntry('addMenu', SettingsArea.prefs, Icons.add_circle_outline_rounded, (_) => 'Add Menu', (l) => l.setKwAddMenu),
  SettingsEntry('language', SettingsArea.prefs, Icons.language_rounded, (l) => l.language, (l) => l.setKwLanguage),
  SettingsEntry('currency', SettingsArea.prefs, Icons.account_balance_wallet_outlined, (l) => l.currencyLabel, (l) => l.setKwCurrency),
  SettingsEntry('numberFormat', SettingsArea.prefs, Icons.money_outlined, (l) => l.numberFormatLabel, (l) => l.setKwNumberFormat),
  SettingsEntry('currencyCode', SettingsArea.prefs, Icons.abc_rounded, (l) => l.showCurrencyCode, (l) => l.setKwCurrencyCode),
  SettingsEntry('defaultAccount', SettingsArea.prefs, Icons.account_balance_wallet_outlined, (l) => l.defaultAccountLabel, (l) => l.setKwDefaultAccount),
  SettingsEntry('swipe', SettingsArea.prefs, Icons.swap_horiz_rounded, (l) => l.horizontalSwipeLabel, (l) => l.setKwSwipe),
  SettingsEntry('privacyMode', SettingsArea.privacy, Icons.visibility_off_outlined, (l) => l.privacyModeLabel, (l) => l.setKwPrivacyMode),
  SettingsEntry('biometric', SettingsArea.privacy, Icons.fingerprint_rounded, (l) => l.biometricLockLabel, (l) => l.setKwBiometric),
  SettingsEntry('notesBiometric', SettingsArea.privacy, Icons.lock_outline_rounded, (_) => 'Require biometric to open Notes', (l) => l.setKwNotesBiometric),
  SettingsEntry('cardsBiometric', SettingsArea.privacy, Icons.credit_card_outlined, (l) => l.setCardsBiometric, (l) => l.setKwCardsBiometric),
  SettingsEntry('cardsPin', SettingsArea.privacy, Icons.password_rounded, (l) => l.setCardsPin, (l) => l.setKwCardsPin),
  SettingsEntry('drawerCards', SettingsArea.drawer, Icons.wallet_rounded, (l) => l.appDrawerCards, (l) => l.setKwDrawer),
  SettingsEntry('drawerNotes', SettingsArea.drawer, Icons.sticky_note_2_outlined, (l) => l.appDrawerNotes, (l) => l.setKwDrawer),
  SettingsEntry('drawerReminders', SettingsArea.drawer, Icons.notifications_none_rounded, (l) => l.appDrawerReminders, (l) => l.setKwDrawer),
  SettingsEntry('notifPermission', SettingsArea.notifications, Icons.notifications_active_outlined, (l) => l.menuNotifications, (l) => l.setKwNotifications),
  SettingsEntry('notifInbox', SettingsArea.notifications, Icons.inbox_outlined, (l) => l.setNotifInbox, (l) => l.setKwNotifications),
  SettingsEntry('upcoming', SettingsArea.activity, Icons.calendar_month_rounded, (_) => 'Upcoming Events', (l) => l.setKwUpcoming),
  SettingsEntry('stories', SettingsArea.activity, Icons.auto_stories_rounded, (l) => l.menuStoriesArchive, (l) => l.setKwStories),
  SettingsEntry('export', SettingsArea.data, Icons.upload_file_rounded, (l) => l.exportData, (l) => l.setKwExport),
  SettingsEntry('import', SettingsArea.data, Icons.download_rounded, (l) => l.importData, (l) => l.setKwImport),
  SettingsEntry('backup', SettingsArea.data, Icons.backup_outlined, (l) => l.backupTitle, (l) => l.setKwBackup),
  SettingsEntry('clear', SettingsArea.data, Icons.delete_forever_rounded, (l) => l.clearAllData, (l) => l.setKwClear),
];

/// Lowercased title + keywords per entry, built once per language so typing
/// never rebuilds them.
class SettingsSearch {
  SettingsSearch._(this._locale, this._rows);

  final String _locale;
  final List<(SettingsEntry, String)> _rows;
  static SettingsSearch? _cached;

  factory SettingsSearch.of(AppLocalizations l) {
    final c = _cached;
    if (c != null && c._locale == l.localeName) return c;
    // English keywords too: many people search in English in any language.
    final en = lookupAppLocalizations(const Locale('en'));
    return _cached = SettingsSearch._(l.localeName, [
      for (final e in kSettingsIndex)
        (e, '${e.title(l)} ${e.keywords(l)} ${e.title(en)} ${e.keywords(en)}'.toLowerCase()),
    ]);
  }

  List<SettingsEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    // One letter hits nearly every keyword list: match the start only, so the
    // first keystroke doesn't lay out the whole index.
    return [
      for (final (e, text) in _rows)
        if (q.length == 1 ? text.startsWith(q) : text.contains(q)) e,
    ];
  }
}

/// "Settings › Privacy and security".
String settingsPath(SettingsArea area, AppLocalizations l, String settings) {
  final crumb = area.crumb(l);
  return crumb == null ? settings : '$settings › $crumb';
}
