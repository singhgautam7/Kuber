import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_dots_indicator.dart';

class OnboardingNavBar extends StatelessWidget {
  final int currentPage;
  final VoidCallback? onBack;
  final VoidCallback onPrimary;
  final String primaryLabel;
  final bool showBack;

  /// Saving state: the primary button reads as disabled and drops its arrow.
  final bool busy;

  /// Dots shown (one per page of the flow).
  final int pageCount;

  /// Icon-only Back (the last page, where the primary label is long).
  final bool compactBack;

  /// False: the primary button is disabled (e.g. no pick yet).
  final bool primaryEnabled;

  const OnboardingNavBar({
    super.key,
    required this.currentPage,
    required this.onPrimary,
    required this.primaryLabel,
    this.onBack,
    this.showBack = true,
    this.busy = false,
    this.pageCount = 4,
    this.compactBack = false,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final backWidth = showBack ? (compactBack ? 56.0 : 112.0) : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          KuberSpace.md,
          KuberSpace.screenMargin,
          KuberSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OnboardingDotsIndicator(
              currentPage: currentPage,
              pageCount: pageCount,
            ),
            const SizedBox(height: KuberSpace.lg),
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
                      right: showBack ? KuberSpace.md : 0,
                    ),
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: showBack ? 1 : 0,
                        child: OutlinedButton(
                          onPressed: onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outlineVariant),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(56, 56),
                            shape: const StadiumBorder(),
                          ),
                          child: compactBack
                              ? const Icon(Icons.arrow_back_rounded, size: 24)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: KuberSpace.sm),
                                    Text(
                                      'Back',
                                      style: localeFont(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
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
                        onPressed: primaryEnabled ? onPrimary : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: busy
                              ? cs.onSurface.withValues(alpha: 0.12)
                              : cs.primary,
                          foregroundColor: busy
                              ? cs.onSurface.withValues(alpha: 0.38)
                              : cs.onPrimary,
                          disabledBackgroundColor: cs.onSurface.withValues(
                            alpha: 0.12,
                          ),
                          disabledForegroundColor: cs.onSurface.withValues(
                            alpha: 0.38,
                          ),
                          minimumSize: const Size(64, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shape: const StadiumBorder(),
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
                                  style: localeFont(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                              if (!busy) ...[
                                const SizedBox(width: KuberSpace.sm),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                ),
                              ],
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
