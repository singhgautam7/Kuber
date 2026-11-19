// v7.0.0-c perf harness (specs/v7.0.0-c/performance.md). Same 20,000 txn /
// 7 year ledger as perf_v7b_test.dart.
//   Timings (profile):
//     flutter drive --profile --driver=test_driver/perf_v7c_driver.dart \
//       --target=integration_test/perf_v7c_test.dart
//   Header / content rebuild counts while scrolling (debug only):
//     flutter test integration_test/perf_v7c_test.dart --no-uninstall
// Cold start / Home first frame come from `am start -W` (see performance.md).
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'smoke_helpers.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final report = <String, dynamic>{'mode': kProfileMode ? 'profile' : 'debug'};

  testWidgets('perf v7c', (t) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    await boot(t);
    await seedLargeLedger();
    report['txns'] = await db.transactions.count();
    container(t).invalidate(transactionListProvider);
    await settle(t, const Duration(seconds: 4)); // on-open batch + tab warm-up

    // Flings at the middle of the screen, so they hit the top route's list.
    Future<void> flings(int n, {double dy = 900}) async {
      final size = t.view.physicalSize / t.view.devicePixelRatio;
      final at = Offset(size.width / 2, size.height * 0.55);
      for (var i = 0; i < n; i++) {
        await t.flingFrom(at, Offset(0, -dy), 2500);
        await settle(t, const Duration(milliseconds: 700));
      }
      for (var i = 0; i < n; i++) {
        await t.flingFrom(at, Offset(0, dy), 2500);
        await settle(t, const Duration(milliseconds: 700));
      }
    }

    // Short drags across the header's thresholds (0 → 40 → 0 dp), the
    // case where a scroll-linked header would rebuild every frame.
    Future<void> nudges() async {
      final size = t.view.physicalSize / t.view.devicePixelRatio;
      final at = Offset(size.width / 2, size.height * 0.55);
      for (var i = 0; i < 4; i++) {
        await t.dragFrom(at, const Offset(0, -120));
        await settle(t, const Duration(milliseconds: 500));
        await t.dragFrom(at, const Offset(0, 120));
        await settle(t, const Duration(milliseconds: 500));
      }
    }

    // ---- Rebuild counts while scrolling (debug only) ----
    if (kDebugMode) {
      Future<void> count(String key, String path, {bool pushed = false}) async {
        if (pushed) {
          await push(t, path);
        } else {
          await go(t, path);
        }
        await settle(t, const Duration(seconds: 1));
        var header = 0, all = 0;
        final byType = <String, int>{};
        debugOnRebuildDirtyWidget = (e, _) {
          all++;
          final n = e.widget.runtimeType.toString();
          byType[n] = (byType[n] ?? 0) + 1;
          if (e.widget.runtimeType.toString() == 'KuberAppBar') header++;
        };
        await flings(2);
        await nudges();
        debugOnRebuildDirtyWidget = null;
        report['${key}HeaderRebuilds'] = header;
        report['${key}AllRebuilds'] = all;
        debugPrint('KUBER_PERF $key header=$header all=$all');
        final top = byType.entries.toList()..sort((a, b) => b.value - a.value);
        debugPrint('KUBER_PERF $key top ${top.take(12).map((e) => '${e.key}:${e.value}').join(' ')}');
        if (pushed) await back(t);
      }

      await count('categories', '/more/categories');
      await count('preferences', '/more/settings/preferences');
      await count('addLoan', '/loans/add', pushed: true);
      binding.reportData = report;
      return;
    }

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
        'buildP90': p(build, .9),
        'buildMax': build.isEmpty ? 0 : build.last,
        'rasterP90': p(raster, .9),
        'buildOver8': [
          for (final f in timings)
            if (f.buildDuration.inMicroseconds > 8000) (f.buildDuration.inMicroseconds / 1000).round(),
        ],
      };
      debugPrint('KUBER_PERF $key ${report[key]}');
    }

    // ---- Timings (profile) ----
    await frames('homeScroll', () => flings(3));
    await go(t, '/more');
    await frames('analyticsFirstOpen', () async {
      await go(t, '/analytics');
      await settle(t, const Duration(milliseconds: 1500));
    });
    await go(t, '/history');
    await settle(t, const Duration(seconds: 1));
    await frames('historyScroll', () => flings(3, dy: 1400));
    await go(t, '/more/categories');
    await frames('categoriesScroll', () async {
      await flings(2);
      await nudges();
    });
    await go(t, '/more/settings/preferences');
    await frames('settingsScroll', () async {
      await flings(2);
      await nudges();
    });
    await push(t, '/loans/add');
    await settle(t, const Duration(seconds: 1));
    await frames('formScroll', () async {
      await flings(2);
      await nudges();
    });
    await back(t);
    await go(t, '/');

    binding.reportData = report;
    debugPrint('KUBER_PERF ${report.toString()}');
  }, timeout: const Timeout(Duration(minutes: 10)));
}
