import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Wraps Google's User Messaging Platform (UMP) SDK — the GDPR/UK consent
/// flow Google requires before requesting personalized (and, for EEA/UK
/// users, any) ads. Google hosts the form's own copy and design entirely;
/// this just drives the request → show → done sequence Google's UMP
/// integration guide prescribes, so ad_service.dart's MobileAds.initialize()
/// only ever runs after this has settled.
class ConsentService {
  /// Requests the latest consent status from Google and shows the
  /// Google-hosted consent form if one is required — no-ops instantly for
  /// a user outside GDPR/UK scope, or one who already gave a still-valid
  /// answer (requestConsentInfoUpdate's own caching), since neither case
  /// has a form to show. Always call this before initializing the Mobile
  /// Ads SDK / requesting any ad, every app session — Google requires the
  /// status be re-checked each session, not just on first install.
  static Future<void> gatherConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(
        consentDebugSettings: kDebugMode
            ? ConsentDebugSettings(
                debugGeography: DebugGeography.debugGeographyEea,
                // This physical dev-test device's AdMob test-device hash
                // (logged by the SDK itself on first run) — without it,
                // debugGeographyEea alone doesn't reliably force the form
                // on a real (non-emulator) device.
                testIdentifiers: ['E9C631123C155B92EDA90F918304DA69'],
              )
            : null,
      ),
      () async {
        try {
          await _loadAndShowIfRequired();
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (error) {
        debugPrint('🔒 UMP requestConsentInfoUpdate failed: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    return completer.future;
  }

  static Future<void> _loadAndShowIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((formError) {
      if (formError != null) {
        debugPrint('🔒 UMP form error: ${formError.message}');
      }
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }

  /// True if a "manage consent" entry point must be reachable from app
  /// settings — required by Google Play policy for any user who was ever
  /// shown the form (EEA/UK), even after they've already answered it once.
  static Future<bool> isPrivacyOptionsRequired() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// Re-opens the same Google-hosted form in "manage consent" mode, for
  /// the Profile screen's Legal section entry.
  static Future<void> showPrivacyOptionsForm() {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        debugPrint('🔒 UMP privacy options form error: ${formError.message}');
      }
      if (!completer.isCompleted) completer.complete();
    });
    return completer.future;
  }
}
