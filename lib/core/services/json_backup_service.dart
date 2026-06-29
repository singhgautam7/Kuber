import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:isar_community/isar.dart';

import '../../features/accounts/data/account.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/investments/data/investment.dart';
import '../../features/ledger/data/ledger.dart';
import '../../features/loans/data/loan.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/stories/data/insight_story.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/tools/bill_splitter/data/bill.dart';
import '../../features/tools/bill_splitter/data/person.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/data/transaction_suggestion.dart';
import '../../features/widget_editor/data/widget_preference.dart';
import '../../features/backups/services/backup_rotation.dart';
import '../../features/backups/services/saf_backup_store.dart';
import '../../features/backups/data/backup_config.dart';
import '../../features/ask_kuber/data/ask_kuber_message.dart';
import '../../features/sms_import/data/sms_transaction.dart';
import '../../features/sms_import/data/sms_account_mapping.dart';
import '../../features/tools/saved/data/saved_calculation.dart';
import '../../features/tools/saved/data/calculator_recent_use.dart';
import 'data_service.dart';

/// Top-level so it can run on a background isolate via [compute].
String _encodeBackupData(Map<String, dynamic> data) => jsonEncode(data);

/// Reports import progress: `(collectionLabel, recordsDone, recordsTotal)`.
typedef ImportProgressCallback = void Function(
    String label, int current, int total);

class JsonBackupService {
  static const _version = 1;

  Future<String> writeScheduledBackup({
    required Isar isar,
    required String folderUri,
    required int retention,
    DateTime? now,
    SafBackupStore? store,
  }) async {
    final at = now ?? DateTime.now();
    final targetStore = store ?? SafBackupStore();
    final json = await exportJson(isar);
    final fileName = _backupFileName(at);
    await targetStore.writeText(
      folderUri: folderUri,
      fileName: fileName,
      contents: json,
    );
    final names = await targetStore.listFileNames(folderUri);
    final toDelete = pruneBackupFileNames(names, retention: retention);
    for (final name in toDelete) {
      try {
        await targetStore.deleteFile(folderUri: folderUri, fileName: name);
      } catch (_) {
        // Rotation cleanup is best-effort. A failed delete must not mark the
        // backup write itself as failed.
      }
    }
    return fileName;
  }

  String _backupFileName(DateTime at) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'kuber_backup_${at.year}-${two(at.month)}-${two(at.day)}_'
        '${two(at.hour)}${two(at.minute)}.json';
  }

  Future<String> exportJson(Isar isar) async {
    final transactions = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final categoryGroups = await isar.categoryGroups.where().findAll();
    final accounts = await isar.accounts.where().findAll();
    final tags = await isar.tags.where().findAll();
    final transactionTags = await isar.transactionTags.where().findAll();
    final recurringRules = await isar.recurringRules.where().findAll();
    final budgets = await isar.budgets.where().findAll();
    final ledgers = await isar.ledgers.where().findAll();
    final loans = await isar.loans.where().findAll();
    final investments = await isar.investments.where().findAll();
    final suggestions = await isar.transactionSuggestions.where().findAll();
    final people = await isar.persons.where().findAll();
    final bills = await isar.bills.where().findAll();
    final notifications = await isar.appNotifications.where().findAll();
    final widgetPreferences = await isar.widgetPreferences.where().findAll();
    final stories = await isar.insightStorys.where().findAll();
    final backupConfigs = await isar.backupConfigs.where().findAll();
    final savedCalculations = await isar.savedCalculations.where().findAll();
    final recentUses = await isar.calculatorRecentUses.where().findAll();
    final askKuberMessages = await isar.askKuberMessages.where().findAll();
    final smsTransactions = await isar.smsTransactions.where().findAll();
    final smsAccountMappings = await isar.smsAccountMappings.where().findAll();

    final data = {
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'transactions': transactions.map(_txToMap).toList(),
      'categories': categories.map(_catToMap).toList(),
      'categoryGroups': categoryGroups.map(_groupToMap).toList(),
      'accounts': accounts.map(_accountToMap).toList(),
      'tags': tags.map(_tagToMap).toList(),
      'transactionTags': transactionTags.map(_txTagToMap).toList(),
      'recurringRules': recurringRules.map(_recurringToMap).toList(),
      'budgets': budgets.map(_budgetToMap).toList(),
      'ledgers': ledgers.map(_ledgerToMap).toList(),
      'loans': loans.map(_loanToMap).toList(),
      'investments': investments.map(_investmentToMap).toList(),
      'transactionSuggestions': suggestions.map((s) => s.toMap()).toList(),
      'people': people.map((p) => p.toMap()).toList(),
      'bills': bills.map((b) => b.toMap()).toList(),
      'appNotifications': notifications.map((n) => n.toMap()).toList(),
      'widgetPreferences': widgetPreferences.map((w) => w.toMap()).toList(),
      'insightStories': stories.map((s) => s.toMap()).toList(),
      'backupConfigs': backupConfigs.map((b) => b.toMap()).toList(),
      'savedCalculations': savedCalculations.map((s) => s.toMap()).toList(),
      'calculatorRecentUses': recentUses.map((r) => r.toMap()).toList(),
      'askKuberMessages': askKuberMessages.map((a) => a.toMap()).toList(),
      'smsTransactions': smsTransactions.map((s) => s.toMap()).toList(),
      'smsAccountMappings': smsAccountMappings.map((s) => s.toMap()).toList(),
    };

    // Encoding the whole database into one string is the heaviest part of a
    // backup. Run it on a background isolate so a multi-MB export never stalls
    // the UI thread (the data map is plain primitives, so it copies cleanly).
    // On web, where there are no isolates, compute runs inline and this is a
    // no-op — still correct, just not offloaded.
    return compute(_encodeBackupData, data);
  }

  Future<ImportResult> importJson(
    Isar isar,
    String jsonContent, {
    ImportProgressCallback? onProgress,
  }) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;

      await isar.writeTxn(() => isar.clear());

      var count = 0;

      // Restores one collection using chunked bulk inserts. Each chunk is its
      // own write transaction: `putAll` is far faster than per-record `put`,
      // and the await boundary between chunks lets the import overlay repaint
      // with live "<done>/<total> <label>" progress (a single mega-transaction
      // never yields a frame, so the indicator would otherwise freeze).
      Future<void> restore<T>(
        String key,
        String label,
        IsarCollection<T> collection,
        T Function(Map<String, dynamic>) fromMap,
      ) async {
        final list = _list(data, key);
        final total = list.length;
        if (total == 0) return;
        const chunkSize = 500;
        onProgress?.call(label, 0, total);
        for (var start = 0; start < total; start += chunkSize) {
          final end = start + chunkSize < total ? start + chunkSize : total;
          final batch = [
            for (var i = start; i < end; i++) fromMap(list[i]),
          ];
          await isar.writeTxn(() => collection.putAll(batch));
          count += batch.length;
          onProgress?.call(label, end, total);
        }
      }

      await restore('categoryGroups', 'category groups', isar.categoryGroups,
          _mapToGroup);
      await restore('categories', 'categories', isar.categorys, _mapToCat);
      await restore('accounts', 'accounts', isar.accounts, _mapToAccount);
      await restore('tags', 'tags', isar.tags, _mapToTag);
      await restore(
          'transactions', 'transactions', isar.transactions, _mapToTx);
      await restore('transactionTags', 'transaction tags', isar.transactionTags,
          _mapToTxTag);
      await restore('recurringRules', 'recurring rules', isar.recurringRules,
          _mapToRecurring);
      await restore('budgets', 'budgets', isar.budgets, _mapToBudget);
      await restore('ledgers', 'ledger entries', isar.ledgers, _mapToLedger);
      await restore('loans', 'loans', isar.loans, _mapToLoan);
      await restore(
          'investments', 'investments', isar.investments, _mapToInvestment);
      await restore('savedCalculations', 'saved calculations',
          isar.savedCalculations, _mapToSavedCalculation);
      await restore('calculatorRecentUses', 'recent calculators',
          isar.calculatorRecentUses, _mapToRecentUse);
      await restore('askKuberMessages', 'chat history', isar.askKuberMessages,
          _mapToAskKuberMessage);
      await restore('smsAccountMappings', 'SMS mappings',
          isar.smsAccountMappings, _mapToSmsAccountMapping);
      await restore('smsTransactions', 'SMS transactions', isar.smsTransactions,
          _mapToSmsTransaction);

      return ImportResult(successCount: count, failureCount: 0);
    } catch (e) {
      return ImportResult(
        successCount: 0,
        failureCount: 0,
        error: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> _list(Map<String, dynamic> data, String key) {
    final raw = data[key];
    if (raw == null) return [];
    return (raw as List).cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Serializers
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _txToMap(Transaction t) => {
    'id': t.id,
    'name': t.name,
    'amount': t.amount,
    'type': t.type,
    'categoryId': t.categoryId,
    'accountId': t.accountId,
    'notes': t.notes,
    'quickAddNote': t.quickAddNote,
    'linkedRuleId': t.linkedRuleId,
    'linkedRuleType': t.linkedRuleType,
    'isBalanceAdjustment': t.isBalanceAdjustment,
    'isTransfer': t.isTransfer,
    'transferId': t.transferId,
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
    'nameLower': t.nameLower,
    'attachmentPaths': t.attachmentPaths,
  };

  Map<String, dynamic> _catToMap(Category c) => {
    'id': c.id,
    'name': c.name,
    'icon': c.icon,
    'colorValue': c.colorValue,
    'isDefault': c.isDefault,
    'type': c.type,
    'groupId': c.groupId,
  };

  Map<String, dynamic> _groupToMap(CategoryGroup g) => {
    'id': g.id,
    'name': g.name,
  };

  Map<String, dynamic> _accountToMap(Account a) => {
    'id': a.id,
    'name': a.name,
    'type': a.type,
    'initialBalance': a.initialBalance,
    'creditLimit': a.creditLimit,
    'isCreditCard': a.isCreditCard,
    'icon': a.icon,
    'colorValue': a.colorValue,
    'last4Digits': a.last4Digits,
    'isDisabled': a.isDisabled,
  };

  Map<String, dynamic> _tagToMap(Tag t) => {
    'id': t.id,
    'name': t.name,
    'isEnabled': t.isEnabled,
    'createdAt': t.createdAt.toIso8601String(),
  };

  Map<String, dynamic> _txTagToMap(TransactionTag tt) => {
    'id': tt.id,
    'transactionId': tt.transactionId,
    'tagId': tt.tagId,
  };

  Map<String, dynamic> _recurringToMap(RecurringRule r) => {
    'id': r.id,
    'name': r.name,
    'amount': r.amount,
    'type': r.type,
    'categoryId': r.categoryId,
    'accountId': r.accountId,
    'notes': r.notes,
    'frequency': r.frequency,
    'customDays': r.customDays,
    'startDate': r.startDate.toIso8601String(),
    'nextDueAt': r.nextDueAt.toIso8601String(),
    'executionCount': r.executionCount,
    'endType': r.endType,
    'endAfter': r.endAfter,
    'endDate': r.endDate?.toIso8601String(),
    'isPaused': r.isPaused,
    'createdAt': r.createdAt.toIso8601String(),
    'updatedAt': r.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _budgetToMap(Budget b) => {
    'id': b.id,
    'categoryId': b.categoryId,
    'amount': b.amount,
    'periodType': b.periodType.name,
    'startDate': b.startDate.toIso8601String(),
    'endDate': b.endDate?.toIso8601String(),
    'isRecurring': b.isRecurring,
    'anchorDay': b.anchorDay,
    'durationDays': b.durationDays,
    'isActive': b.isActive,
    'lastEvaluatedAt': b.lastEvaluatedAt?.toIso8601String(),
    'createdAt': b.createdAt.toIso8601String(),
    'updatedAt': b.updatedAt.toIso8601String(),
    'alerts': b.alerts
        .map(
          (a) => {
            'type': a.type.name,
            'value': a.value,
            'isTriggered': a.isTriggered,
            'enableNotification': a.enableNotification,
            'createdAt': a.createdAt.toIso8601String(),
          },
        )
        .toList(),
  };

  Map<String, dynamic> _ledgerToMap(Ledger l) => {
    'id': l.id,
    'uid': l.uid,
    'personName': l.personName,
    'personNameLower': l.personNameLower,
    'type': l.type,
    'originalAmount': l.originalAmount,
    'accountId': l.accountId,
    'categoryId': l.categoryId,
    'notes': l.notes,
    'expectedDate': l.expectedDate?.toIso8601String(),
    'isSettled': l.isSettled,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _loanToMap(Loan l) => {
    'id': l.id,
    'uid': l.uid,
    'name': l.name,
    'loanType': l.loanType,
    'lenderName': l.lenderName,
    'referenceNumber': l.referenceNumber,
    'principalAmount': l.principalAmount,
    'emiAmount': l.emiAmount,
    'rateType': l.rateType,
    'interestRate': l.interestRate,
    'loanStartDate': l.loanStartDate?.toIso8601String(),
    'billDate': l.billDate,
    'startDate': l.startDate.toIso8601String(),
    'endDate': l.endDate?.toIso8601String(),
    'autoAddTransaction': l.autoAddTransaction,
    'accountId': l.accountId,
    'categoryId': l.categoryId,
    'notes': l.notes,
    'isCompleted': l.isCompleted,
    'createdAt': l.createdAt.toIso8601String(),
    'updatedAt': l.updatedAt.toIso8601String(),
  };

  Map<String, dynamic> _investmentToMap(Investment i) => {
    'id': i.id,
    'uid': i.uid,
    'name': i.name,
    'investmentType': i.investmentType,
    'currentValue': i.currentValue,
    'investedAmount': i.investedAmount,
    'autoDebit': i.autoDebit,
    'sipAmount': i.sipAmount,
    'sipDate': i.sipDate,
    'accountId': i.accountId,
    'categoryId': i.categoryId,
    'notes': i.notes,
    'createdAt': i.createdAt.toIso8601String(),
    'updatedAt': i.updatedAt.toIso8601String(),
  };

  // ---------------------------------------------------------------------------
  // Deserializers
  // ---------------------------------------------------------------------------

  Transaction _mapToTx(Map<String, dynamic> m) => Transaction()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..amount = (m['amount'] as num).toDouble()
    ..type = m['type'] as String
    ..categoryId = m['categoryId'] as String
    ..accountId = m['accountId'] as String
    ..notes = m['notes'] as String?
    ..quickAddNote = m['quickAddNote'] as String?
    ..linkedRuleId = m['linkedRuleId'] as String?
    ..linkedRuleType = m['linkedRuleType'] as String?
    ..isBalanceAdjustment = (m['isBalanceAdjustment'] as bool?) ?? false
    ..isTransfer = (m['isTransfer'] as bool?) ?? false
    ..transferId = m['transferId'] as String?
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String)
    ..nameLower = m['nameLower'] as String
    ..attachmentPaths = (m['attachmentPaths'] as List?)?.cast<String>() ?? [];

  Category _mapToCat(Map<String, dynamic> m) => Category()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..icon = m['icon'] as String
    ..colorValue = m['colorValue'] as int
    ..isDefault = (m['isDefault'] as bool?) ?? false
    ..type = (m['type'] as String?) ?? 'both'
    ..groupId = m['groupId'] as int?;

  CategoryGroup _mapToGroup(Map<String, dynamic> m) => CategoryGroup()
    ..id = m['id'] as int
    ..name = m['name'] as String;

  Account _mapToAccount(Map<String, dynamic> m) => Account()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..type = m['type'] as String
    ..initialBalance = (m['initialBalance'] as num?)?.toDouble() ?? 0.0
    ..creditLimit = (m['creditLimit'] as num?)?.toDouble()
    ..isCreditCard = (m['isCreditCard'] as bool?) ?? false
    ..icon = m['icon'] as String?
    ..colorValue = m['colorValue'] as int?
    ..last4Digits = m['last4Digits'] as String?
    ..isDisabled = (m['isDisabled'] as bool?) ?? false;

  Tag _mapToTag(Map<String, dynamic> m) => Tag()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..isEnabled = (m['isEnabled'] as bool?) ?? true
    ..createdAt = DateTime.parse(m['createdAt'] as String);

  TransactionTag _mapToTxTag(Map<String, dynamic> m) => TransactionTag()
    ..id = m['id'] as int
    ..transactionId = m['transactionId'] as int
    ..tagId = m['tagId'] as int;

  RecurringRule _mapToRecurring(Map<String, dynamic> m) => RecurringRule()
    ..id = m['id'] as int
    ..name = m['name'] as String
    ..amount = (m['amount'] as num).toDouble()
    ..type = m['type'] as String
    ..categoryId = m['categoryId'] as String
    ..accountId = m['accountId'] as String
    ..notes = m['notes'] as String?
    ..frequency = m['frequency'] as String
    ..customDays = m['customDays'] as int?
    ..startDate = DateTime.parse(m['startDate'] as String)
    ..nextDueAt = DateTime.parse(m['nextDueAt'] as String)
    ..executionCount = (m['executionCount'] as int?) ?? 0
    ..endType = m['endType'] as String
    ..endAfter = m['endAfter'] as int?
    ..endDate = m['endDate'] != null
        ? DateTime.parse(m['endDate'] as String)
        : null
    ..isPaused = (m['isPaused'] as bool?) ?? false
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String);

  Budget _mapToBudget(Map<String, dynamic> m) {
    final b = Budget()
      ..id = m['id'] as int
      ..categoryId = m['categoryId'] as String
      ..amount = (m['amount'] as num).toDouble()
      ..periodType = BudgetPeriodType.values.firstWhere(
        (e) => e.name == m['periodType'],
        orElse: () => BudgetPeriodType.monthly,
      )
      ..startDate = DateTime.parse(m['startDate'] as String)
      ..endDate = m['endDate'] != null
          ? DateTime.parse(m['endDate'] as String)
          : null
      ..isRecurring = (m['isRecurring'] as bool?) ?? true
      ..anchorDay = m['anchorDay'] as int?
      ..durationDays = m['durationDays'] as int?
      ..isActive = (m['isActive'] as bool?) ?? true
      ..lastEvaluatedAt = m['lastEvaluatedAt'] != null
          ? DateTime.parse(m['lastEvaluatedAt'] as String)
          : null
      ..createdAt = DateTime.parse(m['createdAt'] as String)
      ..updatedAt = DateTime.parse(m['updatedAt'] as String);
    final alertList = m['alerts'] as List?;
    if (alertList != null) {
      b.alerts = alertList.map((a) {
        final am = a as Map<String, dynamic>;
        return BudgetAlert()
          ..type = BudgetAlertType.values.firstWhere(
            (e) => e.name == am['type'],
            orElse: () => BudgetAlertType.percentage,
          )
          ..value = (am['value'] as num).toDouble()
          ..isTriggered = (am['isTriggered'] as bool?) ?? false
          ..enableNotification = (am['enableNotification'] as bool?) ?? true
          ..createdAt = am['createdAt'] != null
              ? DateTime.parse(am['createdAt'] as String)
              : DateTime.now();
      }).toList();
    }
    return b;
  }

  Ledger _mapToLedger(Map<String, dynamic> m) => Ledger()
    ..id = m['id'] as int
    ..uid = m['uid'] as String
    ..personName = m['personName'] as String
    ..personNameLower = m['personNameLower'] as String
    ..type = m['type'] as String
    ..originalAmount = (m['originalAmount'] as num).toDouble()
    ..accountId = m['accountId'] as String
    ..categoryId = m['categoryId'] as String
    ..notes = m['notes'] as String?
    ..expectedDate = m['expectedDate'] != null
        ? DateTime.parse(m['expectedDate'] as String)
        : null
    ..isSettled = (m['isSettled'] as bool?) ?? false
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String);

  Loan _mapToLoan(Map<String, dynamic> m) => Loan()
    ..id = m['id'] as int
    ..uid = m['uid'] as String
    ..name = m['name'] as String
    ..loanType = m['loanType'] as String
    ..lenderName = m['lenderName'] as String
    ..referenceNumber = m['referenceNumber'] as String?
    ..principalAmount = (m['principalAmount'] as num).toDouble()
    ..emiAmount = (m['emiAmount'] as num).toDouble()
    ..rateType = m['rateType'] as String?
    ..interestRate = (m['interestRate'] as num?)?.toDouble()
    ..loanStartDate = m['loanStartDate'] != null
        ? DateTime.parse(m['loanStartDate'] as String)
        : null
    ..billDate = m['billDate'] as int
    ..startDate = DateTime.parse(m['startDate'] as String)
    ..endDate = m['endDate'] != null
        ? DateTime.parse(m['endDate'] as String)
        : null
    ..autoAddTransaction = (m['autoAddTransaction'] as bool?) ?? false
    ..accountId = m['accountId'] as String
    ..categoryId = m['categoryId'] as String
    ..notes = m['notes'] as String?
    ..isCompleted = (m['isCompleted'] as bool?) ?? false
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String);

  Investment _mapToInvestment(Map<String, dynamic> m) => Investment()
    ..id = m['id'] as int
    ..uid = m['uid'] as String
    ..name = m['name'] as String
    ..investmentType = m['investmentType'] as String
    ..currentValue = (m['currentValue'] as num?)?.toDouble()
    ..investedAmount = (m['investedAmount'] as num?)?.toDouble()
    ..autoDebit = (m['autoDebit'] as bool?) ?? false
    ..sipAmount = (m['sipAmount'] as num?)?.toDouble()
    ..sipDate = m['sipDate'] as int?
    ..accountId = m['accountId'] as String?
    ..categoryId = m['categoryId'] as String
    ..notes = m['notes'] as String?
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String);

  SavedCalculation _mapToSavedCalculation(Map<String, dynamic> m) =>
      SavedCalculation()
        ..id = m['id'] as int
        ..tool = m['tool'] as String
        ..name = m['name'] as String
        ..inputsJson = m['inputsJson'] as String
        ..summary = m['summary'] as String
        ..savedAt = DateTime.parse(m['savedAt'] as String)
        ..updatedAt = DateTime.parse(m['updatedAt'] as String);

  CalculatorRecentUse _mapToRecentUse(Map<String, dynamic> m) =>
      CalculatorRecentUse()
        ..id = m['id'] as int
        ..calculatorType = m['calculatorType'] as String
        ..lastUsed = DateTime.parse(m['lastUsed'] as String)
        ..useCount = (m['useCount'] as int?) ?? 0;

  AskKuberMessage _mapToAskKuberMessage(Map<String, dynamic> m) =>
      AskKuberMessage()
        ..id = m['id'] as int
        ..text = m['text'] as String
        ..isUser = m['isUser'] as bool
        ..time = DateTime.parse(m['time'] as String)
        ..thinkingJson = m['thinkingJson'] as String?
        ..vizJson = m['vizJson'] as String?
        ..metadataJson = m['metadataJson'] as String?;

  SmsAccountMapping _mapToSmsAccountMapping(Map<String, dynamic> m) =>
      SmsAccountMapping()
        ..id = m['id'] as int
        ..senderId = m['senderId'] as String
        ..accountId = m['accountId'] as String
        ..usageCount = (m['usageCount'] as int?) ?? 0
        ..lastUsed = DateTime.parse(m['lastUsed'] as String);

  SmsTransaction _mapToSmsTransaction(Map<String, dynamic> m) => SmsTransaction()
    ..id = m['id'] as int
    ..rawSms = m['rawSms'] as String
    ..senderId = m['senderId'] as String
    ..rawSmsHash = m['rawSmsHash'] as String
    ..parsedDate = DateTime.parse(m['parsedDate'] as String)
    ..parsedAmount = (m['parsedAmount'] as num).toDouble()
    ..parsedType = m['parsedType'] as String
    ..parsedMerchant = m['parsedMerchant'] as String?
    ..parsedAccountSuffix = m['parsedAccountSuffix'] as String?
    ..suggestedAccountId = m['suggestedAccountId'] as String?
    ..suggestedCategoryId = m['suggestedCategoryId'] as String?
    ..reviewStatus = m['reviewStatus'] as String
    ..smsDate = DateTime.parse(m['smsDate'] as String)
    ..importedAt = m['importedAt'] != null
        ? DateTime.parse(m['importedAt'] as String)
        : null
    ..importedTransactionId = m['importedTransactionId'] as String?
    ..patternMatched = m['patternMatched'] as String?;
}
