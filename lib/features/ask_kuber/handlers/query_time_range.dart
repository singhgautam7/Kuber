import '../models/query_context.dart';

/// A resolved query time window plus the phrasing the frequency and
/// last-transaction handlers reuse. [suffix] is the natural-language clause
/// appended to an answer ("this month", "in the past 3 months"); it is empty
/// for all-time so the answer reads cleanly without a trailing phrase.
class QueryRange {
  final DateTime from;
  final DateTime to;

  /// Short label for thinking steps (never empty), e.g. "this month",
  /// "the past 3 months", "all time".
  final String label;

  /// Answer suffix (may be empty for all time), e.g. "this month",
  /// "in the past 3 months".
  final String suffix;

  /// Pretty date range for [ThinkingInfo.dateFilter].
  final String thinkingDate;

  final bool isAllTime;

  const QueryRange({
    required this.from,
    required this.to,
    required this.label,
    required this.suffix,
    required this.thinkingDate,
    required this.isAllTime,
  });
}

/// Resolves the time window named in [ctx]. Uses the same precedence and the
/// existing [ParameterExtractor.customRange] as the spending handler, falling
/// back to all time. Never does custom date parsing of its own.
QueryRange resolveQueryRange(QueryContext ctx) {
  final lower = ctx.lower;

  final custom = ctx.extractor.customRange(lower);
  if (custom != null) {
    return QueryRange(
      from: custom.from,
      to: custom.to,
      label: 'the past ${custom.label}',
      suffix: 'in the past ${custom.label}',
      thinkingDate:
          '${ctx.fmtDate(custom.from)} – ${ctx.fmtDate(custom.to.subtract(const Duration(days: 1)))}',
      isAllTime: false,
    );
  }

  if (lower.contains('this year')) {
    return QueryRange(
      from: ctx.yearStart,
      to: ctx.yearEnd,
      label: 'this year',
      suffix: 'this year',
      thinkingDate: '${ctx.fmtDate(ctx.yearStart)} – ${ctx.fmtDate(ctx.today)}',
      isAllTime: false,
    );
  }

  if (lower.contains('last month')) {
    return QueryRange(
      from: ctx.lastMonthStart,
      to: ctx.lastMonthEnd,
      label: 'last month',
      suffix: 'last month',
      thinkingDate:
          '${ctx.fmtDate(ctx.lastMonthStart)} – ${ctx.fmtDate(ctx.lastMonthEnd.subtract(const Duration(days: 1)))}',
      isAllTime: false,
    );
  }

  if (lower.contains('last week')) {
    final lastWeekStart = ctx.weekStart.subtract(const Duration(days: 7));
    return QueryRange(
      from: lastWeekStart,
      to: ctx.weekStart,
      label: 'last week',
      suffix: 'last week',
      thinkingDate:
          '${ctx.fmtDate(lastWeekStart)} – ${ctx.fmtDate(ctx.weekStart.subtract(const Duration(days: 1)))}',
      isAllTime: false,
    );
  }

  if (lower.contains('today')) {
    return QueryRange(
      from: ctx.today,
      to: ctx.today.add(const Duration(days: 1)),
      label: 'today',
      suffix: 'today',
      thinkingDate: ctx.fmtDate(ctx.today),
      isAllTime: false,
    );
  }

  // "last week"/"last month"/"last N" are handled above, so a remaining "last"
  // here is incidental (e.g. "when did I last spend ... this week").
  if (lower.contains('week')) {
    return QueryRange(
      from: ctx.weekStart,
      to: ctx.today.add(const Duration(days: 1)),
      label: 'this week',
      suffix: 'this week',
      thinkingDate: '${ctx.fmtDate(ctx.weekStart)} – ${ctx.fmtDate(ctx.today)}',
      isAllTime: false,
    );
  }

  if (lower.contains('month')) {
    return QueryRange(
      from: ctx.monthStart,
      to: ctx.monthEnd,
      label: 'this month',
      suffix: 'this month',
      thinkingDate: '${ctx.fmtDate(ctx.monthStart)} – ${ctx.fmtDate(ctx.today)}',
      isAllTime: false,
    );
  }

  // All time fallback. `to` is exclusive of tomorrow so today is included.
  return QueryRange(
    from: DateTime(2000),
    to: ctx.today.add(const Duration(days: 1)),
    label: 'all time',
    suffix: '',
    thinkingDate: 'All time',
    isAllTime: true,
  );
}
