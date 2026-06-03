import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/stories/data/insight_story.dart';
import '../../features/transactions/services/suggestion_service.dart';
import '../../features/widget_editor/data/widget_preference.dart';
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

    // Migration 5: Backfill TransactionSuggestion from existing transactions
    if (!(prefs.getBool(PrefsKeys.migratedSuggestionBackfillV1) ?? false)) {
      await _backfillSuggestions(isar);
      await prefs.setBool(PrefsKeys.migratedSuggestionBackfillV1, true);
    }

    // Migration 6: Move insight_stories widget to position 1 (second from top)
    if (!(prefs.getBool(PrefsKeys.migratedStoriesPositionV2) ?? false)) {
      await _migrateStoriesPosition(isar);
      await prefs.setBool(PrefsKeys.migratedStoriesPositionV2, true);
    }

    // Migration 7: Wipe stories created by the older build. They used
    // non-uniform TTLs and had layout/grouping bugs; with a tiny user base the
    // cleanest path is to clear them so everyone regenerates fresh stories under
    // the new model (correct 48h TTL, grouping, comparisons).
    if (!(prefs.getBool(PrefsKeys.migratedStoryResetV1) ?? false)) {
      await _clearLegacyStories(isar);
      // Clear the once-per-day gate so fresh stories regenerate on this launch
      // even if the user already opened the app today before updating.
      await prefs.remove(PrefsKeys.lastStoryGenerationDate);
      await prefs.setBool(PrefsKeys.migratedStoryResetV1, true);
    }
  }

  static Future<void> _clearLegacyStories(Isar isar) async {
    await isar.writeTxn(() => isar.insightStorys.clear());
  }

  static Future<void> _backfillSuggestions(Isar isar) async {
    await SuggestionService(isar).rebuildAll();
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

  static Future<void> _migrateStoriesPosition(Isar isar) async {
    final rows = await isar.widgetPreferences
        .filter()
        .scopeEqualTo('home')
        .sortByOrder()
        .findAll();
    if (rows.isEmpty) return;
    final storyIndex = rows.indexWhere((w) => w.widgetKey == 'insight_stories');
    if (storyIndex == -1 || storyIndex == 1) return; // not found or already at 1
    final story = rows.removeAt(storyIndex);
    final insertAt = rows.isNotEmpty ? 1 : 0;
    rows.insert(insertAt, story);
    await isar.writeTxn(() async {
      for (int i = 0; i < rows.length; i++) {
        rows[i].order = i;
        await isar.widgetPreferences.put(rows[i]);
      }
    });
  }
}
