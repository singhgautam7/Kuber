import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../insights/models/insight.dart';
import '../../insights/providers/insight_provider.dart';

class SmartInsightsCard extends ConsumerStatefulWidget {
  const SmartInsightsCard({super.key});

  @override
  ConsumerState<SmartInsightsCard> createState() => _SmartInsightsCardState();
}

class _SmartInsightsCardState extends ConsumerState<SmartInsightsCard> {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Insights',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
        const SizedBox(height: KuberSpacing.sm),
        Column(
          children: visible
              .map((insight) => _InsightTile(insight: insight))
              .toList(),
        ),
        const SizedBox(height: KuberSpacing.md),
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
      margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Text(
            insight.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              insight.message,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
