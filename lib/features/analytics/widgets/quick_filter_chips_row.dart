import '../../../shared/widgets/kuber_chips.dart';
import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/l10n_ext.dart';

import '../providers/analytics_provider.dart';

class QuickFilterChipsRow extends StatelessWidget {
  final FilterType selectedType;
  final ValueChanged<FilterType> onTypeSelected;

  const QuickFilterChipsRow({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = FilterType.values
        .where((t) => t != FilterType.custom)
        .toList();

    // Presets as wrapping filter chips (board 6, date range).
    return Wrap(
      spacing: KuberSpace.sm,
      runSpacing: KuberSpace.sm,
      children: [
        for (final type in types)
          KuberChip(
            label: sentenceCase(_typeLabel(context, type)),
            selected: selectedType == type,
            onTap: () => onTypeSelected(type),
          ),
      ],
    );
  }

  String _typeLabel(BuildContext context, FilterType t) {
    switch (t) {
      case FilterType.all:
        return context.l10n.filterAll;
      case FilterType.today:
        return context.l10n.filterToday;
      case FilterType.thisWeek:
        return context.l10n.filterThisWeek;
      case FilterType.lastWeek:
        return context.l10n.filterLastWeek;
      case FilterType.thisMonth:
        return context.l10n.filterThisMonth;
      case FilterType.lastMonth:
        return context.l10n.filterLastMonth;
      case FilterType.thisYear:
        return context.l10n.filterThisYear;
      case FilterType.custom:
        return context.l10n.filterCustom;
    }
  }
}
