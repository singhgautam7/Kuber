import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import 'csv_service.dart';
import 'json_backup_service.dart';
import 'mock_data_service.dart';
import '../database/seed_service.dart';
import '../utils/color_palette.dart';


class ImportResult {
  final int successCount;
  final int failureCount;
  final String? error;

  ImportResult({
    required this.successCount,
    required this.failureCount,
    this.error,
  });
}

class DataService {
  final Isar isar;
  final CsvService _csvService = CsvService();

  DataService(this.isar);

  /// Exports all data to a single CSV string.
  Future<Map<String, String>> exportData() async {
    final transactions = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final accounts = await isar.accounts.where().findAll();
    final tags = await isar.tags.where().findAll();
    final transactionTags = await isar.transactionTags.where().findAll();
    final groups = await isar.categoryGroups.where().findAll();

    final categoryNames = {for (var c in categories) c.id.toString(): c.name};
    final accountNames = {for (var a in accounts) a.id.toString(): a.name};
    final groupNameMap = {for (var g in groups) g.id: g.name};
    final categoryToGroupName = {
      for (var c in categories)
        if (c.groupId != null) c.id.toString(): groupNameMap[c.groupId] ?? ''
    };
    final tagNameMap = {for (var t in tags) t.id: t.name};

    final Map<int, List<String>> txTagsMap = {};
    for (var bridge in transactionTags) {
      final name = tagNameMap[bridge.tagId];
      if (name != null) {
        txTagsMap.putIfAbsent(bridge.transactionId, () => []).add(name);
      }
    }

    final csvContent = _csvService.exportTransactions(
      transactions: transactions,
      categoryNames: categoryNames,
      accountNames: accountNames,
      groupNames: categoryToGroupName,
      transactionTags: txTagsMap,
    );

    return {'transactions.csv': csvContent};
  }

  /// Downloads the CSV template and returns the file path.
  Future<String?> downloadTemplate() async {
    final template = _csvService.generateTemplate();
    const fileName = 'kuber_template.csv';
    return await _saveFile(template, fileName);
  }

  Future<String?> _saveFile(String content, String fileName) async {
    // Option A (Preferred): Save to app-specific directory (no permission required)
    // We'll use the external storage directory if available (visible in Files app on some Androids)
    // or fallback to application documents.
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      // Ensure directory exists
      if (!await directory.exists()) {
        try {
          await directory.create(recursive: true);
        } catch (e) {
          debugPrint('DataService: Failed to create Download directory: $e');
        }
      }
    } else {
      directory = await getDownloadsDirectory();
    }
    
    directory ??= await getExternalStorageDirectory();
    directory ??= await getApplicationDocumentsDirectory();
    
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    debugPrint('DataService: File saved to ${file.path}');
    return file.path;
  }

  /// Parses CSV content into a list of maps.
  List<Map<String, String>> parseCsv(String csvContent) {
    if (csvContent.isEmpty) return [];
    
    final List<List<dynamic>> rows = Csv(dynamicTyping: false).decode(csvContent);
    
    if (rows.isEmpty) return [];

    final List<String> headers = rows.first.map((e) => e.toString().trim()).toList();
    final List<Map<String, String>> parsedRows = [];

    for (int i = 1; i < rows.length; i++) {
      final Map<String, String> rowMap = {};
      for (int j = 0; j < headers.length; j++) {
        if (j < rows[i].length) {
          rowMap[headers[j]] = rows[i][j]?.toString().trim() ?? '';
        } else {
          rowMap[headers[j]] = ''; // Handle cases where a row has fewer columns than headers
        }
      }
      parsedRows.add(rowMap);
    }
    return parsedRows;
  }

  /// Imports data from a CSV file. If [override] is true, clears all data first.
  Future<ImportResult> importData(String csvContent, {bool override = false}) async {
    try {
      final rows = parseCsv(csvContent);
      if (rows.isEmpty) return ImportResult(successCount: 0, failureCount: 0, error: 'Empty file');

      if (override) {
        await isar.writeTxn(() => isar.clear());
        await SeedService().seedInitialData(isar);
      }

      return await _importTransactions(rows);
    } catch (e) {
      return ImportResult(successCount: 0, failureCount: 0, error: e.toString());
    }
  }

  /// Exports all data as a JSON backup string.
  Future<String> exportJson() async {
    return JsonBackupService().exportJson(isar);
  }

  /// Imports data from a JSON backup string (clears all existing data).
  Future<ImportResult> importJson(String jsonContent) async {
    return JsonBackupService().importJson(isar, jsonContent);
  }


  Future<ImportResult> _importTransactions(List<Map<String, String>> rows) async {
    int success = 0;
    int failure = 0;

    // 1. Preload categories and accounts for name-to-id mapping
    final existingCategories = await isar.categorys.where().findAll();
    final existingAccounts = await isar.accounts.where().findAll();
    final existingGroups = await isar.categoryGroups.where().findAll();

    final categoryMap = {for (var c in existingCategories) c.name.toLowerCase(): c};
    final accountMap = {for (var a in existingAccounts) a.name.toLowerCase(): a};
    final groupMap = {for (var g in existingGroups) g.name.toLowerCase(): g};

    final List<Transaction> toInsert = [];

    // Preload tags to minimize queries (optional, but keep it simple for now)

    for (final row in rows) {
      try {
        final dateStr = row['date'] ?? '';
        final name = row['name'] ?? 'Imported Transaction';
        final amount = double.tryParse(row['amount'] ?? '0') ?? 0.0;
        final type = (row['type']?.toLowerCase() ?? 'expense');
        final categoryName = row['category'] ?? 'Other';
        final groupNameRaw = row['group'] ?? '';
        final groupNameNormalized = groupNameRaw.trim().replaceAll(RegExp(r'\s+'), ' ');
        // Enforce 15 char limit during import as well
        final groupName = groupNameNormalized.length > 15 
            ? groupNameNormalized.substring(0, 15).trim() 
            : groupNameNormalized;

        final accountName = row['account'] ?? 'Cash';
        final notes = row['notes'];
        final fromAccName = row['from_account'];
        final toAccName = row['to_account'];

        if (amount <= 0 && type != 'transfer') {
           failure++;
           continue;
        }

        // Resolve Group
        CategoryGroup? group;
        if (groupName.isNotEmpty) {
           group = groupMap[groupName.toLowerCase()];
           if (group == null) {
              group = CategoryGroup()..name = groupName;
              await isar.writeTxn(() => isar.categoryGroups.put(group!));
              groupMap[groupName.toLowerCase()] = group;
           }
        }

        // Resolve Category
        Category? category = categoryMap[categoryName.toLowerCase()];
        if (category == null && type != 'transfer') {
          category = Category()
            ..name = categoryName
            ..icon = 'category'
            ..colorValue = AppColorPalette.getRandomColor()
            ..type = type
            ..groupId = group?.id;
          await isar.writeTxn(() => isar.categorys.put(category!));
          categoryMap[categoryName.toLowerCase()] = category;
        } else if (category != null) {
           bool updated = false;
           if (category.colorValue == 0xFF90A4AE) {
              category.colorValue = AppColorPalette.getRandomColor();
              updated = true;
           }
           if (group != null && category.groupId == null) {
              category.groupId = group.id;
              updated = true;
           }
           if (updated) {
              await isar.writeTxn(() => isar.categorys.put(category!));
           }
        }

        // Resolve Account
        Account? account = accountMap[accountName.toLowerCase()];
        if (account == null) {
          final isCC = accountName.toLowerCase().contains('credit');
          account = Account()
            ..name = accountName
            ..type = 'bank' // default type
            ..isCreditCard = isCC
            ..icon = isCC ? 'credit_card' : 'account_balance'
            ..colorValue = AppColorPalette.getRandomColor();
          await isar.writeTxn(() => isar.accounts.put(account!));
          accountMap[accountName.toLowerCase()] = account;
        } else if (account.colorValue == null) {
           account.colorValue = AppColorPalette.getRandomColor();
           await isar.writeTxn(() => isar.accounts.put(account!));
        }

        final tx = Transaction()
          ..id = int.tryParse(row['id'] ?? '') ?? Isar.autoIncrement
          ..name = name
          ..nameLower = name.toLowerCase()
          ..amount = amount
          ..type = type
          ..categoryId = category?.id.toString() ?? ''
          ..accountId = account.id.toString()
          ..notes = notes

          ..createdAt = DateTime.tryParse(dateStr) ?? DateTime.now()
          ..updatedAt = DateTime.now();
        
        // Temporarily store tags for post-save mapping
        tx.tempTags = row['tags'];

        // Handle Transfer — create two linked legs
        if (type == 'transfer' || (fromAccName != null && toAccName != null && fromAccName.isNotEmpty && toAccName.isNotEmpty)) {
          Account? fromAcc = accountMap[fromAccName?.toLowerCase()];
          if (fromAcc == null && fromAccName != null && fromAccName.isNotEmpty) {
             fromAcc = Account()
               ..name = fromAccName
               ..type = 'bank'
               ..isCreditCard = fromAccName.toLowerCase().contains('credit')
               ..icon = 'account_balance'
               ..colorValue = AppColorPalette.getRandomColor();
             await isar.writeTxn(() => isar.accounts.put(fromAcc!));
             accountMap[fromAccName.toLowerCase()] = fromAcc;
          } else if (fromAcc != null && fromAcc.colorValue == null) {
             fromAcc.colorValue = AppColorPalette.getRandomColor();
             await isar.writeTxn(() => isar.accounts.put(fromAcc!));
          }

          Account? toAcc = accountMap[toAccName?.toLowerCase()];
          if (toAcc == null && toAccName != null && toAccName.isNotEmpty) {
             toAcc = Account()
               ..name = toAccName
               ..type = 'bank'
               ..isCreditCard = toAccName.toLowerCase().contains('credit')
               ..icon = 'account_balance'
               ..colorValue = AppColorPalette.getRandomColor();
             await isar.writeTxn(() => isar.accounts.put(toAcc!));
             accountMap[toAccName.toLowerCase()] = toAcc;
          } else if (toAcc != null && toAcc.colorValue == null) {
             toAcc.colorValue = AppColorPalette.getRandomColor();
             await isar.writeTxn(() => isar.accounts.put(toAcc!));
          }

          final transferId = DateTime.now().millisecondsSinceEpoch.toString();
          final createdAt = DateTime.tryParse(dateStr) ?? DateTime.now();

          // Expense leg (FROM)
          tx.type = 'expense';
          tx.accountId = fromAcc?.id.toString() ?? account.id.toString();
          tx.categoryId = '';
          tx.isTransfer = true;
          tx.transferId = transferId;
          toInsert.add(tx);

          // Income leg (TO)
          final toTx = Transaction()
            ..id = Isar.autoIncrement
            ..name = name
            ..nameLower = name.toLowerCase()
            ..amount = amount
            ..type = 'income'
            ..categoryId = ''
            ..accountId = toAcc?.id.toString() ?? account.id.toString()
            ..isTransfer = true
            ..transferId = transferId
            ..notes = notes
  
            ..createdAt = createdAt
            ..updatedAt = DateTime.now();
          toInsert.add(toTx);
        } else {
          toInsert.add(tx);
        }
        success++;
      } catch (e) {
        debugPrint('Row import failed: $e');
        failure++;
      }
    }

    if (toInsert.isNotEmpty) {
      await isar.writeTxn(() async {
        for (final tx in toInsert) {
          await isar.transactions.put(tx);
          
          // Process Tags
          final tagsStr = tx.tempTags; // I'll add a temp field or use row mapping
          if (tagsStr != null && tagsStr.isNotEmpty) {
             final tagNames = tagsStr.split('|').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
             for (final rawName in tagNames) {
                final normalized = Tag.normalize(rawName);
                if (normalized.isEmpty) continue;
                
                // Find or create tag
                var tag = await isar.tags.filter().nameEqualTo(normalized).findFirst();
                if (tag == null) {
                  tag = Tag()
                    ..name = normalized
                    ..createdAt = DateTime.now();
                  await isar.tags.put(tag);
                }
                
                // Link
                final existingMapping = await isar.transactionTags
                  .filter()
                  .transactionIdEqualTo(tx.id)
                  .tagIdEqualTo(tag.id)
                  .findFirst();
                  
                if (existingMapping == null) {
                  await isar.transactionTags.put(TransactionTag()
                    ..transactionId = tx.id
                    ..tagId = tag.id);
                }
             }
          }
        }
      });
    }

    return ImportResult(successCount: success, failureCount: failure);
  }

  /// Generates mock data.
  Future<void> generateMockData() async {
    await MockDataService.generate(isar);
  }

  /// Clears all data and re-seeds defaults.
  Future<void> clearAllData() async {
    await isar.writeTxn(() => isar.clear());
    await SeedService().seedInitialData(isar);
  }


}
