import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';

class BarCompareSeries {
  final String name;
  final Color color;
  final List<double> values; // one per category
  const BarCompareSeries({
    required this.name,
    required this.color,
    required this.values,
  });
}

/// A grouped bar comparison (e.g. Old vs New regime, Lumpsum vs SIP). Each
/// category renders one bar per series, with a compact ₹ value above each bar
/// and a legend below.
class ToolBarCompare extends ConsumerWidget {
  final List<String> categories;
  final List<BarCompareSeries> series;
  final double barAreaHeight;

  const ToolBarCompare({
    super.key,
    required this.categories,
    required this.series,
    this.barAreaHeight = 130,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);

    double maxVal = 0;
    for (final s in series) {
      for (final v in s.values) {
        if (v > maxVal) maxVal = v;
      }
    }
    final safeMax = (maxVal * 1.12) <= 0 ? 1 : maxVal * 1.12;

    return Column(
      children: [
        SizedBox(
          height: barAreaHeight + 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var ci = 0; ci < categories.length; ci++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (final s in series) ...[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formatter.formatCompactCurrency(s.values[ci],
                                      symbol: currency.symbol),
                                  style: localeFont(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: s.color,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 30,
                                  height: (s.values[ci] / safeMax *
                                          barAreaHeight)
                                      .clamp(4, barAreaHeight)
                                      .toDouble(),
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(KuberRadius.sm),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: KuberSpacing.sm),
                          ],
                        ],
                      ),
                      const SizedBox(height: KuberSpacing.sm),
                      Text(
                        categories[ci],
                        style: localeFont(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: KuberSpacing.lg,
          runSpacing: KuberSpacing.sm,
          children: [
            for (final s in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(s.name,
                      style: localeFont(
                          fontSize: 11.5, color: cs.onSurfaceVariant)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
