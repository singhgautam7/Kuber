import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

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
            KuberHomeWidgetTitle(
              title: 'ACCOUNTS',
              trailing: GestureDetector(
                onTap: () => context.push('/more/accounts'),
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
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: accounts.length,
                itemBuilder: (context, i) {
                  final account = accounts[i];
                  final balanceAsync =
                      ref.watch(accountBalanceProvider(account.id));
                  final acctColor = resolveAccountColor(account);

                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AccountDetailSheet(account: account),
                        );
                      },
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      child: Container(
                        padding: const EdgeInsets.all(KuberSpacing.md),
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
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                  balanceColor = balance < 0
                                      ? cs.error
                                      : balance > 0
                                          ? cs.tertiary
                                          : null;
                                } else {
                                  balanceColor = balance < 0 ? cs.error : null;
                                }
                                return Text(
                                  maskAmount(ref.watch(formatterProvider).formatCurrency(balance), ref.watch(privacyModeProvider)),
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
                          ],
                        ),
                      ),
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
