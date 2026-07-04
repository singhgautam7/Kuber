import 'package:isar_community/isar.dart';

part 'reminder.g.dart';

/// Status string constants for [Reminder.status]. Stored as plain strings so
/// the schema stays migration-safe (no enum ordinals).
class ReminderStatus {
  static const pending = 'pending';
  static const completed = 'completed';
  static const snoozed = 'snoozed';
}

/// Repeat string constants for [Reminder.repeat]. null = no repeat.
class ReminderRepeat {
  static const daily = 'daily';
  static const weekly = 'weekly';
  static const monthly = 'monthly';
  static const yearly = 'yearly';

  static const all = [daily, weekly, monthly, yearly];
}

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  late String title;

  String? notes;

  @Index()
  late DateTime dueAt;

  /// null = no amount attached.
  double? amount;

  /// 'expense' | 'income' | null (only meaningful when [amount] is set).
  String? transactionType;

  String? categoryId;

  /// 'daily' | 'weekly' | 'monthly' | 'yearly' | null.
  String? repeat;

  /// 'pending' | 'completed' | 'snoozed'. Overdue is COMPUTED
  /// (`status != completed && dueAt < now`), never stored.
  @Index()
  late String status;

  DateTime? completedAt;

  late DateTime createdAt;

  late DateTime updatedAt;

  @ignore
  bool get isCompleted => status == ReminderStatus.completed;

  @ignore
  bool get isOverdue => !isCompleted && dueAt.isBefore(DateTime.now());

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'notes': notes,
    'dueAt': dueAt.toIso8601String(),
    'amount': amount,
    'transactionType': transactionType,
    'categoryId': categoryId,
    'repeat': repeat,
    'status': status,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
