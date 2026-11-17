import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_shape_loader.dart';


enum AppButtonType {
  primary, // filled (primary / onPrimary)
  normal, // tonal (secondaryContainer)
  outline, // outlined (1dp outlineVariant)
  danger, // danger tonal (errorContainer); `filled` = solid error
  dotted, // dashed outline, low emphasis
}

/// The one button (components/controls.md, board 2i): stadium, 40 high
/// (padding 16, labelLarge) or 56 high (padding 24, titleMedium), icon 20 with
/// an 8 gap. Disabled = onSurface 12% / 38%.
///
/// Pill structure (Material + InkWell + StadiumBorder) adapted from Mull
/// `shared/widgets/app_button.dart`; the public API is unchanged.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool iconAfterLabel;
  final bool fullWidth;
  final double? width;

  /// Snaps to the two spec sizes: >= 48 renders 56, below that 40.
  final double height;
  final bool isLoading;

  /// Overrides the side padding (24 for 56 buttons, 16 otherwise).
  final double? horizontalPadding;

  /// For [AppButtonType.danger] only: a solid error fill (high-stakes
  /// confirms) instead of the default danger-tonal container.
  final bool filled;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.normal,
    this.icon,
    this.iconAfterLabel = false,
    this.horizontalPadding,
    this.fullWidth = false,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final large = height >= 48;
    final h = large ? 56.0 : 40.0;
    final disabled = onPressed == null || isLoading;

    var (Color bg, Color fg, BorderSide side) = switch (type) {
      AppButtonType.primary => (cs.primary, cs.onPrimary, BorderSide.none),
      AppButtonType.normal =>
        (cs.secondaryContainer, cs.onSecondaryContainer, BorderSide.none),
      AppButtonType.outline => (
          Colors.transparent,
          cs.onSurface,
          BorderSide(color: cs.outlineVariant)
        ),
      AppButtonType.danger => filled
          ? (cs.error, cs.onError, BorderSide.none)
          : (cs.errorContainer, cs.onErrorContainer, BorderSide.none),
      AppButtonType.dotted =>
        (Colors.transparent, cs.onSurfaceVariant, BorderSide.none),
    };
    if (disabled && !isLoading) {
      bg = type == AppButtonType.outline || type == AppButtonType.dotted
          ? Colors.transparent
          : cs.onSurface.withValues(alpha: 0.12);
      fg = cs.onSurface.withValues(alpha: 0.38);
      if (type == AppButtonType.outline) {
        side = BorderSide(color: cs.onSurface.withValues(alpha: 0.12));
      }
    }

    final textStyle =
        (large ? theme.textTheme.titleMedium : theme.textTheme.labelLarge)!
            .copyWith(color: fg);
    final iconWidget = Icon(icon, size: 20, color: fg);

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: KuberShapeLoader(size: 20, color: fg),
          )
        else if (icon != null && !iconAfterLabel) ...[
          iconWidget,
          const SizedBox(width: 8),
        ],
        if (isLoading) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (!isLoading && icon != null && iconAfterLabel) ...[
          const SizedBox(width: 8),
          iconWidget,
        ],
      ],
    );

    final level = KuberMotion.levelOf(context);
    final fade = level == MotionLevel.off ? KuberMotion.fxInstant : KuberMotion.fxFast;
    final hPad = horizontalPadding ??
        (large && (width == null || width! >= 120) ? 24 : 16);

    // Pill today: Pressable morphs the corners pill -> 8 dp (h40) / 12 dp
    // (h56) on springFast; Material's own shape tween is off so the spring
    // drives it frame by frame.
    Widget button = Pressable(
      kind: PressKind.button,
      enabled: !disabled,
      restRadius: h / 2,
      pressedRadius: large ? 12 : 8,
      builder: (context, radius, _) {
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: side,
        );
        Widget b = ConstrainedBox(
          constraints: BoxConstraints(minHeight: h),
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: bg),
            duration: fade,
            curve: KuberMotion.curveEffects,
            builder: (context, color, child) => Material(
              color: color,
              animationDuration: Duration.zero,
              shape: shape,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: disabled ? null : onPressed,
                // 24 side padding for 56 buttons, unless a caller fixed a
                // narrow width (Quick Add Cancel is 100, Ask Kuber preview 96).
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: child,
                ),
              ),
            ),
            child: Center(widthFactor: 1, heightFactor: 1, child: content),
          ),
        );
        if (type == AppButtonType.dotted) {
          b = CustomPaint(
            foregroundPainter:
                _DashedBorderPainter(color: cs.outline, radius: radius),
            child: b,
          );
        }
        return b;
      },
    );

    return Semantics(
      button: true,
      enabled: !disabled,
      child: SizedBox(
        width: fullWidth ? double.infinity : width,
        height: h,
        child: button,
      ),
    );
  }
}

/// Paints a dashed stadium border, used by [AppButtonType.dotted].
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius.clamp(0.0, size.height / 2)),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color || old.radius != radius;
}
