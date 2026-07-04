import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';

/// About Reminders info sheet (screen 2f). Same standard info-sheet shell
/// as About Kuber Notes for visual consistency.
const kAboutRemindersInfoConfig = KuberInfoConfig(
  title: 'About Reminders',
  description:
      'Never miss a bill, a collection, or anything money-related. Set a '
      'time and Kuber nudges you.',
  items: [
    KuberInfoItem(
      icon: Icons.schedule_rounded,
      title: 'How overdue works',
      description:
          'If a reminder passes without action, it stays at the top in '
          'Overdue until you mark it done or snooze it.',
    ),
    KuberInfoItem(
      icon: Icons.notifications_active_outlined,
      title: 'Notifications',
      description:
          'You get a system notification with Mark done and Snooze '
          'actions. It also lands in your Kuber inbox.',
    ),
    KuberInfoItem(
      icon: Icons.add_rounded,
      title: 'Add as transactions',
      description:
          'A reminder with an amount can become a real transaction in one '
          'tap, pre-filled and dated today.',
    ),
    KuberInfoItem(
      icon: Icons.repeat_rounded,
      title: 'Repeat schedules',
      description:
          'Daily, Weekly, Monthly or Yearly. On Mark done, it rolls to the '
          'next occurrence automatically.',
    ),
  ],
);

void showAboutRemindersInfoSheet(BuildContext context) {
  KuberInfoBottomSheet.show(context, kAboutRemindersInfoConfig);
}
