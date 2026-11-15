// CONTRACT STUB. Owned by H-data. Localised text built from the tree.

import '../../../l10n/app_localizations.dart';
import 'query_ast.dart';

/// User-visible field name (localised; the keyword stays English).
String fieldLabel(QueryField f, AppLocalizations l) => throw UnimplementedError();

/// Display parts of a token: `category:` + `Food or Travel`, `amount:` +
/// `over ₹500`, words as `"swiggy"`. [money] formats rupees (Indian grouping).
class TokenDisplay {
  const TokenDisplay(this.field, this.value);
  final String field;
  final String value;
}

TokenDisplay tokenDisplay(
  ConditionNode c,
  AppLocalizations l,
  String Function(double) money,
) =>
    throw UnimplementedError();

/// "In plain words" readback, generated from the tree.
String readbackOf(
  QueryNode node,
  AppLocalizations l,
  String Function(double) money,
) =>
    throw UnimplementedError();

/// Plain-English message for an error (design copy).
String queryErrorMessage(QueryError e, AppLocalizations l) =>
    throw UnimplementedError();
