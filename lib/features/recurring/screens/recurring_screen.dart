import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/info_provider.dart';
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';
import '../widgets/recurring_detail_sheet.dart';
import '../widgets/recurring_widgets.dart';

final recurringMonthlyCostProvider =
    FutureProvider<
      ({
        double net,
        double income,
        double expense,
        int activeCount,
        int pausedCount,
        List<UpcomingCharge> upcoming,
      })
    >((ref) async {
      final rules = await ref.watch(recurringListProvider.future);
      final active = rules
          .where((r) => !r.isPaused && !RecurringRepository.isExpired(r))
          .toList();
      double monthlyEquivalent(RecurringRule rule) {
        return switch (rule.frequency) {
          'daily' => rule.amount * 30,
          'weekly' => rule.amount * 4.33,
          'biweekly' => rule.amount * 2.17,
          'quarterly' => rule.amount / 3,
          'yearly' => rule.amount / 12,
          'custom' =>
            rule.customDays == null || rule.customDays == 0
                ? rule.amount
                : rule.amount * (30 / rule.customDays!),
          _ => rule.amount,
        };
      }

      final upcoming =
          active
              .map(
                (r) => UpcomingCharge(
                  name: r.name,
                  amount: r.amount,
                  on: r.nextDueAt,
                ),
              )
              .toList()
            ..sort((a, b) => a.on.compareTo(b.on));

      // Net monthly automation = recurring income - recurring expenses.
      // A positive value means net income, negative means net expense.
      final recurringIncome = active
          .where((r) => r.type == 'income')
          .fold<double>(0, (sum, r) => sum + monthlyEquivalent(r));
      final recurringExpenses = active
          .where((r) => r.type == 'expense')
          .fold<double>(0, (sum, r) => sum + monthlyEquivalent(r));
      final netAutomationCost = recurringIncome - recurringExpenses;

      return (
        net: netAutomationCost,
        income: recurringIncome,
        expense: recurringExpenses,
        activeCount: active.length,
        pausedCount: rules.where((r) => r.isPaused).length,
        upcoming: upcoming.take(3).toList(),
      );
    });

class RecurringScreen extends ConsumerStatefulWidget {
  const RecurringScreen({super.key});

  @override
  ConsumerState<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends ConsumerState<RecurringScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rulesAsync = ref.watch(recurringListProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final recentlyProcessedAsync = ref.watch(recentlyProcessedProvider);
    final accountsAsync = ref.watch(accountListProvider);

    ref.listen<AsyncValue<bool>>(
      infoSeenProvider(PrefsKeys.seenInfoRecurring),
      (prev, next) {
        if (next.hasValue && next.value == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            KuberInfoBottomSheet.show(context, InfoConstants.recurring);
            ref
                .read(infoSeenProvider(PrefsKeys.seenInfoRecurring).notifier)
                .markSeen();
          });
        }
      },
    );

    return Scaffold(
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: context.l10n.addRecurring,
        onPressed: () => context.push('/recurring/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      backgroundColor: cs.surface,
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(context.l10n.errorWithDetails(e.toString()))),
        data: (allRules) {
          final catMap = categoryMapAsync.valueOrNull ?? {};
          final accounts = accountsAsync.valueOrNull ?? [];
          // Header search: rule name or category name. While searching only
          // the matching rules show (no hero, no recently processed).
          final q = _query.trim().toLowerCase();
          final rules = q.isEmpty
              ? allRules
              : [
                  for (final r in allRules)
                    if (r.name.toLowerCase().contains(q) ||
                        (catMap[int.tryParse(r.categoryId)]?.name
                                .toLowerCase()
                                .contains(q) ??
                            false))
                      r,
                ];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: context.l10n.recurringModule,
                  infoConfig: InfoConstants.recurring,
                  search: allRules.isEmpty
                      ? null
                      : KuberHeaderSearch(
                          controller: _searchController,
                          hint: context.l10n.searchRecurringHint,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                ),
              ),

              if (rules.isEmpty && q.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.noMatches,
                    description: context.l10n.nothingMatchesQuery(
                      _query.trim(),
                    ),
                  ),
                )
              else if (rules.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.repeat_rounded,
                    title: context.l10n.noRecurring,
                    description: context.l10n.recurringEmptyDesc,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    0,
                    KuberSpace.screenMargin,
                    KuberExtendedFab.clearance,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (q.isEmpty) ...[
                        ref
                            .watch(recurringMonthlyCostProvider)
                            .when(
                              data: (summary) => RecurringHero(
                                monthlyIncome: summary.income,
                                monthlyExpense: summary.expense,
                                activeCount: summary.activeCount,
                                pausedCount: summary.pausedCount,
                              ),
                              loading: () => const SizedBox(
                                height: 180,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                        const SizedBox(height: KuberSpace.sectionGap),
                      ],
                      KuberSectionHeader(title: context.l10n.rulesUpper),
                      KuberGroup(
                        children: [
                          ...rules.map((rule) {
                            final catId = int.tryParse(rule.categoryId);
                            final cat = catId != null ? catMap[catId] : null;
                            final accountName = accounts
                                .where((a) => a.id.toString() == rule.accountId)
                                .firstOrNull
                                ?.name;
                            // Paused rules stay in the list at 50% (board 3.19).
                            return Opacity(
                              opacity: rule.isPaused ? 0.5 : 1,
                              child: RecurringRuleCard(
                                ruleName: rule.name,
                                frequencyLabel: _frequencyLabelLocalized(
                                  context,
                                  rule.frequency,
                                ),
                                accountName: accountName,
                                icon: cat != null
                                    ? IconMapper.fromString(cat.icon)
                                    : Icons.category_outlined,
                                iconColor: cat != null
                                    ? harmonizeCategory(
                                        context,
                                        Color(cat.colorValue),
                                      )
                                    : cs.primary,
                                amount: rule.type == 'expense'
                                    ? -rule.amount
                                    : rule.amount,
                                nextChargeOn: rule.nextDueAt,
                                onTap: () => showRecurringDetailSheet(
                                  context,
                                  ref,
                                  rule,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      if (q.isEmpty)
                        recentlyProcessedAsync.when(
                          data: (transactions) {
                            if (transactions.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: KuberSpace.sectionGap),
                                KuberSectionHeader(
                                  title: context.l10n.recentlyProcessed,
                                ),
                                KuberGroup(
                                  children: [
                                    ...transactions.map((t) {
                                      final catId = int.tryParse(t.categoryId);
                                      final cat = catId != null
                                          ? catMap[catId]
                                          : null;
                                      final accountName = accounts
                                          .where(
                                            (a) =>
                                                a.id.toString() == t.accountId,
                                          )
                                          .firstOrNull
                                          ?.name;
                                      return RecurringProcessedRow(
                                        ruleName: t.name,
                                        accountName: accountName,
                                        processedAt: t.createdAt,
                                        icon: cat != null
                                            ? IconMapper.fromString(cat.icon)
                                            : Icons.category_outlined,
                                        iconColor: cat != null
                                            ? harmonizeCategory(
                                                context,
                                                Color(cat.colorValue),
                                              )
                                            : cs.primary,
                                        amount: t.type == 'expense'
                                            ? -t.amount
                                            : t.amount,
                                        onTap: () => showTransactionDetailSheet(
                                          context,
                                          ref,
                                          t,
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String _frequencyLabelLocalized(BuildContext context, String frequency) {
  final l = context.l10n;
  final label = switch (frequency) {
    'daily' => l.freqDaily,
    'weekly' => l.freqWeekly,
    'biweekly' => l.freqBiweekly,
    'quarterly' => l.freqQuarterly,
    'yearly' => l.freqYearly,
    'custom' => l.freqCustom,
    _ => l.freqMonthly,
  };
  return label.toUpperCase();
}
