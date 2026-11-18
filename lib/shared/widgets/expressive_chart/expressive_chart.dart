import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import 'chart_model.dart';
import 'chart_painter.dart';
import 'chart_physics.dart';
import 'chart_tooltip.dart';

export 'chart_model.dart';
export 'chart_tooltip.dart' show TooltipPlacement, placeTooltip;

/// Key of the chart's horizontal scroll view (tests drag it).
const Key kExpressiveChartScrollKey = Key('expressive_chart_scroll');

/// Key of the open tooltip card.
const Key kExpressiveChartTooltipKey = Key('expressive_chart_tooltip');

/// The v7.0.0-b layered-column / line chart (handoff Part 1). Pure widget:
/// the caller supplies formatted strings via [formatAmount] / [formatAxis]
/// (privacy masking included) and pages older periods through [onLoadOlder].
class ExpressiveChart extends StatefulWidget {
  const ExpressiveChart({
    super.key,
    required this.series,
    required this.periods,
    required this.formatAmount,
    required this.formatAxis,
    this.mode = ExpressiveChartMode.bar,
    this.window = 6,
    this.state = ExpressiveChartState.data,
    this.selected,
    this.onSelectedChanged,
    this.onLoadOlder,
    this.hasMoreOlder = false,
    this.loadingOlder = false,
    this.resetKey,
    this.surface,
    this.emptyTitle,
    this.emptyBody,
    this.singleNote,
  });

  /// 1 or 2 series. Two: income first, expense second (net row).
  final List<ExpressiveSeries> series;

  /// Oldest first; the last one is "today".
  final List<ExpressivePeriod> periods;
  final String Function(double) formatAmount;

  /// Compact axis label without a currency symbol.
  final String Function(double) formatAxis;
  final ExpressiveChartMode mode;

  /// Slots in view: 6 (6M, Month) or 12 (1Y).
  final int window;
  final ExpressiveChartState state;

  /// Selected period key (optional; the chart also selects by itself).
  final int? selected;
  final ValueChanged<int?>? onSelectedChanged;

  /// Called when the left edge comes within 2 slots and [hasMoreOlder].
  final VoidCallback? onLoadOlder;
  final bool hasMoreOlder;

  /// Skeleton pills on the left while the owner loads a page.
  final bool loadingOlder;

  /// Change it to replay the first-show animation and clear the selection
  /// (Analytics bucket change).
  final Object? resetKey;

  /// Card colour behind the chart (edge fade). Defaults to surfaceContainer.
  final Color? surface;
  final String? emptyTitle;
  final String? emptyBody;
  final String? singleNote;

  @override
  State<ExpressiveChart> createState() => _ExpressiveChartState();
}

class _ExpressiveChartState extends State<ExpressiveChart>
    with TickerProviderStateMixin
    implements ChartLive {
  final _scroll = ScrollController();
  final _link = LayerLink();
  final _plotKey = GlobalKey();
  final _ovl = OverlayPortalController();
  late final Listenable _merged;

  late final AnimationController _winC = AnimationController.unbounded(vsync: this);
  late final AnimationController _yC = AnimationController.unbounded(vsync: this);
  late final AnimationController _modeC = AnimationController.unbounded(vsync: this);
  late final AnimationController _dataC = AnimationController.unbounded(vsync: this);
  late final AnimationController _introC = AnimationController(vsync: this);
  late final AnimationController _selInC = AnimationController.unbounded(vsync: this);
  late final AnimationController _selOutC = AnimationController.unbounded(vsync: this);
  late final AnimationController _dimC =
      AnimationController(vsync: this, duration: KuberMotion.fxFast);
  late final AnimationController _yRollC =
      AnimationController(vsync: this, duration: KuberMotion.digitRoll);
  late final AnimationController _tipPosC = AnimationController.unbounded(vsync: this);
  late final AnimationController _tipC = AnimationController.unbounded(vsync: this);

  late List<List<double>> _from;
  late List<List<double>> _to;
  late List<ExpressivePeriod> _cur;
  double _targetMax = 100;
  double _prevMax = 100;
  bool _introStarted = false;
  bool _introIsLine = false;
  bool _shimmerOn = false;

  int? _selKey, _prevSelKey, _tipKey;
  int? _selIdxCache, _prevIdxCache;
  double _plotW = 0;
  double _semPx = 0;
  bool _edgeArmed = true;
  double _edgePx = 0;
  int _requestedAt = -1;
  ScrollPosition? _page;
  ChartTextCache _texts = ChartTextCache();
  Object? _themeSig;

  MotionLevel _level = MotionLevel.expressive;

  // ---- ChartLive ------------------------------------------------------------

  @override
  double get pixels => _scroll.hasClients ? _scroll.position.pixels : 0;
  @override
  double get maxExtent => _scroll.hasClients ? _scroll.position.maxScrollExtent : 0;
  @override
  double get win => _winC.value;
  @override
  double get yMax => _yC.value;
  @override
  double get mode => _modeC.value.clamp(0.0, 1.0);
  @override
  double get dataT => _dataC.value;
  @override
  double get intro => _introC.value;
  @override
  bool get introIsLine => _introIsLine;
  @override
  int? get selIdx => _selIdxCache;
  @override
  int? get prevSelIdx => _prevIdxCache;
  @override
  double get selIn => _selInC.value;
  @override
  double get selOut => _selOutC.value;
  @override
  double get dim => _dimC.value;
  @override
  double get yRoll => _yRollC.value;
  @override
  double get yPrevMax => _prevMax;
  @override
  double get yTargetMax => _targetMax;
  @override
  void addListener(VoidCallback l) => _merged.addListener(l);
  @override
  void removeListener(VoidCallback l) => _merged.removeListener(l);

  // ---- lifecycle ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _cur = widget.periods;
    _to = _valuesFor(_cur);
    _from = _to;
    _targetMax = _prevMax = _computeMax(_cur);
    _yC.value = _targetMax;
    _winC.value = widget.window.toDouble();
    _modeC.value = widget.mode == ExpressiveChartMode.line ? 1 : 0;
    _dataC.value = 1;
    _selInC.value = 0;
    _selOutC.value = 0;
    _yRollC.value = 1;
    _selKey = widget.selected;
    _resolveIdx();
    if (_selKey != null) {
      _selInC.value = 1;
      _dimC.value = 1;
    }
    _merged = Listenable.merge([
      _scroll, _winC, _yC, _modeC, _dataC, _introC, _selInC, _selOutC, //
      _dimC, _yRollC, ShimmerClock.instance.phase,
    ]);
    _scroll.addListener(_onScroll);
    _tipC.addStatusListener((_) => _syncOverlay());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _level = KuberMotion.levelOf(context);
    final theme = Theme.of(context);
    final sig = (theme.colorScheme, MediaQuery.textScalerOf(context));
    if (_themeSig != sig) {
      _themeSig = sig;
      _texts = ChartTextCache();
    }
    _page = Scrollable.maybeOf(context)?.position;
    if (!_introStarted) {
      _introStarted = true;
      _startIntro();
    }
    _syncShimmer();
  }

  @override
  void dispose() {
    if (_shimmerOn) ShimmerClock.instance.release();
    _scroll.dispose();
    for (final c in [
      _winC, _yC, _modeC, _dataC, _introC, _selInC, _selOutC, _dimC, //
      _yRollC, _tipPosC, _tipC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ExpressiveChart old) {
    super.didUpdateWidget(old);
    final windowChanged = old.window != widget.window;
    final reset = old.resetKey != widget.resetKey;
    if (widget.selected != old.selected && widget.selected != _selKey) {
      _setSel(widget.selected, notify: false);
    }
    if (reset || windowChanged) {
      _setSel(null, notify: false);
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
    if (windowChanged) _spring(_winC, widget.window.toDouble(), KuberMotion.springStandard);
    if (reset) {
      _cur = widget.periods;
      _to = _valuesFor(_cur);
      _from = _to;
      _dataC.value = 1;
      _retargetMax(animate: false);
      _startIntro();
    } else if (!listEquals(old.periods, widget.periods) || !listEquals(old.series, widget.series)) {
      _updateData();
    }
    _resolveIdx();
    if (old.mode != widget.mode) _animateMode();
    _requestedAt = -1;
    _syncShimmer();
  }

  // ---- animation helpers ----------------------------------------------------

  void _spring(AnimationController c, double target, SpringDescription s) {
    switch (_level) {
      case MotionLevel.off:
        c.stop();
        c.value = target;
      case MotionLevel.subtle:
        c.springTo(target, KuberMotion.springSubtle);
      case MotionLevel.expressive:
        c.springTo(target, s);
    }
  }

  void _animateMode() {
    final t = widget.mode == ExpressiveChartMode.line ? 1.0 : 0.0;
    if (_level == MotionLevel.subtle) {
      _modeC.animateTo(t, duration: KuberMotion.fxDefault, curve: KuberMotion.curveEffects);
    } else {
      _spring(_modeC, t, KuberMotion.springStandard);
    }
  }

  void _startIntro() {
    _introIsLine = widget.mode == ExpressiveChartMode.line;
    switch (_level) {
      case MotionLevel.off:
        _introC.value = 1;
      case MotionLevel.subtle:
        _introC.duration = KuberMotion.fxDefault;
        _introC.forward(from: 0);
      case MotionLevel.expressive:
        _introC.duration = _introIsLine
            ? const Duration(milliseconds: 400)
            : KuberMotion.standardCurve.settle + KuberMotion.staggerStep * 5;
        _introC.forward(from: 0);
    }
  }

  void _syncShimmer() {
    final want = _skeletons > 0 && _level == MotionLevel.expressive;
    if (want == _shimmerOn) return;
    _shimmerOn = want;
    want ? ShimmerClock.instance.acquire() : ShimmerClock.instance.release();
  }

  int get _skeletons =>
      (widget.state == ExpressiveChartState.loading || widget.loadingOlder)
          ? widget.window
          : 0;

  // ---- data -----------------------------------------------------------------

  List<List<double>> _valuesFor(List<ExpressivePeriod> ps) => [
        for (final p in ps)
          [
            for (var s = 0; s < widget.series.length; s++)
              s < p.values.length ? p.values[s] : 0.0,
          ],
      ];

  double _computeMax(List<ExpressivePeriod> ps) {
    var m = 0.0;
    for (final p in ps) {
      for (final v in p.values) {
        m = math.max(m, v);
      }
    }
    return ExpressiveChartMetrics.niceMax(m);
  }

  void _retargetMax({bool animate = true}) {
    final next = _computeMax(widget.periods);
    if (next == _targetMax) return;
    _prevMax = _targetMax;
    _targetMax = next;
    if (animate && _level != MotionLevel.off) {
      _yRollC.forward(from: 0);
      _spring(_yC, next, KuberMotion.springStandard);
    } else {
      _yC.value = next;
      _yRollC.value = 1;
    }
  }

  void _updateData() {
    final old = <int, int>{
      for (var i = 0; i < _cur.length; i++) _cur[i].key: i,
    };
    final t = _dataC.value;
    List<double> shown(int i) => [
          for (var s = 0; s < _from[i].length; s++)
            math.max(0.0, _from[i][s] + (_to[i][s] - _from[i][s]) * t),
        ];
    final next = widget.periods;
    final newTo = _valuesFor(next);
    final newFrom = <List<double>>[];
    var changed = false;
    for (var i = 0; i < next.length; i++) {
      final oi = old[next[i].key];
      final zeros = List<double>.filled(newTo[i].length, 0);
      if (oi == null) {
        newFrom.add(zeros);
        changed = true;
      } else {
        final s = shown(oi);
        newFrom.add(s.length == newTo[i].length ? s : zeros);
        if (!listEquals(s, newTo[i])) changed = true;
      }
    }
    _cur = next;
    _from = newFrom;
    _to = newTo;
    _retargetMax();
    if (changed) {
      _dataC.value = 0;
      _spring(_dataC, 1, KuberMotion.springStandard);
    } else {
      _dataC.value = 1;
    }
  }

  void _resolveIdx() {
    int? idx(int? key) {
      if (key == null) return null;
      final i = widget.periods.indexWhere((p) => p.key == key);
      return i < 0 ? null : i;
    }

    _selIdxCache = idx(_selKey);
    _prevIdxCache = idx(_prevSelKey);
  }

  // ---- selection --------------------------------------------------------------

  void _setSel(int? key, {bool notify = true}) {
    if (key == _selKey) return;
    final old = _selKey;
    if (old != null) {
      _prevSelKey = old;
      _selOutC.value = _selInC.value;
      _spring(_selOutC, 0, KuberMotion.springFast);
    }
    _selKey = key;
    _selInC.stop();
    _selInC.value = 0;
    if (key != null) {
      _tipKey = key;
      final idx = widget.periods.indexWhere((p) => p.key == key);
      if (old == null) {
        _tipPosC.stop();
        _tipPosC.value = idx.toDouble();
        _openTip();
      } else if (_level == MotionLevel.off) {
        _tipPosC.value = idx.toDouble();
      } else {
        _tipPosC.springTo(idx.toDouble(),
            _level == MotionLevel.subtle ? KuberMotion.springSubtle : KuberMotion.springDefault);
      }
      _spring(_selInC, 1, KuberMotion.springFast);
      _dimTo(1);
    } else {
      _closeTip();
      _dimTo(0);
    }
    _resolveIdx();
    _syncOverlay();
    if (notify) widget.onSelectedChanged?.call(key);
    setState(() {});
  }

  void _dimTo(double t) {
    if (_level == MotionLevel.off) {
      _dimC.value = t;
    } else {
      _dimC.animateTo(t, curve: KuberMotion.curveEffects);
    }
  }

  void _openTip() {
    switch (_level) {
      case MotionLevel.off:
        _tipC.value = 1;
      case MotionLevel.subtle:
        _tipC.animateTo(1, duration: KuberMotion.fxFast, curve: KuberMotion.curveEffects);
      case MotionLevel.expressive:
        _tipC.value = 0;
        _tipC.springTo(1, KuberMotion.springFast);
    }
  }

  void _closeTip() {
    if (_level == MotionLevel.off) {
      _tipC.value = 0;
    } else {
      _tipC.stop();
      _tipC.animateTo(0, duration: KuberMotion.fxInstant, curve: KuberMotion.curveEffects);
    }
  }

  void _syncOverlay() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncOverlay();
      });
      return;
    }
    final show = _selKey != null || _tipC.value > 0.01;
    if (show && !_ovl.isShowing) {
      _ovl.show();
    } else if (!show && _ovl.isShowing) {
      _ovl.hide();
    }
  }

  void _selectColumn(int? t, {required bool toggle, bool haptic = false}) {
    if (t == null) return;
    final p = t - _skeletons;
    if (p < 0 || p >= widget.periods.length) return;
    final key = widget.periods[p].key;
    if (toggle && key == _selKey) {
      _setSel(null);
    } else if (key != _selKey) {
      _setSel(key);
      if (haptic) KuberHaptics.tick();
    }
  }

  ChartGeometry _geo() => ChartGeometry(
        plotWidth: _plotW,
        total: _skeletons + widget.periods.length,
        win: _winC.value,
        pixels: pixels,
        windowTarget: widget.window,
      );

  // ---- scroll ---------------------------------------------------------------

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    final px = pos.pixels;
    final slot = _plotW / widget.window;
    // Edge tick: once when an end is hit, re-armed a slot away.
    final atEdge = px <= pos.minScrollExtent + 0.01 || px >= pos.maxScrollExtent - 0.01;
    if (atEdge && _edgeArmed && pos.maxScrollExtent > 0) {
      _edgeArmed = false;
      _edgePx = px;
      _edgeTick();
    } else if (!_edgeArmed && slot > 0 && (px - _edgePx).abs() >= slot) {
      _edgeArmed = true;
    }
    // Older page.
    if (widget.hasMoreOlder &&
        !widget.loadingOlder &&
        _requestedAt != widget.periods.length &&
        px >= pos.maxScrollExtent - 2 * slot) {
      _requestedAt = widget.periods.length;
      widget.onLoadOlder?.call();
    }
    // The selected column scrolled out of view: close.
    final sp = _selIdxCache;
    if (sp != null && _plotW > 0) {
      final cx = _geo().cx(sp + _skeletons);
      if (cx < 0 || cx > _plotW) _setSel(null);
    }
  }

  void _edgeTick() {
    // The app-wide scroll listener mutes haptics while scrolling; the edge
    // tick is the one allowed exception.
    final was = KuberHaptics.scrolling;
    KuberHaptics.scrolling = false;
    KuberHaptics.tick();
    KuberHaptics.scrolling = was;
  }

  bool _onNotification(ScrollNotification n) {
    if (n is OverscrollNotification && _level == MotionLevel.off && _edgeArmed) {
      _edgeArmed = false;
      _edgePx = _scroll.hasClients ? _scroll.position.pixels : 0;
      _edgeTick();
    } else if (n is ScrollEndNotification) {
      final px = pixels;
      // Only TalkBack reads the per-column nodes; skip the rebuild otherwise.
      if ((px - _semPx).abs() > 0.5 && SemanticsBinding.instance.semanticsEnabled) {
        setState(() => _semPx = px);
      }
    }
    return false;
  }

  // ---- build ------------------------------------------------------------------

  String _a11yLabel(int p) {
    final l10n = context.l10n;
    final period = widget.periods[p];
    final f = widget.formatAmount;
    if (period.noData) return l10n.chartA11yNoData(period.fullLabel);
    if (widget.series.length == 2) {
      final net = period.values[0] - period.values[1];
      return l10n.chartA11yColumn(
        period.fullLabel,
        f(period.values[0]),
        f(period.values[1]),
        (net >= 0 ? l10n.chartTipSaved : l10n.chartTipOverspent).toLowerCase(),
        f(net.abs()),
      );
    }
    return l10n.chartA11yOne(period.fullLabel, widget.series[0].name, f(period.values[0]));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    final scale = scaler.scale(14) / 14;
    final big = scale >= ExpressiveChartMetrics.largeFontScale;
    final axisW = big ? ExpressiveChartMetrics.axisWidthLarge : ExpressiveChartMetrics.axisWidth;
    final ls = theme.textTheme.labelSmall!;
    final labelH = 16 + (ls.fontSize ?? 11) * scale * (ls.height ?? 1.3);
    final chartH = ExpressiveChartMetrics.topPad + ExpressiveChartMetrics.plotHeight + labelH;
    final sk = _skeletons;
    final n = widget.periods.length;

    return LayoutBuilder(builder: (context, cons) {
      final w = cons.maxWidth;
      final plotW = math.max(0.0, w - axisW);
      _plotW = plotW;
      final slotT = plotW / widget.window;
      final frame = ChartFrame(
        periods: widget.periods,
        series: widget.series,
        from: _from,
        to: _to,
        skeletons: sk,
        window: widget.window,
        level: _level,
        axisWidth: axisW,
        labelHeight: labelH,
        cs: cs,
        gridline: context.kuberChart.gridline,
        surface: widget.surface ?? cs.surfaceContainer,
        labelStyle: ls,
        textScaler: scaler,
        texts: _texts,
        formatAxis: widget.formatAxis,
        firstLetters: widget.window > 7,
        labelEvery: big && widget.window > 7 ? 2 : 1,
        semanticsLabel: _a11yLabel,
        onSemanticsTap: (p) => _selectColumn(p + sk, toggle: false),
        semanticsPixels: _semPx,
        dark: cs.brightness == Brightness.dark,
        skeletonShimmer: _shimmerOn,
        textDirection: Directionality.of(context),
      );
      // Everything fits (e.g. Home's exact 7D / 6M / 1Y): nothing to scroll,
      // so no rubber band either. Long-press drag still selects.
      final ScrollPhysics physics = sk + n <= widget.window
          ? const NeverScrollableScrollPhysics()
          : ChartScrollPhysics(slot: slotT, level: _level);
      final scrollArea = ScrollConfiguration(
        behavior: ScrollConfiguration.of(context)
            .copyWith(overscroll: false, scrollbars: false),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: SingleChildScrollView(
            key: kExpressiveChartScrollKey,
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: physics,
            child: SizedBox(
              width: math.max(plotW, (sk + n) * slotT),
              height: ExpressiveChartMetrics.plotHeight + labelH,
            ),
          ),
        ),
      );

      return OverlayPortal(
        controller: _ovl,
        overlayChildBuilder: (ctx) => _buildTooltip(ctx, axisW, labelH, big),
        child: RepaintBoundary(
          child: CompositedTransformTarget(
            link: _link,
            child: TapRegion(
              onTapOutside: (_) {
                if (_selKey != null) _setSel(null);
              },
              child: SizedBox(
                key: _plotKey,
                width: w,
                height: chartH,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ChartPainter(frame: frame, live: this),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: ExpressiveChartMetrics.topPad,
                      width: plotW,
                      height: ExpressiveChartMetrics.plotHeight + labelH,
                      child: RawGestureDetector(
                        behavior: HitTestBehavior.translucent,
                        gestures: {
                          TapGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                            TapGestureRecognizer.new,
                            (r) => r.onTapUp = (d) =>
                                _selectColumn(_geo().columnAt(d.localPosition.dx), toggle: true),
                          ),
                          LongPressGestureRecognizer:
                              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                            () => LongPressGestureRecognizer(
                                duration: const Duration(milliseconds: 400)),
                            (r) => r
                              ..onLongPressStart = (d) {
                                final t = _geo().columnAt(d.localPosition.dx);
                                if (t != null && t - sk >= 0) {
                                  KuberHaptics.longPress();
                                  _selectColumn(t, toggle: false);
                                }
                              }
                              ..onLongPressMoveUpdate = (d) {
                                final x = d.localPosition.dx.clamp(0.0, plotW - 0.01);
                                _selectColumn(_geo().columnAt(x.toDouble()),
                                    toggle: false, haptic: true);
                              },
                          ),
                        },
                        child: scrollArea,
                      ),
                    ),
                    if (widget.state == ExpressiveChartState.data && n == 0 && widget.emptyTitle != null)
                      Positioned(
                        left: 0,
                        width: plotW,
                        top: ExpressiveChartMetrics.topPad + ExpressiveChartMetrics.plotHeight / 2 - 30,
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.emptyTitle!,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleSmall!.copyWith(color: cs.onSurface)),
                                if (widget.emptyBody != null)
                                  Text(widget.emptyBody!,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall!
                                          .copyWith(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.state == ExpressiveChartState.data && n == 1 && widget.singleNote != null)
                      Positioned(
                        left: 0,
                        width: plotW - slotT,
                        top: ExpressiveChartMetrics.topPad + ExpressiveChartMetrics.plotHeight / 2 - 24,
                        child: IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
                            child: Text(widget.singleNote!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall!
                                    .copyWith(color: cs.onSurfaceVariant)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---- tooltip ----------------------------------------------------------------

  Widget _buildTooltip(BuildContext ctx, double axisW, double labelH, bool big) {
    return ListenableBuilder(
      listenable: Listenable.merge([_scroll, _tipPosC, _tipC, _modeC, ?_page]),
      builder: (context, _) {
        final box = _plotKey.currentContext?.findRenderObject();
        final key = _tipKey;
        if (box is! RenderBox || !box.attached || key == null || _plotW <= 0) {
          return const SizedBox.shrink();
        }
        final p = widget.periods.indexWhere((e) => e.key == key);
        if (p < 0) return const SizedBox.shrink();
        final period = widget.periods[p];
        final geo = _geo();
        final cx = geo.cx(_skeletons) + _tipPosC.value * geo.slot;
        if (cx < 0 || cx > _plotW) return const SizedBox.shrink();
        final lineMode = _modeC.value > 0.5;
        final colW = ExpressiveChartMetrics.columnWidth(_winC.value);
        final top = ExpressiveChartMetrics.topPad +
            chartColumnTop(
              period: period,
              series: widget.series,
              yMax: _targetMax,
              lineMode: lineMode,
              colW: colW,
            );
        final labelsBottom = ExpressiveChartMetrics.topPad + ExpressiveChartMetrics.plotHeight + labelH;
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final tw = big ? 240.0 : 184.0;
        final rows = widget.series.length + (widget.series.length == 2 ? 1 : 0);
        final estH = (22 + 16 + 6 + rows * 20 + (widget.series.length == 2 ? 9 : 0)) * scale;
        final global = box.localToGlobal(Offset.zero);
        final page = Scrollable.maybeOf(context);
        var viewTop = 0.0;
        final pageBox = page?.context.findRenderObject();
        if (pageBox is RenderBox && pageBox.attached) viewTop = pageBox.localToGlobal(Offset.zero).dy;
        final pl = placeTooltip(
          cx: cx,
          columnTop: top,
          labelsBottom: labelsBottom,
          tip: Size(tw, estH),
          chartGlobal: global,
          screenWidth: MediaQuery.sizeOf(context).width,
          viewportTop: viewTop,
        );
        final v = _tipC.value;
        final expressive = _level == MotionLevel.expressive;
        final opacity = (expressive ? v * 2 : v).clamp(0.0, 1.0);
        final s = expressive ? 0.8 + 0.2 * v.clamp(0.0, 1.2) : 1.0;
        return CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.topLeft,
          child: IgnorePointer(
            child: CustomSingleChildLayout(
              delegate: _TipLayout(
                width: tw,
                left: pl.left,
                columnTop: top,
                labelsBottom: labelsBottom,
                flipped: pl.flipped,
              ),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: s,
                  alignment: Alignment((pl.pointerX / tw) * 2 - 1, pl.flipped ? -1 : 1),
                  child: ChartTooltipCard(
                    key: kExpressiveChartTooltipKey,
                    period: period,
                    series: widget.series,
                    width: tw,
                    pointerX: pl.pointerX,
                    flipped: pl.flipped,
                    formatAmount: widget.formatAmount,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TipLayout extends SingleChildLayoutDelegate {
  const _TipLayout({
    required this.width,
    required this.left,
    required this.columnTop,
    required this.labelsBottom,
    required this.flipped,
  });
  final double width, left, columnTop, labelsBottom;
  final bool flipped;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints c) =>
      BoxConstraints(minWidth: width, maxWidth: width, maxHeight: c.maxHeight);

  @override
  Offset getPositionForChild(Size size, Size child) => Offset(
        left,
        flipped
            ? labelsBottom + kTooltipFlipGap
            : columnTop - kTooltipGap - child.height,
      );

  @override
  bool shouldRelayout(_TipLayout o) =>
      o.width != width ||
      o.left != left ||
      o.columnTop != columnTop ||
      o.labelsBottom != labelsBottom ||
      o.flipped != flipped;
}
