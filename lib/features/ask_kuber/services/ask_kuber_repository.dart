import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/ask_kuber_message.dart';
import '../models/chat_message.dart';
import '../models/chip_action.dart';
import '../models/thinking_info.dart';
import '../models/viz_payload.dart';

/// Persistence for Ask Kuber's own chat history (and a small unhandled-query
/// log). The only data Ask Kuber writes; user financial data is read-only.
///
/// Visualizations and follow-up chips are JSON-serialized into the row so a
/// reloaded chat restores them fully (a persisted navigate chip keeps working).
class AskKuberRepository {
  final Isar isar;
  AskKuberRepository(this.isar);

  static const _unhandledKey = 'ask_kuber_unhandled_log';
  static const _unhandledCap = 50;

  /// All messages in chronological (insertion) order.
  Future<List<ChatMessage>> loadAll() async {
    final rows = await isar.askKuberMessages.where().findAll();
    return rows.map(_toMessage).toList();
  }

  /// Appends a message and back-fills its [ChatMessage.storedId].
  Future<void> append(ChatMessage msg) async {
    final row = _toRow(msg);
    await isar.writeTxn(() async {
      final id = await isar.askKuberMessages.put(row);
      msg.storedId = id;
    });
  }

  /// Wipes the whole conversation (Clear chat).
  Future<void> clear() async {
    await isar.writeTxn(() async {
      await isar.askKuberMessages.clear();
    });
  }

  /// Records a query that only the fallback could answer. Capped ring buffer in
  /// SharedPreferences so it never grows unbounded and needs no Isar schema.
  Future<void> logUnhandled(String raw) async {
    final q = raw.trim();
    if (q.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_unhandledKey) ?? <String>[];
    list.add('${DateTime.now().toIso8601String()}\t$q');
    if (list.length > _unhandledCap) {
      list.removeRange(0, list.length - _unhandledCap);
    }
    await prefs.setStringList(_unhandledKey, list);
  }

  ChatMessage _toMessage(AskKuberMessage row) {
    return ChatMessage(
      text: row.text,
      isUser: row.isUser,
      time: row.time,
      thinking: row.thinkingJson == null
          ? null
          : ThinkingInfo.fromJson(
              jsonDecode(row.thinkingJson!) as Map<String, dynamic>),
      vizPayload: row.vizJson == null
          ? null
          : VizPayload.fromJson(jsonDecode(row.vizJson!) as Map<String, dynamic>),
      followUps: row.metadataJson == null
          ? const []
          : (jsonDecode(row.metadataJson!) as List<dynamic>)
              .map((e) => ChipAction.fromJson(e as Map<String, dynamic>))
              .toList(),
      storedId: row.id,
    );
  }

  AskKuberMessage _toRow(ChatMessage msg) {
    return AskKuberMessage()
      ..text = msg.text
      ..isUser = msg.isUser
      ..time = msg.time
      ..thinkingJson =
          msg.thinking == null ? null : jsonEncode(msg.thinking!.toJson())
      ..vizJson =
          msg.vizPayload == null ? null : jsonEncode(msg.vizPayload!.toJson())
      ..metadataJson = msg.followUps.isEmpty
          ? null
          : jsonEncode(msg.followUps.map((c) => c.toJson()).toList());
  }
}
