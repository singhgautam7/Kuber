import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../data/saved_calculation.dart';

/// All saved calculations, newest-updated first.
final savedCalculationsProvider =
    AsyncNotifierProvider<SavedCalculationsNotifier, List<SavedCalculation>>(
  SavedCalculationsNotifier.new,
);

class SavedCalculationsNotifier extends AsyncNotifier<List<SavedCalculation>> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<List<SavedCalculation>> build() async {
    return _isar.savedCalculations.where().sortByUpdatedAtDesc().findAll();
  }

  /// Create a new saved calculation. Returns the new id.
  Future<int> create({
    required String tool,
    required String name,
    required String inputsJson,
    required String summary,
  }) async {
    final now = DateTime.now();
    final record = SavedCalculation()
      ..tool = tool
      ..name = name
      ..inputsJson = inputsJson
      ..summary = summary
      ..savedAt = now
      ..updatedAt = now;
    final id = await _isar.writeTxn(() => _isar.savedCalculations.put(record));
    ref.invalidateSelf();
    return id;
  }

  /// Overwrite the inputs/summary of an existing record (keeps the name).
  Future<void> updateRecord(
    int id, {
    String? name,
    required String inputsJson,
    required String summary,
  }) async {
    final existing = await _isar.savedCalculations.get(id);
    if (existing == null) return;
    existing
      ..name = name ?? existing.name
      ..inputsJson = inputsJson
      ..summary = summary
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.savedCalculations.put(existing));
    ref.invalidateSelf();
  }

  Future<void> deleteMany(List<int> ids) async {
    await _isar.writeTxn(() => _isar.savedCalculations.deleteAll(ids));
    ref.invalidateSelf();
  }

  Future<SavedCalculation?> getById(int id) => _isar.savedCalculations.get(id);
}

/// Saved calculations filtered to a single tool.
final savedCalculationsByToolProvider =
    Provider.family<AsyncValue<List<SavedCalculation>>, String>((ref, tool) {
  return ref.watch(savedCalculationsProvider).whenData(
        (list) => list.where((c) => c.tool == tool).toList(),
      );
});

/// Distinct tool keys that currently have at least one save (for filter chips).
final savedToolsProvider = Provider<List<String>>((ref) {
  final list = ref.watch(savedCalculationsProvider).valueOrNull ?? const [];
  final seen = <String>{};
  final ordered = <String>[];
  for (final c in list) {
    if (seen.add(c.tool)) ordered.add(c.tool);
  }
  return ordered;
});
