import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/advanced_history/data/saved_filter.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/isar_test_helper.dart';

const donut = AhChartSpec(AhChartType.donut, AhChartSplit.category, AhChartMeasure.total);
const bars = AhChartSpec(AhChartType.bars, AhChartSplit.account, AhChartMeasure.count);
const line = AhChartSpec(AhChartType.line, AhChartSplit.month, AhChartMeasure.average);

void main() {
  late Isar isar;
  late ProviderContainer c;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    isar = await openTestIsar();
    c = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
  });
  tearDown(() async {
    c.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await closeAndCleanIsar(isar);
  });
  AhViewNotifier n() => c.read(ahViewProvider.notifier);
  AhView v() => c.read(ahViewProvider);
  SavedFilterRepository repo() => c.read(savedFilterRepositoryProvider);

  test('setFilter keeps the last valid node', () {
    expect(v().isStart, isTrue);
    expect(n().setFilter('type:expense  amount:>500'), isTrue);
    expect(v().queryText, 'type:expense and amount:>500');
    final node = v().node;
    expect(n().setFilter('type:expense and (amount:>5'), isFalse);
    expect(v().node, same(node));
    expect(v().queryText, 'type:expense and amount:>500');
    n().setFilter('');
    expect(v().node, isNull);
  });

  test('group / sort / charts mutators', () {
    n().setGroup(AhGroupBy.category);
    expect(v().sort, AhSort.groupedDefault);
    n().setSort(const AhSort(AhSortField.count, descending: false));
    n().setGroup(AhGroupBy.tag);
    expect(v().sort.field, AhSortField.count); // grouped to grouped keeps it
    n().setGroup(AhGroupBy.none);
    expect(v().sort, AhSort.ungroupedDefault);

    n().addChart(donut);
    n().addChart(bars);
    n().addChart(line);
    n().moveChart(0, 2);
    expect(v().charts, [bars, line, donut]);
    n().updateChart(1, donut.copyWith(measure: AhChartMeasure.count));
    final removed = n().removeChart(0);
    expect(removed, bars);
    n().insertChart(0, removed);
    expect(v().charts.first, bars);
    n().addChart(donut);
    n().addChart(donut);
    expect(v().charts.length, kAhMaxCharts);
    n().addChart(donut);
    expect(v().charts.length, kAhMaxCharts);
  });

  test('clearAll keeps KPI choice; KPI pref is global outside a saved view', () async {
    n().setKpis([AhKpi.net, AhKpi.income]);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    n().setFilter('swiggy');
    n().addChart(donut);
    n().clearAll();
    expect(v().hasAnything, isFalse);
    expect(v().kpis, [AhKpi.net, AhKpi.income]);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(kAhKpiPrefKey), ['net', 'income']);
    n().setKpis([]);
    expect(v().kpis, kAhDefaultKpis);
  });

  test('KPI pref loads lazily', () async {
    SharedPreferences.setMockInitialValues({
      kAhKpiPrefKey: ['largest', 'bogus', 'net']
    });
    final c2 = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
    c2.read(ahViewProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c2.read(ahViewProvider).kpis, [AhKpi.largest, AhKpi.net]);
    c2.dispose();
  });

  test('saved view CRUD, names, round trip with chart order', () async {
    n().setFilter('category:food,travel and not tag:x');
    n().setGroup(AhGroupBy.month);
    n().setSort(const AhSort(AhSortField.name, descending: false));
    n().addChart(donut);
    n().addChart(line);
    n().addChart(bars);
    n().setKpis([AhKpi.expense, AhKpi.transactions]);
    final f = await repo().saveNew('  Trips  ', v());
    expect(f.name, 'Trips');
    expect(f.charts.map((e) => e.order), [0, 1, 2]);
    n().markSaved(f.id);

    expect(await repo().nameTaken('trips'), isTrue);
    expect(await repo().nameTaken('TRIPS', exceptId: f.id), isFalse);
    for (final bad in ['', 'x' * 41, 'TRIPS']) {
      await expectLater(repo().saveNew(bad, v()),
          throwsA(isA<SavedFilterNameException>()), reason: bad);
    }

    final want = v();
    n().clearAll();
    expect(v().savedId, isNull);
    final stored = (await isar.savedFilters.where().findAll()).single;
    n().applySaved(stored);
    final got = v();
    expect(got.queryText, want.queryText);
    expect(got.node!.toJson(), want.node!.toJson());
    expect(got.groupBy, want.groupBy);
    expect(got.sort, want.sort);
    expect(got.charts, [donut, line, bars]);
    expect(got.kpis, [AhKpi.expense, AhKpi.transactions]);
    expect(got.savedId, f.id);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await isar.savedFilters.get(f.id))!.lastUsedAt, isNotNull);

    await repo().rename(f.id, 'Trips 2026');
    expect((await isar.savedFilters.get(f.id))!.name, 'Trips 2026');
    await repo().delete(f.id);
    expect(v().savedId, isNull);
    expect(await isar.savedFilters.count(), 0);
  });

  test('change detection', () async {
    n().setFilter('swiggy');
    n().addChart(donut);
    n().addChart(bars);
    final f = await repo().saveNew('A', v());
    n().markSaved(f.id);
    c.listen(savedFiltersProvider, (_, __) {});
    await c.read(savedFiltersProvider.future);
    List<AhChange> ch() => c.read(ahChangesProvider);
    expect(ch(), isEmpty);

    n().setFilter('uber');
    expect(ch(), [AhChange.filter]);
    n().setFilter('swiggy');
    expect(ch(), isEmpty);
    n().setGroup(AhGroupBy.tag);
    n().setSort(const AhSort(AhSortField.count));
    expect(ch(), [AhChange.group, AhChange.sort]);
    n().setGroup(AhGroupBy.none);
    expect(ch(), isEmpty);
    n().setKpis([AhKpi.net]);
    expect(ch(), [AhChange.kpis]);
    n().setKpis(kAhDefaultKpis);
    n().moveChart(0, 1);
    expect(ch(), [AhChange.chartMoved]);
    n().moveChart(0, 1);
    n().addChart(line);
    expect(ch(), [AhChange.chartAdded]);
    n().removeChart(2);
    n().removeChart(1);
    expect(ch(), [AhChange.chartRemoved]);
    n().insertChart(1, bars);
    n().updateChart(0, donut.copyWith(split: AhChartSplit.tag));
    expect(ch(), [AhChange.chartEdited]);

    await repo().saveChanges(f.id, v());
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(ch(), isEmpty);
  });
}
