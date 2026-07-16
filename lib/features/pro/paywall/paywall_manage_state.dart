import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/info_table.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../purchase_states/restore_purchases_flow.dart';
import 'pro_state.dart';

/// Shown instead of pricing cards when a user who already has Pro opens the
/// paywall (Section 5). Leads with a "modern premium" status hero — animated
/// glow, days-as-Pro, plan — then read-only subscription details and a
/// hand-off to Play to manage or cancel, since Kuber never touches billing
/// state directly.
class PaywallManageSection extends StatelessWidget {
  final KuberProState proState;
  const PaywallManageSection({super.key, required this.proState});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final planLabel = switch (proState.plan) {
      ProPlan.monthly => 'Monthly',
      ProPlan.yearly => 'Yearly',
      ProPlan.lifetime => 'Lifetime',
      null => proState.source == ProSource.promo ? 'Promo' : 'Pro',
    };

    final renewalLabel = proState.source == ProSource.promo
        ? (proState.promoEndsAt == null
            ? 'Free, lifetime'
            : 'Free until ${_shortDate(proState.promoEndsAt!)}')
        : proState.plan == ProPlan.lifetime
            ? 'One-time purchase, no renewal'
            : proState.expiryDate != null
                ? 'Renews ${_shortDate(proState.expiryDate!)}'
                : 'Active';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHero(proState: proState, planLabel: planLabel),
        const SizedBox(height: KuberSpacing.xl),
        Text(
          'Your plan',
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        InfoTable(
          rows: [
            InfoTableDataRow(label: 'Plan', value: planLabel),
            InfoTableHighlightRow(
              label: 'Status',
              value: renewalLabel,
              valueColor: cs.tertiary,
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.lg),
        if (proState.source != ProSource.promo)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse(
                  'https://play.google.com/store/account/subscriptions',
                ),
                mode: LaunchMode.externalApplication,
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              child: Text(
                'Manage subscription',
                style: localeFont(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        const SizedBox(height: KuberSpacing.md),
        Center(child: const RestorePurchasesLink()),
      ],
    );
  }

  String _shortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// Animated status card: a slow pulsing glow behind a crown mark, "N days as
/// Pro", and the plan/promo label. This is the visual anchor that's supposed
/// to make a Pro user's paywall visit feel distinct from the sales pitch a
/// free user sees, echoing the Ask Kuber mark's living-glow treatment rather
/// than a static badge.
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
    final days = widget.proState.daysSincePremium;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_controller.value);
              return SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.28 + t * 0.14),
                            cs.primary.withValues(alpha: 0.05),
                            cs.primary.withValues(alpha: 0.0),
                          ],
                          stops: const [0.35, 0.7, 1.0],
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 1.0 + t * 0.04,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              cs.primary.withValues(alpha: 0.55),
                              cs.primary.withValues(alpha: 0.15),
                            ],
                          ),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.35),
                          ),
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
          const SizedBox(height: KuberSpacing.md),
          Text(
            widget.planLabel == 'Promo' ? 'Kuber Pro · Promo' : 'Kuber Pro · ${widget.planLabel}',
            style: localeFont(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            days > 0
                ? '$days ${days == 1 ? 'day' : 'days'} as Pro'
                : 'Active today',
            style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
