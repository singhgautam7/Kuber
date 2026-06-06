import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import 'settings_widgets.dart' show SquircleIcon;

class SettingsChoice<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData icon;
  const SettingsChoice({
    required this.value,
    required this.label,
    required this.icon,
    this.subtitle,
  });
}

/// Bottom sheet for picking a single value from a short list.
/// Used by Theme, Bottom Navigation, Number Format, Horizontal Swipe.
class SettingsChoiceSheet<T> extends StatelessWidget {
  final String title;
  final String? subtitle; // uppercase eyebrow under the title
  final List<SettingsChoice<T>> choices;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const SettingsChoiceSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.choices,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return KuberBottomSheet(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: choices.map((c) {
          final cs = Theme.of(context).colorScheme;
          final isSel = c.value == selectedValue;
          return Padding(
            padding: const EdgeInsets.only(bottom: KuberSpacing.xs),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                onSelected(c.value);
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSel ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? cs.primary.withValues(alpha: 0.25) : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    SquircleIcon(
                      icon: c.icon,
                      color: isSel ? cs.primary : cs.onSurfaceVariant,
                      size: 18, padding: 8,
                    ),
                    const SizedBox(width: KuberSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.label,
                            style: localeFont(
                              fontSize: 14,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                              color: isSel ? cs.primary : cs.onSurface,
                            ),
                          ),
                          if (c.subtitle case final s?) ...[
                            const SizedBox(height: 2),
                            Text(
                              s,
                              style: localeFont(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSel)
                      Icon(Icons.check_circle_rounded, color: cs.primary, size: 22)
                    else
                      Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}