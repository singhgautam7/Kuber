import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_dots_indicator.dart';

class OnboardingNavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onBack;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final bool showBack;

  const OnboardingNavBar({
    super.key,
    required this.currentPage,
    required this.onPrimary,
    required this.primaryLabel,
    this.onBack,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final backWidth = showBack ? (currentPage == 3 ? 56.0 : 112.0) : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpacing.xl,
          KuberSpacing.md,
          KuberSpacing.xl,
          KuberSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingDotsIndicator(currentPage: currentPage),
            const SizedBox(height: KuberSpacing.md),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: 56,
                    width: backWidth,
                    margin: EdgeInsets.only(
                      right: showBack ? KuberSpacing.md : 0,
                    ),
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: showBack ? 1 : 0,
                        child: OutlinedButton(
                          onPressed: onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outline),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                KuberRadius.md,
                              ),
                            ),
                          ),
                          child: currentPage == 3
                              ? const Icon(Icons.chevron_left_rounded, size: 28)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.chevron_left_rounded,
                                      size: 24,
                                    ),
                                    const SizedBox(width: KuberSpacing.xs),
                                    Text(
                                      'Back',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      height: 56,
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.16),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Row(
                            key: ValueKey(primaryLabel),
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  primaryLabel,
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: KuberSpacing.sm),
                              const Icon(Icons.arrow_forward_rounded, size: 24),
                            ],
                          ),
                        ),
                      ),
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
}
