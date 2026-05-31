import 'package:isar_community/isar.dart';

part 'backup_config.g.dart';

@collection
class BackupConfig {
  Id id = Isar.autoIncrement;

  bool enabled = false;

  String frequency = 'weekly';

  int retention = 5;

  String? folderUri;

  DateTime? lastBackupAt;

  DateTime? lastAttemptAt;

  String? lastFailureReason;

  Map<String, dynamic> toMap() => {
    'id': id,
    'enabled': enabled,
    'frequency': frequency,
    'retention': retention,
    'folderUri': folderUri,
    'lastBackupAt': lastBackupAt?.toIso8601String(),
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    'lastFailureReason': lastFailureReason,
  };
}
