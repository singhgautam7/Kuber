import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/tools/saved/providers/saved_calculations_provider.dart';
import 'package:kuber/features/tools/saved/providers/recent_use_provider.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    container = ProviderContainer(
      overrides: [isarProvider.overrideWithValue(isar)],
    );
  });

  tearDown(() async {
    container.dispose();
    await closeAndCleanIsar(isar);
  });

  group('SavedCalculationsNotifier', () {
    test('create persists and lists newest-first', () async {
      final notifier = container.read(savedCalculationsProvider.notifier);
      final id1 = await notifier.create(
        tool: 'emi-calculator',
        name: 'Home loan',
        inputsJson: '{"principal":"2500000"}',
        summary: '₹25L @ 8.5%',
      );
      await Future.delayed(const Duration(milliseconds: 5));
      await notifier.create(
        tool: 'goal-planner',
        name: 'College fund',
        inputsJson: '{"target":"4000000"}',
        summary: '₹40L in 12y',
      );

      final list = await container.read(savedCalculationsProvider.future);
      expect(list.length, 2);
      expect(list.first.name, 'College fund'); // newest first
      expect(await notifier.getById(id1), isNotNull);
    });

    test('updateRecord overwrites inputs and summary', () async {
      final notifier = container.read(savedCalculationsProvider.notifier);
      final id = await notifier.create(
        tool: 'emi-calculator',
        name: 'Home loan',
        inputsJson: '{"principal":"2500000"}',
        summary: 'old',
      );
      await notifier.updateRecord(id,
          inputsJson: '{"principal":"3000000"}', summary: 'new');

      final rec = await notifier.getById(id);
      expect(rec!.summary, 'new');
      expect(rec.inputsJson, contains('3000000'));
    });

    test('deleteMany removes records', () async {
      final notifier = container.read(savedCalculationsProvider.notifier);
      final id1 = await notifier.create(
          tool: 'emi-calculator', name: 'A', inputsJson: '{}', summary: '');
      final id2 = await notifier.create(
          tool: 'ppf-calculator', name: 'B', inputsJson: '{}', summary: '');
      await notifier.deleteMany([id1, id2]);
      final list = await container.read(savedCalculationsProvider.future);
      expect(list, isEmpty);
    });

    test('savedToolsProvider returns distinct tools', () async {
      final notifier = container.read(savedCalculationsProvider.notifier);
      await notifier.create(
          tool: 'emi-calculator', name: 'A', inputsJson: '{}', summary: '');
      await notifier.create(
          tool: 'emi-calculator', name: 'B', inputsJson: '{}', summary: '');
      await notifier.create(
          tool: 'goal-planner', name: 'C', inputsJson: '{}', summary: '');
      await container.read(savedCalculationsProvider.future);
      final tools = container.read(savedToolsProvider);
      expect(tools.toSet(), {'emi-calculator', 'goal-planner'});
    });
  });

  group('RecentUseNotifier', () {
    test('touch upserts and increments use count', () async {
      final notifier = container.read(recentCalculatorsProvider.notifier);
      await notifier.touch('emi-calculator');
      await notifier.touch('emi-calculator');
      await notifier.touch('goal-planner');

      final list = await container.read(recentCalculatorsProvider.future);
      expect(list.length, 2); // emi upserted, not duplicated
      final emi =
          list.firstWhere((e) => e.calculatorType == 'emi-calculator');
      expect(emi.useCount, 2);
    });

    test('topRecentCalculatorsProvider returns most-recent-first keys', () async {
      final notifier = container.read(recentCalculatorsProvider.notifier);
      await notifier.touch('emi-calculator');
      await Future.delayed(const Duration(milliseconds: 5));
      await notifier.touch('goal-planner');
      await container.read(recentCalculatorsProvider.future);

      final top = container.read(topRecentCalculatorsProvider);
      expect(top.first, 'goal-planner');
      expect(top.length, 2);
    });
  });
}
