// Upcoming events Calendar view (upcoming-calendar-v1 §1 to §8).
//
// Inner scroll of the screen's NestedScrollView:
//   month header (pinned 48) → month summary (scrolls away) →
//   weekday row + grid + handle (pinned, collapses to the selected week) →
//   day list.
// Months page horizontally (PageView); collapsed, the strip pages by week.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/schedule/schedule_engine.dart' show dayKey;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider, privacyModeProvider;
import '../engine/occurrences.dart';
import '../providers/upcoming_calendar_provider.dart';
import '../providers/upcoming_events_provider.dart';
import 'upcoming_day_cell.dart';
import 'upcoming_events_widget.dart' show UpcomingEventRow;

const double _kHeaderH = 48;
const double _kWeekdayH = 32;
const double _kHandleH = 16;
const double _kGridPad = 12;

/// Occurrences of [items] that pass the shared type filter.
List<CalendarOccurrence> _filtered(List<CalendarOccurrence> items, String filter) =>
    filter == 'all' ? items : items.where((o) => o.event.sourceType == filter).toList();

/// The month's grid: leading days of the previous month (week start from the
/// phone region), the month, trailing days to complete the last week.
List<DateTime> _gridDays(int monthKey, int firstWeekday) {
  final first = monthOf(monthKey);
  final lead = (first.weekday % 7 - firstWeekday + 7) % 7;
  final days = DateTime(first.year, first.month + 1, 0).day;
  final rows = ((lead + days) / 7).ceil();
  return [for (var i = 0; i < rows * 7; i++) DateTime(first.year, first.month, 1 - lead + i)];
}

class UpcomingCalendarView extends ConsumerStatefulWidget {
  const UpcomingCalendarView({super.key});

  @override
  ConsumerState<UpcomingCalendarView> createState() => _UpcomingCalendarViewState();
}

class _UpcomingCalendarViewState extends ConsumerState<UpcomingCalendarView> {
  PageController? _pages;
  late int _first; // first month (yyyymm)
  late int _count;
  late DateTime _selected;
  late DateTime _today;
  final _keep = <int, ProviderSubscription<AsyncValue<List<CalendarOccurrence>>>>{};
  final _summaryKey = GlobalKey();
  bool _collapsed = false;
  // Built day cells, reused while their inputs are unchanged: a tap rebuilds
  // only the two cells whose selection changed, and collapsing the grid
  // (a rebuild per scroll frame) rebuilds none.
  final _cellCache = <String, Widget>{};

  int get _monthIndex => (_pages?.hasClients ?? false) ? (_pages!.page ?? 0).round() : _indexOf(monthKeyOf(_selected));
  int _keyAt(int index) {
    final d = monthOf(_first);
    return monthKeyOf(DateTime(d.year, d.month + index));
  }

  int _indexOf(int key) {
    final a = monthOf(_first), b = monthOf(key);
    return (b.year - a.year) * 12 + b.month - a.month;
  }

  void _init(int first) {
    final now = ref.read(upcomingClockProvider)();
    _today = DateTime(now.year, now.month, now.day);
    _first = first;
    final last = monthKeyOf(DateTime(now.year, now.month + 12));
    _count = _indexOf(last) + 1;
    _selected = _today;
    // keepPage off: the page must not come back from PageStorage (it would
    // read the scroll view's saved offset as a page).
    _pages = PageController(initialPage: _indexOf(monthKeyOf(_today)), keepPage: false);
  }

  @override
  void dispose() {
    _pages?.dispose();
    for (final s in _keep.values) {
      s.close();
    }
    super.dispose();
  }

  /// Keeps every month the calendar has shown cached until it closes.
  AsyncValue<List<CalendarOccurrence>> _month(int key) {
    _keep.putIfAbsent(key, () => ref.listenManual(calendarMonthProvider(key), (_, __) {}));
    return ref.watch(calendarMonthProvider(key));
  }

  void _onPage(int index) {
    final key = _keyAt(index);
    if (monthKeyOf(_selected) == key) return;
    setState(() {
      _selected = key == monthKeyOf(_today) ? _today : monthOf(key);
    });
  }

  void _select(DateTime d) {
    HapticFeedback.selectionClick();
    final key = monthKeyOf(d);
    if (key != _keyAt(_monthIndex)) {
      final i = _indexOf(key);
      if (i < 0 || i >= _count) return;
      _pages?.animateToPage(i, duration: KuberMotion.of(context, _kReflow), curve: Curves.easeOutCubic);
    }
    setState(() => _selected = d);
  }

  void _goMonth(int delta) {
    final i = _monthIndex + delta;
    if (i < 0 || i >= _count) return;
    _pages?.animateToPage(i, duration: KuberMotion.of(context, _kReflow), curve: Curves.easeOutCubic);
  }

  /// Collapsed: a swipe moves the selection by a week.
  void _goWeek(int delta) {
    final d = _selected.add(Duration(days: 7 * delta));
    final i = _indexOf(monthKeyOf(d));
    if (i < 0 || i >= _count) return;
    if (i != _monthIndex) _pages?.jumpToPage(i);
    setState(() => _selected = DateTime(d.year, d.month, d.day));
    // The new week's month may lay out differently: stay collapsed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = PrimaryScrollController.maybeOf(context);
      if (!mounted || c == null || !c.hasClients) return;
      final rows = _gridDays(monthKeyOf(_selected), MaterialLocalizations.of(context).firstDayOfWeekIndex).length ~/ 7;
      c.jumpTo(math.min(c.position.maxScrollExtent, _summaryHeight + (rows - 1) * kDayCellHeight));
    });
  }

  void _quickAdd(DateTime d) {
    HapticFeedback.mediumImpact();
    context.push('/reminders/add?date=${DateFormat('yyyy-MM-dd').format(d)}');
  }

  double get _summaryHeight =>
      (_summaryKey.currentContext?.findRenderObject() as RenderBox?)?.size.height ?? 0;

  /// On release inside the collapse range, settle to expanded or collapsed.
  bool _onScrollEnd(ScrollEndNotification n, int rows) {
    final pos = Scrollable.maybeOf(n.context!)?.position;
    if (pos == null || n.depth != 0) return false;
    final start = _summaryHeight, range = (rows - 1) * kDayCellHeight;
    final off = pos.pixels;
    if (off <= start || off >= start + range) return false;
    final target = off < start + range / 2 ? start : start + range;
    final duration = KuberMotion.of(context, _kReflow);
    Future.microtask(() => pos.animateTo(target, duration: duration, curve: Curves.easeOutCubic));
    return false;
  }

  void _expand() {
    final c = PrimaryScrollController.maybeOf(context);
    if (c == null || !c.hasClients) return;
    c.animateTo(math.min(c.offset, _summaryHeight),
        duration: KuberMotion.of(context, _kReflow), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final firstAsync = ref.watch(calendarFirstMonthProvider);
    final first = firstAsync.valueOrNull;
    if (first == null) return const SizedBox.shrink();
    if (_pages == null) _init(first);
    final filter = ref.watch(upcomingEventsSourceFilterProvider);
    final weekStart = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final selectedKey = monthKeyOf(_selected);
    final selectedMonth = _month(selectedKey);
    final rows = _gridDays(selectedKey, weekStart).length ~/ 7;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (n) => _onScrollEnd(n, rows),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FixedHeader(
              height: _kHeaderH,
              child: _MonthHeader(
                pages: _pages!,
                keyAt: _keyAt,
                count: _count,
                today: _today,
                onPrev: () => _goMonth(-1),
                onNext: () => _goMonth(1),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _summaryKey,
              child: _MonthSummary(
                pages: _pages!,
                keyAt: _keyAt,
                monthData: _month,
                filter: filter,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _GridHeader(
              rows: rows,
              builder: (context, p) {
                final collapsed = p >= 0.999;
                if (collapsed != _collapsed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _collapsed = collapsed);
                  });
                }
                return _GridArea(
                  p: p,
                  rows: rows,
                  pages: _pages!,
                  count: _count,
                  keyAt: _keyAt,
                  monthData: _month,
                  filter: filter,
                  weekStart: weekStart,
                  today: _today,
                  selected: _selected,
                  cellCache: _cellCache,
                  onPage: _onPage,
                  onTap: _select,
                  onLongPress: _quickAdd,
                  onWeek: _goWeek,
                  onExpand: _expand,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _DayList(
              day: _selected,
              today: _today,
              month: selectedMonth,
              filter: filter,
            ),
          ),
          // Slack so a short day list can still collapse the grid fully.
          SliverLayoutBuilder(
            builder: (context, c) {
              final need = c.viewportMainAxisExtent + _summaryHeight + (rows - 1) * kDayCellHeight;
              final slack = math.max(navBarBottomPadding(context), need - c.precedingScrollExtent);
              return SliverToBoxAdapter(child: SizedBox(height: slack));
            },
          ),
        ],
      ),
    );
  }
}

const Duration _kReflow = Duration(milliseconds: 230);

class _FixedHeader extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  const _FixedHeader({required this.height, required this.child});
  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: Theme.of(context).colorScheme.surface, child: child);
  @override
  bool shouldRebuild(_FixedHeader old) => true;
}

/// Weekday row + grid + handle. p = scrolled ÷ (grid height − one row).
class _GridHeader extends SliverPersistentHeaderDelegate {
  final int rows;
  final Widget Function(BuildContext context, double p) builder;
  const _GridHeader({required this.rows, required this.builder});

  @override
  double get maxExtent => _kWeekdayH + rows * kDayCellHeight + _kHandleH;
  @override
  double get minExtent => _kWeekdayH + kDayCellHeight + _kHandleH;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final range = (rows - 1) * kDayCellHeight;
    final p = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    return ColoredBox(color: Theme.of(context).colorScheme.surface, child: builder(context, p));
  }

  @override
  bool shouldRebuild(_GridHeader old) => true;
}

class _MonthHeader extends StatelessWidget {
  final PageController pages;
  final int Function(int) keyAt;
  final int count;
  final DateTime today;
  final VoidCallback onPrev, onNext;
  const _MonthHeader({
    required this.pages,
    required this.keyAt,
    required this.count,
    required this.today,
    required this.onPrev,
    required this.onNext,
  });

  static String title(BuildContext context, int key, DateTime today) {
    final locale = Localizations.localeOf(context).toString();
    final d = monthOf(key);
    return DateFormat(d.year == today.year ? 'LLLL' : 'LLLL y', locale).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;
    return AnimatedBuilder(
      animation: pages,
      builder: (context, _) {
        final page = pages.hasClients ? (pages.page ?? pages.initialPage.toDouble()) : pages.initialPage.toDouble();
        final index = page.round().clamp(0, count - 1);
        // Cross-fades at the midpoint of a swipe.
        final frac = page - page.floor();
        final opacity = frac == 0 ? 1.0 : ((0.5 - frac).abs() * 2).clamp(0.0, 1.0);
        final text = title(context, keyAt(index), today);
        final big = theme.textTheme.headlineSmall!.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600);
        final fits = (TextPainter(
          text: TextSpan(text: text, style: big),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout())
                .width <=
            MediaQuery.sizeOf(context).width - 120;
        // Spoken labels always carry the year (design §7).
        final locale = Localizations.localeOf(context).toString();
        String full(int k) => DateFormat('LLLL y', locale).format(monthOf(k));
        final prev = index > 0 ? full(keyAt(index - 1)) : null;
        final next = index < count - 1 ? full(keyAt(index + 1)) : null;
        return Padding(
          padding: const EdgeInsets.only(left: KuberSpace.screenMargin, right: 4),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Opacity(
                    opacity: opacity,
                    child: Text(
                      text,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: fits ? big : theme.textTheme.titleLarge!.copyWith(color: cs.onSurface),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: prev == null ? null : l.ueA11yPrevMonth(prev),
                onPressed: prev == null ? null : onPrev,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: next == null ? null : l.ueA11yNextMonth(next),
                onPressed: next == null ? null : onNext,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthSummary extends ConsumerWidget {
  final PageController pages;
  final int Function(int) keyAt;
  final AsyncValue<List<CalendarOccurrence>> Function(int) monthData;
  final String filter;
  const _MonthSummary({required this.pages, required this.keyAt, required this.monthData, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final priv = ref.watch(privacyModeProvider);
    final locale = Localizations.localeOf(context).toString();
    String money(double v) => maskAmount(fmt.formatCurrency(v), priv);
    return AnimatedBuilder(
      animation: pages,
      builder: (context, _) {
        final page = pages.hasClients ? (pages.page ?? pages.initialPage.toDouble()) : pages.initialPage.toDouble();
        final key = keyAt(page.round());
        final items = monthData(key).valueOrNull;
        final t = items == null ? null : OccurrenceTotals.of(_filtered(items, filter));
        final base = theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant);
        final strong = theme.textTheme.titleSmall!.copyWith(
            color: cs.onSurface, fontFeatures: const [FontFeature.tabularFigures()]);
        List<InlineSpan> part(String template, double v) {
          final i = template.indexOf('{amount}');
          return [
            TextSpan(text: template.substring(0, i)),
            TextSpan(text: money(v), style: strong),
            TextSpan(text: template.substring(i + 8)),
          ];
        }

        final spans = <InlineSpan>[TextSpan(text: DateFormat('LLLL', locale).format(monthOf(key)))];
        if (t != null && t.out > 0) spans..add(const TextSpan(text: ' · '))..addAll(part(l.ueOutAmount('{amount}'), t.out));
        if (t != null && t.inn > 0) spans..add(const TextSpan(text: ' · '))..addAll(part(l.ueInAmount('{amount}'), t.inn));
        return Padding(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 0, KuberSpace.screenMargin, 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(style: base, children: spans)),
                if (t != null && t.cardBills > 0)
                  Text(l.ueCardBills(money(t.cardBills)),
                      style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _GridArea extends ConsumerWidget {
  final double p;
  final int rows;
  final PageController pages;
  final int count;
  final int Function(int) keyAt;
  final AsyncValue<List<CalendarOccurrence>> Function(int) monthData;
  final String filter;
  final int weekStart;
  final DateTime today, selected;
  final Map<String, Widget> cellCache;
  final ValueChanged<int> onPage;
  final ValueChanged<DateTime> onTap, onLongPress;
  final ValueChanged<int> onWeek;
  final VoidCallback onExpand;

  const _GridArea({
    required this.p,
    required this.rows,
    required this.pages,
    required this.count,
    required this.keyAt,
    required this.monthData,
    required this.filter,
    required this.weekStart,
    required this.today,
    required this.selected,
    required this.cellCache,
    required this.onPage,
    required this.onTap,
    required this.onLongPress,
    required this.onWeek,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final width = MediaQuery.sizeOf(context).width;
    final cellW = (width - 2 * _kGridPad) / 7;
    final collapsed = p >= 0.999;
    final reduced = KuberMotion.reduced(context);

    // Weekday row: short names, narrow where a short one is wider than a cell.
    final names = [
      for (var i = 0; i < 7; i++) DateTime(2026, 11, 1 + (weekStart + i) % 7), // 1 Nov 2026 is a Sunday
    ];
    final style = theme.textTheme.labelSmall!.copyWith(color: cs.onSurfaceVariant);
    final scaler = MediaQuery.textScalerOf(context);
    // This build runs on every frame while the grid collapses: measure the
    // weekday names once per locale, width and text size.
    final fmt = _weekdayFormats.putIfAbsent('$locale|$cellW|${scaler.scale(100)}|${style.fontSize}', () {
      final short = DateFormat.E(locale);
      final tooWide = names.any((d) {
        final p = TextPainter(
          text: TextSpan(text: short.format(d), style: style),
          textDirection: Directionality.of(context),
          textScaler: scaler,
        )..layout();
        final w = p.width;
        p.dispose();
        return w > cellW - 8;
      });
      return tooWide ? DateFormat('EEEEE', locale) : short;
    });

    // Spoken-label helpers, once per locale (never a DateFormat per cell).
    final labels = _LabelKit(
      l: l,
      dayMonth: _dateFormats.putIfAbsent('d MMMM|$locale', () => DateFormat('d MMMM', locale)),
      fullDate: _dateFormats.putIfAbsent('EEEE d MMMM|$locale', () => DateFormat('EEEE d MMMM', locale)),
      money: ref.watch(formatterProvider).formatCurrency,
      private: ref.watch(privacyModeProvider),
    );
    final gridH = rows * kDayCellHeight * (1 - p) + kDayCellHeight * p;
    final selectedKey = monthKeyOf(selected);
    final selectedRow = _gridDays(selectedKey, weekStart).indexWhere((d) => dayKey(d) == dayKey(selected)) ~/ 7;

    Widget monthGrid(int index) {
      final key = keyAt(index);
      final days = _gridDays(key, weekStart);
      final items = monthData(key).valueOrNull;
      final byDay = <int, List<CalendarOccurrence>>{};
      for (final o in _filtered(items ?? const [], filter)) {
        byDay.putIfAbsent(o.day, () => []).add(o);
      }
      final rowCount = days.length ~/ 7;
      final selRow = key == selectedKey ? selectedRow : 0;
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxHeight: rowCount * kDayCellHeight,
          child: Transform.translate(
            offset: Offset(0, reduced ? 0 : -selRow * kDayCellHeight * p),
            child: Column(
              children: [
                for (var r = 0; r < rowCount; r++)
                  Opacity(
                    opacity: r == selRow || reduced ? 1 : (1 - p),
                    child: Row(
                      children: [
                        for (final d in days.sublist(r * 7, r * 7 + 7))
                          _cell(labels, d, key, items, byDay[dayKey(d)] ?? const [], cellW),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final grid = PageView.builder(
      controller: pages,
      itemCount: count,
      physics: collapsed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
      onPageChanged: onPage,
      itemBuilder: (_, i) => monthGrid(i),
    );

    return Column(
      children: [
        SizedBox(
          height: _kWeekdayH,
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _kGridPad),
              child: Row(
                children: [
                  for (final d in names)
                    SizedBox(width: cellW, child: Text(fmt.format(d), textAlign: TextAlign.center, style: style)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: gridH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _kGridPad),
            child: collapsed
                ? Semantics(
                    label: l.ueA11yWeekCollapsed(DateFormat('d MMMM', locale).format(
                        _gridDays(selectedKey, weekStart)[selectedRow * 7])),
                    onTap: onExpand,
                    child: GestureDetector(
                      onHorizontalDragEnd: (e) {
                        final v = e.primaryVelocity ?? 0;
                        if (v.abs() > 200) onWeek(v < 0 ? 1 : -1);
                      },
                      child: grid,
                    ),
                  )
                : grid,
          ),
        ),
        Semantics(
          button: true,
          label: l.ueA11yHandle,
          onTap: onExpand,
          child: GestureDetector(
            onTap: onExpand,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: _kHandleH,
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: KuberShape.fullR,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(_LabelKit labels, DateTime d, int monthKey, List<CalendarOccurrence>? monthItems,
      List<CalendarOccurrence> items, double w) {
    final other = monthKeyOf(d) != monthKey;
    final isToday = dayKey(d) == dayKey(today);
    final isSelected = !other && dayKey(d) == dayKey(selected);
    // Everything the cell and its spoken label depend on. The month's list
    // is a new object whenever its data changes.
    final cacheKey = '${dayKey(d)}|$monthKey|$isSelected|${dayKey(today)}|${other && d.isAfter(selected)}|'
        '${identityHashCode(monthItems)}|$filter|$w|${labels.private}|${labels.l.localeName}';
    if (cellCache.length > 600) cellCache.clear();
    return cellCache[cacheKey] ??= _buildCell(labels, d, other, isToday, isSelected, items, w);
  }

  Widget _buildCell(_LabelKit labels, DateTime d, bool other, bool isToday, bool isSelected,
      List<CalendarOccurrence> items, double w) {
    final state = DayCellState(
      day: d.day,
      today: isToday && !other,
      selected: isSelected,
      past: d.isBefore(today),
      otherMonth: other,
      overdue: items.any((o) => o.status == OccurrenceStatus.overdue),
      dots: [
        for (final o in items)
          DayDot(o.event.sourceType, skipped: o.status == OccurrenceStatus.skipped),
      ],
    );
    return UpcomingDayCell(
      width: w,
      state: state,
      semanticLabel: _spokenLabel(labels, d, other, items),
      onTap: () => onTap(d),
      onLongPress: () => onLongPress(d),
    );
  }

  String _spokenLabel(_LabelKit k, DateTime d, bool other, List<CalendarOccurrence> items) {
    if (other) {
      final date = k.dayMonth.format(d);
      return d.isAfter(selected) ? k.l.ueA11yOtherMonthNext(date) : k.l.ueA11yOtherMonthPrev(date);
    }
    return spokenDayLabel(
      l: k.l,
      fullDate: k.fullDate,
      day: d,
      today: today,
      selected: dayKey(d) == dayKey(selected),
      items: items,
      money: k.money,
      private: k.private,
    );
  }
}

final _weekdayFormats = <String, DateFormat>{};
final _dateFormats = <String, DateFormat>{};

/// What a cell's spoken label needs, built once per grid build.
class _LabelKit {
  final AppLocalizations l;
  final DateFormat dayMonth, fullDate;
  final String Function(double) money;
  final bool private;
  const _LabelKit({
    required this.l,
    required this.dayMonth,
    required this.fullDate,
    required this.money,
    required this.private,
  });
}

/// "Today, Thursday 12 November, selected, 2 events, ₹349 due, 1 needs
/// confirmation" (design §7). Out for past days, due for today and later.
String spokenDayLabel({
  required AppLocalizations l,
  required DateFormat fullDate,
  required DateTime day,
  required DateTime today,
  required bool selected,
  required List<CalendarOccurrence> items,
  required String Function(double) money,
  required bool private,
}) {
  final date = fullDate.format(day);
  final isToday = dayKey(day) == dayKey(today);
  final bits = <String>[isToday ? l.ueA11yToday(date) : date];
  if (selected) bits.add(l.ueA11ySelected);
  bits.add(l.ueA11yEvents(items.length));
  if (items.isNotEmpty) {
    final t = OccurrenceTotals.of(items);
    if (private) {
      if (!t.isEmpty) bits.add(l.ueA11yHidden);
    } else {
      if (t.out > 0) bits.add(day.isBefore(today) ? l.ueOutAmount(money(t.out)) : l.ueA11yDue(money(t.out)));
      if (t.inn > 0) bits.add(l.ueInAmount(money(t.inn)));
      if (t.cardBills > 0) bits.add(l.ueA11yCardBill(money(t.cardBills)));
    }
  }
  final overdue = items.where((o) => o.status == OccurrenceStatus.overdue).length;
  if (overdue > 0) bits.add(l.ueA11yOverdue(overdue));
  final confirm = items.where((o) => o.status == OccurrenceStatus.needsConfirmation).length;
  if (confirm > 0) bits.add(l.ueA11yConfirm(confirm));
  return bits.join(', ');
}

class _DayList extends ConsumerWidget {
  final DateTime day, today;
  final AsyncValue<List<CalendarOccurrence>> month;
  final String filter;
  const _DayList({required this.day, required this.today, required this.month, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final priv = ref.watch(privacyModeProvider);
    final locale = Localizations.localeOf(context).toString();
    final all = month.valueOrNull;
    if (all == null) return const SizedBox(height: 120);
    final monthItems = _filtered(all, filter);
    final items = monthItems.where((o) => o.day == dayKey(day)).toList();
    final t = OccurrenceTotals.of(items);
    String money(double v) => maskAmount(fmt.formatCurrency(v), priv);
    final header = dayKey(day) == dayKey(today)
        ? l.ueDayToday(DateFormat('d MMMM', locale).format(day))
        : DateFormat('EEE, d MMMM', locale).format(day);
    final totals = [
      if (t.out > 0) l.ueOutAmount(money(t.out)),
      if (t.inn > 0) l.ueInAmount(money(t.inn)),
    ].join(' · ');

    final Widget body;
    if (monthItems.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.only(top: KuberSpace.lg),
        child: Column(children: [
          Icon(Icons.event_available_outlined, size: 32, color: cs.onSurfaceVariant),
          const SizedBox(height: KuberSpace.sm),
          Text(l.ueEmptyMonth, textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(color: cs.onSurface)),
        ]),
      );
    } else if (items.isEmpty) {
      body = KuberCard(
        child: Column(children: [
          Icon(Icons.event_available_outlined, size: 24, color: cs.onSurfaceVariant),
          const SizedBox(height: KuberSpace.sm),
          Text(l.ueEmptyDay, textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall!.copyWith(color: cs.onSurface)),
        ]),
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberGroup(children: [
            for (final o in items) UpcomingEventRow(event: o.event, occurrence: o),
          ]),
          if (items.any((o) => o.isCardDue && o.cardBill != null))
            Padding(
              padding: const EdgeInsets.fromLTRB(4, KuberSpace.sm, 4, 0),
              child: Text(l.ueCardNote,
                  style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: KuberMotion.of(context, KuberMotion.fast),
      child: Padding(
        key: ValueKey('${dayKey(day)}:$filter:${items.length}'),
        padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 12, KuberSpace.screenMargin, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (monthItems.isNotEmpty)
              KuberSectionHeader(
                title: header,
                trailing: totals.isEmpty
                    ? null
                    : Text(totals,
                        style: theme.textTheme.bodySmall!.copyWith(
                            color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
              ),
            body,
          ],
        ),
      ),
    );
  }
}
