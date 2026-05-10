import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import 'onboarding_dots_indicator.dart';

class OnboardingNavBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;

  const OnboardingNavBar({
    super.key,
    required this.currentPage,
    this.totalPages = 4,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Continue →',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (onBack != null)
          OutlinedButton(
            onPressed: onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurface,
              side: BorderSide(color: cs.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.md,
              ),
            ),
            child: Text(
              '← Back',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(width: 80),
        const Spacer(),
        OnboardingDotsIndicator(
          totalPages: totalPages,
          currentPage: currentPage,
        ),
        const Spacer(),
        if (onNext != null)
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.lg,
                vertical: KuberSpacing.md,
              ),
            ),
            child: Text(
              nextLabel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          )
        else
          const SizedBox(width: 80),
      ],
    );
  }
}
