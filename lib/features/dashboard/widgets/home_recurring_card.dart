import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../categories/providers/category_provider.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../recurring/widgets/recurring_detail_sheet.dart';

class HomeRecurringCard extends ConsumerWidget {
  const HomeRecurringCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingRecurringProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;

    return upcomingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rules) {
        if (rules.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('RECURRING',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        )),
                    GestureDetector(
                      onTap: () => GoRouter.of(context).push('/more/recurring'),
                      child: Text('VIEW ALL',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: colorScheme.primary,
                          )),
                    ),
                  ],
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
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final dueDay = DateTime(
                      rule.nextDueAt.year, rule.nextDueAt.month, rule.nextDueAt.day);

                  String statusLabel;
                  Color statusColor;
                  if (dueDay.isBefore(today)) {
                    statusLabel = 'PROCESSED';
                    statusColor = cs.tertiary;
                  } else if (dueDay.isAtSameMomentAs(today)) {
                    statusLabel = 'PENDING';
                    statusColor = cs.primary;
                  } else {
                    statusLabel = 'SCHEDULED';
                    statusColor = cs.onSurfaceVariant;
                  }

                  final catColor = cat != null
                      ? harmonizeCategory(context, Color(cat.colorValue))
                      : cs.onSurfaceVariant;

                  return GestureDetector(
                    onTap: () => showRecurringDetailSheet(context, ref, rule),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
                      padding: const EdgeInsets.all(KuberSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              cat != null
                                  ? IconMapper.fromString(cat.icon)
                                  : Icons.category_outlined,
                              color: catColor,
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
                                    Flexible(
                                      child: Text(
                                        rule.name,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: KuberSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(KuberRadius.sm),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat('MMM d').format(rule.nextDueAt),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(rule.amount),
                            style: textTheme.bodyMedium?.copyWith(
                              color: rule.type == 'income'
                                  ? cs.tertiary
                                  : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              ),
            ],
          ),
        );
      },
    );
  }
}
