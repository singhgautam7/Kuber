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

  static String full(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }
}
