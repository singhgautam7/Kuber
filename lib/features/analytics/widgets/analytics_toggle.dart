import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AnalyticsCardSmallTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const AnalyticsCardSmallTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberShape.medium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(labels.length, (i) {
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected ? cs.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(KuberShape.medium),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: localeFont(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
