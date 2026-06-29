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
/// scrolling for the remaining columns. Short tables grow with the page;
/// long ones (e.g. a 30-year monthly schedule) are virtualized into a
/// bounded, internally-scrolling table so building 300+ rows never hitches.
/// Supports alternating row tints, an optional total row, an optional
/// Yearly/Monthly toggle and an optional footnote.
class ToolScheduleTable extends StatefulWidget {
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

  @override
  State<ToolScheduleTable> createState() => _ToolScheduleTableState();
}

class _ToolScheduleTableState extends State<ToolScheduleTable> {
  static const double _headerHeight = 40;
  static const double _rowHeight = 44;

  /// Above this many rows the table virtualizes into a bounded scroll area.
  static const int _virtualizeAbove = 24;
  static const int _maxVisibleRows = 12;

  // Synced vertical controllers for the frozen column and the data body.
  final _frozenCtrl = ScrollController();
  final _bodyCtrl = ScrollController();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _frozenCtrl.addListener(() => _sync(_frozenCtrl, _bodyCtrl));
    _bodyCtrl.addListener(() => _sync(_bodyCtrl, _frozenCtrl));
  }

  void _sync(ScrollController from, ScrollController to) {
    if (_syncing || !to.hasClients || from.offset == to.offset) return;
    _syncing = true;
    // Clamp to the target's range: when the row count shrinks the source can
    // briefly hold an offset beyond the (now shorter) target's extent.
    final target = from.offset.clamp(0.0, to.position.maxScrollExtent);
    if (target != to.offset) to.jumpTo(target);
    _syncing = false;
  }

  @override
  void didUpdateWidget(ToolScheduleTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Row count changed (e.g. Yearly↔Monthly toggle): reset scroll to the top
    // so a stale offset from the longer list can't exceed the new range.
    if (oldWidget.rows.length != widget.rows.length) {
      for (final c in [_frozenCtrl, _bodyCtrl]) {
        if (c.hasClients) c.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _frozenCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Color _rowBg(ColorScheme cs, int index, bool isTotal) {
    if (isTotal) return cs.primary.withValues(alpha: 0.06);
    return index.isOdd
        ? cs.onSurface.withValues(alpha: 0.02)
        : Colors.transparent;
  }

  Widget _cell(
    ColorScheme cs,
    String text, {
    required bool numeric,
    required bool header,
    required bool isTotal,
  }) {
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

  bool _isTotal(int ri) => widget.totalRow && ri == widget.rows.length - 1;

  Widget _frozenCellFor(ColorScheme cs, int ri) => Container(
        color: ri.isOdd
            ? cs.surfaceContainerHigh.withValues(alpha: 0.6)
            : cs.surfaceContainer,
        child: _cell(cs, widget.rows[ri].first,
            numeric: widget.columns.first.numeric,
            header: false,
            isTotal: _isTotal(ri)),
      );

  Widget _dataRowFor(ColorScheme cs, int ri) => Container(
        color: _rowBg(cs, ri, _isTotal(ri)),
        child: Row(
          children: [
            for (var ci = 1; ci < widget.columns.length; ci++)
              SizedBox(
                width: widget.dataColumnWidth,
                child: _cell(
                  cs,
                  ci < widget.rows[ri].length ? widget.rows[ri][ci] : '',
                  numeric: widget.columns[ci].numeric,
                  header: false,
                  isTotal: _isTotal(ri),
                ),
              ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lazy = widget.rows.length > _virtualizeAbove;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.toggleLabels != null && widget.onToggle != null) ...[
          SizedBox(
            width: 168,
            child: ToolSegmentedControl(
              labels: widget.toggleLabels!,
              selectedIndex: widget.toggleIndex,
              onChanged: widget.onToggle!,
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
            child: lazy ? _buildVirtualized(cs) : _buildEager(cs),
          ),
        ),
        if (widget.note != null) ...[
          const SizedBox(height: KuberSpacing.sm),
          Text(
            widget.note!,
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

  Widget _dataHeader(ColorScheme cs) => Container(
        color: cs.surfaceContainerHigh,
        child: Row(
          children: [
            for (var ci = 1; ci < widget.columns.length; ci++)
              SizedBox(
                width: widget.dataColumnWidth,
                child: _cell(cs, widget.columns[ci].label,
                    numeric: widget.columns[ci].numeric,
                    header: true,
                    isTotal: false),
              ),
          ],
        ),
      );

  // Short tables: a plain Column that grows with the page (no nested scroll).
  Widget _buildEager(ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.firstColumnWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: cs.surfaceContainerHigh,
                child: _cell(cs, widget.columns.first.label,
                    numeric: widget.columns.first.numeric,
                    header: true,
                    isTotal: false),
              ),
              for (var ri = 0; ri < widget.rows.length; ri++)
                _frozenCellFor(cs, ri),
            ],
          ),
        ),
        Container(
          width: 1,
          color: cs.outline,
          height: _headerHeight + _rowHeight * widget.rows.length,
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dataHeader(cs),
                for (var ri = 0; ri < widget.rows.length; ri++)
                  _dataRowFor(cs, ri),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Long tables: a bounded, internally-scrolling table. The frozen column and
  // the data body are separate ListView.builders (so only visible rows are
  // built) with synced vertical offsets; the data header + body share one
  // horizontal scroll so columns line up.
  Widget _buildVirtualized(ColorScheme cs) {
    final visibleRows = widget.rows.length < _maxVisibleRows
        ? widget.rows.length
        : _maxVisibleRows;
    final bodyHeight = visibleRows * _rowHeight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: widget.firstColumnWidth,
          child: Column(
            children: [
              Container(
                color: cs.surfaceContainerHigh,
                child: _cell(cs, widget.columns.first.label,
                    numeric: widget.columns.first.numeric,
                    header: true,
                    isTotal: false),
              ),
              SizedBox(
                height: bodyHeight,
                child: ListView.builder(
                  controller: _frozenCtrl,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemExtent: _rowHeight,
                  itemCount: widget.rows.length,
                  itemBuilder: (_, ri) => _frozenCellFor(cs, ri),
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: cs.outline, height: _headerHeight + bodyHeight),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (widget.columns.length - 1) * widget.dataColumnWidth,
              child: Column(
                children: [
                  _dataHeader(cs),
                  SizedBox(
                    height: bodyHeight,
                    child: ListView.builder(
                      controller: _bodyCtrl,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemExtent: _rowHeight,
                      itemCount: widget.rows.length,
                      itemBuilder: (_, ri) => _dataRowFor(cs, ri),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
