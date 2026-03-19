import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/account_form_sheet.dart';

IconData _accountIcon(String type) {
  switch (type.toLowerCase()) {
    case 'bank':
      return Icons.account_balance_rounded;
    case 'card':
      return Icons.credit_card_rounded;
    case 'upi':
      return Icons.phone_android_rounded;
    case 'cash':
      return Icons.payments_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

Color _accountColor(String type) {
  switch (type.toLowerCase()) {
    case 'bank':
      return const Color(0xFF5C6BC0); // indigo
    case 'card':
      return const Color(0xFFAB47BC); // purple/mauve
    case 'upi':
      return const Color(0xFFFF7043); // deep orange
    case 'cash':
      return const Color(0xFF66BB6A); // green
    default:
      return KuberColors.textSecondary;
  }
}

String _accountTypeLabel(Account account) {
  if (account.isCreditCard) return 'CREDIT CARD';
  switch (account.type.toLowerCase()) {
    case 'bank':
      return 'BANK ACCOUNT';
    case 'upi':
      return 'UPI';
    case 'cash':
      return 'CASH';
    case 'card':
      return 'CREDIT CARD';
    default:
      return account.type.toUpperCase();
  }
}

IconData _resolveIcon(Account account) {
  if (account.icon != null) return IconMapper.fromString(account.icon!);
  return _accountIcon(account.type);
}

Color _resolveColor(Account account) {
  if (account.colorValue != null) return Color(account.colorValue!);
  return _accountColor(account.type);
}

void _openAccountSheet(BuildContext context, {Account? account}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: KuberColors.surfaceCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => AccountFormSheet(account: account),
  );
}

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);

    return Scaffold(
      appBar: KuberAppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: KuberColors.textSecondary,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: GoogleFonts.plusJakartaSans(
                  color: KuberColors.textSecondary)),
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

      if (a.isCreditCard) {
        if (balance > 0) totalDebt += balance; // positive utilized = debt
      } else {
        totalAssets += balance;
      }
    }
    final netWorth = totalAssets - totalDebt;

    return CustomScrollView(
      slivers: [
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
                        'Managed\nAccounts',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: KuberColors.textPrimary,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Overview of your linked financial institutions.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: KuberColors.textSecondary,
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
                    decoration: const BoxDecoration(
                      color: KuberColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
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
            child: _EmptyState(),
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final double balance;

  const _AccountCard({required this.account, required this.balance});

  @override
  Widget build(BuildContext context) {
    final isCreditCard = account.isCreditCard;
    final balanceLabel = isCreditCard ? 'Credit Utilized' : 'Available Balance';
    final balanceColor =
        (isCreditCard && balance > 0) ? KuberColors.expense : KuberColors.textPrimary;
    final accentColor = _resolveColor(account);

    return Container(
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + name/type + menu
          Row(
            children: [
              CategoryIcon.circle(
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: KuberColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _accountTypeLabel(account),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: KuberColors.textMuted,
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
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: KuberColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),

          // Balance amount + credit limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${balance.abs().toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: balanceColor,
                  letterSpacing: -0.5,
                ),
              ),
              if (isCreditCard && account.creditLimit != null)
                Text(
                  'Limit  ₹${account.creditLimit!.toStringAsFixed(0)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: KuberColors.textMuted,
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
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: KuberColors.textSecondary,
        size: 20,
      ),
      color: KuberColors.surfaceElement,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (val) => _handleAction(context, ref, val),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit',
              style: GoogleFonts.plusJakartaSans(
                  color: KuberColors.textPrimary)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('Delete',
              style:
                  GoogleFonts.plusJakartaSans(color: KuberColors.expense)),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    if (action == 'edit') {
      _openAccountSheet(context, account: account);
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: KuberColors.surfaceCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete account?',
            style: GoogleFonts.plusJakartaSans(
              color: KuberColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'All transactions linked to "${account.name}" will be unlinked.',
            style:
                GoogleFonts.plusJakartaSans(color: KuberColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: GoogleFonts.plusJakartaSans(
                      color: KuberColors.textSecondary)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: KuberColors.expense,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ref
                    .read(accountListProvider.notifier)
                    .delete(account.id);
                Navigator.pop(context);
              },
              child: Text('Delete',
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }
  }
}

class _NetWorthCard extends StatelessWidget {
  final double netWorth;
  final double totalAssets;
  final double totalDebt;

  const _NetWorthCard({
    required this.netWorth,
    required this.totalAssets,
    required this.totalDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: KuberColors.surfaceElement,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'TOTAL NET WORTH',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KuberColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${netWorth.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: KuberColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NetWorthLegend(
                color: KuberColors.income,
                label: 'Assets',
                amount: totalAssets,
              ),
              const SizedBox(width: 24),
              _NetWorthLegend(
                color: KuberColors.expense,
                label: 'Debt',
                amount: totalDebt,
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

  const _NetWorthLegend({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: KuberColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: KuberColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: KuberColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No accounts yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: KuberColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first account to start tracking',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: KuberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
