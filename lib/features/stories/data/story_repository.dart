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

  Future<void> deleteExpired(DateTime now) async {
    await isar.writeTxn(() {
      return isar.insightStorys.filter().expiresAtLessThan(now).deleteAll();
    });
  }

  Stream<void> watchLazy() => isar.insightStorys.watchLazy();
}
