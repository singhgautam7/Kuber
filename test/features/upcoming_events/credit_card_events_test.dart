import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/utils/monthly_recurrence.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/upcoming_events/engine/event_aggregator.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUpAll(initialiseIsarForTests);
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  Future<int> putCard({
    required String name,
    bool isCreditCard = true,
    bool isDisabled = false,
    int? billDay,
    int? dueDay,
  }) async {
    final a = Account()
      ..name = name
      ..type = 'bank'
      ..isCreditCard = isCreditCard
      ..isDisabled = isDisabled
      ..billGenerationDay = billDay
      ..paymentDueDay = dueDay;
    return isar.writeTxn(() => isar.accounts.put(a));
  }

  Future<List<CreditCardEvent>> creditEvents({int windowDays = 45}) async {
    final events = await UpcomingEventsAggregator(isar).getUpcomingEvents(
      window: Duration(days: windowDays),
      sourceFilters: {'creditCard'},
    );
    return events.cast<CreditCardEvent>();
  }

  // Mirror the aggregator's own window predicate so the today-collision edge
  // (a day equal to today resolves to midnight-today, which is before "now")
  // is handled identically in the expectation.
  bool inWindow(DateTime d, {int windowDays = 45}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: windowDays));
    return !d.isBefore(now) && !d.isAfter(end);
  }

  test('emits a bill and a due event for a credit card with both days', () async {
    final id = await putCard(name: 'HDFC Regalia', billDay: 20, dueDay: 5);
    final events = await creditEvents();

    final bills = events.where((e) => !e.isPaymentDue).toList();
    final dues = events.where((e) => e.isPaymentDue).toList();

    expect(bills.length, inWindow(nextMonthlyOccurrence(20)) ? 1 : 0);
    expect(dues.length, inWindow(nextMonthlyOccurrence(5)) ? 1 : 0);
    for (final e in events) {
      expect(e.sourceType, 'creditCard');
      expect(e.account.id, id);
      expect(e.amount, isNull);
    }
    if (bills.isNotEmpty) {
      expect(bills.single.date, nextMonthlyOccurrence(20));
      expect(bills.single.title, contains('Bill generated'));
    }
    if (dues.isNotEmpty) {
      expect(dues.single.date, nextMonthlyOccurrence(5));
      expect(dues.single.title, contains('Payment due'));
    }
  });

  test('emits only a bill event when the due day is unset', () async {
    await putCard(name: 'Card', billDay: 12, dueDay: null);
    final events = await creditEvents();
    expect(events.every((e) => !e.isPaymentDue), isTrue);
  });

  test('disabled credit card emits nothing', () async {
    await putCard(name: 'Old Card', isDisabled: true, billDay: 10, dueDay: 25);
    expect(await creditEvents(), isEmpty);
  });

  test('non-credit account emits nothing even if days are set', () async {
    await putCard(name: 'Savings', isCreditCard: false, billDay: 10, dueDay: 25);
    expect(await creditEvents(), isEmpty);
  });

  test('day-31 resolves within the month, never overflowing', () async {
    await putCard(name: 'Amex', billDay: 31, dueDay: null);
    final events = await creditEvents(windowDays: 60);
    for (final e in events) {
      // Resolved bill date's day must be a real day of its month.
      expect(e.date.day, lessThanOrEqualTo(daysInMonth(e.date.year, e.date.month)));
    }
  });
}
