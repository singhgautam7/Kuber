import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/locale_font.dart';

void main() {
  test('Inter weight maps to the wght axis', () {
    final s = localeFont(fontWeight: FontWeight.w600);
    expect(s.fontFamily, 'Inter');
    expect(s.fontVariations, [const FontVariation('wght', 600)]);
    expect(localeFont().fontVariations, [const FontVariation('wght', 400)]);
  });

  test('w900 clamps to 700', () {
    final s = localeFont(fontWeight: FontWeight.w900);
    expect(s.fontVariations, [const FontVariation('wght', 700)]);
  });

  test('regional locales fall back to the system Noto family', () {
    final s = localeFont(locale: const Locale('hi'));
    expect(s.fontFamily, 'Inter');
    expect(s.fontFamilyFallback, contains('Noto Sans Devanagari'));
    expect(localeFont(locale: const Locale('en')).fontFamilyFallback, isNull);
  });
}
