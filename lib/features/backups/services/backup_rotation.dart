List<String> pruneBackupFileNames(
  Iterable<String> fileNames, {
  required int retention,
}) {
  final matches =
      fileNames
          .where(
            (name) =>
                name.startsWith('kuber_backup_') && name.endsWith('.json'),
          )
          .toList()
        ..sort((a, b) => b.compareTo(a));
  if (matches.length <= retention) return const [];
  return matches.skip(retention).toList();
}
