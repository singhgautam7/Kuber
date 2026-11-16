import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/services/ah_engine.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../../../helpers/isar_test_helper.dart';
import 'ah_fixture.dart';

/// Independent brute-force evaluation on the plain fixture copies.
bool bf(QueryNode n, Transaction t, AhFixture f) {
  switch (n) {
    case AndNode():
      return n.children.every((c) => bf(c, t, f));
    case OrNode():
      return n.children.any((c) => bf(c, t, f));
    case NotNode():
      return !bf(n.child, t, f);
    case ConditionNode():
      return n.values.any((v) => _bfOne(n, v, t, f));
  }
}

DateTime _d(String v, bool end) {
  final p = v.split('-').map(int.parse).toList();
  if (p.length == 1) return end ? DateTime(p[0] + 1) : DateTime(p[0]);
  if (p.length == 2) return end ? DateTime(p[0], p[1] + 1) : DateTime(p[0], p[1]);
  return end ? DateTime(p[0], p[1], p[2] + 1) : DateTime(p[0], p[1], p[2]);
}

(DateTime, DateTime) _per(String v) {
  final n = fixtureNow;
  switch (v) {
    case 'thismonth':
      return (DateTime(n.year, n.month), DateTime(n.year, n.month + 1));
    case 'lastmonth':
      return (DateTime(n.year, n.month - 1), DateTime(n.year, n.month));
    case 'thisyear':
      return (DateTime(n.year), DateTime(n.year + 1));
    case 'lastyear':
      return (DateTime(n.year - 1), DateTime(n.year));
  }
  if (v.startsWith('last')) {
    final k = int.parse(v.substring(4, v.length - 1));
    return (DateTime(n.year, n.month, n.day).subtract(Duration(days: k - 1)),
        DateTime(n.year, n.month, n.day + 1));
  }
  return (_d(v, false), _d(v, true));
}

bool _bfOne(ConditionNode c, String v, Transaction t, AhFixture f) {
  switch (c.field) {
    case QueryField.type:
      if (v == 'transfer') return t.isTransfer;
      return !t.isTransfer && t.type == v;
    case QueryField.amount:
      final a = t.amount.abs();
      final x = double.parse(v);
      return switch (c.op) {
        QueryOp.eq => (a - x).abs() < 1e-6,
        QueryOp.gt => a > x,
        QueryOp.gte => a >= x,
        QueryOp.lt => a < x,
        QueryOp.lte => a <= x,
        QueryOp.range =>
          a >= double.parse(c.values[0]) && a <= double.parse(c.values[1]),
      };
    case QueryField.category:
      final cat = f.cats.where((k) => '${k.id}' == t.categoryId).firstOrNull;
      if (cat == null) return false;
      if (cat.name.toLowerCase() == v.toLowerCase()) return true;
      final g = f.groups.where((g) => g.id == cat.groupId).firstOrNull;
      return g != null && g.name.toLowerCase() == v.toLowerCase();
    case QueryField.account:
      final a = f.accounts.firstWhere((a) => '${a.id}' == t.accountId);
      return a.name.toLowerCase().contains(v.toLowerCase());
    case QueryField.tag:
      final mine = f.txnTags[t.id] ?? {};
      if (v == 'none') return mine.isEmpty;
      return mine.any((id) =>
          f.tags.firstWhere((g) => g.id == id).name.toLowerCase() == v.toLowerCase());
    case QueryField.date:
      final d = t.createdAt;
      bool within(DateTime a, DateTime b) => !d.isBefore(a) && d.isBefore(b);
      switch (c.op) {
        case QueryOp.eq:
          final p = _per(v);
          return within(p.$1, p.$2);
        case QueryOp.range:
          return within(_per(c.values[0]).$1, _per(c.values[1]).$2);
        case QueryOp.gt:
          return !d.isBefore(_per(v).$2);
        case QueryOp.gte:
          return !d.isBefore(_per(v).$1);
        case QueryOp.lt:
          return d.isBefore(_per(v).$1);
        case QueryOp.lte:
          return d.isBefore(_per(v).$2);
      }
    case QueryField.words:
      final w = v.toLowerCase();
      return t.name.toLowerCase().contains(w) ||
          (t.notes ?? '').toLowerCase().contains(w);
    case QueryField.has:
      return v == 'attachment'
          ? t.attachmentPaths.isNotEmpty
          : (t.notes ?? '').isNotEmpty;
    case QueryField.source:
      final sms = t.importSource == 'sms' || t.importedFromSms != null;
      final quick = t.quickAddNote != null;
      final rec = ['recurring', 'loan', 'investment'].contains(t.sourceType) ||
          t.linkedRuleType != null;
      return switch (v) {
        'sms' => sms,
        'quickadd' => quick,
        'recurring' => rec,
        'import' => false,
        _ => !sms && !quick && !rec,
      };
    case QueryField.subType:
      return t.subType?.name == v;
  }
}

const _leaves = [
  'type:expense', 'type:income', 'type:transfer', 'amount:>500', 'amount:<=120',
  'amount:500..2000', 'amount:499.5', 'category:food', 'category:food,travel',
  'category:living', 'category:fun', 'account:hdfc', 'account:cash',
  'tag:trip', 'tag:none', 'tag:work,gift', 'date:2026-03', 'date:thisyear',
  'date:lastmonth', 'date:last30d', 'date:2026-01..2026-03', 'date:>=2026-05',
  'date:<2026-01-15', 'swiggy', 'words:uber', 'has:attachment', 'has:note',
  'source:sms', 'source:quickadd', 'source:recurring', 'source:manual',
  'source:import', 'subtype:savings',
];

String _gen(Random r, int depth) {
  String leaf() {
    final l = _leaves[r.nextInt(_leaves.length)];
    return r.nextInt(6) == 0 ? 'not $l' : l;
  }

  if (depth == 0 || r.nextInt(3) == 0) return leaf();
  final n = 2 + r.nextInt(2);
  final parts = [for (var i = 0; i < n; i++) _gen(r, depth - 1)];
  final out = StringBuffer(parts.first);
  for (final p in parts.skip(1)) {
    out.write(r.nextBool() ? ' and ' : ' or ');
    out.write(p);
  }
  final s = out.toString();
  return r.nextBool() ? '($s)' : s;
}

void main() {
  late Isar isar;
  late AhFixture fx;
  setUpAll(initialiseIsarForTests);
  setUp(() async {
    isar = await openTestIsar();
    fx = await buildFixture(isar);
  });
  tearDown(() => closeAndCleanIsar(isar));

  test('40 random queries: Isar match equals brute force', () async {
    final r = Random(42);
    final lk = await AhLookups.load(isar);
    var nonEmpty = 0;
    for (var q = 0; q < 60; q++) {
      final text = _gen(r, 3);
      final res = parseItems(tokenize(text));
      expect(res.isValid, isTrue, reason: text);
      final node = res.node!;
      final got = (await ahMatch(isar, node, fixtureNow, lk)).map((t) => t.id).toSet();
      final want = {
        for (final t in fx.txns)
          if (bf(node, t, fx)) t.id
      };
      expect(got, want, reason: text);
      if (want.isNotEmpty) nonEmpty++;
      // The canonical text of the tree means the same thing.
      final again = parseItems(tokenize(serializeNode(node))).node!;
      final got2 = (await ahMatch(isar, again, fixtureNow, lk)).map((t) => t.id).toSet();
      expect(got2, want, reason: 'canonical: $text');
    }
    expect(nonEmpty, greaterThan(25));
  });

  test('hand checked semantics', () async {
    final lk = await AhLookups.load(isar);
    Future<List<Transaction>> m(String t) =>
        ahMatch(isar, parseItems(tokenize(t)).node, fixtureNow, lk);
    // transfers are neither expense nor income
    expect((await m('type:expense')).any((t) => t.isTransfer), isFalse);
    expect((await m('type:transfer')).every((t) => t.isTransfer), isTrue);
    // a category group matches its categories
    final living = await m('category:living');
    final single = await m('category:food or category:travel or category:rent');
    expect(living.map((t) => t.id).toSet(), single.map((t) => t.id).toSet());
    // case-insensitive, quoted name with spaces
    expect((await m('account:"hdfc millennia"')).isNotEmpty, isTrue);
    expect((await m('category:FOOD')).isNotEmpty, isTrue);
    // source:import matches nothing, manual excludes the others
    expect(await m('source:import'), isEmpty);
    final manual = await m('source:manual');
    expect(manual.every((t) => sourceOf(t) == 'manual'), isTrue);
    // unknown category matches nothing
    expect(await m('category:nothing'), isEmpty);
    // not of a tag leaf
    final noTag = await m('not tag:trip');
    expect(noTag.any((t) => (fx.txnTags[t.id] ?? {}).contains(fx.tags[0].id)), isFalse);
  });
}
