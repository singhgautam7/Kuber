import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/account_form_sheet.dart';



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

void _openAccountSheet(BuildContext context, {Account? account}) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
    builder: (_) => AccountFormSheet(account: account),
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
        _openAccountSheet(context);
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
    final cs = Theme.of(context).colorScheme;
    // Compute net worth from all account balances
    double totalAssets = 0;
    double totalDebt = 0;

    final balanceMap = <int, double>{};
    for (final a in accounts) {
      final balanceAsync = ref.watch(accountBalanceProvider(a.id));
      final balance = balanceAsync.valueOrNull ?? a.initialBalance;
      balanceMap[a.id] = balance;

      if (a.isCreditCard) {
        if (balance > 0) totalDebt += balance; // positive utilized = debt
      } else {
        totalAssets += balance;
      }
    }
    final netWorth = totalAssets - totalDebt;

    return CustomScrollView(
      slivers: [
        // App bar
        const SliverToBoxAdapter(
          child: KuberAppBar(showBack: true, title: 'Accounts'),
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
                        'Manage\nAccounts',
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
                        'Overview of your linked financial institutions.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _openAccountSheet(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: cs.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
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
            child: EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No accounts yet',
              description: 'Add your first account to start tracking',
              actionLabel: 'Add Account',
              onAction: () => _openAccountSheet(context),
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
    final symbol = ref.watch(currencyProvider).symbol;
    final isCreditCard = account.isCreditCard;
    final balanceLabel = isCreditCard ? 'Credit Utilized' : 'Available Balance';
    final Color balanceColor;
    if (isCreditCard) {
      balanceColor = balance > 0
          ? cs.error
          : balance < 0
              ? cs.tertiary
              : cs.onSurface;
    } else {
      balanceColor = balance < 0 ? cs.error : cs.onSurface;
    }
    final accentColor = _resolveColor(account);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name/type + menu
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
                  ],
                ),
              ),
              _AccountMenu(account: account),
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
                '${balance < 0 ? '-' : ''}$symbol${balance.abs().toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: balanceColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (isCreditCard && account.creditLimit != null)
                Text(
                  'Limit  $symbol${account.creditLimit!.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  final Account account;

  const _AccountMenu({required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        color: cs.onSurfaceVariant,
        size: 20,
      ),
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.md)),
      onSelected: (val) => _handleAction(context, ref, val),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit',
              style: GoogleFonts.inter(
                  color: cs.onSurface)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete',
              style:
                  GoogleFonts.inter(color: cs.error)),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final cs = Theme.of(context).colorScheme;
    if (action == 'edit') {
      _openAccountSheet(context, account: account);
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cs.surfaceContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.md)),
          title: Text(
            'Delete account?',
            style: GoogleFonts.inter(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'All transactions linked to "${account.name}" will be unlinked.',
            style:
                GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.inter(
                      color: cs.onSurfaceVariant)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              onPressed: () {
                ref
                    .read(accountListProvider.notifier)
                    .delete(account.id);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
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
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
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
            '${netWorth < 0 ? '-' : ''}$symbol${netWorth.abs().toStringAsFixed(2)}',
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
        Text(
          '$label: $symbol${amount.toStringAsFixed(2)}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

