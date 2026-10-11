import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/budgets/data/budget.dart';
import 'package:kuber/features/home_v2/data/home_v2_state.dart';
import 'package:kuber/features/home_v2/data/home_v2_widgets.dart';
import 'package:kuber/features/home_v2/providers/get_started_provider.dart';
import 'package:kuber/features/home_v2/providers/home_v2_gates_provider.dart';
import 'package:kuber/features/home_v2/services/home_v2_gates.dart';
import 'package:kuber/features/stories/data/insight_story.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/widget_editor/data/widget_catalog.dart';
import 'package:kuber/features/widget_editor/data/widget_preference.dart';
import 'package:kuber/features/widget_editor/models/home_widget_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

Transaction txn({
  String type = 'expense',
  String? source,
  bool adjustment = false,
  DateTime? at,
}) {
  final d = at ?? DateTime.now();
  return Transaction()
    ..name = 'x'
    ..nameLower = 'x'
    ..amount = 100
    ..type = type
    ..categoryId = ''
    ..accountId = '1'
    ..importSource = source
    ..isBalanceAdjustment = adjustment
    ..createdAt = d
    ..updatedAt = d;
}

void main() {
  late Isar isar;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async {
    isar = await openTestIsar();
    SharedPreferences.setMockInitialValues({});
  });
  tearDown(() async => closeAndCleanIsar(isar));

  group('cohort', () {
    test(
      'fresh install (not onboarded, no rows, no data) is v2, seeded',
      () async {
        await isar.writeTxn(
          () => isar.accounts.putAll([
            Account()
              ..name = 'Cash'
              ..type = 'cash',
            Account()
              ..name = 'Bank'
              ..type = 'bank',
          ]),
        );
        final s = await resolveHomeCohort(isar, onboarded: false);
        expect(s.cohort, HomeCohort.v2);
        expect(s.seededAccountIds, hasLength(2));
        final rows = await isar.widgetPreferences
            .filter()
            .scopeEqualTo('home')
            .sortByOrder()
            .findAll();
        expect(
          {for (final r in rows.where((r) => r.enabled)) r.widgetKey},
          {'balance_hero', 'quick_add', 'recent_transactions'},
        );
        expect(s.widgets['spending_stats']!.vis, WidgetVis.auto);
        expect(s.widgets['ask_kuber_widget']!.vis, WidgetVis.off);
      },
    );

    test(
      'update: onboarded, saved layout or data means v1, untouched',
      () async {
        expect(
          (await resolveHomeCohort(isar, onboarded: true)).cohort,
          HomeCohort.v1,
        );
        expect(await isar.widgetPreferences.count(), 0);

        SharedPreferences.setMockInitialValues({});
        await isar.writeTxn(() => isar.transactions.put(txn()));
        expect(
          (await resolveHomeCohort(isar, onboarded: false)).cohort,
          HomeCohort.v1,
        );
      },
    );

    test('decided once: later launches keep the stored cohort', () async {
      SharedPreferences.setMockInitialValues({PrefsKeys.homeLayout: 'v1'});
      // Even a "fresh-looking" state stays v1 once decided.
      expect(
        (await resolveHomeCohort(isar, onboarded: false)).cohort,
        HomeCohort.v1,
      );
    });

    test('snapshot round trip through prefs', () async {
      final store = await HomeV2Store.open();
      final s = HomeV2Snapshot(
        cohort: HomeCohort.v2,
        installedAt: DateTime(2026, 10, 1),
        seededAccountIds: const {1, 2},
        widgets: homeV2InitialWidgetStates(),
        gsGraduatedAt: DateTime(2026, 10, 9),
        gsGraduationReason: GsGraduation.completed,
        balanceSet: true,
      );
      await store.write(s);
      final back = store.read();
      expect(back.cohort, HomeCohort.v2);
      expect(back.seededAccountIds, {1, 2});
      expect(back.gsGraduationReason, GsGraduation.completed);
      expect(back.balanceSet, isTrue);
      expect(back.widgets['home_accounts']!.vis, WidgetVis.auto);
    });
  });

  group('unlock insert position', () {
    List<HomeWidgetConfig> configs(Set<String> on) => [
      for (final c in kHomeWidgetCatalog)
        c.copyWith(enabled: on.contains(c.id)),
    ];

    test('after the nearest earlier catalog neighbour on Home', () {
      final out = insertUnlocked(
        configs({'balance_hero', 'quick_add', 'recent_transactions'}),
        {'spending_stats'},
      );
      final on = [
        for (final c in out)
          if (c.enabled) c.id,
      ];
      expect(on, [
        'balance_hero',
        'spending_stats',
        'quick_add',
        'recent_transactions',
      ]);
    });

    test('respects a user reorder; first when no earlier neighbour is on', () {
      // User moved Recent Transactions to the top.
      final base = configs({
        'balance_hero',
        'quick_add',
        'recent_transactions',
      });
      final reordered = [
        base.firstWhere((c) => c.id == 'recent_transactions'),
        ...base.where((c) => c.id != 'recent_transactions'),
      ];
      final out = insertUnlocked(reordered, {'kuber_notes_widget'});
      final on = [
        for (final c in out)
          if (c.enabled) c.id,
      ];
      // Nearest earlier catalog neighbour that is on: quick_add.
      expect(on, [
        'recent_transactions',
        'balance_hero',
        'quick_add',
        'kuber_notes_widget',
      ]);

      final none = insertUnlocked(configs({'recent_transactions'}), {
        'insight_stories',
      });
      expect(
        [
          for (final c in none)
            if (c.enabled) c.id,
        ].first,
        'insight_stories',
      );
    });
  });

  group('Get started', () {
    test('steps from transactions', () {
      expect(gsStepsFrom([txn(source: 'sms')]).sms, isTrue);
      expect(gsStepsFrom([txn(source: 'quick_add')]).manual, isTrue);
      expect(gsStepsFrom([txn()]).manual, isTrue);
      expect(gsStepsFrom([txn(adjustment: true)]).adjusted, isTrue);
      final linked = txn()..linkedRuleType = 'loan';
      expect(gsStepsFrom([linked]).manual, isFalse);
    });

    GsData data({
      bool s1 = false,
      bool s2 = false,
      bool s3 = false,
      int n = 0,
    }) => GsData(
      step1: s1,
      step2: s2,
      step3: s3,
      txCount: n,
      state: GsState.fresh,
    );

    test('graduation: completed, 10 transactions, 14-day timeout', () {
      final now = DateTime(2026, 10, 20);
      expect(
        gsGraduationFor(
          data(s1: true, s2: true, s3: true, n: 2),
          firstShownAt: now,
          now: now,
        ),
        GsGraduation.completed,
      );
      expect(
        gsGraduationFor(data(n: 10), firstShownAt: now, now: now),
        GsGraduation.transactions,
      );
      final firstShown = now.subtract(const Duration(days: 14));
      expect(
        gsGraduationFor(data(n: 1), firstShownAt: firstShown, now: now),
        GsGraduation.timeout,
      );
      // Timeout needs at least one transaction.
      expect(
        gsGraduationFor(data(), firstShownAt: firstShown, now: now),
        isNull,
      );
      expect(gsGraduationFor(data(n: 9), firstShownAt: now, now: now), isNull);
    });
  });

  group('gates', () {
    Future<Set<String>> eval(
      Set<String> pending, {
      Set<int> seeded = const {},
    }) => HomeV2Gates.evaluate(
      isar,
      pending,
      seededAccountIds: seeded,
      smsPermission: () async => false,
    );

    test('spending stats: expenses on 7 distinct days in 30', () async {
      final now = DateTime.now();
      await isar.writeTxn(
        () => isar.transactions.putAll([
          for (var d = 0; d < 6; d++) txn(at: now.subtract(Duration(days: d))),
        ]),
      );
      expect(await eval({'spending_stats'}), isEmpty);
      await isar.writeTxn(
        () => isar.transactions.put(
          txn(at: now.subtract(const Duration(days: 8))),
        ),
      );
      expect(await eval({'spending_stats'}), {'spending_stats'});
    });

    test('chart: 3 distinct days; budget: an active budget', () async {
      final now = DateTime.now();
      await isar.writeTxn(
        () => isar.transactions.putAll([
          txn(at: now),
          txn(at: now.subtract(const Duration(days: 1))),
        ]),
      );
      expect(await eval({'seven_day_chart'}), isEmpty);
      await isar.writeTxn(
        () => isar.transactions.put(
          txn(type: 'income', at: now.subtract(const Duration(days: 40))),
        ),
      );
      expect(await eval({'seven_day_chart'}), {'seven_day_chart'});

      expect(await eval({'budget_snapshot'}), isEmpty);
      await isar.writeTxn(
        () => isar.budgets.put(
          Budget()
            ..categoryId = '1'
            ..amount = 1000
            ..periodType = BudgetPeriodType.values.first
            ..isRecurring = true
            ..startDate = now
            ..createdAt = now
            ..updatedAt = now,
        ),
      );
      expect(await eval({'budget_snapshot'}), {'budget_snapshot'});
    });

    test('stories: the seeded Welcome story does not count', () async {
      InsightStory story(String key, String type) => InsightStory()
        ..storyKey = key
        ..type = type
        ..generatedAt = DateTime.now()
        ..expiresAt = DateTime.now().add(const Duration(days: 2))
        ..payloadJson = '{}';
      await isar.writeTxn(() => isar.insightStorys.put(story('w', 'welcome')));
      expect(await eval({'insight_stories'}), isEmpty);
      await isar.writeTxn(() => isar.insightStorys.put(story('d', 'daily')));
      expect(await eval({'insight_stories'}), {'insight_stories'});
    });

    test('bank accounts ignore seeded accounts until data exists', () async {
      final ids = await isar.writeTxn(
        () => isar.accounts.putAll([
          Account()
            ..name = 'Cash'
            ..type = 'cash',
        ]),
      );
      expect(await eval({'home_accounts'}, seeded: ids.toSet()), isEmpty);
      await isar.writeTxn(
        () => isar.accounts.put(
          Account()
            ..name = 'HDFC'
            ..type = 'bank',
        ),
      );
      expect(await eval({'home_accounts'}, seeded: ids.toSet()), {
        'home_accounts',
      });
    });
  });
}
