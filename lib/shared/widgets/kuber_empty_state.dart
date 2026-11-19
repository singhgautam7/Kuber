import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

class KuberEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const KuberEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final level = KuberMotion.levelOf(context);
    // Runs once, on first build: tile scale 0.9 to 1 (springDefault) + fade,
    // text fades 40 ms later. Subtle: fades only. Off: none.
    Widget enter(
        {required Widget child, required bool tile, required bool scale}) {
      if (level == MotionLevel.off) return child;
      final spring = tile && scale;
      final delay = tile ? Duration.zero : const Duration(milliseconds: 40);
      final total = (spring ? KuberMotion.defaultCurve.settle : KuberMotion.fxFast) + delay;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: total,
        curve: spring
            ? KuberMotion.defaultCurve
            : Interval(delay.inMicroseconds / total.inMicroseconds, 1,
                curve: KuberMotion.curveEffects),
        child: child,
        builder: (context, t, child) => Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: spring
              ? Transform.scale(scale: 0.9 + 0.1 * t, child: child)
              : child,
        ),
      );
    }

    final expressive = level == MotionLevel.expressive;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            enter(
              tile: true,
              scale: expressive,
              child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: cs.onSecondaryContainer,
                size: 32,
              ),
            )),
            const SizedBox(height: KuberSpace.md),
            enter(
              tile: false,
              scale: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
            Text(
              title,
              style: localeFont(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpace.xs),
            Text(
              description,
              style: localeFont(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KuberSpace.md),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(
                  actionLabel!,
                  style: localeFont(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}