import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/services/json_backup_service.dart';
import '../../../features/notifications/data/app_notification.dart';
import '../../../features/notifications/data/notification_repository.dart';
import '../data/backup_config.dart';
import '../data/backup_repository.dart';
import '../services/saf_backup_store.dart';

enum BackupFrequency { daily, weekly, monthly }

enum BackupStatus { failed, succeeded, neverConfigured }

enum BackupFailureReason { folderRevoked, diskFull, writeError, unknown }

class BackupSettings {
  final bool enabled;
  final BackupFrequency frequency;
  final int retention;
  final String? folderPath;
  final BackupStatus status;
  final String? failureReason;
  final String? lastAttemptLabel;
  final DateTime? lastBackupAt;

  const BackupSettings({
    this.enabled = false,
    this.frequency = BackupFrequency.weekly,
    this.retention = 5,
    this.folderPath,
    this.status = BackupStatus.neverConfigured,
    this.failureReason,
    this.lastAttemptLabel,
    this.lastBackupAt,
  });

  bool get backupJustCompleted {
    if (status != BackupStatus.succeeded) return false;
    final now = DateTime.now();
    return lastBackupAt != null &&
        lastBackupAt!.year == now.year &&
        lastBackupAt!.month == now.month &&
        lastBackupAt!.day == now.day;
  }
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(isarProvider));
});

final safBackupStoreProvider = Provider<SafBackupStore>((ref) {
  return SafBackupStore();
});

class BackupSettingsNotifier extends AsyncNotifier<BackupSettings> {
  StreamSubscription<void>? _sub;

  @override
  Future<BackupSettings> build() async {
    final repo = ref.watch(backupRepositoryProvider);
    _sub?.cancel();
    _sub = repo.watchLazy().listen((_) => ref.invalidateSelf());
    ref.onDispose(() => _sub?.cancel());
    return _toSettings(await repo.getOrCreate());
  }

  Future<void> setEnabled(bool enabled) async {
    final repo = ref.read(backupRepositoryProvider);
    final config = await repo.getOrCreate();
    config.enabled = enabled;
    if (enabled && config.folderUri == null) {
      await repo.save(config);
      await pickFolder();
      return;
    }
    await repo.save(config);
  }

  Future<void> setFrequency(BackupFrequency frequency) async {
    final repo = ref.read(backupRepositoryProvider);
    final config = await repo.getOrCreate();
    config.frequency = frequency.name;
    await repo.save(config);
  }

  Future<void> setRetention(int retention) async {
    final repo = ref.read(backupRepositoryProvider);
    final config = await repo.getOrCreate();
    config.retention = retention;
    await repo.save(config);
  }

  Future<void> pickFolder() async {
    final uri = await ref.read(safBackupStoreProvider).pickFolder();
    if (uri == null) return;
    final repo = ref.read(backupRepositoryProvider);
    final config = await repo.getOrCreate();
    config.folderUri = uri;
    config.enabled = true;
    await repo.save(config);
  }

  Future<(bool, String)> backupNow() async {
    final config = await ref.read(backupRepositoryProvider).getOrCreate();
    try {
      await runBackup(config, manual: true);
      final updated = await ref.read(backupRepositoryProvider).getOrCreate();
      if (updated.lastFailureReason != null) {
        return (false, _failureMessage(_failureFromString(updated.lastFailureReason!)));
      }
      return (true, 'Backed up successfully');
    } catch (e) {
      return (false, 'Backup failed: $e');
    }
  }

  // Guards against the cold-start loader and the on-resume check both firing a
  // scheduled backup at the same instant (both could pass isDue before either
  // writes lastBackupAt).
  bool _scheduledBackupRunning = false;

  Future<bool> runDueBackup() async {
    if (_scheduledBackupRunning) return false;
    _scheduledBackupRunning = true;
    try {
      final config = await ref.read(backupRepositoryProvider).getOrCreate();
      if (!isDue(config, DateTime.now())) return false;
      await runBackup(config);
      return true;
    } finally {
      _scheduledBackupRunning = false;
    }
  }

  Future<void> runBackup(BackupConfig config, {bool manual = false}) async {
    final repo = ref.read(backupRepositoryProvider);
    final now = DateTime.now();
    config.lastAttemptAt = now;
    if (config.folderUri == null || config.folderUri!.isEmpty) {
      await _recordFailure(config, BackupFailureReason.folderRevoked);
      return;
    }
    try {
      await JsonBackupService().writeScheduledBackup(
        isar: ref.read(isarProvider),
        folderUri: config.folderUri!,
        retention: config.retention,
        store: ref.read(safBackupStoreProvider),
      );
      config.lastBackupAt = now;
      config.lastFailureReason = null;
      await repo.save(config);
    } catch (error) {
      debugPrint('Kuber backup failed: $error');
      await _recordFailure(config, _classify(error));
    }
  }

  bool isDue(BackupConfig config, DateTime now) {
    if (!config.enabled || config.folderUri == null) return false;
    final last = config.lastBackupAt;
    if (last == null) return true;
    final days = switch (_frequencyFromString(config.frequency)) {
      BackupFrequency.daily => 1,
      BackupFrequency.weekly => 7,
      BackupFrequency.monthly => 30,
    };
    final lastLocal = last.toLocal();
    final lastMidnight = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    return nowMidnight.difference(lastMidnight).inDays >= days;
  }

  Future<void> _recordFailure(
    BackupConfig config,
    BackupFailureReason reason,
  ) async {
    config.lastFailureReason = _failureToString(reason);
    config.lastAttemptAt = DateTime.now();
    await ref.read(backupRepositoryProvider).save(config);
    await NotificationRepository(ref.read(isarProvider)).add(
      type: NotificationType.backup,
      title: 'Automatic backup failed',
      body: _failureMessage(reason),
      payload: 'backup:${_failureToString(reason)}',
      iconHint: 'backup',
      createdAt: config.lastAttemptAt,
    );
  }

  BackupFailureReason _classify(Object error) {
    final text = error.toString().toLowerCase();
    if (error is FileSystemException && text.contains('space')) {
      return BackupFailureReason.diskFull;
    }
    if (error is PlatformException && error.code == 'folder_revoked') {
      return BackupFailureReason.folderRevoked;
    }
    if (text.contains('no space') || text.contains('enospc')) {
      return BackupFailureReason.diskFull;
    }
    if (text.contains('permission') || text.contains('not found')) {
      return BackupFailureReason.folderRevoked;
    }
    if (text.contains('write')) return BackupFailureReason.writeError;
    return BackupFailureReason.unknown;
  }
}

final backupSettingsProvider =
    AsyncNotifierProvider<BackupSettingsNotifier, BackupSettings>(
      BackupSettingsNotifier.new,
    );

BackupSettings _toSettings(BackupConfig config) {
  final status = config.lastFailureReason != null
      ? BackupStatus.failed
      : config.lastBackupAt != null
      ? BackupStatus.succeeded
      : BackupStatus.neverConfigured;
  return BackupSettings(
    enabled: config.enabled,
    frequency: _frequencyFromString(config.frequency),
    retention: config.retention,
    folderPath: config.folderUri,
    status: status,
    failureReason: config.lastFailureReason == null
        ? null
        : _failureMessage(_failureFromString(config.lastFailureReason!)),
    lastAttemptLabel: _lastAttemptLabel(
      config.lastAttemptAt ?? config.lastBackupAt,
    ),
    lastBackupAt: config.lastBackupAt,
  );
}

BackupFrequency _frequencyFromString(String value) {
  return BackupFrequency.values.firstWhere(
    (f) => f.name == value,
    orElse: () => BackupFrequency.weekly,
  );
}

BackupFailureReason _failureFromString(String value) {
  return switch (value) {
    'folder_revoked' => BackupFailureReason.folderRevoked,
    'disk_full' => BackupFailureReason.diskFull,
    'write_error' => BackupFailureReason.writeError,
    _ => BackupFailureReason.unknown,
  };
}

String _failureToString(BackupFailureReason reason) {
  return switch (reason) {
    BackupFailureReason.folderRevoked => 'folder_revoked',
    BackupFailureReason.diskFull => 'disk_full',
    BackupFailureReason.writeError => 'write_error',
    BackupFailureReason.unknown => 'unknown',
  };
}

String _failureMessage(BackupFailureReason reason) {
  return switch (reason) {
    BackupFailureReason.folderRevoked =>
      'Kuber could not access your backup folder. Choose it again to continue.',
    BackupFailureReason.diskFull =>
      'Your device or selected folder is out of space.',
    BackupFailureReason.writeError => 'Kuber could not write the backup file.',
    BackupFailureReason.unknown =>
      'Something went wrong while saving the backup.',
  };
}

String? _lastAttemptLabel(DateTime? date) {
  if (date == null) return null;
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return '${date.day}/${date.month}/${date.year}';
}
