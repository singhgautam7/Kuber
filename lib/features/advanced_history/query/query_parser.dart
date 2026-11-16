// Advanced History query text <-> items <-> tree. Pure Dart, no data access.
//
// Grammar (precedence NOT > AND > OR, a space between operands is AND):
//   token    := field ':' [op] value | '"' words '"' | bareword
//   value    := v | v ',' v ... | '(' v 'OR' v ... ')' | a '..' b (amount, date)
//   op       := '>' | '<' | '>=' | '<='  (amount and date only)
//   operand  := ('not' | '-')* (token | '(' expr ')')
// `category:food OR category:travel` stays two tokens joined by `or`; only the
// comma and bracket forms make one multi-value token.

import '../../transactions/data/transaction.dart' show TxnSubType;
import 'query_ast.dart';

// ---------------------------------------------------------------------------
// Public API

/// Text to normalised items. Never throws: text that doesn't parse becomes a
/// [TokenItem] with a null condition. A joiner sits between every two operands.
List<QueryItem> tokenize(String text) {
  final items = <QueryItem>[];
  void operandStart() {
    if (items.isNotEmpty && (items.last is TokenItem || items.last is CloseItem)) {
      items.add(const JoinerItem(isOr: false));
    }
  }

  final n = text.length;
  var i = 0;
  while (i < n) {
    final c = text[i];
    if (_isSpace(c)) {
      i++;
    } else if (c == '(') {
      operandStart();
      items.add(const OpenItem());
      i++;
    } else if (c == ')') {
      items.add(const CloseItem());
      i++;
    } else if (c == '-' && i + 1 < n && !_isSpace(text[i + 1])) {
      operandStart();
      items.add(const NotItem());
      i++;
    } else {
      final end = _wordEnd(text, i);
      final raw = text.substring(i, end);
      i = end;
      final lower = raw.toLowerCase();
      if (lower == 'and' || lower == 'or') {
        items.add(JoinerItem(isOr: lower == 'or'));
      } else if (lower == 'not') {
        operandStart();
        items.add(const NotItem());
      } else {
        operandStart();
        final r = _parseTokenText(raw);
        items.add(r.node == null
            ? TokenItem(raw, null)
            : TokenItem(conditionText(r.node!), r.node));
      }
    }
  }
  return items;
}

/// Canonical text for items (round-trips through [tokenize]).
String serializeItems(List<QueryItem> items) {
  final sb = StringBuffer();
  QueryItem? prev;
  for (final it in items) {
    final noSpace = prev == null || prev is OpenItem || it is CloseItem;
    if (!noSpace) sb.write(' ');
    sb.write(switch (it) {
      TokenItem() => it.text,
      JoinerItem() => it.isOr ? 'or' : 'and',
      NotItem() => 'not',
      OpenItem() => '(',
      CloseItem() => ')',
    });
    prev = it;
  }
  return sb.toString();
}

/// Items to tree (NOT > AND > OR), errors with item positions, and the boxes
/// to draw (explicit brackets and implicit and/or grouping, with depth).
/// Unmatched brackets give `node: null`.
ParseResult parseItems(List<QueryItem> items) => _Parser(items).run();

/// Tree to canonical text / items. Only the brackets the tree needs are
/// written (OR inside AND, nested groups of the same kind, groups under NOT).
String serializeNode(QueryNode node) => serializeItems(itemsFromNode(node));

List<QueryItem> itemsFromNode(QueryNode node) {
  final out = <QueryItem>[];
  _emit(node, out, _Ctx.none);
  return out;
}

/// Number of filters (tokens) for the badge: joiners, nots and brackets
/// don't count.
int tokenCount(List<QueryItem> items) => items.whereType<TokenItem>().length;

/// Flips the joiner at [joinerIndex]. and -> or wraps both neighbours in
/// brackets (or joins an adjacent OR group, flattening same-operator
/// nesting); or -> and removes brackets that are no longer needed.
/// Returns [items] unchanged when the index isn't a joiner between two
/// operands or the brackets don't match.
List<QueryItem> flipJoiner(List<QueryItem> items, int joinerIndex) {
  final j = joinerIndex;
  if (j <= 0 || j >= items.length - 1) return items;
  final joiner = items[j];
  if (joiner is! JoinerItem) return items;
  final pairs = _pairs(items);
  if (pairs == null) return items;
  return joiner.isOr
      ? _orToAnd(items, j, pairs)
      : _andToOr(items, j, pairs);
}

// ---------------------------------------------------------------------------
// Value validation against the user's data (kept out of parsing)

/// Names the user has, for [validateValues].
class AhLookup {
  const AhLookup({
    this.categories = const [],
    this.categoryGroups = const [],
    this.accounts = const [],
    this.tags = const [],
  });
  final List<String> categories;
  final List<String> categoryGroups;
  final List<String> accounts;
  final List<String> tags;
}

/// `unknownValue` errors (with the closest name as `args[2]`, or '') for
/// category / account / tag values that match nothing. Pure parsing never
/// calls this; the Filter page does, with the user's names.
List<QueryError> validateValues(List<QueryItem> items, AhLookup lookup) {
  final errors = <QueryError>[];
  final cats = [...lookup.categories, ...lookup.categoryGroups];
  for (var i = 0; i < items.length; i++) {
    final it = items[i];
    if (it is! TokenItem || it.condition == null) continue;
    final c = it.condition!;
    for (final v in c.values) {
      final lv = v.toLowerCase();
      bool ok;
      List<String> pool;
      switch (c.field) {
        case QueryField.category:
          pool = cats;
          ok = cats.any((x) => x.toLowerCase() == lv);
        case QueryField.account:
          pool = lookup.accounts;
          ok = lookup.accounts.any((x) => x.toLowerCase().contains(lv));
        case QueryField.tag:
          pool = lookup.tags;
          ok = lv == 'none' || lookup.tags.any((x) => x.toLowerCase() == lv);
        default:
          continue;
      }
      if (!ok) {
        errors.add(QueryError(QueryErrorCode.unknownValue, i,
            [c.field.keyword, v, closestName(v, pool)]));
      }
    }
  }
  return errors;
}

/// The name in [names] closest to [input] (prefix, contains or a small edit
/// distance), or '' when none is near.
String closestName(String input, Iterable<String> names) {
  final i = input.toLowerCase().trim();
  if (i.isEmpty) return '';
  final limit = i.length <= 4 ? 1 : (i.length ~/ 3).clamp(2, 4);
  String best = '';
  var bestScore = 1 << 30;
  for (final name in names) {
    final l = name.toLowerCase();
    if (l == i) return name;
    var d = _lev(i, l);
    if (l.startsWith(i) || i.startsWith(l)) {
      d = 0;
    } else if (i.length >= 3 && l.contains(i)) {
      d = 1;
    }
    if (d <= limit && d < bestScore) {
      best = name;
      bestScore = d;
    }
  }
  return best;
}

/// Canonical text of one filter (`category:food,travel`, `"swiggy"`).
String conditionText(ConditionNode c) {
  if (c.field == QueryField.words && c.values.length == 1 && c.op == QueryOp.eq) {
    return _quote(c.values.first);
  }
  final k = c.field.keyword;
  switch (c.op) {
    case QueryOp.range:
      return '$k:${c.values[0]}..${c.values[1]}';
    case QueryOp.eq:
      return '$k:${c.values.map(_fmtVal).join(',')}';
    case QueryOp.gt:
      return '$k:>${_fmtVal(c.values.first)}';
    case QueryOp.lt:
      return '$k:<${_fmtVal(c.values.first)}';
    case QueryOp.gte:
      return '$k:>=${_fmtVal(c.values.first)}';
    case QueryOp.lte:
      return '$k:<=${_fmtVal(c.values.first)}';
  }
}

/// Quotes a value for query text when it needs it (`"Food & Dining"`).
String quoteValue(String v) => _fmtVal(v);

// ---------------------------------------------------------------------------
// Lexing helpers

bool _isSpace(String c) => c == ' ' || c == '\t' || c == '\n' || c == '\r';

final _fieldColon = RegExp(r'^[A-Za-z]+:(>=|<=|>|<)?$');

/// End (exclusive) of the word starting at [start]: runs to whitespace or a
/// bracket, except quoted text and a `field:( ... )` group are part of it.
int _wordEnd(String t, int start) {
  var i = start;
  final n = t.length;
  while (i < n) {
    final c = t[i];
    if (_isSpace(c) || c == ')') break;
    if (c == '(') {
      if (_fieldColon.hasMatch(t.substring(start, i))) {
        i = _groupEnd(t, i);
        break;
      }
      break;
    }
    if (c == '"') {
      i = _quoteEnd(t, i);
      continue;
    }
    i++;
  }
  return i;
}

/// Index after the closing quote of the quote opening at [i] (or the end).
int _quoteEnd(String t, int i) {
  var j = i + 1;
  while (j < t.length) {
    if (t[j] == '\\' && j + 1 < t.length) {
      j += 2;
      continue;
    }
    if (t[j] == '"') return j + 1;
    j++;
  }
  return t.length;
}

/// Index after the `)` matching the `(` at [i] (or the end).
int _groupEnd(String t, int i) {
  var depth = 0;
  var j = i;
  while (j < t.length) {
    final c = t[j];
    if (c == '"') {
      j = _quoteEnd(t, j);
      continue;
    }
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return j + 1;
    }
    j++;
  }
  return t.length;
}

String _quote(String v) =>
    '"${v.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';

String _unescape(String s) => s.replaceAllMapped(
    RegExp(r'\\(["\\])'), (m) => m.group(1)!);

/// The inside of a fully quoted string, or null when [raw] isn't exactly one.
String? _unquoteWhole(String raw) {
  if (raw.length < 2 || raw[0] != '"') return null;
  final end = _quoteEnd(raw, 0);
  if (end != raw.length || raw[raw.length - 1] != '"') return null;
  return _unescape(raw.substring(1, raw.length - 1));
}

final _needsQuote = RegExp(r'''[\s,()"\\]''');

String _fmtVal(String v) {
  if (v.isEmpty ||
      _needsQuote.hasMatch(v) ||
      v.startsWith('>') ||
      v.startsWith('<') ||
      v.startsWith('=') ||
      v.toLowerCase() == 'or') {
    return _quote(v);
  }
  return v;
}

/// Values of `a,b`, `(a OR b)` or `"a b",c`. Null on an unterminated quote.
List<String>? _splitValues(String s) {
  var t = s.trim();
  if (t.startsWith('(')) {
    t = t.substring(1);
    if (t.endsWith(')')) t = t.substring(0, t.length - 1);
  }
  final out = <String>[];
  var i = 0;
  while (i < t.length) {
    final c = t[i];
    if (_isSpace(c) || c == ',') {
      i++;
    } else if (c == '"') {
      final end = _quoteEnd(t, i);
      if (end > t.length || t[end - 1] != '"' || end - i < 2) return null;
      out.add(_unescape(t.substring(i + 1, end - 1)));
      i = end;
    } else {
      var j = i;
      while (j < t.length && !_isSpace(t[j]) && t[j] != ',') {
        j++;
      }
      final w = t.substring(i, j);
      if (w.toLowerCase() != 'or') out.add(w);
      i = j;
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
// One token's text -> condition (or the error it deserves)

class _Cond {
  const _Cond.ok(ConditionNode this.node)
      : code = null,
        args = const [];
  const _Cond.err(QueryErrorCode this.code, [this.args = const []]) : node = null;
  final ConditionNode? node;
  final QueryErrorCode? code;
  final List<String> args;
}

final _alpha = RegExp(r'^[A-Za-z]+$');
final _keywords = [for (final f in QueryField.values) f.keyword];

_Cond _parseTokenText(String raw) {
  if (raw.startsWith('"')) {
    final v = _unquoteWhole(raw);
    if (v == null || v.trim().isEmpty) return _Cond.err(QueryErrorCode.badToken, [raw]);
    return _Cond.ok(ConditionNode(QueryField.words, QueryOp.eq, [v]));
  }
  final colon = raw.indexOf(':');
  if (colon > 0 && _alpha.hasMatch(raw.substring(0, colon))) {
    return _parseField(raw.substring(0, colon), raw.substring(colon + 1), raw);
  }
  return _Cond.ok(ConditionNode(QueryField.words, QueryOp.eq, [raw]));
}

const _types = ['expense', 'income', 'transfer'];
const _hasValues = ['attachment', 'note'];
const _sources = ['manual', 'sms', 'quickadd', 'recurring', 'import'];

_Cond _parseField(String name, String rest, String raw) {
  final f = QueryField.fromKeyword(name);
  if (f == null) {
    return _Cond.err(
        QueryErrorCode.unknownField, [name, closestName(name, _keywords)]);
  }
  var op = QueryOp.eq;
  var body = rest;
  for (final p in const ['>=', '<=', '>', '<']) {
    if (body.startsWith(p)) {
      op = switch (p) {
        '>=' => QueryOp.gte,
        '<=' => QueryOp.lte,
        '>' => QueryOp.gt,
        _ => QueryOp.lt,
      };
      body = body.substring(p.length);
      break;
    }
  }
  final numeric = f == QueryField.amount || f == QueryField.date;
  if (op != QueryOp.eq && !numeric) return _Cond.err(QueryErrorCode.badToken, [raw]);
  final vals = _splitValues(body);
  if (vals == null || vals.isEmpty) return _Cond.err(QueryErrorCode.badToken, [raw]);
  if (op != QueryOp.eq && vals.length != 1) {
    return _Cond.err(QueryErrorCode.badToken, [raw]);
  }

  ConditionNode ok(QueryOp o, List<String> v) => ConditionNode(f, o, v);

  switch (f) {
    case QueryField.amount:
    case QueryField.date:
      final isAmount = f == QueryField.amount;
      final code = isAmount ? QueryErrorCode.badAmount : QueryErrorCode.badDate;
      String? one(String v) => isAmount ? _amount(v) : _date(v);
      if (op == QueryOp.eq && vals.length == 1 && vals.first.contains('..')) {
        final parts = vals.first.split('..');
        if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
          return _Cond.err(code, [vals.first]);
        }
        var a = one(parts[0]);
        var b = one(parts[1]);
        if (a == null) return _Cond.err(code, [parts[0]]);
        if (b == null) return _Cond.err(code, [parts[1]]);
        if (isAmount && double.parse(a) > double.parse(b)) {
          final t = a;
          a = b;
          b = t;
        }
        return _Cond.ok(ok(QueryOp.range, [a, b]));
      }
      final out = <String>[];
      for (final v in vals) {
        final x = one(v);
        if (x == null) return _Cond.err(code, [v]);
        out.add(x);
      }
      return _Cond.ok(ok(op, out));
    case QueryField.type:
      return _fixed(f, vals, _types, (v) => v);
    case QueryField.has:
      return _fixed(f, vals, _hasValues, (v) => v);
    case QueryField.source:
      return _fixed(f, vals, _sources, (v) => v);
    case QueryField.subType:
      final names = [for (final s in TxnSubType.values) s.name];
      String? norm(String v) {
        final k = v.toLowerCase().replaceAll('_', '');
        for (final s in TxnSubType.values) {
          if (s.name.toLowerCase() == k) return s.name;
        }
        return null;
      }

      final out = <String>[];
      for (final v in vals) {
        final x = norm(v);
        if (x == null) {
          return _Cond.err(QueryErrorCode.unknownValue,
              [f.keyword, v, closestName(v, names)]);
        }
        out.add(x);
      }
      return _Cond.ok(ok(QueryOp.eq, out));
    case QueryField.tag:
      final out = <String>[];
      for (var v in vals) {
        v = v.trim();
        if (v.startsWith('#')) v = v.substring(1);
        if (v.isEmpty) return _Cond.err(QueryErrorCode.badToken, [raw]);
        out.add(v.toLowerCase() == 'none' ? 'none' : v);
      }
      return _Cond.ok(ok(QueryOp.eq, out));
    case QueryField.category:
    case QueryField.account:
    case QueryField.words:
      final out = [for (final v in vals) v.trim()];
      if (out.any((v) => v.isEmpty)) return _Cond.err(QueryErrorCode.badToken, [raw]);
      return _Cond.ok(ok(QueryOp.eq, out));
  }
}

_Cond _fixed(QueryField f, List<String> vals, List<String> allowed,
    String Function(String) map) {
  final out = <String>[];
  for (final v in vals) {
    final x = map(v.toLowerCase());
    if (!allowed.contains(x)) {
      return _Cond.err(
          QueryErrorCode.unknownValue, [f.keyword, v, closestName(v, allowed)]);
    }
    out.add(x);
  }
  return _Cond.ok(ConditionNode(f, QueryOp.eq, out));
}

String? _amount(String v) {
  var s = v.trim();
  // A typed currency sign or code in front of the number is ignored.
  s = s.replaceFirst(RegExp(r'^[^\d.]+'), '');
  final d = double.tryParse(s);
  if (d == null || d.isNaN || d.isInfinite || d < 0) return null;
  return d == d.roundToDouble() && d < 1e15 ? d.toInt().toString() : d.toString();
}

final _relDays = RegExp(r'^last(\d+)d$');
final _ymd = RegExp(r'^(\d{4})(?:-(\d{1,2})(?:-(\d{1,2}))?)?$');

/// Canonical date value, or null. Years 1900..2200.
String? _date(String v) {
  final s = v.trim().toLowerCase();
  if (const ['thismonth', 'lastmonth', 'thisyear', 'lastyear'].contains(s)) return s;
  final r = _relDays.firstMatch(s);
  if (r != null) {
    final n = int.tryParse(r.group(1)!);
    return n != null && n >= 1 && n <= 36500 ? 'last${n}d' : null;
  }
  final m = _ymd.firstMatch(s);
  if (m == null) return null;
  final y = int.parse(m.group(1)!);
  if (y < 1900 || y > 2200) return null;
  if (m.group(2) == null) return '$y';
  final mo = int.parse(m.group(2)!);
  if (mo < 1 || mo > 12) return null;
  final ms = mo.toString().padLeft(2, '0');
  if (m.group(3) == null) return '$y-$ms';
  final d = int.parse(m.group(3)!);
  final dt = DateTime(y, mo, d);
  if (dt.year != y || dt.month != mo || dt.day != d) return null;
  return '$y-$ms-${d.toString().padLeft(2, '0')}';
}

int _lev(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost]
          .reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

// ---------------------------------------------------------------------------
// Parsing

/// Bracket pairs both ways (open->close and close->open), or null when any
/// bracket is unmatched.
Map<int, int>? _pairs(List<QueryItem> items) {
  final map = <int, int>{};
  final stack = <int>[];
  for (var i = 0; i < items.length; i++) {
    final it = items[i];
    if (it is OpenItem) {
      stack.add(i);
    } else if (it is CloseItem) {
      if (stack.isEmpty) return null;
      final o = stack.removeLast();
      map[o] = i;
      map[i] = o;
    }
  }
  return stack.isEmpty ? map : null;
}

class _Parser {
  _Parser(this.items);
  final List<QueryItem> items;
  final errors = <QueryError>[];
  final implicit = <GroupBox>[];
  final open = <int, int>{}; // open -> close
  final close = <int>{};

  ParseResult run() {
    if (items.isEmpty) return const ParseResult(node: null);
    final stack = <int>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      if (it is OpenItem) {
        stack.add(i);
      } else if (it is CloseItem) {
        if (stack.isEmpty) {
          errors.add(QueryError(QueryErrorCode.missingOpen, i));
        } else {
          open[stack.removeLast()] = i;
        }
      }
    }
    for (final o in stack) {
      var last = '';
      for (var k = o + 1; k < items.length; k++) {
        final it = items[k];
        if (it is TokenItem) last = it.text;
      }
      errors.add(QueryError(QueryErrorCode.missingClose, o, [last]));
    }
    if (errors.isNotEmpty) {
      // Unmatched brackets: no tree, but still report bad tokens.
      for (var i = 0; i < items.length; i++) {
        final it = items[i];
        if (it is TokenItem) _cond(it, i);
      }
      errors.sort((a, b) => a.itemIndex.compareTo(b.itemIndex));
      return ParseResult(node: null, errors: errors, boxes: _boxes());
    }
    final r = _range(0, items.length);
    errors.sort((a, b) => a.itemIndex.compareTo(b.itemIndex));
    return ParseResult(
      node: errors.isEmpty ? r.node : null,
      errors: errors,
      boxes: _boxes(),
    );
  }

  List<GroupBox> _boxes() {
    final raw = <(int, int, bool)>[
      for (final e in open.entries) (e.key, e.value, false),
      for (final b in implicit) (b.start, b.end, true),
    ];
    final boxes = <GroupBox>[];
    for (final b in raw) {
      var depth = 1;
      for (final o in raw) {
        if (identical(o, b)) continue;
        if (o.$1 <= b.$1 && b.$2 <= o.$2 && (o.$1 != b.$1 || o.$2 != b.$2)) depth++;
      }
      boxes.add(GroupBox(b.$1, b.$2, depth, implicit: b.$3));
    }
    boxes.sort((a, b) {
      final c = a.start.compareTo(b.start);
      return c != 0 ? c : b.end.compareTo(a.end);
    });
    return boxes;
  }

  ConditionNode? _cond(TokenItem it, int idx) {
    if (it.condition != null) return it.condition;
    final r = _parseTokenText(it.text);
    if (r.node != null) return r.node;
    errors.add(QueryError(r.code ?? QueryErrorCode.badToken, idx, r.args));
    return null;
  }

  /// Items [s, e) (no unmatched brackets inside): OR of AND runs.
  ({QueryNode? node, int operands}) _range(int s, int e) {
    final segs = <(int, int)>[];
    final orIdx = <int>[];
    var segStart = s;
    var i = s;
    while (i < e) {
      final it = items[i];
      if (it is OpenItem) {
        i = open[i]! + 1;
      } else {
        if (it is JoinerItem && it.isOr) {
          segs.add((segStart, i));
          orIdx.add(i);
          segStart = i + 1;
        }
        i++;
      }
    }
    segs.add((segStart, e));
    final nodes = <QueryNode>[];
    final runs = <(int, int, int)>[]; // start, end, operand count
    for (var k = 0; k < segs.length; k++) {
      final (a, b) = segs[k];
      if (a >= b) {
        if (segs.length > 1) {
          errors.add(QueryError(
              QueryErrorCode.joinerNeedsBothSides, k < orIdx.length ? orIdx[k] : orIdx[k - 1]));
        }
        continue;
      }
      final r = _and(a, b);
      if (r.node != null) nodes.add(r.node!);
      runs.add((a, b - 1, r.operands));
    }
    if (segs.length > 1) {
      for (final (a, b, count) in runs) {
        if (count >= 2) implicit.add(GroupBox(a, b, 1, implicit: true));
      }
    }
    final node = nodes.isEmpty
        ? null
        : nodes.length == 1
            ? nodes.first
            : OrNode(nodes);
    return (node: node, operands: segs.length);
  }

  ({QueryNode? node, int operands}) _and(int a, int b) {
    final nodes = <QueryNode>[];
    var operands = 0;
    var i = a;
    var needOperand = true;
    var lastJoiner = -1;
    while (i < b) {
      final it = items[i];
      if (it is JoinerItem) {
        if (needOperand) {
          errors.add(QueryError(QueryErrorCode.joinerNeedsBothSides, i));
        } else {
          needOperand = true;
          lastJoiner = i;
        }
        i++;
        continue;
      }
      final r = _operand(i, b);
      operands++;
      if (r.node != null) nodes.add(r.node!);
      i = r.next;
      needOperand = false;
    }
    if (needOperand && lastJoiner >= 0) {
      errors.add(QueryError(QueryErrorCode.joinerNeedsBothSides, lastJoiner));
    }
    final node = nodes.isEmpty
        ? null
        : nodes.length == 1
            ? nodes.first
            : AndNode(nodes);
    return (node: node, operands: operands);
  }

  ({QueryNode? node, int next}) _operand(int i, int b) {
    var j = i;
    var nots = 0;
    while (j < b && items[j] is NotItem) {
      nots++;
      j++;
    }
    if (j >= b) {
      errors.add(QueryError(QueryErrorCode.badToken, i - 0, ['not']));
      return (node: null, next: b);
    }
    QueryNode? node;
    final it = items[j];
    if (it is TokenItem) {
      node = _cond(it, j);
      j++;
    } else if (it is OpenItem) {
      final c = open[j]!;
      if (c == j + 1) {
        errors.add(QueryError(QueryErrorCode.emptyGroup, j));
      } else {
        node = _range(j + 1, c).node;
      }
      j = c + 1;
    } else {
      // A joiner right after `not`.
      errors.add(QueryError(QueryErrorCode.joinerNeedsBothSides, j));
      j++;
    }
    if (node != null) {
      for (var k = 0; k < nots; k++) {
        node = NotNode(node!);
      }
    }
    return (node: node, next: j);
  }
}

// ---------------------------------------------------------------------------
// Tree -> items

enum _Ctx { none, and, or, not }

void _emit(QueryNode n, List<QueryItem> out, _Ctx parent) {
  switch (n) {
    case ConditionNode():
      out.add(TokenItem(conditionText(n), n));
    case NotNode():
      out.add(const NotItem());
      final c = n.child;
      if (c is ConditionNode || c is NotNode) {
        _emit(c, out, _Ctx.not);
      } else {
        out.add(const OpenItem());
        _emit(c, out, _Ctx.none);
        out.add(const CloseItem());
      }
    case AndNode():
      if (n.children.length == 1) return _emit(n.children.first, out, parent);
      final wrap = parent == _Ctx.and || parent == _Ctx.not;
      if (wrap) out.add(const OpenItem());
      for (var i = 0; i < n.children.length; i++) {
        if (i > 0) out.add(const JoinerItem(isOr: false));
        _emit(n.children[i], out, _Ctx.and);
      }
      if (wrap) out.add(const CloseItem());
    case OrNode():
      if (n.children.length == 1) return _emit(n.children.first, out, parent);
      final wrap = parent != _Ctx.none;
      if (wrap) out.add(const OpenItem());
      for (var i = 0; i < n.children.length; i++) {
        if (i > 0) out.add(const JoinerItem(isOr: true));
        _emit(n.children[i], out, _Ctx.or);
      }
      if (wrap) out.add(const CloseItem());
  }
}

// ---------------------------------------------------------------------------
// flipJoiner

/// Start index of the operand ending at [end] (its leading nots included),
/// or -1.
int _operandStart(List<QueryItem> items, int end, Map<int, int> pairs) {
  int s;
  final it = items[end];
  if (it is TokenItem) {
    s = end;
  } else if (it is CloseItem) {
    s = pairs[end]!;
  } else {
    return -1;
  }
  while (s > 0 && items[s - 1] is NotItem) {
    s--;
  }
  return s;
}

/// End index (inclusive) of the operand starting at [start] (nots skipped),
/// or -1.
int _operandEnd(List<QueryItem> items, int start, Map<int, int> pairs) {
  var e = start;
  while (e < items.length && items[e] is NotItem) {
    e++;
  }
  if (e >= items.length) return -1;
  final it = items[e];
  if (it is TokenItem) return e;
  if (it is OpenItem) return pairs[e]!;
  return -1;
}

/// A bracket group whose own top-level joiners are all `or` (at least one).
bool _isOrGroup(List<QueryItem> items, int o, int c, Map<int, int> pairs) {
  if (items[o] is! OpenItem || pairs[o] != c) return false;
  var seen = false;
  var i = o + 1;
  while (i < c) {
    final it = items[i];
    if (it is OpenItem) {
      i = pairs[i]! + 1;
      continue;
    }
    if (it is JoinerItem) {
      if (!it.isOr) return false;
      seen = true;
    }
    i++;
  }
  return seen;
}

List<QueryItem> _andToOr(List<QueryItem> items, int j, Map<int, int> pairs) {
  final lEnd = j - 1;
  final lStart = _operandStart(items, lEnd, pairs);
  final rStart = j + 1;
  final rEnd = _operandEnd(items, rStart, pairs);
  if (lStart < 0 || rEnd < 0) return items;
  final lGroup = _isOrGroup(items, lStart, lEnd, pairs);
  final rGroup = _isOrGroup(items, rStart, rEnd, pairs);
  const or = JoinerItem(isOr: true);
  List<QueryItem> out;
  int o, c;
  if (lGroup && rGroup) {
    out = [...items.sublist(0, lEnd), or, ...items.sublist(rStart + 1)];
    o = lStart;
    c = rEnd - 2;
  } else if (lGroup) {
    out = [
      ...items.sublist(0, lEnd),
      or,
      ...items.sublist(rStart, rEnd + 1),
      const CloseItem(),
      ...items.sublist(rEnd + 1),
    ];
    o = lStart;
    c = rEnd;
  } else if (rGroup) {
    out = [
      ...items.sublist(0, lStart),
      const OpenItem(),
      ...items.sublist(lStart, lEnd + 1),
      or,
      ...items.sublist(rStart + 1),
    ];
    o = lStart;
    c = rEnd;
  } else {
    out = [
      ...items.sublist(0, lStart),
      const OpenItem(),
      ...items.sublist(lStart, lEnd + 1),
      or,
      ...items.sublist(rStart, rEnd + 1),
      const CloseItem(),
      ...items.sublist(rEnd + 1),
    ];
    o = lStart;
    c = rEnd + 2;
  }
  return _dissolveFlatOr(out, o, c);
}

/// `a or (b or c)` is `a or b or c`: drops the brackets of the OR group at
/// [o]..[c] when it sits in an OR chain (or alone inside another bracket).
List<QueryItem> _dissolveFlatOr(List<QueryItem> items, int o, int c) {
  if (o > 0 && items[o - 1] is NotItem) return items;
  // 0 = nothing / enclosing bracket edge, 1 = or, 2 = and
  int side(int idx, bool left) {
    if (idx < 0 || idx >= items.length) return 0;
    final it = items[idx];
    if (it is JoinerItem) return it.isOr ? 1 : 2;
    return 0;
  }

  final l = side(o - 1, true);
  final r = side(c + 1, false);
  if (l == 2 || r == 2) return items;
  final alone = l == 0 &&
      r == 0 &&
      o > 0 &&
      c + 1 < items.length &&
      items[o - 1] is OpenItem &&
      items[c + 1] is CloseItem;
  if (l == 1 || r == 1 || alone) {
    return [
      ...items.sublist(0, o),
      ...items.sublist(o + 1, c),
      ...items.sublist(c + 1),
    ];
  }
  return items;
}

List<QueryItem> _orToAnd(List<QueryItem> items, int j, Map<int, int> pairs) {
  final out = [...items];
  out[j] = const JoinerItem(isOr: false);
  // Smallest bracket pair around the joiner.
  int? o;
  for (var i = j - 1; i >= 0; i--) {
    final it = out[i];
    if (it is OpenItem && pairs[i]! > j) {
      o = i;
      break;
    }
  }
  if (o == null) return out;
  final c = pairs[o]!;
  if (o > 0 && out[o - 1] is NotItem) return out;
  var hasOr = false;
  var i = o + 1;
  while (i < c) {
    final it = out[i];
    if (it is OpenItem) {
      i = pairs[i]! + 1;
      continue;
    }
    if (it is JoinerItem && it.isOr) hasOr = true;
    i++;
  }
  if (hasOr) return out;
  return [...out.sublist(0, o), ...out.sublist(o + 1, c), ...out.sublist(c + 1)];
}
