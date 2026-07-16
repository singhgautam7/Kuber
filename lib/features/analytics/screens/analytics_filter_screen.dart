import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/l10n_ext.dart';

import '../../../shared/widgets/kuber_date_range_selector.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../providers/analytics_provider.dart';

class AnalyticsFilterScreen extends ConsumerWidget {
  const AnalyticsFilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.read(analyticsFilterProvider);
    return KuberDateRangeSelector(
      primaryButtonLabel: context.l10n.applyFilter,
      initialType: filter.type,
      initialFrom: filter.from,
      initialTo: filter.to,
      onApply: (result) {
        // Preset ranges (this month, last year, ...) are Basic Analytics and
        // stay free. A custom date range is Advanced Analytics, so it is gated
        // for free users; the gate sheet uses the root navigator and so
        // survives this screen closing on apply.
        if (result.type == FilterType.custom &&
            !proGate(context, ref, showAdvancedAnalyticsGateSheet)) {
          return;
        }
        ref.read(analyticsFilterProvider.notifier).setFilter(
              result.type,
              from: result.from,
              to: result.to,
            );
      },
    );
  }
}
