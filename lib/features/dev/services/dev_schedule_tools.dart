// Dev tools: test items for the money schedules (QA on emulators with demo
// data only). Adds rules / an EMI loan / a step-up SIP that are due now and an
// FD that has matured, so the background queue has work to do.

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../investments/data/investment.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../tools/engine/fd_rd_engine.dart' show CompoundingFrequency;

Future<int> seedDueScheduleItems(Isar isar, {DateTime? now}) async {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final account = await isar.accounts.where().findFirst();
  final category = await isar.categorys.where().findFirst();
  if (account == null || category == null) return 0;
  final acc = '${account.id}', cat = '${category.id}';

  RecurringRule rule(String name, Schedule s, double amount) => RecurringRule()
    ..name = name
    ..amount = amount
    ..type = 'expense'
    ..categoryId = cat
    ..accountId = acc
    ..frequency = 'custom'
    ..customDays = s.intervalCount
    ..intervalUnit = s.intervalUnit.name
    ..startDate = s.startDate!
    ..nextDueAt = s.startDate!
    ..endType = 'never'
    ..createdAt = n
    ..updatedAt = n
    ..schedule = s
    ..dataVersion = 1;

  final first = DateTime(today.year, today.month, today.day - 2);
  final rules = [
    rule('Test daily tea', scheduleFrom(start: first, unit: ScheduleUnit.day), 20),
    rule('Test weekly maid',
        scheduleFrom(start: DateTime(today.year, today.month, today.day - 7), unit: ScheduleUnit.week), 750),
    rule('Test month-end card',
        scheduleFrom(start: DateTime(today.year, today.month - 2, 31)), 1200),
  ];
  final loan = Loan()
    ..uid = const Uuid().v4()
    ..name = 'Test car loan'
    ..loanType = 'vehicle'
    ..lenderName = 'Test bank'
    ..principalAmount = 500000
    ..emiAmount = 0
    ..billDate = today.day
    ..startDate = DateTime(today.year, today.month - 1, today.day)
    ..accountId = acc
    ..categoryId = cat
    ..createdAt = n
    ..updatedAt = n
    ..mode = LoanMode.advanced
    ..annualRate = 9
    ..interestRate = 9
    ..tenureMonths = 60
    ..startingPoint = LoanStartingPoint.originalDetails
    ..schedule = scheduleFrom(
        start: DateTime(today.year, today.month - 1, today.day),
        endType: ScheduleEnd.afterCount,
        endCount: 60)
    ..dataVersion = 1;
  final sip = Investment()
    ..uid = const Uuid().v4()
    ..name = 'Test index fund'
    ..investmentType = 'mutual_fund'
    ..behaviour = InvestmentBehaviour.market
    ..investedAmount = 0
    ..currentValue = 0
    ..sipAmount = 3000
    ..stepUpValue = 10
    ..accountId = acc
    ..categoryId = cat
    ..createdAt = n
    ..updatedAt = n
    ..sip = scheduleFrom(start: DateTime(today.year - 1, today.month, today.day))
    ..dataVersion = 1;
  final fd = Investment()
    ..uid = const Uuid().v4()
    ..name = 'Test FD'
    ..investmentType = 'fd'
    ..behaviour = InvestmentBehaviour.fixedReturn
    ..investedAmount = 100000
    ..fixedPrincipal = 100000
    ..fixedRate = 7
    ..compounding = CompoundingFrequency.quarterly
    ..fixedStart = DateTime(today.year - 1, today.month, today.day)
    ..fixedTenureMonths = 12
    ..maturityDate = today
    ..accountId = acc
    ..categoryId = cat
    ..createdAt = n
    ..updatedAt = n
    ..dataVersion = 1;
  await isar.writeTxn(() async {
    await isar.recurringRules.putAll(rules);
    await isar.loans.put(loan);
    await isar.investments.putAll([sip, fd]);
  });
  return rules.length + 3;
}
