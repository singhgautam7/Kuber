// Overhauled horizontal Accounts rail for the Home dashboard.
//
// Drop-in replacement for `lib/features/dashboard/widgets/home_accounts_card.dart`.
// Matches the visual language of the new AccountCard on the Accounts page so
// the home rail and the full Accounts screen agree.
//
// Changes vs old version:
//   - Squircle + name + meta-row layout matches AccountCard
//   - No default-account tag in the home rail; the full Accounts page owns
//     that detail.
//   - Negative amounts: no giant red number. For CC, the label
//     "OUTSTANDING" carries the colour; the value stays in onSurface.
//     For bank/cash, a "−" prefix is enough.
//   - Credit cards show a small utilization bar + "X% used / ₹Y limit"
//   - Cards are 220px wide (1.6 visible at a time on a 360-wide phone)
//
// Same provider wiring as before (accountListProvider, accountBalanceProvider,
// formatterProvider, privacyModeProvider, settingsProvider).

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../core/utils/color_harmonizer.dart';

import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

class HomeAccountsCard extends ConsumerWidget {
  const HomeAccountsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountListProvider);
    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (accounts) {
        if (accounts.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberHomeWidgetTitle(
                title: context.l10n.accountsLabel,
                trailing: KuberSectionAction(
                  label: sentenceCase(context.l10n.viewAll),
                  onTap: () => context.push('/more/accounts'),
                ),
              ),
              // Sized by its tallest tile (all tiles stretch to match), so
              // there is no reserved gap under shorter tiles (review round 2).
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < accounts.length; i++) ...[
                        if (i > 0) const SizedBox(width: KuberSpace.cardGap),
                        _HomeAccountTile(
                          account: accounts[i],
                          balance:
                              ref
                                  .watch(accountBalanceProvider(accounts[i].id))
                                  .valueOrNull ??
                              accounts[i].initialBalance,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              useRootNavigator: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) =>
                                  AccountDetailSheet(account: accounts[i]),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeAccountTile extends ConsumerWidget {
  final Account account;
  final double balance;
  final VoidCallback onTap;
  const _HomeAccountTile({
    required this.account,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final masked = ref.watch(privacyModeProvider);

    final isCC = account.isCreditCard;
    final accentColor = resolveAccountColor(account);

    // For CC, `balance` is OUTSTANDING (negative). We render the absolute
    // outstanding under an "OUTSTANDING" label that carries the colour.
    final amountText = isCC
        ? maskAmount(fmt.formatCurrency(balance.abs()), masked)
        : maskAmount(
            '${balance < 0 ? '−' : ''}${fmt.formatCurrency(balance.abs())}',
            masked,
          );

    final theme = Theme.of(context);
    final tones = categoryTones(context, accentColor);
    final hasUtil = isCC && account.creditLimit != null;
    final utilPct = hasUtil && account.creditLimit! > 0
        ? balance.abs() / account.creditLimit!
        : 0.0;
    // Existing thresholds: <30% normal, <100% near limit, 100%+ over.
    final utilState = utilPct >= 1.0
        ? KuberProgressState.overLimit
        : utilPct < 0.30
        ? KuberProgressState.normal
        : KuberProgressState.nearLimit;
    final typeLine = account.last4Digits != null
        ? '${_typeLabel(context, account)} · **** ${account.last4Digits}'
        : _typeLabel(context, account);

    // Board 3.2a: 200 wide, radius 20, 36 tile in the account colour
    // re-toned, titleLarge balance.
    return SizedBox(
      width: 200,
      child: KuberCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tones.container,
                    borderRadius: KuberShape.mediumR,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    resolveAccountIcon(account),
                    size: 20,
                    color: tones.fg,
                  ),
                ),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        typeLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Every tile is the same height (review round 2): a credit card's
            // utilisation bar sits in the 16 gap the other tiles leave, and
            // "18% used" shares the label line.
            if (hasUtil)
              // Wavy M3 bar is 12 tall: 2 + 12 + 2 = the 16 gap.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: KuberLinearProgress(
                  value: utilPct.clamp(0.0, 1.0),
                  state: utilState,
                ),
              )
            else
              const SizedBox(height: KuberSpace.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    sentenceCase(
                      isCC
                          ? context.l10n.outstandingLabel
                          : context.l10n.availableLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: isCC && balance < 0
                          ? context.kuberMoney.expense
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (hasUtil)
                  Text(
                    '${(utilPct.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}% ${context.l10n.usedLabel}',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            Text(
              amountText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge!.copyWith(color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(BuildContext context, Account a) {
    if (a.isCreditCard) return context.l10n.creditCardLabel;
    return switch (a.type.toLowerCase()) {
      'bank' => context.l10n.bankLabel,
      'wallet' => context.l10n.walletLabel,
      'cash' => context.l10n.cashLabel,
      _ => a.type,
    };
  }
}
