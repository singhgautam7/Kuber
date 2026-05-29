import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';

/// A currency amount that smoothly counts up to [value] on first appearance,
/// and tweens between values when [value] changes — a subtle premium touch for
/// focal numbers (net worth, monthly net).
///
/// - [format] turns the in-flight double into the display string (pass your
///   `AppFormatter.formatCurrency` so grouping/symbol stay consistent).
/// - Honours privacy mode: when [isPrivate] is true it shows the mask and does
///   not animate (nothing to reveal).
/// - Uses [TweenAnimationBuilder] (no controller to leak) and a
///   [RepaintBoundary] so the per-frame text repaint stays isolated.
class AnimatedAmount extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final bool isPrivate;
  final Duration duration;
  final Curve curve;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

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
  });

  @override
  Widget build(BuildContext context) {
    if (isPrivate) {
      return Text(
        maskAmount(format(value), true),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value),
        duration: duration,
        curve: curve,
        builder: (context, animatedValue, _) {
          return Text(
            format(animatedValue),
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        },
      ),
    );
  }
}
