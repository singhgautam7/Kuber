import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import 'advanced_analytics_charts.dart';
import 'analytics_common.dart';

class CashFlowSection extends ConsumerWidget {
  const CashFlowSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(monthlyLedgerProvider);
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionDateRangePicker(
          section: AdvancedAnalyticsSection.cashFlow,
        ),
        const SizedBox(height: KuberSpace.lg),
        async.when(
          loading: () => const AnalyticsSkeletonBlock(),
          error: (error, _) => KuberEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Could not load cash flow',
            description: '$error',
          ),
          data: (months) {
            if (months.isEmpty) {
              return const KuberEmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Not enough data',
                description:
                    'Track income and expenses to see your monthly ledger.',
              );
            }
            final income = months.fold<double>(0, (s, m) => s + m.income);
            final expense = months.fold<double>(0, (s, m) => s + m.expense);
            final net = income - expense;
            final savingsRate = income <= 0 ? 0.0 : (net / income) * 100;

            final bestIncome = months.reduce(
              (a, b) => b.income > a.income ? b : a,
            );
            final bestSavings = months.reduce(
              (a, b) => b.savingsRate > a.savingsRate ? b : a,
            );
            final highestExpense = months.reduce(
              (a, b) => b.expense > a.expense ? b : a,
            );
            String mon(MonthlyAggregate m) => DateFormat('MMM').format(m.month);

            Widget pair(Widget a, Widget b) => Row(
              children: [
                Expanded(child: a),
                const SizedBox(width: KuberSpace.sm),
                Expanded(child: b),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Board "Cash flow": status banner, 2x2 totals, the three
                // callouts, then the chart and the monthly ledger.
                _HealthBanner(months: months),
                const SizedBox(height: KuberSpace.md),
                pair(
                  StatPill(
                    label: 'Total income',
                    value: aaMoney(income),
                    color: context.kuberMoney.income,
                  ),
                  StatPill(
                    label: 'Total expense',
                    value: aaMoney(expense),
                    color: context.kuberMoney.expense,
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                pair(
                  StatPill(
                    label: 'Net position',
                    value: '${net >= 0 ? '+' : ''}${aaMoney(net)}',
                    color: net >= 0
                        ? context.kuberMoney.income
                        : context.kuberMoney.expense,
                  ),
                  StatPill(
                    label: 'Savings rate',
                    value: aaPercent(savingsRate),
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: KuberSpace.sm),
                Row(
                  children: [
                    Expanded(
                      child: _Callout(
                        label: 'Best income',
                        value: mon(bestIncome),
                        detail: aaMoney(bestIncome.income),
                      ),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: _Callout(
                        label: 'Best savings',
                        value: mon(bestSavings),
                        detail: aaPercent(bestSavings.savingsRate),
                      ),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: _Callout(
                        label: 'Highest expense',
                        value: mon(highestExpense),
                        detail: aaMoney(highestExpense.expense),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.sectionGap - 4),
                AnalyticsSectionCard(
                  title: 'Income and expense',
                  icon: Icons.ssid_chart_rounded,
                  child: CashFlowAreaChart(
                    incomes: months.map((m) => m.income).toList(),
                    expenses: months.map((m) => m.expense).toList(),
                    nets: months.map((m) => m.net).toList(),
                    labels: months.map((m) => m.label).toList(),
                  ),
                ),
                const KuberSectionHeader(title: 'Monthly ledger'),
                if (months.length <= 1)
                  const KuberEmptyState(
                    icon: Icons.table_rows_rounded,
                    title: 'Select a longer range to see a monthly ledger',
                    description:
                        'The ledger needs at least 2 months to compare.',
                  )
                else
                  _LedgerTable(months: months),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HealthBanner extends StatelessWidget {
  final List<MonthlyAggregate> months;

  const _HealthBanner({required this.months});

  @override
  Widget build(BuildContext context) {
    final negative = months.where((m) => m.net < 0).length;
    final (String label, KuberTone tone, IconData icon) = negative == 0
        ? (
            'Consistent positive cash flow',
            KuberTone.income,
            Icons.check_circle_rounded,
          )
        : negative > months.length / 2
        ? (
            "You've had months of negative cash flow",
            KuberTone.expense,
            Icons.error_rounded,
          )
        : ('Cash flow is variable', KuberTone.warning, Icons.info_rounded);
    final (bg, fg) = kuberToneColors(context, tone);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.lg,
        vertical: KuberSpace.md,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.mediumR),
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: KuberSpace.sm),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caps label, the month, and its figure under it, centred.
class _Callout extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const _Callout({
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.sm,
        vertical: KuberSpace.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: tt.labelSmall!.copyWith(
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: tt.titleMedium!.copyWith(color: cs.onSurface)),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              detail,
              maxLines: 1,
              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerTable extends StatefulWidget {
  final List<MonthlyAggregate> months;

  const _LedgerTable({required this.months});

  @override
  State<_LedgerTable> createState() => _LedgerTableState();
}

class _LedgerTableState extends State<_LedgerTable> {
  int _sortCol = 0;
  bool _asc = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final rows = [...widget.months];
    int cmp(MonthlyAggregate a, MonthlyAggregate b) {
      final r = switch (_sortCol) {
        1 => a.income.compareTo(b.income),
        2 => a.expense.compareTo(b.expense),
        3 => a.net.compareTo(b.net),
        4 => a.savingsRate.compareTo(b.savingsRate),
        5 => a.transactionCount.compareTo(b.transactionCount),
        _ => a.month.compareTo(b.month),
      };
      return _asc ? r : -r;
    }

    rows.sort(cmp);

    void onSort(int col) => setState(() {
      if (_sortCol == col) {
        _asc = !_asc;
      } else {
        _sortCol = col;
        _asc = false;
      }
    });

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: cs.onSurfaceVariant),
          dataTextStyle: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: cs.onSurface),
          dividerThickness: 0.5,
          sortColumnIndex: _sortCol,
          sortAscending: _asc,
          headingRowColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
          columnSpacing: 22,
          columns: [
            DataColumn(
              label: const Text('Month'),
              onSort: (_, __) => onSort(0),
            ),
            DataColumn(
              label: const Text('Income'),
              numeric: true,
              onSort: (_, __) => onSort(1),
            ),
            DataColumn(
              label: const Text('Expense'),
              numeric: true,
              onSort: (_, __) => onSort(2),
            ),
            DataColumn(
              label: const Text('Net'),
              numeric: true,
              onSort: (_, __) => onSort(3),
            ),
            DataColumn(
              label: const Text('Savings'),
              numeric: true,
              onSort: (_, __) => onSort(4),
            ),
            DataColumn(
              label: const Text('Count'),
              numeric: true,
              onSort: (_, __) => onSort(5),
            ),
          ],
          rows: [
            for (final m in rows)
              DataRow(
                cells: [
                  DataCell(Text(m.label)),
                  DataCell(_amt(aaMoney(m.income), context.kuberMoney.income)),
                  DataCell(
                    _amt(aaMoney(m.expense), context.kuberMoney.expense),
                  ),
                  DataCell(
                    _amt(
                      '${m.net >= 0 ? '+' : ''}${aaMoney(m.net)}',
                      m.net >= 0
                          ? context.kuberMoney.income
                          : context.kuberMoney.expense,
                    ),
                  ),
                  DataCell(Text(aaPercent(m.savingsRate))),
                  DataCell(Text('${m.transactionCount}')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _amt(String text, Color color) => Text(
    text,
    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
  );
}
