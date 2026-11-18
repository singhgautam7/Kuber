import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/prefs_keys.dart';
import 'kuber_haptics.dart';

/// How much Kuber moves. See specs/v7.0.0 motion.md "Motion levels".
enum MotionLevel { expressive, subtle, off }

/// What the user picked. Auto resolves from the phone (see [resolveMotionLevel]).
enum MotionPreference { auto, expressive, subtle, off }

/// Result of the one-off device check, cached in prefs. [unknown] until the
/// check has run (Auto then behaves as Expressive).
enum DeviceClass { unknown, normal, low }

/// The Floating header setting (v7.0.0-c handoff, key `floatingHeader`):
/// when the pill shows, or [off] (the header scrolls away with the page).
enum FloatingHeaderMode { always, scrollUp, scrollStop, off }

/// Total RAM under this (MB, as Android reports it) is a low-end phone
/// ("under 4 GB"). Android reports less than the nominal size (a 4 GB phone
/// shows about 3.6 to 3.8 GB, a 3 GB phone about 2.8 GB), so the cut is 3.5 GB.
const int kLowRamMb = 3584;

DeviceClass classifyDevice({required int? ramMb, bool lowRamFlag = false}) =>
    lowRamFlag || (ramMb != null && ramMb < kLowRamMb)
        ? DeviceClass.low
        : DeviceClass.normal;

/// Level for [pref] on a phone of class [device]. The phone wins: with
/// [systemOff] (Remove animations) the answer is always Off.
MotionLevel resolveMotionLevel(
  MotionPreference pref,
  DeviceClass device, {
  bool systemOff = false,
}) {
  if (systemOff) return MotionLevel.off;
  return switch (pref) {
    MotionPreference.expressive => MotionLevel.expressive,
    MotionPreference.subtle => MotionLevel.subtle,
    MotionPreference.off => MotionLevel.off,
    MotionPreference.auto => device == DeviceClass.low
        ? MotionLevel.subtle
        : MotionLevel.expressive,
  };
}

/// Preferences read in main() with the other prefs (no extra await).
class MotionBoot {
  final MotionPreference pref;
  final DeviceClass device;
  final bool haptics;
  final FloatingHeaderMode floatingHeader;
  const MotionBoot({
    this.pref = MotionPreference.auto,
    this.device = DeviceClass.unknown,
    this.haptics = false,
    this.floatingHeader = FloatingHeaderMode.always,
  });

  factory MotionBoot.fromPrefs(SharedPreferences p) => MotionBoot(
        pref: _at(MotionPreference.values, p.getInt(PrefsKeys.motionPreference)),
        device: _at(DeviceClass.values, p.getInt(PrefsKeys.motionDeviceClass)),
        haptics: p.getBool(PrefsKeys.hapticsEnabled) ?? false,
        floatingHeader:
            _at(FloatingHeaderMode.values, p.getInt(PrefsKeys.floatingHeader)),
      );
}

T _at<T>(List<T> v, int? i) => v[(i ?? 0).clamp(0, v.length - 1)];

final bootMotionProvider = Provider<MotionBoot>((ref) => const MotionBoot());

class MotionPreferenceNotifier extends Notifier<MotionPreference> {
  @override
  MotionPreference build() => ref.watch(bootMotionProvider).pref;

  Future<void> set(MotionPreference p) async {
    state = p;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PrefsKeys.motionPreference, p.index);
    } catch (e) {
      debugPrint('Kuber: motion preference not saved: $e');
    }
  }
}

final motionPreferenceProvider =
    NotifierProvider<MotionPreferenceNotifier, MotionPreference>(
        MotionPreferenceNotifier.new);

/// Device class. [check] is called once from the on-open batch; the result
/// is cached so the next cold start reads it with the other prefs.
class MotionDeviceNotifier extends Notifier<DeviceClass> {
  @override
  DeviceClass build() => ref.read(bootMotionProvider).device;

  /// [probe] returns (total RAM in MB, isLowRamDevice); null = not Android.
  Future<void> check(Future<(int, bool)?> Function() probe) async {
    if (state != DeviceClass.unknown) return;
    try {
      final r = await probe();
      final c = r == null
          ? DeviceClass.normal
          : classifyDevice(ramMb: r.$1, lowRamFlag: r.$2);
      state = c;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PrefsKeys.motionDeviceClass, c.index);
    } catch (e) {
      debugPrint('Kuber: device class check failed (non-fatal): $e');
    }
  }
}

final motionDeviceProvider =
    NotifierProvider<MotionDeviceNotifier, DeviceClass>(
        MotionDeviceNotifier.new);

/// Effective level from preference + device class. The phone's Remove
/// animations is applied on top, per build, by [MotionScope].
final motionLevelProvider = Provider<MotionLevel>((ref) => resolveMotionLevel(
      ref.watch(motionPreferenceProvider),
      ref.watch(motionDeviceProvider),
    ));

/// The level for everything below it. One instance sits above the app (see
/// [MotionScopeHost]); [KuberMotion.levelOf] reads it.
class MotionScope extends InheritedWidget {
  const MotionScope({
    super.key,
    required this.level,
    required this.systemOff,
    required super.child,
  });

  /// Effective level (already Off when [systemOff]).
  final MotionLevel level;

  /// The phone's Remove animations is on.
  final bool systemOff;

  static MotionScope? maybeOf(BuildContext c) =>
      c.dependOnInheritedWidgetOfExactType<MotionScope>();

  @override
  bool updateShouldNotify(MotionScope old) =>
      old.level != level || old.systemOff != systemOff;
}

/// Places a [MotionScope] from [motionLevelProvider] + the phone's setting.
/// Rebuilds only when the level or disableAnimations changes.
class MotionScopeHost extends ConsumerWidget {
  const MotionScopeHost({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sys = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final level = ref.watch(motionLevelProvider);
    return MotionScope(
      level: sys ? MotionLevel.off : level,
      systemOff: sys,
      child: child,
    );
  }
}

/// The Haptics switch (off by default). Keeps [KuberHaptics.enabled] in step.
class HapticsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final v = ref.watch(bootMotionProvider).haptics;
    KuberHaptics.enabled = v;
    return v;
  }

  Future<void> set(bool v) async {
    state = v;
    KuberHaptics.enabled = v;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsKeys.hapticsEnabled, v);
    } catch (e) {
      debugPrint('Kuber: haptics preference not saved: $e');
    }
  }
}

final hapticsEnabledProvider =
    NotifierProvider<HapticsEnabledNotifier, bool>(HapticsEnabledNotifier.new);

/// The Floating header setting, read once with the other boot prefs. Headers
/// watch this one field, so they rebuild only when it changes.
class FloatingHeaderNotifier extends Notifier<FloatingHeaderMode> {
  @override
  FloatingHeaderMode build() => ref.watch(bootMotionProvider).floatingHeader;

  Future<void> set(FloatingHeaderMode m) async {
    state = m;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PrefsKeys.floatingHeader, m.index);
    } catch (e) {
      debugPrint('Kuber: floating header preference not saved: $e');
    }
  }
}

final floatingHeaderProvider =
    NotifierProvider<FloatingHeaderNotifier, FloatingHeaderMode>(
        FloatingHeaderNotifier.new);
