import 'package:in_app_purchase/in_app_purchase.dart';
// in_app_purchase_android ships transitively with in_app_purchase; imported
// directly here to read subscription offer tokens / pricing phases that the
// app-facing package does not re-export.
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// One pricing phase of a subscription offer, in display terms. A Play offer is
/// an ordered list of phases, e.g. `[Free for P1Y, then ₹1,099 / P1Y]`.
class OfferPhase {
  /// Play-formatted, currency-correct price for the phase, e.g. `₹1,099` or a
  /// localized "Free" for a zero-price phase.
  final String formattedPrice;

  /// Raw amount in micros (₹1 = 1_000_000). 0 means a free phase.
  final int priceAmountMicros;

  /// ISO-8601 billing period, e.g. `P1Y`, `P1M`, `P14D`.
  final String billingPeriod;

  const OfferPhase({
    required this.formattedPrice,
    required this.priceAmountMicros,
    required this.billingPeriod,
  });

  bool get isFree => priceAmountMicros == 0;

  /// Human label for the period, e.g. `year`, `month`, `14 days`.
  String get periodLabel => humanBillingPeriod(billingPeriod);

  /// Counted duration label for a phase length, e.g. `1 year`, `14 days`. Used
  /// in the offer badge ("1 year free, then ...").
  String get durationLabel => countedBillingPeriod(billingPeriod);

  /// Approximate length of the phase in days (Y=365, M=30, W=7, D=1). Used only
  /// for tie-breaking offer selection, never for display.
  int get approxDays => iso8601PeriodToDays(billingPeriod);
}

/// The subscription offer the paywall will apply for a plan: the token needed to
/// attach it to the purchase, its Play Console tag(s), and its ordered pricing
/// phases. Built from the `GooglePlayProductDetails` Play returned for the plan
/// — Play only ever returns offers the current user is eligible for, so a
/// returning user simply never gets a "new customers" offer here.
class SubscriptionOfferInfo {
  final String productId;

  /// The `offerIdToken` to hand to `GooglePlayPurchaseParam.offerToken` so the
  /// discount actually applies at checkout.
  final String offerToken;

  /// Play Console offer id (e.g. `independence-day-gift`), null for a base plan.
  final String? offerId;

  /// Play Console offer tags.
  final List<String> offerTags;

  /// Ordered pricing phases (intro/free first, recurring last).
  final List<OfferPhase> phases;

  const SubscriptionOfferInfo({
    required this.productId,
    required this.offerToken,
    required this.offerId,
    required this.offerTags,
    required this.phases,
  });

  OfferPhase get firstPhase => phases.first;

  /// The recurring (final) phase — what the user pays after any intro benefit.
  OfferPhase get recurringPhase => phases.last;

  /// True when the first phase is cheaper than the recurring phase — i.e. this
  /// offer carries a free trial or intro discount worth surfacing as a badge.
  /// A plain base plan (single phase) has no intro benefit.
  bool get hasIntroBenefit =>
      phases.length > 1 &&
      phases.first.priceAmountMicros < phases.last.priceAmountMicros;
}

/// Picks the best offer among the eligible [ProductDetails] Play returned for a
/// single subscription id (one entry per base-plan/offer combination). Chooses
/// the lowest first-phase price, breaking ties by the longest free period so a
/// "1 year free" launch offer beats a "14-day trial". Returns null when [all]
/// holds no Android subscription entries (e.g. a non-subscription product, or
/// web where billing is unavailable).
GooglePlayProductDetails? pickBestSubscriptionOffer(List<ProductDetails> all) {
  final candidates = all.whereType<GooglePlayProductDetails>().where((p) {
    final offers = p.productDetails.subscriptionOfferDetails;
    return offers != null &&
        p.subscriptionIndex != null &&
        p.subscriptionIndex! < offers.length;
  }).toList();
  if (candidates.isEmpty) return null;

  candidates.sort((a, b) {
    final byPrice = a.rawPrice.compareTo(b.rawPrice); // first-phase price
    if (byPrice != 0) return byPrice;
    // Same first-phase price (e.g. two free-first offers): prefer the one with
    // the longer free run.
    return _freeDays(b).compareTo(_freeDays(a));
  });
  return candidates.first;
}

/// Builds a [SubscriptionOfferInfo] from a chosen Play subscription offer, or
/// null if the details don't describe a subscription offer.
SubscriptionOfferInfo? offerInfoFrom(ProductDetails? details) {
  if (details is! GooglePlayProductDetails) return null;
  final offers = details.productDetails.subscriptionOfferDetails;
  final idx = details.subscriptionIndex;
  if (offers == null || idx == null || idx >= offers.length) return null;
  final offer = offers[idx];
  return SubscriptionOfferInfo(
    productId: details.id,
    offerToken: offer.offerIdToken,
    offerId: offer.offerId,
    offerTags: offer.offerTags,
    phases: [
      for (final p in offer.pricingPhases)
        OfferPhase(
          formattedPrice: p.formattedPrice,
          priceAmountMicros: p.priceAmountMicros,
          billingPeriod: p.billingPeriod,
        ),
    ],
  );
}

int _freeDays(GooglePlayProductDetails p) {
  final offers = p.productDetails.subscriptionOfferDetails;
  if (offers == null || p.subscriptionIndex == null) return 0;
  final phases = offers[p.subscriptionIndex!].pricingPhases;
  var days = 0;
  for (final phase in phases) {
    if (phase.priceAmountMicros == 0) {
      days += iso8601PeriodToDays(phase.billingPeriod);
    }
  }
  return days;
}

/// Approximate day-count of an ISO-8601 billing period (`P1Y`/`P6M`/`P1W`/
/// `P14D`). Only used for offer-selection tie-breaking, so the Y=365 / M=30 /
/// W=7 approximation is fine.
int iso8601PeriodToDays(String period) {
  final match = RegExp(r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?$')
      .firstMatch(period);
  if (match == null) return 0;
  final y = int.tryParse(match.group(1) ?? '') ?? 0;
  final m = int.tryParse(match.group(2) ?? '') ?? 0;
  final w = int.tryParse(match.group(3) ?? '') ?? 0;
  final d = int.tryParse(match.group(4) ?? '') ?? 0;
  return y * 365 + m * 30 + w * 7 + d;
}

/// Counted, non-localized label for an ISO-8601 billing period, e.g. `1 year`,
/// `6 months`, `14 days`. Used where the number matters ("1 year free").
String countedBillingPeriod(String period) {
  switch (period) {
    case 'P1Y':
      return '1 year';
    case 'P6M':
      return '6 months';
    case 'P3M':
      return '3 months';
    case 'P1M':
      return '1 month';
    case 'P1W':
      return '1 week';
  }
  final days = iso8601PeriodToDays(period);
  if (days <= 0) return 'a while';
  return days == 1 ? '1 day' : '$days days';
}

/// Human, non-localized label for an ISO-8601 billing period. Whole-unit
/// singular periods read as the bare unit (`year`, `month`); anything else
/// reads as a day count (`14 days`).
String humanBillingPeriod(String period) {
  switch (period) {
    case 'P1Y':
      return 'year';
    case 'P6M':
      return '6 months';
    case 'P3M':
      return '3 months';
    case 'P1M':
      return 'month';
    case 'P1W':
      return 'week';
  }
  final days = iso8601PeriodToDays(period);
  if (days <= 0) return 'period';
  return days == 1 ? 'day' : '$days days';
}
