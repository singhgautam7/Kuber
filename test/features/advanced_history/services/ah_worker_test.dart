// Worker isolate: results match the inline run, the cache follows data
// changes, shutdown/restart works. Timings print with --reporter expanded.
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/services/ah_jobs.dart';
import 'package:kuber/features/advanced_history/services/ah_worker.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/data/transaction_repository.dart';

import '../../../helpers/isar_test_helper.dart';
import '../data/ah_fixture.dart';

/// What runAh did before: a one-shot isolate that reopens Isar each time.
Future<R> oneShot<P, R>(Isar isar, P p, Future<R> Function(Isar, P) fn) {
  final dir = isar.directory!;
  return Isolate.run(() async {
    await Isar.initializeIsarCore(download: true);
    final h = await Isar.open(kIsarSchemas, directory: dir, inspector: false);
    try {
      return await fn(h, p);
    } finally {
      await h.close();
    }
  });
}

void main() {
  late Isar isar;
  late Directory dir;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    dir = Directory.systemTemp.createTempSync('ah_worker_');
    isar = await Isar.open(kIsarSchemas,
        directory: dir.path, name: Isar.defaultName, inspector: false);
    await buildFixture(isar, n: 6500, seed: 3);
    TransactionRepository.offloadGetAll = true;
    AhWorker.testCore = true;
  });
  tearDown(() async {
    AhWorker.shutdown();
    TransactionRepository.offloadGetAll = false;
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await isar.close();
    dir.deleteSync(recursive: true);
  });

  Future<int> ms(Future<void> Function() f) async {
    final sw = Stopwatch()..start();
    await f();
    return sw.elapsedMilliseconds;
  }

  test('worker matches inline, follows data changes, restarts', () async {
    final node = parseItems(tokenize('date:thisyear')).node;
    final params = AhCountParams(node, fixtureNow);
    final inline = await ahCountJob(isar, params);
    expect(await runAh(isar, params, ahCountJob), inline);

    // New transaction: the worker's cached lookups/queries see it.
    final t = Transaction()
      ..name = 'late'
      ..nameLower = 'late'
      ..amount = 5
      ..type = 'expense'
      ..categoryId = '1'
      ..accountId = '1'
      ..createdAt = fixtureNow
      ..updatedAt = fixtureNow;
    await isar.writeTxn(() => isar.transactions.put(t));
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(await runAh(isar, params, ahCountJob), inline + 1);

    AhWorker.shutdown();
    expect(await runAh(isar, params, ahCountJob), inline + 1);
  });

  test('timings: one-shot isolate vs worker', () async {
    final node = parseItems(tokenize('date:thisyear')).node;
    final out = <String>[];
    Future<void> cmp<P, R>(String label, P p, Future<R> Function(Isar, P) fn) async {
      final a = await ms(() => oneShot(isar, p, fn));
      final a2 = await ms(() => oneShot(isar, p, fn));
      final b0 = await ms(() => runAh(isar, p, fn));
      final b = await ms(() => runAh(isar, p, fn));
      final b2 = await ms(() => runAh(isar, p, fn));
      out.add('$label: one-shot $a/$a2 ms, worker cold $b0 warm $b/$b2 ms');
    }

    await cmp('live count', AhCountParams(node, fixtureNow), ahCountJob);
    await cmp('chart preview',
        AhChartParams(node, const AhChartSpec(AhChartType.donut, AhChartSplit.category, AhChartMeasure.total), fixtureNow),
        ahChartJob);
    await cmp('field values', QueryField.category, ahFieldValuesJob);
    await cmp('first query',
        AhBundleParams(node, AhGroupBy.none, AhSort.ungroupedDefault, const [], fixtureNow),
        ahBundleJob);
    final ids = (await ahOrderJob(isar,
            AhBundleParams(node, AhGroupBy.none, AhSort.ungroupedDefault, const [], fixtureNow)))
        .ids;
    final sw = Stopwatch()..start();
    await isar.transactions.getAll(ids.sublist(50, 100));
    out.add('load more: before = one-shot full query (see first query), after '
        '${sw.elapsedMicroseconds / 1000} ms by id');
    // ignore: avoid_print
    print(out.join('\n'));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
