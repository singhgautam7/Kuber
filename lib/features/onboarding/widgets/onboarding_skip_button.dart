import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const OnboardingSkipButton({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
        child: SizedBox(
          height: 56,
          child: Center(
            child: TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
