import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A bordered question and answer: collapsed by default, expands on tap.
class KuberExpandableCard extends StatelessWidget {
  final String title;
  final String body;
  const KuberExpandableCard({super.key, required this.title, required this.body});

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
      child: Theme(
        // The border already separates it: no dividers of its own.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
          childrenPadding: const EdgeInsets.fromLTRB(
            KuberSpace.lg,
            0,
            KuberSpace.lg,
            KuberSpace.lg,
          ),
          expandedAlignment: Alignment.centerLeft,
          iconColor: cs.onSurfaceVariant,
          collapsedIconColor: cs.onSurfaceVariant,
          title: Text(title, style: theme.textTheme.titleSmall!.copyWith(color: cs.onSurface)),
          children: [
            Text(body, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
