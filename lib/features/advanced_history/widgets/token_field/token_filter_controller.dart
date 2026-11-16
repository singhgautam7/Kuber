import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../query/query_ast.dart';
import '../../query/query_parser.dart';

/// The buttons of the operator bar.
enum QueryOperator { open, close, and, or, not }

bool _isOperandStart(QueryItem i) =>
    i is TokenItem || i is NotItem || i is OpenItem;
bool _isOperandEnd(QueryItem i) => i is TokenItem || i is CloseItem;

/// State of a [TokenFilterField]: the flat item list, the cursor (a position
/// between items), the highlighted item and the token being edited in place.
///
/// The field, the operator bar and the field list all edit through this.
class TokenFilterController extends ChangeNotifier {
  TokenFilterController({List<QueryItem> items = const []}) {
    _items = List.of(items);
    _ids = [for (final _ in _items) _nextId++];
    cursor = _items.length;
    _reparse();
  }

  /// Owned here so the page can follow focus (docking the operator bar).
  final FocusNode focusNode = FocusNode();

  /// Time a deleted token stays on screen while it scales and fades out.
  Duration removeDelay = const Duration(milliseconds: 150);

  int _nextId = 0;
  late List<QueryItem> _items;
  late List<int> _ids;
  int cursor = 0;
  int? selected;
  int? editing;
  final Set<int> removing = {};
  final Set<int> fresh = {};
  Timer? _removeTimer;

  ParseResult _parsed = const ParseResult(node: null);
  QueryNode? _validNode;

  List<QueryItem> get items => List.unmodifiable(_items);
  List<int> get ids => List.unmodifiable(_ids);

  /// Items without a dangling joiner / not at the end (a picked filter is
  /// followed by "and" so the next pick continues the query).
  List<QueryItem> get effective {
    var n = _items.length;
    while (n > 0 && (_items[n - 1] is JoinerItem || _items[n - 1] is NotItem)) {
      n--;
    }
    return _items.sublist(0, n);
  }

  ParseResult get parsed => _parsed;

  List<QueryError> _extra = const [];
  AhLookup? _lookup;

  /// The user's category / account / tag names: unknown values become errors
  /// (parsing alone is data free).
  AhLookup? get lookup => _lookup;
  set lookup(AhLookup? v) {
    final same = _lookup != null &&
        v != null &&
        _eq(_lookup!.categories, v.categories) &&
        _eq(_lookup!.categoryGroups, v.categoryGroups) &&
        _eq(_lookup!.accounts, v.accounts) &&
        _eq(_lookup!.tags, v.tags);
    if (same) return;
    _lookup = v;
    _reparse();
    notifyListeners();
  }

  static bool _eq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Parse errors plus unknown-value errors.
  List<QueryError> get errors => [..._parsed.errors, ..._extra];

  /// The last tree that parsed cleanly (null = empty box).
  QueryNode? get validNode => _validNode;
  bool get isEmpty => effective.isEmpty;
  bool get isValid => _parsed.isValid && _extra.isEmpty;
  int get filterCount => tokenCount(_items);
  String get text => serializeItems(effective);

  void _reparse() {
    final eff = effective;
    if (eff.isEmpty) {
      _parsed = const ParseResult(node: null);
      _extra = const [];
      _validNode = null;
      return;
    }
    _parsed = parseItems(eff);
    _extra = _lookup == null ? const [] : validateValues(eff, _lookup!);
    if (isValid && _parsed.node != null) _validNode = _parsed.node;
  }

  void _changed() {
    _reparse();
    notifyListeners();
    if (fresh.isNotEmpty) {
      scheduleMicrotask(() => fresh.clear());
    }
  }

  // --- whole-list edits ----------------------------------------------------

  /// Replaces everything (page start, example chips, paste of a full query).
  void setItems(List<QueryItem> items, {int? cursor}) {
    _items = List.of(items);
    _ids = [for (final _ in _items) _nextId++];
    this.cursor = (cursor ?? _items.length).clamp(0, _items.length);
    selected = null;
    editing = null;
    removing.clear();
    _changed();
  }

  void setText(String text) => setItems(tokenize(text));

  void clear() => setItems(const []);

  void moveCursor(int slot) {
    final c = slot.clamp(0, _items.length);
    if (c == cursor && selected == null) return;
    cursor = c;
    selected = null;
    notifyListeners();
  }

  // --- insert --------------------------------------------------------------

  /// Inserts [news] at the cursor, adding the "and" a typed space would add.
  /// [trailingAnd] puts an "and" after a new filter (picker and sealed text).
  void insert(List<QueryItem> news, {bool trailingAnd = false}) {
    if (news.isEmpty) return;
    selected = null;
    final l = cursor > 0 ? _items[cursor - 1] : null;
    final r = cursor < _items.length ? _items[cursor] : null;
    var add = List<QueryItem>.of(news);
    if (add.first is JoinerItem) {
      // A joiner replaces a joiner before it; at the start or after "(" or
      // "not" it makes no sense and is dropped.
      if (l is JoinerItem) {
        _items[cursor - 1] = add.first;
        add = add.sublist(1);
        if (add.isEmpty) return _changed();
      } else if (l == null || l is OpenItem || l is NotItem) {
        add = add.sublist(1);
        if (add.isEmpty) return _changed();
      }
    }
    if (l != null && _isOperandEnd(l) && _isOperandStart(add.first)) {
      add.insert(0, const JoinerItem(isOr: false));
    }
    final last = add.last;
    if (_isOperandEnd(last) && r != null && _isOperandStart(r)) {
      add.add(const JoinerItem(isOr: false));
    } else if (trailingAnd && _isOperandEnd(last) && r == null) {
      add.add(const JoinerItem(isOr: false));
    } else if (trailingAnd &&
        _isOperandEnd(last) &&
        r != null &&
        r is! JoinerItem) {
      add.add(const JoinerItem(isOr: false));
    }
    final newIds = [for (final _ in add) _nextId++];
    _items.insertAll(cursor, add);
    _ids.insertAll(cursor, newIds);
    fresh.addAll(newIds);
    cursor += add.length;
    _changed();
  }

  void insertOperator(QueryOperator op) {
    if (!enabled(op)) return;
    insert(switch (op) {
      QueryOperator.open => const [OpenItem()],
      QueryOperator.close => const [CloseItem()],
      QueryOperator.and => const [JoinerItem(isOr: false)],
      QueryOperator.or => const [JoinerItem(isOr: true)],
      QueryOperator.not => const [NotItem()],
    });
  }

  /// Operator bar rules (design v1.2 note 6).
  bool enabled(QueryOperator op) {
    final prev = cursor > 0 ? _items[cursor - 1] : null;
    switch (op) {
      case QueryOperator.open:
        return true;
      case QueryOperator.close:
        var depth = 0;
        for (var i = 0; i < cursor; i++) {
          if (_items[i] is OpenItem) depth++;
          if (_items[i] is CloseItem) depth--;
        }
        return depth > 0 &&
            prev is! JoinerItem &&
            prev is! NotItem &&
            prev is! OpenItem;
      case QueryOperator.and:
      case QueryOperator.or:
        return prev != null &&
            prev is! OpenItem &&
            prev is! JoinerItem &&
            prev is! NotItem;
      case QueryOperator.not:
        return prev is! NotItem;
    }
  }

  // --- joiner ----------------------------------------------------------------

  void flip(int joinerIndex) {
    if (joinerIndex <= 0 ||
        joinerIndex >= _items.length - 1 ||
        _items[joinerIndex] is! JoinerItem) {
      return;
    }
    final old = _items;
    final oldIds = _ids;
    final next = flipJoiner(List.of(old), joinerIndex);
    // Keep ids per kind in order so tokens keep their widgets and a box that
    // forms or dissolves is a new / removed widget.
    final queues = <Type, List<int>>{};
    for (var i = 0; i < old.length; i++) {
      (queues[old[i].runtimeType] ??= []).add(oldIds[i]);
    }
    final newIds = <int>[];
    for (final it in next) {
      final q = queues[it.runtimeType];
      if (q != null && q.isNotEmpty) {
        newIds.add(q.removeAt(0));
      } else {
        final id = _nextId++;
        newIds.add(id);
      }
    }
    final cursorItem =
        cursor < old.length ? oldIds[cursor] : null; // keep cursor in place
    _items = next;
    _ids = newIds;
    cursor = cursorItem == null ? next.length : newIds.indexOf(cursorItem);
    if (cursor < 0) cursor = next.length;
    selected = null;
    _changed();
  }

  // --- in-place edit ---------------------------------------------------------

  void startEdit(int index) {
    if (index < 0 || index >= _items.length || _items[index] is! TokenItem) {
      return;
    }
    editing = index;
    cursor = index;
    selected = null;
    notifyListeners();
  }

  /// Ends an edit: [text] replaces the token (empty removes it).
  void commitEdit(String text) {
    final i = editing;
    if (i == null) return;
    editing = null;
    final news = tokenize(text.trim());
    if (news.isEmpty) {
      cursor = i;
      _removeAt(i, withJoiner: true);
      return _changed();
    }
    final same = news.length == 1 &&
        news.first is TokenItem &&
        (news.first as TokenItem).text == (_items[i] as TokenItem).text;
    if (same) {
      cursor = i + 1;
      return notifyListeners();
    }
    _items.removeAt(i);
    final id = _ids.removeAt(i);
    cursor = i;
    final before = _items.length;
    insert(news);
    // A single replacing token keeps its widget.
    if (news.length == 1 && _items.length == before + 1 && cursor == i + 1) {
      _ids[i] = id;
      fresh.remove(id);
    }
  }

  // --- backspace ---------------------------------------------------------------

  /// Backspace pressed with nothing typed: highlight the item before the
  /// cursor; a second one deletes it (and the joiner before it).
  void backspace() {
    if (editing != null) {
      final i = editing!;
      editing = null;
      cursor = i;
      _scheduleRemove(i, withJoiner: true);
      return;
    }
    if (selected != null) {
      final s = selected!;
      selected = null;
      _scheduleRemove(s, withJoiner: true);
      return;
    }
    if (cursor == 0) return;
    final prev = _items[cursor - 1];
    if (prev is JoinerItem && cursor == _items.length) {
      // A trailing joiner is just the "and" typing added.
      _removeAt(cursor - 1, withJoiner: false);
      return _changed();
    }
    selected = cursor - 1;
    notifyListeners();
  }

  void _scheduleRemove(int index, {required bool withJoiner}) {
    if (removeDelay == Duration.zero) {
      _removeAt(index, withJoiner: withJoiner);
      return _changed();
    }
    final group = _removalGroup(index, withJoiner);
    removing.addAll([for (final i in group) _ids[i]]);
    notifyListeners();
    final ids = {for (final i in group) _ids[i]};
    _removeTimer?.cancel();
    _removeTimer = Timer(removeDelay, () {
      final idx = [
        for (var i = 0; i < _ids.length; i++)
          if (ids.contains(_ids[i])) i
      ];
      if (idx.isEmpty) return;
      _removeIndexes(idx);
      removing.removeAll(ids);
      _changed();
    });
  }

  List<int> _removalGroup(int index, bool withJoiner) {
    final g = [index];
    final item = _items[index];
    if (withJoiner) {
      if (index > 0 && _items[index - 1] is JoinerItem && item is! JoinerItem) {
        g.add(index - 1);
      } else if (index + 1 < _items.length &&
          _items[index + 1] is JoinerItem &&
          item is! JoinerItem &&
          (index == 0 || _items[index - 1] is OpenItem)) {
        g.add(index + 1);
      } else if (item is JoinerItem && index > 0) {
        g.add(index - 1); // joiner + the operand before it
      }
    }
    return g;
  }

  void _removeAt(int index, {required bool withJoiner}) =>
      _removeIndexes(_removalGroup(index, withJoiner));

  void _removeIndexes(List<int> idx) {
    final sorted = idx.toSet().toList()..sort((a, b) => b.compareTo(a));
    var c = cursor;
    for (final i in sorted) {
      _items.removeAt(i);
      _ids.removeAt(i);
      if (i < c) c--;
    }
    cursor = c.clamp(0, _items.length);
    // A joiner left at the start, after "(" or twice in a row goes too.
    for (var i = _items.length - 1; i >= 0; i--) {
      if (_items[i] is! JoinerItem) continue;
      final p = i > 0 ? _items[i - 1] : null;
      final n = i + 1 < _items.length ? _items[i + 1] : null;
      final bad = p == null ||
          p is OpenItem ||
          p is JoinerItem ||
          p is NotItem ||
          n is CloseItem;
      if (bad) {
        _items.removeAt(i);
        _ids.removeAt(i);
        if (i < cursor) cursor--;
      }
    }
    selected = null;
  }

  @override
  void dispose() {
    _removeTimer?.cancel();
    focusNode.dispose();
    super.dispose();
  }
}
