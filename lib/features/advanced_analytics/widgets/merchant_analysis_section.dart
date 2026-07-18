import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
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

final merchantSortOptionProvider = StateProvider.autoDispose<MerchantSortOption>(
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
      rows.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case MerchantSortOption.nameZtoA:
      rows.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    case MerchantSortOption.txnsHighToLow:
      rows.sort((a, b) => b.count.compareTo(a.count));
  }
  return rows;
});

class MerchantAnalysisSection extends ConsumerWidget {
  final int displayedCount;

  const MerchantAnalysisSection({
    super.key,
    this.displayedCount = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(merchantAnalysisProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final cs = Theme.of(context).colorScheme;
    final sortOption = ref.watch(merchantSortOptionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: SectionDateRangePicker(
                section: AdvancedAnalyticsSection.merchants,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(
              child: MerchantSortPicker(
                selected: sortOption,
                onSelected: (opt) =>
                    ref.read(merchantSortOptionProvider.notifier).state = opt,
              ),
            ),
          ],
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

              // O(1) category-name lookups instead of a where() scan per row.
              final categoryNameById = {
                for (final c in categories) c.id: c.name,
              };
              String? catName(MerchantRow m) {
                if (m.categoryIds.isEmpty) return null;
                return categoryNameById[int.tryParse(m.categoryIds.first)];
              }

              final visibleMerchants = ref
                  .watch(_sortedMerchantsProvider)
                  .take(displayedCount)
                  .toList();

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
                    'ALL MERCHANTS (${data.merchantCount})',
                    style: localeFont(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.sm),
                  for (final m in visibleMerchants)
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
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _SortSheet(
          selected: selected,
          onSelected: onSelected,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.swap_vert_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final MerchantSortOption selected;
  final ValueChanged<MerchantSortOption> onSelected;

  const _SortSheet({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberBottomSheet(
      title: 'Sort merchants',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final opt in MerchantSortOption.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: opt == selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  opt.icon,
                  size: 20,
                  color: opt == selected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              title: Text(
                opt.label,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: opt == selected ? FontWeight.w700 : FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              trailing: opt == selected
                  ? Icon(Icons.check_circle_rounded, color: cs.primary)
                  : null,
              onTap: () {
                onSelected(opt);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
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
