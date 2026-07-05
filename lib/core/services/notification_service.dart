import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../utils/prefs_keys.dart';
import '../../features/notifications/data/app_notification.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Channel ids/names for notification types. These also drive the
/// Android-side channel registration in [NotificationService.init].
class _Channel {
  final String id;
  final String name;
  final String description;
  final Importance importance;
  const _Channel(this.id, this.name, this.description, this.importance);
}

const Map<NotificationType, _Channel> _typeChannels = {
  NotificationType.general: _Channel(
    'kuber_general',
    'General',
    'General app notifications',
    Importance.defaultImportance,
  ),
  NotificationType.budgetAlert: _Channel(
    'budget_alerts',
    'Budget Alerts',
    'Notifications for budget spending limits',
    Importance.high,
  ),
  NotificationType.recurringTransaction: _Channel(
    'kuber_recurring',
    'Recurring Transactions',
    'Notifications for new recurring transactions',
    Importance.high,
  ),
  NotificationType.loanEmi: _Channel(
    'kuber_loan_emi',
    'Loan EMI',
    'Notifications for loan EMI deductions',
    Importance.high,
  ),
  NotificationType.ledgerReminder: _Channel(
    'kuber_ledger_reminder',
    'Ledger Reminders',
    'Lend/borrow reminders',
    Importance.high,
  ),
  NotificationType.backup: _Channel(
    'kuber_backup',
    'Backup Failures',
    'Automatic backup failure notifications',
    Importance.high,
  ),
  NotificationType.reminderTrigger: _Channel(
    'kuber_reminders',
    'Reminders',
    'Money reminder alerts',
    Importance.high,
  ),
};

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

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

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
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        for (final c in _typeChannels.values) {
          await androidPlugin?.createNotificationChannel(
            AndroidNotificationChannel(
              c.id,
              c.name,
              description: c.description,
              importance: c.importance,
            ),
          );
        }
      }

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
  }) async {
    await maybeRequestPermissionOnce();

    final channel = _typeChannels[type]!;
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: channel.importance == Importance.high
          ? Priority.high
          : Priority.defaultPriority,
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

  Future<void> showBudgetAlertNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Notifications for budget spending limits',
          importance: Importance.high,
          priority: Priority.high,
          autoCancel: true,
        );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
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
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Schedules a reminder notification at [when] with "Mark done" and
  /// "Snooze 1 hour" actions. Uses the reminder's Isar id, so re-scheduling
  /// the same reminder replaces the previous alarm.
  ///
  /// Scheduling is duration-based (`now(tz.local) + (when - now)`), which
  /// resolves to the correct absolute instant without needing the device's
  /// IANA timezone name. Inexact scheduling avoids the Android 12+ exact
  /// alarm permission.
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

  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }
}
