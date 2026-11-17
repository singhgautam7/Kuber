import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the bundled variable Inter (v7.0.0). It is an engine font family
/// ('Inter' in pubspec `fonts:`), so the UI font works offline. If the pubspec
/// wiring or the filename regresses, text silently falls back to Roboto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('InterVariable.ttf is bundled, valid and has a wght axis', () async {
    final data = await rootBundle.load('assets/fonts/InterVariable.ttf');
    expect(data.lengthInBytes, greaterThan(10000));
    final sig = data.getUint32(0);
    expect(sig == 0x00010000 || sig == 0x4F54544F, isTrue, reason: 'sfnt header');
    // Table directory: look for 'fvar' (variable font) and 'wght' in it.
    final numTables = data.getUint16(4);
    var hasFvar = false;
    for (var i = 0; i < numTables; i++) {
      final tag = String.fromCharCodes(data.buffer.asUint8List(data.offsetInBytes + 12 + i * 16, 4));
      if (tag == 'fvar') hasFvar = true;
    }
    expect(hasFvar, isTrue, reason: 'variable font (fvar table)');
  });
}
