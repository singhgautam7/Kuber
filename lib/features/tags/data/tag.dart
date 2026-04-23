import 'package:isar_community/isar.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'isEnabled': isEnabled,
    'createdAt': createdAt.toIso8601String(),
  };
}
