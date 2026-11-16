import 'dart:math';

import 'package:isar_community/isar.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/tags/data/transaction_tag.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

/// A seeded ledger in Isar plus plain copies for brute-force checks.
class AhFixture {
  AhFixture(this.txns, this.cats, this.groups, this.accounts, this.tags, this.txnTags);
  final List<Transaction> txns;
  final List<Category> cats;
  final List<CategoryGroup> groups;
  final List<Account> accounts;
  final List<Tag> tags;
  final Map<int, Set<int>> txnTags;
}

final fixtureNow = DateTime(2026, 6, 15, 12);
const catNames = ['Food', 'Travel', 'Rent', 'Salary', 'Fuel', 'Fun'];
const groupNames = ['Living', 'Lifestyle'];
const accNames = ['HDFC Millennia', 'SBI Savings', 'Cash', 'ICICI Amazon'];
const tagNames = ['trip', 'work', 'reimbursed', 'gift', 'emi'];
const words = ['swiggy', 'uber', 'rent', 'salary', 'petrol', 'movie', 'amazon'];

Future<AhFixture> buildFixture(Isar isar, {int n = 400, int seed = 7}) async {
  final r = Random(seed);
  final groups = [for (final g in groupNames) CategoryGroup()..name = g];
  await isar.writeTxn(() => isar.categoryGroups.putAll(groups));
  final cats = [
    for (var i = 0; i < catNames.length; i++)
      Category()
        ..name = catNames[i]
        ..icon = 'restaurant'
        ..colorValue = 0xFF000000 + i * 1000
        ..groupId = i < 3 ? groups[0].id : groups[1].id
  ];
  final accounts = [
    for (final a in accNames)
      Account()
        ..name = a
        ..type = 'bank'
  ];
  final tags = [
    for (final t in tagNames)
      Tag()
        ..name = t
        ..createdAt = DateTime(2026)
  ];
  await isar.writeTxn(() async {
    await isar.categorys.putAll(cats);
    await isar.accounts.putAll(accounts);
    await isar.tags.putAll(tags);
  });
  final txns = <Transaction>[];
  for (var i = 0; i < n; i++) {
    final name = '${words[r.nextInt(words.length)]} ${r.nextInt(50)}';
    final created = DateTime(2025, 11, 1).add(Duration(
        days: r.nextInt(300), hours: r.nextInt(24), minutes: r.nextInt(60)));
    final t = Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = [50, 120, 499, 500, 750, 1500, 2000, 4800, 25000][r.nextInt(9)] +
          (r.nextBool() ? 0.0 : 0.5)
      ..type = r.nextInt(4) == 0 ? 'income' : 'expense'
      ..categoryId = r.nextInt(12) == 0 ? '' : '${cats[r.nextInt(cats.length)].id}'
      ..accountId = '${accounts[r.nextInt(accounts.length)].id}'
      ..createdAt = created
      ..updatedAt = created;
    if (r.nextInt(5) == 0) t.notes = ['reimburse me', 'gift for dad', ''][r.nextInt(3)];
    if (r.nextInt(8) == 0) t.attachmentPaths = ['a.jpg'];
    final s = r.nextInt(14);
    if (s == 0) t.importSource = 'sms';
    if (s == 1) t.importedFromSms = 'raw sms';
    if (s == 2) t.quickAddNote = 'lunch 200';
    if (s == 3) {
      t.sourceType = 'recurring';
      t.linkedRuleType = 'recurring';
    }
    if (s == 4) t.sourceType = 'loan';
    if (s == 5) t.linkedRuleType = 'investment';
    if (r.nextInt(15) == 0) t.subType = TxnSubType.savings;
    if (r.nextInt(25) == 0) {
      t.isTransfer = true;
      t.transferId = 't$i';
    }
    if (r.nextInt(40) == 0) t.isBalanceAdjustment = true;
    txns.add(t);
  }
  await isar.writeTxn(() => isar.transactions.putAll(txns));
  final links = <TransactionTag>[];
  final tt = <int, Set<int>>{};
  for (final t in txns) {
    final k = r.nextInt(10);
    final c = k < 5 ? 0 : (k < 8 ? 1 : 2);
    final picked = <int>{};
    for (var j = 0; j < c; j++) {
      picked.add(tags[r.nextInt(tags.length)].id);
    }
    if (picked.isEmpty) continue;
    tt[t.id] = picked;
    for (final id in picked) {
      links.add(TransactionTag()
        ..transactionId = t.id
        ..tagId = id);
    }
  }
  await isar.writeTxn(() => isar.transactionTags.putAll(links));
  return AhFixture(txns, cats, groups, accounts, tags, tt);
}
