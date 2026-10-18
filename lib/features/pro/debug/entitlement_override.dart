import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../paywall/pro_state.dart';

/// Whether the entitlement override can engage: debug builds, or a QA build
/// made with `--dart-define=KUBER_QA=true` (release-mode APK for device
/// testing). A const, so Play builds (neither) tree-shake every override path.
const bool kEntitlementOverrideEnabled =
    kDebugMode || bool.fromEnvironment('KUBER_QA');

/// Debug-only forced entitlement tiers for local QA of the Pro gates.
enum DebugForcedTier { free, monthly, yearly, lifetime }

/// DEBUG-ONLY entitlement override. Lets a developer force any entitlement
/// state from Settings > Developer > Entitlement Override without a real Play
/// Billing purchase, so every gate can be exercised on-device.
///
/// The whole class is gated on [kDebugMode], which the compiler treats as a
/// `const false` in release builds — so the tree-shaker drops every method body
/// and the override can never engage in production. [KuberProStateNotifier]
/// consults [state] at the top of its build; a non-null value wins over the real
/// Isar-derived entitlement.
///
/// The forced value is held in a static field (hydrated once at startup by
/// [hydrate]) so the synchronous notifier can read it without awaiting
/// SharedPreferences. Writes persist so the override survives an app restart in
/// debug builds.
class DebugEntitlementOverride {
  DebugEntitlementOverride._();

  static DebugForcedTier? _tier;

  /// The active forced tier, or null when there is no override (or in release).
  static DebugForcedTier? get tier =>
      kEntitlementOverrideEnabled ? _tier : null;

  /// The forced [KuberProState], or null to fall through to the real
  /// Isar-derived entitlement. Always null in release builds.
  static KuberProState? get state {
    if (!kEntitlementOverrideEnabled || _tier == null) return null;
    final now = DateTime.now();
    switch (_tier!) {
      case DebugForcedTier.free:
        return const KuberProState(source: ProSource.free);
      case DebugForcedTier.monthly:
        return KuberProState.purchased(
          plan: ProPlan.monthly,
          expiryDate: now.add(const Duration(days: 30)),
          activatedAt: now,
        );
      case DebugForcedTier.yearly:
        return KuberProState.purchased(
          plan: ProPlan.yearly,
          expiryDate: now.add(const Duration(days: 365)),
          activatedAt: now,
        );
      case DebugForcedTier.lifetime:
        return KuberProState.purchased(
          plan: ProPlan.lifetime,
          activatedAt: now,
        );
    }
  }

  /// Loads any persisted override into memory. Called once at startup before
  /// the first `kuberProStateProvider` read. No-op in release.
  static Future<void> hydrate() async {
    if (!kEntitlementOverrideEnabled) return;
    final prefs = await SharedPreferences.getInstance();
    _tier = _parse(prefs.getString(PrefsKeys.debugEntitlementOverride));
  }

  /// Sets (or clears, with a null [tier]) the forced entitlement and persists
  /// it. Callers should `ref.invalidate(kuberProStateProvider)` afterwards so
  /// the whole app re-derives from the new state. No-op in release.
  static Future<void> set(DebugForcedTier? tier) async {
    if (!kEntitlementOverrideEnabled) return;
    _tier = tier;
    final prefs = await SharedPreferences.getInstance();
    if (tier == null) {
      await prefs.remove(PrefsKeys.debugEntitlementOverride);
    } else {
      await prefs.setString(PrefsKeys.debugEntitlementOverride, tier.name);
    }
  }

  static DebugForcedTier? _parse(String? raw) => switch (raw) {
    'free' => DebugForcedTier.free,
    'monthly' => DebugForcedTier.monthly,
    'yearly' => DebugForcedTier.yearly,
    'lifetime' => DebugForcedTier.lifetime,
    _ => null,
  };
}
