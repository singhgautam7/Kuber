import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../purchase_states/restore_purchases_flow.dart';
import '../services/purchase_service.dart';
import 'billing_ui_state.dart';
import 'paywall_error_state.dart';
import 'paywall_loading_state.dart';
import 'paywall_manage_state.dart';
import 'paywall_promo_state.dart';
import 'paywall_trial_state.dart';
import 'pro_state.dart';

/// Route: `/pro`. Full screen, not a bottom sheet, per spec — Pro gets its
/// own space. Reachable from every feature gate, from Settings, and from a
/// "Kuber Pro" tile in More tab. A slow ambient primary glow sits behind the
/// whole screen (same language as Ask Kuber's welcome view) so Pro reads as
/// a distinct, premium moment rather than another settings page.
class KuberProPaywallScreen extends ConsumerStatefulWidget {
  const KuberProPaywallScreen({super.key});

  @override
  ConsumerState<KuberProPaywallScreen> createState() =>
      _KuberProPaywallScreenState();
}

class _KuberProPaywallScreenState extends ConsumerState<KuberProPaywallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final proState = ref.watch(kuberProStateProvider);
    final promo = ref.watch(promoConfigProvider);
    final productsLoading = ref.watch(productsLoadingProvider);
    final productsError = ref.watch(productsErrorProvider);
    final cachedPrices = ref.watch(cachedProductPricesProvider);

    // A user who already owns Pro sees the manage state instead of the
    // pricing cards and feature-clusters (Section 5).
    final isManaging = proState.source == ProSource.purchased ||
        proState.source == ProSource.promo;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _glow,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_glow.value);
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.7),
                        radius: 0.9,
                        colors: [
                          cs.primary.withValues(alpha: 0.22 + t * 0.10),
                          cs.primary.withValues(alpha: 0.05),
                          cs.primary.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 0.75],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KuberSpacing.lg,
                      KuberSpacing.sm,
                      KuberSpacing.lg,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox.square(
                          dimension: 40,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerHigh,
                              shape: const CircleBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    KuberSpacing.sm,
                    KuberSpacing.lg,
                    KuberSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (!isManaging) ...[
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(KuberRadius.md),
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: cs.primary,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.lg),
                      ],
                      Text(
                        'Kuber Pro',
                        textAlign: TextAlign.center,
                        style: localeFont(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      if (!isManaging)
                        Text(
                          'One-time purchase or subscription. No account. '
                          'Fully private.',
                          textAlign: TextAlign.center,
                          style: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        )
                      else
                        Text(
                          'Thank you for supporting Kuber.',
                          textAlign: TextAlign.center,
                          style: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      const SizedBox(height: KuberSpacing.xl),

                      if (proState.isTrial) ...[
                        PaywallTrialBanner(proState: proState),
                        const SizedBox(height: KuberSpacing.xl),
                      ],

                      if (promo != null && !isManaging) ...[
                        PaywallPromoSection(promo: promo),
                        const SizedBox(height: KuberSpacing.xl),
                      ],

                      if (!isManaging) ...[
                        ..._featureClusters(cs),
                        const SizedBox(height: KuberSpacing.xl),
                      ],

                      if (isManaging)
                        PaywallManageSection(proState: proState)
                      else ...[
                        Text(
                          'Choose a plan',
                          style: localeFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.md),
                        // Loading / error / ready states for the pricing cards,
                        // gated on the Play Billing query (billing_ui_state).
                        // While products load we show the pricing skeleton;
                        // when Play is unreachable AND we have no cached price
                        // we show a retry state; otherwise real cards, priced
                        // from the last-known Play price (cached), falling back
                        // to the configured amount.
                        if (productsLoading)
                          const PaywallPricingSkeleton()
                        else if (productsError && cachedPrices.isEmpty)
                          PaywallProductsErrorState(
                            onRetry: () => ref
                                .read(purchaseServiceProvider)
                                .loadProducts(kAllProductIds),
                          )
                        else ...[
                          _PricingCard(
                            plan: ProPlan.monthly,
                            title: 'Monthly',
                            price: cachedPrices[kProMonthlyId] ?? '₹119',
                            priceSuffix: '/month',
                            caption: 'Try Pro month by month',
                            isTrial: proState.isTrial,
                            onSelect: () =>
                                _purchase(context, ref, ProPlan.monthly),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          _PricingCard(
                            plan: ProPlan.yearly,
                            title: 'Yearly',
                            price: cachedPrices[kProYearlyId] ?? '₹1,099',
                            priceSuffix: '/year',
                            caption: '₹92/month',
                            highlighted: true,
                            isTrial: proState.isTrial,
                            onSelect: () =>
                                _purchase(context, ref, ProPlan.yearly),
                          ),
                          const SizedBox(height: KuberSpacing.sm),
                          _PricingCard(
                            plan: ProPlan.lifetime,
                            title: 'Lifetime',
                            price: cachedPrices[kProLifetimeId] ?? '₹2,199',
                            priceSuffix: ' once',
                            caption: 'Pay once, use forever',
                            isTrial: proState.isTrial,
                            onSelect: () =>
                                _purchase(context, ref, ProPlan.lifetime),
                          ),
                        ],
                        const SizedBox(height: KuberSpacing.xl),
                      ],

                      // Centered as a block, but the text within is left-aligned
                      // so a wrap to a second line reads cleanly.
                      Center(
                        child: Text(
                          'No account. No cloud. Cancel anytime through '
                          'Google Play.',
                          textAlign: TextAlign.left,
                          style: localeFont(
                              fontSize: 11.5, color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      if (!isManaging)
                        Center(
                          child: productsLoading
                              ? const RestorePurchasesLinkLoading()
                              : const RestorePurchasesLink(),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _featureClusters(ColorScheme cs) {
    final clusters = <String, List<(IconData, String, String)>>{
      'Automation': [
        (Icons.sms_outlined, 'SMS Import', 'Auto-fill transactions from bank SMS'),
        (Icons.backup_outlined, 'Automatic Backups', 'Scheduled, hands-off backups'),
        (Icons.notifications_active_outlined, 'Reminders', 'Never miss a bill or EMI'),
      ],
      'Intelligence': [
        (Icons.auto_awesome_rounded, 'Unlimited Ask Kuber', 'No weekly message cap'),
        (Icons.insert_chart_outlined_rounded, 'Advanced Analytics', 'Deeper trends and breakdowns'),
        (Icons.auto_stories_rounded, 'Money Stories archive', 'Revisit every past story'),
      ],
      'Notes': [
        (Icons.sticky_note_2_outlined, 'Unlimited Kuber Notes', 'No 2-note limit'),
      ],
      'Polish': [
        (Icons.currency_exchange_rounded, 'Multi-currency', 'Track more than one currency'),
        (Icons.palette_outlined, 'Custom themes', 'Make Kuber look like yours'),
        (Icons.widgets_outlined, 'Multiple widgets', 'More home-screen widgets'),
      ],
    };

    final widgets = <Widget>[];
    clusters.forEach((title, items) {
      widgets.add(
        Text(
          title.toUpperCase(),
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
      );
      widgets.add(const SizedBox(height: KuberSpacing.sm));
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                    vertical: KuberSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(KuberRadius.sm),
                        ),
                        child: Icon(items[i].$1, size: 17, color: cs.primary),
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].$2,
                              style: localeFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                              ),
                            ),
                            Text(
                              items[i].$3,
                              style: localeFont(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (i != items.length - 1) Divider(height: 1, color: cs.outline),
              ],
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: KuberSpacing.xl));
    });
    return widgets;
  }

  void _purchase(BuildContext context, WidgetRef ref, ProPlan plan) {
    // Kicks off the native Play Billing sheet. Entitlement, the success sheet,
    // and every failure snackbar are handled centrally by PurchaseService's
    // purchase-stream listener — the result can arrive after this screen is
    // gone (a pending UPI payment), so nothing here awaits the outcome.
    ref.read(purchaseServiceProvider).buyProduct(productIdForPlan(plan));
  }
}

class _PricingCard extends StatelessWidget {
  final ProPlan plan;
  final String title;
  final String price;
  final String priceSuffix;
  final String caption;
  final bool highlighted;
  final bool isTrial;
  final VoidCallback onSelect;

  const _PricingCard({
    required this.plan,
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.caption,
    required this.isTrial,
    required this.onSelect,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          // The recommended card gets a SUBTLE primary tint (~9% alpha) but
          // keeps the neutral outline like every other row — the "MOST
          // POPULAR" badge already marks it, so a colored border would be
          // redundant emphasis.
          color: highlighted
              ? cs.primary.withValues(alpha: 0.09)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: localeFont(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      if (highlighted) ...[
                        const SizedBox(width: KuberSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(KuberRadius.sm),
                          ),
                          child: Text(
                            'MOST POPULAR',
                            style: localeFont(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    caption,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: localeFont(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: priceSuffix,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
