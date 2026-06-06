import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/onboarding_skip_button.dart';

class OnboardingPageThree extends StatefulWidget {
  final VoidCallback onSkip;

  const OnboardingPageThree({super.key, required this.onSkip});

  @override
  State<OnboardingPageThree> createState() => _OnboardingPageThreeState();
}

class _OnboardingPageThreeState extends State<OnboardingPageThree>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 860),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final features = _FeatureSpec.build(context);

    return Column(
      children: [
        OnboardingSkipButton(onSkip: widget.onSkip),
        Expanded(
          child: OnboardingFit(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.modulesTitle,
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                Text(
                  context.l10n.everythingInOnePlace,
                  style: localeFont(
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                Text(
                  context.l10n.onboardingPage3Description,
                  style: localeFont(
                    fontSize: 13,
                    height: 1.38,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                GridView.builder(
                  itemCount: 6,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: KuberSpacing.sm,
                    crossAxisSpacing: KuberSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) => _AnimatedFeatureCard(
                    animation: _controller,
                    index: index,
                    spec: features[index],
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _AnimatedFeatureCard(
                        animation: _controller,
                        index: 6,
                        spec: features[6],
                        wide: true,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _AnimatedFeatureCard(
                        animation: _controller,
                        index: 7,
                        spec: features[7],
                        wide: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.md),
                _MorePill(colorScheme: cs),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureSpec {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureSpec({
    required this.icon,
    required this.label,
    required this.color,
  });

  static List<_FeatureSpec> build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return [
      _FeatureSpec(
        icon: Icons.account_balance_wallet_rounded,
        label: l10n.budgetsModule,
        color: cs.primary,
      ),
      _FeatureSpec(
        icon: Icons.pie_chart_rounded,
        label: l10n.analyticsModule,
        color: cs.secondary,
      ),
      _FeatureSpec(
        icon: Icons.sync_rounded,
        label: l10n.recurringModule,
        color: cs.tertiary,
      ),
      _FeatureSpec(
        icon: Icons.handshake_rounded,
        label: l10n.lendBorrowModule,
        color: cs.error,
      ),
      _FeatureSpec(
        icon: Icons.show_chart_rounded,
        label: l10n.investmentsModule,
        color: cs.tertiary,
      ),
      _FeatureSpec(
        icon: Icons.auto_awesome_rounded,
        label: l10n.askKuberModule,
        color: cs.primary,
      ),
      _FeatureSpec(
        icon: Icons.calculate_rounded,
        label: l10n.toolsModule,
        color: cs.error,
      ),
      _FeatureSpec(
        icon: Icons.label_rounded,
        label: l10n.tagsCategoriesModule,
        color: cs.primary,
      ),
    ];
  }
}

class _AnimatedFeatureCard extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final _FeatureSpec spec;
  final bool wide;

  const _AnimatedFeatureCard({
    required this.animation,
    required this.index,
    required this.spec,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.06).clamp(0.0, 0.72);
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, 1, curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.86, end: 1).animate(curved),
        child: _FeatureCard(spec: spec, wide: wide),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureSpec spec;
  final bool wide;

  const _FeatureCard({required this.spec, required this.wide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: wide
          ? Row(
              children: [
                _FeatureIcon(spec: spec),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(child: _FeatureLabel(spec.label)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeatureIcon(spec: spec),
                const Spacer(),
                _FeatureLabel(spec.label),
              ],
            ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final _FeatureSpec spec;

  const _FeatureIcon({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: spec.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: spec.color.withValues(alpha: 0.45)),
      ),
      child: Icon(spec.icon, color: spec.color, size: 21),
    );
  }
}

class _FeatureLabel extends StatelessWidget {
  final String label;

  const _FeatureLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: localeFont(
        fontSize: 12,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _MorePill extends StatelessWidget {
  final ColorScheme colorScheme;

  const _MorePill({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: colorScheme.primary),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Text(
          context.l10n.andMuchMore,
          textAlign: TextAlign.center,
          style: localeFont(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(KuberRadius.md),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 6);
        canvas.drawPath(extract, paint);
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}