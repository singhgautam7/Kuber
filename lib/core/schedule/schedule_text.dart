// Words for a schedule: "Every month on the 15th, from 1 Nov 2026, no end."
// Shared by the When component preview, rows, sheets and Schedule debug.

import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../utils/locale_font.dart' show AppLocale;
import '../utils/monthly_recurrence.dart' show ordinalDay;
import 'schedule.dart';
import 'schedule_engine.dart';

String _locale() => AppLocale.current.languageCode;

/// "15th" in English; the plain number elsewhere.
String ordinalFor(int day) => _locale() == 'en' ? ordinalDay(day) : '$day';

String fmtDayLong(DateTime d) => DateFormat('d MMM yyyy', _locale()).format(d);
String fmtDayShort(DateTime d) => DateFormat('d MMM', _locale()).format(d);
String fmtMonthYear(DateTime d) => DateFormat('MMM yyyy', _locale()).format(d);

/// "Every month", "Every 3 months", "Every 2 weeks".
String intervalText(AppLocalizations l, int count, ScheduleUnit unit) {
  if (count <= 1) {
    return switch (unit) {
      ScheduleUnit.day => l.msWhenEveryUnitDay,
      ScheduleUnit.week => l.msWhenEveryUnitWeek,
      ScheduleUnit.month => l.msWhenEveryUnitMonth,
      ScheduleUnit.year => l.msWhenEveryUnitYear,
    };
  }
  final n = '$count';
  return switch (unit) {
    ScheduleUnit.day => l.msWhenEveryNDays(n),
    ScheduleUnit.week => l.msWhenEveryNWeeks(n),
    ScheduleUnit.month => l.msWhenEveryNMonths(n),
    ScheduleUnit.year => l.msWhenEveryNYears(n),
  };
}

/// " on Saturday", " on the 15th", " on 12 March", or ''.
String anchorText(AppLocalizations l, Schedule s) {
  final start = s.startDate;
  if (start == null) return '';
  switch (s.intervalUnit) {
    case ScheduleUnit.day:
      return '';
    case ScheduleUnit.week:
      final wd = s.anchorDay ?? start.weekday;
      // 2024-01-01 is a Monday.
      final name = DateFormat('EEEE', _locale()).format(DateTime(2024, 1, wd));
      return ' ${l.msWhenAnchorWeekday(name)}';
    case ScheduleUnit.month:
      return ' ${l.msWhenAnchorDay(ordinalFor(s.anchorDay ?? start.day))}';
    case ScheduleUnit.year:
      final d = DateTime(2024, s.anchorMonth ?? start.month, s.anchorDay ?? start.day);
      return ' ${l.msWhenAnchorDate(DateFormat('d MMMM', _locale()).format(d))}';
  }
}

String endText(AppLocalizations l, Schedule s, {bool emis = false}) {
  switch (s.endType) {
    case ScheduleEnd.never:
      return l.msWhenEndNever;
    case ScheduleEnd.onDate:
      return l.msWhenEndUntil(fmtDayLong(s.endDate!));
    case ScheduleEnd.afterCount:
      final n = '${s.endCount ?? 0}';
      return emis ? l.msWhenEndEmis(n) : l.msWhenEndTimes(n);
  }
}

/// The full sentence.
String scheduleSentence(AppLocalizations l, Schedule s, {bool emis = false}) {
  if (s.startDate == null) return '';
  return l.msWhenSentence(intervalText(l, s.intervalCount, s.intervalUnit),
      anchorText(l, s), fmtDayLong(s.startDate!), endText(l, s, emis: emis));
}

/// "Every month · next 1 Nov" style short line ("{interval} · next {date}").
String scheduleRowSub(AppLocalizations l, Schedule s, {DateTime? now}) {
  final next = nextDate(s, fromKey: todayKey(now));
  final interval = intervalText(l, s.intervalCount, s.intervalUnit);
  if (next == null) return interval;
  return l.msRecRowSub(interval, fmtDayShort(dayOf(next)));
}

/// True when [day] was moved to its month's last day by the anchor.
bool isClampedDay(Schedule s, int day) {
  final anchor = s.anchorDay;
  if (anchor == null || anchor < 29) return false;
  if (s.intervalUnit != ScheduleUnit.month && s.intervalUnit != ScheduleUnit.year) {
    return false;
  }
  return day % 100 != anchor;
}

/// Narrow weekday ("M") for weekday 1 (Mon) .. 7 (Sun).
String fmtWeekdayNarrow(int weekday) =>
    DateFormat('EEEEE', _locale()).format(DateTime(2024, 1, weekday));
