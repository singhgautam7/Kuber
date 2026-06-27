import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

/// Day divider: thin lines flanking a muted centered label.
/// Formats dates as "Today", "Yesterday", Day name (e.g. "Monday" for the last 7 days),
/// or "d MMM yyyy" for earlier dates.
class DateSeparator extends StatelessWidget {
  final DateTime date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    final String label;
    final diffDays = today.difference(d).inDays;
    if (d == today) {
      label = 'Today';
    } else if (d == yesterday) {
      label = 'Yesterday';
    } else if (diffDays > 0 && diffDays < 7) {
      label = DateFormat('EEEE').format(date);
    } else {
      label = DateFormat('d MMM yyyy').format(date);
    }

    Widget line() =>
        Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.45)));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
      child: Row(children: [
        line(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
          child: Text(label,
              style: localeFont(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500)),
        ),
        line(),
      ]),
    );
  }
}
