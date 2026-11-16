// Localised text built from the query tree (token values, readback, errors,
// group names). Query keywords stay English; everything shown is localised.

import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../models/ah_view.dart';
import 'query_ast.dart';

/// User-visible field name (localised; the keyword stays English).
String fieldLabel(QueryField f, AppLocalizations l) => switch (f) {
      QueryField.type => l.ahqFieldType,
      QueryField.amount => l.ahqFieldAmount,
      QueryField.category => l.ahqFieldCategory,
      QueryField.account => l.ahqFieldAccount,
      QueryField.tag => l.ahqFieldTag,
      QueryField.date => l.ahqFieldDate,
      QueryField.words => l.ahqFieldWords,
      QueryField.has => l.ahqFieldHas,
      QueryField.source => l.ahqFieldSource,
      QueryField.subType => l.ahqFieldSubType,
    };

/// Display parts of a token: [field] is `category:` (lower case, colon
/// included; empty for words) and [value] `Food or Travel`, `over ₹500`,
/// `"swiggy"`.
class TokenDisplay {
  const TokenDisplay(this.field, this.value);
  final String field;
  final String value;
}

TokenDisplay tokenDisplay(
  ConditionNode c,
  AppLocalizations l,
  String Function(double) money,
) {
  if (c.field == QueryField.words) {
    return TokenDisplay('', c.values.map((v) => '"$v"').join(' ${l.ahqOr} '));
  }
  return TokenDisplay(
    '${fieldLabel(c.field, l).toLowerCase()}:',
    _value(c, l, money),
  );
}

String _or(AppLocalizations l, Iterable<String> parts) =>
    parts.join(' ${l.ahqOr} ');

String _value(ConditionNode c, AppLocalizations l, String Function(double) m) {
  switch (c.field) {
    case QueryField.amount:
      return _amount(c, l, m);
    case QueryField.date:
      return _dateDisplay(c, l);
    case QueryField.tag:
      return _or(l, c.values.map((v) => v == 'none' ? l.ahqNone : '#$v'));
    case QueryField.type:
      return _or(l, c.values.map((v) => _typeName(v, l)));
    case QueryField.has:
      return _or(l, c.values.map((v) => v == 'note' ? l.ahqHasNote : l.ahqHasAttachment));
    case QueryField.source:
      return _or(l, c.values.map((v) => _sourceName(v, l)));
    case QueryField.subType:
      return _or(l, c.values.map((v) => _subName(v, l)));
    case QueryField.category:
    case QueryField.account:
    case QueryField.words:
      return _or(l, c.values);
  }
}

String _typeName(String v, AppLocalizations l) => switch (v) {
      'income' => l.ahqTypeIncome,
      'transfer' => l.ahqTypeTransfer,
      _ => l.ahqTypeExpense,
    };

String _sourceName(String v, AppLocalizations l) => switch (v) {
      'sms' => l.ahqSourceSms,
      'quickadd' => l.ahqSourceQuickAdd,
      'recurring' => l.ahqSourceRecurring,
      'import' => l.ahqSourceImport,
      _ => l.ahqSourceManual,
    };

String _subName(String v, AppLocalizations l) => switch (v) {
      'loanRepayment' => l.ahqSubLoanRepayment,
      'investment' => l.ahqSubInvestment,
      'savings' => l.ahqSubSavings,
      'lent' => l.ahqSubLent,
      'borrowed' => l.ahqSubBorrowed,
      'investmentReturn' => l.ahqSubInvestmentReturn,
      'loanReceived' => l.ahqSubLoanReceived,
      _ => l.ahqSubLoanDisbursement,
    };

String _amount(ConditionNode c, AppLocalizations l, String Function(double) m) {
  String f(String v) => m(double.parse(v));
  switch (c.op) {
    case QueryOp.eq:
      return _or(l, c.values.map(f));
    case QueryOp.gt:
      return l.ahqAmountOver(f(c.values[0]));
    case QueryOp.lt:
      return l.ahqAmountUnder(f(c.values[0]));
    case QueryOp.gte:
      return l.ahqAmountOrMore(f(c.values[0]));
    case QueryOp.lte:
      return l.ahqAmountOrLess(f(c.values[0]));
    case QueryOp.range:
      return l.ahqRange(f(c.values[0]), f(c.values[1]));
  }
}

// ---- dates

const _enMonths = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December'
];

String _fmt(String pattern, DateTime d, AppLocalizations l) {
  try {
    return DateFormat(pattern, l.localeName).format(d);
  } catch (_) {
    if (pattern.contains('MMM')) {
      final day = pattern.contains('d') ? '${d.day} ' : '';
      final yr = pattern.contains('y') ? ' ${d.year}' : '';
      final mn = _enMonths[d.month - 1];
      return '$day${pattern.contains('MMMM') ? mn : mn.substring(0, 3)}$yr'.trim();
    }
    return '${d.year}';
  }
}

final _relDays = RegExp(r'^last(\d+)d$');

/// 0 relative, 1 year, 2 month, 3 day.
int _grain(String v) {
  if (!RegExp(r'^\d').hasMatch(v)) return 0;
  if (v.length == 4) return 1;
  if (v.length == 7) return 2;
  if (v.length == 10) return 3;
  return 0;
}

DateTime _parse(String v) {
  final p = v.split('-').map(int.parse).toList();
  return DateTime(p[0], p.length > 1 ? p[1] : 1, p.length > 2 ? p[2] : 1);
}

String _relative(String v, AppLocalizations l) {
  switch (v) {
    case 'thismonth':
      return l.ahqDateThisMonth;
    case 'lastmonth':
      return l.ahqDateLastMonth;
    case 'thisyear':
      return l.ahqDateThisYear;
    case 'lastyear':
      return l.ahqDateLastYear;
  }
  return l.ahqDateLastDays(int.parse(_relDays.firstMatch(v)!.group(1)!));
}

/// `Mar 2026`, `14 Mar 2026`, `2026` or a relative name.
String _dateOne(String v, AppLocalizations l, {bool withYear = true}) {
  switch (_grain(v)) {
    case 0:
      return _relative(v, l);
    case 1:
      return v;
    case 2:
      return _fmt(withYear ? 'MMM y' : 'MMM', _parse(v), l);
    default:
      return _fmt(withYear ? 'd MMM y' : 'd MMM', _parse(v), l);
  }
}

String _dateRange(String a, String b, AppLocalizations l) {
  final same = _grain(a) == _grain(b) &&
      _grain(a) >= 2 &&
      a.substring(0, 4) == b.substring(0, 4);
  return l.ahqRange(_dateOne(a, l, withYear: !same), _dateOne(b, l));
}

String _dateDisplay(ConditionNode c, AppLocalizations l) {
  switch (c.op) {
    case QueryOp.eq:
      return _or(l, c.values.map((v) => _dateOne(v, l)));
    case QueryOp.range:
      return _dateRange(c.values[0], c.values[1], l);
    case QueryOp.gt:
      return l.ahqDateAfter(_dateOne(c.values[0], l));
    case QueryOp.lt:
      return l.ahqDateBefore(_dateOne(c.values[0], l));
    case QueryOp.gte:
      return l.ahqDateFrom(_dateOne(c.values[0], l));
    case QueryOp.lte:
      return l.ahqDateUntil(_dateOne(c.values[0], l));
  }
}

String _lowerFirst(String s) =>
    s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

String _datePhrase(ConditionNode c, AppLocalizations l) {
  String one(String v) {
    switch (_grain(v)) {
      case 0:
        return _lowerFirst(_relative(v, l));
      case 1:
        return l.ahqRbDateIn(v);
      case 2:
        return l.ahqRbDateIn(_fmt('MMMM y', _parse(v), l));
      default:
        return l.ahqRbDateOn(_fmt('d MMM y', _parse(v), l));
    }
  }

  switch (c.op) {
    case QueryOp.eq:
      return _or(l, c.values.map(one));
    case QueryOp.range:
      return l.ahqRbDateRange(_dateRange(c.values[0], c.values[1], l));
    default:
      return _lowerFirst(_dateDisplay(c, l));
  }
}

// ---- readback

/// "In plain words" readback, generated from the tree: a subject (Expenses,
/// Income, Transfers, else Transactions), the date, then the other clauses
/// joined with commas. OR groups sit in brackets; a lone OR reads without.
String readbackOf(
  QueryNode node,
  AppLocalizations l,
  String Function(double) money,
) {
  final top = node is AndNode ? [...node.children] : [node];
  String subject = l.ahqRbTransactions;
  String? date;
  final rest = <String>[];
  var typeTaken = false;
  for (final n in top) {
    if (!typeTaken && n is ConditionNode && n.field == QueryField.type) {
      typeTaken = true;
      subject = _or(
          l,
          n.values.map((v) => switch (v) {
                'income' => l.ahqRbIncome,
                'transfer' => l.ahqRbTransfers,
                _ => l.ahqRbExpenses,
              }));
    } else if (date == null &&
        n is ConditionNode &&
        n.field == QueryField.date) {
      date = _datePhrase(n, l);
    } else {
      rest.add(_clause(n, l, money, topLevel: top.length == 1));
    }
  }
  final head = date == null ? subject : '$subject $date';
  if (rest.isEmpty) return head;
  return '$head ${rest.first}${rest.skip(1).map((x) => ', $x').join()}';
}

String _clause(QueryNode n, AppLocalizations l, String Function(double) m,
    {bool topLevel = false}) {
  switch (n) {
    case ConditionNode():
      return _condClause(n, l, m, negated: false);
    case NotNode():
      final c = n.child;
      if (c is ConditionNode) return _condClause(c, l, m, negated: true);
      return l.ahqRbNotGroup(_clause(c, l, m));
    case AndNode():
      final s = n.children.map((x) => _clause(x, l, m)).join(', ');
      return topLevel ? s : '($s)';
    case OrNode():
      final s = _or(l, n.children.map((x) => _clause(x, l, m)));
      return topLevel ? s : '($s)';
  }
}

String _condClause(ConditionNode c, AppLocalizations l,
    String Function(double) m, {required bool negated}) {
  String names() => _or(l, c.values);
  switch (c.field) {
    case QueryField.type:
      final t = _or(
          l,
          c.values.map((v) => switch (v) {
                'income' => l.ahqRbIncome,
                'transfer' => l.ahqRbTransfers,
                _ => l.ahqRbExpenses,
              }));
      return negated ? l.ahqRbNot(t) : t;
    case QueryField.amount:
      final a = c.op == QueryOp.eq ? l.ahqRbAmountIs(_amount(c, l, m)) : _amount(c, l, m);
      return negated ? l.ahqRbNot(a) : a;
    case QueryField.category:
      return negated ? l.ahqRbNotIn(names()) : l.ahqRbIn(names());
    case QueryField.account:
      return negated ? l.ahqRbNotFrom(names()) : l.ahqRbFrom(names());
    case QueryField.tag:
      if (c.values.length == 1 && c.values.first == 'none') {
        return negated ? l.ahqRbHasTags : l.ahqRbNoTags;
      }
      final t = _or(l, c.values.map((v) => v == 'none' ? l.ahqNone : '#$v'));
      return negated ? l.ahqRbNotTagged(t) : l.ahqRbTagged(t);
    case QueryField.date:
      final d = _datePhrase(c, l);
      return negated ? l.ahqRbNot(d) : d;
    case QueryField.has:
      final att = c.values.first == 'attachment';
      if (att) {
        return negated ? l.ahqRbWithoutAttachment : l.ahqRbWithAttachment;
      }
      return negated ? l.ahqRbWithoutNote : l.ahqRbWithNote;
    case QueryField.source:
      final s = _or(
          l,
          c.values.map((v) => switch (v) {
                'sms' => l.ahqRbSms,
                'quickadd' => l.ahqRbQuickAdd,
                'recurring' => l.ahqRbRecurring,
                'import' => l.ahqRbImported,
                _ => l.ahqRbManual,
              }));
      return negated ? l.ahqRbNot(s) : s;
    case QueryField.subType:
      final k = l.ahqRbKind(_or(l, c.values.map((v) => _subName(v, l))));
      return negated ? l.ahqRbNot(k) : k;
    case QueryField.words:
      final t = c.values.join(' ${l.ahqOr} ');
      return negated ? l.ahqRbNoWords(t) : l.ahqRbWords(t);
  }
}

/// Plain-English message for an error (design copy).
String queryErrorMessage(QueryError e, AppLocalizations l) {
  String arg(int i) => i < e.args.length ? e.args[i] : '';
  switch (e.code) {
    case QueryErrorCode.missingClose:
      return arg(0).isEmpty
          ? l.ahqErrCloseBracket
          : l.ahqErrCloseBracketAfter(arg(0));
    case QueryErrorCode.missingOpen:
      return l.ahqErrOpenBracket;
    case QueryErrorCode.unknownField:
      return arg(1).isEmpty
          ? l.ahqErrFieldPlain(arg(0))
          : l.ahqErrField(arg(0), arg(1));
    case QueryErrorCode.badAmount:
      return l.ahqErrAmount;
    case QueryErrorCode.badDate:
      return l.ahqErrDate;
    case QueryErrorCode.unknownValue:
      final f = QueryField.fromKeyword(arg(0));
      final field = f == null ? arg(0) : fieldLabel(f, l).toLowerCase();
      return arg(2).isEmpty
          ? l.ahqErrValue(field, arg(1))
          : l.ahqErrValueDid(field, arg(1), arg(2));
    case QueryErrorCode.joinerNeedsBothSides:
      return l.ahqErrOr;
    case QueryErrorCode.emptyGroup:
      return l.ahqErrEmptyGroup;
    case QueryErrorCode.badToken:
      return l.ahqErrBadToken(arg(0));
  }
}

/// Group / chart-point name. The data layer returns raw names (the group's
/// name, or the key for type / source / month / year); `''` is "Untagged" or
/// "No category" and `__other` is the donut's "Other".
String ahGroupLabel(AhGroupBy by, String key, String raw, AppLocalizations l) {
  if (key == '__other') return l.ahqOther;
  if (key.isEmpty) {
    return by == AhGroupBy.tag ? l.ahqUntagged : l.ahqNoCategory;
  }
  switch (by) {
    case AhGroupBy.type:
      return _typeName(key, l);
    case AhGroupBy.source:
      return _sourceName(key, l);
    case AhGroupBy.month:
      final p = key.split('-');
      if (p.length == 2) {
        return _fmt('MMM y', DateTime(int.parse(p[0]), int.parse(p[1])), l);
      }
      return key;
    case AhGroupBy.year:
    case AhGroupBy.none:
      return key;
    case AhGroupBy.category:
    case AhGroupBy.account:
    case AhGroupBy.tag:
      return raw.isEmpty ? l.ahqUnknown : raw;
  }
}
