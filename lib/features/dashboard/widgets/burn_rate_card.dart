import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/stats_provider.dart';

class BurnRateCard extends ConsumerWidget {
  const BurnRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final burnRateAsync = ref.watch(burnRateProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return burnRateAsync.when(
      loading: () => _buildLoading(context),
      error: (e, _) => const SizedBox.shrink(),
      data: (data) {
        if (data.avgDaily == 0) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Daily Burn Rate',
            //   style: textTheme.titleMedium?.copyWith(
            //     fontWeight: FontWeight.w700,
            //     letterSpacing: -0.3,
            //   ),
            // ),
            // const SizedBox(height: KuberSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KuberSpacing.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVERAGE SPEND',
                            style: textTheme.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.xs),
                          Text(
                            '${maskAmount(CurrencyFormatter.format(data.avgDaily), isPrivate)}/day',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bolt_rounded, color: cs.primary, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Projected: ',
                          style: textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          maskAmount(CurrencyFormatter.format(data.projected), isPrivate),
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          ' this month',
                          style: textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpacing.md),
          ],
        );
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Daily Burn Rate',
        //   style: textTheme.titleMedium?.copyWith(
        //     fontWeight: FontWeight.w700,
        //     letterSpacing: -0.3,
        //     color: cs.onSurface.withValues(alpha: 0.1),
        //   ),
        // ),
        // const SizedBox(height: KuberSpacing.sm),
        Shimmer.fromColors(
          baseColor: cs.surfaceContainerHigh,
          highlightColor: cs.surfaceContainerLowest,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
      ],
    );
  }
}
