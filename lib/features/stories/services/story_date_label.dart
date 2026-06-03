import 'package:intl/intl.dart';

/// The kinds of `dateLabel` a slide can carry. One label format per kind,
/// matching the design handoff table. Pace comparisons, insights and welcome
/// carry no label and never call this.
enum BubblePeriodKind {
  daily,
  weekly,
  monthly,
  yearlyYtd,
  yearlyFull,
  loan,
  ledger,
  investments,
}

/// Centralised period-label formatting for story slides. ASCII output; ranges
/// use the literal word "to" (never a hyphen or en dash). Returns null when the
/// inputs cannot produce a meaningful label, so callers can simply omit it.
///
/// Examples (per the design table):
///   daily      -> "24 May 2026"
///   weekly     -> "18 May to 24 May 2026"
///   monthly    -> "May 2026"
///   yearlyYtd  -> "Through May 2026"
///   yearlyFull -> "2025"
///   loan       -> "Bike Loan · 24 May"
///   ledger     -> "Rahul · 24 May"
///   investments-> the source period passed in ("This Week" / "May 2026")
String? formatBubblePeriod(
  BubblePeriodKind kind, {
  DateTime? start,
  DateTime? end,
  String? entityName,
  String? sourcePeriod,
}) {
  switch (kind) {
    case BubblePeriodKind.daily:
      if (start == null) return null;
      return DateFormat('d MMMM yyyy').format(start);
    case BubblePeriodKind.weekly:
      if (start == null || end == null) return null;
      return '${DateFormat('d MMM').format(start)} to '
          '${DateFormat('d MMM yyyy').format(end)}';
    case BubblePeriodKind.monthly:
      if (start == null) return null;
      return DateFormat('MMMM yyyy').format(start);
    case BubblePeriodKind.yearlyYtd:
      if (start == null) return null;
      return 'Through ${DateFormat('MMMM yyyy').format(start)}';
    case BubblePeriodKind.yearlyFull:
      if (start == null) return null;
      return DateFormat('yyyy').format(start);
    case BubblePeriodKind.loan:
    case BubblePeriodKind.ledger:
      if (entityName == null || entityName.isEmpty || start == null) return null;
      return '$entityName · ${DateFormat('d MMMM').format(start)}';
    case BubblePeriodKind.investments:
      return (sourcePeriod == null || sourcePeriod.isEmpty)
          ? null
          : sourcePeriod;
  }
}
