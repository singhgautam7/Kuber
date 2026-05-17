import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/prefs_keys.dart';
import '../../features/notifications/data/app_notification.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Channel ids/names for the five notification types. These also drive the
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

  Future<void> init({void Function(String payload)? onTap}) async {
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
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onTap?.call(payload);
          }
        },
      );

      // Register Android channels so they exist before any notification fires.
      if (Platform.isAndroid) {
        final androidPlugin = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
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

      // Detect cold-start launch from a notification tap.
      final launchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _coldStartPayload =
            launchDetails?.notificationResponse?.payload;
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
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
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
        id,
        title,
        body,
        notificationDetails,
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

    const DarwinNotificationDetails darwinDetails =
        DarwinNotificationDetails();

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
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
      await _notificationsPlugin.show(id, title, body, notificationDetails);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
