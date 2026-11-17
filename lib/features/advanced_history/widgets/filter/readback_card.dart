import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';

/// Expanded state is remembered for the session (not across launches).
bool _readbackExpanded = false;

/// Collapsible "In plain words".
class ReadbackCard extends StatefulWidget {
  const ReadbackCard({super.key, required this.text});
  final String text;

  @override
  State<ReadbackCard> createState() => _ReadbackCardState();
}

class _ReadbackCardState extends State<ReadbackCard> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final reduced = KuberMotion.reduced(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "In plain words" toggle (design rbT): notes icon, labelLarge,
        // chevron, all onSurfaceVariant.
        InkWell(
          key: const ValueKey('ahf-readback-toggle'),
          borderRadius: KuberShape.fullR,
          onTap: () => setState(() => _readbackExpanded = !_readbackExpanded),
          child: Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notes_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(l.ahfPlainWords,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: _readbackExpanded ? 0.5 : 0,
                  duration: reduced ? KuberMotion.fxInstant : KuberMotion.fxFast,
                  child: Icon(Icons.expand_more_rounded,
                      size: 18, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: reduced ? KuberMotion.fxInstant : KuberMotion.defaultCurve.settle,
          curve: reduced ? Curves.linear : KuberMotion.defaultCurve.clamped,
          alignment: Alignment.topCenter,
          child: _readbackExpanded
              ? Container(
                  key: const ValueKey('ahf-readback-text'),
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(widget.text,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: cs.onSurface)),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
