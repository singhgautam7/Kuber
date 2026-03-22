import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuberColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App icon
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
              const SizedBox(height: KuberSpacing.xl),

              // Headline
              Text(
                'Welcome to Kuber',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: KuberColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KuberSpacing.sm),

              // Subheadline
              Text(
                'Your personal financial log — simple, private, and local-first.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: KuberColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KuberSpacing.xxl),

              // Feature tiles
              const _FeatureTile(
                icon: Icons.flash_on_rounded,
                title: 'Smart Entry',
                subtitle: 'Auto-fill from your history',
              ),
              const SizedBox(height: KuberSpacing.md),
              const _FeatureTile(
                icon: Icons.bar_chart_rounded,
                title: 'Analytics',
                subtitle: 'Charts and spending breakdowns',
              ),
              const SizedBox(height: KuberSpacing.md),
              const _FeatureTile(
                icon: Icons.account_balance_rounded,
                title: 'Multi-Account',
                subtitle: 'Track bank, cash, and credit cards',
              ),
              const SizedBox(height: KuberSpacing.md),
              const _FeatureTile(
                icon: Icons.lock_outline_rounded,
                title: 'Private & Local',
                subtitle: 'Your data stays on your device',
              ),

              const Spacer(flex: 3),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.push('/onboarding/setup'),
                  style: FilledButton.styleFrom(
                    backgroundColor: KuberColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),

              // Version
              Text(
                _version,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: KuberColors.textSecondary,
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: KuberColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KuberColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
            child: Icon(icon, color: KuberColors.primary, size: 20),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KuberColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: KuberColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
