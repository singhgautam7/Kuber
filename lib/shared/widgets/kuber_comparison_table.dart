import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/locale_font.dart';

/// A static, non-clickable 3-column Free vs Pro comparison table with a leading
/// icon column. A shared sibling of [InfoTable] (same `surfaceContainer` fill,
/// `cs.outline` border, `KuberRadius.md`, row rhythm and `localeFont`), not a
/// fork of it. Used on the Kuber Pro page to state the real free-tier limit for
/// every gated feature and name what stays free.
///
/// Entirely non-interactive: no `InkWell`, no chevron, no tap target. The Pro
/// value cell and the always-free row carry a small `tertiary` (green) check.
class KuberComparisonTable extends StatelessWidget {
  final List<ComparisonEntry> rows;

  /// Compact density (smaller icon, tighter padding) for tight in-context
  /// widths. The caller can pass `dense: true` or leave it to full phrasing.
  final bool dense;

  const KuberComparisonTable({required this.rows, this.dense = false, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dividerColor = cs.outline.withValues(alpha: 0.6);

    // Derive density from the available width so the three columns stay legible
    // on small phones (the feature name must not break mid-word). Callers can
    // also force dense.
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveDense = dense || constraints.maxWidth < 400;

        final children = <Widget>[_HeaderRow(dense: effectiveDense)];
        for (final entry in rows) {
          children.add(Divider(height: 1, thickness: 1, color: dividerColor));
          children.add(switch (entry) {
            ComparisonGroup() => _GroupRow(title: entry.title),
            ComparisonRow() => _FeatureRow(row: entry, dense: effectiveDense),
          });
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
      },
    );
  }
}

// ── Row models ──────────────────────────────────────────────────────────────

sealed class ComparisonEntry {
  const ComparisonEntry();
}

/// A small-caps group subheader (e.g. "Advanced features").
class ComparisonGroup extends ComparisonEntry {
  final String title;
  const ComparisonGroup(this.title);
}

/// A feature row: icon, name, the real free-tier value, and the Pro value.
/// Set [freeChecked] for the always-free row so the Free cell also shows the
/// green check.
class ComparisonRow extends ComparisonEntry {
  final IconData icon;
  final String feature;
  final String free;
  final String pro;
  final bool freeChecked;

  const ComparisonRow({
    required this.icon,
    required this.feature,
    required this.free,
    required this.pro,
    this.freeChecked = false,
  });
}

// ── Rendering ─────────────────────────────────────────────────────────────

// Column flex ratios. Using flex (not fixed pixel widths) lets the value
// columns keep enough room for their longest words ("Unlimited", "Automatic",
// "Included") on narrow phones instead of breaking mid-word, while still
// scaling down gracefully. Feature gets slightly more room than each value.
const int _featureFlex = 5;
const int _valueFlex = 4;

class _HeaderRow extends StatelessWidget {
  final bool dense;
  const _HeaderRow({required this.dense});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    TextStyle label(Color c) => localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: c,
        );

    return Container(
      color: cs.surfaceContainerHigh,
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 16,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: _featureFlex,
            child: Text('FEATURE', style: label(cs.onSurfaceVariant)),
          ),
          Expanded(
            flex: _valueFlex,
            child: Text('FREE',
                textAlign: TextAlign.center, style: label(cs.onSurfaceVariant)),
          ),
          Expanded(
            flex: _valueFlex,
            child: Text('PRO',
                textAlign: TextAlign.center, style: label(cs.primary)),
          ),
        ],
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  final String title;
  const _GroupRow({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final ComparisonRow row;
  final bool dense;
  const _FeatureRow({required this.row, required this.dense});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconSize = dense ? 22.0 : 32.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: _featureFlex,
            child: Row(
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Icon(row.icon,
                      size: dense ? 13 : 17, color: cs.primary),
                ),
                SizedBox(width: dense ? 8 : 10),
                Flexible(
                  child: Text(
                    row.feature,
                    style: localeFont(
                      fontSize: dense ? 11.5 : 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _valueFlex,
            child: _ValueCell(
              text: row.free,
              checked: row.freeChecked,
              dense: dense,
              bold: false,
            ),
          ),
          Expanded(
            flex: _valueFlex,
            child: _ValueCell(
              text: row.pro,
              checked: true,
              dense: dense,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String text;
  final bool checked;
  final bool dense;
  final bool bold;

  const _ValueCell({
    required this.text,
    required this.checked,
    required this.dense,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (checked) ...[
          Icon(Icons.check_rounded, size: dense ? 12 : 14, color: cs.tertiary),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: dense ? 11 : 12,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
              color: bold ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
