import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KuberStyleTokens', () {
    test('Signature tokens match Vault design spec', () {
      final tokens = KuberStyleTokens.of(KuberStyle.signature);
      expect(tokens.style, KuberStyle.signature);
      expect(tokens.buttonRadius, 8.0);
      expect(tokens.cardRadius, 8.0);
      expect(tokens.featuredCardRadius, 8.0);
      expect(tokens.sheetRadius, 12.0);
      expect(tokens.dialogRadius, 8.0);
      expect(tokens.chipRadius, 8.0);
      expect(tokens.textFieldRadius, 8.0);
      expect(tokens.snackbarRadius, 8.0);
      expect(tokens.fabRadius, 8.0);
      expect(tokens.isM3Expressive, isFalse);
    });

    test('Material 3 Expressive tokens match M3E spec', () {
      final tokens = KuberStyleTokens.of(KuberStyle.m3Expressive);
      expect(tokens.style, KuberStyle.m3Expressive);
      expect(tokens.buttonRadius, 999.0);
      expect(tokens.cardRadius, 16.0);
      expect(tokens.featuredCardRadius, 20.0);
      expect(tokens.sheetRadius, 28.0);
      expect(tokens.dialogRadius, 28.0);
      expect(tokens.chipRadius, 999.0);
      expect(tokens.textFieldRadius, 8.0);
      expect(tokens.snackbarRadius, 4.0);
      expect(tokens.fabRadius, 999.0);
      expect(tokens.isM3Expressive, isTrue);
    });

    test('AppTheme attaches KuberStyleTokens extension', () {
      final lightTheme = AppTheme.light(const Locale('en'), ThemeVariant.signature, KuberStyle.m3Expressive);
      final tokens = lightTheme.extension<KuberStyleTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.isM3Expressive, isTrue);
      expect(tokens.buttonRadius, 999.0);
    });
  });

  group('SettingsState designLanguage', () {
    test('defaults to Signature', () {
      const state = SettingsState();
      expect(state.designLanguage, KuberStyle.signature);
    });

    test('copyWith updates designLanguage', () {
      const original = SettingsState();
      final updated = original.copyWith(designLanguage: KuberStyle.m3Expressive);
      expect(updated.designLanguage, KuberStyle.m3Expressive);
    });
  });
}
