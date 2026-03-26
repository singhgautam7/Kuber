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
  final Budget budget;
  final Category category;

  const BudgetDetailsSheet({
    super.key, 
    required this.budget, 
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final progressAsync = ref.watch(budgetProgressProvider(budget));
    final alertsAsync = ref.watch(budgetAlertsProvider(budget.id));

    return Container(
      padding: EdgeInsets.all(KuberSpacing.xl),
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
          alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) {
                return Text('No alerts set', style: GoogleFonts.inter(color: cs.onSurfaceVariant));
              }
              final progress = progressAsync.valueOrNull;
              return Column(
                children: alerts.map((a) => _AlertRow(
                  alert: a, 
                  currentPercentage: progress?.percentage ?? 0,
                )).toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
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
                context.pop();
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
              onPressed: () {
                ref.read(budgetListProvider.notifier).delete(budget.id);
                context.pop();
              },
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
  final double currentPercentage;
  const _AlertRow({required this.alert, required this.currentPercentage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final label = alert.type == BudgetAlertType.percentage 
        ? 'At ${ref.watch(formatterProvider).formatPercentage(alert.value)}' 
        : 'At ${ref.watch(formatterProvider).formatCurrency(alert.value)}';
    
    String status;
    Color statusColor;
    
    if (alert.isTriggered) {
      status = 'TRIGGERED';
      statusColor = Colors.green;
    } else if (currentPercentage >= alert.value) { // This is a bit simplified, but logically if it's not triggered yet but we are past it
       status = 'ACTIVE';
       statusColor = cs.primary;
    } else if (alert.type == BudgetAlertType.percentage && currentPercentage < alert.value) {
      status = 'UPCOMING';
      statusColor = cs.onSurfaceVariant;
    } else {
      status = 'ACTIVE';
      statusColor = cs.primary;
    }

    // Explicit colors from requirement: TRIGGERED (Green), ACTIVE (Blue), UPCOMING (Grey)
    if (alert.isTriggered) {
      status = 'TRIGGERED';
      statusColor = Colors.green;
    } else {
      // Logic for ACTIVE vs UPCOMING
      // For percentage alerts:
      if (alert.type == BudgetAlertType.percentage) {
        if (currentPercentage < alert.value) {
          status = 'UPCOMING';
          statusColor = cs.onSurfaceVariant;
        } else {
          status = 'ACTIVE';
          statusColor = cs.primary;
        }
      } else {
        // For amount alerts, we'd need budget progress to be accurate
        status = 'ACTIVE';
        statusColor = cs.primary;
      }
    }

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
            alert.isTriggered ? Icons.check_circle_outline_rounded : Icons.notifications_outlined,
            size: 20,
            color: statusColor,
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

