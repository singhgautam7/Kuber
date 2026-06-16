// Overhauled Accounts page — replaces the body of
// `lib/features/accounts/screens/accounts_screen.dart`.
//
// Drop-in: keeps the existing top chrome (KuberAppBar + KuberPageHeader),
// auto-info-sheet listener, and trigger-add-account listener. Only the
// scrollable body content changes:
//   - Net worth becomes a hero card with trend pill, sparkline, and a
//     calmer Assets/Debt split (single divided bar instead of two equal
//     numbers fighting for attention).
//   - Account cards rebuilt: type/last4 in a meta row under the name,
//     inline DEFAULT pill, per-card quick-add button, credit-card
//     utilization bar, and an optional last-activity strip.
//   - Negative balances no longer render in giant red. The amount stays
//     in `onSurface`; the "Outstanding" label and the utilization fill
//     carry the semantic colour. Color used as signal, not shouting.
//
// State: the screen pulls from the existing providers — no new providers,
// no schema changes. The last-activity strip needs a per-account "most
// recent transaction" provider; the relevant TODO is marked below.

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/info_provider.dart';
import '../../settings/providers/settings_provider.dart' show settingsProvider;
import '../data/account.dart';
import '../providers/account_provider.dart';
import '../widgets/account_detail_sheet.dart';
import '../widgets/net_worth_hero_card.dart';
import '../widgets/account_card.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    // Manage Accounts shows every account, including disabled ones, so the user
    // can re-enable them. Net worth still excludes disabled balances (below).
    final accountsAsync = ref.watch(allAccountsProvider);

    // Existing listener: add-account trigger from nav bar
    ref.listen<bool>(triggerAddAccountProvider, (_, triggered) {
      if (triggered) {
        ref.read(triggerAddAccountProvider.notifier).state = false;
        context.push('/accounts/add');
      }
    });

    // Existing listener: auto-info sheet
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoAccounts), (
      prev,
      next,
    ) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.accounts);
          ref
              .read(infoSeenProvider(PrefsKeys.seenInfoAccounts).notifier)
              .markSeen();
        });
      }
    });

    return Scaffold(
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: localeFont(color: cs.onSurfaceVariant),
          ),
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
    // Sum balances. We watch one provider per account; mirrors the existing
    // implementation. With 50+ accounts this should be batched via a single
    // aggregate provider, but that's outside the scope of this design pass.
    double totalAssets = 0;
    double totalDebt = 0;
    final balances = <int, double>{};

    for (final a in accounts) {
      final b =
          ref.watch(accountBalanceProvider(a.id)).valueOrNull ??
          a.initialBalance;
      balances[a.id] = b;
      // Disabled accounts stay in the list (muted) but don't contribute to net
      // worth, assets, or debt.
      if (a.isDisabled) continue;
      if (b > 0) {
        totalAssets += b;
      } else if (b < 0) {
        totalDebt += b.abs();
      }
    }
    final netWorth = totalAssets - totalDebt;

    final defaultId = ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
    );

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: KuberAppBar(
            showBack: true,
            showHome: true,
            title: '',
            infoConfig: InfoConstants.accounts,
          ),
        ),
        SliverToBoxAdapter(
          child: KuberPageHeader(
            title: context.l10n.manageAccounts,
            description: '',
            actionTooltip: context.l10n.addAccount,
            onAction: () => context.push('/accounts/add'),
          ),
        ),

        // Hero — only when there's something to show
        if (accounts.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.lg,
            ),
            sliver: SliverToBoxAdapter(
              child: NetWorthHeroCard(
                netWorth: netWorth,
                totalAssets: totalAssets,
                totalDebt: totalDebt,
              ),
            ),
          ),

        // Empty state
        if (accounts.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: KuberEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: context.l10n.noAccountsYet,
              description: context.l10n.addFirstAccount,
              actionLabel: context.l10n.addAccount,
              onAction: () => context.push('/accounts/add'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList.separated(
              itemCount: accounts.length + 1, // +1 for "Add another"
              separatorBuilder: (_, i) => SizedBox(
                height: i == accounts.length - 1
                    ? KuberSpacing.lg
                    : KuberSpacing.sm + 2,
              ),
              itemBuilder: (ctx, i) {
                if (i == accounts.length) {
                  return _AddAnotherAccountChip(
                    onTap: () => context.push('/accounts/add'),
                  );
                }
                final a = accounts[i];
                return AccountCard(
                  account: a,
                  balance: balances[a.id] ?? a.initialBalance,
                  isDefault: a.id.toString() == defaultId,
                  onTap: () => _openDetailSheet(context, a),
                  onQuickAdd: () {
                    // TODO: route to AddTransactionScreen with this account
                    // pre-selected. The simplest hook is to push
                    // `/add-transaction?accountId=${a.id}` and have
                    // AddTransactionScreen read that query param.
                    context.push('/add-transaction?accountId=${a.id}');
                  },
                );
              },
            ),
          ),

        SliverToBoxAdapter(
          child: SizedBox(height: navBarBottomPadding(context)),
        ),
      ],
    );
  }

  void _openDetailSheet(BuildContext context, Account account) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AccountDetailSheet(account: account),
    );
  }
}

class _AddAnotherAccountChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAnotherAccountChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.lg),
      child: DottedBorderBox(
        color: cs.outlineVariant,
        radius: KuberRadius.lg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: KuberSpacing.sm),
              Text(
                context.l10n.addAnotherAccount,
                style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cheap dashed-border container that doesn't add a package dependency.
/// Paints a 1px dashed outline using `CustomPaint` and `PathMetrics`.
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = KuberRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// Helpers kept identical to the existing screen for parity ------------------

String accountTypeLabel(Account account) {
  String label;
  if (account.isCreditCard) {
    label = 'CREDIT CARD';
  } else {
    switch (account.type.toLowerCase()) {
      case 'bank':
        label = 'BANK';
      case 'card':
        label = 'CREDIT CARD';
      case 'wallet':
        label = 'WALLET';
      case 'cash':
        label = 'CASH';
      default:
        label = account.type.toUpperCase();
    }
  }
  return label;
}

IconData accountIcon(Account a) => resolveAccountIcon(a);
Color accountColor(Account a) => resolveAccountColor(a);