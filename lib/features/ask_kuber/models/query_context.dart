import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../services/parameter_extractor.dart';

/// Reads a provider's current value, like `WidgetRef.read` / `Ref.read`.
/// Abstracting it keeps [QueryContext] decoupled from the widget layer and lets
/// tests inject a stub.
typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

T _unsupportedReader<T>(ProviderListenable<T> _) =>
    throw UnimplementedError('QueryContext.read is not wired in this context');

/// Everything a handler needs to answer a query: the raw + lowercased text, the
/// preloaded read-only datasets the monolith used to fetch once, the standard
/// date windows, and small formatting helpers. Async summaries (balances, loan/
/// ledger/investment/budget rollups) are read on demand through [read].
class QueryContext {
  final String raw;
  final String lower;

  /// Reads providers for the async summary handlers (balances, loans, ledger,
  /// investments, budgets). In the app this is `WidgetRef.read`.
  final ProviderReader read;

  final List<Transaction> txns;
  final List<Account> accounts;
  final List<Category> categories;
  final SettingsState settings;
  final AppFormatter formatter;
  final String currencySymbol;
  final ParameterExtractor extractor;

  final DateTime now;
  final DateTime today;
  final DateTime monthStart;
  final DateTime monthEnd;
  final DateTime lastMonthStart;
  final DateTime lastMonthEnd;
  final DateTime weekStart;
  final DateTime yearStart;
  final DateTime yearEnd;

  QueryContext._({
    required this.raw,
    required this.lower,
    required this.read,
    required this.txns,
    required this.accounts,
    required this.categories,
    required this.settings,
    required this.formatter,
    required this.currencySymbol,
    required this.extractor,
    required this.now,
    required this.today,
    required this.monthStart,
    required this.monthEnd,
    required this.lastMonthStart,
    required this.lastMonthEnd,
    required this.weekStart,
    required this.yearStart,
    required this.yearEnd,
  });

  static Future<QueryContext> build(String raw, WidgetRef ref) async {
    final txns = ref.read(transactionListProvider).valueOrNull ?? const [];
    final accounts = ref.read(accountListProvider).valueOrNull ?? const [];
    final settings = await ref.read(settingsProvider.future);
    final categories = ref.read(categoryListProvider).valueOrNull ??
        await ref.read(categoryListProvider.future) ??
        const <Category>[];
    final formatter = ref.read(formatterProvider);
    final currency = currencyFromCode(settings.currency);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year + 1, 1, 1);

    return QueryContext._(
      raw: raw,
      lower: raw.toLowerCase(),
      read: ref.read,
      txns: txns,
      accounts: accounts,
      categories: categories,
      settings: settings,
      formatter: formatter,
      currencySymbol: currency.symbol,
      extractor: const ParameterExtractor(),
      now: now,
      today: today,
      monthStart: monthStart,
      monthEnd: monthEnd,
      lastMonthStart: lastMonthStart,
      lastMonthEnd: lastMonthEnd,
      weekStart: weekStart,
      yearStart: yearStart,
      yearEnd: yearEnd,
    );
  }

  /// Builds a context with explicit data and no provider plumbing, for unit
  /// tests of handlers that operate on the preloaded datasets. [read] defaults
  /// to a stub that throws, so a test that exercises a summary handler must
  /// supply one.
  factory QueryContext.forTest({
    required String raw,
    ProviderReader read = _unsupportedReader,
    List<Transaction> txns = const [],
    List<Account> accounts = const [],
    List<Category> categories = const [],
    SettingsState settings = const SettingsState(),
    AppFormatter? formatter,
    String currencySymbol = '₹',
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    return QueryContext._(
      raw: raw,
      lower: raw.toLowerCase(),
      read: read,
      txns: txns,
      accounts: accounts,
      categories: categories,
      settings: settings,
      formatter: formatter ?? AppFormatter(),
      currencySymbol: currencySymbol,
      extractor: const ParameterExtractor(),
      now: n,
      today: today,
      monthStart: DateTime(n.year, n.month, 1),
      monthEnd: DateTime(
          n.month == 12 ? n.year + 1 : n.year, n.month == 12 ? 1 : n.month + 1, 1),
      lastMonthStart: DateTime(n.year, n.month - 1, 1),
      lastMonthEnd: DateTime(n.year, n.month, 1),
      weekStart: today.subtract(Duration(days: today.weekday - 1)),
      yearStart: DateTime(n.year, 1, 1),
      yearEnd: DateTime(n.year + 1, 1, 1),
    );
  }

  /// Sum of expense amounts in `[from, to)`, excluding transfers and balance
  /// adjustments (same baseline the monolith used).
  double sumExpenses(DateTime from, DateTime to) => txns.validForCalculations
      .where((t) =>
          t.type == 'expense' &&
          !t.createdAt.isBefore(from) &&
          t.createdAt.isBefore(to))
      .fold(0.0, (s, t) => s + t.amount);

  /// Sum of income amounts in `[from, to)`, same baseline as [sumExpenses].
  double sumIncome(DateTime from, DateTime to) => txns.validForCalculations
      .where((t) =>
          t.type == 'income' &&
          !t.createdAt.isBefore(from) &&
          t.createdAt.isBefore(to))
      .fold(0.0, (s, t) => s + t.amount);

  /// Whole-number currency in the user's symbol. Ask Kuber never shows paise.
  String money(num amount) =>
      formatter.formatCurrency(amount.round(), symbol: currencySymbol);

  String fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
