// Paging by id and per-part recompute: later pages never rerun the query,
// a data / sort change restarts the list, and chart or sort changes only
// recompute what they own (counted through ahJobRuns).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/services/ah_jobs.dart';
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/advanced_history/services/ah_worker.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/isar_test_helper.dart';
import '../data/ah_fixture.dart';

const donut = AhChartSpec(AhChartType.donut, AhChartSplit.category, AhChartMeasure.total);
const bars = AhChartSpec(AhChartType.bars, AhChartSplit.account, AhChartMeasure.count);
const line = AhChartSpec(AhChartType.line, AhChartSplit.month, AhChartMeasure.average);

void main() {
  late Isar isar;
  late AhFixture fx;
  late ProviderContainer c;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
    fx = await buildFixture(isar, n: 600);
    ahJobRuns.clear();
    c = ProviderContainer(overrides: [
      isarProvider.overrideWithValue(isar),
      ahClockProvider.overrideWithValue(() => fixtureNow),
    ]);
  });
  tearDown(() async {
    c.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await closeAndCleanIsar(isar);
  });

  AhViewNotifier view() => c.read(ahViewProvider.notifier);
  final pages = ahTxnPagesProvider(null);
  int runs(Object job) => ahJobRuns[job] ?? 0;

  Future<void> loadAll(int n) async {
    for (var i = 0; i < n; i++) {
      await c.read(pages.notifier).loadMore();
    }
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 300));

  test('later pages come from the id cache, not a new query', () async {
    view().setFilter('amount:>=0');
    c.listen(pages, (_, __) {});
    await c.read(pages.future);
    expect(runs(ahBundleJob), 1);
    await loadAll(3);
    final p = c.read(pages).value!;
    expect(p.items.length, 200);
    expect(p.items.map((t) => t.id).toSet().length, 200);
    expect(runs(ahBundleJob), 1);
    expect(runs(ahOrderJob), 0);
    expect(runs(ahChartJob), 0);
  });

  test('a data change restarts the list without duplicates', () async {
    view().setFilter('amount:>=0');
    c.listen(pages, (_, __) {});
    await c.read(pages.future);
    await loadAll(2);
    expect(c.read(pages).value!.items.length, 150);

    final t = Transaction()
      ..name = 'brand new'
      ..nameLower = 'brand new'
      ..amount = 1
      ..type = 'expense'
      ..categoryId = ''
      ..accountId = '${fx.accounts.first.id}'
      ..createdAt = DateTime(2027)
      ..updatedAt = fixtureNow;
    await isar.writeTxn(() => isar.transactions.put(t));
    await settle();
    final p = await c.read(pages.future);
    expect(p.items.length, 50);
    expect(p.total, fx.txns.length + 1);
    expect(p.items.first.id, t.id); // newest first
    expect(runs(ahBundleJob), 2);
    await loadAll(20);
    final all = c.read(pages).value!;
    expect(all.items.length, fx.txns.length + 1);
    expect(all.items.map((x) => x.id).toSet().length, all.items.length);
  });

  test('a sort change reorders from page one and keeps KPIs and charts', () async {
    view().setFilter('amount:>=0');
    view().addChart(donut);
    c.listen(pages, (_, __) {});
    c.listen(ahKpisProvider, (_, __) {});
    c.listen(ahChartDataProvider(donut), (_, __) {});
    await c.read(pages.future);
    await c.read(ahChartDataProvider(donut).future);
    await loadAll(2);
    expect(runs(ahBundleJob), 1);

    view().setSort(const AhSort(AhSortField.amount));
    final p = await c.read(pages.future);
    await c.read(ahKpisProvider.future);
    await c.read(ahChartDataProvider(donut).future);
    expect(p.items.length, 50);
    expect(p.items.first.amount.abs(),
        fx.txns.map((t) => t.amount.abs()).reduce((a, b) => a > b ? a : b));
    expect(runs(ahOrderJob), 1);
    expect(runs(ahBundleJob), 1, reason: 'KPIs / charts are not recomputed');
    expect(runs(ahChartJob), 0);
  });

  test('loadMore in flight while the view changes is dropped', () async {
    view().setFilter('amount:>=0');
    c.listen(pages, (_, __) {});
    await c.read(pages.future);
    final late = c.read(pages.notifier).loadMore();
    view().setSort(const AhSort(AhSortField.amount)); // rebuilds the notifier
    final fresh = await c.read(pages.future);
    await late;
    final now = c.read(pages).value!;
    expect(now.items.length, 50, reason: 'the stale page was not appended');
    expect(now.items.first.id, fresh.items.first.id);
    await c.read(pages.notifier).loadMore();
    final next = c.read(pages).value!;
    expect(next.items.length, 100);
    expect(next.items.map((t) => t.id).toSet().length, 100);
  });

  test('reordering charts computes nothing and keeps loaded pages', () async {
    view().setFilter('amount:>=0');
    view().addChart(line);
    view().addChart(bars);
    view().addChart(donut);
    c.listen(pages, (_, __) {});
    c.listen(ahKpisProvider, (_, __) {});
    for (final s in [donut, bars, line]) {
      c.listen(ahChartDataProvider(s), (_, __) {});
    }
    await c.read(pages.future);
    for (final s in [donut, bars, line]) {
      await c.read(ahChartDataProvider(s).future);
    }
    await loadAll(2); // 3 pages = 150 rows
    expect(c.read(pages).value!.items.length, 150);
    // Fresh query: charts come from the one bundle job.
    expect(runs(ahBundleJob), 1);
    expect(runs(ahChartJob), 0);

    view().moveChart(0, 2);
    await settle();
    expect(runs(ahBundleJob), 1);
    expect(runs(ahOrderJob), 0);
    expect(runs(ahChartJob), 0);
    expect(c.read(pages).value!.items.length, 150);
  });

  test('adding / editing a chart computes only that chart; removing nothing',
      () async {
    view().setFilter('amount:>=0');
    view().addChart(donut);
    c.listen(pages, (_, __) {});
    c.listen(ahKpisProvider, (_, __) {});
    c.listen(ahChartDataProvider(donut), (_, __) {});
    await c.read(pages.future);
    await c.read(ahChartDataProvider(donut).future);
    await loadAll(1);
    expect(runs(ahBundleJob), 1);
    expect(runs(ahChartJob), 0);

    view().addChart(bars);
    c.listen(ahChartDataProvider(bars), (_, __) {});
    final d = await c.read(ahChartDataProvider(bars).future);
    expect(d.state, AhChartState.ok);
    expect(runs(ahChartJob), 1);
    expect(runs(ahBundleJob), 1);

    final edited = bars.copyWith(measure: AhChartMeasure.total);
    view().updateChart(0, edited);
    c.listen(ahChartDataProvider(edited), (_, __) {});
    await c.read(ahChartDataProvider(edited).future);
    expect(runs(ahChartJob), 2);

    view().removeChart(0);
    await settle();
    expect(runs(ahChartJob), 2);
    expect(runs(ahBundleJob), 1);
    expect(c.read(pages).value!.items.length, 100);
  });

  test('worker lifecycle: tracker never goes negative', () {
    final a = Object(), b = Object();
    AhViewNotifier.pageClosed(a);
    expect(AhViewNotifier.openPages, 0);
    AhViewNotifier.pageOpened(a);
    AhViewNotifier.pageOpened(a);
    AhViewNotifier.pageOpened(b);
    expect(AhViewNotifier.openPages, 2);
    AhViewNotifier.pageClosed(a);
    AhViewNotifier.pageClosed(a);
    AhViewNotifier.pageClosed(b);
    expect(AhViewNotifier.openPages, 0);
    AhWorker.shutdown(); // no worker: a no-op
  });
}
