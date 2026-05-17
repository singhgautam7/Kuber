import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/kuber_date_range_selector.dart';
import '../providers/analytics_provider.dart';

class AnalyticsFilterScreen extends ConsumerWidget {
  const AnalyticsFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.read(analyticsFilterProvider);
    return KuberDateRangeSelector(
      primaryButtonLabel: 'Apply Filter',
      initialType: filter.type,
      initialFrom: filter.from,
      initialTo: filter.to,
      onApply: (result) {
        ref.read(analyticsFilterProvider.notifier).setFilter(
              result.type,
              from: result.from,
              to: result.to,
            );
      },
    );
  }
}
