import 'package:intl/intl.dart';

class DateFormatter {
  static String groupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';
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

    final timeStr = DateFormat('h:mm a').format(date);

    if (dateOnly == today) {
      return 'Today, $timeStr';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, $timeStr';
    } else if (date.year == now.year) {
      return '${DateFormat('MMM d').format(date)}, $timeStr';
    } else {
      return '${DateFormat('MMM d, yyyy').format(date)}, $timeStr';
    }
  }

  static String full(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
