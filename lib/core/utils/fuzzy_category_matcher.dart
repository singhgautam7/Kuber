import '../../features/categories/data/category.dart';

/// Text normalization + fuzzy matching shared by Quick Add (Feature 1),
/// Ask Kuber transaction preview (Feature 2), and Master Search (Feature 4).
///
/// Pure functions only — no I/O, no Isar, no BuildContext — so they are cheap
/// enough to run on the UI isolate and easy to unit test. They never create or
/// mutate anything; category resolution returns an existing match or null.

/// Filler words stripped from the front of a phrase before matching, so
/// "on groceries" / "for movies" resolve the same as "groceries" / "movies".
const _leadingFillers = <String>{
  'on', 'in', 'for', 'a', 'an', 'the', 'at', 'to', 'of',
};

/// Lowercase, trim, collapse internal whitespace, and drop one leading filler
/// word. Idempotent. Used everywhere a comparable key is needed.
String normalizeText(String input) {
  var s = input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  if (s.isEmpty) return s;
  final firstSpace = s.indexOf(' ');
  if (firstSpace > 0) {
    final head = s.substring(0, firstSpace);
    if (_leadingFillers.contains(head)) {
      s = s.substring(firstSpace + 1).trim();
    }
  }
  return s;
}

/// The small set of singular/plural surface forms of [s] used for equality
/// matching, e.g. groceries<->grocery, movies<->movie, box<->boxes. Deliberately
/// simple rule-based English — no dictionary — so it stays offline and instant.
Set<String> plausibleForms(String s) {
  final forms = <String>{s};
  if (s.length > 3 && s.endsWith('ies')) {
    forms.add('${s.substring(0, s.length - 3)}y'); // groceries -> grocery
  }
  if (s.length > 2 && s.endsWith('es')) {
    forms.add(s.substring(0, s.length - 2)); // boxes -> box
  }
  if (s.length > 1 && s.endsWith('s')) {
    forms.add(s.substring(0, s.length - 1)); // movies -> movie, foods -> food
  }
  forms.add('${s}s'); // food -> foods
  if (s.length > 1 && s.endsWith('y')) {
    forms.add('${s.substring(0, s.length - 1)}ies'); // grocery -> groceries
  }
  return forms;
}

/// Relevance of [candidate] against [query]; lower is better, null = no match.
///   0 exact (normalized)
///   1 singular/plural equal
///   2 prefix (either direction)
///   3 substring (either direction, min length 3 on the shorter side)
int? matchScore(String query, String candidate) {
  final q = normalizeText(query);
  final c = normalizeText(candidate);
  if (q.isEmpty || c.isEmpty) return null;
  if (q == c) return 0;
  if (plausibleForms(q).intersection(plausibleForms(c)).isNotEmpty) return 1;
  if (c.startsWith(q) || q.startsWith(c)) return 2;
  if (q.length >= 3 && c.contains(q)) return 3;
  if (c.length >= 3 && q.contains(c)) return 3;
  return null;
}

/// Resolves [input] to one of the user's existing [categories], honoring [type]
/// ('expense' | 'income') when provided ('both'-typed categories always match).
/// Returns the best match or null — it NEVER creates a category, so a duplicate
/// can never be introduced here. The caller decides what to do with a null
/// (e.g. render the "new category" card).
Category? matchCategory(
  String input,
  List<Category> categories, {
  String? type,
}) {
  final q = normalizeText(input);
  if (q.isEmpty) return null;
  Category? best;
  var bestScore = 1 << 30;
  for (final c in categories) {
    if (type != null && c.type != 'both' && c.type != type) continue;
    final s = matchScore(q, c.name);
    if (s == null) continue;
    if (s < bestScore) {
      bestScore = s;
      best = c;
      if (bestScore == 0) break; // can't do better than exact
    }
  }
  return best;
}
