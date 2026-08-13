import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/overflow_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_app_bar.dart';
import '../../../../shared/widgets/kuber_comparison_table.dart';
import '../../../../shared/widgets/kuber_page_header.dart';
import '../settings/redeem_promo_code_sheet.dart';
import '../support/buy_me_coffee_section.dart' show BuyMeCoffeeButton;
import '../purchase_states/restore_purchases_flow.dart';
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

    final overflowItems = <KuberOverflowItem>[
      KuberOverflowItem(
        icon: Icons.restore_rounded,
        label: 'Restore purchases',
        onTap: () => restorePurchases(context, ref),
      ),
      KuberOverflowItem(
        icon: Icons.redeem_rounded,
        label: 'Redeem promo code',
        onTap: () => showRedeemPromoCodeSheet(context),
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
          const Positioned.fill(child: _AmbientGlow()),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: KuberAppBar(
                    showBack: true,
                    showHome: true,
                    showBrand: false,
                    infoConfig: kAboutProInfoConfig,
                    overflowConfig: KuberOverflowConfig(items: overflowItems),
                  ),
                ),
                SliverToBoxAdapter(
                  child: KuberPageHeader(
                    title: 'Kuber Pro',
                    description: _headerSubtitle(proState),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    0,
                    KuberSpacing.lg,
                    KuberSpacing.xxl,
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
      bottomNavigationBar:
          (!isManage) ? _StickyContinue(child: _continueButton(yearlyOffer)) : null,
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
        const SizedBox(height: KuberSpacing.lg),
      ],
      const _SellHero(),
      const SizedBox(height: KuberSpacing.xl),
      if (offer != null && offer.hasIntroBenefit) ...[
        _OfferBadge(offer: offer),
        const SizedBox(height: KuberSpacing.xl),
      ],
      _sectionLabel('CHOOSE A PLAN'),
      const SizedBox(height: KuberSpacing.sm),
      ..._planCards(offer),
      const SizedBox(height: KuberSpacing.xl),
      _sectionTitle('What you get with Pro'),
      const SizedBox(height: KuberSpacing.sm),
      const KuberComparisonTable(rows: kProComparisonRows),
      const SizedBox(height: KuberSpacing.xl),
      const _TipJarSection(),
      const SizedBox(height: KuberSpacing.xl),
      const _TrustFooter(),
    ];
  }

  // ── Manage mode (paid / Play trial / promo) ─────────────────────────────
  List<Widget> _manageBody(KuberProState proState) {
    return [
      PaywallManageSection(proState: proState),
      const SizedBox(height: KuberSpacing.xl),
      _sectionTitle('What Pro includes'),
      const SizedBox(height: KuberSpacing.sm),
      const KuberComparisonTable(rows: kProComparisonRows),
    ];
  }

  // ── Grandfathered legacy trial (manage-lite + sell plans) ───────────────
  List<Widget> _grandfatheredBody(KuberProState proState) {
    return [
      _LegacyTrialCard(proState: proState),
      const SizedBox(height: KuberSpacing.lg),
      _sectionLabel('SUBSCRIBE TO KEEP PRO'),
      const SizedBox(height: KuberSpacing.sm),
      ..._planCards(ref.watch(subscriptionOffersProvider)[kProYearlyId]),
      const SizedBox(height: KuberSpacing.xl),
      _sectionTitle('What you get with Pro'),
      const SizedBox(height: KuberSpacing.sm),
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
      const SizedBox(height: KuberSpacing.sm),
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
      const SizedBox(height: KuberSpacing.sm),
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
      ProPlan.yearly => (yearlyOffer?.hasIntroBenefit ?? false)
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
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }
}

/// Contained primary radial glow blended into the page background near the top,
/// echoing the Ask Kuber welcome view. A static gradient fill (no ticker, no
/// `BoxShadow`), so every card on top stays flat and legible.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final peak = dark ? 0.30 : 0.17;
    final mid = dark ? 0.07 : 0.045;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.92),
          radius: 0.9,
          colors: [
            cs.primary.withValues(alpha: peak),
            cs.primary.withValues(alpha: mid),
            cs.primary.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.42, 0.66],
        ),
      ),
    );
  }
}

// ── Sell-mode pieces ────────────────────────────────────────────────────────

class _SellHero extends StatelessWidget {
  const _SellHero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    color: cs.primary, size: 19),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Text(
                  'Everything Kuber, unlocked.',
                  style: localeFont(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          Text(
            'Support development. Get every feature. No accounts, no cloud, '
            'still fully offline.',
            style: localeFont(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          Row(
            children: const [
              _TrustChip(icon: Icons.wifi_off_rounded, label: 'Offline'),
              SizedBox(width: KuberSpacing.lg),
              _TrustChip(icon: Icons.lock_outline_rounded, label: 'Private'),
              SizedBox(width: KuberSpacing.lg),
              _TrustChip(
                  icon: Icons.person_off_outlined, label: 'No accounts'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: localeFont(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WelcomeBackCard extends StatelessWidget {
  const _WelcomeBackCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.waving_hand_rounded, size: 20, color: cs.tertiary),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: localeFont(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Resubscribe to continue where you left off. Your data is '
                  'still safe on this device.',
                  style: localeFont(
                    fontSize: 12.5,
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
    final warning = context.kuberColors.warning;
    final endsLabel = proState.trialEndsAt != null
        ? 'Access ends on ${_shortDate(proState.trialEndsAt!)}'
        : 'Your legacy trial is ending soon';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: KuberSpacing.xl, horizontal: KuberSpacing.lg),
          decoration: BoxDecoration(
            color: warning.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
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
              const SizedBox(height: KuberSpacing.md),
              Text(
                'You\'re on a legacy trial',
                style: localeFont(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                endsLabel,
                style: localeFont(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded,
                size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: KuberSpacing.sm),
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
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.09)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: selected ? cs.primary : cs.outline),
        ),
        child: Row(
          children: [
            _Radio(selected: selected),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: KuberSpacing.sm,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: localeFont(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (tag != _PlanTag.none) _tagChip(cs),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    benefit,
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: benefitAccent ? FontWeight.w600 : FontWeight.w400,
                      color: benefitAccent ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: localeFont(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    TextSpan(
                      text: suffix,
                      style: localeFont(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(ColorScheme cs) {
    if (tag == _PlanTag.bestValue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
        ),
        child: Text(
          'BEST VALUE',
          style: localeFont(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        'PAY ONCE',
        style: localeFont(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: cs.onSurfaceVariant,
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
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? cs.primary : cs.outlineVariant,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
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
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'One-time thanks. No subscription, no unlocks. Just fuel for '
          'development.',
          style: localeFont(
            fontSize: 12.5,
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
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
            fontSize: 11.5,
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Consumer(
          builder: (context, ref, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => restorePurchases(context, ref),
                child: Text(
                  'Restore purchases',
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
              Text('·', style: localeFont(color: cs.onSurfaceVariant)),
              TextButton(
                onPressed: () => showRedeemPromoCodeSheet(context),
                child: Text(
                  'Redeem promo code',
                  style: localeFont(
                    fontSize: 13,
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
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg,
            KuberSpacing.md,
            KuberSpacing.lg,
            KuberSpacing.md,
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
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, size: 18, color: cs.primary),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAUNCH OFFER',
                  style: localeFont(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  main,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
