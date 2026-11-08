import 'dart:io';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../utils/prefs_keys.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/notifications/data/notification_repository.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Kuber's notification categories as the phone lists them (App info ›
/// Notifications). The phone keeps whether each is on: Settings ›
/// Notifications shows that and opens the phone's page for it, so there is
/// one switch per category, not one in Kuber and one in Android.
enum KuberChannel {
  payments('kuber_payments'),
  budgets('budget_alerts'),
  reminders('kuber_reminders'),
  ledger('kuber_ledger_reminder'),
  backups('kuber_backup');

  const KuberChannel(this.id);
  final String id;

  /// Name and description, in the app's language.
  (String, String) text(AppLocalizations l) => switch (this) {
        payments => (l.obNotifEmi, l.setNotifEmiSub),
        budgets => (l.obNotifBudget, l.setNotifBudgetSub),
        reminders => (l.appDrawerReminders, l.obNotifRemindersSub),
        ledger => (l.setNotifLedger, l.setNotifLedgerSub),
        backups => (l.obNotifBackupRow, l.setNotifBackupSub),
      };

  static KuberChannel? of(NotificationType type) => switch (type) {
        NotificationType.recurringTransaction || NotificationType.loanEmi => payments,
        NotificationType.budgetAlert => budgets,
        NotificationType.reminderTrigger => reminders,
        NotificationType.ledgerReminder => ledger,
        NotificationType.backup => backups,
        NotificationType.general => null,
      };
}

const _generalChannel = ('kuber_general', 'General', 'General app notifications');

/// Merged into kuber_payments (EMI, SIP or Subscriptions).
const _oldChannels = ['kuber_recurring', 'kuber_loan_emi'];

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Captured at startup if the app was launched from a notification tap.
  /// Cleared once consumed by the deep-link handler.
  String? _coldStartPayload;
  String? consumeColdStartPayload() {
    final p = _coldStartPayload;
    _coldStartPayload = null;
    return p;
  }

  /// Captured at startup if the app was launched from a notification ACTION
  /// button (e.g. a reminder's "Mark done"). Cleared once consumed.
  ({String actionId, String payload})? _coldStartAction;
  ({String actionId, String payload})? consumeColdStartAction() {
    final a = _coldStartAction;
    _coldStartAction = null;
    return a;
  }

  bool _timezonesReady = false;
  void _ensureTimezones() {
    if (_timezonesReady) return;
    tzdata.initializeTimeZones();
    _timezonesReady = true;
  }

  Future<void> init({
    void Function(String payload)? onTap,
    void Function(String actionId, String payload)? onAction,
  }) async {
    if (_isInitialized) return;
    // Recurring, EMI and SIP rows only reach the inbox on their own; this
    // shows them on the phone too, unless their switch is off. Budgets and
    // reminders post their own; a background backup failure has its own
    // notice (background_tasks.dart).
    NotificationRepository.onAdded = (n) async {
      if (!_mirrored.contains(n.type)) return;
      await showAppNotification(
        type: n.type,
        id: _mirrorIdBase + n.id % 100000000,
        title: n.title,
        body: n.body,
        payload: n.payload,
        ask: false,
      );
    };

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_stat_kuber');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
          );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null || payload.isEmpty) return;
          final actionId = response.actionId;
          if (actionId != null && actionId.isNotEmpty) {
            onAction?.call(actionId, payload);
          } else {
            onTap?.call(payload);
          }
        },
      );

      // Register Android channels so they exist before any notification fires.
      await registerChannels();

      // Detect cold-start launch from a notification tap or action button.
      final launchDetails = await _notificationsPlugin
          .getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final response = launchDetails?.notificationResponse;
        final actionId = response?.actionId;
        final payload = response?.payload;
        if (actionId != null &&
            actionId.isNotEmpty &&
            payload != null &&
            payload.isNotEmpty) {
          _coldStartAction = (actionId: actionId, payload: payload);
        } else {
          _coldStartPayload = payload;
        }
      }

      _isInitialized = true;
    } catch (e) {
      // Silently fail or log to a crash reporting service
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Ask for OS notification permission the first time we have a reason to
  /// fire one. Subsequent calls are no-ops (gated by a SharedPreferences
  /// flag), so the system dialog only appears once per install.
  Future<void> maybeRequestPermissionOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(PrefsKeys.notificationPermissionAsked) ?? false) return;
    await requestPermission();
    await prefs.setBool(PrefsKeys.notificationPermissionAsked, true);
  }

  static const _mirrored = {
    NotificationType.recurringTransaction,
    NotificationType.loanEmi,
  };
  static const _mirrorIdBase = 700000000;

  AndroidFlutterLocalNotificationsPlugin? get _android => Platform.isAndroid
      ? _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      : null;

  AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

  /// Creates the categories, or renames them into [locale] (on start and when
  /// the language changes), and removes the two that were merged.
  Future<void> registerChannels([Locale? locale]) async {
    final android = _android;
    if (android == null) return;
    final code = locale?.languageCode ??
        (await SharedPreferences.getInstance()).getString(PrefsKeys.language) ??
        'en';
    try {
      _l10n = lookupAppLocalizations(Locale(code));
    } catch (_) {}
    for (final id in _oldChannels) {
      await android.deleteNotificationChannel(channelId: id);
    }
    await android.createNotificationChannel(AndroidNotificationChannel(
      _generalChannel.$1,
      _generalChannel.$2,
      description: _generalChannel.$3,
    ));
    for (final c in KuberChannel.values) {
      final (name, description) = c.text(_l10n);
      await android.createNotificationChannel(AndroidNotificationChannel(
        c.id,
        name,
        description: description,
        importance: Importance.high,
      ));
    }
  }

  /// Which categories are on in the phone's settings (all on where the
  /// phone has no categories).
  Future<Map<KuberChannel, bool>> channelStates() async {
    final list = await _android?.getNotificationChannels() ?? const [];
    final on = {for (final c in list) c.id: c.importance != Importance.none};
    return {for (final c in KuberChannel.values) c: on[c.id] ?? true};
  }

  /// Generic OS notification for app-domain events (the five [NotificationType]s).
  /// Each type maps to its own Android channel. Payload should be the same
  /// string written to [AppNotification.payload] so the tap handler can
  /// deep-link consistently.
  Future<void> showAppNotification({
    required NotificationType type,
    required int id,
    required String title,
    required String body,
    String? payload,
    // False from background work, which can't show the permission prompt.
    bool ask = true,
  }) async {
    if (ask) await maybeRequestPermissionOnce();

    // A category the user switched off on the phone drops it there.
    final channel = KuberChannel.of(type);
    final (name, description) =
        channel?.text(_l10n) ?? (_generalChannel.$2, _generalChannel.$3);
    final androidDetails = AndroidNotificationDetails(
      channel?.id ?? _generalChannel.$1,
      name,
      channelDescription: description,
      importance: channel == null ? Importance.defaultImportance : Importance.high,
      priority: channel == null ? Priority.defaultPriority : Priority.high,
      autoCancel: true,
      ticker: title,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      // Silently fail
    }
  }

  // ── Background tasks (vNext) ────────────────────────────────────────────

  static const backgroundChannelId = 'kuber_background';
  static const backgroundNotificationId = 7300;
  static const backgroundRetryAction = 'background_retry';

  /// The ongoing "Background tasks" notification for a run: current step and
  /// progress. Posting silently does nothing when notifications are denied
  /// (Android 13+); the work still runs.
  Future<void> showBackgroundProgress({
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    int done = 0,
    int total = 0,
  }) async {
    final android = AndroidNotificationDetails(
      backgroundChannelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: total <= 0 ? 0 : total,
      progress: done.clamp(0, total <= 0 ? 0 : total),
      indeterminate: total <= 0,
      autoCancel: false,
    );
    try {
      await _notificationsPlugin.show(
        id: backgroundNotificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: android),
        payload: 'background:recurring',
      );
    } catch (_) {}
  }

  Future<void> clearBackground() => cancel(backgroundNotificationId);

  /// A short failure notification with a Retry action. [payload] routes
  /// through the notification routing map (background:backup / :recurring).
  Future<void> showBackgroundFailure({
    required String channelName,
    required String channelDescription,
    required String title,
    required String body,
    required String retryLabel,
    required String payload,
    // KuberChannel.backups.id when only the backup failed, so that category
    // decides whether it shows.
    String channelId = backgroundChannelId,
  }) async {
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      autoCancel: true,
      actions: [
        AndroidNotificationAction(
          backgroundRetryAction,
          retryLabel,
          showsUserInterface: true,
        ),
      ],
    );
    try {
      await _notificationsPlugin.show(
        id: backgroundNotificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(android: android),
        payload: payload,
      );
    } catch (_) {}
  }

  Future<void> showExportNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isProgress = false,
    bool isSuccess = false,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'export_channel',
          'Data Export',
          channelDescription: 'Notifications for data export status',
          importance: isSuccess ? Importance.high : Importance.low,
          priority: isSuccess ? Priority.high : Priority.low,
          showProgress: isProgress,
          indeterminate: isProgress,
          ongoing: isProgress,
          autoCancel: true,
          ticker: title,
        );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    await maybeRequestPermissionOnce();
    _ensureTimezones();

    final delay = when.difference(DateTime.now());
    if (delay.isNegative) return;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      'kuber_reminders',
      'Reminders',
      channelDescription: 'Money reminder alerts',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
      actions: [
        AndroidNotificationAction(
          'reminder_mark_done',
          'Mark done',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'reminder_snooze_1h',
          'Snooze 1 hour',
          showsUserInterface: true,
        ),
      ],
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      // Silently fail — a missed alarm is healed by on-open maintenance.
    }
  }

  /// Schedules a credit-card billing reminder (bill generated / payment due) at
  /// [when]. Reuses the existing `kuber_reminders` channel — these are money
  /// reminders the user explicitly opted into via the account's "Remind me"
  /// toggle — but carries no "Mark done"/"Snooze" actions (they don't apply to
  /// an auto-generated billing reminder). Like [scheduleReminderNotification],
  /// scheduling is duration-based and inexact; a missed alarm is healed by
  /// on-open maintenance. [id] must be stable per card+kind so a reschedule
  /// replaces the previous alarm.
  Future<void> scheduleCreditCardNotification({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    await maybeRequestPermissionOnce();
    _ensureTimezones();

    final delay = when.difference(DateTime.now());
    if (delay.isNegative) return;
    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      'kuber_reminders',
      'Reminders',
      channelDescription: 'Money reminder alerts',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      // Silently fail — a missed alarm is healed by on-open maintenance.
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      // Silently fail — a stale alarm is harmless and is re-evaluated on the
      // next on-open maintenance pass. Also guards environments where the
      // plugin isn't registered (e.g. widget tests).
    }
  }
}
