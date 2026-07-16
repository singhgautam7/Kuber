import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../main.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';

import '../../../shared/widgets/brand_icon.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Kick Home's heavy provider reads off now (non-blocking) so they warm
    // while the splash animates. The splash still dismisses on its fixed timer
    // below — we never make the user wait on data — and Home shows its own
    // skeletons for anything not cached yet by the time it mounts.
    _warmCriticalHomeData();

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _navigate();
      });
    });
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool(PrefsKeys.onboarded) ?? false;
    if (!mounted) return;

    if (onboarded) {
      final missedCount = ref.read(recurringProcessResultProvider);
      context.go(missedCount > 0 ? '/recurring-loader' : '/');
    } else {
      context.go('/onboarding');
    }
  }

  /// Fire-and-forget warm of the providers Home renders from on first build
  /// (current-month hero summary, account balances, category map, widget
  /// layout). Each is a non-autoDispose [FutureProvider], so a value read here
  /// stays cached and is ready when Home mounts, without blocking the timed
  /// splash. `.ignore()` swallows any error/timeout — Home's skeletons cover
  /// the not-yet-ready case.
  void _warmCriticalHomeData() {
    for (final future in <Future<void>>[
      ref.read(monthlySummaryProvider.future).then((_) {}),
      ref.read(accountBalancesProvider.future).then((_) {}),
      ref.read(categoryMapProvider.future).then((_) {}),
      ref.read(homeWidgetsProvider.future).then((_) {}),
    ]) {
      future.ignore();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
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
    );
  }
}