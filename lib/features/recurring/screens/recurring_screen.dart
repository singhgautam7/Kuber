// Recurring (design R.1): the hub for everything that repeats. Monthly
// summary, Active (rules + linked EMIs and SIPs), Paused, Recently processed
// (History rows), Ended (collapsed).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../settings/providers/info_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/widgets/transaction_row.dart';
import '../providers/recurring_hub_provider.dart';
import '../widgets/hub_row_tile.dart';

class RecurringScreen extends ConsumerStatefulWidget {
  /// 'processed' scrolls to Recently processed (background-task result).
  final String? focus;
  const RecurringScreen({super.key, this.focus});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  final _search = TextEditingController();
  final _processedKey = GlobalKey();
  String _query = '';
  bool _endedOpen = false;
  bool _focused = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _maybeFocus() {
    if (_focused || widget.focus != 'processed') return;
    _focused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _processedKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final hubAsync = ref.watch(recurringHubProvider);

    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoRecurring),
        (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.recurring);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoRecurring).notifier).markSeen();
        });
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: l.msRecFab,
        onPressed: () => context.push('/recurring/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      body: hubAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.errorWithDetails('$e'))),
        data: (hub) {
          _maybeFocus();
          final q = _query.trim().toLowerCase();
          bool match(HubRow r) => q.isEmpty || r.name.toLowerCase().contains(q);
          final active = hub.active.where(match).toList();
          final paused = hub.paused.where(match).toList();
          final ended = hub.ended.where(match).toList();
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: KuberAppBar(
                showBack: true,
                title: l.recurringModule,
                infoConfig: InfoConstants.recurring,
                search: hub.isEmpty
                    ? null
                    : KuberHeaderSearch(
                        controller: _search,
                        hint: l.searchRecurringHint,
                        onChanged: (v) => setState(() => _query = v),
                      ),
              ),
            ),
            if (hub.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: KuberEmptyState(
                  icon: Icons.repeat_rounded,
                  title: l.msRecEmptyTitle,
                  description: l.msRecEmptyBody,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 0,
                    KuberSpace.screenMargin, KuberExtendedFab.clearance),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (q.isEmpty) _MonthlySummary(hub: hub),
                    if (active.isNotEmpty) ...[
                      _header(l.msRecActive, active.length),
                      KuberGroup(children: [for (final r in active) HubRowTile(row: r)]),
                    ],
                    if (paused.isNotEmpty) ...[
                      _header(l.msRecPaused, paused.length),
                      KuberGroup(children: [for (final r in paused) HubRowTile(row: r)]),
                    ],
                    if (q.isEmpty && hub.processed.isNotEmpty) ...[
                      KeyedSubtree(key: _processedKey, child: _header(l.msRecProcessed, null)),
                      _Processed(hub: hub),
                      const SizedBox(height: 12),
                      AppButton(
                        label: l.msRecViewHistory,
                        type: AppButtonType.outline,
                        fullWidth: true,
                        onPressed: () {
                          final f = ref.read(historyFilterProvider.notifier);
                          if (ref.read(historyFilterProvider).isRecurring != true) {
                            f.toggleRecurring();
                          }
                          context.go('/history');
                        },
                      ),
                    ],
                    if (ended.isNotEmpty) ...[
                      const SizedBox(height: KuberSpace.sectionGap),
                      _EndedHeader(
                        count: ended.length,
                        open: _endedOpen,
                        onTap: () => setState(() => _endedOpen = !_endedOpen),
                      ),
                      if (_endedOpen) ...[
                        const SizedBox(height: 8),
                        KuberGroup(children: [for (final r in ended) HubRowTile(row: r)]),
                      ],
                    ],
                  ]),
                ),
              ),
          ]);
        },
      ),
    );
  }

  Widget _header(String title, int? count) => Padding(
        padding: const EdgeInsets.only(top: KuberSpace.sectionGap),
        child: KuberSectionHeader(
          title: title,
          trailing: count == null
              ? null
              : Text('$count',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

class _MonthlySummary extends ConsumerWidget {
  final RecurringHub hub;
  const _MonthlySummary({required this.hub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final parts = [
      (l.msRecBills, hub.bills, cs.primary),
      (l.msRecEmis, hub.emis, interestColor(context)),
      (l.msRecSips, hub.sips, money.income),
    ];
    final total = hub.out;
    Widget line(String label, double v, Color c, {bool outlined = false}) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: outlined ? null : c,
                border: outlined ? Border.all(color: c, width: 1.5) : null,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: tt.bodyMedium)),
            Text(fmt.formatCurrency(v.round()),
                style: tt.titleSmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          ]),
        );
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Text(l.msRecEveryMonth.toUpperCase(),
                style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
            KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.monthly)),
          ]),
          const SizedBox(height: 4),
          Wrap(crossAxisAlignment: WrapCrossAlignment.end, spacing: 6, runSpacing: 4, children: [
            Text(fmt.formatCurrency(total.round()), style: tt.headlineMedium),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(l.msRecOut, style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
            ),
            const SizedBox(width: 12),
            Text(fmt.formatCurrency(hub.income.round()),
                style: tt.headlineSmall!.copyWith(color: money.income)),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(l.msRecIn, style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant)),
            ),
          ]),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: KuberShape.fullR,
              child: SizedBox(
                height: 12,
                child: Row(children: [
                  for (final (i, p) in parts.indexed)
                    if (p.$2 > 0) ...[
                      if (i > 0 && parts.take(i).any((x) => x.$2 > 0)) const SizedBox(width: 2),
                      Expanded(
                          flex: (p.$2 / total * 1000).round().clamp(1, 1000),
                          child: Container(color: p.$3)),
                    ],
                ]),
              ),
            ),
          ],
          const SizedBox(height: 4),
          for (final p in parts) line(p.$1, p.$2, p.$3),
          line(l.msRecIncome, hub.income, money.income, outlined: true),
        ],
      ),
    );
  }
}

class _Processed extends ConsumerWidget {
  final RecurringHub hub;
  const _Processed({required this.hub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryMapProvider).valueOrNull ?? const {};
    final accounts = ref.watch(accountMapProvider).valueOrNull ?? const {};
    return TransactionDayCard(
      transactions: hub.processed,
      onTap: (t) => showTransactionDetailSheet(context, ref, t),
      onEdit: (t) => context.push('/add-transaction', extra: t),
      onDelete: (t) => deleteTransactionWithUndo(context, ref, t),
      formatter: ref.watch(formatterProvider),
      categoryMap: cats,
      accountMap: accounts,
    );
  }
}

class _EndedHeader extends StatelessWidget {
  final int count;
  final bool open;
  final VoidCallback onTap;
  const _EndedHeader({required this.count, required this.open, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return KuberCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(children: [
          Expanded(child: Text(context.l10n.msRecEnded, style: tt.titleSmall)),
          Text('$count', style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(width: 8),
          Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}
