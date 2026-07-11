import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/utils/prefs_keys.dart';
import '../data/user_entitlement.dart';

/// Kuber Pro purchase tiers. Maps to the Play Console product IDs listed in
/// the strategy document: `kuber_pro_monthly`, `kuber_pro_yearly`,
/// `kuber_pro_lifetime`.
enum ProPlan { monthly, yearly, lifetime }

/// How the current device came to have Pro. `free` means no Pro at all.
enum ProSource { free, trial, promo, purchased }

/// Local-only Kuber Pro entitlement snapshot. Immutable value object every
/// widget consumes via [kuberProStateProvider]. The durable half of the
/// system is the [UserEntitlement] Isar row that [KuberProStateNotifier]
/// hydrates from and writes back to. There is no user account, no server
/// session, no cloud sync — this is Kuber's "no account" promise expressed
/// in code.
class KuberProState {
  final ProSource source;
  final ProPlan? plan; // set when source == purchased

  /// Trial window end. Two producers now:
  ///   - LEGACY app-managed trial (`source == trial`): install + 14 days.
  ///   - Play Billing free-trial phase (`source == purchased`): the yearly
  ///     subscription's free-trial phase end. See [inTrialPhase].
  /// Null means the user is not in any trial.
  final DateTime? trialEndsAt;
  final DateTime? promoEndsAt; // set when source == promo, null = free forever
  final DateTime? expiryDate; // set when source == purchased && plan != lifetime
  final DateTime? activatedAt; // when Pro/promo first turned on, for "N days as Pro"

  const KuberProState({
    this.source = ProSource.free,
    this.plan,
    this.trialEndsAt,
    this.promoEndsAt,
    this.expiryDate,
    this.activatedAt,
  });

  /// Legacy app-managed trial. No longer created for new installs (that was an
  /// abusable "reinstall for another 14 days" hole); retained only to
  /// grandfather users who still have a `trial` row. See
  /// `ensureEntitlementBootstrap`.
  factory KuberProState.trial({required DateTime endsAt}) =>
      KuberProState(source: ProSource.trial, trialEndsAt: endsAt);

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
    DateTime? trialEndsAt,
  }) => KuberProState(
        source: ProSource.purchased,
        plan: plan,
        expiryDate: expiryDate,
        activatedAt: activatedAt ?? DateTime.now(),
        trialEndsAt: trialEndsAt,
      );

  bool get isPro =>
      source == ProSource.purchased || source == ProSource.promo;

  /// Legacy app-managed trial only (unpaid). A Play Billing free trial is a
  /// real active subscription, so it reads as [isPro], not [isTrial].
  bool get isTrial => source == ProSource.trial;
  bool get isFree => source == ProSource.free;

  /// Whether trial UI (the countdown pill, the "TRIAL" button label) should
  /// show. True for a legacy app trial AND for a Play Billing subscription
  /// currently in its free-trial phase — both carry a future [trialEndsAt].
  bool get inTrialPhase =>
      trialEndsAt != null && trialEndsAt!.isAfter(DateTime.now());

  /// Whether the user may use Pro-gated features right now. A legacy trial user
  /// is unpaid ([isPro] false) but still gets full access, so gates check this
  /// rather than [isPro]. A Play trial user is already [isPro]. The paywall's
  /// manage-vs-sell decision keys off [isPro]: a Play-trial user has a real
  /// subscription to manage, a legacy-trial user does not.
  bool get hasProAccess => isPro || isTrial;

  /// Whole days since Pro/promo was activated. Used by the manage-state hero
  /// as a small badge of pride, not a functional countdown.
  int get daysSincePremium {
    if (activatedAt == null || !isPro) return 0;
    return DateTime.now().difference(activatedAt!).inDays;
  }

  int get trialDaysLeft {
    if (trialEndsAt == null) return 0;
    final hours = trialEndsAt!.difference(DateTime.now()).inHours;
    return (hours / 24).ceil().clamp(0, 14);
  }

  bool get trialEndingSoon => inTrialPhase && trialDaysLeft <= 3;
}

/// Reads / writes the [UserEntitlement] singleton and converts it to and from
/// [KuberProState]. Everything is synchronous — the row is a single tiny
/// record, and Isar Community's sync API is fine here.
///
/// The Notifier is the only place that touches the Isar row. Anything else in
/// the app that needs to mutate Pro state calls one of the intent-named
/// methods below ([applyPurchase], [applyPromo], [revoke],
/// [markTrialEndedNoticeShown]); nothing writes `state =` directly. That
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
        // Expired trial: transient in-memory downgrade. The persistent row
        // is not rewritten here — the row stays `trial` so the "trial ended
        // notice" logic can still find it. Rendering as free is enough to
        // gate the UI.
        if (row.trialEndsAt == null || row.trialEndsAt!.isBefore(now)) {
          return const KuberProState(source: ProSource.free);
        }
        return KuberProState.trial(endsAt: row.trialEndsAt!);

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
        if (row.proExpiresAt != null && row.proExpiresAt!.isBefore(now)) {
          return const KuberProState(source: ProSource.free);
        }
        return KuberProState.purchased(
          plan: ProPlan.monthly,
          expiryDate: row.proExpiresAt,
          activatedAt: row.activatedAt,
        );

      case EntitlementTier.proYearly:
        if (row.proExpiresAt != null && row.proExpiresAt!.isBefore(now)) {
          return const KuberProState(source: ProSource.free);
        }
        // The yearly base plan carries Play Billing's 14-day free trial phase.
        // `trialEndsAt` (set by `applyPurchase` from the purchase date) drives
        // the trial pill; `inTrialPhase` ignores it once it's in the past, so a
        // restored older subscription reads as plain Pro.
        return KuberProState.purchased(
          plan: ProPlan.yearly,
          trialEndsAt: row.trialEndsAt,
          expiryDate: row.proExpiresAt,
          activatedAt: row.activatedAt,
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
  KuberProState build() {
    return _stateFromRow(_readRow());
  }

  void _writeRow(void Function(UserEntitlement row) mutate) {
    _isar.writeTxnSync(() {
      final row = _readRow();
      mutate(row);
      _isar.collection<UserEntitlement>().putSync(row);
    });
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
    DateTime? trialEndsAt,
  }) {
    _writeRow((r) {
      r.tier = switch (plan) {
        ProPlan.monthly => EntitlementTier.proMonthly,
        ProPlan.yearly => EntitlementTier.proYearly,
        ProPlan.lifetime => EntitlementTier.proLifetime,
      };
      r.proExpiresAt = plan == ProPlan.lifetime ? null : expiryDate;
      // Play Billing free-trial phase end for the subscription (yearly). The
      // row field is reused (it was the legacy app-trial end); on a purchased
      // row it means "this subscription's trial ends here". Null clears it.
      r.trialEndsAt = trialEndsAt;
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
  /// [UserEntitlement.firstInstallAt] or [UserEntitlement.trialEndedNoticeShown]
  /// — those are per-install facts.
  void revoke() {
    _writeRow((r) {
      r.tier = EntitlementTier.free;
      r.proExpiresAt = null;
      r.activeProductId = null;
      r.activePurchaseToken = null;
      r.lastVerifiedAt = DateTime.now();
    });
  }

  /// Marks the one-shot "your trial ended" bottom sheet as shown.
  void markTrialEndedNoticeShown() {
    _writeRow((r) => r.trialEndedNoticeShown = true);
  }

  /// True once, right after the trial window closes but before the notice has
  /// been shown. The app calls this on cold start and, if it returns true,
  /// shows the sheet then calls [markTrialEndedNoticeShown].
  bool shouldShowTrialEndedNotice() {
    final row = _readRow();
    if (row.trialEndedNoticeShown) return false;
    if (row.tier != EntitlementTier.trial) return false;
    if (row.trialEndsAt == null) return false;
    return row.trialEndsAt!.isBefore(DateTime.now());
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
/// SECURITY (Round 2): a new install now starts on the **free** tier, NOT an
/// app-managed 14-day trial. The old app trial (14 days from `firstInstallAt`,
/// tracked locally) could be reset indefinitely by reinstalling or clearing
/// app data — an unbounded-free-Pro hole. The 14-day trial is now Play
/// Billing's own free-trial phase on the yearly subscription: it is tied to the
/// user's Google account, so it can't be farmed by wiping local state.
///
/// Existing users who already hold a `trial` row are untouched here and keep
/// their app trial to its natural end (see `_stateFromRow`'s `trial` case).
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
      productHighlight:
          (highlight == null || highlight.isEmpty) ? null : highlight,
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
final promoConfigProvider =
    NotifierProvider<PromoConfigNotifier, PromoConfig?>(
  PromoConfigNotifier.new,
);

/// True once the user has closed the home promo banner this session. Reset
/// on cold start (it is a plain in-memory provider, not persisted).
final promoBannerDismissedProvider = StateProvider<bool>((ref) => false);
