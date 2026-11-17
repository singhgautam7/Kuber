import 'package:flutter/material.dart';

import '../../core/motion/motion_level.dart';
import '../../core/motion/spring_curve.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';

/// A currency amount with rolling digits (motion.md "Numbers").
///
/// - Expressive: each changed digit rolls 100 % up (value grew) or down in
///   300 ms on curve.effects, 20 ms apart from right to left; the width eases
///   on springStandard when the length changes; tabular figures. On first
///   appearance ([animateIn]) the digits roll in from the formatted zero.
/// - Subtle: the whole text cross-fades in fx.fast. Off: it swaps.
/// - Settled, it is one plain [Text]. Privacy mode ([isPrivate]) shows the
///   mask and never animates.
/// - [format] turns the value into the display string (pass your
///   `AppFormatter.formatCurrency` so grouping and symbol stay consistent).
///
/// [duration] and [curve] are kept for old callers and ignored. In the
/// Expressive rolling state [maxLines] / [overflow] do not apply: a too-wide
/// amount scales down instead (FittedBox) while it animates.
class AnimatedAmount extends StatefulWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final bool isPrivate;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Roll in from zero on first appearance (default). False starts at [value]
  /// and only animates when it changes later.
  final bool animateIn;

  const AnimatedAmount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.isPrivate = false,
    this.duration = const Duration(milliseconds: 650),
    this.curve = Curves.easeOutCubic,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.animateIn = true,
  });

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount> {
  late String _text; // what is shown (target of the current roll)
  String _from = '';
  bool _up = true;
  bool _rolling = false;
  int _gen = 0;
  bool _started = false;

  Text _plain(String t, [TextStyle? style]) => Text(t,
      style: style ?? widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow);

  @override
  void initState() {
    super.initState();
    _text = widget.format(widget.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.animateIn &&
        !widget.isPrivate &&
        KuberMotion.levelOf(context) == MotionLevel.expressive) {
      final zero = widget.format(0);
      if (zero != _text) {
        _from = zero;
        _rolling = true;
        _up = widget.value >= 0;
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedAmount old) {
    super.didUpdateWidget(old);
    final next = widget.format(widget.value);
    if (next == _text) return;
    _from = _text;
    _text = next;
    _up = widget.value >= old.value;
    _rolling = KuberMotion.levelOf(context) == MotionLevel.expressive &&
        !widget.isPrivate;
    _gen++;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPrivate) {
      return _plain(maskAmount(_text, true));
    }
    final level = KuberMotion.levelOf(context);
    if (level == MotionLevel.expressive && _rolling) {
      final base = (widget.style ?? DefaultTextStyle.of(context).style)
          .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
      final align = switch (widget.textAlign) {
        TextAlign.right || TextAlign.end => Alignment.centerRight,
        TextAlign.center => Alignment.center,
        _ => Alignment.centerLeft,
      };
      return RepaintBoundary(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: align,
          child: RollingText(
            key: ValueKey(_gen),
            from: _from,
            to: _text,
            up: _up,
            style: base,
            onDone: () {
              if (mounted) setState(() => _rolling = false);
            },
          ),
        ),
      );
    }
    if (level == MotionLevel.subtle) {
      return AnimatedSwitcher(
        duration: KuberMotion.fxFast,
        switchInCurve: KuberMotion.curveEffects,
        switchOutCurve: KuberMotion.curveEffects,
        layoutBuilder: (cur, prev) => Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [...prev, ?cur],
        ),
        child: KeyedSubtree(key: ValueKey(_text), child: _plain(_text)),
      );
    }
    return _plain(_text);
  }
}

/// Rolls [from] into [to]: aligned from the right, each changed character
/// slides out (up if [up]) while the new one slides in, 300 ms on
/// curve.effects, 20 ms apart right to left. Lengths differ: the extra
/// characters grow or shrink in width on springStandard. Calls [onDone] when
/// everything has settled. Use through [AnimatedAmount].
class RollingText extends StatefulWidget {
  const RollingText({
    super.key,
    required this.from,
    required this.to,
    required this.up,
    required this.style,
    this.onDone,
  });

  final String from, to;
  final bool up;
  final TextStyle style;
  final VoidCallback? onDone;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText>
    with TickerProviderStateMixin {
  late final AnimationController _roll;
  late final AnimationController _w = AnimationController.unbounded(vsync: this);
  late final List<(String?, String?)> _pairs; // left to right
  late final bool _widthChanges;
  bool _measured = false;
  List<double> _w0 = const [], _w1 = const [];

  @override
  void initState() {
    super.initState();
    final a = widget.from.characters.toList();
    final b = widget.to.characters.toList();
    final n = a.length > b.length ? a.length : b.length;
    final pairs = <(String?, String?)>[];
    var changed = 0;
    for (var j = n - 1; j >= 0; j--) {
      final o = j < a.length ? a[a.length - 1 - j] : null;
      final c = j < b.length ? b[b.length - 1 - j] : null;
      pairs.add((o, c));
      if (o != c) changed++;
    }
    _pairs = pairs;
    _widthChanges = a.length != b.length;
    final total = KuberMotion.digitRoll +
        const Duration(milliseconds: 20) * (changed > 0 ? changed - 1 : 0);
    _roll = AnimationController(vsync: this, duration: total);
    _roll.addStatusListener((s) {
      if (s == AnimationStatus.completed && !_w.isAnimating) widget.onDone?.call();
    });
    _w.value = 0;
    _roll.forward();
    if (_widthChanges) {
      _w.springTo(1, KuberMotion.springStandard).whenCompleteOrCancel(() {
        if (_roll.isCompleted) widget.onDone?.call();
      });
    }
  }

  @override
  void dispose() {
    _roll.dispose();
    _w.dispose();
    super.dispose();
  }

  double _measure(String? ch) {
    if (ch == null) return 0;
    final p = TextPainter(
      text: TextSpan(text: ch, style: widget.style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = p.width;
    p.dispose();
    return w;
  }

  @override
  Widget build(BuildContext context) {
    if (!_measured) {
      _measured = true;
      _w0 = [for (final p in _pairs) _measure(p.$1)];
      _w1 = [for (final p in _pairs) _measure(p.$2)];
    }
    final total = _roll.duration!.inMicroseconds;
    return AnimatedBuilder(
      animation: Listenable.merge([_roll, _w]),
      builder: (context, _) {
        final children = <Widget>[];
        var rank = 0; // changed chars counted from the right
        final ranks = List<int>.filled(_pairs.length, 0);
        for (var i = _pairs.length - 1; i >= 0; i--) {
          if (_pairs[i].$1 != _pairs[i].$2) ranks[i] = rank++;
        }
        for (var i = 0; i < _pairs.length; i++) {
          final (o, c) = _pairs[i];
          final delay = const Duration(milliseconds: 20).inMicroseconds * ranks[i];
          final r = KuberMotion.curveEffects.transform(
              ((_roll.value * total - delay) / KuberMotion.digitRoll.inMicroseconds)
                  .clamp(0.0, 1.0));
          final width = o == c
              ? _w1[i]
              : _w0[i] + (_w1[i] - _w0[i]) * _w.value.clamp(0.0, 1.0);
          children.add(_Slot(
            width: width,
            from: o,
            to: c,
            t: r,
            up: widget.up,
            style: widget.style,
          ));
        }
        return Row(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.width,
    required this.from,
    required this.to,
    required this.t,
    required this.up,
    required this.style,
  });

  final double width;
  final String? from, to;
  final double t;
  final bool up;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (from == to) return Text(to ?? '', style: style);
    final dir = up ? 1.0 : -1.0;
    // Size follows the taller of the two; each glyph moves +-100 % of it.
    return SizedBox(
      width: width,
      child: ClipRect(
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            // Reserves the line height.
            Opacity(opacity: 0, child: Text(to ?? from ?? '', style: style)),
            if (from != null)
              Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(0, -dir * t),
                  child: Opacity(
                    opacity: 1 - t,
                    child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(from!, style: style, softWrap: false)),
                  ),
                ),
              ),
            if (to != null)
              Positioned.fill(
                child: FractionalTranslation(
                  translation: Offset(0, dir * (1 - t)),
                  child: Opacity(
                    opacity: t,
                    child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(to!, style: style, softWrap: false)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
