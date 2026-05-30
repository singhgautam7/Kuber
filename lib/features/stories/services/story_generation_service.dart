import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../../core/utils/formatters.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../categories/data/category.dart';
import '../../dashboard/providers/insight_engine.dart';
import '../../insights/models/insight.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../data/insight_story.dart';
import '../data/story_repository.dart';
import '../models/story_models.dart';
import 'story_keys.dart';

class StoryGenerationService {
  final Isar isar;
  final AppFormatter formatter;

  StoryGenerationService(this.isar)
    : formatter = AppFormatter(system: NumberSystem.indian);

  Future<void> generateMissingNow({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final repo = StoryRepository(isar);
    final candidates = await _candidates(at);
    final existing = await repo.byKeys(
      candidates.map((s) => s.storyKey).toSet(),
    );
    final existingKeys = existing.map((s) => s.storyKey).toSet();
    final missing = candidates
        .where((story) => !existingKeys.contains(story.storyKey))
        .toList();
    await repo.putAll(missing);
    await repo.deleteExpired(at);
  }

  Future<List<InsightStory>> _candidates(DateTime now) async {
    final txns = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final loans = await isar.collection<Loan>().where().findAll();
    final ledgers = await isar.collection<Ledger>().where().findAll();
    final investments = await isar.collection<Investment>().where().findAll();

    final out = <InsightStory>[];
    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    _addRecap(
      out,
      key: StoryKeys.dailyRecap(yesterday),
      type: 'recap_day',
      label: 'Yesterday',
      start: yesterday,
      end: yesterday.add(const Duration(days: 1)),
      expiresAt: now.add(const Duration(hours: 48)),
      color: StoryColorKey.blue,
      icon: 'calendar',
      txns: txns,
      categories: categories,
      generatedAt: now,
    );

    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    _addRecap(
      out,
      key: StoryKeys.weeklyRecap(now),
      type: 'recap_week',
      label: 'This Week',
      start: weekStart,
      end: now.add(const Duration(days: 1)),
      expiresAt: now.add(const Duration(days: 7)),
      color: StoryColorKey.violet,
      icon: 'chart',
      txns: txns,
      categories: categories,
      generatedAt: now,
    );

    final monthStart = DateTime(now.year, now.month);
    _addRecap(
      out,
      key: StoryKeys.monthlyRecap(now),
      type: 'recap_month',
      label: 'This Month',
      start: monthStart,
      end: DateTime(now.year, now.month + 1),
      expiresAt: now.add(const Duration(days: 30)),
      color: StoryColorKey.amber,
      icon: 'calendar',
      txns: txns,
      categories: categories,
      generatedAt: now,
    );

    final yearStart = DateTime(now.year);
    _addRecap(
      out,
      key: StoryKeys.yearlyRecap(now),
      type: 'recap_year',
      label: 'This Year',
      start: yearStart,
      end: DateTime(now.year + 1),
      expiresAt: now.add(const Duration(days: 90)),
      color: StoryColorKey.gold,
      icon: 'trophy',
      txns: txns,
      categories: categories,
      generatedAt: now,
    );

    final engine = InsightEngine(
      allTransactions: txns,
      categories: categories,
      loans: loans,
      ledgers: ledgers,
      investments: investments,
      currencySymbol: '₹',
      formatter: formatter,
    );
    final insights = engine.generate()
        .where((i) => i.type != InsightType.fallbackTip)
        .take(5)
        .toList();
    if (insights.isNotEmpty) {
      out.add(_consolidatedInsightsStory(insights, now));
    }

    if (loans.isNotEmpty) {
      out.add(_loansStory(loans, txns, now));
    }
    if (investments.isNotEmpty) {
      out.add(_investmentsStory(investments, txns, now));
    }
    for (final ledger in ledgers.where((l) => !l.isSettled).take(3)) {
      out.add(_ledgerStory(ledger, now));
    }

    return out.where((s) => s.payloadJson != '[]').toList();
  }

  void _addRecap(
    List<InsightStory> out, {
    required String key,
    required String type,
    required String label,
    required DateTime start,
    required DateTime end,
    required DateTime expiresAt,
    required StoryColorKey color,
    required String icon,
    required List<Transaction> txns,
    required List<Category> categories,
    required DateTime generatedAt,
  }) {
    final s = _recap(
      key: key,
      type: type,
      label: label,
      start: start,
      end: end,
      expiresAt: expiresAt,
      color: color,
      icon: icon,
      txns: txns,
      categories: categories,
      generatedAt: generatedAt,
    );
    if (s != null) out.add(s);
  }

  InsightStory? _recap({
    required String key,
    required String type,
    required String label,
    required DateTime start,
    required DateTime end,
    required DateTime expiresAt,
    required StoryColorKey color,
    required String icon,
    required List<Transaction> txns,
    required List<Category> categories,
    required DateTime generatedAt,
  }) {
    final summary = txns.computeSummary(
      start: start,
      end: end,
      excludeLinkedRules: true,
    );
    if (summary.expense == 0 && summary.income == 0) return null;
    final topCategories = summary.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final catById = {for (final c in categories) c.id.toString(): c.name};
    final slides = <StorySlide>[
      StorySlide(
        variant: SlideVariant.hero,
        background: color,
        icon: icon,
        header: label,
        hero: _money(summary.expense),
        title: 'spent with ${_money(summary.income)} received',
        emphasis: const [Emphasis('spent', EmphasisStyle.bold)],
        footer:
            'Net ${summary.net >= 0 ? '+' : '-'}${_money(summary.net.abs())}',
      ),
    ];
    if (topCategories.isNotEmpty) {
      slides.add(
        StorySlide(
          variant: SlideVariant.stats,
          background: color,
          icon: 'category',
          header: label,
          title: 'Top categories',
          stats: [
            for (final entry in topCategories.take(4))
              StatItem(catById[entry.key] ?? 'Unknown', _money(entry.value)),
          ],
        ),
      );
    }
    return _story(
      key: key,
      type: type,
      generatedAt: generatedAt,
      expiresAt: expiresAt,
      slides: slides,
    );
  }

  InsightStory _consolidatedInsightsStory(
    List<KuberInsight> insights,
    DateTime now,
  ) {
    final slides = <StorySlide>[
      for (final insight in insights)
        () {
          final (color, icon) = _styleForInsight(insight.type);
          return StorySlide(
            variant: SlideVariant.statement,
            background: color,
            icon: icon,
            header: insight.typeLabel.isEmpty ? 'Highlight' : insight.typeLabel,
            title: _stripEmDash(insight.message),
            emphasis: [
              for (final h in insight.highlights)
                Emphasis(
                  h,
                  insight.highlightIsWarning
                      ? EmphasisStyle.warning
                      : EmphasisStyle.primary,
                ),
            ],
          );
        }(),
    ];
    return _story(
      key: StoryKeys.insights(now),
      type: 'insights',
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 30)),
      slides: slides,
    );
  }

  InsightStory _loansStory(List loans, List<Transaction> txns, DateTime now) {
    final emi = loans.fold<double>(0, (sum, dynamic l) => sum + l.emiAmount);
    final active = loans.where((dynamic l) => !l.isCompleted).length;
    return _story(
      key: StoryKeys.loans(now),
      type: 'loans',
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      slides: [
        StorySlide(
          variant: SlideVariant.stats,
          background: StoryColorKey.cyan,
          icon: 'loan',
          header: 'Loans',
          title: 'Loan snapshot',
          stats: [
            StatItem('Active loans', '$active'),
            StatItem('Monthly EMI total', _money(emi)),
          ],
        ),
      ],
    );
  }

  InsightStory _investmentsStory(
    List investments,
    List<Transaction> txns,
    DateTime now,
  ) {
    final invested = investments.fold<double>(
      0,
      (sum, dynamic i) => sum + ((i.investedAmount as double?) ?? 0),
    );
    final current = investments.fold<double>(
      0,
      (sum, dynamic i) =>
          sum +
          ((i.currentValue as double?) ?? (i.investedAmount as double?) ?? 0),
    );
    final delta = current - invested;
    return _story(
      key: StoryKeys.investments(now),
      type: 'investments',
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      slides: [
        StorySlide(
          variant: SlideVariant.compare,
          background: StoryColorKey.blue,
          icon: 'investment',
          header: 'Investments',
          title: 'Portfolio check',
          compare: CompareData(
            priorLabel: 'Invested',
            prior: _money(invested),
            nowLabel: 'Current value',
            now: _money(current),
            deltaIcon: delta >= 0 ? 'trending_up' : 'trending_down',
            delta: '${delta >= 0 ? '+' : '-'}${_money(delta.abs())}',
          ),
        ),
      ],
    );
  }

  InsightStory _ledgerStory(dynamic ledger, DateTime now) {
    final amount = _money(ledger.originalAmount as double);
    final isLent = ledger.type == 'lent';
    return _story(
      key: StoryKeys.ledger(ledger.uid as String),
      type: 'ledger',
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      slides: [
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.slate,
          icon: 'ledger',
          header: 'Lend / Borrow',
          title: isLent
              ? '${ledger.personName} owes you $amount'
              : 'You owe ${ledger.personName} $amount',
          subtitle: 'This entry is still open.',
          emphasis: [Emphasis(amount, EmphasisStyle.primary)],
        ),
      ],
    );
  }

  InsightStory _story({
    required String key,
    required String type,
    required DateTime generatedAt,
    required DateTime expiresAt,
    required List<StorySlide> slides,
  }) {
    return InsightStory()
      ..storyKey = key
      ..type = type
      ..generatedAt = generatedAt
      ..expiresAt = expiresAt
      ..payloadJson = jsonEncode(slides.map((s) => s.toJson()).toList());
  }

  String _money(double value) => formatter.formatCurrency(value.round());

  String _stripEmDash(String value) => value.replaceAll('\u2014', '-');

  (StoryColorKey, String) _styleForInsight(InsightType type) {
    return switch (type) {
      InsightType.savingsTrend => (StoryColorKey.emerald, 'savings'),
      InsightType.loanEmiTotal ||
      InsightType.loanPayoffCountdown ||
      InsightType.loanInterestPaid => (StoryColorKey.cyan, 'loan'),
      InsightType.ledgerOutstanding ||
      InsightType.ledgerOldestOpen => (StoryColorKey.slate, 'ledger'),
      InsightType.investmentPortfolioChange ||
      InsightType.investmentTopPerformer ||
      InsightType.investmentPeriodInvested => (
        StoryColorKey.blue,
        'investment',
      ),
      InsightType.spendingFreeStreak => (StoryColorKey.gold, 'fire'),
      InsightType.topCategory ||
      InsightType.categoryTrend ||
      InsightType.categoryConcentration => (StoryColorKey.rose, 'category'),
      _ => (StoryColorKey.violet, 'sparkle'),
    };
  }
}
