import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/backups/data/backup_config.dart';
import 'package:kuber/features/backups/providers/backup_provider.dart';

/// The status card's "Next: …" chip uses the same rule as the due check:
/// frequency days after the day of the last backup, today when none ran.
void main() {
  final now = DateTime(2026, 10, 19, 10);

  BackupConfig config({
    bool enabled = true,
    String? folder = 'content://tree/primary%3ADocuments%2FKuber%20Backups',
    String frequency = 'weekly',
    DateTime? last,
  }) =>
      BackupConfig()
        ..enabled = enabled
        ..folderUri = folder
        ..frequency = frequency
        ..lastBackupAt = last;

  test('off or no folder: no next backup', () {
    expect(nextBackupDay(config(enabled: false), now: now), isNull);
    expect(nextBackupDay(config(folder: null), now: now), isNull);
  });

  test('never backed up: due today', () {
    expect(nextBackupDay(config(), now: now), DateTime(2026, 10, 19));
  });

  test('daily / weekly / monthly from the last backup day', () {
    final last = DateTime(2026, 10, 19, 9, 41);
    expect(nextBackupDay(config(frequency: 'daily', last: last), now: now),
        DateTime(2026, 10, 20));
    expect(nextBackupDay(config(last: last), now: now), DateTime(2026, 10, 26));
    expect(nextBackupDay(config(frequency: 'monthly', last: last), now: now),
        DateTime(2026, 11, 18));
  });
}
