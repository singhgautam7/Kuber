import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_path.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/animated_amount.dart';
import '../../../shared/widgets/expressive_shapes.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../home_v2/providers/home_v2_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';

/// Which part of the split bar is focused (v7.0.0-b "Balance card").
enum BalancePart { net, expense, income }

const double _barH = 24, _barHFocus = 32, _barHDim = 16, _areaH = 32;
const double _gap = 4, _minPart = 12, _topGap = 4, _zoneBottom = 20;
const double _underlineMs = 200, _underlineDelayMs = 60;

/// Home's first widget: net for the month over a 24 dp split bar. Tap a part
/// (or its number) to focus income or expense; tap it again, tap outside or
/// scroll to go back. Focus is this State only: no provider, no query. The
/// comparison with last month comes from [MonthlySummary] (same pass).
class BalanceHeroCard extends ConsumerStatefulWidget {
  final MonthlySummary summary;
  const BalanceHeroCard({super.key, required this.summary});

  @override
  ConsumerState<BalanceHeroCard> createState() => _BalanceHeroCardState();
}

class _BalanceHeroCardState extends ConsumerState<BalanceHeroCard>
    with TickerProviderStateMixin {
  BalancePart _part = BalancePart.net;
  BalancePart _last = BalancePart.expense; // content kept while fading out

  // Spring values: 1 while that part is focused.
  late final _ci = AnimationController.unbounded(vsync: this);
  late final _ce = AnimationController.unbounded(vsync: this);
  late final _rise = AnimationController.unbounded(vsync: this);
  late final _fade = AnimationController(vsync: this); // legend <-> comparison
  late final _ul = AnimationController(vsync: this); // underline
  late final Animation<double> _legendOpacity =
      Tween<double>(begin: 1, end: 0).animate(_fade);
  late final AppLifecycleListener _life =
      AppLifecycleListener(onHide: _resetNow, onPause: _resetNow);
  ScrollPosition? _pos;
  double _focusPixels = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos != _pos) {
      _pos?.removeListener(_onScroll);
      _pos = pos?..addListener(_onScroll);
    }
    // Leaving Home (tab branch inactive): reset without animation.
    if (!TickerMode.valuesOf(context).enabled) {
      _resetNow();
    } else if (ModalRoute.of(context)?.isCurrent == false) {
      // A sheet / dialog took the route: back to net, animated.
      _go(BalancePart.net);
    }
  }

  @override
  void initState() {
    super.initState();
    KuberPath.observer.changes.addListener(_onRootRoutes);
  }

  /// A sheet / dialog pushed on the root navigator over the shell.
  /// Deferred a frame: GoRouter pushes declarative pages during a build.
  void _onRootRoutes() {
    if (_part == BalancePart.net) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && KuberPath.shellRoute?.isCurrent == false && _part != BalancePart.net) {
        _go(BalancePart.net);
      }
    });
  }

  @override
  void dispose() {
    KuberPath.observer.changes.removeListener(_onRootRoutes);
    _pos?.removeListener(_onScroll);
    _life.dispose();
    for (final c in [_ci, _ce, _rise, _fade, _ul]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    final p = _pos;
    if (_part == BalancePart.net || p == null) return;
    if ((p.pixels - _focusPixels).abs() < 0.5) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _go(BalancePart.net));
    } else {
      _go(BalancePart.net);
    }
  }

  void _resetNow() {
    for (final c in [_ci, _ce, _rise, _fade, _ul]) {
      c.stop();
      c.value = 0;
    }
    if (_part != BalancePart.net) {
      _part = BalancePart.net;
      if (mounted) setState(() {});
    }
  }

  void _tap(BalancePart p) {
    _go(_part == p ? BalancePart.net : p);
    KuberHaptics.tick();
  }

  void _go(BalancePart next) {
    if (!mounted || next == _part) return;
    final lvl = KuberMotion.levelOf(context);
    final prev = _part;
    setState(() {
      _part = next;
      if (next != BalancePart.net) _last = next;
    });
    final on = next != BalancePart.net;
    if (on && prev == BalancePart.net) {
      _focusPixels = _pos?.pixels ?? 0;
    }
    final ciT = next == BalancePart.income ? 1.0 : 0.0;
    final ceT = next == BalancePart.expense ? 1.0 : 0.0;
    if (lvl == MotionLevel.off) {
      _ci.value = ciT;
      _ce.value = ceT;
      _fade.value = on ? 1 : 0;
      _rise.value = on ? 1 : 0;
      _ul.value = on ? 1 : 0;
      return;
    }
    final sp = KuberMotion.spatial(lvl, KuberMotion.springFast);
    _ci.springTo(ciT, sp);
    _ce.springTo(ceT, sp);
    _fade.animateTo(on ? 1 : 0,
        duration: KuberMotion.fxFast, curve: KuberMotion.curveEffects);
    if (lvl == MotionLevel.expressive) {
      _rise.springTo(on ? 1 : 0, KuberMotion.springDefault);
      if (on && prev == BalancePart.net) {
        _ul.animateTo(1,
            duration: const Duration(
                milliseconds: (_underlineMs + _underlineDelayMs) ~/ 1),
            curve: Curves.linear);
      } else if (!on) {
        _ul.animateTo(0, duration: KuberMotion.fxInstant, curve: Curves.linear);
      }
    } else {
      _rise.value = on ? 1 : 0;
      _ul.animateTo(on ? 1 : 0,
          duration: KuberMotion.fxFast, curve: KuberMotion.curveEffects);
    }
  }

  static Size _measure(String s, TextStyle st, TextScaler scaler) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: st),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final r = Size(tp.width, tp.preferredLineHeight);
    tp.dispose();
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final symbol = ref.watch(currencyProvider).symbol;
    String money(double v) => isPrivate
        ? maskAmount('', true)
        : formatter.formatCurrency(v, symbol: symbol).trim();
    final incomeText = isPrivate ? maskAmount('', true) : '+${money(s.totalIncome)}';
    final expenseText = isPrivate ? maskAmount('', true) : '\u2212${money(s.totalExpense)}';
    final total = s.totalIncome + s.totalExpense;
    final month = DateFormat('MMMM').format(DateTime.now()).toUpperCase();
    final l10n = context.l10n;

    // Home v2 empty state (board HV2.6): no 0, no empty bar; one line and an
    // Add transaction action unless Get started is on screen.
    if (total == 0 && ref.watch(isHomeV2Provider)) {
      final gsVisible = ref.watch(homeV2Provider.select((v) => v.gsEligible));
      return KuberCard(
        hero: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$month · ${l10n.netLabel}',
              style: tt.labelMedium!.copyWith(
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: KuberSpace.xs),
            Text(
              l10n.homeV2WBalanceEmpty(
                DateFormat.MMMM(Localizations.localeOf(context).toString())
                    .format(DateTime.now()),
              ),
              style: tt.bodyMedium!.copyWith(color: cs.onSurface),
            ),
            if (!gsVisible)
              Padding(
                padding: const EdgeInsets.only(top: KuberSpace.xs),
                child: TextButton.icon(
                  onPressed: () => context.push('/add-transaction'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.homeV2WBalanceEmptyAct),
                ),
              ),
          ],
        ),
      );
    }

    // Focus needs a bar to focus on.
    final part = total == 0 ? BalancePart.net : _part;
    final lvl = KuberMotion.levelOf(context);
    final expressive = lvl == MotionLevel.expressive;
    final expenseRole = context.kuberMoney.expense;
    final incomeRole = context.kuberMoney.income;
    // Bar colours: income primary; expense is primary at tone ~72 (45 in
    // dark), which is exactly the scheme's inversePrimary in both modes.
    final incomeColor = cs.primary;
    final expenseColor = cs.inversePrimary;
    final hasInc = s.totalIncome > 0, hasExp = s.totalExpense > 0;
    final frac = total > 0 ? s.totalIncome / total : 0.5;

    final legendStyle = tt.titleSmall!.copyWith(color: cs.onSurface);
    final labelStyle = tt.labelMedium!.copyWith(
      letterSpacing: 0.8,
      color: cs.onSurfaceVariant,
    );
    final scaler = MediaQuery.textScalerOf(context);
    final p = KuberSpace.cardPaddingHero;

    return TapRegion(
      onTapOutside: (_) => _go(BalancePart.net),
      child: KuberCard(
        hero: true,
        padding: EdgeInsets.fromLTRB(p, p, p, p - _zoneBottom),
        child: LayoutBuilder(
          builder: (context, cons) {
            final w = cons.maxWidth;
            final incSize = _measure(incomeText, legendStyle, scaler);
            final expSize = _measure(expenseText, legendStyle, scaler);
            // One line: dot 8 + gap 8 + text each side, 12 between.
            final twoLine = 16 + incSize.width + 16 + expSize.width + 12 > w;
            final rowH = incSize.height < 24 ? 24.0 : incSize.height;
            final legendH = twoLine ? rowH * 2 + 4 : rowH;
            final labelH = twoLine
                ? _measure('A', labelStyle, scaler).height * 2
                : 0.0;
            final stackH = _topGap + _areaH + 8 + legendH + _zoneBottom;
            final legendTop = _topGap + _areaH + 8;
            final geo = _barGeo(w, frac, hasInc, hasExp);

            Color amountColor() => switch (part) {
              BalancePart.expense => expenseRole,
              BalancePart.income => incomeRole,
              BalancePart.net =>
                (isPrivate || total > 0) ? cs.onSurface : cs.onSurfaceVariant,
            };
            final target = switch (part) {
              BalancePart.expense => -s.totalExpense,
              BalancePart.income => s.totalIncome,
              BalancePart.net => s.net,
            };
            String fmt(double v) {
              final sign = part == BalancePart.expense
                  ? '\u2212'
                  : part == BalancePart.income
                  ? '+'
                  : (v >= 0 ? '+' : '\u2212');
              return '$sign${formatter.formatCurrency(v.abs(), symbol: symbol).trim()}';
            }

            final focusColor = _last == BalancePart.income
                ? incomeRole
                : expenseRole;
            final labelRaw = switch (part) {
              BalancePart.expense => l10n.balLabelExpense(month),
              BalancePart.income => l10n.balLabelIncome(month),
              BalancePart.net => l10n.balLabelNet(month),
            };
            final labelFull = labelRaw.toUpperCase();
            final cut = labelFull.lastIndexOf(' · ') + 3;

            Widget dot(Color c) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            );
            Widget legendItem(Color c, String t, {bool dotAfter = false}) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!dotAfter) dot(c),
                if (!dotAfter) const SizedBox(width: 8),
                Text(t, style: legendStyle, maxLines: 1),
                if (dotAfter) const SizedBox(width: 8),
                if (dotAfter) dot(c),
              ],
            );

            Widget zone(
              Key key,
              BalancePart p,
              double left,
              double width,
              double top,
              double height,
              String label,
            ) => Positioned(
              left: left,
              width: width,
              top: top,
              height: height,
              child: Semantics(
                button: true,
                label: label,
                excludeSemantics: true,
                onTap: () => _tap(p),
                child: GestureDetector(
                  key: key,
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _tap(p),
                ),
              ),
            );

            final incLabel = l10n.balA11yShowIncome(money(s.totalIncome));
            final expLabel = l10n.balA11yShowExpense(money(s.totalExpense));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: labelH),
                  child: Wrap(
                    children: [
                      Text(labelFull.substring(0, cut), style: labelStyle),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedSwitcher(
                            duration: lvl == MotionLevel.off
                                ? Duration.zero
                                : KuberMotion.fxFast,
                            child: Text(
                              labelFull.substring(cut),
                              key: ValueKey(part),
                              style: labelStyle,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -3,
                            child: AnimatedBuilder(
                              animation: _ul,
                              builder: (_, _) {
                                final v = _ul.value.clamp(0.0, 1.0);
                                final wf = expressive
                                    ? KuberMotion.curveEffects.transform(
                                        ((v * (_underlineMs + _underlineDelayMs) -
                                                    _underlineDelayMs) /
                                                _underlineMs)
                                            .clamp(0.0, 1.0),
                                      )
                                    : 1.0;
                                return Opacity(
                                  opacity: expressive ? 1 : v,
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: FractionallySizedBox(
                                      widthFactor: wf,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: focusColor,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: amountColor()),
                  duration: lvl == MotionLevel.off
                      ? Duration.zero
                      : KuberMotion.fxFast,
                  curve: KuberMotion.curveEffects,
                  builder: (_, c, _) => AnimatedAmount(
                    value: target,
                    animateIn: false,
                    isPrivate: isPrivate,
                    maxLines: 1,
                    format: fmt,
                    style: tt.headlineMedium!.copyWith(color: c),
                  ),
                ),
                SizedBox(
                  height: stackH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _topGap,
                        height: _areaH,
                        child: RepaintBoundary(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(end: frac),
                            duration: lvl == MotionLevel.off
                                ? Duration.zero
                                : KuberMotion.standardCurve.settle,
                            curve: KuberMotion.standardCurve.clamped,
                            builder: (_, f, _) => CustomPaint(
                              painter: _BarPainter(
                                ci: _ci,
                                ce: _ce,
                                frac: f,
                                hasInc: hasInc,
                                hasExp: hasExp,
                                empty: total == 0,
                                incColor: incomeColor,
                                expColor: expenseColor,
                                trackColor: cs.surfaceContainerHighest,
                                expressive: expressive,
                                subtle: lvl == MotionLevel.subtle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Legend <-> comparison, same box in both states.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: legendTop,
                        height: legendH,
                        child: FadeTransition(
                          opacity: _legendOpacity,
                          child: twoLine
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: rowH,
                                      child: legendItem(incomeColor, incomeText),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: rowH,
                                      child: legendItem(expenseColor, expenseText),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    legendItem(incomeColor, incomeText),
                                    legendItem(
                                      expenseColor,
                                      expenseText,
                                      dotAfter: true,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: legendTop,
                        height: legendH,
                        child: IgnorePointer(
                          child: FadeTransition(
                            opacity: _fade,
                            child: AnimatedBuilder(
                              animation: _rise,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(
                                  0,
                                  expressive ? (1 - _rise.value) * 6 : 0,
                                ),
                                child: child,
                              ),
                              child: _Comparison(
                                part: _last,
                                summary: s,
                                color: focusColor,
                                money: money,
                                twoLine: twoLine,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (total > 0) ...[
                        // Bar parts: each is a button (bar area plus its gap).
                        if (hasInc)
                          zone(
                            const Key('balBarIncome'),
                            BalancePart.income,
                            0,
                            hasExp ? geo.incW + _gap / 2 : w,
                            0,
                            _topGap + _areaH + 8,
                            incLabel,
                          ),
                        if (hasExp)
                          zone(
                            const Key('balBarExpense'),
                            BalancePart.expense,
                            hasInc ? geo.incW + _gap / 2 : 0,
                            hasInc ? w - geo.incW - _gap / 2 : w,
                            0,
                            _topGap + _areaH + 8,
                            expLabel,
                          ),
                        // Numbers: only while the legend is what is shown.
                        if (part == BalancePart.net) ...[
                          if (hasInc)
                            zone(
                              const Key('balNumIncome'),
                              BalancePart.income,
                              0,
                              incSize.width + 16 + 8,
                              legendTop,
                              twoLine ? rowH + 2 : rowH + _zoneBottom,
                              incLabel,
                            ),
                          if (hasExp)
                            zone(
                              const Key('balNumExpense'),
                              BalancePart.expense,
                              twoLine
                                  ? 0
                                  : w - expSize.width - 16 - 8,
                              expSize.width + 16 + 8,
                              legendTop + (twoLine ? rowH + 2 : 0),
                              rowH + _zoneBottom,
                              expLabel,
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

({double incW, double expW}) _barGeo(
  double w,
  double frac,
  bool hasInc,
  bool hasExp,
) {
  if (hasInc && !hasExp) return (incW: w, expW: 0);
  if (!hasInc && hasExp) return (incW: 0, expW: w);
  final t = w - _gap;
  final inc = (t * frac).clamp(_minPart, t - _minPart).toDouble();
  return (incW: inc, expW: t - inc);
}

class _Comparison extends StatelessWidget {
  final BalancePart part;
  final MonthlySummary summary;
  final Color color;
  final String Function(double) money;
  final bool twoLine;
  const _Comparison({
    required this.part,
    required this.summary,
    required this.color,
    required this.money,
    required this.twoLine,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isExpense = part == BalancePart.expense;
    final cur = isExpense ? summary.totalExpense : summary.totalIncome;
    final prev = isExpense ? summary.prevExpense : summary.prevIncome;
    final d = cur - prev;
    final IconData? icon;
    final String text;
    if (!summary.hasEarlier) {
      icon = null;
      text = l10n.balCmpFirst;
    } else if (prev.abs() < 0.005) {
      // Earlier months exist but nothing of this kind last month: no
      // comparison against zero (owner, 19 Nov).
      icon = null;
      text = isExpense ? l10n.balCmpNoSpendLast : l10n.balCmpNoEarnLast;
    } else if (d.abs() < 0.005) {
      icon = Icons.trending_flat_rounded;
      text = l10n.balCmpSame;
    } else if (d > 0) {
      icon = Icons.trending_up_rounded;
      text = isExpense
          ? l10n.balCmpSpendMore(money(d))
          : l10n.balCmpEarnMore(money(d));
    } else {
      icon = Icons.trending_down_rounded;
      text = isExpense
          ? l10n.balCmpSpendLess(money(-d))
          : l10n.balCmpEarnLess(money(-d));
    }
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment:
          twoLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Padding(
            padding: EdgeInsets.only(top: twoLine ? 3 : 0),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            text,
            maxLines: twoLine ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.ci,
    required this.ce,
    required this.frac,
    required this.hasInc,
    required this.hasExp,
    required this.empty,
    required this.incColor,
    required this.expColor,
    required this.trackColor,
    required this.expressive,
    required this.subtle,
  }) : super(repaint: Listenable.merge([ci, ce]));

  final AnimationController ci, ce;
  final double frac;
  final bool hasInc, hasExp, empty, expressive, subtle;
  final Color incColor, expColor, trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    void seg(double x, double w, double h, Color c, double a, bool sj,
        bool ej, double jr) {
      final r = Rect.fromLTWH(x, cy - h / 2, w, h);
      canvas.drawRSuperellipse(
        ExpressiveShapes.barSegment(r,
            startJoint: sj, endJoint: ej, jointRadius: jr),
        Paint()..color = c.withValues(alpha: a),
      );
    }

    if (empty) {
      seg(0, size.width, _barH, trackColor, 1, false, false, 0);
      return;
    }
    final geo = _barGeo(size.width, frac, hasInc, hasExp);
    final i = ci.value, e = ce.value;
    // Subtle: only the tapped part changes height; the other just dims.
    final hI = _barH +
        (_barHFocus - _barH) * i -
        (subtle ? 0 : (_barH - _barHDim) * e);
    final hE = _barH +
        (_barHFocus - _barH) * e -
        (subtle ? 0 : (_barH - _barHDim) * i);
    final aI = 1 - 0.62 * e.clamp(0.0, 1.0);
    final aE = 1 - 0.62 * i.clamp(0.0, 1.0);
    final jI = ExpressiveShapes.joint +
        (expressive ? (ExpressiveShapes.jointActive - ExpressiveShapes.joint) * i : 0);
    final jE = ExpressiveShapes.joint +
        (expressive ? (ExpressiveShapes.jointActive - ExpressiveShapes.joint) * e : 0);
    final both = hasInc && hasExp;
    if (hasInc) {
      seg(0, geo.incW, hI.clamp(8.0, 36.0), incColor, aI, false, both, jI);
    }
    if (hasExp) {
      final x = hasInc ? geo.incW + _gap : 0.0;
      seg(x, geo.expW, hE.clamp(8.0, 36.0), expColor, aE, both, false, jE);
    }
  }

  @override
  bool shouldRepaint(_BarPainter o) =>
      o.frac != frac ||
      o.hasInc != hasInc ||
      o.hasExp != hasExp ||
      o.empty != empty ||
      o.incColor != incColor ||
      o.expColor != expColor ||
      o.trackColor != trackColor ||
      o.expressive != expressive ||
      o.subtle != subtle;
}
