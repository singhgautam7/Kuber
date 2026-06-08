import 'package:flutter/material.dart';

/// Optional inline visualization rendered inside a Kuber bubble, below the
/// text. Augments the plain-English answer, never replaces it.
sealed class VizPayload {
  const VizPayload();

  Map<String, dynamic> toJson();

  static VizPayload? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    switch (json['kind'] as String?) {
      case 'topCategories':
        return TopCategoriesViz(
          (json['rows'] as List<dynamic>? ?? const [])
              .map((e) => CategoryVizRow.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      case 'budgetStatus':
        return BudgetStatusViz(
          spent: (json['spent'] as num?)?.toDouble() ?? 0,
          budgeted: (json['budgeted'] as num?)?.toDouble() ?? 0,
          status: BudgetStatus.values[(json['status'] as int? ?? 0)
              .clamp(0, BudgetStatus.values.length - 1)],
          caption: json['caption'] as String? ?? '',
        );
      default:
        return null;
    }
  }
}

/// Ranked horizontal-bar list of top spending categories.
class TopCategoriesViz extends VizPayload {
  final List<CategoryVizRow> rows;
  const TopCategoriesViz(this.rows);

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'topCategories',
    'rows': rows.map((r) => r.toJson()).toList(),
  };
}

class CategoryVizRow {
  final String name;
  final Color color;
  final double amount;

  /// Share of the total expense over the period, 0.0 to 1.0. The bar fill width
  /// is computed relative to the largest row by the renderer (so the top
  /// category fills the track); this value drives semantics/captions.
  final double percentOfTotal;

  const CategoryVizRow({
    required this.name,
    required this.color,
    required this.amount,
    required this.percentOfTotal,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'color': color.toARGB32(),
    'amount': amount,
    'percentOfTotal': percentOfTotal,
  };

  factory CategoryVizRow.fromJson(Map<String, dynamic> json) => CategoryVizRow(
    name: json['name'] as String? ?? '',
    color: Color((json['color'] as num?)?.toInt() ?? 0xFF888888),
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    percentOfTotal: (json['percentOfTotal'] as num?)?.toDouble() ?? 0,
  );
}

enum BudgetStatus { withinBudget, approaching, over }

/// Thin progress bar for a single budget, coloured by [status].
class BudgetStatusViz extends VizPayload {
  final double spent;
  final double budgeted;
  final BudgetStatus status;

  /// e.g. "₹4,200 of ₹5,000 (84%)".
  final String caption;

  const BudgetStatusViz({
    required this.spent,
    required this.budgeted,
    required this.status,
    required this.caption,
  });

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'budgetStatus',
    'spent': spent,
    'budgeted': budgeted,
    'status': status.index,
    'caption': caption,
  };
}
