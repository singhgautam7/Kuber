import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/reminder.dart';
import '../data/reminders_repository.dart';

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  return RemindersRepository(ref.watch(isarProvider));
});

final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(remindersRepositoryProvider).watchAll();
});

/// Landing filter chips: All | Overdue | Today | This week | Completed.
enum RemindersFilter { all, overdue, today, thisWeek, completed }

final remindersFilterProvider =
    StateProvider<RemindersFilter>((ref) => RemindersFilter.all);

final remindersSearchProvider = StateProvider<String>((ref) => '');

/// Grouped reminders for the landing screen sections.
class ReminderSections {
  final List<Reminder> overdue;
  final List<Reminder> today;
  final List<Reminder> thisWeek;
  final List<Reminder> later;
  final List<Reminder> completed;

  const ReminderSections({
    required this.overdue,
    required this.today,
    required this.thisWeek,
    required this.later,
    required this.completed,
  });

  bool get isEmpty =>
      overdue.isEmpty &&
      today.isEmpty &&
      thisWeek.isEmpty &&
      later.isEmpty &&
      completed.isEmpty;
}

final reminderSectionsProvider = Provider<ReminderSections>((ref) {
  final all = ref.watch(remindersStreamProvider).valueOrNull ?? const [];
  final filter = ref.watch(remindersFilterProvider);
  final query = ref.watch(remindersSearchProvider).trim().toLowerCase();

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final tomorrowStart = todayStart.add(const Duration(days: 1));
  final weekEnd = todayStart.add(Duration(days: 8 - todayStart.weekday));

  Iterable<Reminder> pool = all;
  if (query.isNotEmpty) {
    pool = pool.where((r) =>
        r.title.toLowerCase().contains(query) ||
        (r.notes ?? '').toLowerCase().contains(query));
  }

  bool isOverdue(Reminder r) => !r.isCompleted && r.dueAt.isBefore(now);
  bool isToday(Reminder r) =>
      !r.isCompleted &&
      !isOverdue(r) &&
      r.dueAt.isBefore(tomorrowStart);
  bool isThisWeek(Reminder r) =>
      !r.isCompleted &&
      !isOverdue(r) &&
      !isToday(r) &&
      r.dueAt.isBefore(weekEnd);

  pool = switch (filter) {
    RemindersFilter.all => pool,
    RemindersFilter.overdue => pool.where(isOverdue),
    RemindersFilter.today => pool.where(isToday),
    RemindersFilter.thisWeek => pool.where((r) => isToday(r) || isThisWeek(r)),
    RemindersFilter.completed => pool.where((r) => r.isCompleted),
  };

  final list = pool.toList()..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  final completed = list.where((r) => r.isCompleted).toList()
    ..sort((a, b) => (b.completedAt ?? b.updatedAt)
        .compareTo(a.completedAt ?? a.updatedAt));

  return ReminderSections(
    overdue: list.where(isOverdue).toList(),
    today: list.where(isToday).toList(),
    thisWeek: list.where(isThisWeek).toList(),
    later: list
        .where((r) =>
            !r.isCompleted && !isOverdue(r) && !isToday(r) && !isThisWeek(r))
        .toList(),
    completed: completed,
  );
});
