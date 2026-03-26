import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../settings/providers/settings_provider.dart';
import '../../accounts/providers/account_provider.dart';

class HomeAccountsCard extends ConsumerWidget {
  const HomeAccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bank Accounts',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/more/accounts'),
                  child: Text(
                    'View All',
                    style: textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: accounts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: KuberSpacing.md),
                itemBuilder: (context, i) {
                  final account = accounts[i];
                  final balanceAsync =
                      ref.watch(accountBalanceProvider(account.id));
                  final acctColor = resolveAccountColor(account);
                  final cardWidth = (MediaQuery.of(context).size.width -
                          2 * KuberSpacing.lg -
                          KuberSpacing.md) /
                      2;
                  return SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainer,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(
                          color: cs.outline,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: acctColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  resolveAccountIcon(account),
                                  size: 18,
                                  color: acctColor,
                                ),
                              ),
                              const SizedBox(width: KuberSpacing.sm),
                              Expanded(
                                child: Text(
                                  account.name,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          balanceAsync.when(
                            loading: () =>
                                Text('...', style: textTheme.titleMedium),
                            error: (e, _) =>
                                Text('-', style: textTheme.titleMedium),
                            data: (balance) {
                              final Color? balanceColor;
                              if (account.isCreditCard) {
                                balanceColor = balance > 0
                                    ? cs.error
                                    : balance < 0
                                        ? cs.tertiary
                                        : null;
                              } else {
                                balanceColor = balance < 0 ? cs.error : null;
                              }
                              return Text(
                                ref.watch(formatterProvider).formatCurrency(balance),
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: balanceColor,
                                ),
                              );
                            },
                          ),
                          if (account.last4Digits != null)
                            Text(
                              '**** ${account.last4Digits}',
                              style: textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
