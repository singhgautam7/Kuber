import 'package:isar_community/isar.dart';

part 'app_notification.g.dart';

// IMPORTANT: never reorder these values — isar_community persists @enumerated
// fields by ordinal index. Append-only.
enum NotificationType {
  general,
  budgetAlert,
  recurringTransaction,
  loanEmi,
  ledgerReminder,
  backup,
}

@collection
class AppNotification {
  Id id = Isar.autoIncrement;

  @Index()
  @enumerated
  late NotificationType type;

  late String title;
  late String body;

  // Format: "<entity>:<id>", e.g. "recurring:42", "loan:7", "budget:3",
  // "ledger:11". null for general notifications with no target.
  @Index()
  String? payload;

  @Index()
  late DateTime createdAt;

  DateTime? readAt;

  String? iconHint;

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'title': title,
    'body': body,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'readAt': readAt?.toIso8601String(),
    'iconHint': iconHint,
  };
}
