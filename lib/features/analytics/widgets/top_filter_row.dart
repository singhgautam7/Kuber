import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../providers/analytics_provider.dart';

class TopFilterRow extends ConsumerWidget {
  const TopFilterRow({super.key});

  void _goToFilterScreen(BuildContext context) {
    context.push('/analytics/filter');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(analyticsFilterProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isToday = filter.type == FilterType.today;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Quick Filter Pill (Always visible)
          GestureDetector(
            onTap: () => _goToFilterScreen(context),
            child: Container(
              key: TutorialStepKeys.analyticsFilterPill,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.unfold_more_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    _typeLabel(context, filter.type),
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Date Range (Center aligned)
          Expanded(
            child: GestureDetector(
              onTap: () => _goToFilterScreen(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_outlined,
                        size: 16,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _rangeLabel(filter.from, filter.to),
                        textAlign: TextAlign.center,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reset Button (Consistent style)
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => ref.read(analyticsFilterProvider.notifier).reset(),
            child: Opacity(
              opacity: isToday ? 0.3 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                ),
                child: Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(BuildContext context, FilterType t) {
    switch (t) {
      case FilterType.all:
        return context.l10n.filterAll;
      case FilterType.today:
        return context.l10n.filterToday;
      case FilterType.thisWeek:
        return context.l10n.filterThisWeek;
      case FilterType.lastWeek:
        return context.l10n.filterLastWeek;
      case FilterType.thisMonth:
        return context.l10n.filterThisMonth;
      case FilterType.lastMonth:
        return context.l10n.filterLastMonth;
      case FilterType.thisYear:
        return context.l10n.filterThisYear;
      case FilterType.custom:
        return context.l10n.filterCustom;
    }
  }

  String _rangeLabel(DateTime from, DateTime to) {
    if (from.year == to.year) {
      final fmtStart = DateFormat('MMM d');
      final fmtEnd = DateFormat('MMM d, yyyy');
      return '${fmtStart.format(from)} – ${fmtEnd.format(to)}';
    } else {
      final fmt = DateFormat('MMM d, yyyy');
      return '${fmt.format(from)} – ${fmt.format(to)}';
    }
  }
}