import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../insights/models/insight.dart';
import '../../insights/providers/insight_provider.dart';

class HomeSmartInsights extends ConsumerStatefulWidget {
  const HomeSmartInsights({super.key});

  @override
  ConsumerState<HomeSmartInsights> createState() => _HomeSmartInsightsState();
}

class _HomeSmartInsightsState extends ConsumerState<HomeSmartInsights> {
  bool _showAllInsights = false;

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(smartInsightsProvider);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (insights.isEmpty) return const SizedBox.shrink();

    final visible = _showAllInsights ? insights : insights.take(3).toList();
    final hasMore = insights.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Smart Insights',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasMore)
                GestureDetector(
                  onTap: () => setState(() => _showAllInsights = !_showAllInsights),
                  child: Text(
                    _showAllInsights ? 'Show less' : 'Show more',
                    style: textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ...visible.map((insight) => _InsightTile(insight: insight)),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final KuberInsight insight;
  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final Color bgColor;
    final Color borderColor;

    if (insight.isPositive) {
      bgColor = cs.tertiary.withValues(alpha: 0.08);
      borderColor = cs.tertiary.withValues(alpha: 0.2);
    } else {
      bgColor = cs.error.withValues(alpha: 0.06);
      borderColor = cs.error.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Text(
            insight.emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight.message,
              style: textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
