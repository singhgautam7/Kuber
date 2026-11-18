import 'package:flutter/material.dart';
import 'package:kuber/core/theme/app_theme.dart';

import '../../../shared/widgets/kuber_segmented_control.dart';

/// In-card segmented control (Category | Group, Expense | Income): the M3
/// segmented button (h40, stadium, secondaryContainer).
class KuberSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showCheck;

  const KuberSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.showCheck = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: KuberSegmentedControl<int>(
        values: [for (var i = 0; i < labels.length; i++) i],
        labels: labels,
        selected: selectedIndex,
        onSelected: onChanged,
        height: 40,
        showCheck: showCheck,
        compact: true,
      ),
    );
  }
}

/// Selection highlight behind a chart group: a rounded column in onSurface at
/// 5% (light) / 8% (dark). Still used by Custom dashboards' charts.
Color chartSelectionColumn(ColorScheme cs) => cs.onSurface.withValues(
  alpha: cs.brightness == Brightness.dark ? 0.08 : 0.05,
);

const double kChartSelectionRadius = KuberShape.medium;
