import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../shared/widgets/add_new_button.dart';
import '../../accounts/providers/account_provider.dart';

class AccountPickerSheet extends ConsumerWidget {
  final int? selectedAccountId;
  final ValueChanged<int> onSelected;
  final int? excludeAccountId;

  const AccountPickerSheet({
    super.key,
    required this.selectedAccountId,
    required this.onSelected,
    this.excludeAccountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final accounts = ref.watch(accountListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg,
            KuberSpacing.sm,
            KuberSpacing.lg,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: KuberColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),

              // Title + subtitle
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Account',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: KuberColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose the account for this transaction',
                        style: textTheme.bodySmall?.copyWith(
                          color: KuberColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: KuberColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],
          ),
        ),

        // Account list
        Flexible(
          child: accounts.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Center(
              child: Text('Error: $e'),
            ),
            data: (allAccs) {
              final accs = excludeAccountId != null
                  ? allAccs.where((a) => a.id != excludeAccountId).toList()
                  : allAccs;
              if (accs.isEmpty) {
                return Center(
                  child: Text(
                    'No accounts yet',
                    style: textTheme.bodyMedium?.copyWith(
                      color: KuberColors.textSecondary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                itemCount: accs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: KuberSpacing.sm),
                itemBuilder: (context, index) {
                  final acc = accs[index];
                  final selected = acc.id == selectedAccountId;
                  final color = resolveAccountColor(acc);

                  return _AccountTile(
                    name: acc.name,
                    type: acc.isCreditCard ? 'CREDIT CARD' : acc.type.toUpperCase(),
                    icon: resolveAccountIcon(acc),
                    color: color,
                    selected: selected,
                    balance: ref.watch(accountBalanceProvider(acc.id)),
                    isCreditCard: acc.isCreditCard,
                    creditLimit: acc.creditLimit,
                    onTap: () => onSelected(acc.id),
                  );
                },
              );
            },
          ),
        ),

        // Add new account button
        AddNewButton(
          label: 'Add new account',
          onTap: () {
            Navigator.pop(context);
            GoRouter.of(context).push('/more/accounts');
          },
        ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  final bool selected;
  final AsyncValue<double> balance;
  final bool isCreditCard;
  final double? creditLimit;
  final VoidCallback onTap;

  const _AccountTile({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.selected,
    required this.balance,
    this.isCreditCard = false,
    this.creditLimit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : KuberColors.surfaceMuted,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? color : KuberColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.bodyMedium?.copyWith(
                      color: KuberColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    type,
                    style: textTheme.labelSmall?.copyWith(
                      color: KuberColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            balance.when(
              loading: () => SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: KuberColors.textSecondary,
                ),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (bal) {
                final display = isCreditCard && creditLimit != null
                    ? '₹${bal.abs().toStringAsFixed(0)} / ₹${creditLimit!.toStringAsFixed(0)}'
                    : '₹${bal.abs().toStringAsFixed(0)}';
                return Text(
                  display,
                  style: textTheme.bodyMedium?.copyWith(
                    color: KuberColors.textSecondary,
                  ),
                );
              },
            ),
            if (selected) ...[
              const SizedBox(width: KuberSpacing.sm),
              Icon(Icons.check_circle, size: 20, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

