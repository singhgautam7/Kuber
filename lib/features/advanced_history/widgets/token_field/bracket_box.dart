import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../common/ah_motion.dart';
import 'token_chips.dart';

/// A shaded box around matched brackets (levels 1 to 3, tokens.md) or the
/// dashed box of the implied "and before or" grouping.
class BracketBox extends StatefulWidget {
  const BracketBox({
    super.key,
    required this.depth,
    required this.implicit,
    required this.animate,
    required this.filterCount,
    required this.children,
  });

  final int depth;
  final bool implicit;

  /// True when the box forms after the page is up (clip from the centre).
  final bool animate;
  final int filterCount;
  final List<Widget> children;

  @override
  State<BracketBox> createState() => _BracketBoxState();
}

class _BracketBoxState extends State<BracketBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late final AhSpringCurve _curve =
      AhSpringCurve(AhMotion.expressiveDefaultSpatial);

  @override
  void initState() {
    super.initState();
    _c.value = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.animate && _c.value == 1 && !_started) {
      _started = true;
      if (!AhMotion.reduced(context)) {
        _c.duration = _curve.settle;
        _c.value = 0;
        _c.forward();
      }
    }
  }

  bool _started = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final on = cs.onSecondaryContainer;
    final BoxDecoration? deco;
    final EdgeInsets pad;
    final double radius;
    if (widget.implicit) {
      deco = null;
      pad = const EdgeInsets.all(4);
      radius = KuberShape.medium;
    } else if (widget.depth <= 1) {
      deco = BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(KuberShape.medium),
      );
      pad = const EdgeInsets.all(4);
      radius = KuberShape.medium;
    } else {
      final l3 = widget.depth >= 3;
      radius = l3 ? 8 : 10;
      deco = BoxDecoration(
        color: on.withValues(alpha: l3 ? 0.15 : 0.09),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
            color: on.withValues(alpha: l3 ? 0.30 : 0.20), width: 1),
      );
      pad = const EdgeInsets.symmetric(vertical: 6, horizontal: 8);
    }
    Widget box = Container(
      padding: pad,
      decoration: deco,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widget.children,
      ),
    );
    if (widget.implicit) {
      box = CustomPaint(
        foregroundPainter: DashedBorderPainter(
          color: on.withValues(alpha: 0.45),
          radius: radius,
        ),
        child: box,
      );
    }
    return Semantics(
      container: true,
      label: context.l10n.ahfBoxSemantics(widget.filterCount),
      child: AnimatedBuilder(
        animation: _c,
        child: box,
        builder: (context, child) {
          final t = _c.value;
          if (t >= 1) return child!;
          final v = _curve.transform(t).clamp(0.0, 1.0);
          return Opacity(
            opacity: v,
            child: ClipRect(
              child: Align(widthFactor: v, heightFactor: 1, child: child),
            ),
          );
        },
      ),
    );
  }
}
