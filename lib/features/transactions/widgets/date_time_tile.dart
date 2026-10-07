import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/locale_font.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/l10n_ext.dart';

/// Shared date & time selector tile used by both normal and transfer forms.
class DateTimeTile extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DateTimeTile({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Navigation row inside the Add Transaction grouped list (board 3.4):
    // value as the title, the field name under it.
    return KuberListRow(
      onTap: onTap,
      leading: const KuberIconTile(icon: Icons.calendar_today),
      title: formatDate(context, selectedDate),
      subtitle: sentenceCase(context.l10n.dateTimeLabel),
      trailing: const KuberChevron(),
    );
  }

  /// Format a date into a human-readable string (Today, Yesterday, or full date + time).
  static String formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dayPart;
    if (dateOnly == today) {
      dayPart = context.l10n.todayLabel;
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      dayPart = context.l10n.yesterdayLabel;
    } else {
      dayPart = DateFormat('dd MMM yyyy').format(date);
    }

    final timePart = DateFormat('hh:mm a').format(date);
    return '$dayPart • $timePart';
  }
}
