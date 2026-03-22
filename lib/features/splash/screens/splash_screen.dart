import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../main.dart';

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
      duration: const Duration(milliseconds: 800),
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

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 900), () {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuberColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: KuberColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: KuberColors.primary,
                    size: 44,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'Kuber',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: KuberColors.primary,
                  ),
                ),
                const SizedBox(height: KuberSpacing.sm),
                Text(
                  'Your personal financial log',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: KuberColors.textSecondary,
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
