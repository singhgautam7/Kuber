import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../features/accounts/data/account.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/categories/data/category.dart';
import '../../features/categories/data/category_group.dart';
import '../../features/investments/data/investment.dart';
import '../../features/ledger/data/ledger.dart';
import '../../features/loans/data/loan.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/tags/data/tag.dart';
import '../../features/tags/data/transaction_tag.dart';
import '../../features/transactions/data/transaction.dart';
import '../database/seed_service.dart';
import 'data_service.dart';

class JsonBackupService {
  static const _version = 1;

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
    };

    return jsonEncode(data);
  }

  Future<ImportResult> importJson(Isar isar, String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;

      await isar.writeTxn(() => isar.clear());
      await SeedService().seedInitialData(isar);

      int count = 0;

      await isar.writeTxn(() async {
        for (final m in _list(data, 'categoryGroups')) {
          await isar.categoryGroups.put(_mapToGroup(m));
          count++;
        }
        for (final m in _list(data, 'categories')) {
          await isar.categorys.put(_mapToCat(m));
          count++;
        }
        for (final m in _list(data, 'accounts')) {
          await isar.accounts.put(_mapToAccount(m));
          count++;
        }
        for (final m in _list(data, 'tags')) {
          await isar.tags.put(_mapToTag(m));
          count++;
        }
        for (final m in _list(data, 'transactions')) {
          await isar.transactions.put(_mapToTx(m));
          count++;
        }
        for (final m in _list(data, 'transactionTags')) {
          await isar.transactionTags.put(_mapToTxTag(m));
          count++;
        }
        for (final m in _list(data, 'recurringRules')) {
          await isar.recurringRules.put(_mapToRecurring(m));
          count++;
        }
        for (final m in _list(data, 'budgets')) {
          await isar.budgets.put(_mapToBudget(m));
          count++;
        }
        for (final m in _list(data, 'ledgers')) {
          await isar.ledgers.put(_mapToLedger(m));
          count++;
        }
        for (final m in _list(data, 'loans')) {
          await isar.loans.put(_mapToLoan(m));
          count++;
        }
        for (final m in _list(data, 'investments')) {
          await isar.investments.put(_mapToInvestment(m));
          count++;
        }
      });

      return ImportResult(successCount: count, failureCount: 0);
    } catch (e) {
      return ImportResult(successCount: 0, failureCount: 0, error: e.toString());
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
            .map((a) => {
                  'type': a.type.name,
                  'value': a.value,
                  'isTriggered': a.isTriggered,
                  'enableNotification': a.enableNotification,
                  'createdAt': a.createdAt.toIso8601String(),
                })
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
    ..nameLower = m['nameLower'] as String;

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
    ..last4Digits = m['last4Digits'] as String?;

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
    ..endDate = m['endDate'] != null ? DateTime.parse(m['endDate'] as String) : null
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
      ..endDate = m['endDate'] != null ? DateTime.parse(m['endDate'] as String) : null
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
    ..expectedDate =
        m['expectedDate'] != null ? DateTime.parse(m['expectedDate'] as String) : null
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
    ..endDate = m['endDate'] != null ? DateTime.parse(m['endDate'] as String) : null
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
    ..autoDebit = (m['autoDebit'] as bool?) ?? false
    ..sipAmount = (m['sipAmount'] as num?)?.toDouble()
    ..sipDate = m['sipDate'] as int?
    ..accountId = m['accountId'] as String?
    ..categoryId = m['categoryId'] as String
    ..notes = m['notes'] as String?
    ..createdAt = DateTime.parse(m['createdAt'] as String)
    ..updatedAt = DateTime.parse(m['updatedAt'] as String);
}
