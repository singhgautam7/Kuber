import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../categories/providers/category_provider.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';
import '../widgets/budget_details_sheet.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetListProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: budgetsAsync.when(
        data: (budgets) {
          return CustomScrollView(
            slivers: [
              // App bar
              const SliverToBoxAdapter(
                child: KuberAppBar(showBack: true, title: 'Budgets'),
              ),

              // Page header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Track\nBudgets',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Monitor and control your monthly spending limits per category.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/budgets/add'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (budgets.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.account_balance_rounded,
                    title: 'No budgets yet',
                    description: 'Create budgets to control your spending per category',
                    actionLabel: 'Create Budget',
                    onAction: () => context.push('/budgets/add'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: budgets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return BudgetCard(budget: budgets[index]);
                    },
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
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
    final categories = ref.watch(categoryListProvider).valueOrNull ?? [];
    final category = categories.firstWhere(
      (c) => c.id.toString() == budget.categoryId,
      orElse: () => categories.first,
    );
    final cs = Theme.of(context).colorScheme;

    final isExpired = !budget.isRecurring && budget.endDate != null && budget.endDate!.isBefore(DateTime.now());
    final isDisabled = !budget.isActive;
    final isInactive = isExpired || isDisabled;

    return GestureDetector(
      onTap: isExpired ? null : () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BudgetDetailsSheet(
            budget: budget,
            category: category,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KuberSpacing.sm),
                  decoration: BoxDecoration(
                    color: isInactive 
                        ? cs.onSurfaceVariant.withValues(alpha: 0.1)
                        : Color(category.colorValue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: isInactive ? cs.onSurfaceVariant : Color(category.colorValue),
                    size: 20,
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isInactive ? cs.onSurfaceVariant : cs.onSurface,
                            ),
                          ),
                          if (isDisabled) ...[
                            const SizedBox(width: 8),
                            _StatusBadge(label: 'DISABLED', color: cs.onSurfaceVariant),
                          ] else if (isExpired) ...[
                            const SizedBox(width: 8),
                            _StatusBadge(label: 'EXPIRED', color: cs.error),
                          ],
                        ],
                      ),
                      progressAsync.when(
                        data: (p) => Text(
                          isExpired 
                            ? 'BUDGET PERIOD ENDED'
                            : isDisabled
                              ? 'BUDGET IS CURRENTLY PAUSED'
                              : p.percentage >= 100
                                ? 'EXCEEDED BY ₹${(p.spent - p.limit).toStringAsFixed(0)}'
                                : 'RESETS IN ${p.daysRemaining} DAYS',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isInactive 
                                ? cs.onSurfaceVariant 
                                : p.percentage >= 100 ? cs.error : cs.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                if (!isInactive) _AlertChips(budgetId: budget.id, budgetAmount: budget.amount),
              ],
            ),
            const SizedBox(height: KuberSpacing.lg),
            progressAsync.when(
              data: (p) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹${p.spent.toStringAsFixed(0)} ',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isInactive ? cs.onSurfaceVariant : cs.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: '/ ₹${p.limit.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(KuberRadius.full),
                    child: LinearProgressIndicator(
                      value: (p.percentage / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: cs.outline.withValues(alpha: 0.2),
                      color: isInactive ? cs.onSurfaceVariant.withValues(alpha: 0.5) : cs.primary,
                    ),
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(minHeight: 8),
              error: (err, _) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }

  // Static accent color used for progress bars (reverted from dynamic)
  // Dynamic color still used in details sheet for text
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AlertChips extends ConsumerWidget {
  final int budgetId;
  final double budgetAmount;
  const _AlertChips({required this.budgetId, required this.budgetAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(budgetAlertsProvider(budgetId));
    final cs = Theme.of(context).colorScheme;

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) return const SizedBox.shrink();

        // Show first 2 alerts
        final displayAlerts = alerts.take(2).toList();
        return Row(
          children: displayAlerts.map((a) {
            final percentage = a.type == BudgetAlertType.percentage
                ? a.value
                : (a.value / budgetAmount) * 100;
            
            final label = a.type == BudgetAlertType.percentage
                ? '${a.value.toStringAsFixed(0)}%'
                : '₹${a.value.toStringAsFixed(0)}';
            
            Color badgeColor;
            if (percentage >= 66) {
              badgeColor = Colors.orangeAccent;
            } else if (percentage >= 33) {
              badgeColor = Colors.amber;
            } else {
              badgeColor = Colors.green;
            }

            if (a.isTriggered) badgeColor = cs.error;

            return Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _Chip(
                label: label,
                color: badgeColor,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
