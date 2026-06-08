import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/viz_payload.dart';

/// Ranked horizontal-bar list of top spending categories, rendered inside the
/// Kuber bubble. Bar width is proportional to the largest row (longest = full
/// track). Category colours are harmonized, like everywhere else in Kuber.
class TopCategoriesVizView extends ConsumerWidget {
  final TopCategoriesViz data;
  const TopCategoriesVizView({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final symbol = ref.watch(currencyProvider).symbol;

    final rows = data.rows.take(5).toList();
    if (rows.isEmpty) return const SizedBox.shrink();
    final maxAmount = rows.map((r) => r.amount).fold<double>(0, (m, a) => a > m ? a : m);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            _Row(
              row: row,
              fraction: maxAmount > 0 ? (row.amount / maxAmount).clamp(0.0, 1.0) : 0,
              amountText: formatter.formatCurrency(row.amount.round(), symbol: symbol),
              cs: cs,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final CategoryVizRow row;
  final double fraction;
  final String amountText;
  final ColorScheme cs;

  const _Row({
    required this.row,
    required this.fraction,
    required this.amountText,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final color = harmonizeCategory(context, row.color);
    return SizedBox(
      height: 22,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(fontSize: 12, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              amountText,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
        ],
      ),
    );
  }
}
