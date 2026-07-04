part of 'income_expense_chart.dart';

/// Line variant of the redesigned income/expense chart (screens 4b/4d).
/// Lives in a part file purely to keep the main widget file under the
/// 400-line ceiling; shares the state class's private members.
extension _LineVariant on _IncomeExpenseChartState {
  Widget _buildLineChart(ColorScheme cs, double maxY) {
    final n = widget.points.length;

    LineChartBarData series(
      Color color,
      double Function(IncomeExpensePoint) value, {
      bool areaFill = false,
    }) {
      return LineChartBarData(
        spots: [
          for (var i = 0; i < n; i++)
            FlSpot(i.toDouble(), value(widget.points[i])),
        ],
        color: color,
        barWidth: 2.5,
        isCurved: false,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, _) => spot.x.toInt() == _selectedIndex,
          getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
            radius: 4.5,
            color: color,
            strokeWidth: 2,
            strokeColor: cs.surfaceContainer,
          ),
        ),
        belowBarData: BarAreaData(
          show: areaFill,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.tertiary.withValues(alpha: 0.18),
              cs.tertiary.withValues(alpha: 0),
            ],
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        minX: -0.3,
        maxX: (n - 1) + 0.3,
        titlesData: _titles(cs),
        gridData: _grid(cs, maxY),
        borderData: FlBorderData(show: false),
        extraLinesData: _selectedIndex == null
            ? const ExtraLinesData()
            : ExtraLinesData(verticalLines: [
                VerticalLine(
                  x: _selectedIndex!.toDouble(),
                  color: cs.primary.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [2, 3],
                ),
              ]),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            final spots = response?.lineBarSpots;
            if (spots == null || spots.isEmpty) {
              _onTapIndex(null);
              return;
            }
            _onTapIndex(spots.first.x.round());
          },
        ),
        lineBarsData: [
          // Income line gets the soft area fill in expanded mode only (4d).
          series(cs.tertiary, (p) => p.income, areaFill: !widget.compact),
          series(cs.error, (p) => p.expense),
        ],
      ),
    );
  }
}

/// Clips horizontally (so scrollable bars stay inside the card) while leaving
/// the top/bottom open for the floating tooltip.
class _HorizontalClipper extends CustomClipper<Rect> {
  const _HorizontalClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -2000, size.width, size.height + 2000);

  @override
  bool shouldReclip(_HorizontalClipper oldClipper) => false;
}
