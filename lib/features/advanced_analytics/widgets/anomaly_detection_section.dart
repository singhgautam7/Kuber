import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
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
        const SizedBox(height: KuberSpacing.md),
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
            return Column(
              children: [
                for (final item in data.items) ...[
                  _AnomalyCard(item: item),
                  const SizedBox(height: KuberSpacing.sm),
                ],
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
    final cs = Theme.of(context).colorScheme;
    final positive = item.tone == 'positive';
    final accent = positive ? cs.tertiary : context.kuberColors.warning;
    final icon = positive
        ? Icons.trending_down_rounded
        : item.title.contains('large')
            ? Icons.receipt_long_rounded
            : Icons.trending_up_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(KuberRadius.sm),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: localeFont(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: localeFont(
                    fontSize: 12,
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
