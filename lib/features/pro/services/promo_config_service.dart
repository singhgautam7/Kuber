import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';

/// Where the promo campaign JSON is hosted. The developer points this at a
/// static host (GitHub Pages is the plan) at launch. While it is empty, remote
/// fetch is disabled entirely and the app simply never shows a promo — no
/// network call is made, so there is no cost to shipping with this blank.
const kPromoConfigUrl = '';

/// A cached campaign is treated as fresh for this long. The first cold start
/// after it elapses triggers a re-fetch.
const kPromoConfigTtl = Duration(hours: 24);

/// Fetches and caches the remote promo campaign JSON. This service only does
/// network + cache; parsing and exposure live in `pro_state.dart`
/// (`PromoConfig.tryFromJson` / `promoConfigProvider`), so the two halves stay
/// independent and there is no import cycle.
///
/// Everything here is best-effort: Kuber has no server of its own, and a promo
/// is a nice-to-have. Any failure (offline, bad host, malformed body) leaves
/// whatever was previously cached untouched and surfaces nothing.
class PromoConfigService {
  const PromoConfigService();

  /// Re-fetches the campaign JSON when the cache is missing or older than
  /// [kPromoConfigTtl], and caches the raw body plus a fetch timestamp. Call
  /// post-first-frame on cold start. No-op when [kPromoConfigUrl] is empty.
  Future<void> refreshIfStale() async {
    if (kPromoConfigUrl.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final fetchedAtMs = prefs.getInt(PrefsKeys.promoConfigFetchedAt);
    if (fetchedAtMs != null) {
      final age = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(fetchedAtMs));
      if (age >= Duration.zero && age < kPromoConfigTtl) return;
    }

    await _fetchAndCache(prefs);
  }

  Future<void> _fetchAndCache(SharedPreferences prefs) async {
    try {
      final resp = await http
          .get(Uri.parse(kPromoConfigUrl))
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        debugPrint('Kuber: promo fetch HTTP ${resp.statusCode}');
        return;
      }
      // Validate the body parses to a JSON object before caching, so a bad
      // deploy can never poison the cache with something the reader chokes on.
      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('Kuber: promo config was not a JSON object; ignoring');
        return;
      }
      await prefs.setString(PrefsKeys.promoConfigCached, resp.body);
      await prefs.setInt(
        PrefsKeys.promoConfigFetchedAt,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Kuber: promo fetch failed (non-fatal): $e');
    }
  }
}
