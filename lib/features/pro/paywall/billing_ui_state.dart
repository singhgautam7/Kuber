import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/prefs_keys.dart';

/// True until the app's one-time Pro entitlement bootstrap
/// (`ensureEntitlementBootstrap()` + the first `kuberProStateProvider` read)
/// has completed. Gates the Settings "Kuber Pro" card skeleton and keeps the
/// Home trial pill hidden (never shown as a skeleton — see spec) until real
/// state is known. Set to `false` once from `app.dart`'s startup sequence,
/// never toggled back to `true`.
final proBootstrapLoadingProvider = StateProvider<bool>((ref) => true);

/// True while `PurchaseService.loadProducts()` is in flight for the current
/// product query (startup load or a manual retry). Gates the paywall pricing
/// skeleton and the Buy Me a Coffee skeleton grid. Set `true` at the top of
/// `loadProducts()`, `false` on every exit path — success, an empty
/// response, and the catch block.
final productsLoadingProvider = StateProvider<bool>((ref) => true);

/// True only when the most recent `loadProducts()` attempt failed outright
/// (Play Billing unavailable, or the query threw). Cleared back to `false`
/// at the start of the next retry. Gates the paywall error state and the
/// "hide Buy Me a Coffee entirely" rule — never render a broken support
/// section, just don't render it.
final productsErrorProvider = StateProvider<bool>((ref) => false);

/// Last-known Play Billing prices for the three Pro products, keyed by
/// product id (`kProMonthlyId` etc — see `purchase_service.dart`), persisted
/// to `SharedPreferences` on every successful `loadProducts()` call and read
/// back on cold start. Lets the paywall show a real (if possibly stale)
/// price instead of a bare error message when Play Billing can't be reached.
class CachedProductPricesNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => const {};

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefsKeys.cachedProPrices);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      // Corrupt cache; ignore, next successful load overwrites it.
    }
  }

  Future<void> update(Map<String, String> prices) async {
    if (prices.isEmpty) return;
    state = {...state, ...prices};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.cachedProPrices, jsonEncode(state));
  }
}

final cachedProductPricesProvider =
    NotifierProvider<CachedProductPricesNotifier, Map<String, String>>(
  CachedProductPricesNotifier.new,
);
