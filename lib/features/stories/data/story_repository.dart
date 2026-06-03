import 'package:isar_community/isar.dart';

import 'insight_story.dart';

class StoryRepository {
  final Isar isar;
  StoryRepository(this.isar);

  Future<List<InsightStory>> listActive(DateTime now) {
    return isar.insightStorys
        .filter()
        .expiresAtGreaterThan(now)
        .sortByGeneratedAtDesc()
        .findAll();
  }

  Future<List<InsightStory>> listArchive({
    required int offset,
    required int limit,
  }) {
    return isar.insightStorys
        .where()
        .sortByGeneratedAtDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<InsightStory>> byKeys(Set<String> keys) {
    if (keys.isEmpty) return Future.value([]);
    return isar.insightStorys
        .filter()
        .anyOf(keys.toList(), (q, key) => q.storyKeyEqualTo(key))
        .findAll();
  }

  Future<InsightStory?> byKey(String key) =>
      isar.insightStorys.filter().storyKeyEqualTo(key).findFirst();

  /// All rows, including expired tombstones — used by generation to gate cadence
  /// and to update pace stories in place.
  Future<List<InsightStory>> all() => isar.insightStorys.where().findAll();

  Future<int> count() => isar.insightStorys.count();

  Future<void> putAll(List<InsightStory> stories) async {
    if (stories.isEmpty) return;
    await isar.writeTxn(() => isar.insightStorys.putAll(stories));
  }

  Future<void> markSeen(int id, int slideIndex) async {
    final story = await isar.insightStorys.get(id);
    if (story == null) return;
    if (!story.seenSlides.contains(slideIndex)) {
      story.seenSlides = [...story.seenSlides, slideIndex];
    }
    story.seenAt = DateTime.now();
    await isar.writeTxn(() => isar.insightStorys.put(story));
  }

  /// Hard-delete sweep: removes stories whose `expiresAt` is older than the
  /// retention cutoff. Tombstones (expired but within the cutoff) are kept so
  /// the cadence dedup queries still suppress regeneration inside their window.
  Future<void> deleteOlderThan(DateTime cutoff) async {
    await isar.writeTxn(() {
      return isar.insightStorys.filter().expiresAtLessThan(cutoff).deleteAll();
    });
  }

  Stream<void> watchLazy() => isar.insightStorys.watchLazy();
}
