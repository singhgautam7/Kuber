import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/backups/services/backup_rotation.dart';

void main() {
  group('pruneBackupFileNames', () {
    test('keeps newest date-sortable backup names by retention', () {
      final toDelete = pruneBackupFileNames([
        'notes.txt',
        'kuber_backup_2026-05-28_0900.json',
        'kuber_backup_2026-05-29_0900.json',
        'kuber_backup_2026-05-30_0900.json',
        'kuber_backup_2026-05-27_0900.json',
      ], retention: 2);

      expect(toDelete, [
        'kuber_backup_2026-05-28_0900.json',
        'kuber_backup_2026-05-27_0900.json',
      ]);
    });
  });
}
