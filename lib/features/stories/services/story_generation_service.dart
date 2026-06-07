import 'dart:convert';

import 'package:flutter/material.dart' show Locale;
import 'package:flutter/foundation.dart' show compute;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/locale_font.dart';
import '../../../l10n/app_localizations.dart';
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
      locale: AppLocale.current,
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
  final Locale locale;

  const _StoryGenInput({
    required this.txns,
    required this.categories,
    required this.loans,
    required this.ledgers,
    required this.investments,
    required this.now,
    required this.existingMeta,
    required this.lastInvestmentsAt,
    required this.locale,
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
Future<List<InsightStory>> _buildStoryCandidates(_StoryGenInput input) async {
  AppLocale.current = input.locale;
  Intl.defaultLocale = input.locale.languageCode;
  // Date symbol data is per-isolate; load the active locale so DateFormat in
  // story_date_label can render localized month/day names without throwing.
  await initializeDateFormatting(input.locale.languageCode);
  return _StoryCandidateBuilder(
    AppFormatter(system: NumberSystem.indian),
  ).build(input);
}

class _StoryCandidateBuilder {
  final AppFormatter formatter;

  _StoryCandidateBuilder(this.formatter);

  String _getSpentWord(String languageCode) {
    return switch (languageCode) {
      'hi' || 'mr' => 'खर्च',
      'pa' => 'ਖਰਚ',
      'bn' => 'খরচ',
      _ => 'spent',
    };
  }

  late Map<String, ExistingStoryMeta> _meta;
  final _out = <InsightStory>[];

  List<InsightStory> build(_StoryGenInput input) {
    _meta = input.existingMeta;
    _out.clear();

    final now = input.now;
    final txns = input.txns;
    final categories = input.categories;
    final startOfToday = DateTime(now.year, now.month, now.day);
    final yesterday = startOfToday.subtract(const Duration(days: 1));

    // ── Recaps: highlights of the just-completed period ───────────────
    // Each is generated ONCE per period (keyed by that period), so it appears
    // when the period completes and then expires 48h later (no daily refresh).
    // Key-based dedup also means it catches up if the user opens a few days late.
    _dailyRecap(txns, categories, now, yesterday, startOfToday);
    _weeklyRecap(txns, categories, now, startOfToday);
    _monthlyRecap(txns, categories, now);
    _yearlyRecap(txns, categories, now);

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
      final l10n = lookupAppLocalizations(AppLocale.current);

      if (summary.expense > 0 || summary.income > 0) {
        final emphasisText = _getSpentWord(AppLocale.current.languageCode);
        slides.add(
          StorySlide(
            variant: SlideVariant.hero,
            background: StoryColorKey.blue,
            icon: 'calendar',
            header: l10n.dailyRecapHeader,
            dateLabel: label,
            hero: _money(summary.expense),
            title: l10n.spentYesterday,
            emphasis: [Emphasis(emphasisText, EmphasisStyle.bold)],
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
            header: l10n.dailyRecapHeader,
            dateLabel: label,
            title: l10n.topSpend(top.$2, top.$1),
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
            header: l10n.dailyRecapHeader,
            dateLabel: label,
            title: l10n.topCategories,
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
  ) {
    // The just-completed week (last Mon..Sun) and the week before it.
    final thisWeekStart = startOfToday.subtract(Duration(days: now.weekday - 1));
    final lastStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastEnd = thisWeekStart; // exclusive
    final lastSun = lastEnd.subtract(const Duration(days: 1));
    final beforeStart = lastStart.subtract(const Duration(days: 7));
    final beforeSun = lastStart.subtract(const Duration(days: 1));

    _insertIfNew(StoryKeys.weeklyRecap(lastStart), () {
      final summary = _summary(txns, lastStart, lastEnd);
      if (summary.expense == 0 && summary.income == 0) {
        return _story('recap_week', now, const []);
      }
      final before = _summary(txns, beforeStart, lastStart);
      final label = formatBubblePeriod(
        BubblePeriodKind.weekly,
        start: lastStart,
        end: lastSun,
      );
      final l10n = lookupAppLocalizations(AppLocale.current);
      final emphasisText = _getSpentWord(AppLocale.current.languageCode);

      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.violet,
          icon: 'chart',
          header: l10n.weeklyRecapHeader,
          dateLabel: label,
          hero: _money(summary.expense),
          title: l10n.spentLastWeek,
          emphasis: [Emphasis(emphasisText, EmphasisStyle.bold)],
          footer: _deltaFooter(l10n.theWeekBefore, summary.expense, before.expense),
        ),
      ];
      if (before.expense > 0) {
        slides.add(
          _comparisonSlide(
            color: StoryColorKey.violet,
            nowLabel: '${l10n.thisWeek} (${_shortRange(lastStart, lastSun)})',
            nowAmount: summary.expense,
            priorLabel: '${l10n.previousWeek} (${_shortRange(beforeStart, beforeSun)})',
            priorAmount: before.expense,
          ),
        );
      }
      slides.add(
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.violet,
          icon: 'calendar',
          header: l10n.weeklyRecapHeader,
          dateLabel: label,
          title: l10n.averageDay(_money(summary.expense / 7)),
          emphasis: [Emphasis(_money(summary.expense / 7), EmphasisStyle.primary)],
        ),
      );
      final biggest = _biggestDay(txns, lastStart, lastEnd);
      if (biggest != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.violet,
            icon: 'trending_up',
            header: l10n.weeklyRecapHeader,
            dateLabel: label,
            title: l10n.biggestDay(biggest.$1, biggest.$2),
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
            header: l10n.weeklyRecapHeader,
            dateLabel: label,
            title: l10n.topCategories,
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      return _story(
        'recap_week',
        now,
        slides,
        periodStart: lastStart,
        periodEnd: lastEnd,
      );
    });
  }

  void _monthlyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
  ) {
    // The just-completed month and the month before it.
    final lastStart = DateTime(now.year, now.month - 1, 1);
    final lastEnd = DateTime(now.year, now.month, 1); // exclusive
    final beforeStart = DateTime(now.year, now.month - 2, 1);
    final daysInLast = lastEnd.difference(lastStart).inDays;
    final lastName = DateFormat('MMMM').format(lastStart);
    final beforeName = DateFormat('MMMM').format(beforeStart);

    _insertIfNew(StoryKeys.monthlyRecap(lastStart), () {
      final summary = _summary(txns, lastStart, lastEnd);
      if (summary.expense == 0 && summary.income == 0) {
        return _story('recap_month', now, const []);
      }
      final before = _summary(txns, beforeStart, lastStart);
      final label = formatBubblePeriod(BubblePeriodKind.monthly, start: lastStart);
      final l10n = lookupAppLocalizations(AppLocale.current);
      final emphasisText = _getSpentWord(AppLocale.current.languageCode);

      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.amber,
          icon: 'calendar',
          header: l10n.monthlyRecapHeader,
          dateLabel: label,
          hero: _money(summary.expense),
          title: l10n.spentLastMonth(lastName),
          emphasis: [Emphasis(emphasisText, EmphasisStyle.bold)],
          footer: _deltaFooter(beforeName, summary.expense, before.expense),
        ),
      ];
      if (before.expense > 0) {
        slides.add(
          _comparisonSlide(
            color: StoryColorKey.amber,
            nowLabel: '${l10n.thisMonth} ($lastName)',
            nowAmount: summary.expense,
            priorLabel: '${l10n.previousMonth} ($beforeName)',
            priorAmount: before.expense,
          ),
        );
      }
      slides.add(
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.amber,
          icon: 'calendar',
          header: l10n.monthlyRecapHeader,
          dateLabel: label,
          title: l10n.averageDay(_money(summary.expense / daysInLast)),
          emphasis: [
            Emphasis(_money(summary.expense / daysInLast), EmphasisStyle.primary),
          ],
        ),
      );
      if (_topCategory(summary, categories) != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.amber,
            icon: 'category',
            header: l10n.monthlyRecapHeader,
            dateLabel: label,
            title: l10n.topCategories,
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      final top = _topTransaction(txns, lastStart, lastEnd, categories);
      if (top != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.amber,
            icon: 'wallet',
            header: l10n.monthlyRecapHeader,
            dateLabel: label,
            title: l10n.biggestSingleSpend(top.$2, top.$1),
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
            header: l10n.monthlyRecapHeader,
            dateLabel: label,
            title: l10n.savedEarned(rate.toString()),
            emphasis: [Emphasis('$rate%', EmphasisStyle.primary)],
          ),
        );
      }
      return _story(
        'recap_month',
        now,
        slides,
        periodStart: lastStart,
        periodEnd: lastEnd,
      );
    });
  }

  void _yearlyRecap(
    List<Transaction> txns,
    List<Category> categories,
    DateTime now,
  ) {
    // The just-completed year and the year before it.
    final lastYear = now.year - 1;
    final start = DateTime(lastYear, 1, 1);
    final end = DateTime(now.year, 1, 1); // exclusive
    final beforeStart = DateTime(lastYear - 1, 1, 1);

    _insertIfNew(StoryKeys.yearlyRecap(start), () {
      final summary = _summary(txns, start, end);
      if (summary.expense == 0 && summary.income == 0) {
        return _story('recap_year', now, const []);
      }
      final before = _summary(txns, beforeStart, start);
      final label = formatBubblePeriod(BubblePeriodKind.yearlyFull, start: start);
      final l10n = lookupAppLocalizations(AppLocale.current);
      final emphasisText = _getSpentWord(AppLocale.current.languageCode);

      final slides = <StorySlide>[
        StorySlide(
          variant: SlideVariant.hero,
          background: StoryColorKey.gold,
          icon: 'trophy',
          header: l10n.yearlyRecapHeader,
          dateLabel: label,
          hero: _money(summary.expense),
          title: l10n.spentLastYear(lastYear.toString()),
          emphasis: [Emphasis(emphasisText, EmphasisStyle.bold)],
          footer: _deltaFooter('${lastYear - 1}', summary.expense, before.expense),
        ),
      ];
      if (before.expense > 0) {
        slides.add(
          _comparisonSlide(
            color: StoryColorKey.gold,
            nowLabel: '${l10n.thisYear} ($lastYear)',
            nowAmount: summary.expense,
            priorLabel: '${l10n.previousYear} (${lastYear - 1})',
            priorAmount: before.expense,
          ),
        );
      }
      slides.add(
        StorySlide(
          variant: SlideVariant.statement,
          background: StoryColorKey.gold,
          icon: 'calendar',
          header: l10n.yearlyRecapHeader,
          dateLabel: label,
          title: l10n.averageMonth(_money(summary.expense / 12)),
          emphasis: [Emphasis(_money(summary.expense / 12), EmphasisStyle.primary)],
        ),
      );
      final highest = _highestMonth(txns, lastYear, 12);
      if (highest != null) {
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.gold,
            icon: 'trending_up',
            header: l10n.yearlyRecapHeader,
            dateLabel: label,
            title: l10n.biggestMonth(highest.$1, highest.$2),
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
            header: l10n.yearlyRecapHeader,
            dateLabel: label,
            title: l10n.topCategories,
            stats: _categoryStats(summary, categories),
          ),
        );
      }
      if (summary.income > 0) {
        final rate = ((summary.income - summary.expense) / summary.income * 100)
            .round();
        slides.add(
          StorySlide(
            variant: SlideVariant.statement,
            background: StoryColorKey.gold,
            icon: 'savings',
            header: l10n.yearlyRecapHeader,
            dateLabel: label,
            title: l10n.savedEarned(rate.toString()),
            emphasis: [Emphasis('$rate%', EmphasisStyle.primary)],
          ),
        );
      }
      return _story('recap_year', now, slides, periodStart: start, periodEnd: end);
    });
  }

  /// A two-cell comparison slide (prior vs now) with a delta chip. Used by the
  /// weekly/monthly/yearly recaps to compare the period with the one before it.
  StorySlide _comparisonSlide({
    required StoryColorKey color,
    required String nowLabel,
    required double nowAmount,
    required String priorLabel,
    required double priorAmount,
  }) {
    final less = nowAmount < priorAmount;
    final diff = (nowAmount - priorAmount).abs();
    final l10n = lookupAppLocalizations(AppLocale.current);
    return StorySlide(
      variant: SlideVariant.compare,
      background: color,
      icon: less ? 'trending_down' : 'trending_up',
      header: l10n.comparedTitle,
      title: less ? l10n.comparedLess : l10n.comparedMore,
      compare: CompareData(
        priorLabel: priorLabel,
        prior: _money(priorAmount),
        nowLabel: nowLabel,
        now: _money(nowAmount),
        deltaIcon: less ? 'trending_down' : 'trending_up',
        delta: '${_money(diff)} ${less ? l10n.lessLabel : l10n.moreLabel}',
      ),
    );
  }

  /// Compact single-line date range: "25 to 31 May" (same month) or
  /// "28 Apr to 4 May" (spanning months). ASCII, uses "to".
  String _shortRange(DateTime start, DateTime endInclusive) {
    final sameMonth =
        start.month == endInclusive.month && start.year == endInclusive.year;
    final l10n = lookupAppLocalizations(AppLocale.current);
    if (sameMonth) {
      return '${start.day} ${l10n.toLabel} ${endInclusive.day} '
          '${DateFormat('MMM').format(endInclusive)}';
    }
    return '${DateFormat('d MMM').format(start)} ${l10n.toLabel} '
        '${DateFormat('d MMM').format(endInclusive)}';
  }

  // ── Entity builders ──────────────────────────────────────────────────

  void _loanStories(List<Loan> loans, DateTime now) {
    // One consolidated Loans story with a slide per active loan (so the ring/
    // archive show a single Loans bubble, not one per loan).
    final active = loans.where((l) => !l.isCompleted).take(6).toList();
    if (active.isEmpty) return;
    _upsertEntity(StoryKeys.loans, now, _loanCadence, () {
      final l10n = lookupAppLocalizations(AppLocale.current);
      final slides = [
        for (final loan in active)
          StorySlide(
            variant: SlideVariant.stats,
            background: StoryColorKey.cyan,
            icon: 'loan',
            header: l10n.loansHeader,
            title: loan.name,
            stats: [
              StatItem(l10n.monthlyEmi, _money(loan.emiAmount)),
              StatItem(l10n.principal, _money(loan.principalAmount)),
              if (loan.lenderName.isNotEmpty)
                StatItem(l10n.lender, loan.lenderName),
            ],
          ),
      ];
      return _story('loans', now, slides);
    });
  }

  void _ledgerStories(List<Ledger> ledgers, DateTime now) {
    // One consolidated Lend / Borrow story with a slide per open entry.
    final open = ledgers.where((l) => !l.isSettled).take(6).toList();
    if (open.isEmpty) return;
    _upsertEntity(StoryKeys.ledger, now, _ledgerCadence, () {
      final l10n = lookupAppLocalizations(AppLocale.current);
      final slides = [
        for (final ledger in open)
          () {
            final amount = _money(ledger.originalAmount);
            final isLent = ledger.type == 'lent';
            return StorySlide(
              variant: SlideVariant.statement,
              background: StoryColorKey.slate,
              icon: 'ledger',
              header: l10n.ledgerHeader,
              title: isLent
                  ? l10n.ledgerOwesYou(ledger.personName, amount)
                  : l10n.ledgerYouOwe(ledger.personName, amount),
              subtitle: l10n.ledgerEntryOpen,
              emphasis: [Emphasis(amount, EmphasisStyle.primary)],
            );
          }(),
      ];
      return _story('ledger', now, slides);
    });
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
    final l10n = lookupAppLocalizations(AppLocale.current);
    final story = _story('investments', now, [
      StorySlide(
        variant: SlideVariant.compare,
        background: StoryColorKey.blue,
        icon: 'investment',
        header: l10n.investmentsHeader,
        dateLabel: formatBubblePeriod(
          BubblePeriodKind.investments,
          sourcePeriod: l10n.thisWeek,
        ),
        title: l10n.portfolioCheck,
        compare: CompareData(
          priorLabel: l10n.investedLabel,
          prior: _money(invested),
          nowLabel: l10n.currentValueLabel,
          now: _money(current),
          deltaIcon: delta >= 0 ? 'trending_up' : 'trending_down',
          delta: '${delta >= 0 ? '+' : '-'}${_money(delta.abs())}',
        ),
      ),
    ])..storyKey = key;
    if (story.payloadJson != '[]') _out.add(story);
  }

  void _insightStories(_StoryGenInput input, DateTime now) {
    // One consolidated Insights story with a slide per insight, cadence-gated as
    // a whole — so the ring shows a single Insights bubble and the archive a
    // single Insights card (not one card per insight).
    _upsertEntity(StoryKeys.insights, now, _insightCadence, () {
      final engine = InsightEngine(
        allTransactions: input.txns,
        categories: input.categories,
        loans: input.loans,
        ledgers: input.ledgers,
        investments: input.investments,
        currencySymbol: '₹',
        formatter: formatter,
      );
      final insights = engine
          .generate()
          .where(
            (i) =>
                i.type != InsightType.fallbackTip &&
                i.type != InsightType.fallbackTotal,
          )
          .take(6)
          .toList();
      if (insights.isEmpty) return null;

      final l10n = lookupAppLocalizations(AppLocale.current);
      final slides = [
        for (final insight in insights)
          () {
            final (color, icon) = _styleForInsight(insight.type);
            return StorySlide(
              variant: SlideVariant.statement,
              background: color,
              icon: icon,
              header: insight.typeLabel.isEmpty
                  ? l10n.highlightHeader
                  : insight.typeLabel,
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
      return _story('insights', now, slides);
    });
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
    final l10n = lookupAppLocalizations(AppLocale.current);
    return diff >= 0
        ? l10n.aboveAverage(_money(diff))
        : l10n.belowAverage(_money(diff.abs()));
  }

  String? _deltaFooter(String label, double current, double prior) {
    if (prior == 0) return null;
    final diff = current - prior;
    final l10n = lookupAppLocalizations(AppLocale.current);
    return diff <= 0
        ? l10n.deltaLess(_money(diff.abs()), label)
        : l10n.deltaMore(_money(diff), label);
  }

  /// (transactionName, amountString) of the biggest single expense in range.
  /// Falls back to the category name when the transaction has no name.
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
    final l10n = lookupAppLocalizations(AppLocale.current);
    final catById = {for (final c in categories) c.id.toString(): c.name};
    final name = top.name.trim().isNotEmpty
        ? top.name.trim()
        : (catById[top.categoryId] ?? l10n.uncategorized);
    return (name, _money(top.amount));
  }

  /// (categoryName, percentOfSpend) of the top spending category.
  (String, int)? _topCategory(SummaryResult summary, List<Category> categories) {
    if (summary.spendingByCategory.isEmpty || summary.expense == 0) return null;
    final entries = summary.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.first;
    final l10n = lookupAppLocalizations(AppLocale.current);
    final catById = {for (final c in categories) c.id.toString(): c.name};
    final pct = (top.value / summary.expense * 100).round();
    return (catById[top.key] ?? l10n.uncategorized, pct);
  }

  List<StatItem> _categoryStats(
    SummaryResult summary,
    List<Category> categories,
  ) {
    final entries = summary.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final l10n = lookupAppLocalizations(AppLocale.current);
    final catById = {for (final c in categories) c.id.toString(): c.name};
    return [
      for (final e in entries.take(4))
        StatItem(catById[e.key] ?? l10n.uncategorized, _money(e.value)),
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
    return (DateFormat('EEEE').format(best.key), _money(best.value));
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
    return (
      DateFormat('MMMM').format(DateTime(year, bestMonth, 1)),
      _money(bestTotal),
    );
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

    final l10n = lookupAppLocalizations(AppLocale.current);

    if (!spentOn(yesterday)) {
      // Count the no-spend streak ending yesterday (inclusive).
      var streak = 0;
      var day = yesterday;
      while (streak < 60 && !spentOn(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      }
      final emphasisText = switch (AppLocale.current.languageCode) {
        'hi' || 'bn' => '$streak दिन',
        'pa' => '$streak ਦਿਨ',
        'mr' => '$streak दिवस',
        _ => '$streak day',
      };
      return StorySlide(
        variant: SlideVariant.statement,
        background: color,
        icon: 'fire',
        header: l10n.dailyRecapHeader,
        dateLabel: label,
        title: streak == 1
            ? l10n.noSpendDay
            : l10n.noSpendStreak(streak.toString()),
        emphasis: [Emphasis(emphasisText, EmphasisStyle.primary)],
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
      final emphasisText = switch (AppLocale.current.languageCode) {
        'hi' || 'bn' => '$prior दिन',
        'pa' => '$prior ਦਿਨ',
        'mr' => '$prior दिवस',
        _ => '$prior day',
      };
      return StorySlide(
        variant: SlideVariant.statement,
        background: color,
        icon: 'warning',
        header: l10n.dailyRecapHeader,
        dateLabel: label,
        title: l10n.noSpendStreakEnded(prior.toString()),
        emphasis: [Emphasis(emphasisText, EmphasisStyle.warning)],
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
