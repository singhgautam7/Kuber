import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
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
import 'story_date_label.dart';
import 'story_keys.dart';
import 'story_ttl.dart';

/// Cadence windows for the non-recap, non-pace bubbles. A story of the same
/// entity is not regenerated until its window has elapsed (expired tombstones
/// inside the window still suppress regeneration).
const _loanCadence = Duration(days: 20);
const _ledgerCadence = Duration(days: 20);
const _investmentCadence = Duration(days: 10);
const _insightCadence = Duration(days: 10);

class StoryGenerationService {
  final Isar isar;

  StoryGenerationService(this.isar);

  /// Generates every story that is due right now (recaps on period rollover,
  /// pace comparisons once per day, entity bubbles within their cadence). The
  /// heavy work runs on a background isolate; this method only does cheap Isar
  /// reads/writes on the main isolate.
  Future<void> generateDue({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final repo = StoryRepository(isar);

    // Load raw data + existing-story metadata on the main isolate (an Isar
    // instance cannot cross an isolate boundary), then build + gate candidates
    // on a background isolate so the InsightEngine, recap summaries, and JSON
    // encoding never touch the UI thread.
    final existing = await repo.all();
    final meta = <String, ExistingStoryMeta>{
      for (final s in existing)
        s.storyKey: ExistingStoryMeta(
          id: s.id,
          type: s.type,
          generatedAt: s.generatedAt,
          seenAt: s.seenAt,
          seenSlides: List<int>.from(s.seenSlides),
        ),
    };
    DateTime? lastInvestmentsAt;
    for (final s in existing) {
      if (s.type == 'investments') {
        if (lastInvestmentsAt == null ||
            s.generatedAt.isAfter(lastInvestmentsAt)) {
          lastInvestmentsAt = s.generatedAt;
        }
      }
    }

    final input = _StoryGenInput(
      txns: await isar.transactions.where().findAll(),
      categories: await isar.categorys.where().findAll(),
      loans: await isar.collection<Loan>().where().findAll(),
      ledgers: await isar.collection<Ledger>().where().findAll(),
      investments: await isar.collection<Investment>().where().findAll(),
      now: at,
      existingMeta: meta,
      lastInvestmentsAt: lastInvestmentsAt,
    );

    final resolved = await compute(_buildStoryCandidates, input);
    await repo.putAll(resolved);
    await repo.deleteOlderThan(at.subtract(kStoryTombstoneRetention));
  }
}

/// Sendable bundle for the background isolate. None of these entities carry
/// `IsarLink`s, so they copy across the isolate boundary cleanly.
class _StoryGenInput {
  final List<Transaction> txns;
  final List<Category> categories;
  final List<Loan> loans;
  final List<Ledger> ledgers;
  final List<Investment> investments;
  final DateTime now;
  final Map<String, ExistingStoryMeta> existingMeta;
  final DateTime? lastInvestmentsAt;

  const _StoryGenInput({
    required this.txns,
    required this.categories,
    required this.loans,
    required this.ledgers,
    required this.investments,
    required this.now,
    required this.existingMeta,
    required this.lastInvestmentsAt,
  });
}

/// Lightweight, sendable snapshot of a row that already exists, used by the
/// isolate to decide insert / update-in-place / skip without re-querying Isar.
class ExistingStoryMeta {
  final int id;
  final String type;
  final DateTime generatedAt;
  final DateTime? seenAt;
  final List<int> seenSlides;

  const ExistingStoryMeta({
    required this.id,
    required this.type,
    required this.generatedAt,
    required this.seenAt,
    required this.seenSlides,
  });
}

/// Isolate entry point invoked via [compute].
List<InsightStory> _buildStoryCandidates(_StoryGenInput input) {
  return _StoryCandidateBuilder(
    AppFormatter(system: NumberSystem.indian),
  ).build(input);
}

class _StoryCandidateBuilder {
  final AppFormatter formatter;

  _StoryCandidateBuilder(this.formatter);

  late Map<String, ExistingStoryMeta> _meta;
  final _out = <InsightStory>[];

  List<InsightStory> build(_StoryGenInput input) {
    _meta = input.existingMeta;
    _out.clear();

    final now = input.now;
    final txns = input.txns;
    final categories = input.categories;
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));
    final yesterday = startOfToday.subtract(const Duration(days: 1));

    // ── Recaps ─────────────────────────────────────────────────────────
    // Daily is about the just-completed day (a fresh row each day). Weekly,
    // monthly, and yearly are period-to-date and refresh in place once per day
    // (stable key, so they are always present without duplicating).
    _dailyRecap(txns, categories, now, yesterday, startOfToday);
    _weeklyRecap(txns, categories, now, startOfToday, startOfTomorrow);
    _monthlyRecap(txns, categories, now, startOfToday, startOfTomorrow);
    _yearlyRecap(txns, categories, now, startOfToday, startOfTomorrow);

    // ── Pace comparisons (once per day, update-in-place) ───────────────
    _dailyPace(txns, now, startOfToday, startOfTomorrow);
    _weeklyPace(txns, now, startOfToday, startOfTomorrow);
    _monthlyPace(txns, now, startOfToday, startOfTomorrow);

    // ── Entity bubbles (cadence-gated) ─────────────────────────────────
    _loanStories(input.loans, now);
    _ledgerStories(input.ledgers, now);
    _investmentStory(input.investments, now, input.lastInvestmentsAt);
    _insightStories(input, now);

    return _out;
  }

  // ── Persistence gates ────────────────────────────────────────────────

  /// Recap / one-off insert: only if the key does not already exist.
  void _insertIfNew(String key, InsightStory Function() build) {
    if (_meta.containsKey(key)) return;
    final story = build()..storyKey = key;
    if (story.payloadJson == '[]') return;
    _out.add(story);
  }

  /// Once-per-day upsert for period-to-date recaps and pace comparisons: insert,
  /// or update in place if a row from a previous day exists. Preserves seenAt +
  /// seenSlides; refreshes payload/generatedAt/expiry so the bubble stays present
  /// for the whole period without duplicating.
  void _upsertDaily(String key, DateTime startOfToday, InsightStory? Function() build) {
    final existing = _meta[key];
    if (existing != null && existing.generatedAt.isAfter(startOfToday)) {
      return; // already refreshed today
    }
    final story = build();
    if (story == null || story.payloadJson == '[]') return;
    story.storyKey = key;
    if (existing != null) {
      story.id = existing.id;
      story.seenAt = existing.seenAt;
      story.seenSlides = existing.seenSlides;
    }
    _out.add(story);
  }

  /// Entity bubble: skip while inside the cadence window; otherwise insert, or
  /// overwrite a stale tombstone (resetting seen so the fresh story resurfaces).
  void _upsertEntity(
    String key,
    DateTime now,
    Duration window,
    InsightStory? Function() build,
  ) {
    final existing = _meta[key];
    if (existing != null &&
        now.difference(existing.generatedAt) < window) {
      return; // still inside the cadence window
    }
    final story = build();
    if (story == null || story.payloadJson == '[]') return;
    story.storyKey = key;
    if (existing != null) story.id = existing.id; // overwrite stale tombstone
    _out.add(story);
  }

  // ── Recap builders ───────────────────────────────────────────────────

  void _dailyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
    DateTime yesterday,
    DateTime end,
  ) {
    _insertIfNew(StoryKeys.dailyRecap(yesterday), () {
      final summary = _summary(txns, yesterday, end);
      final slides = <StorySlide>[];
      final label = formatBubblePeriod(BubblePeriodKind.daily, start: yesterday);

      if (summary.expense > 0 || summary.income > 0) {
        slides.add(
          StorySlide(
            variant: SlideVariant.hero,
            background: StoryColorKey.blue,
            icon: 'calendar',
            header: 'Daily',
            dateLabel: label,
            hero: _money(summary.expense),
            title: 'spent yesterday',
            emphasis: const [Emphasis('spent', EmphasisStyle.bold)],
            footer: _avgComparisonFooter(txns, yesterday, summary.expense),
          ),
        );
      }
      final top = _topTransaction(txns, yesterday, end, categories);
      if (top != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.blue,
            icon: 'wallet',
            header: 'Daily',
            dateLabel: label,
            title: 'Top spend: ${top.$2} on ${top.$1}',
            emphasis: [Emphasis(top.$2, EmphasisStyle.primary)],
          ),
        );
      }
      final cat = _topCategory(summary, categories);
      if (cat != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.blue,
            icon: 'category',
            header: 'Daily',
            dateLabel: label,
            title: 'Top categories',
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      final streak = _streakSlide(txns, yesterday, StoryColorKey.blue, label);
      if (streak != null) slides.add(streak);

      return _story('recap_day', now, slides, periodStart: yesterday, periodEnd: end);
    });
  }

  void _weeklyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    final start = startOfToday.subtract(Duration(days: now.weekday - 1)); // Mon
    final end = startOfTomorrow; // this week through today
    final daysElapsed = now.weekday;
    _upsertDaily(StoryKeys.weeklyRecap(now), startOfToday, () {
      final summary = _summary(txns, start, end);
      if (summary.expense == 0 && summary.income == 0) return null;
      // Pace-matched comparison to the same point last week.
      final prior = _summary(
        txns,
        start.subtract(const Duration(days: 7)),
        end.subtract(const Duration(days: 7)),
      );
      final label = formatBubblePeriod(
        BubblePeriodKind.weekly,
        start: start,
        end: startOfToday,
      );
      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.violet,
          icon: 'chart',
          header: 'Weekly',
          dateLabel: label,
          hero: _money(summary.expense),
          title: 'spent this week',
          emphasis: const [Emphasis('spent', EmphasisStyle.bold)],
          footer: _deltaFooter('last week', summary.expense, prior.expense),
        ),
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.violet,
          icon: 'calendar',
          header: 'Weekly',
          dateLabel: label,
          title: 'About ${_money(summary.expense / daysElapsed)} a day on average',
          emphasis: [
            Emphasis(_money(summary.expense / daysElapsed), EmphasisStyle.primary),
          ],
        ),
      ];
      final biggest = _biggestDay(txns, start, end);
      if (biggest != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.violet,
            icon: 'trending_up',
            header: 'Weekly',
            dateLabel: label,
            title: '${biggest.$1} was your biggest day at ${biggest.$2}',
            emphasis: [Emphasis(biggest.$2, EmphasisStyle.primary)],
          ),
        );
      }
      if (_topCategory(summary, categories) != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.violet,
            icon: 'category',
            header: 'Weekly',
            dateLabel: label,
            title: 'Top categories',
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      if (summary.income > 0) {
        slides.add(
          StorySlide(
            variant: SlideVariant.compare,
            background: StoryColorKey.violet,
            icon: 'savings',
            header: 'Weekly',
            dateLabel: label,
            title: 'Income and expenses compared',
            compare: CompareData(
              priorLabel: 'Income',
              prior: _money(summary.income),
              nowLabel: 'Expenses',
              now: _money(summary.expense),
              deltaIcon: summary.net >= 0 ? 'trending_up' : 'trending_down',
              delta:
                  'NET: ${summary.net >= 0 ? '+' : '-'}${_money(summary.net.abs())}',
            ),
          ),
        );
      }
      return _story('recap_week', now, slides, periodStart: start, periodEnd: end);
    });
  }

  void _monthlyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    final start = DateTime(now.year, now.month, 1);
    final end = startOfTomorrow; // this month through today
    final daysElapsed = now.day;
    _upsertDaily(StoryKeys.monthlyRecap(now), startOfToday, () {
      final summary = _summary(txns, start, end);
      if (summary.expense == 0 && summary.income == 0) return null;
      // Pace-matched comparison to the same day last month.
      final prior = _summary(
        txns,
        DateTime(now.year, now.month - 1, 1),
        DateTime(now.year, now.month - 1, now.day).add(const Duration(days: 1)),
      );
      final label = formatBubblePeriod(BubblePeriodKind.monthly, start: start);
      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.amber,
          icon: 'calendar',
          header: 'Monthly',
          dateLabel: label,
          hero: _money(summary.expense),
          title: 'spent this month',
          emphasis: const [Emphasis('spent', EmphasisStyle.bold)],
          footer: _deltaFooter('last month', summary.expense, prior.expense),
        ),
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.amber,
          icon: 'calendar',
          header: 'Monthly',
          dateLabel: label,
          title: 'About ${_money(summary.expense / daysElapsed)} a day on average',
          emphasis: [
            Emphasis(_money(summary.expense / daysElapsed), EmphasisStyle.primary),
          ],
        ),
      ];
      if (_topCategory(summary, categories) != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.amber,
            icon: 'category',
            header: 'Monthly',
            dateLabel: label,
            title: 'Top categories',
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      final top = _topTransaction(txns, start, end, categories);
      if (top != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.amber,
            icon: 'wallet',
            header: 'Monthly',
            dateLabel: label,
            title: 'Biggest single spend was ${top.$2} on ${top.$1}',
            emphasis: [Emphasis(top.$2, EmphasisStyle.primary)],
          ),
        );
      }
      if (summary.income > 0) {
        final rate = ((summary.income - summary.expense) / summary.income * 100)
            .round();
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.amber,
            icon: 'savings',
            header: 'Monthly',
            dateLabel: label,
            title: 'You saved $rate% of what you earned',
            emphasis: [Emphasis('$rate%', EmphasisStyle.primary)],
          ),
        );
      }
      return _story('recap_month', now, slides, periodStart: start, periodEnd: end);
    });
  }

  void _yearlyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    final start = DateTime(now.year, 1, 1);
    final end = startOfTomorrow; // year through today
    final monthsElapsed = now.month;
    _upsertDaily(StoryKeys.yearlyRecap(now), startOfToday, () {
      final summary = _summary(txns, start, end);
      if (summary.expense == 0 && summary.income == 0) return null;
      final label = formatBubblePeriod(BubblePeriodKind.yearlyYtd, start: now);
      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.gold,
          icon: 'trophy',
          header: 'Yearly',
          dateLabel: label,
          hero: _money(summary.expense),
          title: 'spent this year',
          emphasis: const [Emphasis('spent', EmphasisStyle.bold)],
        ),
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.gold,
          icon: 'calendar',
          header: 'Yearly',
          dateLabel: label,
          title: 'About ${_money(summary.expense / monthsElapsed)} a month on average',
          emphasis: [
            Emphasis(_money(summary.expense / monthsElapsed), EmphasisStyle.primary),
          ],
        ),
      ];
      final highest = _highestMonth(txns, now.year, monthsElapsed);
      if (highest != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.gold,
            icon: 'trending_up',
            header: 'Yearly',
            dateLabel: label,
            title: '${highest.$1} was your highest month at ${highest.$2}',
            emphasis: [Emphasis(highest.$2, EmphasisStyle.primary)],
          ),
        );
      }
      if (_topCategory(summary, categories) != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.gold,
            icon: 'category',
            header: 'Yearly',
            dateLabel: label,
            title: 'Top categories',
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      final projection = summary.expense / monthsElapsed * 12;
      slides.add(
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.gold,
          icon: 'target',
          header: 'Yearly',
          dateLabel: label,
          title: 'At this pace you will spend about ${_money(projection)} this year',
          emphasis: [Emphasis(_money(projection), EmphasisStyle.primary)],
        ),
      );
      return _story('recap_year', now, slides, periodStart: start, periodEnd: end);
    });
  }

  // ── Pace comparison builders ─────────────────────────────────────────

  void _dailyPace(
    List<Transaction> txns,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    _upsertDaily(StoryKeys.compareDay(now), startOfToday, () {
      final today = _spend(txns, startOfToday, startOfTomorrow);
      // 30-day daily average (trailing, excluding today).
      final trailing = _spend(
        txns,
        startOfToday.subtract(const Duration(days: 30)),
        startOfToday,
      );
      final avg = trailing / 30;
      if (today == 0 || avg == 0) return null;
      return _paceStory(
        type: 'recap_day',
        now: now,
        color: StoryColorKey.blue,
        icon: 'calendar',
        header: 'TODAY VS AVG',
        priorLabel: '30 day avg',
        prior: avg,
        nowLabel: 'Today',
        current: today,
      );
    });
  }

  void _weeklyPace(
    List<Transaction> txns,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    final thisWeekStart = startOfToday.subtract(Duration(days: now.weekday - 1));
    _upsertDaily(StoryKeys.compareWeek(now), startOfToday, () {
      final current = _spend(txns, thisWeekStart, startOfTomorrow);
      final prior = _spend(
        txns,
        thisWeekStart.subtract(const Duration(days: 7)),
        startOfTomorrow.subtract(const Duration(days: 7)),
      );
      if (current == 0 || prior == 0) return null;
      return _paceStory(
        type: 'recap_week',
        now: now,
        color: StoryColorKey.violet,
        icon: 'chart',
        header: 'THIS WEEK VS LAST',
        priorLabel: 'Last week',
        prior: prior,
        nowLabel: 'This week',
        current: current,
      );
    });
  }

  void _monthlyPace(
    List<Transaction> txns,
    DateTime now,
    DateTime startOfToday,
    DateTime startOfTomorrow,
  ) {
    final thisMonthStart = DateTime(now.year, now.month, 1);
    _upsertDaily(StoryKeys.compareMonth(now), startOfToday, () {
      final current = _spend(txns, thisMonthStart, startOfTomorrow);
      // Prior month through the same day-of-month (pace-matched).
      final priorStart = DateTime(now.year, now.month - 1, 1);
      final priorEndExcl =
          DateTime(now.year, now.month - 1, now.day).add(const Duration(days: 1));
      final prior = _spend(txns, priorStart, priorEndExcl);
      if (current == 0 || prior == 0) return null;
      return _paceStory(
        type: 'recap_month',
        now: now,
        color: StoryColorKey.amber,
        icon: 'calendar',
        header: 'THIS MONTH VS LAST',
        priorLabel: 'Last month',
        prior: prior,
        nowLabel: 'This month',
        current: current,
      );
    });
  }

  InsightStory _paceStory({
    required String type,
    required DateTime now,
    required StoryColorKey color,
    required String icon,
    required String header,
    required String priorLabel,
    required double prior,
    required String nowLabel,
    required double current,
  }) {
    final pct = (current - prior) / prior * 100;
    final String title;
    if (pct < -5) {
      title = 'You slowed down';
    } else if (pct > 5) {
      title = 'You sped up';
    } else {
      title = 'Roughly on the same pace';
    }
    final diff = current - prior;
    final less = diff < 0;
    final delta = '${_money(diff.abs())} ${less ? 'less' : 'more'}';
    final slide = StorySlide(
      variant: SlideVariant.compare,
      background: color,
      icon: icon,
      header: header,
      title: title,
      compare: CompareData(
        priorLabel: priorLabel,
        prior: _money(prior),
        nowLabel: nowLabel,
        now: _money(current),
        deltaIcon: less ? 'trending_down' : 'trending_up',
        delta: delta,
      ),
    );
    return _story(type, now, [slide]);
  }

  // ── Entity builders ──────────────────────────────────────────────────

  void _loanStories(List<Loan> loans, DateTime now) {
    for (final loan in loans.where((l) => !l.isCompleted)) {
      _upsertEntity(StoryKeys.loanEntity(loan.uid), now, _loanCadence, () {
        final label = formatBubblePeriod(
          BubblePeriodKind.loan,
          start: now,
          entityName: loan.name,
        );
        return _story('loans', now, [
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.cyan,
            icon: 'loan',
            header: 'Loans',
            dateLabel: label,
            title: loan.name,
            stats: [
              StatItem('Monthly EMI', _money(loan.emiAmount)),
              StatItem('Principal', _money(loan.principalAmount)),
              if (loan.lenderName.isNotEmpty)
                StatItem('Lender', loan.lenderName),
            ],
          ),
        ]);
      });
    }
  }

  void _ledgerStories(List<Ledger> ledgers, DateTime now) {
    for (final ledger in ledgers.where((l) => !l.isSettled)) {
      _upsertEntity(StoryKeys.ledger(ledger.uid), now, _ledgerCadence, () {
        final amount = _money(ledger.originalAmount);
        final isLent = ledger.type == 'lent';
        final label = formatBubblePeriod(
          BubblePeriodKind.ledger,
          start: now,
          entityName: ledger.personName,
        );
        return _story('ledger', now, [
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.slate,
            icon: 'ledger',
            header: 'Lend / Borrow',
            dateLabel: label,
            title: isLent
                ? '${ledger.personName} owes you $amount'
                : 'You owe ${ledger.personName} $amount',
            subtitle: 'This entry is still open.',
            emphasis: [Emphasis(amount, EmphasisStyle.primary)],
          ),
        ]);
      });
    }
  }

  void _investmentStory(
    List<Investment> investments,
    DateTime now,
    DateTime? lastInvestmentsAt,
  ) {
    if (investments.isEmpty) return;
    if (lastInvestmentsAt != null &&
        now.difference(lastInvestmentsAt) < _investmentCadence) {
      return;
    }
    final key = StoryKeys.investments(now);
    if (_meta.containsKey(key)) return; // already have this period's row
    final invested = investments.fold<double>(
      0,
      (sum, i) => sum + (i.investedAmount ?? 0),
    );
    final current = investments.fold<double>(
      0,
      (sum, i) => sum + (i.currentValue ?? i.investedAmount ?? 0),
    );
    final delta = current - invested;
    final story = _story('investments', now, [
      StorySlide(
        variant: SlideVariant.compare,
        background: StoryColorKey.blue,
        icon: 'investment',
        header: 'Investments',
        dateLabel: formatBubblePeriod(
          BubblePeriodKind.investments,
          sourcePeriod: 'This week',
        ),
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
    ])..storyKey = key;
    if (story.payloadJson != '[]') _out.add(story);
  }

  void _insightStories(_StoryGenInput input, DateTime now) {
    final engine = InsightEngine(
      allTransactions: input.txns,
      categories: input.categories,
      loans: input.loans,
      ledgers: input.ledgers,
      investments: input.investments,
      currencySymbol: '₹',
      formatter: formatter,
    );
    final insights = engine.generate().where(
      (i) =>
          i.type != InsightType.fallbackTip &&
          i.type != InsightType.fallbackTotal,
    );
    for (final insight in insights) {
      _upsertEntity(
        StoryKeys.insightSubtype(insight.type.name),
        now,
        _insightCadence,
        () {
          final (color, icon) = _styleForInsight(insight.type);
          return _story('insights', now, [
            StorySlide(
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
            ),
          ]);
        },
      );
    }
  }

  // ── Aggregation helpers (reuse computeSummary) ───────────────────────

  /// Full-cashflow summary for recaps (matches the Home/History totals).
  SummaryResult _summary(List<Transaction> txns, DateTime start, DateTime end) =>
      txns.computeSummary(start: start, end: end, excludeLinkedRules: false);

  /// Discretionary spend for pace comparisons (matches the insight engine's
  /// `_monthComparison` / `_spendingHighToday`).
  double _spend(List<Transaction> txns, DateTime start, DateTime end) => txns
      .computeSummary(start: start, end: end, excludeLinkedRules: true)
      .expense;

  String? _avgComparisonFooter(
    List<Transaction> txns,
    DateTime day,
    double spent,
  ) {
    final trailing = _summary(
      txns,
      day.subtract(const Duration(days: 30)),
      day,
    ).expense;
    final avg = trailing / 30;
    if (avg == 0) return null;
    final diff = spent - avg;
    return diff >= 0
        ? '${_money(diff)} above your 30 day average'
        : '${_money(diff.abs())} below your 30 day average';
  }

  String? _deltaFooter(String label, double current, double prior) {
    if (prior == 0) return null;
    final diff = current - prior;
    return diff <= 0
        ? '${_money(diff.abs())} less than $label'
        : '${_money(diff)} more than $label';
  }

  /// (categoryName, amountString) of the biggest single expense in range.
  (String, String)? _topTransaction(
    List<Transaction> txns,
    DateTime start,
    DateTime end,
    List<Category> categories,
  ) {
    Transaction? top;
    for (final t in txns) {
      if (t.type != 'expense' || t.isTransfer || t.isBalanceAdjustment) continue;
      if (t.linkedRuleType != null) continue;
      if (t.createdAt.isBefore(start) || !t.createdAt.isBefore(end)) continue;
      if (top == null || t.amount > top.amount) top = t;
    }
    if (top == null) return null;
    final catById = {for (final c in categories) c.id.toString(): c.name};
    return (catById[top.categoryId] ?? 'Uncategorized', _money(top.amount));
  }

  /// (categoryName, percentOfSpend) of the top spending category.
  (String, int)? _topCategory(SummaryResult summary, List<Category> categories) {
    if (summary.spendingByCategory.isEmpty || summary.expense == 0) return null;
    final entries = summary.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.first;
    final catById = {for (final c in categories) c.id.toString(): c.name};
    final pct = (top.value / summary.expense * 100).round();
    return (catById[top.key] ?? 'Uncategorized', pct);
  }

  List<StatItem> _categoryStats(
    SummaryResult summary,
    List<Category> categories,
  ) {
    final entries = summary.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final catById = {for (final c in categories) c.id.toString(): c.name};
    return [
      for (final e in entries.take(4))
        StatItem(catById[e.key] ?? 'Uncategorized', _money(e.value)),
    ];
  }

  /// (dayLabel, amountString) of the highest-spend day in [start, end).
  (String, String)? _biggestDay(
    List<Transaction> txns,
    DateTime start,
    DateTime end,
  ) {
    final totals = <DateTime, double>{};
    for (final t in txns) {
      if (t.type != 'expense' || t.isTransfer || t.isBalanceAdjustment) continue;
      if (t.createdAt.isBefore(start) || !t.createdAt.isBefore(end)) continue;
      final d = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      totals[d] = (totals[d] ?? 0) + t.amount;
    }
    if (totals.isEmpty) return null;
    final best = totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return (weekdays[best.key.weekday - 1], _money(best.value));
  }

  /// (monthLabel, amountString) of the highest-spend month in the given year,
  /// considering only the first [monthsToCheck] months.
  (String, String)? _highestMonth(
    List<Transaction> txns,
    int year,
    int monthsToCheck,
  ) {
    var bestMonth = 0;
    var bestTotal = -1.0;
    for (var m = 1; m <= monthsToCheck; m++) {
      final total = _summary(
        txns,
        DateTime(year, m, 1),
        DateTime(year, m + 1, 1),
      ).expense;
      if (total > bestTotal) {
        bestTotal = total;
        bestMonth = m;
      }
    }
    if (bestMonth == 0 || bestTotal <= 0) return null;
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return (months[bestMonth - 1], _money(bestTotal));
  }

  /// No-spend streak slide for the daily recap, or null when not relevant.
  StorySlide? _streakSlide(
    List<Transaction> txns,
    DateTime yesterday,
    StoryColorKey color,
    String? label,
  ) {
    // Only meaningful for users with recent spending activity — a brand-new or
    // dormant user should not get a "no spend day" celebration.
    final trailing = _spend(
      txns,
      yesterday.subtract(const Duration(days: 30)),
      yesterday.add(const Duration(days: 1)),
    );
    if (trailing == 0) return null;

    bool spentOn(DateTime day) =>
        _spend(txns, day, day.add(const Duration(days: 1))) > 0;

    if (!spentOn(yesterday)) {
      // Count the no-spend streak ending yesterday (inclusive).
      var streak = 0;
      var day = yesterday;
      while (streak < 60 && !spentOn(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      }
      return StorySlide(
        variant: SlideVariant.statement,
        background: color,
        icon: 'fire',
        header: 'Daily',
        dateLabel: label,
        title: streak == 1
            ? 'A no spend day. Nice.'
            : 'That is a $streak day no spend streak',
        emphasis: [Emphasis('$streak day', EmphasisStyle.primary)],
      );
    }

    // Yesterday had spend: did it end a real, bounded no-spend streak? Only
    // report it if there is genuine prior spending within ~30 days, otherwise
    // the count is just "no data yet" rather than a streak.
    var prior = 0;
    var day = yesterday.subtract(const Duration(days: 1));
    var foundPriorSpend = false;
    for (var i = 0; i < 30; i++) {
      if (spentOn(day)) {
        foundPriorSpend = true;
        break;
      }
      prior++;
      day = day.subtract(const Duration(days: 1));
    }
    if (foundPriorSpend && prior >= 2) {
      return StorySlide(
        variant: SlideVariant.statement,
        background: color,
        icon: 'warning',
        header: 'Daily',
        dateLabel: label,
        title: 'Your $prior day no spend streak ended',
        emphasis: [Emphasis('$prior day', EmphasisStyle.warning)],
      );
    }
    return null;
  }

  // ── Common ───────────────────────────────────────────────────────────

  InsightStory _story(
    String type,
    DateTime now,
    List<StorySlide> slides, {
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    final payload = jsonEncode(slides.map((s) => s.toJson()).toList());
    return InsightStory()
      ..type = type
      ..generatedAt = now
      ..expiresAt = now.add(kStoryTtl)
      ..periodStart = periodStart
      ..periodEnd = periodEnd
      ..contentHash = _stableHash(slides.map((s) => s.title).join('|'))
      ..payloadJson = payload;
  }

  String _money(double value) => formatter.formatCurrency(value.round());

  String _stripEmDash(String value) => value.replaceAll('—', '-');

  /// Deterministic FNV-1a hash. Safety field only (cadence/storyKey gate dedup),
  /// so a non-crypto hash is fine and avoids a new package.
  String _stableHash(String s) {
    var hash = 0x811c9dc5;
    for (final c in s.codeUnits) {
      hash ^= c;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

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
