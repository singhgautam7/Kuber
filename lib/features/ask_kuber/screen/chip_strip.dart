import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
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
  final void Function(String subject, String body) onEmail;

  const ChipStrip({
    super.key,
    required this.actions,
    required this.onAsk,
    required this.onNavigate,
    required this.onEmail,
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
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 4),
          child: child,
        ),
      ),
      child: Container(
        color: cs.surface,
        padding: const EdgeInsets.only(top: KuberSpace.sm),
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
            padding: const EdgeInsets.only(left: KuberSpace.lg, right: 28),
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
      NavChipAction(:final label, :final route) => _FilledChip(
        label: label,
        icon: Icons.arrow_forward_rounded,
        onTap: () => onNavigate(route),
        cs: cs,
      ),
      EmailChipAction(:final label, :final subject, :final body) => _FilledChip(
        label: label,
        icon: Icons.mail_outline_rounded,
        iconLeading: true,
        onTap: () => onEmail(subject, body),
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        // M3 suggestion chip (board 3.8b): r8, outline.
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.mediumR,
          side: BorderSide(color: cs.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: cs.primary.withValues(alpha: 0.12),
          highlightColor: cs.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filled primary pill with an icon. Used for navigate chips (trailing arrow)
/// and email chips (leading envelope) — same treatment, differing only in which
/// side the icon sits.
class _FilledChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconLeading;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _FilledChip({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.cs,
    this.iconLeading = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.labelLarge!.copyWith(color: cs.onPrimary),
    );
    final iconWidget = Icon(icon, size: 16, color: cs.onPrimary);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: cs.primary,
        shape: const RoundedRectangleBorder(borderRadius: KuberShape.mediumR),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: cs.onPrimary.withValues(alpha: 0.18),
          highlightColor: cs.onPrimary.withValues(alpha: 0.10),
          child: Padding(
            padding: iconLeading
                ? const EdgeInsets.fromLTRB(8, 6, 12, 6)
                : const EdgeInsets.fromLTRB(12, 6, 8, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: iconLeading
                  ? [iconWidget, const SizedBox(width: 6), text]
                  : [text, const SizedBox(width: 6), iconWidget],
            ),
          ),
        ),
      ),
    );
  }
}
