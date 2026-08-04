import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/fuzzy_category_matcher.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import 'quick_add_resolver.dart';

/// Turns confirmable [drafts] into transactions, creating any new categories at
/// confirm time (deduped by name — never one per line). Shared by the Quick Add
/// page and the Ask Kuber preview so category creation happens in exactly one
/// place, only when the user commits. Returns the transactions to write; the
/// caller persists them atomically via `addMany`.
///
/// [source] is the `importSource` ('quick_add' | 'ask_kuber'). When
/// [sourceTextOverride] is set (Ask Kuber's original message) it is stored as
/// each transaction's `quickAddNote`; otherwise the per-line raw text is used.
Future<List<Transaction>> materializeDrafts(
  WidgetRef ref,
  List<QuickAddDraft> drafts, {
  required String source,
  String? sourceTextOverride,
}) async {
  final confirmable = drafts.where((d) => d.counts).toList();
  if (confirmable.isEmpty) return const [];

  final catNotifier = ref.read(categoryListProvider.notifier);
  var categories = ref.read(categoryListProvider).valueOrNull ?? const <Category>[];
  final createdByName = <String, int>{}; // normalized name -> id (this pass)

  Future<int?> ensureCategoryId(QuickAddDraft d) async {
    if (d.categoryId != null) return d.categoryId;
    final raw = (d.categoryHint ?? '').trim();
    final name = raw.isEmpty ? 'General' : raw.toTitleCase();
    final norm = normalizeText(name);
    if (createdByName.containsKey(norm)) return createdByName[norm];
    // It may already exist (a real category, or one created earlier this pass).
    final existing = matchCategory(name, categories, type: d.type);
    if (existing != null) {
      createdByName[norm] = existing.id;
      return existing.id;
    }
    final cat = Category()
      ..name = name
      ..icon = 'category'
      ..colorValue = 0xFF6B7280
      ..type = d.type == 'income' ? 'income' : 'expense';
    await catNotifier.add(cat);
    categories = await ref.read(categoryListProvider.future);
    final created = matchCategory(name, categories, type: d.type) ??
        categories
            .firstWhereOrNull((c) => c.name.toLowerCase() == name.toLowerCase());
    if (created != null) createdByName[norm] = created.id;
    return created?.id;
  }

  final now = DateTime.now();
  final txns = <Transaction>[];
  for (final d in confirmable) {
    final categoryId = await ensureCategoryId(d);
    if (categoryId == null || d.accountId == null || d.amount == null) continue;
    final name = (d.categoryHint?.trim().isNotEmpty ?? false)
        ? d.categoryHint!.toTitleCase()
        : (d.categoryName ?? 'Quick Add');
    txns.add(
      Transaction()
        ..name = name
        ..nameLower = name.toLowerCase()
        ..amount = d.amount!
        ..type = d.type
        ..categoryId = categoryId.toString()
        ..accountId = d.accountId!.toString()
        ..importSource = source
        ..quickAddNote = sourceTextOverride ?? d.rawText
        ..createdAt = now
        ..updatedAt = now,
    );
  }
  return txns;
}
