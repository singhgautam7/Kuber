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
import '../../settings/providers/settings_provider.dart' show formatterProvider;
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
                  description: 'Your active subscriptions and bill automations',
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
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _RecurringKpisGrid(rules: rules),
                                  const SizedBox(height: KuberSpacing.lg),

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
                                    data: (catMap) {
                                      final accounts = accountsAsync.valueOrNull ?? [];
                                      return Column(
                                        children: rules.map((rule) {
                                          final catId = int.tryParse(rule.categoryId);
                                          final cat = catId != null ? catMap[catId] : null;
                                          final accountName = accounts
                                              .where((a) => a.id.toString() == rule.accountId)
                                              .firstOrNull
                                              ?.name;
                              return _RuleCard(
                                  rule: rule,
                                  categoryIcon: cat != null
                                      ? IconMapper.fromString(cat.icon)
                                      : Icons.category_outlined,
                                  categoryColor: cat != null
                                      ? harmonizeCategory(context, Color(cat.colorValue))
                                      : cs.onSurfaceVariant,
                                              accountName: accountName,
                                              onTap: () => showRecurringDetailSheet(
                                                context, ref, rule,
                                              ),
                                            );
                                        }).toList(),
                                      );
                                    },
                                  ),

                                  // Recently Processed
                                  const SizedBox(height: KuberSpacing.lg),
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
                                    final catColor = cs.onSurfaceVariant;
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
                                            '${t.type == 'expense' ? '-' : ''}${ref.watch(formatterProvider).formatCurrency(t.amount)}',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: cs.onSurfaceVariant,
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

}

class _RecurringKpisGrid extends ConsumerWidget {
  final List<RecurringRule> rules;
  const _RecurringKpisGrid({required this.rules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRules = rules.where((r) => !r.isPaused && !RecurringRepository.isExpired(r)).toList();
    
    double activeAutoIncome = 0;
    double activeAutoExpense = 0;
    for (final r in activeRules) {
      if (r.type == 'income') {
        activeAutoIncome += r.amount;
      } else {
        activeAutoExpense += r.amount;
      }
    }

    final upcomingCount = activeRules
        .where((r) => r.nextDueAt.isBefore(DateTime.now().add(const Duration(days: 7))))
        .length;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                context,
                title: 'ACTIVE AUTO INC.',
                value: '+${ref.watch(formatterProvider).formatCurrency(activeAutoIncome)}',
                valueColor: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 12),
              _buildKpiCard(
                context,
                title: 'ACTIVE RULES',
                value: '${activeRules.length}',
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                context,
                title: 'ACTIVE AUTO EXP.',
                value: '-${ref.watch(formatterProvider).formatCurrency(activeAutoExpense)}',
                valueColor: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              _buildKpiCard(
                context,
                title: 'UPCOMING (7d)',
                value: '$upcomingCount',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, {required String title, required String value, Color? valueColor}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final RecurringRule rule;
  final IconData categoryIcon;
  final Color categoryColor;
  final String? accountName;
  final VoidCallback onTap;

  const _RuleCard({
    required this.rule,
    required this.categoryIcon,
    required this.categoryColor,
    this.accountName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isPaused = rule.isPaused;
    final isExpired = RecurringRepository.isExpired(rule);

    final statusLabel = isPaused ? 'PAUSED' : isExpired ? 'EXPIRED' : 'ACTIVE';
    final statusColor = isPaused ? cs.onSurfaceVariant : isExpired ? cs.error : cs.tertiary;

    final amountColor = rule.type == 'income' ? cs.tertiary : cs.error;
    final amountSign = rule.type == 'income' ? '+' : '-';
    
    final freqText = rule.frequency.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: (isPaused || isExpired) ? 0.4 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: [
              // Top Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 28),
                  ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule.name,
                        style: textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NEXT: ${DateFormat('MMM d, yyyy').format(rule.nextDueAt).toUpperCase()}',
                        style: textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (accountName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          accountName!,
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: KuberSpacing.lg),
            
            // Bottom Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Consumer(builder: (context, ref, _) {
                  return Text(
                    '$amountSign${ref.watch(formatterProvider).formatCurrency(rule.amount)}',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  );
                }),
                _StatusBadge(label: freqText, color: cs.primary),
              ],
            ),
          ],
        ),
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
