import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';

/// Mounted in place of the real Kuber Pro status card in
/// `settings/kuber_pro_settings_section.dart` while
/// `proBootstrapLoadingProvider` is true. Same footprint as the real card
/// (icon chip + two text lines) so nothing shifts on resolve. The "Redeem
/// promo code" / "Restore purchases" rows below are static regardless of
/// entitlement and can keep rendering immediately — only this identity card
/// depends on resolved state.
class KuberProSettingsCardSkeleton extends StatelessWidget {
  const KuberProSettingsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          KuberSkeleton(width: 40, height: 40, borderRadius: KuberRadius.md),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KuberSkeleton(width: 140, height: 15),
                const SizedBox(height: 6),
                KuberSkeleton(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
