part of 'ah_chart_view.dart';

/// Clips left and right only (the tooltip may rise above the plot).
class _SideClipper extends CustomClipper<Rect> {
  const _SideClipper();
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -200, size.width, size.height + 200);
  @override
  bool shouldReclip(_SideClipper oldClipper) => false;
}

/// Grows to fit the detail row (expressiveDefaultSpatial) and back.
class _DetailSlot extends StatelessWidget {
  const _DetailSlot({required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final reduced = KuberMotion.reduced(context);
    return AnimatedSize(
      duration: reduced ? KuberMotion.fxInstant : KuberMotion.defaultCurve.settle,
      curve: reduced ? Curves.linear : KuberMotion.defaultCurve.clamped,
      alignment: Alignment.topCenter,
      child: child ?? const SizedBox(width: double.infinity),
    );
  }
}

/// Dots and names of the compared values.
class _Legend extends StatelessWidget {
  const _Legend({required this.labels, required this.colors});
  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Wrap(
      spacing: KuberSpace.lg,
      runSpacing: KuberSpace.xs,
      children: [
        for (var i = 0; i < labels.length; i++)
          Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: colors[i], shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(labels[i],
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ]),
      ],
    );
  }
}

/// Floating tooltip on bars and line (Home chart style): inverseSurface, r8,
/// label, value (or one row per compared value plus the total), "View
/// transactions".
class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.label,
    required this.value,
    required this.rows,
    required this.onView,
  });
  final String label;

  /// The point's value; null when the single row says it.
  final String? value;
  final List<(Color, String, String)> rows;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final on = cs.onInverseSurface;
    final small = tt.labelMedium!;
    return Container(
      key: const ValueKey('ah-chart-tooltip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: KuberShape.smallR,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: small.copyWith(color: on.withValues(alpha: 0.8))),
          const SizedBox(height: 2),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: r.$1, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(r.$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small.copyWith(color: on.withValues(alpha: 0.8))),
                ),
                const SizedBox(width: 6),
                Text(r.$3,
                    style: small.copyWith(
                        color: on,
                        fontWeight: FontWeight.w600,
                        fontFeatures: kAhTabular)),
              ]),
            ),
          if (value != null)
            Padding(
              padding: EdgeInsets.only(top: rows.isEmpty ? 0 : 4),
              child: Text(value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall!.copyWith(
                      color: on,
                      fontWeight: FontWeight.w700,
                      fontFeatures: kAhTabular)),
            ),
          if (onView != null)
            GestureDetector(
              key: const ValueKey('ah-chart-view'),
              behavior: HitTestBehavior.opaque,
              onTap: onView,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(context.l10n.ahdViewTxns,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: small.copyWith(color: cs.inversePrimary)),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded,
                        size: 14, color: cs.inversePrimary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Under the donut / heatmap once a part is picked: name, exact value and a
/// note, then "View transactions". Each part fades up 30 ms after the one
/// before.
class _ChartDetail extends StatelessWidget {
  const _ChartDetail({
    super.key,
    required this.color,
    required this.label,
    required this.value,
    required this.onView,
    this.note,
  });
  final Color color;
  final String label, value;
  final String? note;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      key: const ValueKey('ah-donut-detail'),
      margin: const EdgeInsets.only(top: KuberSpace.md),
      padding: const EdgeInsets.fromLTRB(
          KuberSpace.lg, KuberSpace.md, KuberSpace.md, KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AhFadeIn(
                  child: Row(children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodyMedium!
                              .copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ]),
                ),
                const SizedBox(height: 2),
                AhFadeIn(
                  delay: const Duration(milliseconds: 30),
                  child: Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleMedium!.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                          fontFeatures: kAhTabular)),
                ),
                if (note != null)
                  AhFadeIn(
                    delay: const Duration(milliseconds: 60),
                    child: Text(note!,
                        style:
                            tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          if (onView != null)
            AhFadeIn(
              delay: const Duration(milliseconds: 90),
              child: AppButton(
                key: const ValueKey('ah-chart-view'),
                label: context.l10n.ahdViewTxns,
                height: 40,
                icon: Icons.arrow_forward_rounded,
                iconAfterLabel: true,
                onPressed: onView,
              ),
            ),
        ],
      ),
    );
  }
}

/// Formatters are rebuilt as closures every build: same output = same.
bool _sameFmt(String Function(double) a, String Function(double) b) =>
    identical(a, b) || a(1234.5) == b(1234.5);

void _text(Canvas c, String s, TextStyle st, Offset at,
    {double maxW = 80,
    TextAlign align = TextAlign.center,
    double alpha = 1,
    double? within,
    bool right = false}) {
  final tp = TextPainter(
    text: TextSpan(
        text: s,
        style: st.copyWith(color: st.color?.withValues(alpha: alpha))),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
    textAlign: align,
  )..layout(maxWidth: maxW);
  var x = right ? at.dx - tp.width : at.dx - tp.width / 2;
  // Keep edge labels inside the chart instead of running off the card.
  if (within != null) x = x.clamp(0.0, math.max(0.0, within - tp.width));
  tp.paint(c, Offset(x, at.dy));
  tp.dispose();
}
