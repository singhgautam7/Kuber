import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              CategoryIcon.square(
                icon: resolveAccountIcon(account),
                rawColor: resolveAccountColor(account),
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      _accountTypeLabel(account),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHigh,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

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
                        : 'No recent transactions',
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

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/accounts/edit', extra: account);
                  },
                  icon: Icons.edit_rounded,
                  label: 'Edit account',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditBalancePrompt(context, ref, balanceAsync.valueOrNull ?? 0.0);
                  },
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Edit balance',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                'Delete Account',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),
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
    final utilized = balance; // balance is negated in provider for CC
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
                  'CREDIT UTILIZED',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '-${formatter.formatCurrency(utilized)}',
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Delete Account?',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete ${account.name}? This will unlink all transactions.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            onPressed: () {
              ref.read(accountListProvider.notifier).delete(account.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close sheet
            },
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditBalancePrompt(BuildContext context, WidgetRef ref, double currentBalance) {
    final controller = TextEditingController(text: currentBalance.abs().toString());
    final cs = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('Update Balance', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter the new initial balance for this account:', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                prefixText: '${ref.read(currencyProvider).symbol} ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          FilledButton(
            onPressed: () {
              final newBal = double.tryParse(controller.text) ?? currentBalance;
              final updated = account..initialBalance = newBal;
              ref.read(accountListProvider.notifier).add(updated);
              Navigator.pop(ctx);
            },
            child: Text('Update', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: cs.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
