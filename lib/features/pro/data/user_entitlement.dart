import 'package:isar_community/isar.dart';

part 'user_entitlement.g.dart';

/// Kuber Pro entitlement, persisted as a single-row Isar collection.
///
/// This is the durable half of the entitlement system. The paired
/// `KuberProState` (`../paywall/pro_state.dart`) is the value object every
/// widget consumes; this row is what the Notifier hydrates from at cold start
/// and writes back to on every state change. Everything lives on the device.
/// No user accounts, no cloud, no server session.
///
/// The `tier` string is intentionally a raw string (not a Dart enum) so
/// adding a new tier in future does not require an Isar schema migration.
/// Legal values are enforced by [EntitlementTier] and its `fromString` on
/// read. Anything else round-trips as [EntitlementTier.free] rather than
/// crashing.
@collection
class UserEntitlement {
  /// Singleton: exactly one row exists per install. `id = 0` is safe because
  /// no other collection here uses it; Isar treats it as a normal fixed id.
  Id id = 0;

  /// Wall-clock time of the very first launch on this device. Used to compute
  /// the 14-day trial window and to render "N days as Pro" for a promo/
  /// purchased user (via [activatedAt]). Never mutated after the row is
  /// created.
  late DateTime firstInstallAt;

  /// See [EntitlementTier] for legal values. Stored as string so a new tier
  /// can be added without a schema bump.
  late String tier;

  /// End of the 14-day trial window. Set when [tier] transitions to 'trial'
  /// (typically at first install). Ignored once [tier] leaves 'trial'.
  DateTime? trialEndsAt;

  /// Expiry of the current Pro grant. Null means Pro forever (lifetime, or a
  /// free-forever promo). For a monthly / yearly subscription this mirrors
  /// the Play Billing purchase expiry.
  DateTime? proExpiresAt;

  /// The moment Pro was first activated for this install (purchased or
  /// promo). Feeds "N days as Pro" on the manage-state hero. Null until Pro
  /// is first granted; kept across resubscription so the badge is a badge of
  /// pride, not a countdown.
  DateTime? activatedAt;

  /// Purchase token returned by Play Billing on a successful purchase. Kept
  /// so we can locally verify against Play's own signature on subsequent
  /// launches. Not sent anywhere. Null for promo / trial / free.
  String? activePurchaseToken;

  /// The Play Console product id currently entitling the user, e.g.
  /// `kuber_pro_yearly`. Null for promo / trial / free.
  String? activeProductId;

  /// Last time we successfully reconciled with Play Billing's
  /// `queryPurchases()`. Used to decide whether a fallback-to-cache is
  /// stale-but-acceptable when Play is offline.
  DateTime? lastVerifiedAt;

  /// True once the one-shot "your trial ended" bottom sheet has been shown.
  /// Prevents nagging on every open after day 14.
  bool trialEndedNoticeShown = false;
}

/// String constants for [UserEntitlement.tier]. Kept as a class-of-consts
/// (not a Dart enum) so the string round-trips are explicit at every write
/// site — accidentally storing an unknown string would silently fall back to
/// [free] on read, and we want the compiler to catch it.
class EntitlementTier {
  static const free = 'free';
  static const trial = 'trial';
  static const proMonthly = 'pro_monthly';
  static const proYearly = 'pro_yearly';
  static const proLifetime = 'pro_lifetime';
  static const proPromo = 'pro_promo';

  static const all = <String>{
    free,
    trial,
    proMonthly,
    proYearly,
    proLifetime,
    proPromo,
  };

  /// Coerces an arbitrary string (typically read back from Isar) to a legal
  /// tier value. Unknown strings collapse to [free] rather than throwing,
  /// which matches how the app should react to a downgrade: if we don't
  /// understand the stored tier, treat it as no entitlement.
  static String coerce(String? raw) => all.contains(raw) ? raw! : free;
}
