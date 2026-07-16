import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../charts/widgets/income_expense_chart_controls.dart'
    show KuberSegmentedTabs;
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../providers/advanced_analytics_provider.dart';
import 'aa_bar_chart.dart';
import 'analytics_common.dart';

/// 'spending' or 'income'.
final trendsMetricProvider = StateProvider<String>((ref) => 'spending');

/// 0 = Percent, 1 = Amount for the "By category" value column.
final trendsCategoryValueModeProvider = StateProvider<int>((ref) => 0);

class TrendsOverTimeSection extends ConsumerWidget {
  const TrendsOverTimeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(trendsProvider);
    final metric = ref.watch(trendsMetricProvider);
    final formatter = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    final isIncome = metric == 'income';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MetricChips(),
        const SizedBox(height: KuberSpacing.md),
        result.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load year-over-year trends',
            description: '$error',
          ),
          data: (data) {
            if (data.monthsTracked < 12) {
              return KuberEmptyState(
                icon: Icons.insights_rounded,
                title: 'Come back after 12 months of data',
                description:
                    'Year over year needs a full year of history to compare. '
                    'You currently have ${data.monthsTracked} months tracked.',
              );
            }

            final currentVals = data.currentSeries
                .map((m) => isIncome ? m.income : m.expense)
                .toList();
            final prevVals = data.previousSeries
                .map((m) => isIncome ? m.income : m.expense)
                .toList();
            // Month name only (no year): this year vs last year, so "Jan" is
            // unambiguous.
            final labels = data.currentSeries
                .map((m) => DateFormat('MMM').format(m.month))
                .toList();
            final currentTotal =
                isIncome ? data.currentIncome : data.currentExpense;
            final prevTotal =
                isIncome ? data.previousIncome : data.previousExpense;
            final change = prevTotal <= 0
                ? 0.0
                : ((currentTotal - prevTotal) / prevTotal) * 100;
            // For income a rise is good (green); for spending a rise is bad.
            final changeGood = isIncome ? change >= 0 : change <= 0;

            final chartData = [
              for (var i = 0; i < labels.length; i++)
                AaBarDatum(
                  label: labels[i],
                  current: currentVals[i],
                  previous: i < prevVals.length ? prevVals[i] : null,
                ),
            ];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AaBarChart(
                  data: chartData,
                  currentLabel: 'This year',
                  previousLabel: 'Last year',
                ),
                const SizedBox(height: KuberSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: StatPill(
                        label: 'This year',
                        value: formatter.formatCompactCurrency(currentTotal),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: StatPill(
                        label: 'Last year',
                        value: formatter.formatCompactCurrency(prevTotal),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: StatPill(
                        label: 'Change',
                        value: aaPercent(change),
                        color: changeGood ? cs.tertiary : cs.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),
                _ByCategory(isIncome: isIncome),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ByCategory extends ConsumerWidget {
  final bool isIncome;

  const _ByCategory({required this.isIncome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final data = ref.watch(trendsProvider).valueOrNull;
    final valueMode = ref.watch(trendsCategoryValueModeProvider);
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    if (data == null) return const SizedBox.shrink();

    final rows = isIncome ? data.incomeCategoryChanges : data.categoryChanges;
    // Only show rows that resolve to a real category (drops uncategorised /
    // orphaned ids, which otherwise showed a confusing generic "Category" row).
    final resolved = [
      for (final r in rows)
        if (categories.any((c) => c.id == int.tryParse(r.id))) r,
    ];
    if (resolved.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BY CATEGORY',
              style: localeFont(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: cs.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            KuberSegmentedTabs(
              labels: const ['Percent', 'Amount'],
              selectedIndex: valueMode,
              onChanged: (i) =>
                  ref.read(trendsCategoryValueModeProvider.notifier).state = i,
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.sm),
        for (var i = 0; i < resolved.length; i++)
          _CategoryChangeRow(
            row: resolved[i],
            isIncome: isIncome,
            showAmount: valueMode == 1,
            isLast: i == resolved.length - 1,
          ),
      ],
    );
  }
}

class _MetricChips extends ConsumerWidget {
  const _MetricChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metric = ref.watch(trendsMetricProvider);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (final entry in const {
          'spending': 'Total Spending',
          'income': 'Total Income',
        }.entries) ...[
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(trendsMetricProvider.notifier).state = entry.key,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: metric == entry.key
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHigh,
                  border: Border.all(
                    color: metric == entry.key ? cs.primary : cs.outline,
                  ),
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Text(
                  entry.value,
                  style: localeFont(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: metric == entry.key
                        ? cs.primary
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          if (entry.key == 'spending') const SizedBox(width: KuberSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryChangeRow extends ConsumerWidget {
  final dynamic row;
  final bool isIncome;
  final bool showAmount;
  final bool isLast;

  const _CategoryChangeRow({
    required this.row,
    required this.isIncome,
    required this.showAmount,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final id = int.tryParse(row.id as String);
    final matches = categories.where((c) => c.id == id);
    if (matches.isEmpty) return const SizedBox.shrink();
    final category = matches.first;

    final percent = row.percent as double;
    final delta = row.delta as double;
    final rose = delta > 0;
    // A rise in income is good (green); a rise in spending is bad (red).
    final good = isIncome ? rose : !rose;
    final color = good ? cs.tertiary : cs.error;
    final valueText = showAmount
        ? '${delta >= 0 ? '+' : ''}${aaMoney(delta)}'
        : '${percent > 0 ? '+' : ''}${percent.toStringAsFixed(0)}%';
    final caption =
        '${isIncome ? 'Income' : 'Spending'} ${rose ? 'increased' : 'decreased'} by';
    final catColor = Color(category.colorValue);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.sm),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.sm),
            ),
            child: Icon(
              IconMapper.fromString(category.icon),
              size: 16,
              color: catColor,
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                caption,
                style: localeFont(fontSize: 9, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 1),
              Text(
                valueText,
                style: localeFont(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Category chooser used across Advanced Analytics: a tappable chip that opens
/// the same [CategoryPickerSheet] as Add Transaction (search, grouped grid,
/// icons and colors), instead of a Material dropdown.
class AaCategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const AaCategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIntId = int.tryParse(selectedId ?? '');
    final matches = categories.where((c) => c.id == selectedIntId);
    final selectedCat = matches.isEmpty ? null : matches.first;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: cs.surfaceContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(KuberRadius.lg),
            ),
          ),
          builder: (_) => CategoryPickerSheet(
            selectedCategoryId: selectedIntId,
            onSelected: (id) {
              onSelected(id.toString());
              Navigator.pop(context);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            if (selectedCat != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(selectedCat.colorValue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
                child: Icon(
                  IconMapper.fromString(selectedCat.icon),
                  size: 16,
                  color: Color(selectedCat.colorValue),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: Text(
                  selectedCat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Select a category',
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
