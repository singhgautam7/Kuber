import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_chips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/overflow_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_app_bar.dart';
import '../../../../shared/widgets/kuber_comparison_table.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../settings/redeem_promo_code_sheet.dart';
import '../support/buy_me_coffee_section.dart' show BuyMeCoffeeButton;
import '../purchase_states/restore_purchases_flow.dart';
import '../services/billing_diagnostics.dart';
import '../services/purchase_service.dart';
import 'billing_ui_state.dart';
import 'paywall_error_state.dart';
import 'paywall_loading_state.dart';
import 'paywall_manage_state.dart';
import 'pro_page_extras.dart';
import 'pro_state.dart';
import 'subscription_offer.dart';

/// Play Store package id, for the subscription-management deeplink.
const _kAndroidPackage = 'com.grs.kuber';

/// Route: `/pro`. A single full-screen page that adapts to every entitlement
/// state, split into two macro-modes (see specs pro-page-redesign):
///  - **Sell** (free / lapsed) and the grandfathered legacy trial: pitch + plan
///    cards + a sticky Continue.
///  - **Manage** (paid active / Play Billing trial / promo): status hero +
///    read-only plan details + hand-offs to Play.
/// The manage-vs-sell decision keys off `isPro` (a real entitlement), not
/// `hasProAccess`.
class KuberProPaywallScreen extends ConsumerStatefulWidget {
  const KuberProPaywallScreen({super.key});

  @override
  ConsumerState<KuberProPaywallScreen> createState() =>
      _KuberProPaywallScreenState();
}

class _KuberProPaywallScreenState extends ConsumerState<KuberProPaywallScreen> {
  ProPlan _selected = ProPlan.yearly;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final offers = ref.watch(subscriptionOffersProvider);
    final yearlyOffer = offers[kProYearlyId];

    final isManage = proState.isPro; // purchased or promo
    final isGrandfathered = proState.isTrial; // legacy app trial (unpaid)
    final subscribed = proState.isPro && proState.plan != null;
    final restoreFailed = ref.watch(restoreFailedSessionProvider);

    final overflowItems = <KuberOverflowItem>[
      KuberOverflowItem(
        icon: Icons.restore_rounded,
        label: 'Restore purchases',
        onTap: () => restorePurchases(context, ref),
      ),
      KuberOverflowItem(
        icon: Icons.redeem_rounded,
        label: 'Redeem promo code',
        onTap: () => showRedeemPromoCodeSheet(context, ref),
      ),
      if (restoreFailed)
        KuberOverflowItem(
          icon: Icons.bug_report_outlined,
          label: 'Report a billing issue',
          onTap: () => _reportBillingIssue(context),
        ),
      if (subscribed)
        KuberOverflowItem(
          icon: Icons.open_in_new_rounded,
          label: 'Manage on Play Store',
          onTap: _openPlaySubscriptions,
        ),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: KuberAppBar(
                    title: 'Kuber Pro',
                    subtitle: _headerSubtitle(proState),
                    showBack: true,
                    infoConfig: kAboutProInfoConfig,
                    overflowConfig: KuberOverflowConfig(items: overflowItems),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.lg,
                    0,
                    KuberSpace.lg,
                    KuberSpace.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      isManage
                          ? _manageBody(proState)
                          : isGrandfathered
                          ? _grandfatheredBody(proState)
                          : _sellBody(proState, yearlyOffer),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: (!isManage)
          ? _StickyContinue(child: _continueButton(yearlyOffer))
          : null,
    );
  }

  String _headerSubtitle(KuberProState s) {
    if (s.isPro) {
      return s.inTrialPhase ? 'Trial active' : 'You\'re on Pro';
    }
    if (s.isTrial) return 'Legacy trial';
    return 'Unlock everything Kuber offers';
  }

  // ── Sell mode (free / lapsed) ───────────────────────────────────────────
  List<Widget> _sellBody(KuberProState proState, SubscriptionOfferInfo? offer) {
    final hadPrior = ref.watch(hadPriorProProvider);
    return [
      if (hadPrior) ...[
        const _WelcomeBackCard(),
        const SizedBox(height: KuberSpace.lg),
      ],
      const _SellHero(),
      const SizedBox(height: KuberSpace.xl),
      if (offer != null && offer.hasIntroBenefit) ...[
        _OfferBadge(offer: offer),
        const SizedBox(height: KuberSpace.xl),
      ],
      _sectionLabel('CHOOSE A PLAN'),
      const SizedBox(height: KuberSpace.sm),
      ..._planCards(offer),
      const SizedBox(height: KuberSpace.xl),
      _sectionTitle('What you get with Pro'),
      const SizedBox(height: KuberSpace.sm),
      const KuberComparisonTable(rows: kProComparisonRows),
      const SizedBox(height: KuberSpace.xl),
      const _TipJarSection(),
      const SizedBox(height: KuberSpace.xl),
      const _TrustFooter(),
    ];
  }

  // ── Manage mode (paid / Play trial / promo) ─────────────────────────────
  List<Widget> _manageBody(KuberProState proState) {
    return [
      PaywallManageSection(proState: proState),
      const SizedBox(height: KuberSpace.xl),
      _sectionTitle('What Pro includes'),
      const SizedBox(height: KuberSpace.sm),
      const KuberComparisonTable(rows: kProComparisonRows),
    ];
  }

  // ── Grandfathered legacy trial (manage-lite + sell plans) ───────────────
  List<Widget> _grandfatheredBody(KuberProState proState) {
    return [
      _LegacyTrialCard(proState: proState),
      const SizedBox(height: KuberSpace.lg),
      _sectionLabel('SUBSCRIBE TO KEEP PRO'),
      const SizedBox(height: KuberSpace.sm),
      ..._planCards(ref.watch(subscriptionOffersProvider)[kProYearlyId]),
      const SizedBox(height: KuberSpace.xl),
      _sectionTitle('What you get with Pro'),
      const SizedBox(height: KuberSpace.sm),
      const KuberComparisonTable(rows: kProComparisonRows),
    ];
  }

  // ── Plan cards (radio) ──────────────────────────────────────────────────
  List<Widget> _planCards(SubscriptionOfferInfo? yearlyOffer) {
    final loading = ref.watch(productsLoadingProvider);
    final error = ref.watch(productsErrorProvider);
    final prices = ref.watch(cachedProductPricesProvider);

    if (loading) return [const PaywallPricingSkeleton()];
    if (error && prices.isEmpty) {
      return [
        PaywallProductsErrorState(
          onRetry: () =>
              ref.read(purchaseServiceProvider).loadProducts(kAllProductIds),
        ),
      ];
    }

    final yearlyBenefit = (yearlyOffer?.hasIntroBenefit ?? false)
        ? '1 year free, then ${_price(ProPlan.yearly, prices)}/yr'
        : 'Save 23% vs monthly';

    return [
      _PlanCard(
        plan: ProPlan.monthly,
        title: 'Monthly',
        price: _price(ProPlan.monthly, prices),
        suffix: '/mo',
        benefit: 'Try Pro month by month',
        selected: _selected == ProPlan.monthly,
        onTap: () => setState(() => _selected = ProPlan.monthly),
      ),
      const SizedBox(height: KuberSpace.sm),
      _PlanCard(
        plan: ProPlan.yearly,
        title: 'Yearly',
        price: _price(ProPlan.yearly, prices),
        suffix: '/yr',
        benefit: yearlyBenefit,
        benefitAccent: yearlyOffer?.hasIntroBenefit ?? false,
        tag: _PlanTag.bestValue,
        selected: _selected == ProPlan.yearly,
        onTap: () => setState(() => _selected = ProPlan.yearly),
      ),
      const SizedBox(height: KuberSpace.sm),
      _PlanCard(
        plan: ProPlan.lifetime,
        title: 'Lifetime',
        price: _price(ProPlan.lifetime, prices),
        suffix: '',
        benefit: 'Pay once, use forever',
        tag: _PlanTag.payOnce,
        selected: _selected == ProPlan.lifetime,
        onTap: () => setState(() => _selected = ProPlan.lifetime),
      ),
    ];
  }

  Widget _continueButton(SubscriptionOfferInfo? yearlyOffer) {
    final prices = ref.watch(cachedProductPricesProvider);
    final price = _price(_selected, prices);
    final label = switch (_selected) {
      ProPlan.monthly => 'Continue with Monthly · $price/mo',
      ProPlan.yearly =>
        (yearlyOffer?.hasIntroBenefit ?? false)
            ? 'Start free year · then $price/yr'
            : 'Continue with Yearly · $price/yr',
      ProPlan.lifetime => 'Continue with Lifetime · $price',
    };
    return AppButton(
      label: label,
      type: AppButtonType.primary,
      fullWidth: true,
      height: 48,
      onPressed: () => ref
          .read(purchaseServiceProvider)
          .buyProduct(productIdForPlan(_selected)),
    );
  }

  String _price(ProPlan p, Map<String, String> cached) => switch (p) {
    ProPlan.monthly => cached[kProMonthlyId] ?? '₹119',
    ProPlan.yearly => cached[kProYearlyId] ?? '₹1,099',
    ProPlan.lifetime => cached[kProLifetimeId] ?? '₹2,199',
  };

  void _openPlaySubscriptions() {
    final sku = ref.read(kuberProStateProvider).plan;
    final skuId = sku != null ? productIdForPlan(sku) : null;
    final uri = skuId != null
        ? 'https://play.google.com/store/account/subscriptions'
              '?sku=$skuId&package=$_kAndroidPackage'
        : 'https://play.google.com/store/account/subscriptions';
    launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
  }

  Future<void> _reportBillingIssue(BuildContext context) async {
    final report = await BillingDiagnostics.instance
        .generateDiagnosticsReport();
    const subject = '[Kuber Billing Issue] Restore Failed';
    final body =
        '''
Please describe the issue you encountered:
(e.g., I purchased Lifetime on another device, but tapping Restore purchases says "No purchase found")

---
$report
''';

    final uri = Uri.parse(
      'mailto:singhgautam.dev@gmail.com'
      '?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );

    if (!await launchUrl(uri)) {
      if (context.mounted) {
        showKuberSnackBar(
          context,
          'Could not open email app. You can copy diagnostics from Dev Tools.',
          isError: true,
        );
      }
    }
  }

  Widget _sectionLabel(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: localeFont(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }
}

/// Contained primary radial glow blended into the page background near the top,
/// echoing the Ask Kuber welcome view. A static gradient fill (no ticker, no
/// `BoxShadow`), so every card on top stays flat and legible.
// ── Sell-mode pieces ────────────────────────────────────────────────────────

/// Sell hero (board 3.14): centred 56 primary tile, headlineMedium title,
/// body copy and outlined trust chips. No card, no glow.
class _SellHero extends StatelessWidget {
  const _SellHero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: KuberShape.largeR,
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: cs.onPrimary,
            size: 28,
          ),
        ),
        const SizedBox(height: KuberSpace.lg),
        Text(
          'Everything Kuber, unlocked.',
          textAlign: TextAlign.center,
          style: tt.headlineMedium!.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: KuberSpace.sm),
        Text(
          'Support development. Get every feature. No accounts, no cloud, '
          'still fully offline.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: KuberSpace.md),
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: KuberSpace.sm,
          runSpacing: KuberSpace.sm,
          children: [
            _TrustChip(icon: Icons.wifi_off_rounded, label: 'Offline'),
            _TrustChip(icon: Icons.lock_outline_rounded, label: 'Private'),
            _TrustChip(icon: Icons.person_off_outlined, label: 'No accounts'),
          ],
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) =>
      KuberChip(label: label, icon: icon, showCheck: false);
}

class _WelcomeBackCard extends StatelessWidget {
  const _WelcomeBackCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: context.kuberMoney.income.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        border: Border.all(color: context.kuberMoney.income),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.waving_hand_rounded,
            size: 20,
            color: context.kuberMoney.income,
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Resubscribe to continue where you left off. Your data is '
                  'still safe on this device.',
                  style: localeFont(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegacyTrialCard extends StatelessWidget {
  final KuberProState proState;
  const _LegacyTrialCard({required this.proState});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberMoney.warning;
    final endsLabel = proState.trialEndsAt != null
        ? 'Access ends on ${_shortDate(proState.trialEndsAt!)}'
        : 'Your legacy trial is ending soon';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: KuberSpace.xl,
            horizontal: KuberSpace.lg,
          ),
          decoration: BoxDecoration(
            color: warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
            border: Border.all(color: warning),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.schedule_rounded, color: warning, size: 26),
              ),
              const SizedBox(height: KuberSpace.md),
              Text(
                'You\'re on a legacy trial',
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endsLabel,
                style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.sm),
            Expanded(
              child: Text(
                'Legacy trial from an earlier version. No card required.',
                style: localeFont(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _PlanTag { none, bestValue, payOnce }

class _PlanCard extends StatelessWidget {
  final ProPlan plan;
  final String title;
  final String price;
  final String suffix;
  final String benefit;
  final bool benefitAccent;
  final _PlanTag tag;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.title,
    required this.price,
    required this.suffix,
    required this.benefit,
    required this.selected,
    required this.onTap,
    this.benefitAccent = false,
    this.tag = _PlanTag.none,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    final sub = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    // Board 3.14: radio card; selected = secondaryContainer + 2dp primary.
    return Material(
      color: selected ? cs.secondaryContainer : cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: selected
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.lg),
          child: Row(
            children: [
              _Radio(selected: selected),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: KuberSpace.sm,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: tt.titleMedium!.copyWith(color: fg)),
                        if (tag != _PlanTag.none)
                          KuberPill(
                            label: tag == _PlanTag.bestValue
                                ? 'BEST VALUE'
                                : 'PAY ONCE',
                            tone: tag == _PlanTag.bestValue
                                ? KuberTone.income
                                : KuberTone.secondary,
                          ),
                      ],
                    ),
                    Text(
                      benefit,
                      style: tt.bodyMedium!.copyWith(
                        color: benefitAccent ? cs.primary : sub,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: tt.titleMedium!.copyWith(color: fg)),
                  if (suffix.isNotEmpty)
                    Text(suffix, style: tt.bodySmall!.copyWith(color: sub)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? cs.primary : cs.onSurfaceVariant,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _TipJarSection extends StatelessWidget {
  const _TipJarSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Not ready for Pro? Support Kuber.',
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'One-time thanks. No subscription, no unlocks. Just fuel for '
          'development.',
          style: localeFont(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: KuberSpace.md),
        const BuyMeCoffeeButton(),
      ],
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'Managed by Google Play. Cancel anytime in Play Store. Restore works '
          'across your devices.',
          textAlign: TextAlign.center,
          style: localeFont(
            fontSize: 11,
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        Consumer(
          builder: (context, ref, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => restorePurchases(context, ref),
                child: Text(
                  'Restore purchases',
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
              Text('·', style: localeFont(color: cs.onSurfaceVariant)),
              TextButton(
                onPressed: () => showRedeemPromoCodeSheet(context, ref),
                child: Text(
                  'Redeem promo code',
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom bar hosting the sticky Continue button (sell + grandfathered modes).
class _StickyContinue extends StatelessWidget {
  final Widget child;
  const _StickyContinue({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpace.lg,
            KuberSpace.md,
            KuberSpace.lg,
            KuberSpace.md,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Display-only badge above the plan cards describing an active launch offer,
/// e.g. "Get 1 year free · Then ₹1,099/year. Applies at checkout." The discount
/// is applied by attaching the offer token when Yearly is purchased; Play does
/// not expose the offer's calendar end date, so no "ends on" line is shown.
class _OfferBadge extends StatelessWidget {
  final SubscriptionOfferInfo offer;
  const _OfferBadge({required this.offer});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final first = offer.firstPhase;
    final recurring = offer.recurringPhase;
    final main = first.isFree
        ? 'Get ${first.durationLabel} free'
        : '${first.formattedPrice} for ${first.durationLabel}';
    final sub =
        'Then ${recurring.formattedPrice}/${recurring.periodLabel}. Applies at '
        'checkout.';

    return Container(
      padding: const EdgeInsets.all(KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        border: Border.all(color: cs.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, size: 18, color: cs.primary),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAUNCH OFFER',
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  main,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  sub,
                  style: localeFont(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
