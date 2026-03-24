import 'package:isar/isar.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  bool isEnabled = true;

  @Index()
  late DateTime createdAt;

  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-_]'), '');
  }
}
