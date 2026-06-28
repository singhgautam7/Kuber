import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/backups/data/backup_config.dart';
import '../../helpers/isar_test_helper.dart';

Future<bool> isAutomaticBackupDue(Isar isar) async {
  final config = await isar.collection<BackupConfig>().where().findFirst();
  if (config == null || !config.enabled || config.folderUri == null) {
    return false;
  }
  final last = config.lastBackupAt;
  if (last == null) return true;
  final days = switch (config.frequency) {
    'daily' => 1,
    'monthly' => 30,
    _ => 7,
  };
  final lastLocal = last.toLocal();
  final lastMidnight = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
  final now = DateTime.now();
  final nowMidnight = DateTime(now.year, now.month, now.day);
  return nowMidnight.difference(lastMidnight).inDays >= days;
}

void main() {
  late Isar isar;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('Automatic Backup Due Check - Calendar Day Logic', () {
    test('returns false if config is disabled or folderUri is null', () async {
      final config = BackupConfig()
        ..enabled = false
        ..frequency = 'daily'
        ..folderUri = null;
      await isar.writeTxn(() => isar.backupConfigs.put(config));
      expect(await isAutomaticBackupDue(isar), isFalse);
    });

    test('returns true if lastBackupAt is null', () async {
      final config = BackupConfig()
        ..enabled = true
        ..frequency = 'daily'
        ..folderUri = 'test_folder'
        ..lastBackupAt = null;
      await isar.writeTxn(() => isar.backupConfigs.put(config));
      expect(await isAutomaticBackupDue(isar), isTrue);
    });

    test('daily: triggers on a new calendar day even if less than 24 hours have passed', () async {
      // Last backup at 11:00 PM yesterday (local time)
      final now = DateTime.now();
      final yesterday11Pm = DateTime(now.year, now.month, now.day - 1, 23, 0, 0);
      final lastUtc = yesterday11Pm.toUtc();
      
      final config = BackupConfig()
        ..enabled = true
        ..frequency = 'daily'
        ..folderUri = 'test_folder'
        ..lastBackupAt = lastUtc;
      await isar.writeTxn(() => isar.backupConfigs.put(config));

      expect(await isAutomaticBackupDue(isar), isTrue);
    });

    test('daily: does not trigger on the same calendar day', () async {
      // Last backup at 12:01 AM today (local time)
      final now = DateTime.now();
      final today1201Am = DateTime(now.year, now.month, now.day, 0, 1, 0);
      final lastUtc = today1201Am.toUtc();

      final config = BackupConfig()
        ..enabled = true
        ..frequency = 'daily'
        ..folderUri = 'test_folder'
        ..lastBackupAt = lastUtc;
      await isar.writeTxn(() => isar.backupConfigs.put(config));

      // Same calendar day
      expect(await isAutomaticBackupDue(isar), isFalse);
    });

    test('weekly: triggers after 7 calendar days', () async {
      // Last backup 6 calendar days ago
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final config6 = BackupConfig()
        ..enabled = true
        ..frequency = 'weekly'
        ..folderUri = 'test_folder'
        ..lastBackupAt = sixDaysAgo.toUtc();
      await isar.writeTxn(() => isar.backupConfigs.put(config6));
      expect(await isAutomaticBackupDue(isar), isFalse);

      // Last backup 7 calendar days ago
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      config6.lastBackupAt = sevenDaysAgo.toUtc();
      await isar.writeTxn(() => isar.backupConfigs.put(config6));
      expect(await isAutomaticBackupDue(isar), isTrue);
    });

    test('monthly: triggers after 30 calendar days', () async {
      // Last backup 29 calendar days ago
      final twentyNineDaysAgo = DateTime.now().subtract(const Duration(days: 29));
      final config29 = BackupConfig()
        ..enabled = true
        ..frequency = 'monthly'
        ..folderUri = 'test_folder'
        ..lastBackupAt = twentyNineDaysAgo.toUtc();
      await isar.writeTxn(() => isar.backupConfigs.put(config29));
      expect(await isAutomaticBackupDue(isar), isFalse);

      // Last backup 30 calendar days ago
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      config29.lastBackupAt = thirtyDaysAgo.toUtc();
      await isar.writeTxn(() => isar.backupConfigs.put(config29));
      expect(await isAutomaticBackupDue(isar), isTrue);
    });
  });
}
