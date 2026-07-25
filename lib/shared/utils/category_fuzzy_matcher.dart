import '../../features/categories/data/category.dart';

enum CategoryMatchKind {
  exact,
  fuzzy,
  noMatch,
}

class CategoryMatchResult {
  final CategoryMatchKind kind;
  final Category? category;
  final String candidateName;
  final double confidence;

  const CategoryMatchResult._({
    required this.kind,
    this.category,
    required this.candidateName,
    required this.confidence,
  });

  factory CategoryMatchResult.exact(Category category, String candidate) =>
      CategoryMatchResult._(
        kind: CategoryMatchKind.exact,
        category: category,
        candidateName: candidate,
        confidence: 1.0,
      );

  factory CategoryMatchResult.fuzzy(Category category, String candidate, double confidence) =>
      CategoryMatchResult._(
        kind: CategoryMatchKind.fuzzy,
        category: category,
        candidateName: candidate,
        confidence: confidence,
      );

  factory CategoryMatchResult.noMatch(String candidate) =>
      CategoryMatchResult._(
        kind: CategoryMatchKind.noMatch,
        candidateName: candidate,
        confidence: 0.0,
      );
}

class CategoryFuzzyMatcher {
  const CategoryFuzzyMatcher();

  /// Computes Levenshtein distance between two strings [s] and [t].
  static int levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }

  /// Normalizes string for matching: lowercase, trimmed, trailing 's' stripped.
  static String normalize(String input) {
    var str = input.trim().toLowerCase();
    if (str.length > 3 && str.endsWith('s') && !str.endsWith('ss')) {
      str = str.substring(0, str.length - 1);
    }
    return str;
  }

  /// Matches [candidate] against [categories].
  ///
  /// Priority:
  /// 1. Exact match (case-insensitive)
  /// 2. Normalized match (singular / plural)
  /// 3. Substring match
  /// 4. Levenshtein distance <= 2 (confidence calculated based on edit distance)
  /// 5. No match -> returns CategoryMatchResult.noMatch (never auto-creates silently)
  static CategoryMatchResult match(String rawCandidate, List<Category> categories) {
    final candidate = rawCandidate.trim();
    if (candidate.isEmpty || categories.isEmpty) {
      return CategoryMatchResult.noMatch(candidate);
    }

    final lowerCandidate = candidate.toLowerCase();
    final normCandidate = normalize(candidate);

    // 1. Exact match (case-insensitive)
    for (final cat in categories) {
      final catLower = cat.name.trim().toLowerCase();
      if (catLower == lowerCandidate) {
        return CategoryMatchResult.exact(cat, candidate);
      }
    }

    // 2. Normalized match (singular / plural awareness)
    for (final cat in categories) {
      final normCat = normalize(cat.name);
      if (normCat == normCandidate) {
        return CategoryMatchResult.exact(cat, candidate);
      }
    }

    // 3. Substring match
    Category? substringMatch;
    for (final cat in categories) {
      final catLower = cat.name.trim().toLowerCase();
      if (catLower.contains(lowerCandidate) || lowerCandidate.contains(catLower)) {
        substringMatch = cat;
        break;
      }
    }
    if (substringMatch != null) {
      return CategoryMatchResult.fuzzy(substringMatch, candidate, 0.85);
    }

    // 4. Levenshtein distance <= 2
    Category? bestFuzzyMatch;
    int minDistance = 999;

    for (final cat in categories) {
      final normCat = normalize(cat.name);
      final dist = levenshteinDistance(normCandidate, normCat);
      final maxDistThreshold = normCandidate.length <= 4 ? 1 : 2;

      if (dist <= maxDistThreshold && dist < minDistance) {
        minDistance = dist;
        bestFuzzyMatch = cat;
      }
    }

    if (bestFuzzyMatch != null) {
      final confidence = 1.0 - (minDistance / (normCandidate.length + 1));
      return CategoryMatchResult.fuzzy(bestFuzzyMatch, candidate, confidence.clamp(0.5, 0.9));
    }

    // 5. No match
    return CategoryMatchResult.noMatch(candidate);
  }
}
