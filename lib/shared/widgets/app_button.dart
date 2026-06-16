import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum AppButtonType {
  primary,   // accent fill (submit)
  normal,    // default neutral
  outline,   // bordered
  danger,    // red (delete)
  dotted,    // dashed neutral border (secondary, low-emphasis)
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool iconAfterLabel;
  final bool fullWidth;
  final double? width;
  final double height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.normal,
    this.icon,
    this.iconAfterLabel = false,
    this.fullWidth = false,
    this.width,
    this.height = 52,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Style configuration
    final Color backgroundColor;
    final Color foregroundColor;
    final BorderSide? borderSide;

    switch (type) {
      case AppButtonType.primary:
        backgroundColor = cs.primary;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case AppButtonType.normal:
        backgroundColor = cs.surfaceContainerHigh;
        foregroundColor = cs.onSurface;
        borderSide = BorderSide(color: cs.outline.withValues(alpha: 0.1));
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = cs.onSurface;
        borderSide = BorderSide(color: cs.outline);
        break;
      case AppButtonType.danger:
        backgroundColor = Colors.transparent;
        foregroundColor = cs.error;
        borderSide = BorderSide(color: cs.error.withValues(alpha: 0.5));
        break;
      case AppButtonType.dotted:
        // Solid border omitted here; a dashed border is painted below.
        backgroundColor = Colors.transparent;
        foregroundColor = cs.onSurface;
        borderSide = null;
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        side: borderSide ?? BorderSide.none,
      ),
      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.12),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.38),
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null && !iconAfterLabel) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: foregroundColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (!isLoading && icon != null && iconAfterLabel) ...[
          const SizedBox(width: 8),
          Icon(icon, size: 18),
        ],
      ],
    );

    final button = SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );

    if (type == AppButtonType.dotted) {
      return CustomPaint(
        foregroundPainter: _DashedBorderPainter(
          color: cs.outline,
          radius: KuberRadius.md,
        ),
        child: button,
      );
    }
    return button;
  }
}

/// Paints a dashed rounded-rectangle border, used by [AppButtonType.dotted].
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
      Radius.circular(radius),
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
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
