import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;
  late String icon; // Material icon name, e.g. "restaurant"
  late int colorValue; // raw Color int — harmonized at render time
  bool isDefault = false; // default categories cannot be deleted
}
