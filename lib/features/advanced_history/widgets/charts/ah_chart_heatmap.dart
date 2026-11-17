part of 'ah_chart_view.dart';

const _cell = 14.0, _gap = 3.0, _col = _cell + _gap, _monthH = 18.0;
const _dayGutter = 22.0;

/// Calendar heatmap: one rounded square per day, weeks as columns (Monday
/// on top), up to the last 53 weeks of the results; darker = more. Scrolls
/// sideways, starting at the latest week. A tap picks a day and shows its
/// value and "View transactions" under the grid.
class _AhHeatmap extends StatefulWidget {
  const _AhHeatmap({
    required this.points,
    required this.fmt,
    required this.dayLabel,
    required this.draw,
    required this.onView,
  });
  final List<AhChartPoint> points;
  final String Function(double) fmt;
  final String Function(String) dayLabel;
  final Animation<double> draw;
  final ValueChanged<AhChartPoint>? onView;

  @override
  State<_AhHeatmap> createState() => _AhHeatmapState();
}

class _AhHeatmapState extends State<_AhHeatmap> {
  final _scroll = ScrollController();
  DateTime? _selected;
  bool _jumped = false;

  @override
  void didUpdateWidget(_AhHeatmap old) {
    super.didUpdateWidget(old);
    // The card maps a fresh list on every build: compare the content.
    if (!_AhChartViewState._same(old.points, widget.points)) {
      _selected = null;
      _jumped = false;
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final values = <DateTime, AhChartPoint>{
      // Keys are day keys (`2026-11-03`) from the engine.
      for (final p in widget.points) DateTime.parse(p.key): p,
    };
    if (values.isEmpty) return const SizedBox.shrink();
    final days = values.keys.toList()..sort();
    final end = days.last;
    final first = days.first;
    final floor = DateTime(end.year, end.month, end.day - 7 * 53 + 1);
    final start = first.isAfter(floor) ? first : floor;
    final gridStart =
        DateTime(start.year, start.month, start.day - (start.weekday - 1));
    final weeks = end.difference(gridStart).inDays ~/ 7 + 1;

    // Four steps over the non-zero values (quartiles).
    final nz = [
      for (final d in days)
        if (!d.isBefore(start) && values[d]!.value > 0) values[d]!.value
    ]..sort();
    double q(double f) => nz.isEmpty ? 0 : nz[((nz.length - 1) * f).round()];
    final cuts = [q(0.25), q(0.5), q(0.75)];
    int level(double v) => v <= 0
        ? 0
        : v <= cuts[0]
            ? 1
            : v <= cuts[1]
                ? 2
                : v <= cuts[2]
                    ? 3
                    : 4;
    final shades = [
      cs.surfaceContainerHighest,
      cs.primary.withValues(alpha: 0.28),
      cs.primary.withValues(alpha: 0.5),
      cs.primary.withValues(alpha: 0.75),
      cs.primary,
    ];

    final locale = Localizations.localeOf(context).toString();
    final monthFmt = DateFormat('MMM', locale);
    final narrow = MaterialLocalizations.of(context).narrowWeekdays; // Sun first
    final width = weeks * _col;
    final height = _monthH + 7 * _col;
    if (!_jumped) {
      _jumped = true;
      // Start at the latest week.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    }

    DateTime? dayAt(Offset o) {
      final c = (o.dx / _col).floor();
      final r = ((o.dy - _monthH) / _col).floor();
      if (c < 0 || c >= weeks || r < 0 || r > 6) return null;
      final d =
          DateTime(gridStart.year, gridStart.month, gridStart.day + c * 7 + r);
      if (d.isBefore(start) || d.isAfter(end)) return null;
      return d;
    }

    final sel = _selected;
    final selPoint = sel == null ? null : values[sel];
    final selValue = selPoint?.value ?? 0;
    final small = tt.labelSmall!.copyWith(color: cs.onSurfaceVariant);

    final grid = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (dt) {
        final d = dayAt(dt.localPosition);
        setState(() => _selected = d == null || d == _selected ? null : d);
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: widget.draw,
          builder: (context, _) => CustomPaint(
            size: Size(width, height),
            painter: _HeatmapPainter(
              gridStart: gridStart,
              start: start,
              end: end,
              weeks: weeks,
              points: widget.points,
              shades: shades,
              locale: locale,
              shadeOf: (d) => shades[level(values[d]?.value ?? 0)],
              selected: sel,
              ring: cs.onSurface,
              monthLabel: monthFmt.format,
              label: small,
              t: KuberMotion.curveEffects.transform(widget.draw.value),
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mon, Wed, Fri (rows 0, 2, 4), pinned while the grid scrolls.
              SizedBox(
                width: _dayGutter,
                child: Column(children: [
                  const SizedBox(height: _monthH),
                  for (var r = 0; r < 7; r++)
                    SizedBox(
                      height: _col,
                      child: r.isEven && r < 6
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(narrow[(r + 1) % 7], style: small),
                            )
                          : null,
                    ),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('ah-heatmap-scroll'),
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: grid,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        // Less [] [] [] [] [] More
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(context.l10n.ahdLess, style: small),
            const SizedBox(width: 6),
            for (final c in shades) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: c,
                    borderRadius:
                        BorderRadius.circular(KuberShape.extraSmall)),
              ),
              const SizedBox(width: 3),
            ],
            const SizedBox(width: 3),
            Text(context.l10n.ahdMore, style: small),
          ],
        ),
        _DetailSlot(
          child: sel == null
              ? null
              : _ChartDetail(
                  key: ValueKey('h$sel'),
                  color: shades[level(selValue)],
                  label: widget.dayLabel(ahDayKey(sel)),
                  value: widget.fmt(selValue),
                  onView: widget.onView != null && selPoint != null
                      ? () => widget.onView!(selPoint)
                      : null,
                ),
        ),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.gridStart,
    required this.start,
    required this.end,
    required this.weeks,
    required this.points,
    required this.shades,
    required this.locale,
    required this.shadeOf,
    required this.selected,
    required this.ring,
    required this.monthLabel,
    required this.label,
    required this.t,
  });
  final DateTime gridStart, start, end;
  final int weeks;
  /// Data, shade colours and month locale: what [shadeOf] / [monthLabel]
  /// (closures, new each build) are derived from, compared in shouldRepaint.
  final List<AhChartPoint> points;
  final List<Color> shades;
  final String locale;
  final Color Function(DateTime) shadeOf;
  final DateTime? selected;
  final Color ring;
  final String Function(DateTime) monthLabel;
  final TextStyle label;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const r = Radius.circular(KuberShape.extraSmall);
    var lastMonth = -1;
    for (var c = 0; c < weeks; c++) {
      // Columns fade in left to right as the chart draws.
      final a = (t * weeks * 1.5 - c).clamp(0.0, 1.0);
      final colStart =
          DateTime(gridStart.year, gridStart.month, gridStart.day + c * 7);
      for (var row = 0; row < 7; row++) {
        final d = DateTime(colStart.year, colStart.month, colStart.day + row);
        if (d.isBefore(start) || d.isAfter(end)) continue;
        // Month name over the first column a month shows in.
        if (d.month != lastMonth && (d.day <= 7 || lastMonth < 0)) {
          lastMonth = d.month;
          final tp = TextPainter(
            text: TextSpan(text: monthLabel(d), style: label),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          tp.paint(canvas, Offset(c * _col, 0));
          tp.dispose();
        }
        final rect = Rect.fromLTWH(c * _col, _monthH + row * _col, _cell, _cell);
        final shade = shadeOf(d);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, r),
            Paint()..color = shade.withValues(alpha: shade.a * a));
        if (selected == d) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect.inflate(1.5), r),
            Paint()
              ..color = ring
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter o) =>
      !identical(o.points, points) ||
      !listEquals(o.shades, shades) ||
      o.locale != locale ||
      o.gridStart != gridStart ||
      o.start != start ||
      o.end != end ||
      o.weeks != weeks ||
      o.selected != selected ||
      o.ring != ring ||
      o.label != label ||
      o.t != t;
}
