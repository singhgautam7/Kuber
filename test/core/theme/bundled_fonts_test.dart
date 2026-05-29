import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the pre-bundled Inter weights (#6). google_fonts loads these from
/// assets before any network fetch, so the primary UI font works offline and
/// without a runtime download. If the pubspec asset wiring or a filename
/// regresses, the app silently falls back to fetching/Roboto — this catches it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Variant names must match google_fonts' `toApiFilenamePart()` mapping so the
  // bundled-asset lookup (`Inter-<Variant>.ttf`) resolves.
  const variants = [
    'Light', // w300
    'Regular', // w400
    'Medium', // w500
    'SemiBold', // w600
    'Bold', // w700
    'ExtraBold', // w800
    'Black', // w900
  ];

  for (final variant in variants) {
    test('Inter-$variant.ttf is bundled and is a valid font', () async {
      final data = await rootBundle.load('assets/google_fonts/Inter-$variant.ttf');
      expect(
        data.lengthInBytes,
        greaterThan(10000),
        reason: 'Inter-$variant.ttf should be a real subset font, not empty',
      );
      // sfnt header: 0x00010000 (TrueType/glyf) or 'OTTO' (CFF).
      final sig = data.getUint32(0);
      expect(
        sig == 0x00010000 || sig == 0x4F54544F,
        isTrue,
        reason: 'Inter-$variant.ttf has a valid sfnt header',
      );
    });
  }
}
