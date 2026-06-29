import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_service.dart';
import '../data/calculator_recent_use.dart';

/// Recently-used calculators, most recent first. Drives the "Recently used"
/// section on the Tools landing page (top 3).
final recentCalculatorsProvider =
    AsyncNotifierProvider<RecentUseNotifier, List<CalculatorRecentUse>>(
  RecentUseNotifier.new,
);

class RecentUseNotifier extends AsyncNotifier<List<CalculatorRecentUse>> {
  Isar get _isar => ref.read(isarProvider);

  @override
  FutureOr<List<CalculatorRecentUse>> build() async {
    return _isar.calculatorRecentUses.where().sortByLastUsedDesc().findAll();
  }

  /// Record that [calculatorType] was just opened: upsert the row, bump the
  /// use count and timestamp.
  Future<void> touch(String calculatorType) async {
    final existing = await _isar.calculatorRecentUses
        .filter()
        .calculatorTypeEqualTo(calculatorType)
        .findFirst();
    final row = existing ?? CalculatorRecentUse();
    row
      ..calculatorType = calculatorType
      ..lastUsed = DateTime.now()
      ..useCount = (existing?.useCount ?? 0) + 1;
    await _isar.writeTxn(() => _isar.calculatorRecentUses.put(row));
    ref.invalidateSelf();
  }
}

/// Top recently-used calculator route keys (max 5, most recent first).
final topRecentCalculatorsProvider = Provider<List<String>>((ref) {
  final list = ref.watch(recentCalculatorsProvider).valueOrNull ?? const [];
  return list.take(5).map((e) => e.calculatorType).toList();
});
