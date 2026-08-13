import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../paywall/pro_state.dart';

/// Debug-only forced entitlement tiers for local QA of the Pro gates.
enum DebugForcedTier { free, trial, monthly, yearly, lifetime }

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
  static int _trialDaysLeft = 14;

  /// The active forced tier, or null when there is no override (or in release).
  static DebugForcedTier? get tier => kDebugMode ? _tier : null;

  /// Days-remaining used when forcing [DebugForcedTier.trial].
  static int get trialDaysLeft => _trialDaysLeft;

  /// The forced [KuberProState], or null to fall through to the real
  /// Isar-derived entitlement. Always null in release builds.
  static KuberProState? get state {
    if (!kDebugMode || _tier == null) return null;
    final now = DateTime.now();
    switch (_tier!) {
      case DebugForcedTier.free:
        return const KuberProState(source: ProSource.free);
      case DebugForcedTier.trial:
        return KuberProState.trial(
          endsAt: now.add(Duration(days: _trialDaysLeft.clamp(1, 14))),
        );
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
          trialEndsAt: now.add(const Duration(days: 14)),
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
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    _trialDaysLeft = prefs.getInt(PrefsKeys.debugEntitlementTrialDays) ?? 14;
    _tier = _parse(prefs.getString(PrefsKeys.debugEntitlementOverride));
  }

  /// Sets (or clears, with a null [tier]) the forced entitlement and persists
  /// it. Callers should `ref.invalidate(kuberProStateProvider)` afterwards so
  /// the whole app re-derives from the new state. No-op in release.
  static Future<void> set(DebugForcedTier? tier, {int? trialDaysLeft}) async {
    if (!kDebugMode) return;
    _tier = tier;
    if (trialDaysLeft != null) _trialDaysLeft = trialDaysLeft.clamp(1, 14);
    final prefs = await SharedPreferences.getInstance();
    if (tier == null) {
      await prefs.remove(PrefsKeys.debugEntitlementOverride);
    } else {
      await prefs.setString(PrefsKeys.debugEntitlementOverride, tier.name);
      await prefs.setInt(
        PrefsKeys.debugEntitlementTrialDays,
        _trialDaysLeft,
      );
    }
  }

  static DebugForcedTier? _parse(String? raw) => switch (raw) {
        'free' => DebugForcedTier.free,
        'trial' => DebugForcedTier.trial,
        'monthly' => DebugForcedTier.monthly,
        'yearly' => DebugForcedTier.yearly,
        'lifetime' => DebugForcedTier.lifetime,
        _ => null,
      };
}
