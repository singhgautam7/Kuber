import 'package:intl/intl.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/core/utils/locale_font.dart';

class DateFormatter {
  static String groupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final l10n = lookupAppLocalizations(AppLocale.current);

    if (dateOnly == today) return l10n.todayLabel;
    if (dateOnly == today.subtract(const Duration(days: 1))) return l10n.yesterdayLabel;
    if (date.year != now.year) return DateFormat('d MMM yyyy').format(date);
    return DateFormat('EEE, d MMM').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    final l10n = lookupAppLocalizations(AppLocale.current);

    final timeStr = DateFormat('h:mm a').format(date);

    if (dateOnly == today) {
      return l10n.relativeToday(timeStr);
    } else if (dateOnly == yesterday) {
      return l10n.relativeYesterday(timeStr);
    } else if (date.year == now.year) {
      return '${DateFormat('MMM d').format(date)}, $timeStr';
    } else {
      return '${DateFormat('MMM d, yyyy').format(date)}, $timeStr';
    }
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final l10n = lookupAppLocalizations(AppLocale.current);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return l10n.minsAgo(mins);
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return l10n.hoursAgo(hours);
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return l10n.daysAgo(days);
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }

  static String full(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
