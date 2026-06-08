import 'package:isar_community/isar.dart';

part 'ask_kuber_message.g.dart';

/// Persisted Ask Kuber chat message. Additive collection - Ask Kuber writes
/// only its own chat history, never user financial data.
///
/// [thinkingJson], [vizJson] and [metadataJson] hold the JSON-serialized
/// [ThinkingInfo], [VizPayload] and follow-up [ChipAction] list respectively so
/// a reloaded chat restores visualizations and working chips.
@collection
class AskKuberMessage {
  Id id = Isar.autoIncrement;

  late String text;
  late bool isUser;

  @Index()
  late DateTime time;

  String? thinkingJson;
  String? vizJson;
  String? metadataJson;
}
