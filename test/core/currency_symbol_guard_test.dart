import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every amount must go through `formatterProvider` / `AppFormatter`, which
/// follows the user's currency. A hardcoded rupee sign is how screens ended up
/// showing ₹ with USD selected (specs/fixes/user-feedback-oct-2026.md).
///
/// Allowed: the formatter itself and the intentional exceptions listed in that
/// spec. Comment lines are ignored.
const _allowed = <String>[
  'lib/core/utils/formatters.dart',
  'lib/core/utils/currency_data.dart',
  // Two currencies by design.
  'lib/features/tools/currency_converter/',
  // Indian statutory limits defined in rupees (80C, PPF, EPF).
  'lib/features/tools/salary_calculator/',
  'lib/features/tools/ppf_calculator/',
  'lib/core/constants/info_constants.dart',
  // Parsers that must keep accepting ₹ / Rs / INR in input.
  'lib/features/sms_import/engine/',
  'lib/features/quick_add/services/quick_add_parser.dart',
  'lib/features/notes/engine/',
  'lib/features/notes/screens/note_editor_actions.dart',
  'lib/features/notes/data/notes_constants.dart',
  'lib/features/ask_kuber/screen/message_bubble.dart',
  // Play Store prices (charged in INR), not ledger amounts.
  'lib/features/pro/',
  // Brand mark / coin art, not amounts.
  'lib/features/ask_kuber/screen/kuber_mark.dart',
  'lib/features/onboarding/pages/onboarding_page_1.dart',
  'lib/shared/widgets/brand_icon.dart',
  // Generated l10n (SMS import copy about Indian bank messages).
  'lib/l10n/',
];

final _rupee = RegExp(r'₹|\\u20[bB]9');
final _trailingComment = RegExp(r'\s//\s.*$');

void main() {
  test('no hardcoded rupee sign outside the formatter and exceptions', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));
    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (_allowed.any(path.startsWith)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.startsWith('//') || line.startsWith('*')) continue;
        if (_rupee.hasMatch(line.replaceFirst(_trailingComment, ''))) {
          offenders.add('$path:${i + 1}: $line');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Format amounts with formatterProvider / AppFormatter, or add '
            'an intentional exception to the allow-list and the spec.');
  });
}
