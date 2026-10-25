import 'package:isar_community/isar.dart';

part 'processed_occurrence.g.dart';

/// One row per schedule occurrence that has been handled. The unique [key]
/// makes posting an occurrence twice impossible: the row is inserted in the
/// same write transaction as the transaction it creates, so a second run, a
/// second isolate or a retry after a crash aborts instead of duplicating.
@collection
class ProcessedOccurrence {
  Id id = Isar.autoIncrement;

  /// '{sourceType}:{sourceId}:{yyyymmdd}'.
  @Index(unique: true)
  late String key;

  /// 'recurring' | 'loan' | 'investment'.
  @Index(composite: [CompositeIndex('sourceId')])
  late String sourceType;
  late String sourceId;

  /// yyyymmdd.
  late int occurrenceDate;

  /// 'posted' | 'skipped' | 'seeded' (migration, from an existing linked
  /// transaction).
  late String status;

  int? transactionId;
  String? runId;
  late DateTime createdAt;

  static String keyOf(String sourceType, String sourceId, int day) =>
      '$sourceType:$sourceId:$day';

  Map<String, dynamic> toMap() => {
    'id': id,
    'key': key,
    'sourceType': sourceType,
    'sourceId': sourceId,
    'occurrenceDate': occurrenceDate,
    'status': status,
    'transactionId': transactionId,
    'runId': runId,
    'createdAt': createdAt.toIso8601String(),
  };

  static ProcessedOccurrence fromMap(Map<String, dynamic> m) =>
      ProcessedOccurrence()
        ..id = m['id'] as int
        ..key = m['key'] as String
        ..sourceType = m['sourceType'] as String
        ..sourceId = m['sourceId'] as String
        ..occurrenceDate = m['occurrenceDate'] as int
        ..status = m['status'] as String
        ..transactionId = m['transactionId'] as int?
        ..runId = m['runId'] as String?
        ..createdAt = DateTime.parse(m['createdAt'] as String);
}
