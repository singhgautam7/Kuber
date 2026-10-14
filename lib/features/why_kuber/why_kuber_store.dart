import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/prefs_keys.dart';

/// Why Kuber tour state (specs/home-v3.3/plan.md §4), in prefs.
///
/// - Seen: the user reached page 5, from any entry (Welcome, More, the Home
///   card). Never cleared outside Dev tools.
/// - Card dismissed: the close icon on the Home card (Undo restores it).
class WhyKuberStore {
  const WhyKuberStore._();

  static Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  /// Bumped when the tour becomes seen, so the Home card can go at once
  /// whichever entry the tour was finished from.
  static final seenSignal = ValueNotifier<int>(0);

  static Future<bool> seen() async =>
      (await _p).getString(PrefsKeys.tourSeenAt) != null;

  static Future<void> markSeen() async {
    final p = await _p;
    if (p.getString(PrefsKeys.tourSeenAt) == null) {
      await p.setString(
        PrefsKeys.tourSeenAt,
        DateTime.now().toIso8601String(),
      );
      seenSignal.value++;
    }
  }

  static Future<bool> cardDismissed() async =>
      (await _p).getBool(PrefsKeys.tourCardDismissed) ?? false;

  static Future<void> setCardDismissed(bool v) async =>
      (await _p).setBool(PrefsKeys.tourCardDismissed, v);

  /// Dev tools › Reset Why Kuber.
  static Future<void> reset() async {
    final p = await _p;
    await p.remove(PrefsKeys.tourSeenAt);
    await p.remove(PrefsKeys.tourCardDismissed);
  }
}
