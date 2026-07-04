import 'package:kuber/core/utils/locale_font.dart';
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
import '../../upcoming_events/widgets/upcoming_events_widget.dart';
import '../widgets/quick_add_widget.dart';
import '../../sms_import/widgets/sms_import_home_widget.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

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

  @override
  void initState() {
    super.initState();
    _subtitleIndex = Random().nextInt(7);

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

  /// Map a widget id from the catalog to its actual implementation. Hidden
  /// widgets are simply not constructed — their providers never run.
  Widget _buildHomeWidget(String id) {
    switch (id) {
      case 'balance_hero':
        return RepaintBoundary(
          key: TutorialStepKeys.dashboardBalanceCard,
          child: const _BalanceHeroSection(),
        );
      case 'quick_add':
        return QuickAddWidget(key: TutorialStepKeys.quickAddFab);
      case 'spending_stats':
        return const RepaintBoundary(child: SpendingStatsCard());
      case 'home_accounts':
        return const RepaintBoundary(child: HomeAccountsCard());
      case 'seven_day_chart':
        return const RepaintBoundary(child: _SevenDayChartSection());
      case 'insight_stories':
        return const RepaintBoundary(child: StoryRingSection());
      case 'smart_insights':
        return const RepaintBoundary(child: HomeSmartInsights());
      case 'budget_snapshot':
        return const RepaintBoundary(child: BudgetSnapshotCard());
      case 'upcoming_events_widget':
        return const RepaintBoundary(child: UpcomingEventsWidget());
      case 'kuber_notes_widget':
        return const RepaintBoundary(child: NotesHomeWidget());
      case 'recent_transactions':
        return const RepaintBoundary(child: HomeRecentTransactionsCard());
      case 'sms_import_widget':
        return const RepaintBoundary(child: SmsImportHomeWidget());
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(
      settingsProvider.select((async) => async.valueOrNull?.userName ?? ''),
    );
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final widgetsAsync = ref.watch(homeWidgetsProvider);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: navBarBottomPadding(context),
        ),
        children: [
          HomeHeader(
            unreadCount: ref.watch(unreadCountProvider).valueOrNull ?? 0,
            onTapNotifications: _openNotificationsSheet,
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Greeting — fixed, not part of the editor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName.isNotEmpty
                    ? '${_timeGreeting(l10n)}, ${userName.toTitleCase()}'
                    : _timeGreeting(l10n),
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: KuberSpacing.xs),
              Text(
                _homeSubtitles(l10n)[_subtitleIndex],
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Dynamic widget list — order + enabled comes from Isar via the
          // widget editor. Disabled widgets are not constructed at all, so
          // their providers don't run.
          ...widgetsAsync.when(
            loading: () => const <Widget>[],
            error: (_, __) => const <Widget>[],
            data: (configs) {
              final visible = configs.where((c) => c.enabled).toList();
              return [
                for (final c in visible) ...[
                  _buildHomeWidget(c.id),
                  const SizedBox(height: KuberSpacing.xl),
                ],
                const EditWidgetsButton(scope: WidgetEditorScope.home),
              ];
            },
          ),
        ],
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
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
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
    return IncomeExpenseChart(
      compact: true,
      points: points,
      rangeTabs: const [
        ChartRangeTab('days7', '7D'),
        ChartRangeTab('weeks4', '4W'),
        ChartRangeTab('months6', '6M'),
      ],
      selectedRangeId: switch (range) {
        HomeChartRange.days7 => 'days7',
        HomeChartRange.weeks4 => 'weeks4',
        HomeChartRange.months6 => 'months6',
      },
      onRangeSelected: (id) => ref.read(homeChartRangeProvider.notifier).state =
          switch (id) {
        'days7' => HomeChartRange.days7,
        'weeks4' => HomeChartRange.weeks4,
        _ => HomeChartRange.months6,
      },
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
    final netColor = isPositive ? cs.tertiary : cs.error;
    final prefix = isPositive ? '+' : '-';
    final formattedNet = formatter
        .formatCurrency(summary.net.abs(), symbol: symbol)
        .trim();
    final formattedIncome = maskAmount(
      formatter.formatCurrency(summary.totalIncome, symbol: symbol),
      isPrivate,
    );
    final formattedExpense = maskAmount(
      formatter.formatCurrency(summary.totalExpense, symbol: symbol),
      isPrivate,
    );

    final total = summary.totalIncome + summary.totalExpense;
    final incPct = total > 0 ? summary.totalIncome / total : 0.5;

    final monthLabel = DateFormat('MMMM').format(DateTime.now()).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: month label + net amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$monthLabel · ${context.l10n.netLabel}',
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              isPrivate
                  ? Text(
                      '****',
                      style: localeFont(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.6,
                      ),
                    )
                  : Text(
                      '$prefix$formattedNet',
                      style: localeFont(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: netColor,
                        letterSpacing: -0.6,
                      ),
                    ),
            ],
          ),

          const SizedBox(height: KuberSpacing.md),

          // Proportional income/expense ratio bar
          if (total == 0)
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(3),
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
                      color: cs.tertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  flex: ((1 - incPct) * 1000).round().clamp(1, 1000),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: cs.error,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: KuberSpacing.sm + 2),

          // Income / Expense legend
          Row(
            children: [
              // Income: dot + amount
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Text(
                formattedIncome,
                style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              // Expense: amount + dot
              Text(
                formattedExpense,
                style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: cs.error,
                  shape: BoxShape.circle,
                ),
              ),
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberHomeWidgetTitle(title: 'Income & Expense'),
          const SizedBox(height: 24),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              child: Text(
                context.l10n.spendingAnalysisEmpty,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}