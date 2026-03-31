import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider;
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';
import '../widgets/recurring_detail_sheet.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rulesAsync = ref.watch(recurringListProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final recentlyProcessedAsync = ref.watch(recentlyProcessedProvider);
    final accountsAsync = ref.watch(accountListProvider);
    final symbol = ref.watch(currencyProvider).symbol;

    return Scaffold(
      backgroundColor: cs.surface,
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rules) {
          return CustomScrollView(
            slivers: [
              // App bar
              const SliverToBoxAdapter(
                child: KuberAppBar(showBack: true, title: 'Recurring'),
              ),

              // Page header
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Manage\nAutomations',
                  description: 'Automated scheduled transactions',
                  actionTooltip: 'Add Recurring',
                  onAction: () => context.push('/recurring/add'),
                ),
              ),

              // Body content
              if (rules.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No recurring transactions',
                    description: 'Automate subscriptions and repeated payments',
                    actionLabel: 'Add Recurring',
                    onAction: () => context.push('/recurring/add'),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      KuberSpacing.lg,
                      0,
                      KuberSpacing.lg,
                      navBarBottomPadding(context) + KuberSpacing.lg,
                    ),
                    child: Builder(builder: (context) {
                      final activeRules = rules
                          .where((r) => !r.isPaused && !RecurringRepository.isExpired(r))
                          .toList();
                      final monthlyTotal = _computeMonthlyTotal(activeRules);
                      final upcomingCount = activeRules
                          .where((r) => r.nextDueAt
                              .isBefore(DateTime.now().add(const Duration(days: 7))))
                          .length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats card
                          Container(
                            padding: const EdgeInsets.all(KuberSpacing.lg),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainer,
                              borderRadius: BorderRadius.circular(KuberRadius.md),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _StatTile(
                                    label: 'Monthly Total',
                                    value: ref.watch(formatterProvider).formatCurrency(monthlyTotal),
                                  ),
                                ),
                                Expanded(
                                  child: _StatTile(
                                    label: 'Active',
                                    value: '${activeRules.length}',
                                  ),
                                ),
                                Expanded(
                                  child: _StatTile(
                                    label: 'Upcoming 7d',
                                    value: '$upcomingCount',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.xl),

                          // Rule cards
                          Text(
                            'RULES',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          categoryMapAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (catMap) => Column(
                              children: rules.map((rule) {
                                final catId = int.tryParse(rule.categoryId);
                                final cat = catId != null ? catMap[catId] : null;
                              return _RuleCard(
                                  rule: rule,
                                  categoryIcon: cat != null
                                      ? IconMapper.fromString(cat.icon)
                                      : Icons.category_outlined,
                                  categoryColor: cat != null
                                      ? harmonizeCategory(context, Color(cat.colorValue))
                                      : cs.onSurfaceVariant,
                                  symbol: symbol,
                                  onTap: () => showRecurringDetailSheet(
                                    context, ref, rule,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Recently Processed
                          const SizedBox(height: KuberSpacing.xl),
                          recentlyProcessedAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (transactions) {
                              if (transactions.isEmpty) return const SizedBox.shrink();
                              final catMap = categoryMapAsync.valueOrNull ?? {};
                              final accounts = accountsAsync.valueOrNull ?? [];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RECENTLY PROCESSED',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: KuberSpacing.sm),
                                  ...transactions.map((t) {
                                    final catId = int.tryParse(t.categoryId);
                                    final cat = catId != null ? catMap[catId] : null;
                                    final catIcon = cat != null
                                        ? IconMapper.fromString(cat.icon)
                                        : Icons.category_outlined;
                                    final catColor = cat != null
                                        ? harmonizeCategory(context, Color(cat.colorValue))
                                        : cs.onSurfaceVariant;
                                    final accountName = accounts
                                        .where((a) => a.id.toString() == t.accountId)
                                        .firstOrNull
                                        ?.name;
                                    final dateStr = DateFormat('MMM d').format(t.createdAt);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                                      padding: const EdgeInsets.all(KuberSpacing.md),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainer,
                                        borderRadius: BorderRadius.circular(KuberRadius.md),
                                        border: Border.all(color: cs.outline),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: catColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(catIcon, color: catColor, size: 22),
                                          ),
                                          const SizedBox(width: KuberSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  t.name,
                                                  style: textTheme.bodyMedium?.copyWith(
                                                    color: cs.onSurface,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${accountName ?? 'Unknown'} · $dateStr',
                                                  style: textTheme.labelSmall?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            ref.watch(formatterProvider).formatCurrency(t.amount),
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: t.type == 'income'
                                                  ? cs.tertiary
                                                  : cs.error,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _computeMonthlyTotal(List<RecurringRule> rules) {
    double total = 0;
    for (final r in rules) {
      switch (r.frequency) {
        case 'daily':
          total += r.amount * 30;
        case 'weekly':
          total += r.amount * 4.33;
        case 'biweekly':
          total += r.amount * 2.17;
        case 'monthly':
          total += r.amount;
        case 'yearly':
          total += r.amount / 12;
        case 'custom':
          if (r.customDays != null && r.customDays! > 0) {
            total += r.amount * (30 / r.customDays!);
          }
      }
    }
    return total;
  }
}


class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final RecurringRule rule;
  final IconData categoryIcon;
  final Color categoryColor;
  final String symbol;
  final VoidCallback onTap;

  const _RuleCard({
    required this.rule,
    required this.categoryIcon,
    required this.categoryColor,
    required this.symbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPaused = rule.isPaused;
    final isExpired = RecurringRepository.isExpired(rule);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(categoryIcon, color: categoryColor, size: 22),
            ),
            const SizedBox(width: KuberSpacing.md),

            // Name & next date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rule.name,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Next: ${DateFormat('MMM d, yyyy').format(rule.nextDueAt)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),

            // Amount + status badge stacked on the right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer(builder: (context, ref, _) {
                  return Text(
                    ref.watch(formatterProvider).formatCurrency(rule.amount),
                    style: textTheme.bodyMedium?.copyWith(
                      color: rule.type == 'income'
                          ? cs.tertiary
                          : cs.error,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
                const SizedBox(height: 4),
                _StatusBadge(
                  label: isPaused
                      ? 'PAUSED'
                      : isExpired
                          ? 'EXPIRED'
                          : 'ACTIVE',
                  color: isPaused
                      ? cs.onSurfaceVariant
                      : isExpired
                          ? cs.error
                          : cs.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
