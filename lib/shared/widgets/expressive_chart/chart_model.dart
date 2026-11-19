import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bar (layered columns) or Line. Switching keeps the selection.
enum ExpressiveChartMode { bar, line }

/// [loading] draws skeleton pills only (first load); [data] draws the periods.
enum ExpressiveChartState { data, loading }

/// One plotted series (Income, Expense, or a single custom series).
@immutable
class ExpressiveSeries {
  const ExpressiveSeries({
    required this.name,
    required this.color,
    Color? inverseColor,
  }) : _inverse = inverseColor;

  final String name;
  final Color color;
  final Color? _inverse;

  /// Tone used on the inverseSurface tooltip (money tone 80 / 40).
  Color get inverseColor => _inverse ?? color;

  @override
  bool operator ==(Object other) =>
      other is ExpressiveSeries &&
      other.name == name &&
      other.color == color &&
      other.inverseColor == inverseColor;

  @override
  int get hashCode => Object.hash(name, color, inverseColor);
}

/// One period (a month, a day, ...) of the chart. [values] has one entry per
/// series, in series order.
@immutable
class ExpressivePeriod {
  const ExpressivePeriod({
    required this.key,
    required this.label,
    required this.fullLabel,
    required this.values,
    this.noData = false,
    this.isCurrent = false,
  });

  /// Stable id (survives prepending older periods): yyyy*12+month for months.
  final int key;

  /// X axis label ("Nov").
  final String label;

  /// Tooltip title ("November 2026").
  final String fullLabel;
  final List<double> values;

  /// No transaction at all in this period: Bar draws a hollow ring on the
  /// axis, Line breaks and bridges with a dotted line.
  final bool noData;

  /// The period in progress (bold label, "so far").
  final bool isCurrent;

  bool get isZero => values.every((v) => v <= 0);

  @override
  bool operator ==(Object other) =>
      other is ExpressivePeriod &&
      other.key == key &&
      other.label == label &&
      other.fullLabel == fullLabel &&
      other.noData == noData &&
      other.isCurrent == isCurrent &&
      _listEq(other.values, values);

  @override
  int get hashCode =>
      Object.hash(key, label, fullLabel, noData, isCurrent, Object.hashAll(values));
}

bool _listEq(List<double> a, List<double> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Layout numbers from the handoff.
abstract final class ExpressiveChartMetrics {
  static const double plotHeight = 132;

  /// Room above the plot for the tallest dot / top Y label.
  static const double topPad = 8;
  static const double axisWidth = 36;
  static const double axisWidthLarge = 48;
  static const double edgeFade = 20;
  static const double rubberFactor = 0.3;
  static const double rubberMax = 24;
  static const double minSegment = 6;
  static const double jointGap = 2;

  /// Text scale from which the "largest font" layout applies.
  static const double largeFontScale = 1.3;

  /// Column width for a window of [win] slots: 28 dp at 6, 16 dp at 12,
  /// linear in between (so a 6M to 1Y change animates the width).
  static double columnWidth(double win) {
    if (win <= 6) return 28;
    if (win >= 12) return 16;
    return 28 - (win - 6) / 6 * 12;
  }

  /// Y axis top: the tallest value sits at ~98 % of the axis, rounded up to
  /// two significant figures so the mid label is clean.
  static double niceMax(double maxVal) {
    if (maxVal <= 0) return 100;
    final target = maxVal / 0.98;
    final exp = (math.log(target) / math.ln10).floor() - 1;
    final magnitude = math.pow(10, exp).toDouble();
    return (target / magnitude).ceil() * magnitude;
  }

  /// Deterministic skeleton pill height, 30 to 55 % of the plot.
  static double skeletonFraction(int index) =>
      0.30 + 0.25 * ((index * 0.6180339887) % 1.0);
}
