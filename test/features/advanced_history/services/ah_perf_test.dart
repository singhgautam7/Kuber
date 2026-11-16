// Indicative numbers on a 6,500 transaction ledger (desktop, inline isolate).
// Run: flutter test test/features/advanced_history/services/ah_perf_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/services/ah_engine.dart';

import '../../../helpers/isar_test_helper.dart';
import '../data/ah_fixture.dart';

void main() {
  late Isar isar;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    isar = await openTestIsar();
    await buildFixture(isar, n: 6500, seed: 3);
  });
  tearDown(() => closeAndCleanIsar(isar));

  test('query + KPIs timings', () async {
    final out = <String>[];
    Future<void> run(String label, String q, AhGroupBy g,
        {List<AhChartSpec> charts = const []}) async {
      final node = parseItems(tokenize(q)).node;
      final sw = Stopwatch()..start();
      final b = await ahBundleJob(
          isar, AhBundleParams(node, g, AhSort.groupedDefault, charts, fixtureNow));
      sw.stop();
      out.add('$label: ${sw.elapsedMilliseconds} ms (${b.kpis.transactions} rows)');
      expect(sw.elapsedMilliseconds, lessThan(2000));
    }

    await run('first query + KPIs (date:thisyear)', 'date:thisyear', AhGroupBy.none);
    await run('same, warm', 'date:thisyear', AhGroupBy.none);
    await run('grouped by Category', 'amount:>=0', AhGroupBy.category);
    await run('grouped by Tag', 'amount:>=0', AhGroupBy.tag);
    await run('grouped by Month', 'amount:>=0', AhGroupBy.month);
    await run('words search swiggy', 'swiggy', AhGroupBy.none);
    await run('words in notes', 'gift', AhGroupBy.none);
    await run('tag + category + date', 'tag:trip category:food date:2026', AhGroupBy.none);
    await run('4 charts + group', 'amount:>=0', AhGroupBy.category, charts: const [
      AhChartSpec(AhChartType.donut, AhChartSplit.category, AhChartMeasure.total),
      AhChartSpec(AhChartType.bars, AhChartSplit.tag, AhChartMeasure.count),
      AhChartSpec(AhChartType.line, AhChartSplit.month, AhChartMeasure.average),
      AhChartSpec(AhChartType.donut, AhChartSplit.account, AhChartMeasure.total),
    ]);
    final sw = Stopwatch()..start();
    await AhLookups.load(isar);
    sw.stop();
    out.add('lookups load: ${sw.elapsedMilliseconds} ms');
    // ignore: avoid_print
    print(out.join('\n'));
  });
}
