// Advanced History query model: the one expression tree every part of the
// feature renders from (tokens, joiners, boxes, readback) and runs (Isar).
//
// CONTRACT FILE. Owned by H-data. H-token and H-UI build against these
// types; changing a public name or shape here must be reported to the main
// agent.
//
// Two shapes:
// * [QueryNode]: the evaluated tree. NOT binds tighter than AND, AND tighter
//   than OR. A space between operands means AND.
// * [QueryItem]: the flat, editable list the token field shows. It may be
//   invalid (unmatched brackets, half-typed tokens); [parseItems] turns it
//   into a [QueryNode] plus errors and [GroupBox]es for rendering.

/// Query keywords stay English in every language (`category`, `and`, ...).
enum QueryField {
  type,
  amount,
  category,
  account,
  tag,
  date,
  words,
  has,
  source,
  subType;

  /// Keyword used in query text (`subType` is typed `subtype`).
  String get keyword => this == QueryField.subType ? 'subtype' : name;

  static QueryField? fromKeyword(String k) {
    final l = k.toLowerCase();
    for (final f in values) {
      if (f.keyword == l) return f;
    }
    return null;
  }
}

/// `:` eq, `:>` gt, `:<` lt, `:>=` gte, `:<=` lte, `a..b` range.
enum QueryOp { eq, gt, lt, gte, lte, range }

sealed class QueryNode {
  const QueryNode();

  Map<String, dynamic> toJson();

  static QueryNode fromJson(Map<String, dynamic> j) {
    switch (j['k']) {
      case 'and':
        return AndNode([
          for (final c in (j['c'] as List)) fromJson(Map<String, dynamic>.from(c)),
        ]);
      case 'or':
        return OrNode([
          for (final c in (j['c'] as List)) fromJson(Map<String, dynamic>.from(c)),
        ]);
      case 'not':
        return NotNode(fromJson(Map<String, dynamic>.from(j['c'])));
      default:
        return ConditionNode(
          QueryField.values.byName(j['f'] as String),
          QueryOp.values.byName(j['o'] as String),
          List<String>.from(j['v'] as List),
        );
    }
  }
}

class AndNode extends QueryNode {
  const AndNode(this.children);
  final List<QueryNode> children;
  @override
  Map<String, dynamic> toJson() =>
      {'k': 'and', 'c': [for (final c in children) c.toJson()]};
}

class OrNode extends QueryNode {
  const OrNode(this.children);
  final List<QueryNode> children;
  @override
  Map<String, dynamic> toJson() =>
      {'k': 'or', 'c': [for (final c in children) c.toJson()]};
}

class NotNode extends QueryNode {
  const NotNode(this.child);
  final QueryNode child;
  @override
  Map<String, dynamic> toJson() => {'k': 'not', 'c': child.toJson()};
}

/// One filter. Several [values] of one field are OR'd
/// (`category:food,travel` = Food or Travel). Values are canonical strings:
/// * type: `expense` | `income` | `transfer`
/// * amount: `500` (eq/gt/lt/gte/lte) or `500`,`2000` (range). Absolute value.
/// * category / account / tag: names as typed, matched case-insensitively.
///   tag `none` = untagged.
/// * date: `2026`, `2026-03`, `2026-03-14`, relative `thismonth`,
///   `lastmonth`, `thisyear`, `lastyear`, `last30d` (any `lastNd`), or a
///   range of two of those.
/// * words: free text, matched (contains, case-insensitive) in title and notes.
/// * has: `attachment` | `note`
/// * source: `manual` | `sms` | `quickadd` | `recurring` | `import`
/// * subType: a `TxnSubType` name.
class ConditionNode extends QueryNode {
  const ConditionNode(this.field, this.op, this.values);
  final QueryField field;
  final QueryOp op;
  final List<String> values;
  @override
  Map<String, dynamic> toJson() =>
      {'k': 'cond', 'f': field.name, 'o': op.name, 'v': values};
}

// ---------------------------------------------------------------------------
// Editable items (what the token field shows)

sealed class QueryItem {
  const QueryItem();
}

/// A sealed token. [condition] is null while the text doesn't parse
/// (shown in the error style); [text] is the canonical text of the token
/// (`category:food,travel`, `"swiggy"`).
class TokenItem extends QueryItem {
  const TokenItem(this.text, this.condition);
  final String text;
  final ConditionNode? condition;
}

/// `and` / `or` between two operands. Normalised item lists always have a
/// joiner between operands (a typed space becomes `and`).
class JoinerItem extends QueryItem {
  const JoinerItem({required this.isOr});
  final bool isOr;
}

/// `not` / `-` before a token or an open bracket.
class NotItem extends QueryItem {
  const NotItem();
}

class OpenItem extends QueryItem {
  const OpenItem();
}

class CloseItem extends QueryItem {
  const CloseItem();
}

/// A box to draw around items [start]..[end] (inclusive item indexes).
/// [depth] 1 = outermost. [implicit] = the grouping the app applies to mixed
/// and/or without brackets (dashed box). Depth > 3 renders as bracket tokens.
class GroupBox {
  const GroupBox(this.start, this.end, this.depth, {this.implicit = false});
  final int start;
  final int end;
  final int depth;
  final bool implicit;
}

enum QueryErrorCode {
  missingClose,
  missingOpen,
  unknownField,
  badAmount,
  badDate,
  unknownValue,
  joinerNeedsBothSides,
  emptyGroup,
  badToken,
}

/// [itemIndex] points at the offending item; [args] fill the l10n message
/// (e.g. the unknown field name and a suggestion).
class QueryError {
  const QueryError(this.code, this.itemIndex, [this.args = const []]);
  final QueryErrorCode code;
  final int itemIndex;
  final List<String> args;
}

class ParseResult {
  const ParseResult({
    required this.node,
    this.errors = const [],
    this.boxes = const [],
  });

  /// Null when the list is empty or invalid. Invalid input must keep the
  /// last valid results (the caller holds on to its previous node).
  final QueryNode? node;
  final List<QueryError> errors;
  final List<GroupBox> boxes;

  bool get isValid => errors.isEmpty;
}
