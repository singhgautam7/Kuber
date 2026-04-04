import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/recurring/data/recurring_processor.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late RecurringProcessor processor;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    processor = RecurringProcessor(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  Future<void> insertRule(RecurringRule rule) async {
    rule.createdAt = DateTime.now();
    rule.updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.recurringRules.put(rule));
  }

  test('returns 0 when no due rules', () async {
    await insertRule(makeRecurringRule(
      nextDueAt: DateTime.now().add(const Duration(days: 7)),
    ));
    final count = await processor.processAll();
    expect(count, 0);
  });

  test('creates transaction for overdue rule', () async {
    await insertRule(makeRecurringRule(
      name: 'Netflix',
      amount: 199,
      type: 'expense',
      frequency: 'monthly',
      nextDueAt: DateTime.now().subtract(const Duration(hours: 1)),
    ));

    final count = await processor.processAll();
    expect(count, 1);

    final txns = await isar.transactions.where().findAll();
    expect(txns.length, 1);
    expect(txns.first.name, 'Netflix');
    expect(txns.first.amount, 199);
    expect(txns.first.type, 'expense');
  });

  test('creates multiple transactions for multi-day overdue', () async {
    await insertRule(makeRecurringRule(
      name: 'Daily expense',
      frequency: 'daily',
      nextDueAt: DateTime.now().subtract(const Duration(days: 3)),
    ));

    final count = await processor.processAll();
    // 3 days ago, 2 days ago, 1 day ago, today = 4 due dates before now
    expect(count, greaterThanOrEqualTo(3));

    final txns = await isar.transactions.where().findAll();
    expect(txns.length, count);
  });

  test('stops at occurrence limit', () async {
    await insertRule(makeRecurringRule(
      name: 'Limited',
      frequency: 'daily',
      endType: 'occurrences',
      endAfter: 2,
      executionCount: 0,
      nextDueAt: DateTime.now().subtract(const Duration(days: 5)),
    ));

    final count = await processor.processAll();
    expect(count, 2);
  });

  test('skips expired rules', () async {
    await insertRule(makeRecurringRule(
      name: 'Expired',
      frequency: 'daily',
      endType: 'occurrences',
      endAfter: 3,
      executionCount: 3, // already at limit
      nextDueAt: DateTime.now().subtract(const Duration(days: 1)),
    ));

    final count = await processor.processAll();
    expect(count, 0);
  });

  test('skips paused rules (via getDue filter)', () async {
    await insertRule(makeRecurringRule(
      name: 'Paused',
      isPaused: true,
      nextDueAt: DateTime.now().subtract(const Duration(days: 1)),
    ));

    final count = await processor.processAll();
    expect(count, 0);
  });

  test('created transactions have correct fields', () async {
    await insertRule(makeRecurringRule(
      name: 'Rent',
      amount: 15000,
      type: 'expense',
      categoryId: '5',
      accountId: '2',
      notes: 'Monthly rent',
      frequency: 'monthly',
      nextDueAt: DateTime.now().subtract(const Duration(hours: 1)),
    ));

    await processor.processAll();
    final txns = await isar.transactions.where().findAll();
    final t = txns.first;

    expect(t.name, 'Rent');
    expect(t.nameLower, 'rent');
    expect(t.amount, 15000);
    expect(t.type, 'expense');
    expect(t.categoryId, '5');
    expect(t.accountId, '2');
    expect(t.notes, 'Monthly rent');
    expect(t.linkedRuleType, 'recurring');
    expect(t.linkedRuleId, isNotNull);
  });

  test('updates rule nextDueAt and executionCount after processing', () async {
    final rule = makeRecurringRule(
      name: 'Weekly',
      frequency: 'weekly',
      nextDueAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    await insertRule(rule);

    await processor.processAll();

    final rules = await isar.recurringRules.where().findAll();
    final updated = rules.first;
    expect(updated.executionCount, 1);
    expect(updated.nextDueAt.isAfter(DateTime.now().subtract(const Duration(days: 1))), true);
  });
}
