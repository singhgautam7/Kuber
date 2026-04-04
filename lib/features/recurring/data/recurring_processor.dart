import 'package:isar/isar.dart';

import '../../transactions/data/transaction.dart';
import 'recurring_repository.dart';
import 'recurring_rule.dart';

class RecurringProcessor {
  final Isar isar;

  RecurringProcessor(this.isar);

  /// Processes all due recurring rules and creates missed transactions.
  /// Returns the total number of transactions created.
  Future<int> processAll() async {
    final now = DateTime.now();
    final repo = RecurringRepository(isar);
    final dueRules = await repo.getDue(now);

    int totalCreated = 0;

    await isar.writeTxn(() async {
      for (final rule in dueRules) {
        if (RecurringRepository.isExpired(rule)) continue;

        var dueDate = rule.nextDueAt;

        // Create transactions for each missed due date
        while (dueDate.isBefore(now)) {
          // Check if rule has expired after incrementing execution count
          if (RecurringRepository.isExpired(rule)) break;

          final combinedDate = DateTime(
            dueDate.year,
            dueDate.month,
            dueDate.day,
            now.hour,
            now.minute,
            now.second,
            now.millisecond,
          );

          final t = Transaction()
            ..name = rule.name
            ..nameLower = rule.name.toLowerCase()
            ..amount = rule.amount
            ..type = rule.type
            ..categoryId = rule.categoryId
            ..accountId = rule.accountId
            ..notes = rule.notes
            ..linkedRuleId = rule.id.toString()
            ..linkedRuleType = 'recurring'
            ..createdAt = combinedDate
            ..updatedAt = DateTime.now();

          await isar.transactions.put(t);
          totalCreated++;

          rule.executionCount++;
          dueDate = RecurringRepository.computeNextDue(rule, dueDate);

          if (RecurringRepository.isExpired(rule)) break;
        }

        rule.nextDueAt = dueDate;
        rule.updatedAt = DateTime.now();
        await isar.recurringRules.put(rule);
      }
    });

    return totalCreated;
  }
}
