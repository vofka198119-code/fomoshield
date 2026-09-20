import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../supabase/supabase_providers.dart';
import 'purchase_service.dart';

// ---------------------------------------------------------------------------
// Purchase Listener — the one place that reacts to Play Billing's
// purchaseStream for the whole app's lifetime. Deliberately NOT scoped to
// monetization_modal.dart: a purchase can complete or get restored after
// that bottom sheet is long gone (the OS account picker, a delayed
// restore, an undelivered purchase from a previous session replaying on
// this app launch — see InAppPurchase.purchaseStream's own doc comment),
// so this has to be wired up once, near app start (see main.dart), not
// per-screen.
// ---------------------------------------------------------------------------

StreamSubscription<List<PurchaseDetails>>? _subscription;

/// Starts listening to the Play Billing purchase stream. Safe to call more
/// than once (e.g. a hot restart re-running main()) — only the first call
/// actually subscribes.
void initPurchaseListener(WidgetRef ref) {
  if (_subscription != null) return;
  final service = ref.read(purchaseServiceProvider);
  _subscription = service.purchaseStream.listen(
    (purchases) => _handlePurchases(ref, service, purchases),
    onError: (Object error) {
      debugPrint('initPurchaseListener: purchase stream error: $error');
    },
  );
}

Future<void> _handlePurchases(
  WidgetRef ref,
  PurchaseService service,
  List<PurchaseDetails> purchases,
) async {
  for (final purchase in purchases) {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Still in flight (e.g. slow/offline payment method) —
        // purchaseInFlightProvider stays true, nothing to report yet.
        break;

      case PurchaseStatus.canceled:
        ref.read(purchaseInFlightProvider.notifier).state = false;
        ref.read(purchaseOutcomeProvider.notifier).state =
            PurchaseOutcome.canceled;
        break;

      case PurchaseStatus.error:
        debugPrint(
          'initPurchaseListener: purchase error: ${purchase.error}',
        );
        ref.read(purchaseInFlightProvider.notifier).state = false;
        ref.read(purchaseOutcomeProvider.notifier).state =
            PurchaseOutcome.error;
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Trust nothing client-side — scanco-backend re-checks this
        // token against the real Google Play Developer API before
        // granting premium (see purchase_service.dart's doc comment).
        final verified = await service.verifyWithBackend(purchase);
        if (verified) {
          refreshSubscriptionTier(ref);
          // Only acknowledge locally once the backend has actually
          // granted premium — an unverified purchase stays pending and
          // gets re-delivered on this stream next app start, giving a
          // transient backend failure a free retry instead of silently
          // losing the purchase.
          if (purchase.pendingCompletePurchase) {
            await service.completePurchase(purchase);
          }
        }
        ref.read(purchaseInFlightProvider.notifier).state = false;
        ref.read(purchaseOutcomeProvider.notifier).state = verified
            ? PurchaseOutcome.success
            : PurchaseOutcome.error;
        break;
    }
  }
}
