import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show PlatformException;
import 'package:isar_community/isar.dart';

import '../../../core/services/json_backup_service.dart';
import '../../notifications/data/app_notification.dart';
import '../../notifications/data/notification_repository.dart';
import '../data/backup_config.dart';
import 'saf_backup_store.dart';

enum BackupOutcome { notDue, done, failed }

/// Scheduled / manual backup without Riverpod, so the background worker
/// isolate and the UI share one implementation.
class ScheduledBackup {
  static Future<BackupConfig> _config(Isar isar) async {
    final existing = await isar.backupConfigs.where().findFirst();
    if (existing != null) return existing;
    final c = BackupConfig();
    await isar.writeTxn(() => isar.backupConfigs.put(c));
    return c;
  }

  /// Same rule as before vNext: [BackupConfig.frequency] days after the day
  /// of the last backup, or right away when none has run.
  static bool isDue(BackupConfig config, DateTime now) {
    if (!config.enabled || config.folderUri == null) return false;
    final last = config.lastBackupAt;
    if (last == null) return true;
    final days = switch (config.frequency) {
      'daily' => 1,
      'monthly' => 30,
      _ => 7,
    };
    final lastLocal = last.toLocal();
    final lastMidnight = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    return nowMidnight.difference(lastMidnight).inDays >= days;
  }

  static Future<bool> isDueNow(Isar isar) async =>
      isDue(await _config(isar), DateTime.now());

  static Future<(BackupOutcome, String?)> runIfDue(Isar isar, SafBackupStore store) async {
    final config = await _config(isar);
    if (!isDue(config, DateTime.now())) return (BackupOutcome.notDue, null);
    return run(isar, store);
  }

  /// Writes a backup now. Records success or the classified failure on the
  /// config and, on failure, adds the in-app notification.
  static Future<(BackupOutcome, String?)> run(Isar isar, SafBackupStore store) async {
    final config = await _config(isar);
    final now = DateTime.now();
    config.lastAttemptAt = now;
    if (config.folderUri == null || config.folderUri!.isEmpty) {
      await recordFailure(isar, config, 'folder_revoked');
      return (BackupOutcome.failed, 'folder_revoked');
    }
    try {
      await JsonBackupService().writeScheduledBackup(
        isar: isar,
        folderUri: config.folderUri!,
        retention: config.retention,
        store: store,
      );
      config
        ..lastBackupAt = now
        ..lastFailureReason = null;
      await isar.writeTxn(() => isar.backupConfigs.put(config));
      return (BackupOutcome.done, null);
    } catch (error) {
      debugPrint('Kuber backup failed: $error');
      final reason = classify(error);
      await recordFailure(isar, config, reason);
      return (BackupOutcome.failed, reason);
    }
  }

  static Future<void> recordFailure(Isar isar, BackupConfig config, String reason) async {
    config
      ..lastFailureReason = reason
      ..lastAttemptAt = DateTime.now();
    await isar.writeTxn(() => isar.backupConfigs.put(config));
    await NotificationRepository(isar).add(
      type: NotificationType.backup,
      title: 'Automatic backup failed',
      body: failureMessage(reason),
      payload: 'backup:$reason',
      iconHint: 'backup',
      createdAt: config.lastAttemptAt,
    );
  }

  /// 'folder_revoked' | 'disk_full' | 'write_error' | 'unknown'.
  static String classify(Object error) {
    final text = error.toString().toLowerCase();
    if (error is FileSystemException && text.contains('space')) return 'disk_full';
    if (error is PlatformException && error.code == 'folder_revoked') {
      return 'folder_revoked';
    }
    if (text.contains('no space') || text.contains('enospc')) return 'disk_full';
    if (text.contains('permission') || text.contains('not found')) {
      return 'folder_revoked';
    }
    if (text.contains('write')) return 'write_error';
    return 'unknown';
  }

  /// Transient failures are worth a WorkManager retry; a revoked folder or a
  /// full disk are not.
  static bool isTransient(String? reason) =>
      reason == 'write_error' || reason == 'unknown';

  static String failureMessage(String reason) => switch (reason) {
        'folder_revoked' =>
          'Kuber could not access your backup folder. Choose it again to continue.',
        'disk_full' => 'Your device or selected folder is out of space.',
        'write_error' => 'Kuber could not write the backup file.',
        _ => 'Something went wrong while saving the backup.',
      };
}
