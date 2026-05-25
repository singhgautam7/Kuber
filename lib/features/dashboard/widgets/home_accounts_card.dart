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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return accountsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
              height: 152,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final account = accounts[i];
                  final balance =
                      ref
                          .watch(accountBalanceProvider(account.id))
                          .valueOrNull ??
                      account.initialBalance;
                  return _HomeAccountTile(
                    account: account,
                    balance: balance,
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

    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.30),
                      ),
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      resolveAccountIcon(account),
                      size: 18,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Text(
                              _typeLabel(account).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (account.last4Digits != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '· **** ${account.last4Digits}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isCC ? 'OUTSTANDING' : 'AVAILABLE',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isCC && balance < 0 ? cs.error : cs.onSurfaceVariant,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                amountText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              if (isCC && account.creditLimit != null) ...[
                const SizedBox(height: 8),
                _MiniUtilization(
                  outstanding: balance.abs(),
                  limit: account.creditLimit!,
                  fmt: fmt,
                  masked: masked,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _typeLabel(Account a) {
    if (a.isCreditCard) return 'Credit Card';
    return switch (a.type.toLowerCase()) {
      'bank' => 'Bank',
      'wallet' => 'Wallet',
      'cash' => 'Cash',
      _ => a.type,
    };
  }
}

class _MiniUtilization extends StatelessWidget {
  final double outstanding;
  final double limit;
  final dynamic fmt;
  final bool masked;
  const _MiniUtilization({
    required this.outstanding,
    required this.limit,
    required this.fmt,
    required this.masked,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rawPct = limit <= 0 ? 0.0 : outstanding / limit;
    final pct = rawPct.clamp(0.0, 1.0);
    final fillColor = rawPct >= 1.0
        ? cs.error
        : rawPct < 0.30
        ? cs.tertiary
        : const Color(0xFFF59E0B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(color: cs.surfaceContainerHigh),
                FractionallySizedBox(
                  widthFactor: pct,
                  child: Container(color: fillColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text.rich(
              TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '${(pct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const TextSpan(text: ' used'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${maskAmount(fmt.formatCurrency(limit), masked)} limit',
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
