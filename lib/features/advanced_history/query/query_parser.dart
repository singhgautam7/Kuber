// CONTRACT STUB. Owned by H-data, who replaces every body. Signatures are
// the contract H-token and H-UI build against.

import 'query_ast.dart';

/// Text to normalised items. Never throws: text that doesn't parse becomes a
/// [TokenItem] with a null condition. Accepts `:` `:>` `:<` `:>=` `:<=`,
/// ranges `a..b`, `field:(a OR b)` and `field:a,b` (one multi-value token),
/// `-x` / `not x`, `and` / `or` in any case, brackets to any depth, double
/// quoted text and bare words (words search).
List<QueryItem> tokenize(String text) => throw UnimplementedError();

/// Canonical text for items (round-trips through [tokenize]).
String serializeItems(List<QueryItem> items) => throw UnimplementedError();

/// Items to tree (NOT > AND > OR), errors with item positions, and the boxes
/// to draw (explicit brackets and implicit and/or grouping, with depth).
ParseResult parseItems(List<QueryItem> items) => throw UnimplementedError();

/// Tree to canonical text / items.
String serializeNode(QueryNode node) => throw UnimplementedError();
List<QueryItem> itemsFromNode(QueryNode node) => throw UnimplementedError();

/// Flips the joiner at [joinerIndex]. and -> or wraps both neighbours in
/// brackets (or joins an adjacent OR group, flattening same-operator
/// nesting); or -> and removes brackets that are no longer needed.
List<QueryItem> flipJoiner(List<QueryItem> items, int joinerIndex) =>
    throw UnimplementedError();

/// Number of filters (tokens) for the badge: joiners, nots and brackets
/// don't count.
int tokenCount(List<QueryItem> items) =>
    items.whereType<TokenItem>().length;
