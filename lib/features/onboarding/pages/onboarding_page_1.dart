import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/onboarding_dots_indicator.dart';
import '../widgets/orbiting_coin_painter.dart';

class OnboardingPage1 extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkip;

  const OnboardingPage1({
    super.key,
    required this.onGetStarted,
    required this.onSkip,
  });

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _version = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),

                const SizedBox(
                  width: 280,
                  height: 280,
                  child: OrbitingCoinAnimation(),
                ),

                SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        _VersionPill(version: _version),
                        const SizedBox(height: KuberSpacing.xl),
                        Text(
                          'Your money.\nYour rules.',
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                            letterSpacing: -1.0,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: KuberSpacing.lg),
                        Text(
                          'An expense manager that lives on your device. No cloud, no signup, no compromises.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.55,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                OnboardingDotsIndicator(totalPages: 4, currentPage: 0),
                const SizedBox(height: KuberSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: widget.onGetStarted,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                    ),
                    child: Text(
                      'Get started →',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),
              ],
            ),
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
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VersionPill extends StatelessWidget {
  final String version;
  const _VersionPill({required this.version});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            version.isNotEmpty
                ? 'OFFLINE-FIRST · v$version'
                : 'OFFLINE-FIRST',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
