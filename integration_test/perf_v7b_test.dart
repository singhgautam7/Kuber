// v7.0.0-b perf harness (specs/v7.0.0-b/performance.md). Same 20,000 txn /
// 7 year ledger as perf_v7_test.dart.
//   Timings (profile):
//     flutter drive --profile --driver=test_driver/perf_v7b_driver.dart \
//       --target=integration_test/perf_v7b_test.dart
//   Balance card rebuild count (debug only, debugOnRebuildDirtyWidget):
//     flutter test integration_test/perf_v7b_test.dart --no-uninstall
// Cold start / Home first frame come from `am start -W` (see performance.md).
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'smoke_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final report = <String, dynamic>{'mode': kProfileMode ? 'profile' : 'debug'};

  testWidgets('perf v7b', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    await boot(t);
    await seedLargeLedger();
    report['txns'] = await db.transactions.count();
    final c = container(t);
    c.invalidate(transactionListProvider);
    await settle(t, const Duration(seconds: 4)); // on-open batch + tab warm-up

    Future<void> frames(String key, Future<void> Function() body) async {
      final timings = <FrameTiming>[];
      void cb(List<FrameTiming> l) => timings.addAll(l);
      SchedulerBinding.instance.addTimingsCallback(cb);
      final sw = Stopwatch()..start();
      await body();
      final wall = sw.elapsedMilliseconds;
      await settle(t, const Duration(milliseconds: 500));
      SchedulerBinding.instance.removeTimingsCallback(cb);
      final build = timings.map((f) => f.buildDuration.inMicroseconds / 1000).toList()..sort();
      final raster = timings.map((f) => f.rasterDuration.inMicroseconds / 1000).toList()..sort();
      double p(List<double> l, double q) => l.isEmpty ? 0 : l[min(l.length - 1, (l.length * q).floor())];
      report[key] = {
        'wallMs': wall,
        'frames': timings.length,
        'jank>16.7': timings.where((f) => f.totalSpan.inMicroseconds > 16700).length,
        'jank>8.3': timings.where((f) => f.totalSpan.inMicroseconds > 8300).length,
        'buildP90': p(build, .9), 'buildMax': build.isEmpty ? 0 : build.last,
        'rasterP90': p(raster, .9), 'rasterMax': raster.isEmpty ? 0 : raster.last,
        // Which frames were slow on the UI thread, in order (ms).
        'buildOver8': [
          for (final f in timings)
            if (f.buildDuration.inMicroseconds > 8000) (f.buildDuration.inMicroseconds / 1000).round(),
        ],
      };
      debugPrint('KUBER_PERF $key ${report[key]}');
    }

    Finder homeList() => find.byWidgetPredicate((w) =>
        w is Scrollable && w.axisDirection == AxisDirection.down).first;
    Finder hScrollables() => find.byWidgetPredicate((w) =>
        w is Scrollable && (w.axisDirection == AxisDirection.left || w.axisDirection == AxisDirection.right));

    // The Income & expense card: brings its Bar / Line chip into view.
    Future<Offset?> chartChip() async {
      final chip = find.text('Bar');
      if (chip.evaluate().isEmpty) {
        try {
          await t.scrollUntilVisible(chip, 250, scrollable: homeList(), maxScrolls: 30);
        } catch (_) {
          return null;
        }
      }
      await t.ensureVisible(chip.first);
      await settle(t, const Duration(milliseconds: 400));
      return t.getCenter(chip.first);
    }

    Future<void> barLine() async {
      if (await chartChip() == null) {
        report['barLineMissing'] = true;
        return;
      }
      for (var i = 0; i < 3; i++) {
        for (final pair in [['Bar', 'Line'], ['Line', 'Bar']]) {
          final chip = find.text(pair[0]);
          if (chip.evaluate().isEmpty) return;
          await t.tap(chip.first, warnIfMissed: false);
          await settle(t, const Duration(milliseconds: 500));
          final item = find.text(pair[1]);
          if (item.evaluate().isEmpty) return;
          await t.tap(item.last, warnIfMissed: false);
          await settle(t, const Duration(milliseconds: 700));
        }
      }
    }

    // The chart's own horizontal scroll: the horizontal Scrollable just
    // below the Bar / Line chip.
    Future<void> hScroll(String key) async {
      final chip = await chartChip();
      Finder? target;
      if (chip != null) {
        for (final e in hScrollables().evaluate()) {
          final r = e.renderObject;
          if (r is! RenderBox || !r.attached) continue;
          final top = r.localToGlobal(Offset.zero).dy;
          if (top > chip.dy - 40 && top < chip.dy + 420) {
            target = find.byElementPredicate((x) => identical(x, e));
            break;
          }
        }
      }
      report['${key}Found'] = target != null;
      if (target == null) return;
      for (var i = 0; i < 4; i++) {
        await t.fling(target, const Offset(600, 0), 2000);
        await settle(t, const Duration(milliseconds: 700));
      }
      for (var i = 0; i < 4; i++) {
        await t.fling(target, const Offset(-600, 0), 2000);
        await settle(t, const Duration(milliseconds: 700));
      }
    }

    // ---- Balance card rebuild count (debug only) ----
    if (kDebugMode) {
      var rebuilds = 0;
      debugOnRebuildDirtyWidget = (e, _) {
        if (e.widget.runtimeType.toString().contains('BalanceHero')) rebuilds++;
      };
      final cats = await db.categorys.where().findAll();
      final accs = await db.accounts.where().findAll();
      final now = DateTime.now();
      await c.read(transactionListProvider.notifier).add(Transaction()
        ..name = 'Perf probe'
        ..nameLower = 'perf probe'
        ..amount = 123
        ..type = 'expense'
        ..categoryId = cats.first.id.toString()
        ..accountId = accs.first.id.toString()
        ..createdAt = now
        ..updatedAt = now);
      await settle(t, const Duration(seconds: 2));
      debugOnRebuildDirtyWidget = null;
      report['balanceCardRebuildsOnAdd'] = rebuilds;
      debugPrint('KUBER_PERF balanceCardRebuildsOnAdd $rebuilds');
      binding.reportData = report;
      return;
    }

    // ---- Timings (profile) ----
    await frames('homeScroll', () async {
      for (var i = 0; i < 3; i++) {
        await t.fling(homeList(), const Offset(0, -900), 2500);
        await settle(t, const Duration(milliseconds: 700));
        await t.fling(homeList(), const Offset(0, 900), 2500);
        await settle(t, const Duration(milliseconds: 700));
      }
    });
    await frames('homeChartBarLine', barLine);
    await frames('homeChartHScroll', () => hScroll('homeChartHScroll'));

    await go(t, '/history');
    await settle(t, const Duration(seconds: 1));
    await frames('analyticsFirstOpen', () async {
      await go(t, '/analytics');
      await settle(t, const Duration(milliseconds: 1500));
    });
    await frames('analyticsChartBarLine', barLine);
    await frames('analyticsChartHScroll', () => hScroll('analyticsChartHScroll'));
    await go(t, '/');

    binding.reportData = report;
    debugPrint('KUBER_PERF ${report.toString()}');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
