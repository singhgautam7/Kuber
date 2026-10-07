import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';

import '../../../core/theme/app_theme.dart';

class SelectorTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final Color iconColor;
  final VoidCallback onTap;

  /// Nothing picked yet: neutral tile, value in onSurfaceVariant.
  final bool isPlaceholder;

  /// Validation error: 1dp error outline and an error label.
  final bool hasError;

  const SelectorTile({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.onTap,
    this.isPlaceholder = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final tones = categoryTones(context, iconColor);

    // Board 3.4: card r20 pad 12, bodySmall label, 36 tile + titleMedium.
    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: hasError ? cs.error : cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sentenceCase(label),
                style: textTheme.bodySmall?.copyWith(
                  color: hasError ? cs.error : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KuberSpace.sm),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPlaceholder
                          ? cs.surfaceContainerHigh
                          : tones.container,
                      borderRadius: KuberShape.mediumR,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isPlaceholder ? cs.onSurfaceVariant : tones.fg,
                    ),
                  ),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      style: textTheme.titleMedium?.copyWith(
                        color: isPlaceholder
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
