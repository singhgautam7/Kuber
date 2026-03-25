import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/category.dart';
import '../data/category_group.dart';
import '../data/category_group_repository.dart';
import '../data/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(isarProvider));
});

final categoryGroupRepositoryProvider = Provider<CategoryGroupRepository>((ref) {
  return CategoryGroupRepository(ref.watch(isarProvider));
});

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(
  CategoryListNotifier.new,
);

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() {
    return ref.watch(categoryRepositoryProvider).getAll();
  }

  Future<void> add(Category c) async {
    await ref.read(categoryRepositoryProvider).save(c);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final categoryGroupListProvider =
    AsyncNotifierProvider<CategoryGroupListNotifier, List<CategoryGroup>>(
  CategoryGroupListNotifier.new,
);

class CategoryGroupListNotifier extends AsyncNotifier<List<CategoryGroup>> {
  @override
  FutureOr<List<CategoryGroup>> build() {
    return ref.watch(categoryGroupRepositoryProvider).getAll();
  }

  Future<void> add(CategoryGroup g) async {
    await ref.read(categoryGroupRepositoryProvider).save(g);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(categoryGroupRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

/// Used to signal Add Transaction screen to auto-select a newly created category
final pendingCategorySelectionProvider = StateProvider<int?>((ref) => null);

/// Provides a map of category id -> Category for quick lookup
final categoryMapProvider = FutureProvider<Map<int, Category>>((ref) async {
  final categories = await ref.watch(categoryListProvider.future);
  return {for (final c in categories) c.id: c};
});
