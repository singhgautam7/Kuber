import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/reminders/data/reminder.dart';
import 'package:kuber/features/reminders/data/reminders_repository.dart';

void main() {
  group('Reminder computed status', () {
    test('pending past due is overdue', () {
      final r = Reminder()
        ..title = 't'
        ..dueAt = DateTime.now().subtract(const Duration(hours: 2))
        ..status = ReminderStatus.pending
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      expect(r.isOverdue, isTrue);
      expect(r.isCompleted, isFalse);
    });

    test('completed is never overdue', () {
      final r = Reminder()
        ..title = 't'
        ..dueAt = DateTime.now().subtract(const Duration(days: 3))
        ..status = ReminderStatus.completed
        ..completedAt = DateTime.now()
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      expect(r.isOverdue, isFalse);
    });
  });

  group('RemindersRepository.nextOccurrence', () {
    test('daily advances past now', () {
      final from = DateTime.now().subtract(const Duration(days: 3));
      final next = RemindersRepository.nextOccurrence(
          from, ReminderRepeat.daily);
      expect(next.isAfter(DateTime.now()), isTrue);
      expect(next.difference(from).inDays, lessThanOrEqualTo(4));
    });

    test('weekly keeps weekday', () {
      final from = DateTime.now().subtract(const Duration(days: 1));
      final next = RemindersRepository.nextOccurrence(
          from, ReminderRepeat.weekly);
      expect(next.weekday, from.weekday);
      expect(next.isAfter(DateTime.now()), isTrue);
    });

    test('monthly moves at least one month forward', () {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, 15, 9);
      final next = RemindersRepository.nextOccurrence(
          from, ReminderRepeat.monthly);
      expect(next.isAfter(now), isTrue);
      expect(next.day, anyOf(15, 1, 2, 3)); // month-length overflow rolls
    });

    test('yearly moves one year forward', () {
      final now = DateTime.now();
      final from = DateTime(now.year - 1, 1, 5);
      final next = RemindersRepository.nextOccurrence(
          from, ReminderRepeat.yearly);
      expect(next.isAfter(now), isTrue);
      expect(next.month, 1);
      expect(next.day, 5);
    });
  });
}
