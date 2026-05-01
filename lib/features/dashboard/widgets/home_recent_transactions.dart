import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../history/utils/history_utils.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/transaction_row.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

class HomeRecentTransactionsCard extends ConsumerWidget {
  const HomeRecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final accountMapAsync = ref.watch(accountMapProvider);
    final allTransactionsAsync = ref.watch(transactionListProvider);
    final fmt = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        KuberHomeWidgetTitle(
          title: 'RECENT TRANSACTIONS',
          trailing: GestureDetector(
            onTap: () => context.go('/history'),
            child: Text(
              'VIEW ALL',
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: cs.primary,
              ),
            ),
          ),
        ),
        recentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(KuberSpacing.xl),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            final accountMap = accountMapAsync.valueOrNull ?? {};
            final categoryMap = categoryMapAsync.valueOrNull ?? {};
            final allTransactions = allTransactionsAsync.valueOrNull ?? [];

            // Build tag names map for indicator line
            final allTags = ref.watch(tagListProvider).valueOrNull ?? [];
            final tagNameById = {for (final t in allTags) t.id: t.name};
            final txnTagsMapData = ref.watch(transactionTagsMapProvider).valueOrNull ?? {};
            final tagNamesMap = <int, List<String>>{};
            for (final entry in txnTagsMapData.entries) {
              final names = entry.value
                  .map((tagId) => tagNameById[tagId])
                  .whereType<String>()
                  .toList();
              if (names.isNotEmpty) tagNamesMap[entry.key] = names;
            }
            final groups = groupTransactionsByDate(transactions);

            return Column(
              children: groups.map((group) {
                return Column(
                  children: [
                    DateGroupHeader(
                      label: group.label,
                      dayTotal: group.dayTotal,
                    ),
                    TransactionDayCard(
                      transactions: group.transactions,
                      onDelete: (t) => deleteTransactionWithUndo(context, ref, t),
                      onTap: (t) => showTransactionDetailSheet(context, ref, t),
                      onEdit: (t) => context.push('/add-transaction', extra: t),
                      formatter: fmt,
                      categoryMap: categoryMap,
                      accountMap: accountMap,
                      transactionList: allTransactions,
                      tagNamesMap: tagNamesMap,
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
