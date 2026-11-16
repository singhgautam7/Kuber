import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';

void main() {
  test('a sort that does not fit the grouping falls back to its default', () {
    const date = AhSort(AhSortField.date, descending: false);
    expect(date.fitFor(AhGroupBy.none), date);
    expect(date.fitFor(AhGroupBy.category), AhSort.groupedDefault);
    const count = AhSort(AhSortField.count);
    expect(count.fitFor(AhGroupBy.tag), count);
    expect(count.fitFor(AhGroupBy.none), AhSort.ungroupedDefault);
  });
}
