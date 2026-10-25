// Analytics, category and balance totals for a seeded existing-user ledger,
// recorded from the pre-vNext app (base 6ce4f0e) with
//   KUBER_RECORD_FIXTURES=1 flutter test test/features/analytics/analytics_totals_golden_test.dart
// The same totals must come out after every migration has run.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/migrations.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/analytics/providers/analytics_provider.dart';
import 'package:kuber/features/transactions/providers/stats_provider.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/legacy_dataset.dart';

const _file = 'test/fixtures/analytics/totals.json';
final _record = Platform.environment['KUBER_RECORD_FIXTURES'] == '1';

String _d(num v) => v.toDouble().toStringAsFixed(6);

Future<Map<String, Object>> _totals(Isar isar) async {
  final c = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
  await c.read(transactionListProvider.future);
  final out = <String, Object>{};
  Future<void> range(String key, DateTime from, DateTime to) async {
    c.read(analyticsFilterProvider.notifier)
        .setFilter(FilterType.custom, from: from, to: to);
    final a = c.read(analyticsComputedProvider);
    final cats = await c.read(analyticsCategoryStatsProvider.future);
    final groups = await c.read(analyticsGroupStatsProvider.future);
    out[key] = {
      'income': _d(a?.totalIncome ?? 0),
      'expense': _d(a?.totalExpense ?? 0),
      'net': _d(a?.netAmount ?? 0),
      'size': a?.sizeDistribution ?? const {},
      'weekday': {for (final e in (a?.dailyAverages ?? const {}).entries) e.key: _d(e.value)},
      'categories': {for (final s in cats) s.category.name: _d(s.total)},
      'groups': {for (final s in groups) s.groupName: _d(s.total)},
    };
  }
  await range('all', DateTime(2022, 1, 1), DateTime(2026, 12, 31));
  for (var m = 1; m <= 12; m++) {
    await range('2025-$m', DateTime(2025, m, 1), DateTime(2025, m + 1, 0));
  }
  final balances = await c.read(accountBalancesProvider.future);
  out['balances'] = {for (final e in balances.entries) '${e.key}': _d(e.value)};
  await Future<void>.delayed(Duration.zero);
  c.dispose();
  return out;
}

void main() {
  setUpAll(initialiseIsarForTests);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('analytics totals for the existing dataset are unchanged by migrations',
      () async {
    final isar = await openTestIsar();
    addTearDown(() => closeAndCleanIsar(isar));
    await seedLegacyDataset(isar);
    final before = await _totals(isar);
    final file = File(_file);
    if (_record) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(before));
    }
    final expected = jsonDecode(file.readAsStringSync());
    expect(jsonEncode(before), jsonEncode(expected), reason: 'before migration');

    await MigrationService.runAll(isar);
    await MigrationService.runAll(isar); // idempotent
    // Fresh prefs: the analytics filter persists its last range, and its
    // async reload would race the next container's setFilter.
    SharedPreferences.setMockInitialValues({});
    final after = await _totals(isar);
    expect(jsonEncode(after), jsonEncode(expected), reason: 'after migration');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
