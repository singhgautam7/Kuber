import 'package:isar_community/isar.dart';

part 'insight_story.g.dart';

@collection
class InsightStory {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String storyKey;

  late String type;

  @Index()
  late DateTime generatedAt;

  @Index()
  late DateTime expiresAt;

  DateTime? seenAt;

  List<int> seenSlides = [];

  late String payloadJson;

  Map<String, dynamic> toMap() => {
    'id': id,
    'storyKey': storyKey,
    'type': type,
    'generatedAt': generatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'seenAt': seenAt?.toIso8601String(),
    'seenSlides': seenSlides,
    'payloadJson': payloadJson,
  };
}
