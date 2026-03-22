import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  return RecurringRepository(ref.watch(isarProvider));
});

final recurringListProvider =
    AsyncNotifierProvider<RecurringListNotifier, List<RecurringRule>>(
  RecurringListNotifier.new,
);

class RecurringListNotifier extends AsyncNotifier<List<RecurringRule>> {
  @override
  FutureOr<List<RecurringRule>> build() {
    return ref.watch(recurringRepositoryProvider).getAll();
  }

  Future<void> add(RecurringRule rule) async {
    await ref.read(recurringRepositoryProvider).save(rule);
    ref.invalidateSelf();
  }

  Future<void> updateRule(RecurringRule rule) async {
    await ref.read(recurringRepositoryProvider).save(rule);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(recurringRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<void> togglePause(RecurringRule rule) async {
    rule.isPaused = !rule.isPaused;
    await ref.read(recurringRepositoryProvider).save(rule);
    ref.invalidateSelf();
  }
}

/// Upcoming recurring rules due in the next 7 days, max 3
final upcomingRecurringProvider =
    FutureProvider<List<RecurringRule>>((ref) async {
  final rules = await ref.watch(recurringListProvider.future);
  final now = DateTime.now();
  final sevenDaysLater = now.add(const Duration(days: 7));

  final upcoming = rules
      .where((r) =>
          !r.isPaused &&
          !RecurringRepository.isExpired(r) &&
          r.nextDueAt.isBefore(sevenDaysLater))
      .toList()
    ..sort((a, b) => a.nextDueAt.compareTo(b.nextDueAt));

  return upcoming.take(3).toList();
});

/// Recently auto-created transactions (with non-null recurringRuleId), last 5
final recentlyProcessedProvider =
    FutureProvider<List<Transaction>>((ref) async {
  final all = await ref.watch(transactionListProvider.future);
  return all
      .where((t) => t.recurringRuleId != null)
      .take(5)
      .toList();
});
