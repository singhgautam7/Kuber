import 'package:flutter/material.dart';

import '../../core/motion/motion_level.dart';
import '../../core/motion/pressable.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

/// The card in the Motion sheet. It reacts to a tap with the press response
/// of [level] (null: the effective level): Expressive scales to .98 and the
/// corners go 20 to 12 dp, Subtle scales to .99, Off shows nothing.
/// [caption] sits under the card (copy: "Tap the card to feel this level").
class MotionPreviewCard extends StatelessWidget {
  const MotionPreviewCard({
    super.key,
    required this.title,
    required this.amount,
    required this.caption,
    this.level,
  });

  final String title;
  final String amount;
  final String caption;
  final MotionLevel? level;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget card = Pressable(
      kind: PressKind.card,
      morphCorners: true,
      restRadius: KuberShape.largeIncreased,
      pressedRadius: KuberShape.medium,
      builder: (context, radius, pressed) => DecoratedBox(
        decoration: BoxDecoration(
          color: Color.lerp(cs.surfaceContainerHigh, cs.surfaceContainerHighest,
              pressed.clamp(0.0, 1.0)),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                ),
                child: Icon(Icons.account_balance_rounded,
                    size: 22, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: localeFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface)),
                    Text(amount,
                        style: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()])),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
    if (level != null) {
      card = MotionScope(level: level!, systemOff: false, child: card);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          card,
          const SizedBox(height: 10),
          Text(caption,
              textAlign: TextAlign.center,
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
