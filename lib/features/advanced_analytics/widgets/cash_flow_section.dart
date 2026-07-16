import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
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
        const SizedBox(height: KuberSpacing.md),
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CashFlowAreaChart(
                  incomes: months.map((m) => m.income).toList(),
                  expenses: months.map((m) => m.expense).toList(),
                  nets: months.map((m) => m.net).toList(),
                  labels: months.map((m) => m.label).toList(),
                ),
                const SizedBox(height: KuberSpacing.md),
                // 4 primary KPIs, 2 per row.
                Row(
                  children: [
                    Expanded(
                      child: StatPill(
                        label: 'Total income',
                        value: aaMoney(income),
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: StatPill(
                        label: 'Total expense',
                        value: aaMoney(expense),
                        color: cs.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: StatPill(
                        label: 'Net position',
                        value: aaMoney(net),
                        color: net >= 0 ? cs.onSurface : cs.error,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: StatPill(
                        label: 'Savings rate',
                        value: aaPercent(savingsRate),
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.md),
                _HealthBanner(months: months),
                const SizedBox(height: KuberSpacing.md),
                // 3 callouts.
                Row(
                  children: [
                    Expanded(
                      child: _Callout(
                        label: 'BEST INCOME',
                        value: '${mon(bestIncome)} · ${aaMoney(bestIncome.income)}',
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _Callout(
                        label: 'BEST SAVINGS',
                        value:
                            '${mon(bestSavings)} · ${aaPercent(bestSavings.savingsRate)}',
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _Callout(
                        label: 'HIGHEST EXPENSE',
                        value:
                            '${mon(highestExpense)} · ${aaMoney(highestExpense.expense)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'MONTHLY LEDGER',
                  style: localeFont(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),
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
    final cs = Theme.of(context).colorScheme;
    final negative = months.where((m) => m.net < 0).length;
    final (String label, Color color, IconData icon) = negative == 0
        ? ('Consistent positive cash flow', cs.tertiary, Icons.check_circle_rounded)
        : negative > months.length / 2
            ? (
                "You've had months of negative cash flow",
                cs.error,
                Icons.error_rounded
              )
            : ('Cash flow is variable', context.kuberColors.warning, Icons.info_rounded);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: localeFont(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  final String label;
  final String value;

  const _Callout({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: localeFont(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortCol,
        sortAscending: _asc,
        headingRowColor: WidgetStatePropertyAll(cs.surfaceContainerHigh),
        columnSpacing: 22,
        columns: [
          DataColumn(label: const Text('Month'), onSort: (_, __) => onSort(0)),
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
                DataCell(_amt(aaMoney(m.income), cs.tertiary)),
                DataCell(_amt(aaMoney(m.expense), cs.error)),
                DataCell(_amt(
                  '${m.net >= 0 ? '+' : ''}${aaMoney(m.net)}',
                  m.net >= 0 ? cs.tertiary : cs.error,
                )),
                DataCell(Text(aaPercent(m.savingsRate))),
                DataCell(Text('${m.transactionCount}')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _amt(String text, Color color) => Text(
        text,
        style: localeFont(color: color, fontWeight: FontWeight.w700),
      );
}
