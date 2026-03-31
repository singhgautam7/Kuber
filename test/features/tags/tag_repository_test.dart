import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:kuber/features/tags/data/tag_repository.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/test_factories.dart';

void main() {
  late Isar isar;
  late TagRepository repo;

  setUpAll(() async {
    await initialiseIsarForTests();
  });

  setUp(() async {
    isar = await openTestIsar();
    repo = TagRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  group('Tag CRUD', () {
    test('saveTag normalizes name', () async {
      final tag = makeTag(name: 'My Tag!');
      await repo.saveTag(tag);
      final all = await repo.getAllTags();
      expect(all.length, 1);
      expect(all.first.name, 'my-tag');
    });

    test('getAllTags returns sorted by name', () async {
      await repo.saveTag(makeTag(name: 'zzz'));
      await repo.saveTag(makeTag(name: 'aaa'));
      final all = await repo.getAllTags();
      expect(all.first.name, 'aaa');
      expect(all.last.name, 'zzz');
    });

    test('findByName finds normalized tag', () async {
      await repo.saveTag(makeTag(name: 'food'));
      final found = await repo.findByName('Food');
      expect(found, isNotNull);
      expect(found!.name, 'food');
    });

    test('findByName returns null for nonexistent', () async {
      final found = await repo.findByName('nonexistent');
      expect(found, isNull);
    });

    test('setTagEnabled toggles enabled', () async {
      final id = await repo.saveTag(makeTag(name: 'test'));
      await repo.setTagEnabled(id, false);
      final all = await repo.getAllTags();
      expect(all.first.isEnabled, false);

      await repo.setTagEnabled(id, true);
      final updated = await repo.getAllTags();
      expect(updated.first.isEnabled, true);
    });
  });

  group('Transaction-Tag relationships', () {
    late int tagId1, tagId2, tagId3;

    setUp(() async {
      tagId1 = await repo.saveTag(makeTag(name: 'food'));
      tagId2 = await repo.saveTag(makeTag(name: 'daily'));
      tagId3 = await repo.saveTag(makeTag(name: 'work'));
    });

    test('updateTransactionTags assigns tags atomically', () async {
      await repo.updateTransactionTags(100, [tagId1, tagId2]);
      final tags = await repo.getTagsForTransaction(100);
      expect(tags.length, 2);
      expect(tags.map((t) => t.name).toSet(), {'food', 'daily'});
    });

    test('updateTransactionTags replaces existing tags', () async {
      await repo.updateTransactionTags(100, [tagId1]);
      await repo.updateTransactionTags(100, [tagId2, tagId3]);
      final tags = await repo.getTagsForTransaction(100);
      expect(tags.length, 2);
      expect(tags.map((t) => t.name).toSet(), {'daily', 'work'});
    });

    test('updateTransactionTags with empty list removes all', () async {
      await repo.updateTransactionTags(100, [tagId1, tagId2]);
      await repo.updateTransactionTags(100, []);
      final tags = await repo.getTagsForTransaction(100);
      expect(tags, isEmpty);
    });

    test('getTagsForTransaction returns empty for unknown txn', () async {
      final tags = await repo.getTagsForTransaction(9999);
      expect(tags, isEmpty);
    });

    test('findTransactionIdsWithTags uses AND logic', () async {
      // txn 100 has food + daily
      await repo.updateTransactionTags(100, [tagId1, tagId2]);
      // txn 200 has food only
      await repo.updateTransactionTags(200, [tagId1]);

      // Search for food + daily → only txn 100
      final result = await repo.findTransactionIdsWithTags([tagId1, tagId2]);
      expect(result, [100]);
    });

    test('findTransactionIdsWithTags returns empty for no match', () async {
      await repo.updateTransactionTags(100, [tagId1]);
      final result = await repo.findTransactionIdsWithTags([tagId3]);
      expect(result, isEmpty);
    });

    test('findTransactionIdsWithTags returns empty for empty input', () async {
      final result = await repo.findTransactionIdsWithTags([]);
      expect(result, isEmpty);
    });

    test('findTransactionIdsWithTags with single tag', () async {
      await repo.updateTransactionTags(100, [tagId1, tagId2]);
      await repo.updateTransactionTags(200, [tagId1]);
      final result = await repo.findTransactionIdsWithTags([tagId1]);
      expect(result.toSet(), {100, 200});
    });
  });
}
