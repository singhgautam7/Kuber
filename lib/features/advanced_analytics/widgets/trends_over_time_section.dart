import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
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
    final isIncome = metric == 'income';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MetricChips(),
        const SizedBox(height: KuberSpace.md),
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
            final currentTotal = isIncome
                ? data.currentIncome
                : data.currentExpense;
            final prevTotal = isIncome
                ? data.previousIncome
                : data.previousExpense;
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
                const SizedBox(height: KuberSpace.md),
                // Board "Year over year": one card, three figures.
                KuberCard(
                  child: Row(
                    children: [
                      _Figure(
                        'This year',
                        formatter.formatCompactCurrency(currentTotal),
                      ),
                      _Figure(
                        'Last year',
                        formatter.formatCompactCurrency(prevTotal),
                      ),
                      _Figure(
                        'Change',
                        aaPercent(change),
                        color: changeGood
                            ? context.kuberMoney.income
                            : context.kuberMoney.expense,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.sectionGap - 4),
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
            Text('BY CATEGORY', style: sectionHeaderStyle(context)),
            const Spacer(),
            KuberSegmentedTabs(
              labels: const ['Percent', 'Amount'],
              selectedIndex: valueMode,
              onChanged: (i) =>
                  ref.read(trendsCategoryValueModeProvider.notifier).state = i,
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.sectionHeaderGap),
        KuberGroup(
          children: [
            for (final r in resolved)
              _CategoryChangeRow(
                row: r,
                isIncome: isIncome,
                showAmount: valueMode == 1,
              ),
          ],
        ),
      ],
    );
  }
}

class _MetricChips extends ConsumerWidget {
  const _MetricChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KuberSegmentedControl<String>(
      values: const ['spending', 'income'],
      labels: const ['Total spending', 'Total income'],
      selected: ref.watch(trendsMetricProvider),
      onSelected: (v) => ref.read(trendsMetricProvider.notifier).state = v,
    );
  }
}

/// Caption over a figure, one third of the stats card.
class _Figure extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Figure(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: tt.titleMedium!.copyWith(color: color ?? cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChangeRow extends StatelessWidget {
  final dynamic row;
  final bool isIncome;
  final bool showAmount;

  const _CategoryChangeRow({
    required this.row,
    required this.isIncome,
    required this.showAmount,
  });

  @override
  Widget build(BuildContext context) {
    final percent = row.percent as double;
    final delta = row.delta as double;
    final rose = delta > 0;
    // A rise in income is good (green); a rise in spending is bad (red).
    final good = isIncome ? rose : !rose;
    final color = good ? context.kuberMoney.income : context.kuberMoney.expense;
    final valueText = showAmount
        ? '${delta >= 0 ? '+' : ''}${aaMoney(delta)}'
        : '${percent > 0 ? '+' : ''}${percent.toStringAsFixed(0)}%';
    final caption =
        '${isIncome ? 'Income' : 'Spending'} ${rose ? 'increased' : 'decreased'}';

    return AnalyticsCategoryRow(
      categoryId: row.id as String,
      subtitle: caption,
      trailing: Text(
        valueText,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
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

    void open() => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KuberShape.extraLarge),
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

    // Board "Category deep-dive": a selected dropdown chip.
    return KuberChip(
      label: selectedCat?.name ?? 'Select a category',
      icon: selectedCat == null
          ? Icons.category_outlined
          : IconMapper.fromString(selectedCat.icon),
      selected: selectedCat != null,
      showCheck: false,
      dropdown: true,
      onTap: open,
    );
  }
}
