import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/locale_font.dart' show AppLocale;
import '../../../l10n/app_localizations.dart';
import 'trial_state.dart' show kTrialLength;

/// Reserved notification ids (7300 background, 7410+ trial).
const kTrialRem3NotificationId = 7410;
const kTrialLastNotificationId = 7411;

/// Payload for a tap: opens `/pro` (route kind `trial` in notification_routes).
const kTrialNotificationPayload = 'trial:pro';

/// Schedules / cancels the two trial reminders.
abstract class TrialReminderScheduler {
  Future<void> schedule(DateTime start);
  Future<void> cancel();
}

/// Day 12 at 10:00 local ("3 days left") and day 14 at 10:00 ("Last day"),
/// day 1 = the start date. Idempotent: fixed ids replace earlier alarms.
class NotificationTrialReminders implements TrialReminderScheduler {
  @override
  Future<void> schedule(DateTime start) async {
    try {
      final s = start.toLocal();
      final l = lookupAppLocalizations(AppLocale.current);
      final end = s.add(kTrialLength);
      String fmt(String pattern) {
        try {
          return DateFormat(pattern, AppLocale.current.toString()).format(end);
        } catch (_) {
          return DateFormat(pattern).format(end);
        }
      }

      final n = NotificationService();
      final day12 = DateTime(s.year, s.month, s.day + 11, 10);
      final day14 = DateTime(s.year, s.month, s.day + 13, 10);
      await n.scheduleCreditCardNotification(
        id: kTrialRem3NotificationId,
        title: l.trialRem3Title,
        body: l.trialRem3NotifBody(fmt('EEEE'), fmt('d MMM')),
        when: day12,
        payload: kTrialNotificationPayload,
        askPermission: false,
      );
      await n.scheduleCreditCardNotification(
        id: kTrialLastNotificationId,
        title: l.trialLastTitle,
        body: l.trialLastBody,
        when: day14,
        payload: kTrialNotificationPayload,
        askPermission: false,
      );
    } catch (e) {
      debugPrint('Kuber trial: reminder scheduling failed (non-fatal): $e');
    }
  }

  @override
  Future<void> cancel() async {
    final n = NotificationService();
    await n.cancel(kTrialRem3NotificationId);
    await n.cancel(kTrialLastNotificationId);
  }
}
