import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../investments/providers/investment_provider.dart';
import '../../ledger/providers/ledger_provider.dart';
import '../../loans/providers/loan_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, settingsProvider;
import '../../transactions/helpers/transaction_filters.dart';
import '../../transactions/providers/transaction_provider.dart';

// ─────────────────────────────── Models ─────────────────────────────────────

class KuberThinkingInfo {
  final String dateFilter;
  final List<String> scanned;
  const KuberThinkingInfo({required this.dateFilter, required this.scanned});
}

class KuberChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final KuberThinkingInfo? thinking;
  const KuberChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.thinking,
  });
}

class _QueryResult {
  final String response;
  final KuberThinkingInfo thinking;
  _QueryResult(this.response, this.thinking);
}

class _DateRange {
  final DateTime from;
  final DateTime to;
  final String label;
  _DateRange({required this.from, required this.to, required this.label});
}

// ─────────────────────────────── Screen ─────────────────────────────────────

class AskKuberScreen extends ConsumerStatefulWidget {
  const AskKuberScreen({super.key});

  @override
  ConsumerState<AskKuberScreen> createState() => _AskKuberScreenState();
}

class _AskKuberScreenState extends ConsumerState<AskKuberScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<KuberChatMessage> _messages = [];
  bool _isProcessing = false;
  bool _isInitializing = true;
  bool _isTyping = false;
  Timer? _typingTimer;

  static const _suggestions = [
    'Spendings this month',
    'Top category',
    'Net worth',
    'Biggest expense',
    'Income this month',
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final settings = await ref.read(settingsProvider.future);
    final name = settings.userName.isNotEmpty ? settings.userName : null;
    final greeting = name != null
        ? 'Hi $name! I\'m Kuber, your on-device finance assistant.\nAsk me anything about your spending, income, or balances.'
        : 'Hi! I\'m Kuber, your on-device finance assistant.\nAsk me anything about your spending, income, or balances.';

    setState(() {
      _messages.add(KuberChatMessage(
          text: greeting, isUser: false, time: DateTime.now()));
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHelp(BuildContext context) {
    KuberInfoBottomSheet.show(
      context,
      const KuberInfoConfig(
        title: 'Ask Kuber',
        description: 'Ask anything about your finances in plain English. Kuber runs entirely on-device — no internet, no data shared.',
        items: [
          KuberInfoItem(
            icon: Icons.currency_rupee_rounded,
            title: 'Spending',
            description: '"How much have I spent today/this week/this month?" or "How much did I spend in the past two weeks?"',
          ),
          KuberInfoItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Balances & Net Worth',
            description: '"What\'s my net worth?", "What\'s my HDFC balance?", or "What\'s my total balance?"',
          ),
          KuberInfoItem(
            icon: Icons.category_outlined,
            title: 'Categories & Trends',
            description: '"What\'s my top spending category?", "How many categories do I have?", "Average monthly expense?"',
          ),
          KuberInfoItem(
            icon: Icons.account_balance_outlined,
            title: 'Loans & Borrowing',
            description: '"How much do I owe on loans?", "How much have I borrowed?", "How much have I lent?"',
          ),
          KuberInfoItem(
            icon: Icons.show_chart,
            title: 'Investments & Budgets',
            description: '"What\'s my portfolio value?", "Show my budgets", "Am I overspending on any budget?"',
          ),
          KuberInfoItem(
            icon: Icons.format_list_numbered_rounded,
            title: 'Counts',
            description: '"How many transactions today?", "How many accounts do I have?", "How many income transactions?"',
          ),
        ],
      ),
    );
  }

  Future<void> _send([String? override]) async {
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty || _isProcessing || _isTyping) return;

    if (override == null) _controller.clear();

    setState(() {
      _messages.add(
          KuberChatMessage(text: input, isUser: true, time: DateTime.now()));
      _isProcessing = true;
    });
    _scrollToBottom();

    final results = await Future.wait([
      _processQuery(input),
      Future.delayed(const Duration(milliseconds: 1000)),
    ]);
    final result = results[0] as _QueryResult;

    if (!mounted) return;
    final msgTime = DateTime.now();
    setState(() {
      _messages.add(KuberChatMessage(
        text: '',
        isUser: false,
        time: msgTime,
        thinking: result.thinking,
      ));
      _isProcessing = false;
      _isTyping = true;
    });
    _scrollToBottom();
    _startTyping(result.response, msgTime, result.thinking);
  }

  void _startTyping(String response, DateTime msgTime, KuberThinkingInfo thinking) {
    int charIndex = 0;
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) { timer.cancel(); return; }
      charIndex = math.min(charIndex + 4, response.length);
      setState(() {
        _messages[_messages.length - 1] = KuberChatMessage(
          text: response.substring(0, charIndex),
          isUser: false,
          time: msgTime,
          thinking: thinking,
        );
      });
      if (charIndex >= response.length) {
        timer.cancel();
        setState(() => _isTyping = false);
      }
      if (charIndex % 60 == 0) _scrollToBottom();
    });
  }

  // ── Date-range helpers ────────────────────────────────────────────────────

  _DateRange? _parseCustomDateRange(String lower) {
    const wordNums = {
      'a': 1, 'an': 1, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
      'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    };
    final match = RegExp(
      r'(?:past|last)\s+(\d+|a|an|one|two|three|four|five|six|seven|eight|nine|ten)'
      r'\s+(day|days|week|weeks|month|months|year|years)',
    ).firstMatch(lower);
    if (match == null) return null;

    final numStr = match.group(1)!;
    final n = int.tryParse(numStr) ?? wordNums[numStr] ?? 1;
    final unit = match.group(2)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final to = today.add(const Duration(days: 1));

    DateTime from;
    String label;
    if (unit.startsWith('day')) {
      from = today.subtract(Duration(days: n - 1));
      label = n == 1 ? 'day' : '$n days';
    } else if (unit.startsWith('week')) {
      from = today.subtract(Duration(days: n * 7));
      label = n == 1 ? 'week' : '$n weeks';
    } else if (unit.startsWith('month')) {
      int m = now.month - n;
      int y = now.year;
      while (m <= 0) {
        m += 12;
        y--;
      }
      from = DateTime(y, m, now.day);
      label = n == 1 ? 'month' : '$n months';
    } else {
      from = DateTime(now.year - n, now.month, now.day);
      label = n == 1 ? 'year' : '$n years';
    }
    return _DateRange(from: from, to: to, label: label);
  }

  bool _hasExplicitTimeContext(String lower) =>
      lower.contains('today') ||
      lower.contains('this week') ||
      lower.contains('this month') ||
      lower.contains('last month') ||
      lower.contains('last week') ||
      lower.contains('this year') ||
      RegExp(r'(?:past|last)\s+\d+').hasMatch(lower) ||
      RegExp(r'(?:past|last)\s+(?:a|an|one|two|three|four|five|six|seven|eight|nine|ten)\s+\w+')
          .hasMatch(lower);

  // ── Query processor ───────────────────────────────────────────────────────

  Future<_QueryResult> _processQuery(String input) async {
    final lower = input.toLowerCase();

    final txns = ref.read(transactionListProvider).valueOrNull ?? [];
    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final settings = await ref.read(settingsProvider.future);
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final formatter = ref.read(formatterProvider);
    final currency = currencyFromCode(settings.currency);
    currency.symbol;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.month == 12 ? now.year + 1 : now.year, now.month == 12 ? 1 : now.month + 1, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final yearStart = DateTime(now.year, 1, 1);
    final yearEnd = DateTime(now.year + 1, 1, 1);

    double sumExpenses(DateTime from, DateTime to) => txns.validForCalculations
        .where((t) =>
            t.type == 'expense' &&
            !t.createdAt.isBefore(from) &&
            t.createdAt.isBefore(to))
        .fold(0.0, (s, t) => s + t.amount);

    double sumIncome(DateTime from, DateTime to) => txns.validForCalculations
        .where((t) =>
            t.type == 'income' &&
            !t.createdAt.isBefore(from) &&
            t.createdAt.isBefore(to))
        .fold(0.0, (s, t) => s + t.amount);

    // ── Category-specific spending ──
    if ((lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense')) &&
        !(lower.contains('top') || lower.contains('most'))) {
      final matchedCat = categories
          .where((c) =>
              c.name.trim().isNotEmpty &&
              lower.contains(c.name.toLowerCase()))
          .firstOrNull;

      if (matchedCat != null) {
        final catCustomRange = _parseCustomDateRange(lower);
        final DateTime from;
        final DateTime to;
        final String dateLabel;
        final String thinkingDate;

        if (catCustomRange != null) {
          from = catCustomRange.from;
          to = catCustomRange.to;
          dateLabel = 'in the past ${catCustomRange.label}';
          thinkingDate =
              '${_fmtDate(catCustomRange.from)} – ${_fmtDate(catCustomRange.to.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('this year')) {
          from = yearStart;
          to = yearEnd;
          dateLabel = 'this year';
          thinkingDate = '${_fmtDate(yearStart)} – ${_fmtDate(today)}';
        } else if (lower.contains('last month')) {
          from = lastMonthStart;
          to = lastMonthEnd;
          dateLabel = 'last month';
          thinkingDate =
              '${_fmtDate(lastMonthStart)} – ${_fmtDate(lastMonthEnd.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('last week')) {
          final lastWeekStart = weekStart.subtract(const Duration(days: 7));
          from = lastWeekStart;
          to = weekStart;
          dateLabel = 'last week';
          thinkingDate =
              '${_fmtDate(lastWeekStart)} – ${_fmtDate(weekStart.subtract(const Duration(days: 1)))}';
        } else if (lower.contains('today')) {
          from = today;
          to = today.add(const Duration(days: 1));
          dateLabel = 'today';
          thinkingDate = _fmtDate(today);
        } else if (lower.contains('week')) {
          from = weekStart;
          to = today.add(const Duration(days: 1));
          dateLabel = 'this week';
          thinkingDate = '${_fmtDate(weekStart)} – ${_fmtDate(today)}';
        } else if (lower.contains('month')) {
          from = monthStart;
          to = monthEnd;
          dateLabel = 'this month';
          thinkingDate = '${_fmtDate(monthStart)} – ${_fmtDate(today)}';
        } else {
          from = DateTime(2000);
          to = today.add(const Duration(days: 1));
          dateLabel = 'overall';
          thinkingDate = 'All time';
        }

        final total = txns.validForCalculations
            .where((t) =>
                t.type == 'expense' &&
                t.categoryId == matchedCat.id.toString() &&
                !t.createdAt.isBefore(from) &&
                t.createdAt.isBefore(to))
            .fold(0.0, (sum, t) => sum + t.amount);

        final verb = (dateLabel == 'today' ||
                dateLabel == 'this week' ||
                dateLabel == 'this month' ||
                dateLabel == 'this year')
            ? "You've spent"
            : 'You spent';
        final suffix =
            dateLabel == 'overall' ? 'in total' : dateLabel;

        return _QueryResult(
          '$verb ${formatter.formatCurrency(total)} on ${matchedCat.name} $suffix.',
          KuberThinkingInfo(
            dateFilter: thinkingDate,
            scanned: ['Transactions', 'Categories (${matchedCat.name})'],
          ),
        );
      }
    }

    // ── Custom date range ("past two weeks", "last 3 months") ──
    final customRange = _parseCustomDateRange(lower);
    if (customRange != null &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(customRange.from, customRange.to);
      return _QueryResult(
        'You spent ${formatter.formatCurrency(total)} in the past ${customRange.label}.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(customRange.from)} – ${_fmtDate(customRange.to)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Expenses today ──
    if ((lower.contains('today') || lower.contains('day')) &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(today, today.add(const Duration(days: 1)));
      return _QueryResult(
        'You\'ve spent ${formatter.formatCurrency(total)} today.',
        KuberThinkingInfo(
          dateFilter: _fmtDate(today),
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Expenses this week ──
    if (lower.contains('week') &&
        !lower.contains('last') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total = sumExpenses(weekStart, today.add(const Duration(days: 1)));
      return _QueryResult(
        'You\'ve spent ${formatter.formatCurrency(total)} this week.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(weekStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Expenses last month ──
    if (lower.contains('last month') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total = sumExpenses(lastMonthStart, lastMonthEnd);
      return _QueryResult(
        'You spent ${formatter.formatCurrency(total)} last month.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(lastMonthStart)} – ${_fmtDate(lastMonthEnd.subtract(const Duration(days: 1)))}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Expenses this month ──
    if ((lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last') &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(monthStart, monthEnd);
      final count = txns.validForCalculations
          .where((t) =>
              t.type == 'expense' &&
              !t.createdAt.isBefore(monthStart) &&
              t.createdAt.isBefore(monthEnd))
          .length;
      return _QueryResult(
        'You\'ve spent ${formatter.formatCurrency(total)} this month across $count transactions.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(monthStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Expenses this year ──
    if (lower.contains('this year') &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(yearStart, yearEnd);
      final count = txns.validForCalculations
          .where((t) =>
              t.type == 'expense' &&
              !t.createdAt.isBefore(yearStart) &&
              t.createdAt.isBefore(yearEnd))
          .length;
      return _QueryResult(
        'You\'ve spent ${formatter.formatCurrency(total)} this year across $count transactions.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(yearStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Top category ──
    if ((lower.contains('most') || lower.contains('top')) &&
        (lower.contains('spent') ||
            lower.contains('category') ||
            lower.contains('categor'))) {
      // Determine date range: custom ("last 2 weeks") > this month > all time
      final catCustomRange = _parseCustomDateRange(lower);
      final allTime = catCustomRange == null && !_hasExplicitTimeContext(lower);

      final Map<String, double> byCat = {};
      for (final t in txns.validForCalculations) {
        if (t.type != 'expense') continue;
        if (catCustomRange != null) {
          if (t.createdAt.isBefore(catCustomRange.from) ||
              !t.createdAt.isBefore(catCustomRange.to)) {
            continue;
          }
        } else if (!allTime) {
          if (t.createdAt.isBefore(monthStart) ||
              !t.createdAt.isBefore(monthEnd)) {
            continue;
          }
        }
        byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
      }

      final String periodLabel;
      final String thinkingDateFilter;
      if (catCustomRange != null) {
        periodLabel = 'in the past ${catCustomRange.label}';
        thinkingDateFilter = '${_fmtDate(catCustomRange.from)} – ${_fmtDate(today)}';
      } else if (allTime) {
        periodLabel = 'overall';
        thinkingDateFilter = 'All time';
      } else {
        periodLabel = 'this month';
        thinkingDateFilter = '${_fmtDate(monthStart)} – ${_fmtDate(today)}';
      }

      if (byCat.isEmpty) {
        return _QueryResult(
          'No expense data found for that period.',
          KuberThinkingInfo(
            dateFilter: thinkingDateFilter,
            scanned: ['Transactions', 'Categories'],
          ),
        );
      }
      final topEntry = byCat.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topCat =
          categories.where((c) => c.id.toString() == topEntry.key).firstOrNull;
      return _QueryResult(
        'Your top spending category $periodLabel is ${topCat?.name ?? "Unknown"} — ${formatter.formatCurrency(topEntry.value)}.',
        KuberThinkingInfo(
          dateFilter: thinkingDateFilter,
          scanned: ['Transactions', 'Categories'],
        ),
      );
    }

    // ── Income this month ──
    if (lower.contains('income') &&
        (lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last')) {
      final total = sumIncome(monthStart, monthEnd);
      return _QueryResult(
        'Your income this month is ${formatter.formatCurrency(total)}.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(monthStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Income this year ──
    if (lower.contains('income') && lower.contains('this year')) {
      final total = sumIncome(yearStart, yearEnd);
      return _QueryResult(
        'Your income this year is ${formatter.formatCurrency(total)}.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(yearStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Savings ──
    if (lower.contains('saving') || lower.contains('saved') || lower.contains('save')) {
      final income = sumIncome(monthStart, monthEnd);
      final expense = sumExpenses(monthStart, monthEnd);
      final savings = income - expense;
      return _QueryResult(
        'This month you earned ${formatter.formatCurrency(income)} and spent ${formatter.formatCurrency(expense)}.\nNet savings: ${formatter.formatCurrency(savings.abs())}${savings < 0 ? ' (deficit)' : ''}.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(monthStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Biggest expense ──
    if ((lower.contains('biggest') || lower.contains('largest')) &&
        (lower.contains('expense') || lower.contains('transaction'))) {
      final expenses = txns.validForCalculations
          .where((t) => t.type == 'expense')
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      if (expenses.isEmpty) {
        return _QueryResult(
          'No expenses found.',
          KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
        );
      }
      final top = expenses.first;
      return _QueryResult(
        'Your biggest expense is "${top.name}" — ${formatter.formatCurrency(top.amount)} on ${_fmtDate(top.createdAt)}.',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Transaction count — today ──
    if (lower.contains('how many') && lower.contains('transaction') && lower.contains('today')) {
      final count = txns.where((t) =>
          !t.isBalanceAdjustment &&
          !t.createdAt.isBefore(today) &&
          t.createdAt.isBefore(today.add(const Duration(days: 1)))).length;
      return _QueryResult(
        'You made $count transaction${count == 1 ? '' : 's'} today.',
        KuberThinkingInfo(dateFilter: _fmtDate(today), scanned: ['Transactions']),
      );
    }

    // ── Transaction count — this week ──
    if (lower.contains('how many') && lower.contains('transaction') && lower.contains('week')) {
      final count = txns.where((t) =>
          !t.isBalanceAdjustment &&
          !t.createdAt.isBefore(weekStart) &&
          t.createdAt.isBefore(today.add(const Duration(days: 1)))).length;
      return _QueryResult(
        'You made $count transaction${count == 1 ? '' : 's'} this week.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(weekStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Transaction count — this month ──
    if (lower.contains('how many') && lower.contains('transaction') && lower.contains('month')) {
      final count = txns.where((t) =>
          !t.isBalanceAdjustment &&
          !t.createdAt.isBefore(monthStart) &&
          t.createdAt.isBefore(monthEnd)).length;
      return _QueryResult(
        'You made $count transaction${count == 1 ? '' : 's'} this month.',
        KuberThinkingInfo(
          dateFilter: '${_fmtDate(monthStart)} – ${_fmtDate(today)}',
          scanned: ['Transactions'],
        ),
      );
    }

    // ── Transaction count — total ──
    if (lower.contains('how many') && lower.contains('transaction')) {
      final count = txns.where((t) => !t.isBalanceAdjustment).length;
      return _QueryResult(
        'You have $count transactions in total.',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Expense transaction count ──
    if (lower.contains('how many') && (lower.contains('expense') || lower.contains('expenses'))) {
      final count = txns.where((t) => t.type == 'expense' && !t.isBalanceAdjustment).length;
      return _QueryResult(
        'You have $count expense transaction${count == 1 ? '' : 's'} in total.',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Income transaction count ──
    if (lower.contains('how many') && lower.contains('income')) {
      final count = txns.where((t) => t.type == 'income' && !t.isBalanceAdjustment).length;
      return _QueryResult(
        'You have $count income transaction${count == 1 ? '' : 's'} in total.',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Account count ──
    if (lower.contains('how many') && lower.contains('account')) {
      return _QueryResult(
        'You have ${accounts.length} account${accounts.length == 1 ? '' : 's'}.',
        KuberThinkingInfo(dateFilter: 'Current', scanned: ['Accounts']),
      );
    }

    // ── Category count ──
    if (lower.contains('how many') && lower.contains('categor')) {
      return _QueryResult(
        'You have ${categories.length} categor${categories.length == 1 ? 'y' : 'ies'} set up.',
        KuberThinkingInfo(dateFilter: 'Current', scanned: ['Categories']),
      );
    }

    // ── Average monthly expense ──
    if ((lower.contains('average') || lower.contains('avg')) &&
        (lower.contains('expense') || lower.contains('spend'))) {
      final monthlyTotals = <String, double>{};
      for (final t in txns.validForCalculations.where((t) => t.type == 'expense')) {
        final key = '${t.createdAt.year}-${t.createdAt.month}';
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + t.amount;
      }
      if (monthlyTotals.isEmpty) {
        return _QueryResult(
          'No expense data yet.',
          KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
        );
      }
      final avg = monthlyTotals.values.reduce((a, b) => a + b) / monthlyTotals.length;
      return _QueryResult(
        'Your average monthly spending is ${formatter.formatCurrency(avg)} (across ${monthlyTotals.length} month${monthlyTotals.length == 1 ? '' : 's'}).',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Recent transactions ──
    if ((lower.contains('recent') || lower.contains('latest')) && lower.contains('transaction')) {
      final valid = txns.where((t) => !t.isBalanceAdjustment && !t.isTransfer).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final top = valid.take(3).toList();
      if (top.isEmpty) {
        return _QueryResult(
          'No transactions found.',
          KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
        );
      }
      final lines = top
          .map((t) => '• ${t.name} — ${formatter.formatCurrency(t.amount)} on ${_fmtDate(t.createdAt)}')
          .join('\n');
      return _QueryResult(
        'Your 3 most recent transactions:\n$lines',
        KuberThinkingInfo(dateFilter: 'All time', scanned: ['Transactions']),
      );
    }

    // ── Account-specific balance ──
    for (final a in accounts) {
      if (lower.contains(a.name.toLowerCase()) &&
          (lower.contains('balance') || lower.contains('how much'))) {
        final balance = await ref.read(accountBalanceProvider(a.id).future);
        return _QueryResult(
          '${a.name} balance: ${formatter.formatCurrency(balance)}.',
          KuberThinkingInfo(dateFilter: 'Current balance', scanned: ['Accounts']),
        );
      }
    }

    // ── Net worth / total balance ──
    if (lower.contains('balance') ||
        lower.contains('net worth') ||
        lower.contains('networth') ||
        lower.contains('total')) {
      double total = 0;
      for (final a in accounts) {
        total += await ref.read(accountBalanceProvider(a.id).future);
      }
      return _QueryResult(
        'Your total net worth across ${accounts.length} account${accounts.length == 1 ? '' : 's'} is ${formatter.formatCurrency(total)}.',
        KuberThinkingInfo(dateFilter: 'Current balances', scanned: ['Accounts']),
      );
    }

    // ── Loans ──
    if (lower.contains('loan') ||
        lower.contains('emi') ||
        (lower.contains('debt') && !lower.contains('borrow')) ||
        lower.contains('repay') ||
        lower.contains('lender')) {
      final summary = await ref.read(loanSummaryProvider.future);
      if (summary.outstanding == 0 && summary.totalPaid == 0) {
        return _QueryResult(
          'You have no active loans tracked.',
          KuberThinkingInfo(dateFilter: 'Current', scanned: ['Loans']),
        );
      }
      return _QueryResult(
        'Loan summary:\n• Outstanding: ${formatter.formatCurrency(summary.outstanding)}\n• Total paid so far: ${formatter.formatCurrency(summary.totalPaid)}',
        KuberThinkingInfo(dateFilter: 'Active loans', scanned: ['Loans']),
      );
    }

    // ── Lend / Borrow ──
    if (lower.contains('borrow') ||
        lower.contains('lent') ||
        lower.contains('lend') ||
        lower.contains('owe') ||
        lower.contains('receivable') ||
        lower.contains('payable')) {
      final summary = await ref.read(ledgerSummaryProvider.future);
      if (lower.contains('borrow') || lower.contains('owe')) {
        return _QueryResult(
          'You currently owe ${formatter.formatCurrency(summary.owed)} in total (money you borrowed).',
          KuberThinkingInfo(dateFilter: 'Current', scanned: ['Ledger']),
        );
      }
      if (lower.contains('lent') || lower.contains('lend') || lower.contains('receivable')) {
        return _QueryResult(
          'People owe you ${formatter.formatCurrency(summary.toReceive)} in total (money you lent).',
          KuberThinkingInfo(dateFilter: 'Current', scanned: ['Ledger']),
        );
      }
      return _QueryResult(
        'Lend/Borrow summary:\n• You are owed: ${formatter.formatCurrency(summary.toReceive)}\n• You owe: ${formatter.formatCurrency(summary.owed)}',
        KuberThinkingInfo(dateFilter: 'Current', scanned: ['Ledger']),
      );
    }

    // ── Investments ──
    if (lower.contains('invest') ||
        lower.contains('portfolio') ||
        lower.contains('stock') ||
        lower.contains('mutual fund') ||
        lower.contains('asset') ||
        lower.contains('gain') ||
        lower.contains('loss')) {
      final summary = await ref.read(investmentSummaryProvider.future);
      if (summary.assetCount == 0) {
        return _QueryResult(
          'No investments tracked yet.',
          KuberThinkingInfo(dateFilter: 'Current', scanned: ['Investments']),
        );
      }
      final gainLabel = summary.gainLoss >= 0
          ? '+${formatter.formatCurrency(summary.gainLoss)}'
          : '−${formatter.formatCurrency(summary.gainLoss.abs())}';
      return _QueryResult(
        'Investment portfolio (${summary.assetCount} asset${summary.assetCount == 1 ? '' : 's'}):\n• Invested: ${formatter.formatCurrency(summary.totalInvested)}\n• Current value: ${formatter.formatCurrency(summary.currentValue)}\n• Gain/Loss: $gainLabel',
        KuberThinkingInfo(dateFilter: 'Current', scanned: ['Investments']),
      );
    }

    // ── Budgets ──
    if (lower.contains('budget') ||
        lower.contains('spending limit') ||
        lower.contains('overspend')) {
      final budgets = await ref.read(budgetVsActualProvider.future);
      if (budgets.isEmpty) {
        return _QueryResult(
          'No active budgets set up.',
          KuberThinkingInfo(dateFilter: 'Current period', scanned: ['Budgets']),
        );
      }
      final catMap = await ref.read(categoryMapProvider.future);
      final lines = budgets.take(5).map((b) {
        final catName = catMap[int.tryParse(b.budget.categoryId)]?.name ?? 'Budget';
        final pct = b.progress.percentage.toStringAsFixed(0);
        final over = b.progress.percentage > 100;
        return '• $catName: ${formatter.formatCurrency(b.progress.spent)} / ${formatter.formatCurrency(b.progress.limit)} ($pct%${over ? ' over!' : ''})';
      }).join('\n');
      return _QueryResult(
        'Your budgets this period:\n$lines',
        KuberThinkingInfo(dateFilter: 'Current period', scanned: ['Budgets', 'Transactions']),
      );
    }

    // ── Fallback ──
    return _QueryResult(
      'I can answer questions about your spending, income, balances, and categories.\n\nTry:\n• "How much have I spent this month?"\n• "How much did I spend in the past two weeks?"\n• "What\'s my net worth?"\n• "What\'s my top category?"\n• "How much do I owe on loans?"\n• "What\'s my portfolio value?"',
      KuberThinkingInfo(dateFilter: 'N/A', scanned: []),
    );
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showSuggestions =
        _messages.where((m) => m.isUser).isEmpty && !_isInitializing;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.md, KuberSpacing.sm, KuberSpacing.lg, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 18, color: cs.primary),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask Kuber (Beta)',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface),
                        ),
                        Text(
                          'On-device • No internet required',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showHelp(context),
                    child: Icon(Icons.help_outline_rounded,
                        size: 20, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.3)),
          // Messages list
          Expanded(
            child: _isInitializing
                ? _InitializingSkeleton()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
                    itemCount: _messages.length + (_isProcessing ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_isProcessing && i == _messages.length) {
                        return _TypingIndicator();
                      }
                      final msg = _messages[i];
                      final showDate = i == 0 ||
                          !_isSameDay(_messages[i - 1].time, msg.time);
                      return Column(
                        children: [
                          if (showDate) _DateSeparator(date: msg.time),
                          msg.isUser
                              ? _UserBubble(message: msg)
                              : _KuberBubble(message: msg),
                        ],
                      );
                    },
                  ),
          ),
          // Suggestion chips
          if (showSuggestions)
            Container(
              color: cs.surface,
              padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestions
                      .map((s) => GestureDetector(
                            onTap: () => _send(s),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(KuberRadius.full),
                                border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                s,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          // Input bar
          Container(
            color: cs.surface,
            padding: EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              KuberSpacing.sm,
              KuberSpacing.lg,
              math.max(KuberSpacing.md, MediaQuery.of(context).padding.bottom),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isProcessing,
                    maxLines: 4,
                    minLines: 1,
                    style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Ask about your spending...',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 15,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (_controller.text.trim().isNotEmpty) _send();
                    },
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    final isEmpty = value.text.trim().isEmpty;
                    final isDisabled = _isProcessing || isEmpty;

                    return GestureDetector(
                      onTap: isDisabled ? null : () => _send(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? cs.onSurfaceVariant.withValues(alpha: 0.2)
                              : cs.primary,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                        ),
                        child: Center(
                          child: _isProcessing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onSurfaceVariant,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 22,
                                  color: isDisabled
                                      ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                      : cs.onPrimary,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ────────────────────────── Skeleton ────────────────────────────────────────

class _InitializingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBox(width: 200, height: 14, cs: cs),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 160, height: 14, cs: cs),
                  const SizedBox(height: 6),
                  _SkeletonBox(width: 120, height: 14, cs: cs),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final ColorScheme cs;
  const _SkeletonBox(
      {required this.width, required this.height, required this.cs});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
        ),
      );
}

// ────────────────────────── Chat bubbles ────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    String label;
    if (d == today) {
      label = 'Today';
    } else if (d == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
      child: Row(children: [
        Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
          child: Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.3))),
      ]),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final KuberChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
          decoration: const BoxDecoration(
            color: Color(0xFF3B82F6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: GoogleFonts.inter(fontSize: 14, color: cs.onPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('h:mm a').format(message.time),
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: cs.onPrimary.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

TextSpan _buildRichText(String text, TextStyle base, Color highlight) {
  final pattern = RegExp(r'[₹$€£]?[\d,]+(?:\.\d+)?', caseSensitive: false);
  final spans = <TextSpan>[];
  int last = 0;
  for (final m in pattern.allMatches(text)) {
    final matched = m.group(0)!;
    if (!RegExp(r'\d').hasMatch(matched)) continue;
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(
      text: matched,
      style: base.copyWith(fontWeight: FontWeight.w700, color: highlight),
    ));
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return TextSpan(children: spans);
}

// ── Kuber bubble with "SHOW THINKING" expandable section ────────────────────

class _KuberBubble extends StatefulWidget {
  final KuberChatMessage message;
  const _KuberBubble({required this.message});

  @override
  State<_KuberBubble> createState() => _KuberBubbleState();
}

class _KuberBubbleState extends State<_KuberBubble>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _sizeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final thinking = widget.message.thinking;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 14, color: cs.primary),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              child: Container(
                margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main message content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: _buildRichText(
                              widget.message.text,
                              GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                              cs.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('h:mm a').format(widget.message.time),
                            style: GoogleFonts.inter(
                                fontSize: 10, color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // "SHOW THINKING" section — only when thinking data is present
                    if (thinking != null) ...[
                      Divider(
                          height: 1, color: cs.outline.withValues(alpha: 0.2)),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KuberSpacing.md, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedRotation(
                                turns: _expanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'SHOW THINKING',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizeTransition(
                        sizeFactor: _sizeAnim,
                        axisAlignment: -1,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              KuberSpacing.md, 0, KuberSpacing.md, KuberSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                  height: 1,
                                  color: cs.outline.withValues(alpha: 0.15)),
                              const SizedBox(height: 6),
                              _ThinkingRow(
                                label: 'Date filter',
                                value: thinking.dateFilter,
                                cs: cs,
                              ),
                              if (thinking.scanned.isNotEmpty)
                                _ThinkingRow(
                                  label: 'Scanned',
                                  value: thinking.scanned.join(', '),
                                  cs: cs,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _ThinkingRow(
      {required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Typing indicator ────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.auto_awesome_rounded, size: 14, color: cs.primary),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.md, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 150),
                const SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: cs.onSurfaceVariant.withValues(alpha: 0.3 + 0.7 * _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
