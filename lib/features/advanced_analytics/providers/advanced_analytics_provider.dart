import 'dart:async';

import 'package:flutter/foundation.dart' show compute, ComputeCallback;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../budgets/data/budget.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../loans/data/loan.dart';
import '../../loans/providers/loan_provider.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../engine/analytics_engine_adapter.dart';

/// Caps how many section aggregations run in a background isolate at once.
/// Opening the landing watches ~8 section providers; without a bound they each
/// call `compute()` on the same frame and spawn ~8 isolates simultaneously,
/// which janks the open on a large database. The gate lets 2 run at a time and
/// queues the rest, so every section still shows its skeleton immediately and
/// the data fills in a couple at a time (see specs/performance.md §10 on
/// isolate cost).
class _ComputeGate {
  _ComputeGate(this.maxConcurrent);
  final int maxConcurrent;
  int _active = 0;
  final _waiting = <Completer<void>>[];

  Future<T> run<T>(Future<T> Function() task) async {
    if (_active >= maxConcurrent) {
      final c = Completer<void>();
      _waiting.add(c);
      await c.future;
    }
    _active++;
    try {
      return await task();
    } finally {
      _active--;
      if (_waiting.isNotEmpty) _waiting.removeAt(0).complete();
    }
  }
}

final _computeGate = _ComputeGate(2);

/// `compute()` behind the shared [_computeGate] so at most 2 isolates run at
/// once across all Advanced Analytics sections.
Future<R> _gated<Q, R>(ComputeCallback<Q, R> fn, Q message) =>
    _computeGate.run(() => compute(fn, message));

enum AdvancedAnalyticsSection {
  trends,
  category,
  patterns,
  cashFlow,
  merchants,
  savings,
}

/// Per-section date range preset. A compact set (1M / 3M / 6M / 12M) chosen in
/// a bottom sheet, matching the design. Each section keeps its own selection.
enum AdvancedAnalyticsRange { last1Month, last3Months, last6Months, last12Months }

extension AdvancedAnalyticsRangeX on AdvancedAnalyticsRange {
  String get shortLabel => switch (this) {
    AdvancedAnalyticsRange.last1Month => '1M',
    AdvancedAnalyticsRange.last3Months => '3M',
    AdvancedAnalyticsRange.last6Months => '6M',
    AdvancedAnalyticsRange.last12Months => '12M',
  };

  String get longLabel => switch (this) {
    AdvancedAnalyticsRange.last1Month => 'Last month',
    AdvancedAnalyticsRange.last3Months => 'Last 3 months',
    AdvancedAnalyticsRange.last6Months => 'Last 6 months',
    AdvancedAnalyticsRange.last12Months => 'Last 12 months',
  };

  /// Compact label for the pill (the sheet uses [longLabel]).
  String get pillLabel => switch (this) {
    AdvancedAnalyticsRange.last1Month => '1 month',
    AdvancedAnalyticsRange.last3Months => '3 months',
    AdvancedAnalyticsRange.last6Months => '6 months',
    AdvancedAnalyticsRange.last12Months => '12 months',
  };

  int get months => switch (this) {
    AdvancedAnalyticsRange.last1Month => 1,
    AdvancedAnalyticsRange.last3Months => 3,
    AdvancedAnalyticsRange.last6Months => 6,
    AdvancedAnalyticsRange.last12Months => 12,
  };

  ({DateTime from, DateTime to}) window(DateTime now) {
    final to = DateTime(now.year, now.month, now.day);
    final from = DateTime(now.year, now.month - (months - 1), 1);
    return (from: from, to: to);
  }
}

const advancedAnalyticsDefaultRange = AdvancedAnalyticsRange.last12Months;

final advancedAnalyticsRangeProvider =
    StateProvider.family<AdvancedAnalyticsRange, AdvancedAnalyticsSection>(
      (ref, section) => advancedAnalyticsDefaultRange,
    );

final cashFlowTableSortProvider = StateProvider<String>((ref) => 'month');
final selectedDeepDiveCategoryProvider = StateProvider<String?>((ref) => null);

final monthlyLedgerProvider = FutureProvider.autoDispose<List<MonthlyAggregate>>((
  ref,
) async {
  final input = await _input(ref, AdvancedAnalyticsSection.cashFlow);
  return _gated(_computeMonthly, input);
});

final trendsProvider = FutureProvider.autoDispose<TrendsResult>((ref) async {
  final input = await _input(ref, AdvancedAnalyticsSection.trends);
  return _gated(_computeTrends, input);
});

final spendingPatternsProvider = FutureProvider.autoDispose<SpendingPatternsResult>((
  ref,
) async {
  final input = await _input(ref, AdvancedAnalyticsSection.patterns);
  return _gated(_computePatterns, input);
});

final forecastProvider = FutureProvider.autoDispose<ForecastResult>((ref) async {
  final input = await _input(ref, AdvancedAnalyticsSection.cashFlow);
  return _gated(_computeForecast, input);
});

final merchantAnalysisProvider = FutureProvider.autoDispose<MerchantAnalysisResult>((
  ref,
) async {
  final input = await _input(ref, AdvancedAnalyticsSection.merchants);
  return _gated(_computeMerchants, input);
});

final savingsRateProvider = FutureProvider.autoDispose<SavingsRateResult>((ref) async {
  final input = await _input(ref, AdvancedAnalyticsSection.savings);
  return _gated(_computeSavings, input);
});

final financialHealthProvider = FutureProvider.autoDispose<FinancialHealthScore>((
  ref,
) async {
  final input = await _input(ref, AdvancedAnalyticsSection.cashFlow);
  return _gated(_computeHealth, input);
});

final anomalyProvider = FutureProvider.autoDispose<AnomalyResult>((ref) async {
  final input = await _input(ref, AdvancedAnalyticsSection.cashFlow);
  return _gated(_computeAnomalies, input);
});

final categoryDeepDiveProvider = FutureProvider.autoDispose<CategoryDeepDiveResult>((
  ref,
) async {
  final categoryId = ref.watch(selectedDeepDiveCategoryProvider);
  final input = await _input(
    ref,
    AdvancedAnalyticsSection.category,
    selectedCategoryId: categoryId,
  );
  return _gated(_computeCategory, input);
});

/// The Isar collections converted to the plain-map shapes the isolate engine
/// consumes, built **once** and shared by every section provider. Previously
/// each of the ~9 section providers rebuilt all of these lists on the main
/// thread on every (re)compute — for a 6000-transaction database that was
/// ~9x redundant allocation on the UI thread (see specs/performance.md §2:
/// derive expensive maps in a provider, not per caller). Riverpod memoises
/// this future, so a per-section date-range change re-reads the cached maps
/// without reconverting; only the raw collections changing invalidates it.
class _AnalyticsSource {
  final List<Map<String, Object?>> transactions;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> budgets;
  final List<Map<String, Object?>> accounts;
  final Map<int, double> balances;
  final List<Map<String, Object?>> loans;
  final List<Map<String, Object?>> recurringRules;

  const _AnalyticsSource({
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.accounts,
    required this.balances,
    required this.loans,
    required this.recurringRules,
  });
}

final _analyticsSourceProvider = FutureProvider<_AnalyticsSource>((ref) async {
  final txns = await ref.watch(transactionListProvider.future);
  final categories = await ref.watch(categoryListProvider.future);
  final budgets = await ref.watch(budgetListProvider.future);
  final accounts = await ref.watch(allAccountsProvider.future);
  final balances = await ref.watch(accountBalancesProvider.future);
  final loans = await ref.watch(loanListProvider.future);
  final recurring = await ref.watch(recurringListProvider.future);

  return _AnalyticsSource(
    transactions: txns.map(_txnMap).toList(),
    categories: categories.map(_categoryMap).toList(),
    budgets: budgets.map(_budgetMap).toList(),
    accounts: accounts.map(_accountMap).toList(),
    balances: balances,
    loans: loans.map(_loanMap).toList(),
    recurringRules: recurring.map(_recurringMap).toList(),
  );
});

Future<AnalyticsInput> _input(
  Ref ref,
  AdvancedAnalyticsSection section, {
  String mode = 'mom',
  String? selectedCategoryId,
}) async {
  final source = await ref.watch(_analyticsSourceProvider.future);
  final preset = ref.watch(advancedAnalyticsRangeProvider(section));
  final range = preset.window(DateTime.now());

  return AnalyticsInput(
    transactions: source.transactions,
    categories: source.categories,
    budgets: source.budgets,
    accounts: source.accounts,
    balances: source.balances,
    loans: source.loans,
    recurringRules: source.recurringRules,
    range: AnalyticsRange(range.from, range.to),
    selectedCategoryId: selectedCategoryId,
    now: DateTime.now(),
    mode: mode,
  );
}

List<MonthlyAggregate> _computeMonthly(AnalyticsInput input) =>
    computeMonthlyAggregates(input);
TrendsResult _computeTrends(AnalyticsInput input) => computeTrends(input);
SpendingPatternsResult _computePatterns(AnalyticsInput input) =>
    computeSpendingPatterns(input);
ForecastResult _computeForecast(AnalyticsInput input) => computeForecast(input);
MerchantAnalysisResult _computeMerchants(AnalyticsInput input) =>
    computeMerchantAnalysis(input);
SavingsRateResult _computeSavings(AnalyticsInput input) =>
    computeSavingsRate(input);
FinancialHealthScore _computeHealth(AnalyticsInput input) =>
    computeFinancialHealth(input);
AnomalyResult _computeAnomalies(AnalyticsInput input) =>
    computeAnomalies(input);
CategoryDeepDiveResult _computeCategory(AnalyticsInput input) =>
    computeCategoryDeepDive(input);

Map<String, Object?> _txnMap(Transaction t) => {
  'id': t.id,
  'name': t.name,
  'amount': t.amount,
  'type': t.type,
  'categoryId': t.categoryId,
  'accountId': t.accountId,
  'linkedRuleType': t.linkedRuleType,
  'isBalanceAdjustment': t.isBalanceAdjustment,
  'isTransfer': t.isTransfer,
  'createdAt': t.createdAt.toIso8601String(),
};

Map<String, Object?> _categoryMap(Category c) => {
  'id': c.id,
  'name': c.name,
  'icon': c.icon,
  'colorValue': c.colorValue,
  'type': c.type,
};

Map<String, Object?> _budgetMap(Budget b) => {
  'id': b.id,
  'categoryId': b.categoryId,
  'amount': b.amount,
  'isActive': b.isActive,
  'periodType': b.periodType.name,
};

Map<String, Object?> _accountMap(Account a) => {
  'id': a.id,
  'name': a.name,
  'type': a.type,
  'isCreditCard': a.isCreditCard,
};

Map<String, Object?> _loanMap(Loan l) => {
  'id': l.id,
  'name': l.name,
  'emiAmount': l.emiAmount,
  'isCompleted': l.isCompleted,
};

Map<String, Object?> _recurringMap(RecurringRule r) => {
  'id': r.id,
  'name': r.name,
  'amount': r.amount,
  'type': r.type,
  'nextDueAt': r.nextDueAt.toIso8601String(),
  'isPaused': r.isPaused,
};
