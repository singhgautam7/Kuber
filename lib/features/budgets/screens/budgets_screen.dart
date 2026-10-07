import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../categories/providers/category_provider.dart';
import '../data/budget.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_details_sheet.dart';
import '../../../core/constants/info_constants.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../settings/providers/info_provider.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetListProvider);
    // Header search matches the budget's category name.
    final q = _query.trim().toLowerCase();
    final categoryNames = {
      for (final c in ref.watch(categoryListProvider).valueOrNull ?? const [])
        c.id.toString(): c.name.toLowerCase(),
    };
    final cs = Theme.of(context).colorScheme;

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoBudgets), (
      prev,
      next,
    ) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.budgets);
          ref
              .read(infoSeenProvider(PrefsKeys.seenInfoBudgets).notifier)
              .markSeen();
        });
      }
    });

    return Scaffold(
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: context.l10n.createBudget,
        onPressed: () => context.push('/budgets/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: KuberAppBar(
              showBack: true,
              title: context.l10n.budgetsTitle,
              infoConfig: InfoConstants.budgets,
              search: (budgetsAsync.valueOrNull?.isEmpty ?? true)
                  ? null
                  : KuberHeaderSearch(
                      controller: _searchController,
                      hint: context.l10n.searchBudgetsHint,
                      onChanged: (v) => setState(() => _query = v),
                    ),
            ),
          ),

          // Page header
          budgetsAsync.when(
            data: (all) {
              final budgets = q.isEmpty
                  ? all
                  : [
                      for (final b in all)
                        if ((categoryNames[b.categoryId] ?? '').contains(q)) b,
                    ];
              if (budgets.isEmpty && q.isNotEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.noMatches,
                    description: context.l10n.nothingMatchesQuery(
                      _query.trim(),
                    ),
                  ),
                );
              }
              if (budgets.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.account_balance_rounded,
                    title: context.l10n.noBudgetsYet,
                    description: context.l10n.createBudgetsDesc,
                  ),
                );
              }

              // Board 3.18: active budgets, then paused / ended, each one
              // grouped list of rows.
              bool inactive(Budget b) =>
                  !b.isActive ||
                  (!b.isRecurring &&
                      b.endDate != null &&
                      b.endDate!.isBefore(DateTime.now()));
              final active = budgets.where((b) => !inactive(b)).toList();
              final ended = budgets.where(inactive).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (active.isNotEmpty) ...[
                        KuberSectionHeader(title: context.l10n.thisMonth),
                        KuberGroup(
                          children: [
                            for (final b in active) BudgetCard(budget: b),
                          ],
                        ),
                      ],
                      if (ended.isNotEmpty) ...[
                        if (active.isNotEmpty)
                          const SizedBox(height: KuberSpace.sectionGap),
                        KuberSectionHeader(title: context.l10n.pausedAndEnded),
                        KuberGroup(
                          children: [
                            for (final b in ended) BudgetCard(budget: b),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) =>
                SliverFillRemaining(child: Center(child: Text('Error: $err'))),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: KuberExtendedFab.clearance),
          ),
        ],
      ),
    );
  }
}

class BudgetCard extends ConsumerWidget {
  final Budget budget;

  const BudgetCard({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(budgetProgressProvider(budget));
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    final cs = Theme.of(context).colorScheme;

    final category = categories.isEmpty
        ? null
        : categories.firstWhere(
            (c) => c.id.toString() == budget.categoryId,
            orElse: () => categories.first,
          );

    final isExpired =
        !budget.isRecurring &&
        budget.endDate != null &&
        budget.endDate!.isBefore(DateTime.now());
    final isDisabled = !budget.isActive;
    final isInactive = isExpired || isDisabled;

    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final tones = category == null
        ? null
        : categoryTones(context, Color(category.colorValue));

    // Board 3.18 row: tile, name (+ status pill), "₹x of ₹y", percentage in
    // the status colour, wavy bar, the existing caps footer.
    final row = InkWell(
      onTap: (isExpired || category == null)
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    BudgetDetailsSheet(budgetId: budget.id, category: category),
              );
            },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: progressAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (err, _) => Text('Error: $err'),
          data: (p) {
            final pct = p.percentage;
            final (state, pctColor) = isInactive
                ? (KuberProgressState.normal, cs.onSurfaceVariant)
                : pct >= 100
                ? (KuberProgressState.overLimit, context.kuberMoney.expense)
                : pct >= 80
                ? (KuberProgressState.nearLimit, context.kuberMoney.warning)
                : (KuberProgressState.normal, cs.onSurfaceVariant);
            final footer = isExpired
                ? context.l10n.budgetPeriodEnded
                : isDisabled
                ? context.l10n.budgetPaused
                : pct >= 100
                ? context.l10n.exceededBy(
                    maskAmount(fmt.formatCurrency(p.spent - p.limit), masked),
                  )
                : (budget.isRecurring
                      ? context.l10n.budgetResetsIn(p.daysRemaining)
                      : context.l10n.budgetExpiresIn(p.daysRemaining));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tones?.container ?? cs.surfaceContainerHigh,
                        borderRadius: KuberShape.mediumR,
                      ),
                      child: Icon(
                        category != null
                            ? IconMapper.fromString(category.icon)
                            : Icons.shopping_bag_outlined,
                        size: 20,
                        color: tones?.fg ?? cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  category?.name ?? context.l10n.budgetLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              if (isDisabled) ...[
                                const SizedBox(width: 8),
                                KuberPill(
                                  label: context.l10n.disabledUpper,
                                  tone: KuberTone.neutral,
                                ),
                              ] else if (isExpired) ...[
                                const SizedBox(width: 8),
                                KuberPill(
                                  label: context.l10n.expiredUpper,
                                  tone: KuberTone.error,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${maskAmount(fmt.formatCurrency(p.spent), masked)} of ${maskAmount(fmt.formatCurrency(p.limit), masked)}',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fmt.formatPercentage(pct),
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: pctColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.md),
                KuberLinearProgress(
                  value: (pct / 100).clamp(0.0, 1.0),
                  state: state,
                ),
                const SizedBox(height: 6),
                Text(
                  footer,
                  style: theme.textTheme.labelSmall!.copyWith(
                    letterSpacing: 0.6,
                    color: !isInactive && pct >= 100
                        ? context.kuberMoney.expense
                        : cs.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    return isInactive ? Opacity(opacity: 0.6, child: row) : row;
  }
}
