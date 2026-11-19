part of 'ah_chart_view.dart';

extension _DonutChart on _AhChartViewState {
  // --- donut -----------------------------------------------------------------

  Widget _donut(BuildContext context, List<Color> colors, Listenable anim) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pts = widget.points;
    final total = pts.fold<double>(0, (a, p) => a + p.value.abs());
    final sel = _selected;
    String pct(int i) => total <= 0
        ? '0%'
        : '${(pts[i].value.abs() / total * 100).round()}%';

    final ring = SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _tap(
                _donutHit(d.localPosition, const Size(140, 140), pts, total)),
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: anim,
                builder: (context, _) => CustomPaint(
                  size: const Size(140, 140),
                  painter: _DonutPainter(
                      _shown(),
                      colors,
                      KuberMotion.curveEffects.transform(_drawT.value),
                      sel,
                      Curves.easeOutCubic.transform(_sel.value)),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: SizedBox(
              width: 76,
              child: AnimatedSwitcher(
                duration: KuberMotion.of(context, KuberMotion.fxFast),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween(
                            begin: KuberMotion.reduced(context) ? 1.0 : 0.8,
                            end: 1.0)
                        .animate(CurvedAnimation(
                            parent: a, curve: KuberMotion.fastCurve)),
                    child: child,
                  ),
                ),
                child: sel == null || sel >= pts.length
                    ? const SizedBox.shrink(key: ValueKey('none'))
                    : FittedBox(
                        key: ValueKey('c$sel'),
                        fit: BoxFit.scaleDown,
                        child: Text(pct(sel),
                            style: tt.titleLarge!.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                                fontFeatures: kAhTabular)),
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ring,
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: AnimatedBuilder(
                animation: _sel,
                builder: (context, _) {
                  final s = Curves.easeOutCubic.transform(_sel.value);
                  return Column(
                    children: [
                      for (var i = 0; i < pts.length; i++)
                        _LegendRow(
                          color: colors[i],
                          label: pts[i].label,
                          value: widget.fmt(pts[i].value),
                          opacity: sel != null && sel != i ? 1 - 0.62 * s : 1,
                          selected: sel == i,
                          onTap: () => _tap(i),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        _DetailSlot(
          child: sel == null || sel >= pts.length
              ? null
              : _ChartDetail(
                  key: ValueKey('d$sel'),
                  color: colors[sel],
                  label: pts[sel].label,
                  value: _full(pts[sel].value),
                  note: context.l10n.ahdOfTotal(pct(sel)),
                  onView: _viewable(pts[sel])
                      ? () => widget.onView!(pts[sel])
                      : null,
                ),
        ),
      ],
    );
  }
}

int? _donutHit(Offset o, Size size, List<AhChartPoint> pts, double total) {
  final c = size.center(Offset.zero);
  final d = o - c;
  final r = d.distance;
  final outer = math.min(size.width, size.height) / 2;
  if (r < outer * 0.4 || r > outer + 6 || total <= 0) return null;
  var a = math.atan2(d.dy, d.dx) + math.pi / 2;
  if (a < 0) a += 2 * math.pi;
  var acc = 0.0;
  for (var i = 0; i < pts.length; i++) {
    acc += pts[i].value.abs() / total * 2 * math.pi;
    if (a <= acc) return i;
  }
  return pts.isEmpty ? null : pts.length - 1;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.opacity,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final String label;
  final String value;
  final double opacity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final weight = selected ? FontWeight.w600 : FontWeight.w400;
    return InkWell(
      onTap: onTap,
      borderRadius: KuberShape.smallR,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                        fontSize: 13, fontWeight: weight, color: cs.onSurface)),
              ),
              const SizedBox(width: 8),
              Text(value,
                  style: localeFont(
                      fontSize: 13,
                      fontWeight: weight,
                      color: cs.onSurfaceVariant,
                      fontFeatures: kAhTabular)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.pts, this.colors, this.t, this.sel, this.s);
  final List<AhChartPoint> pts;
  final List<Color> colors;
  final double t;
  final int? sel;
  final double s;

  @override
  void paint(Canvas canvas, Size size) {
    final total = pts.fold<double>(0, (a, p) => a + p.value.abs());
    if (total <= 0) return;
    const stroke = 22.0;
    final outer = math.min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(
        center: size.center(Offset.zero), radius: outer - stroke / 2);
    var start = -math.pi / 2;
    final sweepTotal = 2 * math.pi * t;
    var drawn = 0.0;
    for (var i = 0; i < pts.length; i++) {
      final full = pts[i].value.abs() / total * 2 * math.pi;
      final sw = math.max(0.0, math.min(full, sweepTotal - drawn));
      drawn += full;
      if (sw <= 0) break;
      final isSel = sel == i;
      final dim = sel != null && !isSel;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + (isSel ? 6 * s : 0)
        ..color = colors[i].withValues(alpha: dim ? 1 - 0.62 * s : 1);
      final g = pts.length > 1 ? 0.03 : 0.0;
      canvas.drawArc(rect, start + g / 2, math.max(0.001, sw - g), false, paint);
      start += full;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) =>
      !identical(o.pts, pts) ||
      !listEquals(o.colors, colors) ||
      o.t != t ||
      o.sel != sel ||
      o.s != s;
}
