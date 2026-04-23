import 'package:isar_community/isar.dart';

part 'category_group.g.dart';

@collection
class CategoryGroup {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}
