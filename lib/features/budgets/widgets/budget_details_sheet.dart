import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../categories/data/category.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';

class BudgetDetailsSheet extends ConsumerWidget {
  final int budgetId;
  final Category category;

  const BudgetDetailsSheet({
    super.key, 
    required this.budgetId, 
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final budgetAsync = ref.watch(budgetByIdProvider(budgetId));

    return budgetAsync.when(
      data: (budget) {
        if (budget == null) return const SizedBox.shrink();
        
        final progressAsync = ref.watch(budgetProgressProvider(budget));
        final alerts = budget.alerts;

        return Container(
          padding: const EdgeInsets.all(KuberSpacing.xl),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Header row: icon + name + close
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shopping_bag_outlined, color: Color(category.colorValue), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                        Text(
                          'MONTHLY BUDGET PLAN',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context, rootNavigator: true).pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              progressAsync.when(
                data: (p) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT SPENDING',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: ref.watch(formatterProvider).formatCurrency(p.spent),
                                    style: GoogleFonts.inter(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${ref.watch(formatterProvider).formatCurrency(p.limit)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'UTILIZATION',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ref.watch(formatterProvider).formatPercentage(p.percentage),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _getUtilizationColor(p.percentage, cs),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (p.percentage / 100).clamp(0.0, 1.0),
                        minHeight: 12,
                        backgroundColor: cs.outline.withValues(alpha: 0.1),
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ref.watch(formatterProvider).formatCurrency(0), style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                        Text(ref.watch(formatterProvider).formatCompactCurrency(p.limit), style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 32),
              Text(
                'ACTIVE ALERTS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              if (alerts.isEmpty)
                Text('No alerts set', style: GoogleFonts.inter(color: cs.onSurfaceVariant))
              else
                Column(
                  children: alerts.map((a) => _AlertRow(
                    alert: a, 
                    currentSpent: progressAsync.valueOrNull?.spent ?? 0,
                    budgetAmount: budget.amount,
                  )).toList(),
                ),
              const SizedBox(height: 32),
              Text(
                'BUDGET CONTROLS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push('/budgets/edit', extra: budget);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'Edit Budget',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(budgetListProvider.notifier).toggleActive(budget.id, !budget.isActive);
                    // Sheet will auto-refresh due to stream notifier
                  },
                  icon: Icon(
                    budget.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(
                    budget.isActive ? 'Disable Budget' : 'Enable Budget',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: BorderSide(color: cs.outline),
                    padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmDeleteBudget(context, ref, budget.id),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    'Delete Budget',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading budget details: $err')),
    );
  }

  void _confirmDeleteBudget(BuildContext context, WidgetRef ref, int id) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        title: Text('Delete budget?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          )),
        content: Text(
          'The budget for "${category.name}" will be permanently deleted.',
          style: GoogleFonts.inter(
            color: cs.onSurfaceVariant,
          )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
            ),
            onPressed: () {
              ref.read(budgetListProvider.notifier).delete(id);
              Navigator.pop(ctx);   // close dialog
              context.pop();        // close sheet
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getUtilizationColor(double percentage, ColorScheme cs) {
    if (percentage >= 100) return cs.error;
    if (percentage >= 66) return Colors.orangeAccent;
    if (percentage >= 33) return Colors.amber;
    return Colors.green;
  }
}

class _AlertRow extends ConsumerWidget {
  final BudgetAlert alert;
  final double currentSpent;
  final double budgetAmount;
  const _AlertRow({
    required this.alert, 
    required this.currentSpent,
    required this.budgetAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final label = alert.type == BudgetAlertType.percentage 
        ? 'At ${ref.watch(formatterProvider).formatPercentage(alert.value)}' 
        : 'At ${ref.watch(formatterProvider).formatCurrency(alert.value)}';
    
    final threshold = alert.type == BudgetAlertType.percentage
        ? budgetAmount * (alert.value / 100)
        : alert.value;
    
    final isReached = currentSpent >= threshold;
    final status = isReached ? 'REACHED' : 'UPCOMING';
    final statusColor = isReached ? cs.primary : cs.onSurfaceVariant;
    
    // Notification Icon & Color
    final notificationIcon = alert.enableNotification 
        ? Icons.notifications_active_outlined 
        : Icons.notifications_off_outlined;
    final notificationColor = alert.enableNotification 
        ? cs.primary 
        : cs.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            notificationIcon,
            size: 20,
            color: notificationColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: cs.onSurface),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

