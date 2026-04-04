import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;
  late String icon; // Material icon name, e.g. "restaurant"
  late int colorValue; // raw Color int — harmonized at render time
  bool isDefault = false; // default categories cannot be deleted
  String type = 'both'; // 'expense' | 'income' | 'both'

  @Index()
  int? groupId;
}

extension CategoryTypeExt on Category {
  String get effectiveType => type.isEmpty ? 'both' : type;
}
