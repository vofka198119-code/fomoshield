import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../supabase/supabase_client.dart';
import '../supabase/supabase_providers.dart';
import '../utils/constants.dart';

// ---------------------------------------------------------------------------
// Purchase Service — real Google Play Billing subscriptions.
//
// Phase 1 (2026-09-20): monthly base plan only. The `premium` subscription
// also has `quarterly`/`annual` base plans live in Play Console already
// (see fomoshield_monetization_setup_2026_09_20 memory), but the plan-
// picker UI to offer them is deliberately deferred — this only ever buys
// `monthly`.
//
// A completed purchase is never trusted on its own: [verifyWithBackend]
// hands the purchase token to scanco-backend, which re-checks it against
// the real Google Play Developer API before granting premium in Supabase
// (routes/purchases.js -> services/playBilling.js). Google also pushes
// renewal/cancel/refund events straight to that same backend via Real-time
// Developer Notifications, independent of whether this app is even open
// (routes/playRtdn.js) — this client only has to handle the purchase-time
// path.
// ---------------------------------------------------------------------------

const String premiumProductId = 'premium';
const String monthlyBasePlanId = 'monthly';

enum PurchaseOutcome { success, error, canceled }

class PurchaseService {
  PurchaseService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${AppConstants.backendBaseUrl}/api/v1',
        headers: AppConstants.backendApiKey.isEmpty
            ? null
            : {'X-API-Key': AppConstants.backendApiKey},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Read fresh on every request, not cached at construction time —
          // see the identical comment in finnhub_service.dart.
          final accessToken =
              SupabaseConfig.client.auth.currentSession?.accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
      ),
    );
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  late final Dio _dio;

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  Future<ProductDetails?> _queryMonthlyProduct() async {
    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.error != null) {
      debugPrint(
        'PurchaseService: queryProductDetails error: ${response.error}',
      );
    }
    for (final product in response.productDetails) {
      if (product is! GooglePlayProductDetails) continue;
      final index = product.subscriptionIndex;
      final offers = product.productDetails.subscriptionOfferDetails;
      if (index == null || offers == null) continue;
      if (offers[index].basePlanId == monthlyBasePlanId) return product;
    }
    return null;
  }

  /// Launches the Play Billing purchase sheet for the monthly plan.
  /// Returns false if billing isn't available or the product/offer
  /// couldn't be resolved — a real purchase result, success or failure,
  /// only ever arrives later via [purchaseStream], never as this method's
  /// return value.
  Future<bool> buyMonthly(String userId) async {
    if (!await _iap.isAvailable()) return false;
    final product = await _queryMonthlyProduct();
    if (product == null) return false;

    final purchaseParam = GooglePlayPurchaseParam(
      productDetails: product,
      // Maps to Play's obfuscatedAccountId — a defense-in-depth cross
      // check on top of the backend's own subscription_purchases lookup
      // (see docs/supabase_migration.sql), not the primary trust
      // mechanism.
      applicationUserName: userId,
      offerToken: (product as GooglePlayProductDetails).offerToken,
    );
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// The monthly plan's real price, already formatted/localized by Play
  /// Billing for the user's own region and currency (e.g. "$4.99",
  /// "€4,99", "₽399") — never hardcode a price string in the app, pricing
  /// varies by country and Google is the source of truth for it. Null if
  /// billing is unavailable or the product/offer couldn't be resolved
  /// (same conditions as [buyMonthly] returning false) — callers should
  /// fall back to a price-less label rather than blocking on this.
  Future<String?> monthlyPriceLabel() async {
    final product = await _queryMonthlyProduct();
    return product?.price;
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  /// Verifies a purchased/restored purchase with scanco-backend. Returns
  /// true only once the backend has confirmed it against Google and
  /// written premium to Supabase — callers should only acknowledge the
  /// purchase locally (completePurchase) after this returns true.
  Future<bool> verifyWithBackend(PurchaseDetails purchase) async {
    try {
      await _dio.post(
        '/purchases/verify',
        data: {
          'purchaseToken': purchase.verificationData.serverVerificationData,
          'productId': purchase.productID,
          'basePlanId': monthlyBasePlanId,
        },
      );
      return true;
    } catch (e) {
      debugPrint('PurchaseService: backend verify failed: $e');
      return false;
    }
  }

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);
}

final purchaseServiceProvider = Provider<PurchaseService>(
  (ref) => PurchaseService(),
);

/// The monthly plan's real, region-priced label (see
/// [PurchaseService.monthlyPriceLabel]) — watched by monetization_modal.dart
/// to show the actual charge on the Upgrade button instead of a bare
/// "Upgrade to Premium" with the price hidden until Play's own purchase
/// sheet. autoDispose: this is cheap to re-fetch and shouldn't outlive
/// whichever paywall sheet asked for it.
final monthlyPriceLabelProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.read(purchaseServiceProvider).monthlyPriceLabel(),
);

/// True while a purchase this app just launched is being processed
/// (Play's own sheet, then our backend verification) — watched by
/// monetization_modal.dart to show a loading state on the Upgrade button.
///
/// Watches currentUserProvider so a sign-out mid-purchase (however
/// unlikely — Play's own purchase sheet blocks the app while open, but a
/// PENDING purchase can sit around while the user backs out and switches
/// accounts) resets this back to false for whoever's signed in next,
/// instead of leaving a stale spinner from a different account's attempt
/// — same reset-on-account-switch idiom as
/// search_counter_provider.dart's searchCounterProvider. The purchase
/// itself is never at risk either way: syncSubscriptionForUser on the
/// backend independently refuses to grant premium to a mismatched
/// account (see playBilling.js's SubscriptionOwnershipMismatchError) —
/// this only ever affects which account's UI shows a leftover spinner.
final purchaseInFlightProvider = StateProvider<bool>((ref) {
  ref.watch(currentUserProvider);
  return false;
});

/// Set by the app-wide purchase-stream listener (see
/// initPurchaseListener in main.dart) once a purchase reaches a terminal
/// state, so whichever UI is still around (typically the monetization
/// modal) can react — e.g. via `ref.listen`. Null means "nothing to
/// report"; a consumer should reset it back to null after handling it.
/// Resets on account switch for the same reason as
/// [purchaseInFlightProvider] above.
final purchaseOutcomeProvider = StateProvider<PurchaseOutcome?>((ref) {
  ref.watch(currentUserProvider);
  return null;
});
