import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../categories/providers/category_provider.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import 'analytics_common.dart';

class MerchantAnalysisSection extends ConsumerWidget {
  const MerchantAnalysisSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(merchantAnalysisProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SectionDateRangePicker(
            section: AdvancedAnalyticsSection.merchants,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load merchants',
            description: '$error',
          ),
          data: (data) {
            if (data.merchantCount < 3) {
              return const KuberEmptyState(
                icon: Icons.storefront_outlined,
                title: 'Not enough merchant history yet',
                description:
                    'Kuber needs a few merchants in this range to compare behavior.',
              );
            }

            String? catName(MerchantRow m) {
              if (m.categoryIds.isEmpty) return null;
              final id = int.tryParse(m.categoryIds.first);
              final match = categories.where((c) => c.id == id);
              return match.isEmpty ? null : match.first.name;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatPill(
                        label: 'Merchants',
                        value: '${data.merchantCount}',
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: StatPill(
                        label: 'Total spend',
                        value: aaMoney(data.totalSpend),
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                if (data.newMerchants.isNotEmpty) ...[
                  const SizedBox(height: KuberSpacing.md),
                  _NewMerchantsBanner(merchants: data.newMerchants),
                ],
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'TOP MERCHANTS',
                  style: localeFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),
                for (final m in data.topMerchants)
                  Padding(
                    padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                    child: _MerchantRow(
                      merchant: m,
                      category: catName(m),
                      share: data.totalSpend <= 0
                          ? 0
                          : (m.total / data.totalSpend) * 100,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MerchantRow extends StatelessWidget {
  final MerchantRow merchant;
  final String? category;
  final double share;

  const _MerchantRow({
    required this.merchant,
    required this.category,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rising = merchant.trendPercent > 0;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${merchant.count} transaction${merchant.count == 1 ? '' : 's'}'
                  '${category != null ? ' · $category' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 10.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Icon(
            rising ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: 16,
            color: rising ? cs.error : cs.tertiary,
          ),
          const SizedBox(width: KuberSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                aaMoney(merchant.total),
                style: localeFont(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              Text(
                '${share.toStringAsFixed(1)}%',
                style: localeFont(fontSize: 10, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewMerchantsBanner extends StatelessWidget {
  final List<MerchantRow> merchants;

  const _NewMerchantsBanner({required this.merchants});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final names = merchants.take(2).map((m) => m.name).toList();
    final including =
        names.isEmpty ? '' : ', including ${names.join(' and ')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Text.rich(
        TextSpan(
          style: localeFont(
            fontSize: 12,
            height: 1.4,
            color: cs.onSurface,
          ),
          children: [
            TextSpan(
              text:
                  '${merchants.length} new merchant${merchants.length == 1 ? '' : 's'}',
              style: localeFont(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: ' this month$including.'),
          ],
        ),
      ),
    );
  }
}
