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

  /// False hides the dots (the first page, before the flow begins).
  final bool showDots;

  /// A second action in the outlined slot instead of Back ("Not now").
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// A centred line above the buttons naming what they decide
  /// ("Allow notifications"), so the buttons themselves can stay short.
  final String? caption;

  /// False drops the arrow after the label (the pages whose design has none,
  /// and until the last page's button is enabled).
  final bool showArrow;

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
    this.showDots = true,
    this.secondaryLabel,
    this.onSecondary,
    this.showArrow = true,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final second = secondaryLabel;
    final outlined = showBack || second != null;
    final backWidth = second != null
        ? 128.0
        : showBack
        ? (compactBack ? 56.0 : 112.0)
        : 0.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          showDots ? KuberSpace.md : KuberSpace.xl,
          KuberSpace.screenMargin,
          KuberSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              child: caption == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(bottom: KuberSpace.md),
                      child: Text(
                        caption!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(color: cs.onSurface),
                      ),
                    ),
            ),
            if (showDots) ...[
              OnboardingDotsIndicator(
                currentPage: currentPage,
                pageCount: pageCount,
              ),
              const SizedBox(height: KuberSpace.lg),
            ],
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
                      right: outlined ? KuberSpace.md : 0,
                    ),
                    child: ClipRect(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: outlined ? 1 : 0,
                        child: OutlinedButton(
                          onPressed: second != null ? onSecondary : onBack,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cs.onSurface,
                            side: BorderSide(color: cs.outlineVariant),
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(56, 56),
                            shape: const StadiumBorder(),
                          ),
                          child: second != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: KuberSpace.md,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      second,
                                      softWrap: false,
                                      style: localeFont(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                )
                              : compactBack
                              ? const Icon(Icons.arrow_back_rounded, size: 24)
                              // Natural width while the slot animates open;
                              // the ClipRect above hides the rest.
                              : OverflowBox(
                                  maxWidth: double.infinity,
                                  child: Row(
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
                              // Shrinks only when the label runs out of room
                              // (the largest system font sizes).
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    primaryLabel,
                                    softWrap: false,
                                    style: localeFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: !busy && showArrow
                                    ? const _ArrowIn()
                                    : const SizedBox.shrink(),
                              ),
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

/// The arrow after the label: slides 8 in and fades, a beat after the button
/// turns on.
class _ArrowIn extends StatelessWidget {
  const _ArrowIn();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
      child: const Padding(
        padding: EdgeInsetsDirectional.only(start: KuberSpace.sm),
        child: Icon(Icons.arrow_forward_rounded, size: 20),
      ),
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(-8 * (1 - t), 0), child: c),
      ),
    );
  }
}
