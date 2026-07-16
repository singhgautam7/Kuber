import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/date_range_picker.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../providers/analytics_provider.dart';

class TopFilterRow extends ConsumerWidget {
  const TopFilterRow({super.key});

  void _goToFilterScreen(BuildContext context) {
    context.push('/analytics/filter');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(analyticsFilterProvider);
    final isToday = filter.type == FilterType.today;

    return KeyedSubtree(
      key: TutorialStepKeys.analyticsFilterPill,
      child: KuberDateRangePicker(
        value: DateRangePickerValue(
          label: _typeLabel(context, filter.type),
          from: filter.from,
          to: filter.to,
        ),
        onTap: () => _goToFilterScreen(context),
        onReset: () => ref.read(analyticsFilterProvider.notifier).reset(),
        canReset: !isToday,
      ),
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
