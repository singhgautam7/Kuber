import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> start(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(settingsProvider.future);
    return c;
  }

  test('changing currency switches an explicit number format; it stays editable', () async {
    final c = await start({PrefsKeys.numberSystem: NumberSystem.indian.index});
    final n = c.read(settingsProvider.notifier);
    await n.setCurrency('USD');
    expect(c.read(settingsProvider).requireValue.numberSystem, NumberSystem.international);
    await n.setCurrency('INR');
    expect(c.read(settingsProvider).requireValue.numberSystem, NumberSystem.indian);
    await n.setNumberSystem(NumberSystem.international);
    expect(c.read(settingsProvider).requireValue.numberSystem, NumberSystem.international);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(PrefsKeys.numberSystem), NumberSystem.international.index);
  });

  test('Automatic stays Automatic and follows the currency', () async {
    final c = await start({});
    await c.read(settingsProvider.notifier).setCurrency('KES');
    final s = c.read(settingsProvider).requireValue;
    expect(s.numberSystem, NumberSystem.automatic);
    expect(c.read(formatterProvider).system, NumberSystem.international);
  });
}
