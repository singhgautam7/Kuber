import 'package:intl/intl.dart';

/// Relative timestamp used across Notes surfaces: "just now", "4h ago",
/// "2d ago", then "12 May" (with year when it differs).
String noteRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (dt.year == now.year) return DateFormat('d MMM').format(dt);
  return DateFormat('d MMM yyyy').format(dt);
}

/// Short absolute date for the editor footer: "1 Jul" / "1 Jul 2025".
String noteShortDate(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year) return DateFormat('d MMM').format(dt);
  return DateFormat('d MMM yyyy').format(dt);
}
