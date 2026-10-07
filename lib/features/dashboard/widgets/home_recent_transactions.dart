import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/l10n_ext.dart';
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
import '../../../shared/widgets/skeleton_loader.dart';

class HomeRecentTransactionsCard extends ConsumerWidget {
  const HomeRecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentTransactionsProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final accountMapAsync = ref.watch(accountMapProvider);
    final transferPairsAsync = ref.watch(transferPairAccountIdsProvider);
    final fmt = ref.watch(formatterProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberHomeWidgetTitle(
          title: context.l10n.recentTransactions,
          trailing: KuberSectionAction(
            label: sentenceCase(context.l10n.viewAll),
            onTap: () => context.go('/history'),
          ),
        ),
        recentAsync.when(
          loading: () => const _RecentTransactionsSkeleton(),
          error: (e, _) =>
              Center(child: Text('${context.l10n.errorLabel}: $e')),
          data: (transactions) {
            if (transactions.isEmpty) {
              return KuberCard(
                child: Center(
                  child: Text(
                    context.l10n.noTransactionsYet,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }
            final accountMap = accountMapAsync.valueOrNull ?? {};
            final categoryMap = categoryMapAsync.valueOrNull ?? {};
            final transferPairs = transferPairsAsync.valueOrNull ?? const {};

            // Tag names map for the row indicator line. Both maps come from
            // cached providers; only the per-recent-row filter runs on rebuild.
            final tagNameById = ref.watch(tagNameByIdProvider);
            final txnTagsMapData =
                ref.watch(transactionTagsMapProvider).valueOrNull ?? {};
            final recentIds = {for (final t in transactions) t.id};
            final tagNamesMap = <int, List<String>>{};
            for (final entry in txnTagsMapData.entries) {
              if (!recentIds.contains(entry.key)) continue;
              final names = entry.value
                  .map((tagId) => tagNameById[tagId])
                  .whereType<String>()
                  .toList();
              if (names.isNotEmpty) tagNamesMap[entry.key] = names;
            }
            final groups = groupTransactionsByDate(transactions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: groups.map((group) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DateGroupHeader(
                      label: group.label,
                      dayTotal: group.dayTotal,
                    ),
                    TransactionDayCard(
                      transactions: group.transactions,
                      onDelete: (t) =>
                          deleteTransactionWithUndo(context, ref, t),
                      onTap: (t) => showTransactionDetailSheet(context, ref, t),
                      onEdit: (t) => context.push('/add-transaction', extra: t),
                      formatter: fmt,
                      categoryMap: categoryMap,
                      accountMap: accountMap,
                      transferPairAccountId: transferPairs,
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

/// Skeleton for the recent-transactions list — a card with a few row
/// placeholders shown while [recentTransactionsProvider] first resolves.
class _RecentTransactionsSkeleton extends StatelessWidget {
  const _RecentTransactionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return KuberGroup(
      children: [
        for (var i = 0; i < 3; i++)
          const SizedBox(
            height: KuberSpace.listItem2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SkeletonBlock(width: 40, height: 40, borderRadius: 12),
                  SizedBox(width: KuberSpace.lg),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(
                          width: 130,
                          height: 12,
                          borderRadius: 999,
                        ),
                        SizedBox(height: 8),
                        SkeletonBlock(width: 80, height: 10, borderRadius: 999),
                      ],
                    ),
                  ),
                  SizedBox(width: KuberSpace.md),
                  SkeletonBlock(width: 56, height: 12, borderRadius: 999),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
