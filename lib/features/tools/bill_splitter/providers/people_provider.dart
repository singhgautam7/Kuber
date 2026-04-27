import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../data/person.dart';

final peopleListProvider =
    AsyncNotifierProvider<PeopleListNotifier, List<Person>>(
  PeopleListNotifier.new,
);

class PeopleListNotifier extends AsyncNotifier<List<Person>> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<List<Person>> build() async {
    return _isar.persons.where().sortByName().findAll();
  }

  Future<int> add(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return -1;
    final person = Person()
      ..name = trimmed
      ..createdAt = DateTime.now();
    final id = await _isar.writeTxn(() => _isar.persons.put(person));
    ref.invalidateSelf();
    return id;
  }

  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.persons.delete(id));
    ref.invalidateSelf();
  }
}
