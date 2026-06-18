import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

/// A bordered card of key/value rows that replaces the old card-in-card field
/// grid in the view bottom sheets. The card has a rounded [cs.outline] border;
/// rows inside are separated by a 1px divider.
///
/// Row variants (see the `InfoTableRow` subclasses):
///  * [InfoTableDataRow] — standard `label → value`. Set [InfoTableDataRow.valueColor]
///    for a highlighted (colored) value, [InfoTableDataRow.valueLeadingIcon] for
///    a leading icon before the value, or [InfoTableDataRow.tappable] for a
///    drill-down row (trailing chevron + press state).
///  * [InfoTableHighlightRow] — convenience for a colored status/amount value.
///  * [InfoTableLabelOnlyRow] — label spans full width with the value on the
///    line below (standalone facts).
class InfoTable extends StatelessWidget {
  final List<InfoTableRow> rows;

  const InfoTable({required this.rows, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dividerColor = cs.outline.withValues(alpha: 0.6);

    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(_RowWidget(row: rows[i]));
      if (i != rows.length - 1) {
        children.add(Divider(height: 1, thickness: 1, color: dividerColor));
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ── Row models ────────────────────────────────────────────────────────────────

sealed class InfoTableRow {
  const InfoTableRow();
}

/// Standard, highlighted, icon-value, or tappable row depending on the fields
/// supplied.
class InfoTableDataRow extends InfoTableRow {
  final String label;
  final String value;

  /// Colors the value text (highlighted variant). Also colors the chevron when
  /// [tappable].
  final Color? valueColor;

  /// When set, renders a small leading icon before the value.
  final IconData? valueLeadingIcon;

  /// Color for [valueLeadingIcon]. Defaults to the muted label color.
  final Color? valueIconColor;

  /// Renders a trailing chevron and a press state.
  final bool tappable;
  final VoidCallback? onTap;

  const InfoTableDataRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueLeadingIcon,
    this.valueIconColor,
    this.tappable = false,
    this.onTap,
  });
}

/// Convenience for a colored status/amount value (`Active` green, `Exceeded`
/// red, …).
class InfoTableHighlightRow extends InfoTableRow {
  final String label;
  final String value;
  final Color valueColor;

  const InfoTableHighlightRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });
}

/// Full-width row: optional label on top, value on the line below. Used for
/// standalone facts where the value would not fit on the right.
class InfoTableLabelOnlyRow extends InfoTableRow {
  final String? label;
  final String value;

  const InfoTableLabelOnlyRow({required this.value, this.label});
}

// ── Rendering ─────────────────────────────────────────────────────────────────

const double _hPad = 16;
const double _minRowHeight = 52;

class _RowWidget extends StatelessWidget {
  final InfoTableRow row;

  const _RowWidget({required this.row});

  static TextStyle _labelStyle(ColorScheme cs) => localeFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: cs.onSurfaceVariant,
      );

  static TextStyle _valueStyle(ColorScheme cs, [Color? color]) => localeFont(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? cs.onSurface,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = row;
    return switch (r) {
      InfoTableDataRow() when r.tappable => _tappable(cs, r),
      InfoTableDataRow() => _standard(cs, r),
      InfoTableHighlightRow() => _standard(
          cs,
          InfoTableDataRow(
            label: r.label,
            value: r.value,
            valueColor: r.valueColor,
          ),
        ),
      InfoTableLabelOnlyRow() => _labelOnly(cs, r),
    };
  }

  Widget _standard(ColorScheme cs, InfoTableDataRow r) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minRowHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 10),
        child: Row(
          children: [
            Text(r.label, style: _labelStyle(cs)),
            const SizedBox(width: 16),
            Expanded(child: _valueContent(cs, r, alignEnd: true)),
          ],
        ),
      ),
    );
  }

  Widget _tappable(ColorScheme cs, InfoTableDataRow r) {
    final accent = r.valueColor ?? cs.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: r.onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _minRowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 10),
            child: Row(
              children: [
                if (r.label.isNotEmpty) ...[
                  Text(r.label, style: _labelStyle(cs)),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: _valueContent(
                    cs,
                    r,
                    alignEnd: r.label.isNotEmpty,
                    forceColor: accent,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 18, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _labelOnly(ColorScheme cs, InfoTableLabelOnlyRow r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPad, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (r.label != null) ...[
            Text(r.label!, style: _labelStyle(cs)),
            const SizedBox(height: 4),
          ],
          Text(r.value, style: _valueStyle(cs)),
        ],
      ),
    );
  }

  /// The right-hand value: optional plain leading icon + text.
  Widget _valueContent(
    ColorScheme cs,
    InfoTableDataRow r, {
    required bool alignEnd,
    Color? forceColor,
  }) {
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.valueLeadingIcon != null) ...[
          Icon(
            r.valueLeadingIcon,
            size: 17,
            color: r.valueIconColor ?? cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            r.value,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: _valueStyle(cs, forceColor ?? r.valueColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

/// Shared amount hero: caption → large colored amount → optional sub-line.
/// Used at the top of the transaction and account view sheets (above the
/// [InfoTable]).
class SheetAmountHero extends StatelessWidget {
  final String caption;
  final String amount;
  final Color amountColor;

  /// Optional muted line below the amount (e.g. "Last transaction 1 hour ago").
  final String? subline;
  final IconData? sublineIcon;

  const SheetAmountHero({
    required this.caption,
    required this.amount,
    required this.amountColor,
    this.subline,
    this.sublineIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          caption.toUpperCase(),
          style: localeFont(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: localeFont(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: amountColor,
            letterSpacing: -1,
          ),
        ),
        if (subline != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sublineIcon != null) ...[
                Icon(sublineIcon, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  subline!,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
