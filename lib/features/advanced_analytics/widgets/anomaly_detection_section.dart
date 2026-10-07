import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import 'analytics_common.dart';
import 'fixed_window_note.dart';

class AnomalyDetectionSection extends ConsumerWidget {
  const AnomalyDetectionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(anomalyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FixedWindowNote(
          message:
              'Anomaly detection always compares this calendar month with recent history.',
        ),
        const SizedBox(height: KuberSpace.lg),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load anomalies',
            description: '$error',
          ),
          data: (data) {
            if (data.items.isEmpty) {
              return const KuberEmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'No unusual patterns detected',
                description: 'Kuber will notify you when something changes.',
              );
            }
            // Board "Anomaly detection": one grouped list.
            return KuberGroup(
              children: [
                for (final item in data.items) _AnomalyCard(item: item),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AnomalyCard extends StatelessWidget {
  final AnomalyItem item;

  const _AnomalyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final positive = item.tone == 'positive';
    final icon = positive
        ? Icons.trending_down_rounded
        : item.title.contains('large')
        ? Icons.receipt_long_rounded
        : Icons.trending_up_rounded;

    final (bg, fg) = kuberToneColors(
      context,
      positive ? KuberTone.income : KuberTone.warning,
    );
    return KuberListRow(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: KuberShape.mediumR),
        child: Icon(icon, size: 20, color: fg),
      ),
      title: item.title,
      subtitle: item.description,
      subtitleLines: 2,
    );
  }
}
