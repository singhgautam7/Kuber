import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_nav_bar.dart';

class OnboardingPage3 extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage3({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _topFeatures = [
    _FeatureData(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Budgets',
      color: Color(0xFF3B82F6),
    ),
    _FeatureData(
      icon: Icons.pie_chart_rounded,
      label: 'Analytics',
      color: Color(0xFF8B5CF6),
    ),
    _FeatureData(
      icon: Icons.sync_rounded,
      label: 'Recurring',
      color: Color(0xFF14B8A6),
    ),
    _FeatureData(
      icon: Icons.handshake_rounded,
      label: 'Lend & borrow',
      color: Color(0xFFF59E0B),
    ),
    _FeatureData(
      icon: Icons.show_chart_rounded,
      label: 'Investments',
      color: Color(0xFF22C55E),
    ),
    _FeatureData(
      icon: Icons.auto_awesome_rounded,
      label: 'Ask Kuber AI',
      color: Color(0xFF3B82F6),
    ),
  ];

  static const _bottomFeatures = [
    _FeatureData(
      icon: Icons.calculate_rounded,
      label: 'Tools & Calculators',
      color: Color(0xFFEC4899),
    ),
    _FeatureData(
      icon: Icons.label_rounded,
      label: 'Tags & Categories',
      color: Color(0xFF6366F1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _tileAnim(int index) {
    final totalItems = _topFeatures.length + _bottomFeatures.length;
    final start = (index / totalItems) * 0.55;
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: KuberSpacing.xxl),

                      Text(
                        '8+ MODULES · ZERO CLUTTER',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        'Everything in\none quiet place.',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.9,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        'Track expenses, plan budgets, monitor portfolios — and ask Kuber for answers.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: KuberSpacing.xl),

                      // Top 6 grid (3 columns)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: KuberSpacing.md,
                          mainAxisSpacing: KuberSpacing.md,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _topFeatures.length,
                        itemBuilder: (context, index) {
                          final anim = _tileAnim(index);
                          return AnimatedBuilder(
                            animation: anim,
                            builder: (context, child) => Opacity(
                              opacity: anim.value,
                              child: Transform.scale(
                                scale: 0.85 + 0.15 * anim.value,
                                child: child,
                              ),
                            ),
                            child: _FeatureTile(data: _topFeatures[index]),
                          );
                        },
                      ),

                      const SizedBox(height: KuberSpacing.md),

                      // Bottom 2 wide tiles
                      Row(
                        children: _bottomFeatures.asMap().entries.map((e) {
                          final anim = _tileAnim(_topFeatures.length + e.key);
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: e.key > 0 ? KuberSpacing.md / 2 : 0,
                                right:
                                    e.key < _bottomFeatures.length - 1
                                        ? KuberSpacing.md / 2
                                        : 0,
                              ),
                              child: AnimatedBuilder(
                                animation: anim,
                                builder: (context, child) => Opacity(
                                  opacity: anim.value,
                                  child: Transform.scale(
                                    scale: 0.85 + 0.15 * anim.value,
                                    child: child,
                                  ),
                                ),
                                child: _WideTile(data: e.value),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: KuberSpacing.lg),

                      // "and much more" pill
                      _AndMuchMorePill(),
                      const SizedBox(height: KuberSpacing.xl),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.xl,
                  vertical: KuberSpacing.lg,
                ),
                child: OnboardingNavBar(
                  currentPage: 2,
                  onBack: widget.onBack,
                  onNext: widget.onNext,
                ),
              ),
            ],
          ),
        ),

        // Skip button — top right
        Positioned(
          top: MediaQuery.of(context).padding.top + KuberSpacing.md,
          right: KuberSpacing.xl,
          child: TextButton(
            onPressed: widget.onSkip,
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureData({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _FeatureTile extends StatelessWidget {
  final _FeatureData data;
  const _FeatureTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: data.color.withValues(alpha: 0.3)),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const Spacer(),
          Text(
            data.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.2,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WideTile extends StatelessWidget {
  final _FeatureData data;
  const _WideTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: data.color.withValues(alpha: 0.3)),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              data.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.2,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AndMuchMorePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: cs.primary.withValues(alpha: 0.4),
        radius: KuberRadius.md,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withValues(alpha: 0.5 + i * 0.25),
                    ),
                  ),
                  if (i < 2) const SizedBox(width: 3),
                ],
              ],
            ),
            const SizedBox(width: KuberSpacing.sm),
            Text(
              'and much more!',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashWidth = 6.0;
    const dashGap = 4.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.extractPath(distance,
            (distance + dashWidth).clamp(0.0, metric.length));
        canvas.drawPath(start, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
