// Saved views: CRUD repository and the live list. Split from ah_providers.dart;
// that file re-exports this one.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../data/saved_filter.dart';
import '../models/ah_view.dart';
import 'ah_providers.dart';

enum SavedFilterNameProblem { empty, tooLong, taken }

class SavedFilterNameException implements Exception {
  const SavedFilterNameException(this.problem);
  final SavedFilterNameProblem problem;
  @override
  String toString() => 'SavedFilterNameException($problem)';
}

const kAhNameMax = 40;

/// Saved views CRUD. Names: required, 40 max, unique ignoring case; a bad
/// name throws [SavedFilterNameException].
final savedFilterRepositoryProvider = Provider<SavedFilterRepository>((ref) {
  return IsarSavedFilterRepository(
    ref.watch(isarProvider),
    onDeleted: (id) {
      if (ref.read(ahViewProvider).savedId == id) {
        ref.read(ahViewProvider.notifier).detachSaved();
      }
    },
  );
});

abstract class SavedFilterRepository {
  Future<bool> nameTaken(String name, {int? exceptId});
  Future<SavedFilter> saveNew(String name, AhView view);
  /// Writes [view] over the saved view [id] and returns the view it
  /// replaced (read in the same write, so Undo can put exactly that back),
  /// or null when [id] is gone.
  Future<AhView?> saveChanges(int id, AhView view);
  Future<void> rename(int id, String name);
  Future<void> delete(int id);
  Future<void> markUsed(int id);
}

class IsarSavedFilterRepository implements SavedFilterRepository {
  IsarSavedFilterRepository(this.isar, {this.onDeleted});
  final Isar isar;
  final void Function(int id)? onDeleted;

  Future<void> _check(String name, {int? exceptId}) async {
    if (name.isEmpty) {
      throw const SavedFilterNameException(SavedFilterNameProblem.empty);
    }
    if (name.length > kAhNameMax) {
      throw const SavedFilterNameException(SavedFilterNameProblem.tooLong);
    }
    if (await nameTaken(name, exceptId: exceptId)) {
      throw const SavedFilterNameException(SavedFilterNameProblem.taken);
    }
  }

  @override
  Future<bool> nameTaken(String name, {int? exceptId}) async {
    final hit = await isar.savedFilters
        .filter()
        .nameEqualTo(name.trim(), caseSensitive: false)
        .findFirst();
    return hit != null && hit.id != exceptId;
  }

  static void _fill(SavedFilter f, AhView v) {
    f.queryText = v.queryText;
    f.astJson = v.node == null ? null : jsonEncode(v.node!.toJson());
    f.groupBy = v.groupBy;
    f.sortField = v.sort.field;
    f.sortDescending = v.sort.descending;
    f.charts = [
      for (var i = 0; i < v.charts.length; i++)
        SavedChart()
          ..order = i
          ..type = v.charts[i].type
          ..split = v.charts[i].split
          ..measure = v.charts[i].measure
          ..seriesBy = v.charts[i].seriesBy?.name
          ..series = List.of(v.charts[i].series)
    ];
    f.kpiSelection = [for (final k in v.kpis) k.name];
  }

  @override
  Future<SavedFilter> saveNew(String name, AhView view) async {
    final n = name.trim();
    await _check(n);
    final now = DateTime.now();
    final f = SavedFilter()
      ..name = n
      ..createdAt = now
      ..updatedAt = now
      ..lastUsedAt = now;
    _fill(f, view);
    await isar.writeTxn(() => isar.savedFilters.put(f));
    return f;
  }

  @override
  Future<AhView?> saveChanges(int id, AhView view) async {
    AhView? before;
    await isar.writeTxn(() async {
      final f = await isar.savedFilters.get(id);
      if (f == null) return;
      before = viewFromSaved(f);
      _fill(f, view);
      f.updatedAt = DateTime.now();
      await isar.savedFilters.put(f);
    });
    return before;
  }

  @override
  Future<void> rename(int id, String name) async {
    final n = name.trim();
    await _check(n, exceptId: id);
    await isar.writeTxn(() async {
      final f = await isar.savedFilters.get(id);
      if (f == null) return;
      f.name = n;
      f.updatedAt = DateTime.now();
      await isar.savedFilters.put(f);
    });
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.savedFilters.delete(id));
    onDeleted?.call(id);
  }

  @override
  Future<void> markUsed(int id) => isar.writeTxn(() async {
        final f = await isar.savedFilters.get(id);
        if (f == null) return;
        f.lastUsedAt = DateTime.now();
        await isar.savedFilters.put(f);
      });
}

/// Saved views, last used first.
final savedFiltersProvider = StreamProvider.autoDispose<List<SavedFilter>>((ref) async* {
  final isar = ref.watch(isarProvider);
  await for (final _ in isar.savedFilters.watchLazy(fireImmediately: true)) {
    final all = await isar.savedFilters.where().findAll();
    all.sort((a, b) {
      final x = a.lastUsedAt ?? a.createdAt;
      final y = b.lastUsedAt ?? b.createdAt;
      return y.compareTo(x);
    });
    yield all;
  }
});

