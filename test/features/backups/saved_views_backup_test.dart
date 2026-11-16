import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/advanced_history/data/saved_filter.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  final service = JsonBackupService();

  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));

  SavedChart chart(int o, AhChartType t, AhChartSplit s, AhChartMeasure m) =>
      SavedChart()
        ..order = o
        ..type = t
        ..split = s
        ..measure = m;

  test('two saved views round trip exactly', () async {
    final t = DateTime(2026, 3, 4, 5, 6, 7);
    await isar.writeTxn(() async {
      await isar.savedFilters.put(SavedFilter()
        ..name = 'Food trips'
        ..queryText = 'type:expense (category:food OR category:travel)'
        ..astJson = '{"a":1}'
        ..groupBy = AhGroupBy.month
        ..sortField = AhSortField.total
        ..sortDescending = false
        ..charts = [
          chart(0, AhChartType.line, AhChartSplit.month, AhChartMeasure.average),
          chart(1, AhChartType.bars, AhChartSplit.tag, AhChartMeasure.count),
          chart(2, AhChartType.donut, AhChartSplit.account, AhChartMeasure.total),
        ]
        ..kpiSelection = ['largest', 'net', 'transactions']
        ..createdAt = t
        ..updatedAt = t.add(const Duration(days: 1))
        ..lastUsedAt = t.add(const Duration(days: 2)));
      await isar.savedFilters.put(SavedFilter()
        ..name = 'Plain'
        ..queryText = 'swiggy'
        ..createdAt = t
        ..updatedAt = t);
    });

    final json = await service.exportJson(isar);
    expect(jsonDecode(json)['version'], 5);
    final isar2 = await openTestIsar();
    addTearDown(() => closeAndCleanIsar(isar2));
    final r = await service.importJson(isar2, json);
    expect(r.error, isNull);

    final a = await isar.savedFilters.where().findAll();
    final b = await isar2.savedFilters.where().findAll();
    expect(b.length, 2);
    for (final x in a) {
      final y = b.firstWhere((f) => f.name == x.name);
      expect(y.id, x.id);
      expect(y.queryText, x.queryText);
      expect(y.astJson, x.astJson);
      expect(y.groupBy, x.groupBy);
      expect(y.sortField, x.sortField);
      expect(y.sortDescending, x.sortDescending);
      expect(y.kpiSelection, x.kpiSelection);
      expect(y.createdAt, x.createdAt);
      expect(y.updatedAt, x.updatedAt);
      expect(y.lastUsedAt, x.lastUsedAt);
      expect(y.charts.length, x.charts.length);
      for (var i = 0; i < x.charts.length; i++) {
        expect(y.charts[i].order, x.charts[i].order);
        expect(y.charts[i].type, x.charts[i].type);
        expect(y.charts[i].split, x.charts[i].split);
        expect(y.charts[i].measure, x.charts[i].measure);
      }
    }
  });

  test('a v4 backup without savedFilters restores fine', () async {
    final r = await service.importJson(isar, jsonEncode({'version': 4}));
    expect(r.error, isNull);
    expect(await isar.savedFilters.count(), 0);
  });

  test('unknown enum names fall back to defaults', () async {
    final row = {
      'id': 1,
      'name': 'X',
      'queryText': 'a',
      'groupBy': 'galaxy',
      'sortField': 'nope',
      'charts': [
        {'order': 0, 'type': 'pie3d', 'split': '?', 'measure': '?'},
      ],
      'createdAt': '2026-01-01T00:00:00.000',
      'updatedAt': '2026-01-01T00:00:00.000',
    };
    final r = await service.importJson(
        isar, jsonEncode({'version': 5, 'savedFilters': [row]}));
    expect(r.error, isNull);
    final f = (await isar.savedFilters.where().findAll()).single;
    expect(f.groupBy, AhGroupBy.none);
    expect(f.sortField, AhSortField.date);
    expect(f.charts.single.type, AhChartType.donut);
    expect(f.charts.single.split, AhChartSplit.category);
    expect(f.charts.single.measure, AhChartMeasure.total);
  });
}
