import 'package:flutter/material.dart';
import 'package:kuber/shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/feature_gates/pro_gate.dart';

class DeeperInsightsTeaser extends ConsumerWidget {
  const DeeperInsightsTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Board 3.6: one-row grouped list, 40 primaryContainer tile, Pro pill.
    return KuberGroup(
      children: [
        KuberListRow(
          leading: const KuberIconTile(
            icon: Icons.insert_chart_outlined_rounded,
            tone: KuberTone.primary,
          ),
          title: 'View deeper insights',
          titleTrailing: const KuberPill(label: 'Pro'),
          subtitle:
              'Trends, patterns, forecast, financial health score, and more',
          subtitleLines: 2,
          trailing: const KuberChevron(),
          onTap: () {
            if (proGate(context, ref, showAdvancedAnalyticsGateSheet)) {
              context.push('/advanced-analytics');
            }
          },
        ),
      ],
    );
  }
}
