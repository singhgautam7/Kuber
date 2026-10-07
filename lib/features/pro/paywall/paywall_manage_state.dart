import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/info_table.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../settings/redeem_promo_code_sheet.dart';
import '../purchase_states/restore_purchases_flow.dart';
import '../services/purchase_service.dart';
import 'billing_ui_state.dart';
import 'pro_state.dart';

const _kAndroidPackage = 'com.grs.kuber';

/// Manage mode: shown to a user who already holds a real entitlement (paid
/// monthly / yearly / lifetime, a Play Billing trial, or a promo grant). Leads
/// with the animated status hero, then read-only plan details, then hand-offs
/// to Play (Kuber never touches billing state directly).
class PaywallManageSection extends ConsumerWidget {
  final KuberProState proState;
  const PaywallManageSection({super.key, required this.proState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final prices = ref.watch(cachedProductPricesProvider);
    final plan = proState.plan;
    final isPromo = proState.source == ProSource.promo;
    final inTrial = proState.inTrialPhase;

    final planLabel = switch (plan) {
      ProPlan.monthly => 'Monthly',
      ProPlan.yearly => 'Yearly',
      ProPlan.lifetime => 'Lifetime',
      null => isPromo ? 'Promo' : 'Pro',
    };
    final planValue = switch (plan) {
      ProPlan.monthly =>
        'Monthly · ${_price(kProMonthlyId, prices, '₹119')}/mo',
      ProPlan.yearly => 'Yearly · ${_price(kProYearlyId, prices, '₹1,099')}/yr',
      ProPlan.lifetime =>
        'Lifetime · ${_price(kProLifetimeId, prices, '₹2,199')}',
      null => isPromo ? 'Kuber Pro (promo)' : 'Kuber Pro',
    };

    // The status row swaps by state (only truthful states — scheduled-cancel is
    // not detectable from in_app_purchase, so it is omitted; Play shows it).
    final (String statusLabel, String statusValue, Color statusColor) =
        _statusRow(cs, context.kuberMoney.income, plan, inTrial, isPromo);

    final rows = <InfoTableRow>[
      InfoTableDataRow(label: 'Plan', value: planValue),
      if (proState.activatedAt != null)
        InfoTableDataRow(
          label: 'Purchased',
          value: _shortDate(proState.activatedAt!),
        ),
      InfoTableHighlightRow(
        label: statusLabel,
        value: statusValue,
        valueColor: statusColor,
      ),
    ];

    final showManageOnPlay = plan != null; // a real subscription/lifetime
    final showCancel =
        plan == ProPlan.monthly || plan == ProPlan.yearly; // recurring only

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHero(proState: proState, planLabel: planLabel),
        if (inTrial) ...[
          const SizedBox(height: KuberSpace.md),
          Center(child: _TrialCountdownPill(daysLeft: proState.trialDaysLeft)),
          const SizedBox(height: KuberSpace.sm),
          Text(
            'You won\'t be charged until the trial ends. Cancel anytime in '
            'Play Store.',
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: KuberSpace.xl),
        Text(
          'Your plan',
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        InfoTable(rows: rows),
        const SizedBox(height: KuberSpace.lg),
        if (showManageOnPlay) ...[
          AppButton(
            label: 'Manage on Play Store',
            type: AppButtonType.outline,
            fullWidth: true,
            height: 48,
            icon: Icons.open_in_new_rounded,
            iconAfterLabel: true,
            onPressed: () => _openPlaySubscriptions(plan),
          ),
          const SizedBox(height: KuberSpace.sm),
        ],
        if (showCancel) ...[
          AppButton(
            label: 'Cancel subscription',
            type: AppButtonType.danger,
            fullWidth: true,
            height: 48,
            onPressed: () => _openPlaySubscriptions(plan),
          ),
          const SizedBox(height: KuberSpace.sm),
        ],
        AppButton(
          label: 'Restore purchases',
          type: AppButtonType.outline,
          fullWidth: true,
          height: 48,
          onPressed: () => restorePurchases(context, ref),
        ),
        const SizedBox(height: KuberSpace.sm),
        AppButton(
          label: 'Redeem promo code',
          type: AppButtonType.outline,
          fullWidth: true,
          height: 48,
          onPressed: () => showRedeemPromoCodeSheet(context, ref),
        ),
        const SizedBox(height: KuberSpace.lg),
        Text(
          'Thanks for backing Kuber. Every subscription funds a solo developer '
          'building this fully offline, ad-free, and account-free.',
          style: localeFont(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  (String, String, Color) _statusRow(
    ColorScheme cs,
    Color income,
    ProPlan? plan,
    bool inTrial,
    bool isPromo,
  ) {
    if (plan == ProPlan.lifetime) {
      return ('Status', 'Lifetime access, no expiry', cs.onSurface);
    }
    if (inTrial && proState.trialEndsAt != null) {
      return (
        'First charge',
        'Free trial ends ${_shortDate(proState.trialEndsAt!)}. You\'ll be charged then.',
        cs.primary,
      );
    }
    if (isPromo) {
      final v = proState.promoEndsAt == null
          ? 'Active, no expiry'
          : 'Active until ${_shortDate(proState.promoEndsAt!)}';
      return ('Status', v, income);
    }
    if (proState.expiryDate != null) {
      return (
        'Status',
        'Renews on ${_shortDate(proState.expiryDate!)}',
        income,
      );
    }
    return ('Status', 'Active', income);
  }

  void _openPlaySubscriptions(ProPlan? plan) {
    final sku = plan != null ? productIdForPlan(plan) : null;
    final uri = sku != null
        ? 'https://play.google.com/store/account/subscriptions'
              '?sku=$sku&package=$_kAndroidPackage'
        : 'https://play.google.com/store/account/subscriptions';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  String _price(String id, Map<String, String> cached, String fallback) =>
      cached[id] ?? fallback;
}

class _TrialCountdownPill extends StatelessWidget {
  final int daysLeft;
  const _TrialCountdownPill({required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberShape.full),
        border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        daysLeft == 1 ? 'Trial ends in 1 day' : 'Trial ends in $daysLeft days',
        style: localeFont(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.primary,
        ),
      ),
    );
  }
}

/// Animated status card: a slow pulsing glow behind a crown mark, "N days as
/// Pro", and the plan/promo label. Echoes the Ask Kuber mark's living-glow
/// treatment. The pulse is isolated in a `RepaintBoundary` so its 60 Hz repaint
/// does not propagate to the rest of the page.
class _StatusHero extends StatefulWidget {
  final KuberProState proState;
  final String planLabel;
  const _StatusHero({required this.proState, required this.planLabel});

  @override
  State<_StatusHero> createState() => _StatusHeroState();
}

class _StatusHeroState extends State<_StatusHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trial = widget.proState.inTrialPhase;
    final days = widget.proState.daysSincePremium;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: KuberSpace.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = Curves.easeInOut.transform(_controller.value);
                // Board 3.14: solid primary tile, no glow; same pulse.
                return SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: 1.0 + t * 0.04,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: KuberShape.largeR,
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: cs.onPrimary,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: KuberSpace.md),
            Text(
              trial ? 'You\'re on a free trial' : 'You\'re on Kuber Pro',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall!.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              trial
                  ? '${widget.planLabel} plan · trial'
                  : days > 0
                  ? '${widget.planLabel} · $days ${days == 1 ? 'day' : 'days'} as Pro'
                  : '${widget.planLabel} · active today',
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortDate(DateTime d) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
