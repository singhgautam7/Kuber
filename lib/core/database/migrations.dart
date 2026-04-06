import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../utils/prefs_keys.dart';

class MigrationService {
  static Future<void> runAll(Isar isar) async {
    final prefs = await SharedPreferences.getInstance();

    // Migration 1: recurringRuleId/isRecurring → linkedRuleId/linkedRuleType
    if (!(prefs.getBool(PrefsKeys.migratedTxnLinkedRuleV1) ?? false)) {
      await _migrateRecurringToLinked(isar);
      await prefs.setBool(PrefsKeys.migratedTxnLinkedRuleV1, true);
    }

    // Migration 2: Seed "Lent / Borrow" system category for existing users
    if (!(prefs.getBool(PrefsKeys.migratedSeedLedgerCategoryV1) ?? false)) {
      await _seedLedgerCategory(isar);
      await prefs.setBool(PrefsKeys.migratedSeedLedgerCategoryV1, true);
    }

    // Migration 3: Seed "Loan EMI" and "Investment" system categories
    if (!(prefs.getBool(PrefsKeys.migratedSeedLoanInvestmentCategoryV1) ?? false)) {
      await _seedLoanInvestmentCategories(isar);
      await prefs.setBool(PrefsKeys.migratedSeedLoanInvestmentCategoryV1, true);
    }

    // Migration 4: Attachments field — Isar auto-initializes List<String> as empty
    if (!(prefs.getBool(PrefsKeys.migratedAttachmentsV1) ?? false)) {
      await prefs.setBool(PrefsKeys.migratedAttachmentsV1, true);
    }
  }

  static Future<void> _migrateRecurringToLinked(Isar isar) async {
    // After schema migration, old recurringRuleId data is inaccessible.
    // The recurring processor will correctly link new transactions going forward.
  }

  static Future<void> _seedLoanInvestmentCategories(Isar isar) async {
    final otherGroup = await isar.categoryGroups
        .filter()
        .nameEqualTo('OTHER')
        .findFirst();

    await isar.writeTxn(() async {
      // Loan EMI category
      final existingLoan = await isar.categorys
          .filter()
          .nameEqualTo('Loan EMI')
          .findFirst();
      if (existingLoan == null) {
        final cat = Category()
          ..name = 'Loan EMI'
          ..icon = 'account_balance'
          ..colorValue = 0xFF5C6BC0
          ..type = 'expense'
          ..isDefault = true
          ..groupId = otherGroup?.id;
        await isar.categorys.put(cat);
      }

      // Investment category
      final existingInv = await isar.categorys
          .filter()
          .nameEqualTo('Investment')
          .findFirst();
      if (existingInv == null) {
        final cat = Category()
          ..name = 'Investment'
          ..icon = 'show_chart'
          ..colorValue = 0xFF26A69A
          ..type = 'expense'
          ..isDefault = true
          ..groupId = otherGroup?.id;
        await isar.categorys.put(cat);
      }
    });
  }

  static Future<void> _seedLedgerCategory(Isar isar) async {
    // Check if "Lent / Borrow" category already exists
    final existing = await isar.categorys
        .filter()
        .nameEqualTo('Lent / Borrow')
        .findFirst();
    if (existing != null) return;

    // Find the OTHER group
    final otherGroup = await isar.categoryGroups
        .filter()
        .nameEqualTo('OTHER')
        .findFirst();

    await isar.writeTxn(() async {
      final cat = Category()
        ..name = 'Lent / Borrow'
        ..icon = 'handshake'
        ..colorValue = 0xFF78909C
        ..type = 'both'
        ..isDefault = true
        ..groupId = otherGroup?.id;
      await isar.categorys.put(cat);
    });
  }
}
