import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/brand_icon.dart';

/// Full-screen brand splash rendered as a fade-out OVERLAY on top of the
/// already-built app, instead of a separate route we navigate away from.
///
/// Why an overlay: the real destination (Home / Onboarding / recurring loader)
/// is built underneath from the first frame, so its heavy first build happens
/// completely hidden behind this opaque splash. Once the brand moment elapses
/// the splash fades out to reveal a screen that is already painted and settled
/// — there is no route transition animating a mid-build screen, which is what
/// produced the splash→home "stuck frame" on high-refresh devices.
///
/// Self-contained: it plays a brand fade+rise, holds for [holdDuration], then
/// fades itself out over [fadeDuration] and calls [onFinished] so the host can
/// drop it from the tree.
class ColdStartSplash extends StatefulWidget {
  final VoidCallback onFinished;

  /// How long the brand stays fully visible before fading out. Covers the
  /// destination's first build + a beat for brand recognition.
  final Duration holdDuration;
  final Duration fadeDuration;

  const ColdStartSplash({
    super.key,
    required this.onFinished,
    this.holdDuration = const Duration(milliseconds: 900),
    this.fadeDuration = const Duration(milliseconds: 320),
  });

  @override
  State<ColdStartSplash> createState() => _ColdStartSplashState();
}

class _ColdStartSplashState extends State<ColdStartSplash>
    with TickerProviderStateMixin {
  // Brand entrance (fade + slight rise), mirrors the old SplashScreen.
  late final AnimationController _enter;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  // Whole-overlay fade-out.
  double _overlayOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _enterFade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enter, curve: Curves.easeOut));
    _enter.forward();

    // After the entrance + hold, fade the whole overlay out, then remove it.
    Future.delayed(
        const Duration(milliseconds: 400) + widget.holdDuration, _fadeOut);
  }

  void _fadeOut() {
    if (!mounted) return;
    setState(() => _overlayOpacity = 0.0);
    Future.delayed(widget.fadeDuration, () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IgnorePointer(
      // Non-interactive while it fades; the destination behind is inert anyway.
      ignoring: _overlayOpacity == 0.0,
      child: AnimatedOpacity(
        opacity: _overlayOpacity,
        duration: widget.fadeDuration,
        curve: Curves.easeOut,
        // Material (not a bare ColoredBox) so the Text widgets inherit a real
        // DefaultTextStyle — without a Material ancestor they'd fall back to
        // Flutter's yellow double-underline error style. The old SplashScreen
        // got this for free from its Scaffold.
        child: Material(
          color: cs.surface,
          child: Center(
            child: FadeTransition(
              opacity: _enterFade,
              child: SlideTransition(
                position: _enterSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandIcon(size: 88),
                    const SizedBox(height: KuberSpacing.lg),
                    Text(
                      'Kuber',
                      style: localeFont(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    Text(
                      context.l10n.splashTagline,
                      style: localeFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
