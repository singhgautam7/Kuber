// Advanced History engine: AST -> Isar filter, KPIs, groups, charts, pages.
//
// Everything here takes an [Isar] and plain arguments so it can run on a
// helper isolate ([runAh]) or inline (tests). No Riverpod, no Flutter.
//
// Matching: the tree is translated to an Isar filter (native scan, only
// matches are deserialised). Tag conditions live in the `TransactionTag` join
// collection, so a tree with a tag leaf runs a superset Isar query (tag leaves
// become TRUE, negations pushed to the leaves first) and the exact predicate
// is applied in Dart afterwards.

import 'dart:isolate';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart' show kIsarSchemas;
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/helpers/transaction_filters.dart';
import '../models/ah_view.dart';
import '../query/query_ast.dart';
import 'ah_results.dart';

// ---------------------------------------------------------------------------
// Running off the UI isolate

/// Runs [fn] with [isar] on a helper isolate (reopening the app's database
/// there, like `TransactionRepository.getAll`), or inline when the database
/// isn't the app's default one (tests) or the isolate fails. [fn] must be a
/// top-level function and [params] plain data.
Future<R> runAh<P, R>(
    Isar isar, P params, Future<R> Function(Isar, P) fn) async {
  final dir = isar.directory;
  if (!kIsWeb &&
      isar.name == Isar.defaultName &&
      dir != null &&
      // ignore: invalid_use_of_visible_for_testing_member
      TransactionRepository.offloadGetAll) {
    try {
      return await Isolate.run(() async {
        final helper =
            await Isar.open(kIsarSchemas, directory: dir, inspector: false);
        try {
          return await fn(helper, params);
        } finally {
          await helper.close();
        }
      });
    } catch (e) {
      debugPrint('Kuber: Advanced History query on a helper isolate failed, running here: $e');
    }
  }
  return fn(isar, params);
}

// ---------------------------------------------------------------------------
// Lookups

class AhLookups {
  AhLookups(this.cats, this.groups, this.accounts, this.tags, this.txnTags);
  final Map<String, Category> cats; // by id string
  final Map<int, String> groups;
  final Map<String, Account> accounts; // by id string
  final Map<int, Tag> tags;
  final Map<int, List<int>> txnTags;

  static Future<AhLookups> load(Isar isar) async {
    final cats = await isar.categorys.where().findAll();
    final groups = await isar.categoryGroups.where().findAll();
    final accounts = await isar.accounts.where().findAll();
    final tags = await isar.tags.where().findAll();
    final links = await isar.transactionTags.where().findAll();
    final tt = <int, List<int>>{};
    for (final l in links) {
      (tt[l.transactionId] ??= []).add(l.tagId);
    }
    return AhLookups(
      {for (final c in cats) '${c.id}': c},
      {for (final g in groups) g.id: g.name},
      {for (final a in accounts) '${a.id}': a},
      {for (final t in tags) t.id: t},
      tt,
    );
  }

  List<int> tagIdsOf(Transaction t) => txnTags[t.id] ?? const [];
}

// ---------------------------------------------------------------------------
// Semantics shared by the Isar filter and the Dart predicate

bool isSms(Transaction t) => t.importSource == 'sms' || t.importedFromSms != null;
bool isQuickAdd(Transaction t) =>
    t.quickAddNote != null || t.importSource == 'quick_add';
bool isRecurringSrc(Transaction t) =>
    const ['recurring', 'loan', 'investment'].contains(t.sourceType) ||
    t.linkedRuleType != null;

/// The one source a transaction is grouped under.
String sourceOf(Transaction t) => isSms(t)
    ? 'sms'
    : isQuickAdd(t)
        ? 'quickadd'
        : isRecurringSrc(t)
            ? 'recurring'
            : 'manual';

String typeOf(Transaction t) => t.isTransfer ? 'transfer' : t.type;

const _tru = FilterCondition.greaterThan(property: r'id', value: -1);
const _fal = FilterCondition.lessThan(property: r'id', value: 0);

class _Leaf {
  const _Leaf(this.isar, this.test);
  final FilterOperation isar;
  final bool Function(Transaction) test;
}

FilterOperation _orOps(List<FilterOperation> ops) => ops.isEmpty
    ? _fal
    : ops.length == 1
        ? ops.first
        : FilterGroup.or(ops);

class _Env {
  _Env(this.now, this.lk);
  final DateTime now;
  final AhLookups lk;
  bool hasTag = false;
}

/// [from, to) bounds of one date value.
(DateTime, DateTime) _period(String v, DateTime now) {
  switch (v) {
    case 'thismonth':
      return (DateTime(now.year, now.month), DateTime(now.year, now.month + 1));
    case 'lastmonth':
      return (DateTime(now.year, now.month - 1), DateTime(now.year, now.month));
    case 'thisyear':
      return (DateTime(now.year), DateTime(now.year + 1));
    case 'lastyear':
      return (DateTime(now.year - 1), DateTime(now.year));
  }
  final rel = RegExp(r'^last(\d+)d$').firstMatch(v);
  if (rel != null) {
    final n = int.parse(rel.group(1)!);
    return (
      DateTime(now.year, now.month, now.day - (n - 1)),
      DateTime(now.year, now.month, now.day + 1)
    );
  }
  final p = v.split('-').map(int.parse).toList();
  if (p.length == 1) return (DateTime(p[0]), DateTime(p[0] + 1));
  if (p.length == 2) return (DateTime(p[0], p[1]), DateTime(p[0], p[1] + 1));
  return (DateTime(p[0], p[1], p[2]), DateTime(p[0], p[1], p[2] + 1));
}

/// Date intervals ([from, to), null = open) of a date condition.
List<(DateTime?, DateTime?)> dateIntervals(ConditionNode c, DateTime now) {
  switch (c.op) {
    case QueryOp.eq:
      return [for (final v in c.values) _period(v, now)];
    case QueryOp.range:
      return [(_period(c.values[0], now).$1, _period(c.values[1], now).$2)];
    case QueryOp.gt:
      return [(_period(c.values[0], now).$2, null)];
    case QueryOp.gte:
      return [(_period(c.values[0], now).$1, null)];
    case QueryOp.lt:
      return [(null, _period(c.values[0], now).$1)];
    case QueryOp.lte:
      return [(null, _period(c.values[0], now).$2)];
  }
}

/// Intervals on the absolute amount: (lo, loIncl, hi, hiIncl), null = open.
List<(double?, bool, double?, bool)> amountIntervals(ConditionNode c) {
  double v(int i) => double.parse(c.values[i]);
  switch (c.op) {
    case QueryOp.eq:
      return [for (var i = 0; i < c.values.length; i++) (v(i), true, v(i), true)];
    case QueryOp.range:
      return [(v(0), true, v(1), true)];
    case QueryOp.gt:
      return [(v(0), false, null, false)];
    case QueryOp.gte:
      return [(v(0), true, null, false)];
    case QueryOp.lt:
      return [(null, true, v(0), false)];
    case QueryOp.lte:
      return [(null, true, v(0), true)];
  }
}

bool _inAmount((double?, bool, double?, bool) i, double abs) {
  final (lo, li, hi, hiI) = i;
  if (lo != null && (li ? abs < lo : abs <= lo)) return false;
  if (hi != null && (hiI ? abs > hi : abs >= hi)) return false;
  return true;
}

FilterOperation _amountIsar((double?, bool, double?, bool) i) {
  final (lo, li, hi, hiI) = i;
  FilterOperation signed(double? a, bool ai, double? b, bool bi) {
    if (a != null && b != null) {
      return FilterCondition.between(
          property: r'amount',
          lower: a,
          includeLower: ai,
          upper: b,
          includeUpper: bi);
    }
    if (a != null) {
      return FilterCondition.greaterThan(
          property: r'amount', value: a, include: ai);
    }
    if (b != null) {
      return FilterCondition.lessThan(property: r'amount', value: b, include: bi);
    }
    return _tru;
  }

  final low = lo ?? 0;
  final lowInc = lo == null ? true : li;
  if (low == 0 && lowInc) {
    return signed(hi == null ? null : -hi, hiI, hi, hiI);
  }
  return FilterGroup.or([
    signed(low, lowInc, hi, hiI),
    signed(hi == null ? null : -hi, hiI, -low, lowInc),
  ]);
}

_Leaf _leaf(ConditionNode c, _Env env) {
  final lk = env.lk;
  switch (c.field) {
    case QueryField.type:
      final leaves = [
        for (final v in c.values)
          switch (v) {
            'transfer' => _Leaf(
                const FilterCondition.equalTo(property: r'isTransfer', value: true),
                (t) => t.isTransfer),
            _ => _Leaf(
                FilterGroup.and([
                  FilterCondition.equalTo(property: r'type', value: v),
                  const FilterCondition.equalTo(
                      property: r'isTransfer', value: false),
                ]),
                (t) => t.type == v && !t.isTransfer),
          }
      ];
      return _any(leaves);
    case QueryField.amount:
      final ivs = amountIntervals(c);
      return _Leaf(_orOps([for (final i in ivs) _amountIsar(i)]),
          (t) => ivs.any((i) => _inAmount(i, t.amount.abs())));
    case QueryField.category:
      final ids = <String>{};
      for (final v in c.values) {
        final lv = v.toLowerCase();
        for (final e in lk.cats.entries) {
          if (e.value.name.toLowerCase() == lv) ids.add(e.key);
        }
        for (final g in lk.groups.entries) {
          if (g.value.toLowerCase() == lv) {
            for (final e in lk.cats.entries) {
              if (e.value.groupId == g.key) ids.add(e.key);
            }
          }
        }
      }
      return _Leaf(
          _orOps([
            for (final id in ids)
              FilterCondition.equalTo(property: r'categoryId', value: id)
          ]),
          (t) => ids.contains(t.categoryId));
    case QueryField.account:
      final ids = <String>{};
      for (final v in c.values) {
        final lv = v.toLowerCase();
        for (final e in lk.accounts.entries) {
          if (e.value.name.toLowerCase().contains(lv)) ids.add(e.key);
        }
      }
      return _Leaf(
          _orOps([
            for (final id in ids)
              FilterCondition.equalTo(property: r'accountId', value: id)
          ]),
          (t) => ids.contains(t.accountId));
    case QueryField.tag:
      env.hasTag = true;
      final none = c.values.any((v) => v.toLowerCase() == 'none');
      final ids = <int>{};
      for (final v in c.values) {
        final lv = v.toLowerCase();
        for (final t in lk.tags.values) {
          if (t.name.toLowerCase() == lv) ids.add(t.id);
        }
      }
      return _Leaf(_tru, (t) {
        final mine = lk.tagIdsOf(t);
        if (none && mine.isEmpty) return true;
        return mine.any(ids.contains);
      });
    case QueryField.date:
      final ivs = dateIntervals(c, env.now);
      FilterOperation op((DateTime?, DateTime?) i) {
        final (a, b) = i;
        if (a != null && b != null) {
          return FilterCondition.between(
              property: r'createdAt', lower: a, upper: b, includeUpper: false);
        }
        if (a != null) {
          return FilterCondition.greaterThan(
              property: r'createdAt', value: a, include: true);
        }
        return FilterCondition.lessThan(property: r'createdAt', value: b);
      }

      return _Leaf(_orOps([for (final i in ivs) op(i)]), (t) {
        final d = t.createdAt;
        return ivs.any((i) =>
            (i.$1 == null || !d.isBefore(i.$1!)) &&
            (i.$2 == null || d.isBefore(i.$2!)));
      });
    case QueryField.words:
      final words = [for (final v in c.values) v.toLowerCase()];
      return _Leaf(
          _orOps([
            for (final w in words) ...[
              FilterCondition.contains(property: r'nameLower', value: w),
              FilterCondition.contains(
                  property: r'notes', value: w, caseSensitive: false),
            ]
          ]),
          (t) => words.any((w) =>
              t.nameLower.contains(w) ||
              (t.notes ?? '').toLowerCase().contains(w)));
    case QueryField.has:
      return _any([
        for (final v in c.values)
          v == 'note'
              ? _Leaf(
                  FilterGroup.and([
                    const FilterCondition.isNotNull(property: r'notes'),
                    FilterGroup.not(const FilterCondition.equalTo(
                        property: r'notes', value: '')),
                  ]),
                  (t) => t.notes != null && t.notes!.isNotEmpty)
              : _Leaf(
                  const FilterCondition.listLength(
                      property: r'attachmentPaths', lower: 1, upper: 999999),
                  (t) => t.attachmentPaths.isNotEmpty),
      ]);
    case QueryField.source:
      return _any([for (final v in c.values) _source(v)]);
    case QueryField.subType:
      return _any([
        for (final v in c.values)
          _Leaf(
              FilterCondition.equalTo(
                  property: r'subType', value: TxnSubType.values.byName(v)),
              (t) => t.subType?.name == v),
      ]);
  }
}

const _smsOp = FilterGroup.or([
  FilterCondition.equalTo(property: r'importSource', value: 'sms'),
  FilterCondition.isNotNull(property: r'importedFromSms'),
]);
const _quickOp = FilterGroup.or([
  FilterCondition.isNotNull(property: r'quickAddNote'),
  FilterCondition.equalTo(property: r'importSource', value: 'quick_add'),
]);
const _recurOp = FilterGroup.or([
  FilterCondition.equalTo(property: r'sourceType', value: 'recurring'),
  FilterCondition.equalTo(property: r'sourceType', value: 'loan'),
  FilterCondition.equalTo(property: r'sourceType', value: 'investment'),
  FilterCondition.isNotNull(property: r'linkedRuleType'),
]);

_Leaf _source(String v) {
  switch (v) {
    case 'sms':
      return _Leaf(_smsOp, isSms);
    case 'quickadd':
      return _Leaf(_quickOp, isQuickAdd);
    case 'recurring':
      return _Leaf(_recurOp, isRecurringSrc);
    case 'import':
      // ponytail: CSV / Kuber-file imports leave no marker on the row, so
      // `source:import` matches nothing until the importers set one.
      return _Leaf(_fal, (_) => false);
    default:
      return _Leaf(FilterGroup.not(FilterGroup.or([_smsOp, _quickOp, _recurOp])),
          (t) => !isSms(t) && !isQuickAdd(t) && !isRecurringSrc(t));
  }
}

_Leaf _any(List<_Leaf> leaves) => _Leaf(
    _orOps([for (final l in leaves) l.isar]), (t) => leaves.any((l) => l.test(t)));

/// Superset-safe Isar filter (tag leaves become TRUE under either polarity).
FilterOperation _isar(QueryNode n, bool neg, _Env env) {
  switch (n) {
    case ConditionNode():
      final l = _leaf(n, env);
      if (n.field == QueryField.tag) return _tru;
      return neg ? FilterGroup.not(l.isar) : l.isar;
    case NotNode():
      return _isar(n.child, !neg, env);
    case AndNode():
      final ops = [for (final c in n.children) _isar(c, neg, env)];
      return neg ? FilterGroup.or(ops) : FilterGroup.and(ops);
    case OrNode():
      final ops = [for (final c in n.children) _isar(c, neg, env)];
      return neg ? FilterGroup.and(ops) : FilterGroup.or(ops);
  }
}

bool Function(Transaction) _test(QueryNode n, _Env env) {
  switch (n) {
    case ConditionNode():
      return _leaf(n, env).test;
    case NotNode():
      final f = _test(n.child, env);
      return (t) => !f(t);
    case AndNode():
      final fs = [for (final c in n.children) _test(c, env)];
      return (t) => fs.every((f) => f(t));
    case OrNode():
      final fs = [for (final c in n.children) _test(c, env)];
      return (t) => fs.any((f) => f(t));
  }
}

/// Every transaction matching [node] (all when null), unsorted.
Future<List<Transaction>> ahMatch(
    Isar isar, QueryNode? node, DateTime now, AhLookups lk) async {
  if (node == null) return isar.transactions.where().findAll();
  final env = _Env(now, lk);
  final op = _isar(node, false, env);
  final found = await isar.transactions
      .buildQuery<Transaction>(filter: op)
      .findAll();
  if (!env.hasTag) return found;
  final test = _test(node, env);
  return found.where(test).toList();
}

// ---------------------------------------------------------------------------
// KPIs, sorting, groups, charts

AhKpis ahKpisOf(List<Transaction> txns) {
  if (txns.isEmpty) return AhKpis.empty;
  var sum = 0.0, largest = 0.0;
  var att = 0;
  for (final t in txns) {
    final a = t.amount.abs();
    sum += a;
    if (a > largest) largest = a;
    if (t.attachmentPaths.isNotEmpty) att++;
  }
  final ie = analyticsIncomeExpense(txns);
  return AhKpis(
    transactions: txns.length,
    income: ie.income,
    expense: ie.expense,
    average: sum / txns.length,
    attachments: att,
    largest: largest,
  );
}

List<Transaction> ahSortTxns(List<Transaction> src, AhSort s, AhLookups lk) {
  final list = [...src];
  int byDate(Transaction a, Transaction b) {
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : b.id.compareTo(a.id);
  }

  int Function(Transaction, Transaction) cmp;
  switch (s.field) {
    case AhSortField.amount:
      cmp = (a, b) {
        final c = a.amount.abs().compareTo(b.amount.abs());
        return c != 0 ? c : byDate(a, b);
      };
    case AhSortField.category:
      String n(Transaction t) => (lk.cats[t.categoryId]?.name ?? '').toLowerCase();
      cmp = (a, b) {
        final c = n(a).compareTo(n(b));
        return c != 0 ? c : byDate(a, b);
      };
    case AhSortField.account:
      String n(Transaction t) => (lk.accounts[t.accountId]?.name ?? '').toLowerCase();
      cmp = (a, b) {
        final c = n(a).compareTo(n(b));
        return c != 0 ? c : byDate(a, b);
      };
    default:
      list.sort(byDate);
      return list;
  }
  final dir = s.descending ? -1 : 1;
  list.sort((a, b) => dir * cmp(a, b));
  return list;
}

AhGroupBy ahGroupByOfSplit(AhChartSplit s) => AhGroupBy.values.byName(s.name);

/// Group keys of [t] (several for tags, `''` = none).
List<String> ahKeysOf(Transaction t, AhGroupBy by, AhLookups lk) {
  switch (by) {
    case AhGroupBy.none:
      return const [''];
    case AhGroupBy.category:
      return [lk.cats.containsKey(t.categoryId) ? t.categoryId : ''];
    case AhGroupBy.account:
      return [t.accountId];
    case AhGroupBy.tag:
      final ids = lk.tagIdsOf(t).where(lk.tags.containsKey).toList();
      return ids.isEmpty ? const [''] : [for (final i in ids) '$i'];
    case AhGroupBy.type:
      return [typeOf(t)];
    case AhGroupBy.source:
      return [sourceOf(t)];
    case AhGroupBy.month:
      return ['${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}'];
    case AhGroupBy.year:
      return ['${t.createdAt.year}'];
  }
}

class _Acc {
  _Acc(this.key, this.label, this.colorValue, this.icon);
  final String key;
  final String label;
  final int? colorValue;
  final String? icon;
  int count = 0;
  double total = 0;
}

_Acc _newAcc(String key, AhGroupBy by, AhLookups lk) {
  switch (by) {
    case AhGroupBy.category:
      final c = lk.cats[key];
      return _Acc(key, c?.name ?? '', c?.colorValue, c?.icon);
    case AhGroupBy.account:
      final a = lk.accounts[key];
      return _Acc(key, a?.name ?? '', a?.colorValue, a?.icon);
    case AhGroupBy.tag:
      return _Acc(key, lk.tags[int.tryParse(key)]?.name ?? '', null, null);
    default:
      return _Acc(key, key, null, null);
  }
}

Map<String, _Acc> _accumulate(
    List<Transaction> txns, AhGroupBy by, AhLookups lk) {
  final m = <String, _Acc>{};
  for (final t in txns) {
    final a = t.amount.abs();
    for (final k in ahKeysOf(t, by, lk)) {
      final acc = m[k] ??= _newAcc(k, by, lk);
      acc.count++;
      acc.total += a;
    }
  }
  return m;
}

/// Group rows. `total` is the sum of absolute amounts in the group and
/// `share` is against the sum over all [txns] (tags can exceed 1).
AhGroups ahGroupsOf(
    List<Transaction> txns, AhGroupBy by, AhSort sort, AhLookups lk) {
  final acc = _accumulate(txns, by, lk).values.toList();
  final overall = txns.fold<double>(0, (s, t) => s + t.amount.abs());
  final dir = sort.descending ? -1 : 1;
  acc.sort((a, b) {
    int c;
    switch (sort.field) {
      case AhSortField.count:
        c = a.count.compareTo(b.count);
      case AhSortField.name:
        c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
        if (c == 0) c = a.key.compareTo(b.key);
      default:
        c = a.total.compareTo(b.total);
    }
    return c == 0 ? a.key.compareTo(b.key) : dir * c;
  });
  var multi = false;
  if (by == AhGroupBy.tag) {
    multi = txns.any((t) => lk.tagIdsOf(t).where(lk.tags.containsKey).length > 1);
  }
  return AhGroups([
    for (final a in acc)
      AhGroupRow(
        by: by,
        key: a.key,
        label: a.label,
        count: a.count,
        total: a.total,
        share: overall == 0 ? 0 : a.total / overall,
        colorValue: a.colorValue,
        icon: a.icon,
      )
  ], multiTagNote: multi);
}

AhChartData ahChartOf(List<Transaction> txns, AhChartSpec spec, AhLookups lk) {
  if (spec.type == AhChartType.line &&
      spec.split != AhChartSplit.month &&
      spec.split != AhChartSplit.year) {
    return const AhChartData(AhChartState.wrongCombo);
  }
  if (txns.isEmpty) return const AhChartData(AhChartState.noResults);
  final by = ahGroupByOfSplit(spec.split);
  final acc = _accumulate(txns, by, lk);
  if (acc.length == 1 && acc.containsKey('')) {
    return AhChartData(AhChartState.nothingToSplit, count: txns.length);
  }
  double value(double total, int count) => switch (spec.measure) {
        AhChartMeasure.total => total,
        AhChartMeasure.count => count.toDouble(),
        AhChartMeasure.average => count == 0 ? 0 : total / count,
      };
  AhChartPoint point(_Acc a) =>
      AhChartPoint(a.key, a.label, value(a.total, a.count), colorValue: a.colorValue);

  if (spec.type == AhChartType.line) {
    final keys = acc.keys.toList()..sort();
    // Fill the months / years between the first and last with zero.
    final filled = <String>[];
    if (by == AhGroupBy.year) {
      for (var y = int.parse(keys.first); y <= int.parse(keys.last); y++) {
        filled.add('$y');
      }
    } else {
      var y = int.parse(keys.first.substring(0, 4));
      var m = int.parse(keys.first.substring(5));
      final end = keys.last;
      while (true) {
        final k = '$y-${m.toString().padLeft(2, '0')}';
        filled.add(k);
        if (k == end) break;
        if (++m > 12) {
          m = 1;
          y++;
        }
      }
    }
    if (filled.length < 2) {
      return AhChartData(AhChartState.notEnoughData, count: txns.length);
    }
    return AhChartData(AhChartState.ok, count: txns.length, points: [
      for (final k in filled)
        acc[k] == null ? AhChartPoint(k, k, 0) : point(acc[k]!)
    ]);
  }

  final sorted = acc.values.toList()
    ..sort((a, b) {
      final c = value(b.total, b.count).compareTo(value(a.total, a.count));
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  if (spec.type == AhChartType.donut && sorted.length > 6) {
    final rest = sorted.skip(5).toList();
    final total = rest.fold<double>(0, (s, a) => s + a.total);
    final count = rest.fold<int>(0, (s, a) => s + a.count);
    return AhChartData(AhChartState.ok, count: txns.length, points: [
      for (final a in sorted.take(5)) point(a),
      AhChartPoint('__other', 'Other', value(total, count)),
    ]);
  }
  return AhChartData(AhChartState.ok,
      count: txns.length, points: [for (final a in sorted) point(a)]);
}

Map<AhChartSplit, AhSplitBlock> ahBlocksOf(List<Transaction> txns, AhLookups lk) {
  int distinct(AhGroupBy by) {
    final s = <String>{};
    for (final t in txns) {
      s.addAll(ahKeysOf(t, by, lk));
      if (s.length > 1) break;
    }
    return s.length;
  }

  final out = <AhChartSplit, AhSplitBlock>{};
  if (!txns.any((t) => lk.tagIdsOf(t).any(lk.tags.containsKey))) {
    out[AhChartSplit.tag] = AhSplitBlock.noTags;
  }
  if (distinct(AhGroupBy.account) <= 1) out[AhChartSplit.account] = AhSplitBlock.oneAccount;
  if (distinct(AhGroupBy.type) <= 1) out[AhChartSplit.type] = AhSplitBlock.oneType;
  if (distinct(AhGroupBy.source) <= 1) out[AhChartSplit.source] = AhSplitBlock.oneSource;
  if (distinct(AhGroupBy.category) <= 1) out[AhChartSplit.category] = AhSplitBlock.oneCategory;
  if (distinct(AhGroupBy.month) <= 1) out[AhChartSplit.month] = AhSplitBlock.oneMonth;
  if (distinct(AhGroupBy.year) <= 1) out[AhChartSplit.year] = AhSplitBlock.oneYear;
  return out;
}

// ---------------------------------------------------------------------------
// Jobs (top-level, for [runAh])

const kAhPageSize = 50;

class AhBundle {
  const AhBundle(this.kpis, this.groups, this.page, this.charts, this.blocks);
  final AhKpis kpis;
  final AhGroups? groups;
  final AhTxnPage page;
  final Map<AhChartSpec, AhChartData> charts;
  final Map<AhChartSplit, AhSplitBlock> blocks;
}

class AhBundleParams {
  const AhBundleParams(this.node, this.groupBy, this.sort, this.charts, this.now);
  final QueryNode? node;
  final AhGroupBy groupBy;
  final AhSort sort;
  final List<AhChartSpec> charts;
  final DateTime now;
}

AhSort _pageSort(AhSort s) =>
    const [AhSortField.date, AhSortField.amount, AhSortField.category, AhSortField.account]
            .contains(s.field)
        ? s
        : AhSort.ungroupedDefault;

AhTxnPage _page(List<Transaction> sorted, int offset) {
  final end = (offset + kAhPageSize).clamp(0, sorted.length);
  return AhTxnPage(
    offset >= sorted.length ? const [] : sorted.sublist(offset, end),
    hasMore: end < sorted.length,
    total: sorted.length,
  );
}

Future<AhBundle> ahBundleJob(Isar isar, AhBundleParams p) async {
  final lk = await AhLookups.load(isar);
  final txns = await ahMatch(isar, p.node, p.now, lk);
  return AhBundle(
    ahKpisOf(txns),
    p.groupBy == AhGroupBy.none ? null : ahGroupsOf(txns, p.groupBy, p.sort, lk),
    _page(ahSortTxns(txns, _pageSort(p.sort), lk), 0),
    {for (final c in p.charts) c: ahChartOf(txns, c, lk)},
    ahBlocksOf(txns, lk),
  );
}

class AhPageParams {
  const AhPageParams(this.node, this.sort, this.now, this.offset,
      {this.by, this.key});
  final QueryNode? node;
  final AhSort sort;
  final DateTime now;
  final int offset;
  final AhGroupBy? by;
  final String? key;
}

Future<List<Transaction>> _matchGroup(
    Isar isar, QueryNode? node, DateTime now, AhGroupBy? by, String? key,
    AhLookups lk) async {
  final txns = await ahMatch(isar, node, now, lk);
  if (by == null || by == AhGroupBy.none) return txns;
  return txns.where((t) => ahKeysOf(t, by, lk).contains(key)).toList();
}

Future<AhTxnPage> ahPageJob(Isar isar, AhPageParams p) async {
  final lk = await AhLookups.load(isar);
  final txns = await _matchGroup(isar, p.node, p.now, p.by, p.key, lk);
  final sort = p.by == null ? _pageSort(p.sort) : AhSort.ungroupedDefault;
  return _page(ahSortTxns(txns, sort, lk), p.offset);
}

Future<AhKpis> ahGroupKpisJob(Isar isar, AhPageParams p) async {
  final lk = await AhLookups.load(isar);
  return ahKpisOf(await _matchGroup(isar, p.node, p.now, p.by, p.key, lk));
}

/// A chart spec outside the open view (builder preview): own match.
class AhChartParams {
  const AhChartParams(this.node, this.spec, this.now);
  final QueryNode? node;
  final AhChartSpec spec;
  final DateTime now;
}

Future<AhChartData> ahChartJob(Isar isar, AhChartParams p) async {
  final lk = await AhLookups.load(isar);
  return ahChartOf(await ahMatch(isar, p.node, p.now, lk), p.spec, lk);
}

class AhCountParams {
  const AhCountParams(this.node, this.now);
  final QueryNode? node;
  final DateTime now;
}

Future<int> ahCountJob(Isar isar, AhCountParams p) async {
  final lk = await AhLookups.load(isar);
  return (await ahMatch(isar, p.node, p.now, lk)).length;
}

/// A value of a field with how many transactions use it.
class AhValueCount {
  const AhValueCount(this.name, this.count);
  final String name;
  final int count;
}

/// The user's values for [field] with counts (suggestions).
Future<List<AhValueCount>> ahFieldValuesJob(Isar isar, QueryField field) async {
  Map<String, int> tally(Iterable<String> keys) {
    final m = <String, int>{};
    for (final k in keys) {
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  switch (field) {
    case QueryField.category:
      final counts =
          tally(await isar.transactions.where().categoryIdProperty().findAll());
      final cats = await isar.categorys.where().findAll();
      return [for (final c in cats) AhValueCount(c.name, counts['${c.id}'] ?? 0)];
    case QueryField.account:
      final counts =
          tally(await isar.transactions.where().accountIdProperty().findAll());
      final accs = await isar.accounts.where().findAll();
      return [for (final a in accs) AhValueCount(a.name, counts['${a.id}'] ?? 0)];
    case QueryField.tag:
      final counts = tally((await isar.transactionTags.where().tagIdProperty().findAll())
          .map((e) => '$e'));
      final tags = await isar.tags.where().findAll();
      return [for (final t in tags) AhValueCount(t.name, counts['${t.id}'] ?? 0)];
    default:
      return const [];
  }
}
