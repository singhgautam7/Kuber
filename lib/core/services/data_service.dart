import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../features/accounts/data/account.dart';
import '../../features/categories/data/category.dart';
import '../../features/transactions/data/transaction.dart';
import 'csv_service.dart';
import 'mock_data_generator.dart';
import '../database/isar_service.dart';
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

  /// Exports all data to a CSV and returns the file path.
  Future<String?> exportData() async {
    final transactions = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final accounts = await isar.accounts.where().findAll();

    final categoryNames = {for (var c in categories) c.id.toString(): c.name};
    final accountNames = {for (var a in accounts) a.id.toString(): a.name};

    final csvContent = _csvService.exportTransactions(
      transactions: transactions,
      categoryNames: categoryNames,
      accountNames: accountNames,
    );

    final timestamp = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());
    final fileName = 'kuber_export_$timestamp.csv';
    return await _saveFile(csvContent, fileName);
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

  /// Imports data from a CSV file.
  Future<ImportResult> importData(String csvContent) async {
    try {
      final rows = _csvService.parseCsv(csvContent);
      if (rows.isEmpty) return ImportResult(successCount: 0, failureCount: 0, error: 'Empty file');

      int success = 0;
      int failure = 0;

      // 1. Preload categories and accounts for name-to-id mapping
      final existingCategories = await isar.categorys.where().findAll();
      final existingAccounts = await isar.accounts.where().findAll();

      final categoryMap = {for (var c in existingCategories) c.name.toLowerCase(): c};
      final accountMap = {for (var a in existingAccounts) a.name.toLowerCase(): a};

      final List<Transaction> toInsert = [];

      for (final row in rows) {
        try {
          final dateStr = row['date'] ?? '';
          final name = row['name'] ?? 'Imported Transaction';
          final amount = double.tryParse(row['amount'] ?? '0') ?? 0.0;
          final type = (row['type']?.toLowerCase() ?? 'expense');
          final categoryName = row['category'] ?? 'Other';
          final accountName = row['account'] ?? 'Cash';
          final notes = row['notes'];
          final fromAccName = row['from_account'];
          final toAccName = row['to_account'];

          if (amount <= 0 && type != 'transfer') {
             failure++;
             continue;
          }

          // Resolve Category
          Category? category = categoryMap[categoryName.toLowerCase()];
          if (category == null && type != 'transfer') {
            category = Category()
              ..name = categoryName
              ..icon = 'category'
              ..colorValue = AppColorPalette.getRandomColor()
              ..type = type;
            await isar.writeTxn(() => isar.categorys.put(category!));
            categoryMap[categoryName.toLowerCase()] = category;
          } else if (category != null && category.colorValue == 0xFF90A4AE) {
             category.colorValue = AppColorPalette.getRandomColor();
             await isar.writeTxn(() => isar.categorys.put(category!));
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
            ..name = name
            ..nameLower = name.toLowerCase()
            ..amount = amount
            ..type = type
            ..categoryId = category?.id.toString() ?? ''
            ..accountId = account.id.toString()
            ..notes = notes
            ..createdAt = DateTime.tryParse(dateStr) ?? DateTime.now()
            ..updatedAt = DateTime.now();

          // Handle Transfer
          if (type == 'transfer' || (fromAccName != null && toAccName != null && fromAccName.isNotEmpty && toAccName.isNotEmpty)) {
            tx.type = 'transfer';
            
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

            tx.fromAccountId = fromAcc?.id.toString();
            tx.toAccountId = toAcc?.id.toString();
            tx.accountId = fromAcc?.id.toString() ?? account.id.toString(); // primary account is 'from'
          }

          toInsert.add(tx);
          success++;
        } catch (e) {
          debugPrint('Row import failed: $e');
          failure++;
        }
      }

      if (toInsert.isNotEmpty) {
        await isar.writeTxn(() => isar.transactions.putAll(toInsert));
      }

      return ImportResult(successCount: success, failureCount: failure);
    } catch (e) {
      return ImportResult(successCount: 0, failureCount: 0, error: e.toString());
    }
  }

  /// Generates mock data.
  Future<void> generateMockData() async {
    await MockDataGenerator(isar).generate();
  }

  /// Clears all data and re-seeds defaults.
  Future<void> clearAllData() async {
    await isar.writeTxn(() => isar.clear());
    await IsarService.seedIfNeeded(isar);
  }


}
