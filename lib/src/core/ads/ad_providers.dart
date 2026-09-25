import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ad_service.dart';
import 'consent_service.dart';

final adServiceProvider = Provider<AdService>((ref) => AdService());

/// Whether the Profile screen's "Ad Consent" row should be shown at all —
/// Google Play policy requires it reachable for anyone the UMP form was
/// ever shown to (EEA/UK), but there's nothing to manage for a user
/// outside that scope, so this hides the row entirely instead of showing
/// a dead end. Re-evaluated each time Profile is opened rather than cached
/// app-wide, since gatherConsent() (splash) can change the answer.
final privacyOptionsRequiredProvider = FutureProvider.autoDispose<bool>(
  (ref) => ConsentService.isPrivacyOptionsRequired(),
);
