import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/widgets/edit_widgets_button.dart';
import '../../notifications/data/app_notification.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/utils/deep_link_handler.dart';
import '../../notifications/widgets/notifications_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../../stories/widgets/story_ring.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../charts/providers/home_income_expense_provider.dart';
import '../../charts/widgets/income_expense_chart.dart';
import '../widgets/home_header.dart';
import '../widgets/home_smart_insights.dart';
import '../widgets/spending_stats_card.dart';
import '../widgets/budget_snapshot_card.dart';
import '../widgets/home_accounts_card.dart';
import '../widgets/home_recent_transactions.dart';
import '../../notes/widgets/notes_home_widget.dart';
import '../../pro/home/ask_kuber_home_widget.dart';
import '../../pro/promo/home_promo_banner.dart';
import '../../pro/paywall/pro_state.dart';
import '../../pro/trial/trial_ending_sheet.dart';
import '../../upcoming_events/widgets/upcoming_events_widget.dart';
import '../widgets/quick_add_widget.dart';
import '../../sms_import/widgets/sms_import_home_widget.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/skeleton_loader.dart';

List<String> _homeSubtitles(AppLocalizations l10n) => [
  l10n.homeSubtitle1,
  l10n.homeSubtitle2,
  l10n.homeSubtitle3,
  l10n.homeSubtitle4,
  l10n.homeSubtitle5,
  l10n.homeSubtitle6,
  l10n.homeSubtitle7,
];

String _timeGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.greetingMorning;
  if (hour < 17) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final int _subtitleIndex;

  // Progressive reveal — the home list grows one item per frame instead of
  // inflating every above-the-fold card in the single frame that renders when
  // Home first mounts. Each card (Balance Hero, Spending Stats, …) costs
  // ~10ms to build; inflating several together produces one 20-34ms hitch (a
  // visibly dropped frame on this 90Hz display), which is the splash→home
  // jitter. Spreading to one card per frame keeps the worst frame ~12ms —
  // sub-perceptible — and the list still fills within a few hundred ms. Cards
  // whose data isn't ready fall back to their own skeletons.
  static const _kInitialReveal = 3; // header + greeting visible on frame 1
  int _revealCount = _kInitialReveal;
  int _lastItemCount = 1 << 30;
  bool _revealScheduled = false;

  void _growReveal() {
    if (_revealScheduled || _revealCount >= _lastItemCount) return;
    _revealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealScheduled = false;
      if (!mounted) return;
      setState(() => _revealCount += 1);
      _growReveal();
    });
  }

  @override
  void initState() {
    super.initState();
    _subtitleIndex = Random().nextInt(7);
    _growReveal();

    // Consume any cold-start notification payload now that the dashboard is
    // mounted and the router is alive.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Trace marker: story generation must start strictly after this point.
      debugPrint('Kuber stories: home first frame painted');
      final payload = ref.read(pendingDeeplinkProvider);
      if (payload == null || payload.isEmpty) return;
      ref.read(pendingDeeplinkProvider.notifier).state = null;
      final repo = ref.read(notificationRepositoryProvider);
      final all = await repo.list();
      AppNotification? match;
      for (final n in all) {
        if (n.payload == payload) {
          match = n;
          break;
        }
      }
      if (!mounted || match == null) return;
      await handleNotificationTap(context, ref, match);
    });

    // One-time "your Kuber Pro trial ended" notice, shown on the first frame
    // after the 14-day window closes. The Isar-backed guard
    // (shouldShowTrialEndedNotice / markTrialEndedNoticeShown) ensures it
    // fires at most once per install.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(kuberProStateProvider.notifier);
      if (notifier.shouldShowTrialEndedNotice()) {
        showTrialEndingSheet(context);
        notifier.markTrialEndedNoticeShown();
      }
    });
  }

  Future<void> _openNotificationsSheet() async {
    final repo = ref.read(notificationRepositoryProvider);
    final list = await repo.list();
    if (!mounted) return;
    await NotificationsSheet.show(
      context,
      notifications: list,
      onClearAll: () async {
        await repo.clearAll();
      },
      onTapNotification: (n) async {
        await handleNotificationTap(context, ref, n);
      },
    );
    // Mark everything read once the sheet is open / dismissed.
    await repo.markAllRead();
  }

  /// Widgets that render their own bottom spacing internally and collapse to
  /// zero height when empty (so no orphan gap remains). The dashboard must NOT
  /// add spacing around these.
  static const _selfSpacedWidgets = {
    'spending_stats',
    'home_accounts',
    'budget_snapshot',
    'smart_insights',
    'sms_import_widget',
  };

  /// Map a widget id from the catalog to its actual implementation. Hidden
  /// widgets are simply not constructed — their providers never run. Every
  /// widget carries a uniform [KuberSpace.xl] bottom gap: self-spacing
  /// widgets add it internally (and drop it when empty); the rest get it here.
  Widget _buildHomeWidget(String id) {
    final Widget? child = switch (id) {
      'balance_hero' => RepaintBoundary(
        key: TutorialStepKeys.dashboardBalanceCard,
        child: const _BalanceHeroSection(),
      ),
      'quick_add' => QuickAddWidget(key: TutorialStepKeys.quickAddFab),
      'spending_stats' => const RepaintBoundary(child: SpendingStatsCard()),
      'home_accounts' => const RepaintBoundary(child: HomeAccountsCard()),
      'seven_day_chart' => const RepaintBoundary(
        child: _SevenDayChartSection(),
      ),
      'insight_stories' => const RepaintBoundary(child: StoryRingSection()),
      'smart_insights' => const RepaintBoundary(child: HomeSmartInsights()),
      'budget_snapshot' => const RepaintBoundary(child: BudgetSnapshotCard()),
      'upcoming_events_widget' => const RepaintBoundary(
        child: UpcomingEventsWidget(),
      ),
      'kuber_notes_widget' => const RepaintBoundary(child: NotesHomeWidget()),
      'ask_kuber_widget' => const RepaintBoundary(child: AskKuberHomeWidget()),
      'recent_transactions' => const RepaintBoundary(
        child: HomeRecentTransactionsCard(),
      ),
      'sms_import_widget' => const RepaintBoundary(
        child: SmsImportHomeWidget(),
      ),
      _ => null,
    };
    if (child == null) return const SizedBox.shrink();
    if (_selfSpacedWidgets.contains(id)) return child;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(
      settingsProvider.select((async) => async.valueOrNull?.userName ?? ''),
    );
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = context.l10n;
    final widgetsAsync = ref.watch(homeWidgetsProvider);

    // Fixed leading items (header, greeting, promo) followed by the dynamic
    // widget list. We flatten everything into a single index-addressable list
    // and feed it to ListView.builder so only the items near the viewport are
    // built on mount — the previous eager `ListView(children: [...])` built
    // every home widget (Balance Hero, accounts, charts, Pro widgets, upcoming
    // events, etc.) synchronously on the first frame, which is what made the
    // splash→home transition stutter as the widget set grew.
    final leading = <Widget>[
      HomeHeader(
        unreadCount: ref.watch(unreadCountProvider).valueOrNull ?? 0,
        onTapNotifications: _openNotificationsSheet,
      ),
      // Greeting (headlineSmall) + rotating subtitle open the body, 16 above
      // the balance card (board 3.2b). Fixed, not part of the editor.
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName.isNotEmpty
                ? '${_timeGreeting(l10n)}, ${userName.toTitleCase()}'
                : _timeGreeting(l10n),
            style: textTheme.headlineSmall?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            _homeSubtitles(l10n)[_subtitleIndex],
            style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
      const SizedBox(height: KuberSpace.lg),
      // Promo campaign banner — self-hides when no promo, dismissed, or Pro.
      const HomePromoBanner(),
    ];

    final trailing = widgetsAsync.when(
      // Until the widget layout (and its data) is ready, show card-shaped
      // skeletons rather than a blank gap. On a large database the timed splash
      // can dismiss before these resolve; this covers that window.
      loading: () => <Widget>[
        for (final h in const <double>[148, 88, 120, 88])
          Padding(
            padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
            child: KuberSkeleton(
              height: h,
              borderRadius: KuberShape.largeIncreased,
            ),
          ),
      ],
      error: (_, __) => const <Widget>[],
      data: (configs) {
        final visible = configs.where((c) => c.enabled).toList();
        return <Widget>[
          // Each widget owns its own bottom spacing (see _buildHomeWidget) so a
          // widget that self-hides in an empty state leaves no gap.
          for (final c in visible) _buildHomeWidget(c.id),
          const EditWidgetsButton(scope: WidgetEditorScope.home),
        ];
      },
    );

    final items = [...leading, ...trailing];
    _lastItemCount = items.length;
    if (_revealCount < items.length) _growReveal();
    final revealed = _revealCount.clamp(0, items.length);

    // The header scrolls with the content (not pinned); it carries its own
    // edge padding, every other item gets the 20 screen margin.
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: navBarBottomPadding(context)),
        itemCount: revealed,
        itemBuilder: (context, index) => index == 0
            ? items[0]
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                child: items[index],
              ),
      ),
    );
  }
}

/// Wrapper that fetches monthly summary lazily so the underlying provider
/// only ticks when the user has the Balance Hero widget enabled.
class _BalanceHeroSection extends ConsumerWidget {
  const _BalanceHeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(monthlySummaryProvider);
    return summaryAsync.when(
      loading: () => const _BalanceHeroSkeleton(),
      error: (e, _) => Center(child: Text('${context.l10n.errorLabel}: $e')),
      data: (summary) => _BalanceHeroCard(summary: summary),
    );
  }
}

/// Wrapper that fetches the 7-day summary lazily — keeps the provider idle
/// when the chart is hidden.
class _SevenDayChartSection extends ConsumerWidget {
  const _SevenDayChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(homeChartRangeProvider);
    final points = ref.watch(homeIncomeExpenseProvider);
    // Empty only when there's no data in ANY range (fresh install); otherwise
    // keep the chart so the user can switch ranges.
    final hasData = points.any((p) => p.income > 0 || p.expense > 0);
    if (!hasData && range == HomeChartRange.months6) {
      return const _SpendingAnalysisEmpty();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberHomeWidgetTitle(title: 'Income & Expense'),
        // RepaintBoundary isolates the chart's internal fl_chart animations
        // (bar transitions, tooltip overlays) from the surrounding home-tab
        // ListView, which scrolls independently.
        RepaintBoundary(
          child: IncomeExpenseChart(
            compact: true,
            showTitle: false,
            points: points,
            rangeTabs: const [
              ChartRangeTab('days7', '7D', 'Last 7 days'),
              ChartRangeTab('weeks4', '4W', 'Last 4 weeks'),
              ChartRangeTab('months6', '6M', 'Last 6 months'),
            ],
            selectedRangeId: switch (range) {
              HomeChartRange.days7 => 'days7',
              HomeChartRange.weeks4 => 'weeks4',
              HomeChartRange.months6 => 'months6',
            },
            onRangeSelected: (id) =>
                ref.read(homeChartRangeProvider.notifier).state = switch (id) {
                  'days7' => HomeChartRange.days7,
                  'weeks4' => HomeChartRange.weeks4,
                  _ => HomeChartRange.months6,
                },
          ),
        ),
      ],
    );
  }
}

/// Skeleton mirroring the Balance Hero card shape so the first paint doesn't
/// flash a spinner while [monthlySummaryProvider] resolves.
class _BalanceHeroSkeleton extends StatelessWidget {
  const _BalanceHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(width: 120, height: 12, borderRadius: 999),
          SizedBox(height: 10),
          SkeletonBlock(width: 160, height: 28, borderRadius: 999),
          SizedBox(height: KuberSpace.lg),
          SkeletonBlock(width: double.infinity, height: 8, borderRadius: 999),
          SizedBox(height: KuberSpace.md),
          Row(
            children: [
              SkeletonBlock(width: 72, height: 12, borderRadius: 999),
              Spacer(),
              SkeletonBlock(width: 72, height: 12, borderRadius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceHeroCard extends ConsumerWidget {
  final MonthlySummary summary;

  const _BalanceHeroCard({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final symbol = ref.watch(currencyProvider).symbol;
    final isPositive = summary.net >= 0;
    final prefix = isPositive ? '+' : '-';
    final formattedNet = formatter
        .formatCurrency(summary.net.abs(), symbol: symbol)
        .trim();
    final formattedIncome = isPrivate
        ? maskAmount('', true)
        : '+${formatter.formatCurrency(summary.totalIncome, symbol: symbol).trim()}';
    final formattedExpense = isPrivate
        ? maskAmount('', true)
        : '-${formatter.formatCurrency(summary.totalExpense, symbol: symbol).trim()}';

    final total = summary.totalIncome + summary.totalExpense;
    final incPct = total > 0 ? summary.totalIncome / total : 0.5;

    final monthLabel = DateFormat('MMMM').format(DateTime.now()).toUpperCase();

    final theme = Theme.of(context);
    // Income in primary, expense in a 40% primary tint (user review round 2);
    // the signs on the legend carry the direction instead of green / red.
    final incomeColor = cs.primary;
    final expenseColor = Color.alphaBlend(
      cs.primary.withValues(alpha: 0.4),
      cs.surfaceContainer,
    );
    final legendStyle = theme.textTheme.titleSmall!.copyWith(
      color: cs.onSurface,
    );
    Widget dot(Color c) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    // Hero card (stat-cards 2l / board 3.2a): caps label, headlineMedium net,
    // 8 split bar with a 4 gap, titleSmall legend.
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$monthLabel · ${context.l10n.netLabel}',
            style: theme.textTheme.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: KuberSpace.xs),
          Text(
            isPrivate ? '****' : '$prefix$formattedNet',
            style: theme.textTheme.headlineMedium!.copyWith(
              color: isPrivate
                  ? cs.onSurface
                  : (total == 0 ? cs.onSurfaceVariant : cs.onSurface),
            ),
          ),
          const SizedBox(height: KuberSpace.lg),

          // Proportional income/expense ratio bar
          if (total == 0)
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: KuberShape.fullR,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  flex: (incPct * 1000).round(),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: incomeColor,
                      borderRadius: KuberShape.fullR,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: ((1 - incPct) * 1000).round().clamp(1, 1000),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: expenseColor,
                      borderRadius: KuberShape.fullR,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: KuberSpace.md),

          // Income / Expense legend
          Row(
            children: [
              dot(incomeColor),
              const SizedBox(width: KuberSpace.sm),
              Text(formattedIncome, style: legendStyle),
              const Spacer(),
              Text(formattedExpense, style: legendStyle),
              const SizedBox(width: KuberSpace.sm),
              dot(expenseColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpendingAnalysisEmpty extends StatelessWidget {
  const _SpendingAnalysisEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KuberHomeWidgetTitle(title: 'Income & Expense'),
        KuberCard(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KuberSpace.lg),
            child: Text(
              context.l10n.spendingAnalysisEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
