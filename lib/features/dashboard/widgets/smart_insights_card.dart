import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../insights/providers/insight_provider.dart';
import '../../insights/models/insight.dart';
import '../../../core/theme/app_theme.dart';

class SmartInsightsCard extends ConsumerWidget {
  const SmartInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(smartInsightsProvider);

    return insightsAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => const SizedBox.shrink(),
      data: (insights) {
        if (insights.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Smart Insights',
            //   style: textTheme.titleMedium?.copyWith(
            //     fontWeight: FontWeight.w700,
            //     letterSpacing: -0.3,
            //   ),
            // ),
            // const SizedBox(height: KuberSpacing.sm),
            Column(
              children: insights.map((insight) => _InsightTile(insight: insight)).toList(),
            ),
            const SizedBox(height: KuberSpacing.md),
          ],
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Smart Insights',
        //   style: textTheme.titleMedium?.copyWith(
        //     fontWeight: FontWeight.w700,
        //     letterSpacing: -0.3,
        //     color: cs.onSurface.withValues(alpha: 0.1),
        //   ),
        // ),
        // const SizedBox(height: KuberSpacing.sm),
        Shimmer.fromColors(
          baseColor: cs.surfaceContainerHigh,
          highlightColor: cs.surfaceContainerLowest,
          child: Column(
            children: List.generate(2, (i) => Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
            )),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
      ],
    );
  }
}

class _InsightTile extends StatelessWidget {
  final Insight insight;
  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (insight.type) {
      case InsightType.budget:
        bgColor = Colors.orange.withValues(alpha: 0.08); // Warning color
        iconColor = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;
      case InsightType.trend:
        bgColor = cs.primary.withValues(alpha: 0.08); // Accent color
        iconColor = cs.primary;
        icon = Icons.trending_up_rounded;
        break;
      case InsightType.behavior:
        bgColor = cs.secondary.withValues(alpha: 0.08); // Neutral/info color
        iconColor = cs.secondary;
        icon = Icons.lightbulb_outline_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              insight.message,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
