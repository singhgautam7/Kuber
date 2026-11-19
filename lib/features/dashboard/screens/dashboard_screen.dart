import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../shared/widgets/edit_widgets_button.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/utils/deep_link_handler.dart';
import '../../notifications/widgets/notifications_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../../stories/widgets/story_ring.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../charts/widgets/income_expense_home_section.dart';
import '../../pro/trial/widgets/pro_suggestion_slot.dart';
import '../../pro/trial/widgets/trial_sheet.dart';
import '../widgets/balance_hero_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_smart_insights.dart';
import '../widgets/spending_stats_card.dart';
import '../widgets/budget_snapshot_card.dart';
import '../widgets/home_accounts_card.dart';
import '../widgets/home_recent_transactions.dart';
import '../../notes/widgets/notes_home_widget.dart';
import '../../pro/home/ask_kuber_home_widget.dart';
import '../../pro/promo/home_promo_banner.dart';
import '../../upcoming_events/widgets/upcoming_events_widget.dart';
import '../widgets/quick_add_widget.dart';
import '../../home_v2/data/home_v2_state.dart';
import '../../home_v2/data/home_v2_widgets.dart' show needsTransactions;
import '../../home_v2/providers/has_transactions_provider.dart';
import '../../home_v2/providers/home_v2_gates_provider.dart';
import '../../home_v2/providers/home_v2_provider.dart';
import '../../rate/rate_prompt.dart';
import '../../home_v2/widgets/home_v2_top_slot.dart';
import '../../sms_import/widgets/sms_import_home_widget.dart';
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
    // Home v2: Data-gated widgets turn on by their triggers. The controller
    // does nothing for v1 or once no widget is waiting.
    if (ref.read(isHomeV2Provider)) ref.read(homeV2GatesProvider);
    // Rate sheet: decided after the on-open batch plus 600 ms (launches 2, 4, 8, 16).
    scheduleRatePrompt(ref, () => context);

    // Trial sheet handed over by the end of setup: once Home has painted and
    // settled, never over the last setup step.
    final trial = ref.read(pendingTrialSheetProvider);
    if (trial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(pendingTrialSheetProvider.notifier).state = null;
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) await showTrialSheet(context, trial);
      });
    }

    // Consume any cold-start notification payload now that the dashboard is
    // mounted and the router is alive.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Trace marker: story generation must start strictly after this point.
      debugPrint('Kuber stories: home first frame painted');
      // Routed by payload alone: scheduled reminders and credit-card
      // reminders have no inbox row to match.
      final payload = ref.read(pendingDeeplinkProvider);
      if (payload == null || payload.isEmpty) return;
      ref.read(pendingDeeplinkProvider.notifier).state = null;
      if (!mounted) return;
      await handleNotificationTap(ref, payload: payload);
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
        await repo.markRead(n.id);
        await handleNotificationTap(ref, payload: n.payload, type: n.type);
      },
    );
    // Mark everything read once the sheet is open / dismissed.
    await repo.markAllRead();
  }

  /// Widgets that render their own bottom spacing internally and collapse to
  /// zero height when empty (so no orphan gap remains). The dashboard must NOT
  /// add spacing around these.
  static const _selfSpacedWidgets = {
    'insight_stories',
    'spending_stats',
    'home_accounts',
    'budget_snapshot',
    'smart_insights',
    'sms_import_widget',
    'balance_hero_slot',
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
      // Trial claim / suggestion / reminder card under the balance card
      // (v7.0.0-b). Collapses to nothing outside a trial and for Pro users.
      'balance_hero_slot' => const ProSuggestionSlot(place: ProSuggestionPlace.home),
      'quick_add' => QuickAddWidget(key: TutorialStepKeys.quickAddFab),
      'spending_stats' => const RepaintBoundary(child: SpendingStatsCard()),
      'home_accounts' => const RepaintBoundary(child: HomeAccountsCard()),
      'seven_day_chart' => const IncomeExpenseHomeSection(),
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
    final isV2 = ref.watch(isHomeV2Provider);
    final hasTxns = ref.watch(hasTransactionsProvider);
    final gsEligible = ref.watch(homeV2Provider.select((s) => s.gsEligible));

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
      // Home v2 hides it while Get started is eligible (suggestion-rules §1).
      // Kept as an item either way so the top slot below never shifts index
      // (which would remount it and lose its animation state).
      if (!isV2 || !gsEligible)
        const HomePromoBanner()
      else
        const SizedBox.shrink(),
      // Home v2 top slot: Get started, or one suggestion.
      if (isV2) const HomeV2TopSlot(),
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
        // Transaction gate (specs/home-v3.3/plan.md §3): widgets that need
        // transactions are not built until the first one exists.
        final visible = configs
            .where((c) => c.enabled && (hasTxns || !needsTransactions(c.id)))
            .toList();
        return <Widget>[
          // Each widget owns its own bottom spacing (see _buildHomeWidget) so a
          // widget that self-hides in an empty state leaves no gap.
          for (final c in visible) ...[
            _buildHomeWidget(c.id),
            if (c.id == 'balance_hero') _buildHomeWidget('balance_hero_slot'),
          ],
          const EditWidgetsButton(scope: WidgetEditorScope.home),
          if (isV2) const _HomeV2WaitingLine(),
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
    // Keep the previous value while the summary reloads (every transaction
    // write): the card must stay mounted so a focused part keeps its focus.
    // Skeleton only on the very first load.
    return ref
        .watch(monthlySummaryProvider)
        .when(
          skipLoadingOnReload: true,
          loading: () => const _BalanceHeroSkeleton(),
          error: (e, _) => Center(child: Text('${context.l10n.errorLabel}: $e')),
          data: (summary) => BalanceHeroCard(summary: summary),
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
          SkeletonBlock(width: double.infinity, height: 24, borderRadius: 999),
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

/// Home v2: "N more widgets will turn on when they have something to show"
/// under Edit widgets (board HV2.7). Hidden at 0.
class _HomeV2WaitingLine extends ConsumerWidget {
  const _HomeV2WaitingLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = ref.watch(
      homeV2Provider.select(
        // Not on Home yet: waiting for data, or added by hand (Ask Kuber).
        (s) => s.widgets.values.where((w) => w.vis != WidgetVis.on).length,
      ),
    );
    if (waiting == 0) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.sm),
      child: Text(
        context.l10n.homeV2WEditMore(waiting),
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}
