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
        color: cs.surfaceContainer,
        shape: StadiumBorder(side: BorderSide(color: cs.outline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: cs.primary.withValues(alpha: 0.12),
          highlightColor: cs.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
            child: Text(
              label,
              style: localeFont(
                  fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
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
      style: localeFont(
          fontSize: 13, fontWeight: FontWeight.w500, color: cs.onPrimary),
    );
    final iconWidget = Icon(icon, size: 13, color: cs.onPrimary);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: cs.primary,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: cs.onPrimary.withValues(alpha: 0.18),
          highlightColor: cs.onPrimary.withValues(alpha: 0.10),
          child: Padding(
            padding: iconLeading
                ? const EdgeInsets.fromLTRB(9, 7, 12, 7)
                : const EdgeInsets.fromLTRB(12, 7, 9, 7),
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
