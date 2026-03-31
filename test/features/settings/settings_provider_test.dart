import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

void main() {
  group('SettingsState', () {
    test('defaults to INR and Indian number system', () {
      const state = SettingsState();
      expect(state.currency, 'INR');
      expect(state.numberSystem, NumberSystem.indian);
    });

    test('copyWith creates new state with overrides', () {
      const original = SettingsState();
      final copy = original.copyWith(
        currency: 'USD',
        numberSystem: NumberSystem.international,
      );
      expect(copy.currency, 'USD');
      expect(copy.numberSystem, NumberSystem.international);
      // Unchanged fields preserved
      expect(copy.dateFormat, 'dd/MM/yyyy');
    });

    test('copyWith preserves original when no overrides', () {
      const original = SettingsState(currency: 'EUR');
      final copy = original.copyWith();
      expect(copy.currency, 'EUR');
    });
  });

  group('formatterProvider', () {
    test('returns Indian formatter by default', () {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(() => _FakeSettingsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final formatter = container.read(formatterProvider);
      expect(formatter, isA<AppFormatter>());
      // Default is Indian — verify by formatting a number
      expect(formatter.formatNumber(1234567), '12,34,567');
    });

    test('returns International formatter when configured', () async {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(
            () => _FakeSettingsNotifier(NumberSystem.international),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(settingsProvider.future);
      final formatter = container.read(formatterProvider);
      expect(formatter.formatNumber(1234567), '1,234,567');
    });
  });

  group('currencyProvider', () {
    test('defaults to INR', () {
      final container = ProviderContainer(
        overrides: [
          settingsProvider.overrideWith(() => _FakeSettingsNotifier()),
        ],
      );
      addTearDown(container.dispose);

      final currency = container.read(currencyProvider);
      expect(currency.code, 'INR');
      expect(currency.symbol, '₹');
    });
  });
}

class _FakeSettingsNotifier extends AsyncNotifier<SettingsState>
    implements SettingsNotifier {
  final NumberSystem _system;

  _FakeSettingsNotifier([this._system = NumberSystem.indian]);

  @override
  Future<SettingsState> build() async {
    return SettingsState(numberSystem: _system);
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {}
  @override
  Future<void> setCurrency(String currency) async {}
  @override
  Future<void> setDateFormat(String format) async {}
  @override
  Future<void> setNumberSystem(NumberSystem system) async {}
  @override
  Future<void> setSwipeMode(SwipeMode mode) async {}
  @override
  Future<void> setThemeMode(themeMode) async {}
  @override
  Future<void> setUserName(String name) async {}
  @override
  Future<void> clearAllData() async {}
}
