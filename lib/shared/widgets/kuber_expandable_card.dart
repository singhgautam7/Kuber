import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';

/// A bordered question and answer: collapsed by default, expands on tap
/// (height spring, 180 degree chevron).
class KuberExpandableCard extends StatefulWidget {
  final String title;
  final String body;
  const KuberExpandableCard({super.key, required this.title, required this.body});

  @override
  State<KuberExpandableCard> createState() => _KuberExpandableCardState();
}

class _KuberExpandableCardState extends State<KuberExpandableCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.lg, vertical: KuberSpace.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(widget.title,
                          style: theme.textTheme.titleSmall!
                              .copyWith(color: cs.onSurface)),
                    ),
                    ChevronTurn(
                      expanded: _open,
                      openDegrees: 180,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ExpandCollapse(
            expanded: _open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  KuberSpace.lg, 0, KuberSpace.lg, KuberSpace.lg),
              child: Text(widget.body,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: cs.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}
