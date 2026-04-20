import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, settingsProvider;
import '../../transactions/providers/transaction_provider.dart';

// ─────────────────────────────── Model ──────────────────────────────────────

class KuberChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  const KuberChatMessage(
      {required this.text, required this.isUser, required this.time});
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

  static const _suggestions = [
    'Spent this month',
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
    // Small delay so screen opens first, then greeting appears (skeleton feel)
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final settings = await ref.read(settingsProvider.future);
    final name = settings.userName.isNotEmpty ? settings.userName : null;
    final greeting = name != null
        ? 'Hi $name! I\'m Kuber — your on-device finance assistant.\nAsk me anything about your spending, income, or balances.'
        : 'Hi! I\'m Kuber — your on-device finance assistant.\nAsk me anything about your spending, income, or balances.';

    setState(() {
      _messages.add(KuberChatMessage(
          text: greeting, isUser: false, time: DateTime.now()));
      _isInitializing = false;
    });
  }

  @override
  void dispose() {
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

  Future<void> _send([String? override]) async {
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty || _isProcessing) return;

    if (override == null) _controller.clear();

    setState(() {
      _messages.add(
          KuberChatMessage(text: input, isUser: true, time: DateTime.now()));
      _isProcessing = true;
    });
    _scrollToBottom();

    final response = await _processQuery(input);

    if (!mounted) return;
    setState(() {
      _messages.add(KuberChatMessage(
          text: response, isUser: false, time: DateTime.now()));
      _isProcessing = false;
    });
    _scrollToBottom();
  }

  Future<String> _processQuery(String input) async {
    final lower = input.toLowerCase();

    final txns = ref.read(transactionListProvider).valueOrNull ?? [];
    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final settings = await ref.read(settingsProvider.future);
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final formatter = ref.read(formatterProvider);
    final currency = currencyFromCode(settings.currency);
    currency.symbol; // accessed via formatter below

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    // Helpers
    double sumExpenses(DateTime from, DateTime to) => txns
        .where((t) =>
            t.type == 'expense' &&
            !t.isTransfer &&
            !t.isBalanceAdjustment &&
            t.linkedRuleType == null &&
            !t.createdAt.isBefore(from) &&
            t.createdAt.isBefore(to.add(const Duration(days: 1))))
        .fold(0.0, (s, t) => s + t.amount);

    double sumIncome(DateTime from, DateTime to) => txns
        .where((t) =>
            t.type == 'income' &&
            !t.isTransfer &&
            !t.isBalanceAdjustment &&
            t.linkedRuleType == null &&
            !t.createdAt.isBefore(from) &&
            t.createdAt.isBefore(to.add(const Duration(days: 1))))
        .fold(0.0, (s, t) => s + t.amount);

    // ── Expenses today ──
    if ((lower.contains('today') || lower.contains('day')) &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(today, today);
      return 'You\'ve spent ${formatter.formatCurrency(total)} today.';
    }

    // ── Expenses this week ──
    if (lower.contains('week') &&
        !lower.contains('last') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total = sumExpenses(weekStart, today);
      return 'You\'ve spent ${formatter.formatCurrency(total)} this week.';
    }

    // ── Expenses last month ──
    if (lower.contains('last month') &&
        (lower.contains('spent') || lower.contains('spend'))) {
      final total = sumExpenses(lastMonthStart, lastMonthEnd);
      return 'You spent ${formatter.formatCurrency(total)} last month.';
    }

    // ── Expenses this month ──
    if ((lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last') &&
        (lower.contains('spent') ||
            lower.contains('spend') ||
            lower.contains('expense'))) {
      final total = sumExpenses(monthStart, today);
      final count = txns
          .where((t) =>
              t.type == 'expense' &&
              !t.isTransfer &&
              !t.isBalanceAdjustment &&
              !t.createdAt.isBefore(monthStart))
          .length;
      return 'You\'ve spent ${formatter.formatCurrency(total)} this month across $count transactions.';
    }

    // ── Top category ──
    if ((lower.contains('most') || lower.contains('top')) &&
        (lower.contains('spent') ||
            lower.contains('category') ||
            lower.contains('categor'))) {
      final Map<String, double> byCat = {};
      for (final t in txns) {
        if (t.type != 'expense' ||
            t.isTransfer ||
            t.isBalanceAdjustment ||
            t.createdAt.isBefore(monthStart)) {
          continue;
        }
        byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
      }
      if (byCat.isEmpty) return 'No expense data for this month yet.';
      final topEntry = byCat.entries.reduce((a, b) => a.value > b.value ? a : b);
      final topCat =
          categories.where((c) => c.id.toString() == topEntry.key).firstOrNull;
      final name = topCat?.name ?? 'Unknown';
      return 'Your top spending category this month is $name — ${formatter.formatCurrency(topEntry.value)}.';
    }

    // ── Income this month ──
    if (lower.contains('income') &&
        (lower.contains('month') || lower.contains('this month')) &&
        !lower.contains('last')) {
      final total = sumIncome(monthStart, today);
      return 'Your income this month is ${formatter.formatCurrency(total)}.';
    }

    // ── Savings ──
    if (lower.contains('saving') || lower.contains('saved') || lower.contains('save')) {
      final income = sumIncome(monthStart, today);
      final expense = sumExpenses(monthStart, today);
      final savings = income - expense;
      return 'This month you earned ${formatter.formatCurrency(income)} and spent ${formatter.formatCurrency(expense)}.\nNet savings: ${formatter.formatCurrency(savings.abs())}${savings < 0 ? ' (deficit)' : ''}.';
    }

    // ── Biggest expense ──
    if ((lower.contains('biggest') || lower.contains('largest')) &&
        (lower.contains('expense') || lower.contains('transaction'))) {
      final expenses = txns
          .where((t) =>
              t.type == 'expense' && !t.isTransfer && !t.isBalanceAdjustment)
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
      if (expenses.isEmpty) return 'No expenses found.';
      final top = expenses.first;
      return 'Your biggest expense is "${top.name}" — ${formatter.formatCurrency(top.amount)} on ${_fmtDate(top.createdAt)}.';
    }

    // ── Transaction count ──
    if (lower.contains('how many') && lower.contains('transaction')) {
      final count = txns.where((t) => !t.isBalanceAdjustment).length;
      return 'You have $count transactions in total.';
    }

    // ── Account-specific balance ──
    for (final a in accounts) {
      if (lower.contains(a.name.toLowerCase()) &&
          (lower.contains('balance') || lower.contains('how much'))) {
        final balance = await ref.read(accountBalanceProvider(a.id).future);
        return '${a.name} balance: ${formatter.formatCurrency(balance)}.';
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
      return 'Your total net worth across ${accounts.length} account${accounts.length == 1 ? '' : 's'} is ${formatter.formatCurrency(total)}.';
    }

    // ── Fallback ──
    return 'I can answer questions about your spending, income, balances, and categories.\n\nTry:\n• "How much have I spent this month?"\n• "What\'s my net worth?"\n• "What\'s my top category?"\n• "What\'s my biggest expense?"';
  }

  String _fmtDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    final showSuggestions =
        _messages.where((m) => m.isUser).isEmpty && !_isInitializing;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const KuberAppBar(showBack: true, title: 'Ask Kuber'),
          // Sub-header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, 0),
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
                        'Ask Kuber',
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
              ],
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
                    itemCount: _messages.length +
                        (_isProcessing ? 1 : 0),
                    itemBuilder: (context, i) {
                      // Typing indicator as last item
                      if (_isProcessing && i == _messages.length) {
                        return _TypingIndicator();
                      }
                      final msg = _messages[i];
                      // Show date separator if needed
                      final showDate = i == 0 ||
                          !_isSameDay(
                              _messages[i - 1].time, msg.time);
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
                                color: cs.primaryContainer
                                    .withValues(alpha: 0.5),
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
            padding: EdgeInsets.fromLTRB(KuberSpacing.lg, KuberSpacing.sm,
                KuberSpacing.lg, math.max(KuberSpacing.md, bottomPad)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.md),
                      border: Border.all(
                          color: cs.outline.withValues(alpha: 0.4)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.md, vertical: 10),
                    child: TextField(
                      controller: _controller,
                      enabled: !_isProcessing,
                      maxLines: 4,
                      minLines: 1,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Ask about your spending...',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.6)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                GestureDetector(
                  onTap: _isProcessing ? null : _send,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isProcessing
                          ? cs.surfaceContainerHigh
                          : cs.primary,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Icon(
                      _isProcessing
                          ? Icons.hourglass_top_rounded
                          : Icons.send_rounded,
                      size: 20,
                      color: _isProcessing
                          ? cs.onSurfaceVariant
                          : cs.onPrimary,
                    ),
                  ),
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
        Expanded(
            child:
                Divider(color: cs.outline.withValues(alpha: 0.3))),
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
        Expanded(
            child:
                Divider(color: cs.outline.withValues(alpha: 0.3))),
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
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: const BorderRadius.only(
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
                style: GoogleFonts.inter(
                    fontSize: 14, color: cs.onPrimary),
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

class _KuberBubble extends StatelessWidget {
  final KuberChatMessage message;
  const _KuberBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            child: Icon(Icons.auto_awesome_rounded,
                size: 14, color: cs.primary),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              child: Container(
                margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border:
                      Border.all(color: cs.outline.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: GoogleFonts.inter(
                          fontSize: 14, color: cs.onSurface),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('h:mm a').format(message.time),
                      style: GoogleFonts.inter(
                          fontSize: 10, color: cs.onSurfaceVariant),
                    ),
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

