import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('classifyDevice: under 4 GB or the low-RAM flag is low', () {
    expect(classifyDevice(ramMb: 3072), DeviceClass.low);
    expect(classifyDevice(ramMb: 6144), DeviceClass.normal);
    expect(classifyDevice(ramMb: 3700), DeviceClass.normal); // nominal 4 GB
    expect(classifyDevice(ramMb: 2048), DeviceClass.low);
    expect(classifyDevice(ramMb: 8192, lowRamFlag: true), DeviceClass.low);
    expect(classifyDevice(ramMb: null), DeviceClass.normal);
  });

  test('Auto: unknown or normal = Expressive, low = Subtle', () {
    for (final d in [DeviceClass.unknown, DeviceClass.normal]) {
      expect(resolveMotionLevel(MotionPreference.auto, d), MotionLevel.expressive);
    }
    expect(resolveMotionLevel(MotionPreference.auto, DeviceClass.low), MotionLevel.subtle);
  });

  test('the preference overrides the device; the phone setting wins over both', () {
    for (final d in DeviceClass.values) {
      expect(resolveMotionLevel(MotionPreference.expressive, d), MotionLevel.expressive);
      expect(resolveMotionLevel(MotionPreference.subtle, d), MotionLevel.subtle);
      expect(resolveMotionLevel(MotionPreference.off, d), MotionLevel.off);
      for (final p in MotionPreference.values) {
        expect(resolveMotionLevel(p, d, systemOff: true), MotionLevel.off);
      }
    }
  });

  test('device check classifies once and caches the class', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(motionDeviceProvider.notifier);
    var calls = 0;
    await n.check(() async {
      calls++;
      return (3072, false);
    });
    expect(c.read(motionDeviceProvider), DeviceClass.low);
    expect(c.read(motionLevelProvider), MotionLevel.subtle);
    await n.check(() async {
      calls++;
      return (8192, false);
    });
    expect(calls, 1, reason: 'runs once');
    final prefs = await SharedPreferences.getInstance();
    expect(MotionBoot.fromPrefs(prefs).device, DeviceClass.low);
  });

  test('6 GB is normal; a non-Android probe (null) is normal', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(motionDeviceProvider.notifier).check(() async => (6144, false));
    expect(c.read(motionDeviceProvider), DeviceClass.normal);
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    await c2.read(motionDeviceProvider.notifier).check(() async => null);
    expect(c2.read(motionDeviceProvider), DeviceClass.normal);
  });

  test('preference persists and boot reads it back', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(motionPreferenceProvider.notifier).set(MotionPreference.subtle);
    expect(c.read(motionLevelProvider), MotionLevel.subtle);
    final prefs = await SharedPreferences.getInstance();
    expect(MotionBoot.fromPrefs(prefs).pref, MotionPreference.subtle);
    // A bad stored index falls back instead of throwing.
    SharedPreferences.setMockInitialValues({'kuber_motion_preference': 99});
    expect(MotionBoot.fromPrefs(await SharedPreferences.getInstance()).pref,
        MotionPreference.off);
  });

  Future<MotionLevel> levelIn(WidgetTester t,
      {required bool disableAnimations,
      MotionPreference pref = MotionPreference.expressive}) async {
    late MotionLevel got;
    await t.pumpWidget(ProviderScope(
      overrides: [
        bootMotionProvider.overrideWithValue(MotionBoot(pref: pref)),
      ],
      child: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MotionScopeHost(
          child: Builder(builder: (c) {
            got = KuberMotion.levelOf(c);
            return const SizedBox();
          }),
        ),
      ),
    ));
    return got;
  }

  testWidgets('Remove animations forces Off whatever is picked', (t) async {
    expect(await levelIn(t, disableAnimations: true), MotionLevel.off);
    expect(await levelIn(t, disableAnimations: false), MotionLevel.expressive);
    expect(await levelIn(t, disableAnimations: false, pref: MotionPreference.subtle),
        MotionLevel.subtle);
  });

  testWidgets('without a scope: Expressive, or Off when the phone asks', (t) async {
    late MotionLevel a;
    await t.pumpWidget(MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(builder: (c) {
          a = KuberMotion.levelOf(c);
          expect(KuberMotion.reduced(c), isTrue);
          expect(KuberMotion.of(c, const Duration(seconds: 1)), KuberMotion.instant);
          return const SizedBox();
        })));
    expect(a, MotionLevel.off);
  });

  test('token values', () {
    expect(KuberMotion.fxDefault, const Duration(milliseconds: 200));
    expect(KuberMotion.staggerDelay(0), Duration.zero);
    expect(KuberMotion.staggerDelay(3), const Duration(milliseconds: 90));
    expect(KuberMotion.staggerDelay(20), const Duration(milliseconds: 150));
    expect(KuberMotion.slowCurve.settle, greaterThan(KuberMotion.defaultCurve.settle));
    expect(KuberMotion.defaultCurve.settle, greaterThan(KuberMotion.standardCurve.settle));
  });
}
