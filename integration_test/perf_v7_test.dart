// v7.0.0 perf harness. Run in profile mode on a device (see specs/v7.0.0/performance.md):
//   flutter drive --profile --dart-define=KUBER_UNLOCK_PRO=true \
//     --driver=test_driver/perf_driver.dart --target=integration_test/perf_v7_test.dart
// Seeds a 20,000 transaction / 7 year ledger once (onboarding skipped), then
// records Custom dashboards timings and frame timings. Results land in
// build/perf_v7.json via the driver.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:kuber/features/transactions/widgets/transaction_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'smoke_helpers.dart';

QueryNode _q(String text) => parseItems(tokenize(text)).node!;

Future<int> _time(Future<void> Function() body) async {
  final sw = Stopwatch()..start();
  await body();
  return sw.elapsedMilliseconds;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final report = <String, dynamic>{};

  testWidgets('perf v7', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    await boot(t);
    await seedLargeLedger();
    report['txns'] = await db.transactions.count();
    final c = container(t);
    c.invalidate(transactionListProvider);
    await settle(t, const Duration(seconds: 4)); // on-open batch + tab warm-up

    // ---- Custom dashboards timings (provider level, UI isolate wall time) ----
    final v = c.read(ahViewProvider.notifier);
    final keep = <ProviderSubscription>[];
    v.applyView(AhView(queryText: 'type:expense', node: _q('type:expense'),
        charts: const [AhChartSpec(AhChartType.bars, AhChartSplit.month, AhChartMeasure.total)]));
    keep.add(c.listen(ahKpisProvider, (_, __) {}));
    keep.add(c.listen(ahTxnPagesProvider(null), (_, __) {}));
    final ah = <String, dynamic>{};
    ah['firstQueryMs'] = await _time(() => c.read(ahTxnPagesProvider(null).future));
    final pages = <int>[];
    for (var i = 0; i < 10; i++) {
      pages.add(await _time(() => c.read(ahTxnPagesProvider(null).notifier).loadMore()));
    }
    ah['loadMoreMs'] = pages;
    ah['rowsAfterLoadMore'] = c.read(ahTxnPagesProvider(null)).valueOrNull?.items.length;
    const donut = AhChartSpec(AhChartType.donut, AhChartSplit.category, AhChartMeasure.total);
    ah['addChartMs'] = await _time(() async {
      v.addChart(donut);
      keep.add(c.listen(ahChartDataProvider(donut), (_, __) {}));
      await c.read(ahChartDataProvider(donut).future);
    });
    ah['rowsAfterAddChart'] = (await c.read(ahTxnPagesProvider(null).future)).items.length;
    ah['reorderMs'] = await _time(() async {
      v.moveChart(1, 0);
      await c.read(ahChartDataProvider(donut).future);
      await c.read(ahTxnPagesProvider(null).future);
    });
    ah['rowsAfterReorder'] = (await c.read(ahTxnPagesProvider(null).future)).items.length;
    final counts = <int>[];
    const draft = 'type:expense amount:>100 (category:Food OR category:Shopping) NOT words:uber';
    for (var n = 4; n <= draft.length; n += 12) {
      final r = parseItems(tokenize(draft.substring(0, n)));
      if (r.node == null) continue;
      final node = r.node!;
      counts.add(await _time(() async {
        final s = c.listen(ahCountProvider(node), (_, __) {});
        await c.read(ahCountProvider(node).future);
        s.close();
      }));
    }
    ah['liveCountMs'] = counts;
    for (final s in keep) {
      s.close();
    }
    report['dashboards'] = ah;
    debugPrint('KUBER_PERF dashboards $ah');

    // ---- Frame timings ----
    Future<void> frames(String key, Future<void> Function() body) async {
      final timings = <FrameTiming>[];
      void cb(List<FrameTiming> l) => timings.addAll(l);
      SchedulerBinding.instance.addTimingsCallback(cb);
      await body();
      await settle(t, const Duration(milliseconds: 500));
      SchedulerBinding.instance.removeTimingsCallback(cb);
      final build = timings.map((f) => f.buildDuration.inMicroseconds / 1000).toList()..sort();
      final raster = timings.map((f) => f.rasterDuration.inMicroseconds / 1000).toList()..sort();
      double p(List<double> l, double q) => l.isEmpty ? 0 : l[min(l.length - 1, (l.length * q).floor())];
      report[key] = {
        'frames': timings.length,
        'jank>16.7': timings.where((f) => f.totalSpan.inMicroseconds > 16700).length,
        'jank>8.3': timings.where((f) => f.totalSpan.inMicroseconds > 8300).length,
        'buildP90': p(build, .9), 'buildMax': build.isEmpty ? 0 : build.last,
        'rasterP90': p(raster, .9), 'rasterMax': raster.isEmpty ? 0 : raster.last,
      };
      debugPrint('KUBER_PERF $key ${report[key]}');
    }

    Future<void> fling(Finder f, int n, {double dy = -1400}) async {
      for (var i = 0; i < n; i++) {
        await t.fling(f, Offset(0, dy), 2500);
        await settle(t, const Duration(milliseconds: 700));
      }
    }

    await frames('tabSwitch', () async {
      for (final p in ['/history', '/analytics', '/more', '/', '/history', '/analytics', '/more', '/']) {
        await go(t, p);
      }
    });

    await go(t, '/history');
    await settle(t, const Duration(seconds: 3));
    dumpTexts(t, 'history');
    debugPrint('KUBER_PERF types: day=${find.byType(TransactionDayCard).evaluate().length} row=${find.byType(TransactionRow).evaluate().length} scroll=${find.byType(Scrollable).evaluate().length}');
    await pumpUntil(t, find.byType(TransactionDayCard), timeout: const Duration(seconds: 30), reason: 'History rows');
    await settle(t, const Duration(seconds: 1));
    Finder list([Type anchor = TransactionDayCard]) =>
        find.ancestor(of: find.byType(anchor).first, matching: find.byType(Scrollable)).first;
    Finder rows() => find.descendant(of: find.byType(TransactionDayCard).first, matching: find.byType(InkWell));
    await frames('historyScroll', () => fling(list(), 10));
    await fling(list(), 10, dy: 1400);
    await settle(t, const Duration(seconds: 1));

    await frames('historyPressRelease', () async {
      for (var i = 0; i < 12; i++) {
        final row = rows().at(i % 2);
        final g = await t.startGesture(t.getCenter(row));
        await t.pump(const Duration(milliseconds: 70));
        await g.cancel();
        await t.pump(const Duration(milliseconds: 90));
      }
    });

    await frames('sheetOpen', () async {
      for (var i = 0; i < 3; i++) {
        await t.tap(rows().first);
        await settle(t, const Duration(milliseconds: 700));
        Navigator.of(t.element(find.byType(TransactionDayCard).first), rootNavigator: true).pop();
        await settle(t, const Duration(milliseconds: 500));
      }
    });

    await go(t, '/');
    await push(t, '/more/settings/theme');
    await frames('quickNavOpen', () async {
      for (var i = 0; i < 3; i++) {
        await t.tap(find.text(en.themeLabel).first);
        await settle(t, const Duration(milliseconds: 700));
        Navigator.of(t.element(find.text(en.themeLabel).first), rootNavigator: true).pop();
        await settle(t, const Duration(milliseconds: 500));
      }
    });
    await go(t, '/');

    v.applyView(AhView(queryText: 'type:expense', node: _q('type:expense')));
    await push(t, '/advanced-history');
    await settle(t, const Duration(seconds: 2));
    await pumpUntil(t, find.byType(TransactionRow), timeout: const Duration(seconds: 30), reason: 'dashboard rows');
    await frames('dashboardsScroll', () => fling(list(TransactionRow), 12));

    binding.reportData = report;
    debugPrint('KUBER_PERF ${report.toString()}');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
