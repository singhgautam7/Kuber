// One account row in the Accounts grouped list (board 3.15): 40 tile in the
// account colour (re-toned), name + Default pill, type (· **** last4) under
// it, balance on the right. Credit cards add the wavy utilisation bar with
// "18% used" and the limit. Disabled accounts stay in the list, dimmed, with
// "· Disabled" on the type line.

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../data/account.dart';

class AccountCard extends ConsumerWidget {
  final Account account;
  final double balance;
  final bool isDefault;
  final VoidCallback onTap;

  const AccountCard({
    super.key,
    required this.account,
    required this.balance,
    required this.isDefault,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);
    final isCC = account.isCreditCard;
    final tones = categoryTones(context, resolveAccountColor(account));

    // Credit cards show the outstanding as a negative amount in the expense
    // colour; other accounts show "−" only when genuinely negative.
    final negative = balance < 0;
    final amount = maskAmount(
      '${negative ? '−' : ''}${fmt.formatCurrency(balance.abs())}',
      masked,
    );
    final typeLine = [
      _typeFor(context, account),
      if (account.last4Digits != null) '**** ${account.last4Digits}',
      if (account.isDisabled) context.l10n.disabledLabel,
    ].join(' · ');

    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tones.container,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Icon(
                  resolveAccountIcon(account),
                  size: 20,
                  color: tones.fg,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          KuberPill(
                            label: sentenceCase(context.l10n.defaultUpper),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      typeLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: negative ? context.kuberMoney.expense : cs.onSurface,
                ),
              ),
            ],
          ),
          if (isCC && account.creditLimit != null) ...[
            const SizedBox(height: 10),
            _Utilization(
              outstanding: balance.abs(),
              limit: account.creditLimit!,
              limitText: maskAmount(
                fmt.formatCurrency(account.creditLimit!),
                masked,
              ),
            ),
          ],
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      child: account.isDisabled ? Opacity(opacity: 0.38, child: row) : row,
    );
  }

  String _typeFor(BuildContext context, Account a) {
    if (a.isCreditCard) return context.l10n.creditCardLabel;
    switch (a.type.toLowerCase()) {
      case 'bank':
        return context.l10n.bankLabel;
      case 'credit_card':
        return context.l10n.creditCardLabel;
      case 'wallet':
        return context.l10n.walletLabel;
      case 'cash':
        return context.l10n.cashLabel;
      default:
        return a.type;
    }
  }
}

/// Wavy M3 bar + "18% used" and the limit. Existing thresholds: <30%
/// normal, <100% near limit, 100%+ over limit.
class _Utilization extends StatelessWidget {
  final double outstanding;
  final double limit;
  final String limitText;
  const _Utilization({
    required this.outstanding,
    required this.limit,
    required this.limitText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawPct = limit <= 0 ? 0.0 : outstanding / limit;
    final pct = rawPct.clamp(0.0, 1.0);
    final state = rawPct >= 1.0
        ? KuberProgressState.overLimit
        : rawPct < 0.30
        ? KuberProgressState.normal
        : KuberProgressState.nearLimit;
    final small = Theme.of(
      context,
    ).textTheme.labelSmall!.copyWith(color: cs.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberLinearProgress(value: pct, state: state),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                '${(pct * 100).toStringAsFixed(0)}% ${context.l10n.usedLabel}',
                style: small,
              ),
            ),
            Text('$limitText ${context.l10n.limitLabel}', style: small),
          ],
        ),
      ],
    );
  }
}
