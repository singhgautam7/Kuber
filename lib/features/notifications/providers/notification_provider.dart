import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(isarProvider));
});

/// Streams the current unread notification count. Used by the home header
/// to drive the bell badge.
final unreadCountProvider = StreamProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).unreadCountStream();
});

/// One-shot deep-link payload captured from a cold-start notification tap.
/// Set in `main.dart` via `getNotificationAppLaunchDetails()`, consumed once
/// by the dashboard after first frame.
final pendingDeeplinkProvider = StateProvider<String?>((ref) => null);
