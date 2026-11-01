import 'dart:async';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/animated_amount.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/sms_today_summary.dart';
import '../screens/sms_import_widgets.dart' show SmsTypeGlyph;

/// "Untracked today" KPI hero at the top of the Unreviewed tab (boards 3.9d,
/// 3.9e): secondaryContainer fill, no outline, not tappable.
///
/// Motion: values tween to their new value (240 ms). When the last message of
/// today leaves Unreviewed while the card is on screen, the numbers count to 0,
/// then the card cross-fades into "All caught up for today" and the check
/// draws in (about 560 ms). Opening the page in any state shows the rest frame;
/// reduced motion is one 90 ms cross-fade.
class SmsTodayCard extends ConsumerStatefulWidget {
  const SmsTodayCard({super.key});

  @override
  ConsumerState<SmsTodayCard> createState() => _SmsTodayCardState();
}

class _SmsTodayCardState extends ConsumerState<SmsTodayCard>
    with SingleTickerProviderStateMixin {
  static const _count = Duration(milliseconds: 240);

  /// Each side of the switch uses one half: out over the first 120 ms (the
  /// switcher runs the outgoing curve in reverse), in over the last 120 ms.
  static const _fadeThrough = Interval(0.5, 1, curve: KuberMotion.decelerate);

  /// Check circle spring + path draw; 1 = rest.
  late final AnimationController _check = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  /// While non-null, the summary layout stays up with its values counting to
  /// zero, before the cross-fade into caught up.
  SmsTodaySummary? _zeroing;

  /// Values count up from zero (Undo, or a refresh adding the first messages).
  bool _countUp = false;
  Timer? _hold;

  @override
  void dispose() {
    _hold?.cancel();
    _check.dispose();
    super.dispose();
  }

  void _onChange(SmsTodaySummary? prev, SmsTodaySummary? next) {
    if (prev == null || next == null || prev == next) return;
    _hold?.cancel();
    final reduced = KuberMotion.reduced(context);
    setState(() {
      _countUp = prev.count == 0 && next.count > 0;
      _zeroing = null;
    });
    if (reduced || prev.count == 0 || next.count > 0) return;
    // Last message of today left the tab on screen: count down, then switch.
    setState(() => _zeroing = prev);
    _hold = Timer(_count, () {
      if (!mounted) return;
      setState(() => _zeroing = null);
      if (next.state == SmsTodayState.caughtUp) _check.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SmsTodaySummary?>(smsTodaySummaryProvider, _onChange);
    final live = ref.watch(smsTodaySummaryProvider);
    if (live == null) return const SizedBox.shrink();

    final reduced = KuberMotion.reduced(context);
    final cs = Theme.of(context).colorScheme;
    final zeroing = _zeroing;

    final Widget body;
    final Object key;
    if (zeroing != null || live.state == SmsTodayState.untracked) {
      body = _UntrackedBody(
        summary: zeroing ?? live,
        zero: zeroing != null,
        countUp: _countUp,
        duration: reduced ? Duration.zero : _count,
      );
      key = reduced ? live : SmsTodayState.untracked;
    } else {
      body = _CaughtBody(
        none: live.state == SmsTodayState.none,
        progress: _check,
      );
      key = reduced ? live : live.state;
    }

    return RepaintBoundary(
      child: KuberCard(
        hero: true,
        color: cs.secondaryContainer,
        borderColor: cs.secondaryContainer,
        child: AnimatedSize(
          duration: reduced
              ? KuberMotion.reducedFade
              : const Duration(milliseconds: 230),
          curve: KuberMotion.decelerate,
          alignment: Alignment.topCenter,
          // Fade through: the old state is gone before the new one appears,
          // so the two layouts' text never overlaps (a plain cross-fade did).
          child: AnimatedSwitcher(
            duration: reduced
                ? KuberMotion.reducedFade
                : const Duration(milliseconds: 240),
            switchInCurve: reduced ? Curves.linear : _fadeThrough,
            switchOutCurve: reduced ? Curves.linear : _fadeThrough,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topLeft,
              children: [...previous, ?current],
            ),
            child: KeyedSubtree(key: ValueKey(key), child: body),
          ),
        ),
      ),
    );
  }
}

class _UntrackedBody extends ConsumerWidget {
  final SmsTodaySummary summary;

  /// Show the layout of [summary] with every value at zero (count-down).
  final bool zero;
  final bool countUp;
  final Duration duration;

  const _UntrackedBody({
    required this.summary,
    required this.zero,
    required this.countUp,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = context.l10n;
    final fg = cs.onSecondaryContainer;
    final rule = fg.withValues(alpha: 0.18);
    final formatter = ref.watch(formatterProvider);
    final symbol = ref.watch(currencyProvider.select((c) => c.symbol));

    final s = summary;
    final hasSpent = s.spent > 0, hasReceived = s.received > 0;
    final both = hasSpent && hasReceived;
    // Either amount at 7+ digits (₹10,00,000): the two KPIs stack.
    final stack = both && (s.spent >= 1000000 || s.received >= 1000000);

    Widget kpi({required bool out, required double value, required bool big}) {
      final target = zero ? 0.0 : value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SmsTypeGlyph(type: out ? 'expense' : 'income', size: 22),
              const SizedBox(width: KuberSpace.sm),
              Text(
                out ? l10n.smsTodaySpentLabel : l10n.smsTodayReceivedLabel,
                style: text.labelLarge!.copyWith(color: fg),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedAmount(
            value: target,
            animateIn: countUp,
            duration: duration,
            curve: KuberMotion.decelerate,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Whole rupees while counting; the exact value at rest.
            format: (v) => formatter.formatCurrency(
              v == target ? v : v.roundToDouble(),
              symbol: symbol,
            ),
            style: (big ? text.displaySmall : text.headlineMedium)!.copyWith(
              color: fg,
            ),
          ),
        ],
      );
    }

    final Widget kpis;
    if (both && !stack) {
      kpis = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: kpi(out: true, value: s.spent, big: false)),
            const SizedBox(width: KuberSpace.lg),
            Container(width: 1, color: rule),
            const SizedBox(width: KuberSpace.lg),
            Expanded(child: kpi(out: false, value: s.received, big: false)),
          ],
        ),
      );
    } else if (both) {
      kpis = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          kpi(out: true, value: s.spent, big: false),
          const SizedBox(height: 14),
          kpi(out: false, value: s.received, big: false),
        ],
      );
    } else if (hasSpent || hasReceived) {
      kpis = kpi(
        out: hasSpent,
        value: hasSpent ? s.spent : s.received,
        big: true,
      );
    } else {
      kpis = const SizedBox.shrink();
    }

    final count = zero ? 0 : s.count;
    final noAmount = zero ? 0 : s.noAmount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.smsTodayLabel.toUpperCase(),
          style: text.labelMedium!.copyWith(letterSpacing: 0.8, color: fg),
        ),
        if (hasSpent || hasReceived) ...[
          const SizedBox(height: KuberSpace.lg),
          kpis,
        ],
        const SizedBox(height: KuberSpace.lg),
        Container(
          padding: const EdgeInsets.only(top: KuberSpace.md),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: rule))),
          child: Row(
            children: [
              Icon(Icons.sms_outlined, size: 18, color: fg),
              const SizedBox(width: KuberSpace.sm),
              Expanded(
                child: AnimatedAmount(
                  value: count.toDouble(),
                  animateIn: countUp,
                  duration: duration,
                  curve: KuberMotion.decelerate,
                  format: (v) => noAmount > 0
                      ? l10n.smsTodayCountNoAmount(v.round(), noAmount)
                      : l10n.smsTodayCount(v.round()),
                  style: text.bodyMedium!.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CaughtBody extends StatelessWidget {
  final bool none;
  final Animation<double> progress;

  const _CaughtBody({required this.none, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = context.l10n;
    final fg = cs.onSecondaryContainer;
    final scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: progress,
        curve: const Interval(0.2, 1, curve: KuberMotion.spring),
      ),
    );
    final draw = CurvedAnimation(
      parent: progress,
      curve: const Interval(0.2, 1, curve: KuberMotion.decelerate),
    );
    return Row(
      children: [
        ScaleTransition(
          scale: scale,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: CustomPaint(
              size: const Size.square(26),
              painter: _CheckPainter(draw, cs.onPrimary),
            ),
          ),
        ),
        const SizedBox(width: KuberSpace.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.smsTodayCaughtTitle,
                style: text.titleLarge!.copyWith(color: fg),
              ),
              Text(
                none ? l10n.smsTodayNoneBody : l10n.smsTodayCaughtBody,
                style: text.bodyMedium!.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The check mark, drawn from start to end as [progress] goes 0 to 1.
class _CheckPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;

  _CheckPainter(this.progress, this.color) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = Path()
      ..moveTo(5 * s, 12.5 * s)
      ..lineTo(9.8 * s, 17 * s)
      ..lineTo(19 * s, 7.5 * s);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final PathMetric m = path.computeMetrics().first;
    canvas.drawPath(m.extractPath(0, m.length * progress.value), paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}
