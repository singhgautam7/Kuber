import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/utils/icon_mapper.dart';
import 'edit_balance_sheet.dart';

class AccountDetailSheet extends ConsumerWidget {
  final Account account;

  const AccountDetailSheet({super.key, required this.account});

  String _accountTypeLabel(Account account) {
    String label = account.isCreditCard ? 'Credit Card' : 'Savings Account';
    if (account.last4Digits != null) {
      label += ' • **** ${account.last4Digits}';
    }
    return label;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final balanceAsync = ref.watch(accountBalanceProvider(account.id));
    final latestTxnAsync =
        ref.watch(accountLatestTransactionProvider(account.id));

    return KuberBottomSheet(
      title: account.name,
      subtitle: _accountTypeLabel(account),
      leadingIcon: CategoryIcon.square(
        icon: account.icon != null ? IconMapper.fromString(account.icon!) : Icons.account_balance,
        rawColor: account.colorValue != null ? Color(account.colorValue!) : cs.primary,
        size: 48,
      ),
      actions: AppButton(
        label: 'View Transactions',
        icon: Icons.receipt_long_rounded,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () {
          Navigator.of(context).pop();
          ref.read(historyFilterProvider.notifier).clearAll();
          ref.read(historyFilterProvider.notifier).setFilters(
                accountIds: {account.id.toString()},
              );
          context.push('/history');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Value Section
          balanceAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading balance',
                style: GoogleFonts.inter(color: cs.error)),
            data: (balance) {
              if (account.isCreditCard) {
                return _buildCreditCardSection(context, ref, balance);
              } else {
                return _buildBankSection(context, ref, balance);
              }
            },
          ),

          const SizedBox(height: 24),

          // Last Transaction Activity
          latestTxnAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (txn) {
              return Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    txn != null
                        ? 'Last transaction ${DateFormatter.timeAgo(txn.createdAt)}'
                        : 'No transactions yet',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Edit account',
                  icon: Icons.edit_rounded,
                  type: AppButtonType.normal,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/accounts/edit', extra: account);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: account.isCreditCard ? 'Edit limit spent' : 'Edit balance',
                  icon: Icons.account_balance_wallet_rounded,
                  type: AppButtonType.normal,
                  onPressed: () {
                    Navigator.pop(context);
                    final balance = balanceAsync.valueOrNull ?? 0.0;
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(KuberRadius.lg),
                        ),
                      ),
                      builder: (_) => EditBalanceSheet(
                        account: account,
                        currentValue: balance,
                        isCredit: account.isCreditCard,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Delete Account',
            icon: Icons.delete_outline_rounded,
            type: AppButtonType.danger,
            fullWidth: true,
            onPressed: () => _confirmDelete(context, ref),
          ),
      ],
    ),
  );
}

  Widget _buildBankSection(BuildContext context, WidgetRef ref, double balance) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final color = balance < 0 ? cs.error : cs.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT AVAILABLE BALANCE',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          formatter.formatCurrency(balance),
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditCardSection(
      BuildContext context, WidgetRef ref, double balance) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final limit = account.creditLimit ?? 0.1; // avoid div by 0
    final utilized = balance.abs();
    final remaining = (account.creditLimit ?? 0) - utilized;
    final percent = (utilized / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LIMIT SPENT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.formatCurrency(utilized),
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: utilized > 0 ? cs.error : cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOTAL LIMIT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.formatCurrency(account.creditLimit ?? 0),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(percent * 100).toInt()}% Utilized',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Text(
              'REMAINING: ${formatter.formatCurrency(remaining)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(cs.error.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final repo = ref.read(accountRepositoryProvider);
    final hasTxns = await repo.hasTransactions(account.id);

    if (!context.mounted) return;

    if (hasTxns) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text('Cannot delete account',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text(
              'This account has transactions linked to it. To delete this account, delete the linked transactions first.',
              style: GoogleFonts.inter()),
          actions: [
            AppButton(
              label: 'OK',
              type: AppButtonType.primary,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: cs.surface,
          title: Text('Delete Account?',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Text(
              'Are you sure you want to delete ${account.name}? This action cannot be undone.',
              style: GoogleFonts.inter()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.inter()),
            ),
            AppButton(
              label: 'Delete',
              type: AppButtonType.primary,
              onPressed: () {
                ref.read(accountListProvider.notifier).delete(account.id);
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Close sheet
              },
            ),
          ],
        ),
      );
    }
  }

}

