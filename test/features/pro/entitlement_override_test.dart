import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/debug/entitlement_override.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // These only exercise anything under kDebugMode, which is true in the test VM.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DebugEntitlementOverride.set(null); // start clean
  });

  test('no override falls through to real state', () {
    expect(DebugEntitlementOverride.state, isNull);
  });

  test('force free yields a free, no-access state', () async {
    await DebugEntitlementOverride.set(DebugForcedTier.free);
    final s = DebugEntitlementOverride.state!;
    expect(s.isFree, isTrue);
    expect(s.hasProAccess, isFalse);
  });

  test('a persisted "trial" override from an older build is ignored', () async {
    SharedPreferences.setMockInitialValues({
      'debug_entitlement_override': 'trial',
    });
    await DebugEntitlementOverride.hydrate();
    expect(DebugEntitlementOverride.state, isNull);
  });

  test('force lifetime yields full Pro, no expiry', () async {
    await DebugEntitlementOverride.set(DebugForcedTier.lifetime);
    final s = DebugEntitlementOverride.state!;
    expect(s.isPro, isTrue);
    expect(s.plan, ProPlan.lifetime);
    expect(s.expiryDate, isNull);
  });

  test('force yearly is plain Pro (no trial phase)', () async {
    await DebugEntitlementOverride.set(DebugForcedTier.yearly);
    final s = DebugEntitlementOverride.state!;
    expect(s.isPro, isTrue);
    expect(s.plan, ProPlan.yearly);
  });

  test('override persists across a hydrate (simulated restart)', () async {
    await DebugEntitlementOverride.set(DebugForcedTier.monthly);
    // Wipe in-memory then rehydrate from the same mock prefs.
    await DebugEntitlementOverride.set(null);
    expect(DebugEntitlementOverride.state, isNull);
    // Re-seed prefs as a restart would find them, then hydrate.
    SharedPreferences.setMockInitialValues({
      'debug_entitlement_override': 'monthly',
    });
    await DebugEntitlementOverride.hydrate();
    expect(DebugEntitlementOverride.state?.plan, ProPlan.monthly);
  });

  tearDown(() async {
    await DebugEntitlementOverride.set(null);
  });

  test('kDebugMode is true in the test VM (guards are exercised)', () {
    expect(kDebugMode, isTrue);
  });
}
