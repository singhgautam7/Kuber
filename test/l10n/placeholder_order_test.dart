import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// gen-l10n builds each method's parameters in the order the placeholders are
// listed under "@key". Call sites pass arguments as the English text reads,
// so the two orders must match (a mismatch silently swaps values, e.g.
// principal and interest).
void main() {
  test('placeholders are listed in the order they appear in the text', () {
    final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
    final bad = <String>[];
    arb.forEach((key, value) {
      if (key.startsWith('@') || value is! String) return;
      if (value.contains(', plural,') || value.contains(', select,')) return;
      final meta = (arb['@$key'] as Map<String, dynamic>?)?['placeholders'] as Map<String, dynamic>?;
      if (meta == null || meta.isEmpty) return;
      final seen = <String>[];
      for (final m in RegExp(r'\{(\w+)\}').allMatches(value)) {
        final n = m.group(1)!;
        if (meta.containsKey(n) && !seen.contains(n)) seen.add(n);
      }
      if (meta.keys.join(',') != seen.join(',')) bad.add('$key: ${meta.keys} vs $seen');
    });
    expect(bad, isEmpty);
  });
}
