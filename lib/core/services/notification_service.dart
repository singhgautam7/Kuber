import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            OpenFilex.open(payload);
          }
        },
      );

      // Handle notification if app was launched from it
      final NotificationAppLaunchDetails? launchDetails = 
          await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          OpenFilex.open(payload);
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
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    
    if (Platform.isAndroid) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  Future<void> showExportNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isProgress = false,
    bool isSuccess = false,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
      await _notificationsPlugin.show(id, title, body, notificationDetails, payload: payload);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> showBudgetAlertNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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
