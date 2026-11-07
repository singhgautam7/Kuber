import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Where a setting lives. [route] is the page, [crumb] the last step of its
/// path ("Settings › Privacy and security"); null crumb = Settings itself.
enum SettingsArea {
  main('/more/settings'),
  pro('/pro'),
  look('/more/settings/look'),
  theme('/more/settings/theme'),
  prefs('/more/settings/preferences'),
  privacy('/more/settings/privacy'),
  drawer('/more/settings/app-drawer'),
  notifications('/more/settings/notifications'),
  help('/more/settings/help'),
  activity('/more/settings/activity'),
  data('/more/data');

  const SettingsArea(this.route);
  final String route;

  String? crumb(AppLocalizations l) => switch (this) {
        SettingsArea.main => null,
        SettingsArea.pro => 'Kuber Pro',
        SettingsArea.look => l.setGroupLook,
        SettingsArea.theme => '${l.setGroupLook} › ${l.themeLabel}',
        SettingsArea.prefs => l.setGroupPrefs,
        SettingsArea.privacy => l.setGroupPrivacy,
        SettingsArea.drawer => l.appDrawerSection,
        SettingsArea.notifications => l.menuNotifications,
        SettingsArea.help => l.setHelpTitle,
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
  SettingsEntry('about', SettingsArea.main, Icons.info_outline_rounded, (l) => l.aboutKuberLabel, (l) => l.setKwAbout),
  SettingsEntry('redeem', SettingsArea.pro, Icons.redeem_rounded, (_) => 'Redeem promo code', (l) => l.setKwPro),
  SettingsEntry('restore', SettingsArea.pro, Icons.restore_rounded, (_) => 'Restore purchases', (l) => l.setKwPro),
  SettingsEntry('theme', SettingsArea.look, Icons.contrast_rounded, (l) => l.themeLabel, (l) => l.setKwTheme),
  SettingsEntry('textSize', SettingsArea.look, Icons.format_size_rounded, (l) => l.textSizeTitle, (l) => l.setKwTextSize),
  SettingsEntry('bottomNav', SettingsArea.look, Icons.space_dashboard_outlined, (l) => l.setBottomNav, (l) => l.setKwBottomNav),
  SettingsEntry('moreLayout', SettingsArea.look, Icons.grid_view_outlined, (l) => l.setMoreLayout, (l) => l.setKwMoreLayout),
  SettingsEntry('homeWidgets', SettingsArea.look, Icons.home_outlined, (l) => l.setHomeWidgets, (l) => l.setKwHomeWidgets),
  SettingsEntry('analyticsWidgets', SettingsArea.look, Icons.insert_chart_outlined_rounded, (l) => l.setAnalyticsWidgets, (l) => l.setKwAnalyticsWidgets),
  SettingsEntry('getStarted', SettingsArea.look, Icons.flag_outlined, (l) => l.homeV2SetGsTitle, (l) => l.setKwGetStarted),
  SettingsEntry('suggestions', SettingsArea.look, Icons.lightbulb_outline_rounded, (l) => l.homeV2SetSgTitle, (l) => l.setKwSuggestions),
  SettingsEntry('gallery', SettingsArea.look, Icons.widgets_outlined, (l) => l.setHomeScreenWidgets, (l) => l.setKwGallery),
  SettingsEntry('quickActions', SettingsArea.prefs, Icons.bolt_outlined, (l) => l.setQuickActions, (l) => l.setKwQuickActions),
  SettingsEntry('addMenu', SettingsArea.prefs, Icons.add_circle_outline_rounded, (l) => l.setAddMenu, (l) => l.setKwAddMenu),
  SettingsEntry('language', SettingsArea.prefs, Icons.language_rounded, (l) => l.language, (l) => l.setKwLanguage),
  SettingsEntry('currency', SettingsArea.prefs, Icons.currency_rupee_rounded, (l) => l.currencyLabel, (l) => l.setKwCurrency),
  SettingsEntry('numberFormat', SettingsArea.prefs, Icons.pin_rounded, (l) => l.setNumberFormat, (l) => l.setKwNumberFormat),
  SettingsEntry('currencyCode', SettingsArea.prefs, Icons.abc_rounded, (l) => l.setShowCode, (l) => l.setKwCurrencyCode),
  SettingsEntry('defaultAccount', SettingsArea.prefs, Icons.account_balance_outlined, (l) => l.setDefaultAccount, (l) => l.setKwDefaultAccount),
  SettingsEntry('swipe', SettingsArea.prefs, Icons.swipe_rounded, (l) => l.setSwipe, (l) => l.setKwSwipe),
  SettingsEntry('privacyMode', SettingsArea.privacy, Icons.visibility_off_outlined, (l) => l.setPrivacyMode, (l) => l.setKwPrivacyMode),
  SettingsEntry('biometric', SettingsArea.privacy, Icons.lock_outline_rounded, (l) => l.setAppLock, (l) => l.setKwBiometric),
  SettingsEntry('notesBiometric', SettingsArea.privacy, Icons.sticky_note_2_outlined, (l) => l.setNotesLock, (l) => l.setKwNotesBiometric),
  SettingsEntry('cardsBiometric', SettingsArea.privacy, Icons.fingerprint_rounded, (l) => l.setCardsFpSearch, (l) => l.setKwCardsBiometric),
  SettingsEntry('cardsPin', SettingsArea.privacy, Icons.password_rounded, (l) => l.setCardsPinSearch, (l) => l.setKwCardsPin),
  SettingsEntry('drawerCards', SettingsArea.drawer, Icons.credit_card_rounded, (l) => l.appDrawerCards, (l) => l.setKwDrawer),
  SettingsEntry('drawerNotes', SettingsArea.drawer, Icons.sticky_note_2_outlined, (l) => l.appDrawerNotes, (l) => l.setKwDrawer),
  SettingsEntry('drawerReminders', SettingsArea.drawer, Icons.alarm_rounded, (l) => l.appDrawerReminders, (l) => l.setKwDrawer),
  SettingsEntry('notifPermission', SettingsArea.notifications, Icons.notifications_active_outlined, (l) => l.menuNotifications, (l) => l.setKwNotifications),
  SettingsEntry('notifInbox', SettingsArea.notifications, Icons.inbox_outlined, (l) => l.setNotifInbox, (l) => l.setKwNotifications),
  SettingsEntry('notifEmi', SettingsArea.notifications, Icons.event_repeat_rounded, (l) => l.obNotifEmi, (l) => l.setKwNotifications),
  SettingsEntry('notifBudget', SettingsArea.notifications, Icons.donut_large_rounded, (l) => l.obNotifBudget, (l) => l.setKwNotifications),
  SettingsEntry('notifBackup', SettingsArea.notifications, Icons.backup_outlined, (l) => l.obNotifBackupRow, (l) => l.setKwNotifications),
  SettingsEntry('tutorial', SettingsArea.help, Icons.school_rounded, (l) => l.setAppTutorial, (l) => l.setKwTutorial),
  SettingsEntry('feedback', SettingsArea.help, Icons.rate_review_outlined, (l) => l.setSendFeedback, (l) => l.setKwFeedback),
  SettingsEntry('upcoming', SettingsArea.activity, Icons.calendar_month_rounded, (l) => l.setUpcoming, (l) => l.setKwUpcoming),
  SettingsEntry('stories', SettingsArea.activity, Icons.auto_stories_rounded, (l) => l.setStories, (l) => l.setKwStories),
  SettingsEntry('backup', SettingsArea.data, Icons.event_repeat_rounded, (l) => l.setAutoBackups, (l) => l.setKwBackup),
  SettingsEntry('restore-data', SettingsArea.data, Icons.settings_backup_restore_rounded, (l) => l.obStartRestore, (l) => l.setKwImport),
  SettingsEntry('import', SettingsArea.data, Icons.upload_file_rounded, (l) => l.obStartCsv, (l) => l.setKwImport),
  SettingsEntry('importKuber', SettingsArea.data, Icons.download_rounded, (l) => l.setImportKuber, (l) => l.setKwImport),
  SettingsEntry('export', SettingsArea.data, Icons.ios_share_rounded, (l) => l.setExport, (l) => l.setKwExport),
  SettingsEntry('mockData', SettingsArea.data, Icons.science_outlined, (l) => l.setMockData, (l) => l.setKwClear),
  SettingsEntry('clear', SettingsArea.data, Icons.delete_forever_rounded, (l) => l.setClear, (l) => l.setKwClear),
  SettingsEntry('expressive', SettingsArea.theme, Icons.format_color_fill_rounded, (l) => l.themeExpressiveTitle, (l) => l.setKwExpressive),
  SettingsEntry('pureBlack', SettingsArea.theme, Icons.dark_mode_outlined, (l) => l.themePureBlackTitle, (l) => l.setKwPureBlack),
];

/// Lowercased title and keywords per entry, built once per language so typing
/// never rebuilds them.
class SettingsSearch {
  SettingsSearch._(this._locale, this._rows);

  /// More than this and a keystroke lays out a long list in one frame: a
  /// two-letter query can hit most keyword lists.
  static const maxResults = 8;

  final String _locale;
  final List<(SettingsEntry, String title, String all)> _rows;
  static SettingsSearch? _cached;

  factory SettingsSearch.of(AppLocalizations l) {
    final c = _cached;
    if (c != null && c._locale == l.localeName) return c;
    // English keywords too: many people search in English in any language.
    final en = lookupAppLocalizations(const Locale('en'));
    return _cached = SettingsSearch._(l.localeName, [
      for (final e in kSettingsIndex)
        (
          e,
          e.title(l).toLowerCase(),
          '${e.title(l)} ${e.keywords(l)} ${e.title(en)} ${e.keywords(en)}'.toLowerCase(),
        ),
    ]);
  }

  /// The keyword that found [e] when its title doesn't show the match.
  String? keywordHit(SettingsEntry e, String query) {
    final q = query.trim().toLowerCase();
    final row = _rows.firstWhere((r) => r.$1 == e);
    if (row.$2.contains(q)) return null;
    final words = row.$3.split(' ').where((w) => w.contains(q)).toSet();
    return words.isEmpty ? null : words.take(3).join(', ');
  }

  /// Title matches first, then keywords. One letter matches the start of a
  /// title only: it would hit nearly every keyword list.
  List<SettingsEntry> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final titles = [
      for (final (e, title, _) in _rows)
        if (q.length == 1 ? title.startsWith(q) : title.contains(q)) e,
    ];
    if (q.length == 1) return titles.take(maxResults).toList();
    return [
      ...titles,
      for (final (e, title, all) in _rows)
        if (!title.contains(q) && all.contains(q)) e,
    ].take(maxResults).toList();
  }
}

/// "Settings › Privacy and security".
String settingsPath(SettingsArea area, AppLocalizations l, String settings) {
  final crumb = area.crumb(l);
  return crumb == null ? settings : '$settings › $crumb';
}
