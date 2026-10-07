import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../categories/providers/category_provider.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import 'analytics_common.dart';

enum MerchantSortOption {
  amountHighToLow('Amount (High to Low)', Icons.arrow_downward_rounded),
  amountLowToHigh('Amount (Low to High)', Icons.arrow_upward_rounded),
  nameAtoZ('Name (A to Z)', Icons.sort_by_alpha_rounded),
  nameZtoA('Name (Z to A)', Icons.sort_by_alpha_rounded),
  txnsHighToLow('Transactions (High to Low)', Icons.repeat_rounded);

  final String label;
  final IconData icon;
  const MerchantSortOption(this.label, this.icon);
}

final merchantSortOptionProvider =
    StateProvider.autoDispose<MerchantSortOption>(
      (ref) => MerchantSortOption.amountHighToLow,
    );

/// Sorted view of the merchant rows, derived in a provider (performance.md
/// rule 2) so the pagination setState on scroll reuses the cached list
/// instead of copying and re-sorting every rebuild.
final _sortedMerchantsProvider = Provider.autoDispose<List<MerchantRow>>((ref) {
  final data = ref.watch(merchantAnalysisProvider).valueOrNull;
  if (data == null) return const [];
  final rows = List.of(data.topMerchants);
  switch (ref.watch(merchantSortOptionProvider)) {
    case MerchantSortOption.amountHighToLow:
      rows.sort((a, b) => b.total.compareTo(a.total));
    case MerchantSortOption.amountLowToHigh:
      rows.sort((a, b) => a.total.compareTo(b.total));
    case MerchantSortOption.nameAtoZ:
      rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case MerchantSortOption.nameZtoA:
      rows.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    case MerchantSortOption.txnsHighToLow:
      rows.sort((a, b) => b.count.compareTo(a.count));
  }
  return rows;
});

class MerchantAnalysisSection extends ConsumerWidget {
  final int displayedCount;

  const MerchantAnalysisSection({super.key, this.displayedCount = 10});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(merchantAnalysisProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final cs = Theme.of(context).colorScheme;
    final sortOption = ref.watch(merchantSortOptionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: KuberSpace.sm,
            children: [
              const SectionDateRangePicker(
                section: AdvancedAnalyticsSection.merchants,
              ),
              MerchantSortPicker(
                selected: sortOption,
                onSelected: (opt) =>
                    ref.read(merchantSortOptionProvider.notifier).state = opt,
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.lg),
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

            // O(1) category-name lookups instead of a where() scan per row.
            final categoryNameById = {for (final c in categories) c.id: c.name};
            String? catName(MerchantRow m) {
              if (m.categoryIds.isEmpty) return null;
              return categoryNameById[int.tryParse(m.categoryIds.first)];
            }

            final visibleMerchants = ref
                .watch(_sortedMerchantsProvider)
                .take(displayedCount)
                .toList();

            final top = visibleMerchants.fold<double>(
              0,
              (mx, m) => m.total > mx ? m.total : mx,
            );
            final tt = Theme.of(context).textTheme;
            Widget stat(String label, String value) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    value,
                    style: tt.titleMedium!.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Board "Merchant analysis": one stats card, then the list.
                KuberCard(
                  child: Row(
                    children: [
                      stat('Merchants', '${data.merchantCount}'),
                      stat('Total spend', aaMoney(data.totalSpend)),
                    ],
                  ),
                ),
                if (data.newMerchants.isNotEmpty) ...[
                  const SizedBox(height: KuberSpace.md),
                  _NewMerchantsBanner(merchants: data.newMerchants),
                ],
                const SizedBox(height: KuberSpace.sectionGap - 4),
                KuberSectionHeader(
                  title: 'All merchants',
                  trailing: Text(
                    '${data.merchantCount}',
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                KuberGroup(
                  children: [
                    for (final m in visibleMerchants)
                      _MerchantRow(
                        merchant: m,
                        category: catName(m),
                        share: data.totalSpend <= 0
                            ? 0
                            : (m.total / data.totalSpend) * 100,
                        barValue: top <= 0 ? 0 : m.total / top,
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class MerchantSortPicker extends StatelessWidget {
  final MerchantSortOption selected;
  final ValueChanged<MerchantSortOption> onSelected;

  const MerchantSortPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return KuberDropdownChip<MerchantSortOption>(
      value: selected,
      icon: Icons.swap_vert_rounded,
      options: [
        for (final o in MerchantSortOption.values)
          KuberDropdownOption(o, o.label, icon: o.icon),
      ],
      onChanged: onSelected,
    );
  }
}

/// Name + amount, "Category · N transactions" + share, and a bar scaled
/// to the top merchant in view.
class _MerchantRow extends StatelessWidget {
  final MerchantRow merchant;
  final String? category;
  final double share;
  final double barValue;

  const _MerchantRow({
    required this.merchant,
    required this.category,
    required this.share,
    required this.barValue,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rising = merchant.trendPercent > 0;
    return KuberListRow(
      title: merchant.name,
      subtitle: [
        ?category,
        '${merchant.count} transaction${merchant.count == 1 ? '' : 's'}',
      ].join(' · '),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            aaMoney(merchant.total),
            style: tt.titleMedium!.copyWith(color: cs.onSurface),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rising
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 14,
                color: rising
                    ? context.kuberMoney.expense
                    : context.kuberMoney.income,
              ),
              const SizedBox(width: 4),
              Text(
                '${share.toStringAsFixed(1)}%',
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
      below: Padding(
        padding: const EdgeInsets.only(top: KuberSpace.sm),
        child: KuberLinearProgress(value: barValue.clamp(0.0, 1.0), flat: true),
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
    final including = names.isEmpty ? '' : ', including ${names.join(' and ')}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Text.rich(
        TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: cs.onSecondaryContainer),
          children: [
            TextSpan(
              text:
                  '${merchants.length} new merchant${merchants.length == 1 ? '' : 's'}',
              style: localeFont(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: ' this month$including.'),
          ],
        ),
      ),
    );
  }
}
