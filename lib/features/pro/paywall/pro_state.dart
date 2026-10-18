import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../data/user_entitlement.dart';
import '../debug/entitlement_override.dart';

/// Kuber Pro purchase tiers. Maps to the Play Console product IDs listed in
/// the strategy document: `kuber_pro_monthly`, `kuber_pro_yearly`,
/// `kuber_pro_lifetime`.
enum ProPlan { monthly, yearly, lifetime }

/// How the current device came to have Pro. `free` means no Pro at all.
/// There is no trial: free months come from Play promo codes, which arrive as
/// a normal subscription purchase.
enum ProSource { free, promo, purchased }

/// Local-only Kuber Pro entitlement snapshot. Immutable value object every
/// widget consumes via [kuberProStateProvider]. The durable half of the
/// system is the [UserEntitlement] Isar row that [KuberProStateNotifier]
/// hydrates from and writes back to. There is no user account, no server
/// session, no cloud sync — this is Kuber's "no account" promise expressed
/// in code.
class KuberProState {
  final ProSource source;
  final ProPlan? plan; // set when source == purchased
  final DateTime? promoEndsAt; // set when source == promo, null = free forever
  final DateTime?
  expiryDate; // set when source == purchased && plan != lifetime
  final DateTime?
  activatedAt; // when Pro/promo first turned on, for "N days as Pro"

  /// False once a subscription was cancelled: Pro stays until [expiryDate]
  /// (the end of the paid period) and then expires. Null when unknown.
  final bool? autoRenewing;

  const KuberProState({
    this.source = ProSource.free,
    this.plan,
    this.promoEndsAt,
    this.expiryDate,
    this.activatedAt,
    this.autoRenewing,
  });

  factory KuberProState.promo({DateTime? endsAt, DateTime? activatedAt}) =>
      KuberProState(
        source: ProSource.promo,
        promoEndsAt: endsAt,
        activatedAt: activatedAt ?? DateTime.now(),
      );

  factory KuberProState.purchased({
    required ProPlan plan,
    DateTime? expiryDate,
    DateTime? activatedAt,
    bool? autoRenewing,
  }) => KuberProState(
    source: ProSource.purchased,
    plan: plan,
    expiryDate: expiryDate,
    activatedAt: activatedAt ?? DateTime.now(),
    autoRenewing: autoRenewing,
  );

  bool get isPro => source == ProSource.purchased || source == ProSource.promo;
  bool get isFree => source == ProSource.free;

  /// Whether the user may use Pro-gated features right now. Every gate in the
  /// app routes through this getter (via `proGate`), so it is the single
  /// on/off switch for Pro.
  ///
  /// True when the user has a real paid/promo entitlement ([isPro]), or a QA
  /// build was compiled with `--dart-define=KUBER_UNLOCK_PRO=true`. The paywall's manage-vs-sell
  /// decision keys off [isPro] (real entitlement), not this getter.
  ///
  /// See `specs/pro-gating-enabled.md` for the full list of gated features and
  /// their free-tier limits.
  bool get hasProAccess =>
      const bool.fromEnvironment('KUBER_UNLOCK_PRO') || isPro;

  /// "Renews on DATE", or "Expires on DATE" once cancelled, for a monthly /
  /// yearly subscription; null when unknown (lifetime, promo, an older build's
  /// row before its next Play check). A renewal date that passed while
  /// offline rolls forward to the next anniversary.
  String? renewalLabel({DateTime? now}) {
    final date = expiryDate;
    if (date == null || plan == null || plan == ProPlan.lifetime) return null;
    final n = now ?? DateTime.now();
    String fmt(DateTime d) => DateFormat('d MMM yyyy').format(d);
    if (autoRenewing == false) {
      return date.isAfter(n)
          ? 'Expires on ${fmt(date)}'
          : 'Expired on ${fmt(date)}';
    }
    final next = date.isAfter(n) ? date : nextRenewalDate(date, plan!, n);
    return 'Renews on ${fmt(next)}';
  }

  /// Whole days since Pro/promo was activated. Used by the manage-state hero
  /// as a small badge of pride, not a functional countdown.
  int get daysSincePremium {
    if (activatedAt == null || !isPro) return 0;
    return DateTime.now().difference(activatedAt!).inDays;
  }

  // Value equality, so re-applying an unchanged purchase (every resume
  // reconcile re-delivers it) doesn't rebuild every Pro-aware widget.
  @override
  bool operator ==(Object other) =>
      other is KuberProState &&
      other.source == source &&
      other.plan == plan &&
      other.promoEndsAt == promoEndsAt &&
      other.expiryDate == expiryDate &&
      other.activatedAt == activatedAt &&
      other.autoRenewing == autoRenewing;

  @override
  int get hashCode => Object.hash(
    source,
    plan,
    promoEndsAt,
    expiryDate,
    activatedAt,
    autoRenewing,
  );
}

/// Reads / writes the [UserEntitlement] singleton and converts it to and from
/// [KuberProState]. Everything is synchronous — the row is a single tiny
/// record, and Isar Community's sync API is fine here.
///
/// The Notifier is the only place that touches the Isar row. Anything else in
/// the app that needs to mutate Pro state calls one of the intent-named
/// methods below ([applyPurchase], [applyPromo], [revoke]); nothing writes
/// `state =` directly. That
/// keeps the persistence side effect co-located with the state transition.
class KuberProStateNotifier extends Notifier<KuberProState> {
  Isar get _isar => ref.read(isarProvider);

  UserEntitlement _readRow() {
    return _isar.collection<UserEntitlement>().getSync(0) ??
        (UserEntitlement()
          ..firstInstallAt = DateTime.now()
          ..tier = EntitlementTier.free);
  }

  KuberProState _stateFromRow(UserEntitlement row) {
    final tier = EntitlementTier.coerce(row.tier);
    final now = DateTime.now();

    switch (tier) {
      case EntitlementTier.trial:
        // Legacy app-managed trial (install + 14 days). New installs stopped
        // getting it on 2026-07-11, so every one has ended: reads as free.
        return const KuberProState(source: ProSource.free);

      case EntitlementTier.proPromo:
        // LEGACY / MIGRATION (Round 2 security refactor): the in-app promo
        // grant is gone — no new device can reach this tier. But users who
        // claimed a local promo BEFORE this change still have `pro_promo` in
        // their row, and we must not cut them off retroactively. We keep
        // honoring their grant until `proExpiresAt` passes (null = a legacy
        // free-lifetime grant, honored indefinitely), exactly as before. A
        // Play Billing query never downgrades them; only the natural expiry
        // below transitions them to free.
        if (row.proExpiresAt != null && row.proExpiresAt!.isBefore(now)) {
          return const KuberProState(source: ProSource.free);
        }
        return KuberProState.promo(
          endsAt: row.proExpiresAt,
          activatedAt: row.activatedAt,
        );

      case EntitlementTier.proMonthly:
      case EntitlementTier.proYearly:
        // The date is refreshed on every Play check, so it only goes stale
        // offline: a paying user offline past renewal day keeps Pro for
        // [kRenewalGrace] before reading as free.
        if (row.proExpiresAt != null &&
            row.proExpiresAt!.add(kRenewalGrace).isBefore(now)) {
          return const KuberProState(source: ProSource.free);
        }
        return KuberProState.purchased(
          plan: tier == EntitlementTier.proMonthly
              ? ProPlan.monthly
              : ProPlan.yearly,
          expiryDate: row.proExpiresAt,
          activatedAt: row.activatedAt,
          autoRenewing: row.autoRenewing,
        );

      case EntitlementTier.proLifetime:
        return KuberProState.purchased(
          plan: ProPlan.lifetime,
          activatedAt: row.activatedAt,
        );

      default:
        return const KuberProState(source: ProSource.free);
    }
  }

  @override
  bool updateShouldNotify(KuberProState previous, KuberProState next) =>
      previous != next;

  @override
  KuberProState build() {
    // DEBUG-ONLY: a forced entitlement (Dev Tools > Entitlement Override) wins
    // over the real Isar-derived state. Compiled out of release builds.
    if (kEntitlementOverrideEnabled) {
      final forced = DebugEntitlementOverride.state;
      if (forced != null) return forced;
    }
    return _stateFromRow(_readRow());
  }

  void _writeRow(void Function(UserEntitlement row) mutate) {
    _isar.writeTxnSync(() {
      final row = _readRow();
      mutate(row);
      _isar.collection<UserEntitlement>().putSync(row);
    });
    // A live debug override stays authoritative even after a real write (e.g. a
    // purchase completing while an override is forced). Compiled out of release.
    if (kEntitlementOverrideEnabled) {
      final forced = DebugEntitlementOverride.state;
      if (forced != null) {
        state = forced;
        return;
      }
    }
    state = _stateFromRow(_readRow());
  }

  /// Applies a successful Play Billing purchase. Called from the paywall's
  /// purchase-stream listener and from the restore-purchases flow. Idempotent
  /// on the same product id.
  void applyPurchase({
    required ProPlan plan,
    DateTime? expiryDate,
    String? productId,
    String? purchaseToken,
    DateTime? activatedAt,
    bool? autoRenewing,
  }) {
    _writeRow((r) {
      r.tier = switch (plan) {
        ProPlan.monthly => EntitlementTier.proMonthly,
        ProPlan.yearly => EntitlementTier.proYearly,
        ProPlan.lifetime => EntitlementTier.proLifetime,
      };
      r.proExpiresAt = plan == ProPlan.lifetime ? null : expiryDate;
      r.autoRenewing = plan == ProPlan.lifetime ? null : autoRenewing;
      // No trials: clears the client-side trial estimate older builds wrote.
      r.trialEndsAt = null;
      // Prefer the real purchase timestamp when one is known (restore of an
      // older purchase), but never overwrite an activation we already recorded
      // — "N days as Pro" should count from the earliest known activation.
      r.activatedAt ??= activatedAt ?? DateTime.now();
      r.activeProductId = productId;
      r.activePurchaseToken = purchaseToken;
      r.lastVerifiedAt = DateTime.now();
    });
  }

  /// Writes the legacy `pro_promo` tier. **Do not call this from client-parsed
  /// remote config** — that was the security hole removed in Round 2. It is
  /// retained only so the tier constant and its row shape stay valid for the
  /// grandfathered users described in `_stateFromRow`'s `proPromo` case; there
  /// is intentionally no live caller. All new Pro state now arrives through
  /// [applyPurchase] from a real Play Billing purchase / restore / Play Store
  /// promo-code redemption.
  void applyPromo({DateTime? endsAt}) {
    _writeRow((r) {
      r.tier = EntitlementTier.proPromo;
      r.proExpiresAt = endsAt;
      r.activatedAt ??= DateTime.now();
    });
  }

  /// Drops the user back to the free tier. Called when Play Billing reports
  /// no active purchases (or on manual revocation for testing). Never touches
  /// [UserEntitlement.firstInstallAt], a per-install fact.
  void revoke() {
    _writeRow((r) {
      r.tier = EntitlementTier.free;
      r.proExpiresAt = null;
      r.autoRenewing = null;
      r.activeProductId = null;
      r.activePurchaseToken = null;
      r.lastVerifiedAt = DateTime.now();
    });
  }

}

/// How long a monthly / yearly subscription stays Pro past its stored renewal
/// date when the app couldn't re-check with Play (offline).
const kRenewalGrace = Duration(days: 3);

/// Next renewal of a subscription bought at [purchaseTime]: the first monthly
/// / yearly anniversary after [now]. Play renews on the purchase's day of the
/// month (clamped to short months), and a promo free month / year counts from
/// redemption, so this matches the "Renews on" Play shows. Play's exact date
/// is only available server-side, which Kuber does not have.
DateTime nextRenewalDate(DateTime purchaseTime, ProPlan plan, DateTime now) {
  final step = plan == ProPlan.yearly ? 12 : 1;
  final p = purchaseTime.toLocal();
  for (var k = 1; ; k++) {
    final first = DateTime(p.year, p.month + k * step, 1);
    final days = DateTime(first.year, first.month + 1, 0).day;
    final d = DateTime(first.year, first.month,
        p.day > days ? days : p.day, p.hour, p.minute, p.second);
    if (d.isAfter(now)) return d;
  }
}

/// Kuber Pro state, hydrated from Isar. Every widget reads this; only
/// [KuberProStateNotifier]'s named mutators write it.
final kuberProStateProvider =
    NotifierProvider<KuberProStateNotifier, KuberProState>(
      KuberProStateNotifier.new,
    );

/// Ensures the [UserEntitlement] singleton exists. Call from bootstrap on
/// every launch.
///
/// A new install starts on the free tier. There is no trial: the old
/// app-managed 14-day trial (resettable by reinstalling) was removed on
/// 2026-07-11, and free months now come from Play promo codes.
///
/// Kept as a top-level function rather than a Notifier method so it can be
/// awaited in `_bootstrap()` before the first frame — we want the row to exist
/// by the time the very first `ref.watch(kuberProStateProvider)` happens.
Future<void> ensureEntitlementBootstrap(Isar isar) async {
  final coll = isar.collection<UserEntitlement>();
  final existing = await coll.get(0);
  if (existing != null) return;

  final row = UserEntitlement()
    ..firstInstallAt = DateTime.now()
    ..tier = EntitlementTier.free;
  await isar.writeTxn(() async {
    await coll.put(row);
  });
}

/// Remote-config-driven promo campaign, hydrated from the JSON cached by
/// `PromoConfigService`. A non-null value means a campaign is live right now.
///
/// SECURITY (Round 2): this is now **display-only marketing content plus a
/// Play Store promo code**. It grants nothing on the client. The old
/// `promo_type` / `grantExpiry` machinery that let the app flip itself to Pro
/// from parsed JSON has been removed — that was exploitable (any device could
/// write the cached JSON and self-grant Pro). The only thing a promo can do
/// now is show the user a real Play Store [code] to redeem; the redemption
/// happens in Play Store and lands back on the purchase stream like any other
/// purchase. See `promo/promo_code_sheet.dart`.
class PromoConfig {
  /// Whether a campaign is live. Mirrors `promo_active`; a false/absent value
  /// makes [tryFromJson] return null.
  final bool active;

  /// Campaign window end (`promo_end_date`); past this, no promo is shown.
  final DateTime? endDate;

  final String headline;
  final String message;

  /// The real Google Play promo code the developer generated in Play Console,
  /// shown to the user to redeem. Null when the campaign has no code yet.
  final String? code;

  /// Which paid plan to emphasize in the paywall (`'yearly'` | `'lifetime'` |
  /// null). Display hint only; grants nothing.
  final String? productHighlight;

  const PromoConfig({
    this.active = true,
    this.endDate,
    required this.headline,
    required this.message,
    this.code,
    this.productHighlight,
  });

  /// Parses one campaign object. Returns null (no promo shown) when the
  /// campaign is inactive, past its end date, or missing its headline/message.
  /// Deliberately strict: a malformed remote config should surface nothing
  /// rather than a half-rendered banner. Note there is no grant type anymore —
  /// a promo is purely display + a redeemable Play Store code.
  static PromoConfig? tryFromJson(Map<String, dynamic> json) {
    if (json['promo_active'] != true) return null;

    DateTime? endDate;
    final endRaw = json['promo_end_date'];
    if (endRaw is String && endRaw.trim().isNotEmpty) {
      endDate = DateTime.tryParse(endRaw.trim())?.toLocal();
      if (endDate != null && endDate.isBefore(DateTime.now())) {
        return null; // campaign already over, even if the flag is stale
      }
    }

    final headline = (json['promo_headline'] as String?)?.trim();
    final message = (json['promo_message'] as String?)?.trim();
    if (headline == null ||
        headline.isEmpty ||
        message == null ||
        message.isEmpty) {
      return null;
    }

    final code = (json['promo_code'] as String?)?.trim();
    final highlight = (json['promo_product_highlight'] as String?)?.trim();

    return PromoConfig(
      active: true,
      endDate: endDate,
      headline: headline,
      message: message,
      code: (code == null || code.isEmpty) ? null : code,
      productHighlight: (highlight == null || highlight.isEmpty)
          ? null
          : highlight,
    );
  }
}

/// Holds the live promo campaign, parsed from the JSON that `PromoConfigService`
/// caches in SharedPreferences. Starts null and is filled by [hydrate], called
/// post-first-frame from `app.dart` after the service has refreshed the cache.
/// Every promo surface reads this synchronously via [promoConfigProvider].
class PromoConfigNotifier extends Notifier<PromoConfig?> {
  @override
  PromoConfig? build() => null;

  /// Reads the cached campaign JSON and publishes the parsed config (or null).
  /// Safe to call repeatedly; cheap after the first SharedPreferences load.
  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    state = _readCached(prefs);
  }

  static PromoConfig? _readCached(SharedPreferences prefs) {
    final raw = prefs.getString(PrefsKeys.promoConfigCached);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return PromoConfig.tryFromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}

/// The live promo campaign, or null when none is running. Hydrated from the
/// cached remote config on cold start.
final promoConfigProvider = NotifierProvider<PromoConfigNotifier, PromoConfig?>(
  PromoConfigNotifier.new,
);

/// True once the user has closed the home promo banner this session. Reset
/// on cold start (it is a plain in-memory provider, not persisted).
final promoBannerDismissedProvider = StateProvider<bool>((ref) => false);
