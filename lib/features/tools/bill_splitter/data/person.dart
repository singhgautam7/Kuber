import 'package:isar_community/isar.dart';

part 'person.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String name;

  late DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };
}
