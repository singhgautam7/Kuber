import 'package:isar_community/isar.dart';

part 'recent_search.g.dart';

/// Deprecated collection, kept registered only so databases created by an
/// earlier build (which shipped the now-removed master-search feature) still
/// open. Isar refuses to open a database whose on-disk schema includes a
/// collection missing from the schema list, so this must stay registered even
/// though nothing reads or writes it anymore. Do not reuse for new features.
@collection
class RecentSearch {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String queryLower;

  late String query;

  @Index()
  late DateTime updatedAt;

  /// Flat view for the Dev Tools DB Explorer, so this legacy collection's
  /// leftover rows are still inspectable on older databases.
  Map<String, dynamic> toMap() => {
        'id': id,
        'query': query,
        'queryLower': queryLower,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
