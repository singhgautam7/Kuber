import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../models/chip_action.dart';

/// Horizontally-scrolling strip of follow-up chips that sits directly above the
/// input and reflects the latest Kuber response. Two variants: ask chips
/// (outlined, re-send a query) and navigate chips (filled primary with a
/// trailing arrow, go to a screen). Re-mount it (via a key) to replay the
/// 220ms entry animation on each new response.
class ChipStrip extends StatelessWidget {
  final List<ChipAction> actions;
  final void Function(String query) onAsk;
  final void Function(String route) onNavigate;

  const ChipStrip({
    super.key,
    required this.actions,
    required this.onAsk,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (actions.isEmpty) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 4), child: child),
      ),
      child: Container(
        color: cs.surface,
        padding: const EdgeInsets.only(top: KuberSpacing.sm),
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.9, 1.0],
            colors: [cs.surface, cs.surface, cs.surface.withValues(alpha: 0.0)],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: KuberSpacing.lg, right: 28),
            child: Row(
              children: [
                for (final action in actions) _chip(context, cs, action),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, ColorScheme cs, ChipAction action) {
    return switch (action) {
      AskChipAction(:final query) => _AskChip(
          label: query,
          onTap: () => onAsk(query),
          cs: cs,
        ),
      NavChipAction(:final label, :final route) => _NavChip(
          label: label,
          onTap: () => onNavigate(route),
          cs: cs,
        ),
    };
  }
}

class _AskChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _AskChip({required this.label, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.full),
          border: Border.all(color: cs.outline),
        ),
        child: Text(
          label,
          style: localeFont(
              fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _NavChip({required this.label, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.fromLTRB(12, 7, 9, 7),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(KuberRadius.full),
          border: Border.all(color: cs.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: localeFont(
                  fontSize: 13, fontWeight: FontWeight.w500, color: cs.onPrimary),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 13, color: cs.onPrimary),
          ],
        ),
      ),
    );
  }
}
