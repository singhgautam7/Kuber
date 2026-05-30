import 'package:isar_community/isar.dart';

import 'backup_config.dart';

class BackupRepository {
  final Isar isar;
  BackupRepository(this.isar);

  Future<BackupConfig> getOrCreate() async {
    final existing = await isar.backupConfigs.where().findFirst();
    if (existing != null) return existing;
    final config = BackupConfig();
    await isar.writeTxn(() => isar.backupConfigs.put(config));
    return config;
  }

  Future<void> save(BackupConfig config) async {
    await isar.writeTxn(() => isar.backupConfigs.put(config));
  }

  Stream<void> watchLazy() => isar.backupConfigs.watchLazy();
}
