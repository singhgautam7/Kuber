import 'package:isar_community/isar.dart';

part 'kuber_note.g.dart';

@collection
class KuberNote {
  Id id = Isar.autoIncrement;

  /// "" allowed — the UI renders "Untitled note" for empty titles.
  late String title;

  /// flutter_quill Delta JSON string.
  late String content;

  String? categoryId;

  List<String> tagIds = [];

  bool pinned = false;

  bool isReadOnly = false;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'categoryId': categoryId,
    'tagIds': tagIds,
    'pinned': pinned,
    'isReadOnly': isReadOnly,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
