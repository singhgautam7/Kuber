import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import 'calculator_widgets.dart';

class ScheduleColumn {
  final String label;
  final bool numeric; // right-aligned when true
  const ScheduleColumn(this.label, {this.numeric = true});
}

/// A period-by-period schedule table with a sticky first column and horizontal
/// scrolling for the remaining columns (the page scrolls vertically). Supports
/// alternating row tints, an optional total row, an optional Yearly/Monthly
/// toggle and an optional footnote.
class ToolScheduleTable extends StatelessWidget {
  final List<ScheduleColumn> columns;
  final List<List<String>> rows;
  final double firstColumnWidth;
  final double dataColumnWidth;
  final bool totalRow;
  final String? note;

  /// Optional Yearly/Monthly (or any) toggle shown above the table.
  final List<String>? toggleLabels;
  final int toggleIndex;
  final ValueChanged<int>? onToggle;

  const ToolScheduleTable({
    super.key,
    required this.columns,
    required this.rows,
    this.firstColumnWidth = 64,
    this.dataColumnWidth = 132,
    this.totalRow = false,
    this.note,
    this.toggleLabels,
    this.toggleIndex = 0,
    this.onToggle,
  });

  static const double _headerHeight = 40;
  static const double _rowHeight = 44;

  Color _rowBg(ColorScheme cs, int index, bool isTotal) {
    if (isTotal) return cs.primary.withValues(alpha: 0.06);
    return index.isOdd
        ? cs.onSurface.withValues(alpha: 0.02)
        : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget cell(String text, {required bool numeric, required bool header, required bool isTotal}) {
      return Container(
        height: header ? _headerHeight : _rowHeight,
        alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: header
              ? localeFont(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.4,
                )
              : localeFont(
                  fontSize: 12,
                  fontWeight: isTotal
                      ? FontWeight.w700
                      : (numeric ? FontWeight.w500 : FontWeight.w600),
                  color: numeric && !isTotal ? cs.onSurfaceVariant : cs.onSurface,
                ),
        ),
      );
    }

    final dataColumns = columns.sublist(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (toggleLabels != null && onToggle != null) ...[
          SizedBox(
            width: 168,
            child: ToolSegmentedControl(
              labels: toggleLabels!,
              selectedIndex: toggleIndex,
              onChanged: onToggle!,
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sticky first column.
                SizedBox(
                  width: firstColumnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        color: cs.surfaceContainerHigh,
                        child: cell(columns.first.label,
                            numeric: columns.first.numeric,
                            header: true,
                            isTotal: false),
                      ),
                      for (var ri = 0; ri < rows.length; ri++)
                        Container(
                          color: ri.isOdd
                              ? cs.surfaceContainerHigh.withValues(alpha: 0.6)
                              : cs.surfaceContainer,
                          child: cell(rows[ri].first,
                              numeric: columns.first.numeric,
                              header: false,
                              isTotal: totalRow && ri == rows.length - 1),
                        ),
                    ],
                  ),
                ),
                Container(width: 1, color: cs.outline, height: _headerHeight + _rowHeight * rows.length),
                // Scrollable data columns.
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: cs.surfaceContainerHigh,
                          child: Row(
                            children: [
                              for (final c in dataColumns)
                                SizedBox(
                                  width: dataColumnWidth,
                                  child: cell(c.label,
                                      numeric: c.numeric,
                                      header: true,
                                      isTotal: false),
                                ),
                            ],
                          ),
                        ),
                        for (var ri = 0; ri < rows.length; ri++)
                          Container(
                            color: _rowBg(cs, ri,
                                totalRow && ri == rows.length - 1),
                            child: Row(
                              children: [
                                for (var ci = 1; ci < columns.length; ci++)
                                  SizedBox(
                                    width: dataColumnWidth,
                                    child: cell(
                                      ci < rows[ri].length ? rows[ri][ci] : '',
                                      numeric: columns[ci].numeric,
                                      header: false,
                                      isTotal:
                                          totalRow && ri == rows.length - 1,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(height: KuberSpacing.sm),
          Text(
            note!,
            style: localeFont(
              fontSize: 11,
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
