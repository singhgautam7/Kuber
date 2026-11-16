import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/currency_data.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/advanced_history/data/saved_filter.dart';
import 'package:kuber/features/advanced_history/models/ah_view.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/services/ah_results.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SeedView extends AhViewNotifier {
  SeedView(this.seed);
  final AhView seed;
  @override
  AhView build() => seed;
}

class ProState extends KuberProStateNotifier {
  ProState(this.value);
  final KuberProState value;
  @override
  KuberProState build() => value;
}

class EmptyPages extends AhTxnPagesNotifier {
  @override
  Future<AhTxnPage> build(AhGroupKey? arg) async =>
      const AhTxnPage([], hasMore: false, total: 0);
  @override
  Future<void> loadMore() async {}
}

class FakeRepo implements SavedFilterRepository {
  FakeRepo({this.taken = const {}});
  final Set<String> taken;
  final saved = <String>[];
  @override
  Future<bool> nameTaken(String name, {int? exceptId}) async =>
      taken.contains(name.trim().toLowerCase());
  @override
  Future<SavedFilter> saveNew(String name, AhView view) async {
    saved.add(name);
    final now = DateTime(2026);
    return SavedFilter()
      ..id = 9
      ..name = name
      ..queryText = ''
      ..createdAt = now
      ..updatedAt = now;
  }

  @override
  Future<void> saveChanges(int id, AhView view) async {}
  @override
  Future<void> rename(int id, String name) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<void> markUsed(int id) async {}
}

const kTestKpis = AhKpis(
    transactions: 12,
    income: 5000,
    expense: 2000,
    average: 583,
    attachments: 1,
    largest: 3000);

AhChartData chartOf(AhChartState s) => AhChartData(s,
    count: 12,
    points: s == AhChartState.ok
        ? const [
            AhChartPoint('1', 'Food', 300),
            AhChartPoint('2', 'Travel', 200),
          ]
        : const []);

SavedFilter savedView(int id, String name, {AhGroupBy group = AhGroupBy.none}) {
  final now = DateTime(2026);
  return SavedFilter()
    ..id = id
    ..name = name
    ..queryText = ''
    ..groupBy = group
    ..createdAt = now
    ..updatedAt = now;
}

final proOn = KuberProState.purchased(
    plan: ProPlan.lifetime, activatedAt: DateTime(2026, 8, 12));

/// Overrides that stand in for H-data: fixed results, no Isar.
List<Override> ahOverrides({
  required AhView view,
  KuberProState? pro,
  AhChartState chart = AhChartState.ok,
  AhKpis? kpis = kTestKpis,
  FakeRepo? repo,
  List<SavedFilter> saved = const [],
  Map<AhChartSplit, AhSplitBlock> blocks = const {},
  AhGroups? groups,
}) =>
    [
      kuberProStateProvider.overrideWith(() => ProState(pro ?? proOn)),
      ahViewProvider.overrideWith(() => SeedView(view)),
      formatterProvider.overrideWithValue(
          AppFormatter(currency: currencyFromCode('INR'))),
      savedFilterRepositoryProvider.overrideWithValue(repo ?? FakeRepo()),
      savedFiltersProvider.overrideWith((ref) => Stream.value(saved)),
      ahKpisProvider.overrideWith((ref) async => kpis),
      ahGroupsProvider.overrideWith((ref) async => groups ?? const AhGroups([])),
      ahTxnPagesProvider.overrideWith(EmptyPages.new),
      ahChartDataProvider.overrideWith((ref, spec) async => chartOf(chart)),
      ahSplitBlocksProvider.overrideWith((ref) async => blocks),
    ];

Future<ProviderContainer> pumpAh(
  WidgetTester t,
  Widget home,
  List<Override> overrides, {
  bool reduced = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 2.5;
  addTearDown(t.view.reset);
  final c = ProviderContainer(overrides: overrides);
  addTearDown(c.dispose);
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      theme: AppTheme.light(const Locale('en')),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
      home: home,
    ),
  ));
  await settleAh(t);
  return c;
}

Future<void> settleAh(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 250));
  }
}
