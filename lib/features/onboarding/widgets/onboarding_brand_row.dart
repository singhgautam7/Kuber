import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/brand_icon.dart';

class OnboardingBrandRow extends StatelessWidget {
  final VoidCallback? onSkip;

  const OnboardingBrandRow({super.key, this.onSkip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.xl,
        KuberSpace.lg,
        KuberSpace.xl,
        KuberSpace.sm,
      ),
      child: Row(
        children: [
          const BrandIcon(size: 40),
          const SizedBox(width: KuberSpace.md),
          Text(
            'Kuber',
            style: localeFont(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
