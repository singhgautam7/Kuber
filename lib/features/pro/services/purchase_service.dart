import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// Transitive with in_app_purchase; imported directly to attach a subscription
// offer token to the purchase (GooglePlayPurchaseParam).
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../core/router/app_router.dart';
import '../paywall/billing_ui_state.dart';
import '../paywall/pro_state.dart';
import '../paywall/subscription_offer.dart';
import '../purchase_states/purchase_failure_snackbar.dart';
import '../purchase_states/purchase_success_sheet.dart';
import '../support/support_success_sheets.dart';
import 'billing_diagnostics.dart';

/// Play Console product IDs. The single source of truth in code — every buy
/// site references these, never a raw string literal.
const kProMonthlyId = 'kuber_pro_monthly';
const kProYearlyId = 'kuber_pro_yearly';
const kProLifetimeId = 'kuber_pro_lifetime';

/// The three entitlement-granting products.
const kProProductIds = <String>{kProMonthlyId, kProYearlyId, kProLifetimeId};

/// The four Buy Me a Coffee consumables. Grant no entitlement.
const kSupportProductIds = <String>{
  'kuber_support_coffee',
  'kuber_support_dinner',
  'kuber_support_feast',
  'kuber_support_banquet',
};

/// Everything we query from Play in one shot at startup.
const kAllProductIds = <String>{...kProProductIds, ...kSupportProductIds};

/// Maps a Play product id to its Pro plan, or null for a non-entitlement
/// product (a support consumable or an unknown id).
ProPlan? planForProductId(String id) => switch (id) {
      kProMonthlyId => ProPlan.monthly,
      kProYearlyId => ProPlan.yearly,
      kProLifetimeId => ProPlan.lifetime,
      _ => null,
    };

/// Maps a Pro plan back to its Play product id.
String productIdForPlan(ProPlan plan) => switch (plan) {
      ProPlan.monthly => kProMonthlyId,
      ProPlan.yearly => kProYearlyId,
      ProPlan.lifetime => kProLifetimeId,
    };

/// Owns the app's single connection to Google Play Billing.
///
/// Kuber has no account and no server, so this is the whole billing stack:
/// it listens to [InAppPurchase.purchaseStream] for the app's lifetime, and
/// routes each event into [kuberProStateProvider] (for entitlement) and the
/// shared success / failure UI helpers. It never verifies against a Kuber
/// server — Play Billing's own signature is the verification for v1, per the
/// strategy doc.
///
/// UI is surfaced through [rootNavigatorKey]'s context rather than a passed-in
/// [BuildContext]: a purchase can complete long after the buy button was
/// tapped (a pending UPI payment, a restore fired at cold start), so the
/// originating widget may be long gone by the time the stream delivers.
class PurchaseService {
  PurchaseService(this._ref);

  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// In-flight Future cache to coalesce concurrent restore/query requests
  /// (e.g. on-resume lifecycle listener racing with manual user tap).
  Future<void>? _inFlightRestore;

  /// Best-pick product per id (the chosen offer for a subscription; the sole
  /// entry for a one-time product). Drives the buy path and the price display.
  final Map<String, ProductDetails> _products = {};

  /// Every ProductDetails Play returned per id. A subscription with a base plan
  /// plus offers (free trial, launch promo) yields several entries sharing one
  /// id — Play only ever includes offers the current user is eligible for.
  final Map<String, List<ProductDetails>> _offers = {};

  bool _available = false;
  bool _initialized = false;

  /// True once Play Billing reported itself available on this device.
  bool get isAvailable => _available;

  /// Loaded product details keyed by product id (populated by [loadProducts]).
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  /// The raw Play Billing purchase stream, exposed for anything that wants to
  /// observe purchases directly. Most callers should not need this — the
  /// service already routes events into entitlement + UI internally.
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// Connects to Play Billing, starts listening to the purchase stream, and
  /// pre-loads product details. Idempotent and best-effort: a device with no
  /// Play services simply ends up with [isAvailable] false and every buy call
  /// short-circuits to the "Play Store unavailable" snackbar.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      _available = await _iap.isAvailable();
      BillingDiagnostics.instance.log(
        'INIT',
        'Play Billing availability: $_available',
      );
    } catch (e) {
      debugPrint('Kuber: Play Billing availability check failed: $e');
      BillingDiagnostics.instance.recordError('initialize:isAvailable', e);
      _available = false;
    }
    if (!_available) return;

    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object e, StackTrace s) {
        debugPrint('Kuber: purchase stream error: $e');
        BillingDiagnostics.instance.recordError('purchaseStream', e, s);
      },
    );

    await loadProducts(kAllProductIds);

    // Reconcile with Play on cold start — the "detected on app open via
    // queryPurchases" promise. Restored purchases arrive on the stream as
    // PurchaseStatus.restored and re-grant entitlement silently. Uses the retry
    // ladder so a returning owner whose Play cache is cold on first launch is
    // still caught within a few seconds, while a genuine Free install stays
    // Free. Fire-and-forget: the ladder's waits must not hold up initialize().
    unawaited(_startupReconcile());
  }

  Future<void> _startupReconcile() async {
    try {
      await reconcileWithRetries(source: 'startup');
    } catch (e) {
      debugPrint('Kuber: startup restore failed (non-fatal): $e');
    }
  }

  /// Queries Play for the given product ids and caches their [ProductDetails].
  /// Safe to call repeatedly; unknown or not-yet-configured ids are ignored.
  ///
  /// Drives the billing loading/error UI state: `productsLoadingProvider` is
  /// true for the duration and false on every exit path; `productsErrorProvider`
  /// is cleared at the start of the attempt and set only when Play is
  /// unavailable or the query throws. On success the three Pro-plan prices are
  /// written to `cachedProductPricesProvider` (and SharedPreferences) so an
  /// offline paywall can still show a last-known price.
  Future<void> loadProducts(Set<String> ids) async {
    _ref.read(productsLoadingProvider.notifier).state = true;
    _ref.read(productsErrorProvider.notifier).state = false;

    if (!_available) {
      _ref.read(productsErrorProvider.notifier).state = true;
      _ref.read(productsLoadingProvider.notifier).state = false;
      return;
    }

    final sw = Stopwatch()..start();
    BillingDiagnostics.instance.recordQueryStart('loadProducts', source: ids.join(','));

    try {
      final resp = await _iap.queryProductDetails(ids).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('loadProducts timed out'),
          );
      sw.stop();
      BillingDiagnostics.instance.recordQueryEnd(
        'loadProducts',
        success: true,
        duration: sw.elapsed,
      );

      if (resp.notFoundIDs.isNotEmpty) {
        debugPrint('Kuber: products not found on Play: ${resp.notFoundIDs}');
        BillingDiagnostics.instance.log(
          'PRODUCTS_NOT_FOUND',
          'IDs not found: ${resp.notFoundIDs}',
        );
      }

      // Group the response by product id. A subscription returns one entry per
      // base-plan/offer combination, so we can't keep just the last — we pick
      // the best offer per id. Only the ids present in this response are
      // touched, so a lazy single-id retry never wipes the others.
      final byId = <String, List<ProductDetails>>{};
      for (final p in resp.productDetails) {
        (byId[p.id] ??= <ProductDetails>[]).add(p);
      }
      byId.forEach((id, list) {
        _offers[id] = list;
        _products[id] = pickBestSubscriptionOffer(list) ?? list.first;
      });

      // Publish the chosen subscription offers so the paywall can render the
      // launch-offer badge and attach the offer token at purchase.
      final offerInfos = <String, SubscriptionOfferInfo>{};
      for (final id in kProProductIds) {
        final info = offerInfoFrom(_products[id]);
        if (info != null) offerInfos[id] = info;
      }
      _ref.read(subscriptionOffersProvider.notifier).state = offerInfos;

      // Persist last-known Pro-plan prices for the offline paywall fallback.
      // For a subscription this is the RECURRING price (what the user pays after
      // any free/intro phase), never the intro "Free" — the intro benefit is
      // surfaced separately as the offer badge.
      final prices = <String, String>{
        for (final id in kProProductIds)
          if (_products[id] != null)
            id: offerInfos[id]?.recurringPhase.formattedPrice ??
                _products[id]!.price,
      };
      if (prices.isNotEmpty) {
        await _ref.read(cachedProductPricesProvider.notifier).update(prices);
      }
    } catch (e) {
      debugPrint('Kuber: loadProducts failed: $e');
      _ref.read(productsErrorProvider.notifier).state = true;
    } finally {
      _ref.read(productsLoadingProvider.notifier).state = false;
    }
  }

  /// Launches the Play purchase flow for a Pro plan / lifetime product. The
  /// result arrives asynchronously on the purchase stream, not from this
  /// future — this only kicks off the native sheet.
  Future<void> buyProduct(String productId) =>
      _launch(productId, consumable: false);

  /// Launches the Play purchase flow for a Buy Me a Coffee consumable.
  Future<void> buySupport(String productId) =>
      _launch(productId, consumable: true);

  Future<void> _launch(String productId, {required bool consumable}) async {
    if (!_available) {
      _snack((ctx, overlay) =>
          showPlayStoreUnavailableSnackbar(ctx, overlay: overlay));
      return;
    }

    var product = _products[productId];
    if (product == null) {
      // Lazy retry in case the startup query missed this id.
      await loadProducts({productId});
      product = _products[productId];
    }
    if (product == null) {
      _snack((ctx, overlay) =>
          showPlayStoreUnavailableSnackbar(ctx, overlay: overlay));
      return;
    }

    final param = _purchaseParamFor(product, consumable: consumable);
    try {
      if (consumable) {
        // autoConsume (default true) makes Play consume the token for us, so
        // the tier can be bought again later — support is a repeatable tip.
        await _iap.buyConsumable(purchaseParam: param);
      } else {
        await _iap.buyNonConsumable(purchaseParam: param);
      }
    } catch (e) {
      debugPrint('Kuber: buy launch failed for $productId: $e');
      _snack((ctx, overlay) => showPurchaseFailedSnackbar(
            ctx,
            onRetry: () => _launch(productId, consumable: consumable),
            overlay: overlay,
          ));
    }
  }

  /// Builds the purchase params. For a subscription we must hand Play the
  /// specific offer token, or the chosen offer's discount (a free trial, the
  /// launch promo) won't apply — Play would fall back to the base plan. One-time
  /// products (lifetime, support tips) carry no offer, so they use the plain
  /// [PurchaseParam].
  PurchaseParam _purchaseParamFor(
    ProductDetails product, {
    required bool consumable,
  }) {
    if (!consumable && product is GooglePlayProductDetails) {
      final info = offerInfoFrom(product);
      if (info != null) {
        return GooglePlayPurchaseParam(
          productDetails: product,
          offerToken: info.offerToken,
        );
      }
    }
    return PurchaseParam(productDetails: product);
  }

  /// Shows a snackbar from the global purchase service, which only holds a
  /// root-navigator context. That context can't resolve an overlay via
  /// `Overlay.of` (the overlay is the Navigator's descendant, not its
  /// ancestor), so we hand the root navigator's overlay to the snackbar
  /// directly. No-op if the navigator isn't mounted yet.
  void _snack(void Function(BuildContext, OverlayState?) show) {
    final navigator = rootNavigatorKey.currentState;
    final overlay = navigator?.overlay;
    final ctx = overlay?.context ?? navigator?.context;
    if (ctx == null) return;
    show(ctx, overlay);
  }

  /// Re-queries Play for prior purchases. Restored entitlements arrive on the
  /// stream as [PurchaseStatus.restored]. The visible "Purchase restored" /
  /// "No previous purchase found" feedback is owned by
  /// `restore_purchases_flow.dart`, which reads entitlement state after this
  /// resolves.
  Future<void> restorePurchases({String source = 'manual', bool force = false}) async {
    if (!_available) {
      BillingDiagnostics.instance.log('RESTORE_SKIP', 'Play Billing is not available');
      return;
    }

    // A forced restore is a deliberately FRESH Play query, never coalesced onto
    // an in-flight one. It exists for the itemAlreadyOwned recovery and the
    // retry ladder: Play has just reconciled server→local cache, so reusing a
    // future that started *before* that reconcile would return the stale empty
    // result and defeat the whole fix.
    if (force) {
      return _performRestore(source);
    }

    if (_inFlightRestore != null) {
      BillingDiagnostics.instance.log(
        'RESTORE_COALESCED',
        'Reusing in-flight restore query',
        {'source': source},
      );
      return _inFlightRestore!;
    }

    _inFlightRestore = _performRestore(source).whenComplete(() {
      _inFlightRestore = null;
    });
    return _inFlightRestore!;
  }

  /// Fires a fresh restore query and, if entitlement doesn't land, retries
  /// after 3s then 8s. Each attempt is a forced (uncoalesced) Play query.
  ///
  /// This is the core of the "returning owner whose Play cache was cold on the
  /// first query" fix: a real owner is caught within the ladder as Play's local
  /// cache warms, while a genuine Free account simply stays Free after all
  /// attempts return empty — no false Pro. Restored purchases land on the stream
  /// and grant entitlement via [_deliver]; this only drives the queries and
  /// waits a beat for that to happen.
  ///
  /// Returns true as soon as Pro is detected. Best-effort: individual query
  /// failures are logged and do not abort the ladder.
  Future<bool> reconcileWithRetries({required String source}) async {
    const retryDelays = <Duration>[
      Duration.zero,
      Duration(seconds: 3),
      Duration(seconds: 8),
    ];
    for (var attempt = 0; attempt < retryDelays.length; attempt++) {
      if (retryDelays[attempt] > Duration.zero) {
        // Short-circuit if entitlement already landed while we waited.
        if (_ref.read(kuberProStateProvider).isPro) return true;
        await Future<void>.delayed(retryDelays[attempt]);
      }
      if (_ref.read(kuberProStateProvider).isPro) return true;

      BillingDiagnostics.instance.log(
        'RESTORE_RETRY',
        'Reconcile attempt ${attempt + 1}/${retryDelays.length}',
        {'source': source},
      );
      try {
        await restorePurchases(source: '$source:try${attempt + 1}', force: true);
      } catch (e) {
        BillingDiagnostics.instance.recordError('reconcileWithRetries', e);
      }
      // Give the purchase stream a beat to deliver + apply before deciding.
      if (await _pollForPro(timeout: const Duration(seconds: 2))) return true;
    }
    return _ref.read(kuberProStateProvider).isPro;
  }

  /// Waits for [kuberProStateProvider] to report Pro, up to [timeout].
  Future<bool> _pollForPro({required Duration timeout}) => pollForProEntitlement(
        () => _ref.read(kuberProStateProvider).isPro,
        timeout: timeout,
      );

  Future<void> _performRestore(String source) async {
    final sw = Stopwatch()..start();
    BillingDiagnostics.instance.recordQueryStart('restorePurchases', source: source);
    try {
      await _iap.restorePurchases().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('restorePurchases timed out after 10s'),
      );
      sw.stop();
      BillingDiagnostics.instance.recordQueryEnd(
        'restorePurchases',
        success: true,
        duration: sw.elapsed,
      );
    } catch (e) {
      sw.stop();
      BillingDiagnostics.instance.recordQueryEnd(
        'restorePurchases',
        success: false,
        duration: sw.elapsed,
        error: e.toString(),
      );
      debugPrint('Kuber: restorePurchases failed: $e');
      rethrow;
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  // --- Purchase stream handling -------------------------------------------

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    BillingDiagnostics.instance.recordStreamPurchases(purchases);
    for (final purchase in purchases) {
      _handle(purchase);
    }
  }

  Future<void> _handle(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // A pending payment (e.g. UPI mandate). Nothing to grant yet; the
        // stream fires again with purchased/error once Play resolves it.
        break;
      case PurchaseStatus.error:
        // "Item already owned" is not a real failure — the user owns the
        // entitlement, the app just hasn't reconciled it. The failed buy flow
        // *forces Play to refresh its local cache from Google's servers*, so a
        // query fired right now finally sees the purchase. Recover silently
        // instead of dumping a confusing "already owned" error on the user.
        if (_isAlreadyOwned(purchase.error)) {
          BillingDiagnostics.instance.log(
            'ALREADY_OWNED',
            'Buy reported itemAlreadyOwned; auto-restoring',
            {'productId': purchase.productID},
          );
          unawaited(_recoverAlreadyOwned());
          break;
        }
        _snack((ctx, overlay) => showPurchaseFailedSnackbar(
              ctx,
              onRetry: () => _launch(
                purchase.productID,
                consumable: kSupportProductIds.contains(purchase.productID),
              ),
              overlay: overlay,
            ));
        break;
      case PurchaseStatus.canceled:
        _snack((ctx, overlay) =>
            showPurchaseCancelledSnackbar(ctx, overlay: overlay));
        break;
      case PurchaseStatus.purchased:
        _deliver(purchase, restored: false);
        break;
      case PurchaseStatus.restored:
        _deliver(purchase, restored: true);
        break;
    }

    // Always finish the transaction so Play stops re-delivering it. For a
    // consumable bought with autoConsume this is already handled, but calling
    // it again is a harmless no-op.
    if (purchase.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchase);
      } catch (e) {
        debugPrint('Kuber: completePurchase failed for ${purchase.productID}: $e');
      }
    }
  }

  /// Grants (or re-grants) whatever a purchased/restored product entitles.
  void _deliver(PurchaseDetails purchase, {required bool restored}) {
    final productId = purchase.productID;

    // Support tiers grant nothing — they are a tip jar. Only thank the user on
    // a fresh purchase; a consumable is never "restored", so this is belt and
    // braces.
    if (kSupportProductIds.contains(productId)) {
      if (!restored) {
        final ctx = rootNavigatorKey.currentContext;
        final tier = SupportTierX.fromProductId(productId);
        if (ctx != null && tier != null) {
          showSupportThankYouSheet(ctx, tier);
        }
      }
      return;
    }

    final plan = planForProductId(productId);
    if (plan == null) return; // unknown product; ignore defensively.

    final activatedAt = _purchaseDate(purchase);
    _ref.read(kuberProStateProvider.notifier).applyPurchase(
          plan: plan,
          expiryDate: _expiryFor(plan, activatedAt, restored: restored),
          productId: productId,
          purchaseToken: purchase.verificationData.serverVerificationData,
          activatedAt: activatedAt,
          trialEndsAt: _trialEndFor(plan, activatedAt),
        );

    // A fresh purchase gets the celebratory success sheet; a silent cold-start
    // restore does not (it would ambush the user with a sheet they didn't ask
    // for on every launch).
    if (!restored) {
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        showProPurchaseSuccessSheet(
          ctx,
          newlyUnlocked: kProUnlockedFeatures,
          onGetStarted: () => rootNavigatorKey.currentState?.maybePop(),
        );
      }
    }
  }

  /// Best-effort detection of Play Billing's "item already owned" response
  /// across plugin versions: the code/message is not a stable enum here, so we
  /// match on the substring. A false negative simply falls back to the generic
  /// "payment failed" snackbar, so this is safe.
  bool _isAlreadyOwned(IAPError? error) {
    if (error == null) return false;
    final haystack =
        '${error.code} ${error.message} ${error.details}'.toLowerCase();
    return haystack.contains('already') && haystack.contains('own');
  }

  /// Silent recovery after a buy attempt returned itemAlreadyOwned. Fires a
  /// FRESH query (Play's local cache is now warm from the failed buy) and waits
  /// for the owned purchase to land on the stream. On success we apply
  /// entitlement (via [_deliver]) and show a friendly "Kuber Pro restored"
  /// snackbar — never the confusing "already owned" error. Only if the
  /// follow-up query STILL finds nothing do we fall back to the manual
  /// already-owned/Restore snackbar (extreme edge case).
  Future<void> _recoverAlreadyOwned() async {
    try {
      await restorePurchases(source: 'already_owned', force: true);
    } catch (e) {
      BillingDiagnostics.instance.recordError('recoverAlreadyOwned', e);
    }
    final granted = await _pollForPro(timeout: const Duration(seconds: 5));
    BillingDiagnostics.instance.log(
      'ALREADY_OWNED_RESULT',
      granted
          ? 'Entitlement restored after itemAlreadyOwned refresh'
          : 'Query still empty after itemAlreadyOwned refresh',
      {'granted': granted},
    );
    if (granted) {
      _snack((ctx, overlay) => showProRestoredSnackbar(ctx, overlay: overlay));
    } else {
      _snack((ctx, overlay) => showAlreadyOwnedSnackbar(
            ctx,
            onRestore: () => restorePurchases(force: true),
            overlay: overlay,
          ));
    }
  }

  /// The real purchase timestamp when Play reports one, else now. On Android
  /// `transactionDate` is epoch-milliseconds-as-string.
  DateTime _purchaseDate(PurchaseDetails purchase) {
    final raw = purchase.transactionDate;
    if (raw != null) {
      final ms = int.tryParse(raw);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.now();
  }

  /// Client-side expiry used only for the "Renews …" label on the manage
  /// screen. Deliberately null on restore: Play only ever restores an active
  /// subscription, but we can't know its true next-renewal date from the
  /// client, and a stale computed date would wrongly read as expired. Null
  /// renders as "Active" and never downgrades the user.
  DateTime? _expiryFor(ProPlan plan, DateTime activatedAt,
      {required bool restored}) {
    if (plan == ProPlan.lifetime) return null;
    if (restored) return null;
    return switch (plan) {
      ProPlan.monthly => activatedAt.add(const Duration(days: 30)),
      ProPlan.yearly => activatedAt.add(const Duration(days: 365)),
      ProPlan.lifetime => null,
    };
  }

  /// End of the Play Billing free-trial phase for a subscription, derived as
  /// `purchaseDate + kProTrialDuration`. Only the yearly base plan carries the
  /// trial (configured in Play Console), so only it gets a value.
  ///
  /// LIMITATION: `in_app_purchase` does not expose, cross-platform, whether a
  /// given purchase is actually in its free-trial phase (that needs the Play
  /// Developer API server-side, `paymentState == 2`). So this is a client-side
  /// estimate. It is correct for the two common cases — a fresh first-time
  /// yearly purchase (trial end in the future) and a restored older
  /// subscription (trial end already in the past, so `inTrialPhase` reads
  /// false = plain Pro). It can only be wrong for a rare resubscribe-without-a-
  /// -new-trial, where the pill would cosmetically show "trial" for 14 days;
  /// entitlement is unaffected. Verify precisely server-side in a future round.
  DateTime? _trialEndFor(ProPlan plan, DateTime activatedAt) {
    if (plan != ProPlan.yearly) return null;
    return activatedAt.add(kProTrialDuration);
  }
}

/// Play Billing free-trial length configured on the yearly base plan in Play
/// Console. Keep in sync with that configuration.
const kProTrialDuration = Duration(days: 14);

/// Polls [isPro] every [interval] until it returns true or [timeout] elapses,
/// returning the final value. Restored purchases grant entitlement
/// asynchronously on the purchase stream, so callers that drive a restore need
/// to wait a beat before reading the result — this is that wait, in one place
/// (the restore flow, the promo sheets, and the service's own already-owned
/// recovery all share it instead of re-rolling a poll loop).
Future<bool> pollForProEntitlement(
  bool Function() isPro, {
  Duration timeout = const Duration(seconds: 2),
  Duration interval = const Duration(milliseconds: 150),
}) async {
  if (isPro()) return true;
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(interval);
    if (isPro()) return true;
  }
  return isPro();
}

/// App-wide singleton. Initialized post-first-frame from `app.dart`; read from
/// buy sites (paywall, Buy Me a Coffee, restore link).
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService(ref);
  ref.onDispose(service.dispose);
  return service;
});
