import 'package:isar_community/isar.dart';

part 'insight_story.g.dart';

@collection
class InsightStory {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String storyKey;

  // Composite (type, generatedAt) index powers the cadence dedup query
  // ("most recent generatedAt for this type/entity"). generatedAt keeps its
  // own single index for the archive/active sorts.
  @Index(composite: [CompositeIndex('generatedAt')])
  late String type;

  @Index()
  late DateTime generatedAt;

  @Index()
  late DateTime expiresAt;

  DateTime? seenAt;

  List<int> seenSlides = [];

  late String payloadJson;

  /// Inclusive start of the period a recap describes. Null for non-recaps.
  DateTime? periodStart;

  /// Inclusive end of the period a recap describes. Null for non-recaps.
  DateTime? periodEnd;

  /// Stable hash of the story's message string, populated on insert. Safety
  /// field for diagnostics only — cadence/storyKey are the dedup gates.
  String? contentHash;

  Map<String, dynamic> toMap() => {
    'id': id,
    'storyKey': storyKey,
    'type': type,
    'generatedAt': generatedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'seenAt': seenAt?.toIso8601String(),
    'seenSlides': seenSlides,
    'payloadJson': payloadJson,
    'periodStart': periodStart?.toIso8601String(),
    'periodEnd': periodEnd?.toIso8601String(),
    'contentHash': contentHash,
  };
}
