import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/feature_gates/pro_gate.dart';

class DeeperInsightsTeaser extends ConsumerWidget {
  const DeeperInsightsTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          onTap: () {
            if (proGate(context, ref, showAdvancedAnalyticsGateSheet)) {
              context.push('/advanced-analytics');
            }
          },
          child: Ink(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Icon(
                    Icons.insert_chart_outlined_rounded,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'View deeper insights',
                              style: localeFont(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          // _ProChip(color: cs.primary),
                        ],
                      ),
                      const SizedBox(height: KuberSpacing.xs),
                      Text(
                        'Trends, patterns, forecast, financial health score, and more',
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// PAYMENT-HIDDEN (KYC pending): the chip usage above is commented out; keep
// the class for when Pro UI is restored.
// ignore: unused_element
class _ProChip extends StatelessWidget {
  final Color color;

  const _ProChip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        'PRO',
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
