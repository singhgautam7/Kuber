import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider, settingsProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/account_detail_sheet.dart';
import '../../../core/constants/info_constants.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../settings/providers/info_provider.dart';



String _accountTypeLabel(Account account) {
  String label;
  if (account.isCreditCard) {
    label = 'CREDIT CARD';
  } else {
    switch (account.type.toLowerCase()) {
      case 'bank':
        label = 'BANK/CASH';
      case 'card':
        label = 'CREDIT CARD';
      default:
        label = account.type.toUpperCase();
    }
  }
  if (account.last4Digits != null &&
      (account.isCreditCard || account.type.toLowerCase() == 'bank')) {
    label += ' • **** ${account.last4Digits}';
  }
  return label;
}

IconData _resolveIcon(Account account) {
  return resolveAccountIcon(account);
}

Color _resolveColor(Account account) {
  return resolveAccountColor(account);
}

void _openAccountDetailSheet(BuildContext context, Account account) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AccountDetailSheet(account: account),
  );
}

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(accountListProvider);

    // Listen for add-account trigger from nav bar
    ref.listen<bool>(triggerAddAccountProvider, (_, triggered) {
      if (triggered) {
        ref.read(triggerAddAccountProvider.notifier).state = false;
        context.push('/accounts/add');
      }
    });

    // Auto-trigger info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoAccounts), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.accounts);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoAccounts).notifier).markSeen();
        });
      }
    });

    return Scaffold(
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.inter(
                  color: cs.onSurfaceVariant)),
        ),
        data: (accounts) => _AccountsBody(accounts: accounts),
      ),
    );
  }
}

class _AccountsBody extends ConsumerWidget {
  final List<Account> accounts;

  const _AccountsBody({required this.accounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Compute net worth from all account balances
    double totalAssets = 0;
    double totalDebt = 0;

    final balanceMap = <int, double>{};
    for (final a in accounts) {
      final balanceAsync = ref.watch(accountBalanceProvider(a.id));
      final balance = balanceAsync.valueOrNull ?? a.initialBalance;
      balanceMap[a.id] = balance;

      if (balance > 0) {
        totalAssets += balance;
      } else if (balance < 0) {
        totalDebt += balance.abs();
      }
    }
    final netWorth = totalAssets - totalDebt;

    return CustomScrollView(
      slivers: [
        // App bar
        const SliverToBoxAdapter(
          child: KuberAppBar(
            showBack: true, 
            title: 'Accounts',
            infoConfig: InfoConstants.accounts,
          ),
        ),

        // Page header
        SliverToBoxAdapter(
          child: KuberPageHeader(
            title: 'Manage\nAccounts',
            description: 'Overview of your linked financial institutions.',
            actionTooltip: 'Add Account',
            onAction: () => context.push('/accounts/add'),
          ),
        ),

        // Net worth card at top (scrollable, not pinned)
        if (accounts.isNotEmpty)
          SliverToBoxAdapter(
            child: _NetWorthCard(
              netWorth: netWorth,
              totalAssets: totalAssets,
              totalDebt: totalDebt,
            ),
          ),

        // Account cards
        if (accounts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No accounts yet',
              description: 'Add your first account to start tracking',
              actionLabel: 'Add Account',
              onAction: () => context.push('/accounts/add'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _AccountCard(
                account: accounts[i],
                balance: balanceMap[accounts[i].id] ??
                    accounts[i].initialBalance,
              ),
            ),
          ),

        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: navBarBottomPadding(context)),
        ),
      ],
    );
  }
}

class _AccountCard extends ConsumerWidget {
  final Account account;
  final double balance;

  const _AccountCard({required this.account, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDefault = ref.watch(
          settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
        ) ==
        account.id.toString();
    final balanceLabel =
        account.isCreditCard ? 'Limit Spent' : 'Available Balance';
    final Color balanceColor;
    if (account.isCreditCard) {
      balanceColor = balance < 0
          ? cs.error
          : balance > 0
              ? cs.tertiary
              : cs.onSurface;
    } else {
      balanceColor = balance < 0 ? cs.error : cs.onSurface;
    }
    final accentColor = _resolveColor(account);

    return InkWell(
      onTap: () => _openAccountDetailSheet(context, account),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name/type
            Row(
              children: [
                CategoryIcon.square(
                  icon: _resolveIcon(account),
                  rawColor: accentColor,
                  size: 44,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _accountTypeLabel(account),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.tertiary.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(KuberRadius.sm),
                            border: Border.all(
                                color: cs.tertiary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  size: 10, color: cs.tertiary),
                              const SizedBox(width: 3),
                              Text(
                                'DEFAULT',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: cs.tertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Balance label
            Text(
              balanceLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),

            // Balance amount + credit limit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${balance < 0 ? '−' : ''}${ref.watch(formatterProvider).formatCurrency(balance.abs())}',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (account.isCreditCard && account.creditLimit != null)
                  Text(
                    'Limit  ${ref.watch(formatterProvider).formatCurrency(account.creditLimit!)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _NetWorthCard extends ConsumerWidget {
  final double netWorth;
  final double totalAssets;
  final double totalDebt;

  const _NetWorthCard({
    required this.netWorth,
    required this.totalAssets,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL NET WORTH',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${netWorth < 0 ? '−' : ''}${ref.watch(formatterProvider).formatCurrency(netWorth.abs())}',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: netWorth < 0 ? cs.error : cs.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NetWorthLegend(
                color: cs.tertiary,
                label: 'Assets',
                amount: totalAssets,
                symbol: symbol,
              ),
              const SizedBox(width: 24),
              _NetWorthLegend(
                color: cs.error,
                label: 'Debt',
                amount: totalDebt,
                symbol: symbol,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetWorthLegend extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final String symbol;

  const _NetWorthLegend({
    required this.color,
    required this.label,
    required this.amount,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Consumer(builder: (context, ref, _) {
          return Text(
            '$label: ${ref.watch(formatterProvider).formatCurrency(amount)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          );
        }),
      ],
    );
  }
}

