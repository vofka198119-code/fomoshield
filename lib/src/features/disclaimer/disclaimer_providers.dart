import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Document Versions Model
// ---------------------------------------------------------------------------

class DocumentVersions {
  final String disclaimerVersion;
  final String privacyPolicyVersion;
  final String termsVersion;
  final String updatedAt;

  const DocumentVersions({
    required this.disclaimerVersion,
    required this.privacyPolicyVersion,
    required this.termsVersion,
    required this.updatedAt,
  });

  factory DocumentVersions.fromJson(Map<String, dynamic> json) {
    return DocumentVersions(
      disclaimerVersion: json['disclaimer_version'] as String? ?? '1.0',
      privacyPolicyVersion: json['privacy_policy_version'] as String? ?? '1.0',
      termsVersion: json['terms_version'] as String? ?? '1.0',
      updatedAt: json['updated_at'] as String? ?? '2026-06-21',
    );
  }

  Map<String, dynamic> toJson() => {
        'disclaimer_version': disclaimerVersion,
        'privacy_policy_version': privacyPolicyVersion,
        'terms_version': termsVersion,
        'updated_at': updatedAt,
      };
}

// ---------------------------------------------------------------------------
// Remote Versions Provider (simulates backend fetch)
// ---------------------------------------------------------------------------

final remoteVersionsProvider = FutureProvider<DocumentVersions>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));

  // In production, replace with actual HTTP call to your backend
  // e.g. final response = await dio.get('https://api.fomoshield.com/config/versions');
  return const DocumentVersions(
    disclaimerVersion: '1.0',
    privacyPolicyVersion: '1.0',
    termsVersion: '1.0',
    updatedAt: '2026-06-21',
  );
});

// ---------------------------------------------------------------------------
// Accepted Versions Provider (shared_preferences)
// ---------------------------------------------------------------------------

class AcceptedVersionsNotifier extends StateNotifier<DocumentVersions?> {
  AcceptedVersionsNotifier() : super(null) {
    _load();
  }

  static const _prefix = 'accepted_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dv = prefs.getString('${_prefix}disclaimer_version');
    final ppv = prefs.getString('${_prefix}privacy_policy_version');
    final tv = prefs.getString('${_prefix}terms_version');
    final ua = prefs.getString('${_prefix}updated_at');

    if (dv != null && ppv != null && tv != null) {
      state = DocumentVersions(
        disclaimerVersion: dv,
        privacyPolicyVersion: ppv,
        termsVersion: tv,
        updatedAt: ua ?? '',
      );
    }
  }

  Future<void> accept(DocumentVersions versions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}disclaimer_version', versions.disclaimerVersion);
    await prefs.setString('${_prefix}privacy_policy_version', versions.privacyPolicyVersion);
    await prefs.setString('${_prefix}terms_version', versions.termsVersion);
    await prefs.setString('${_prefix}updated_at', versions.updatedAt);
    state = versions;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_prefix}disclaimer_version');
    await prefs.remove('${_prefix}privacy_policy_version');
    await prefs.remove('${_prefix}terms_version');
    await prefs.remove('${_prefix}updated_at');
    state = null;
  }
}

final acceptedVersionsProvider =
    StateNotifierProvider<AcceptedVersionsNotifier, DocumentVersions?>((ref) {
  return AcceptedVersionsNotifier();
});

// ---------------------------------------------------------------------------
// Versions Match Check (for disclaimer screen — uses StateNotifier)
// ---------------------------------------------------------------------------

final versionsMatchProvider = FutureProvider<bool>((ref) async {
  final remote = await ref.watch(remoteVersionsProvider.future);
  final accepted = ref.watch(acceptedVersionsProvider);

  if (accepted == null) return false;

  return accepted.disclaimerVersion == remote.disclaimerVersion &&
      accepted.privacyPolicyVersion == remote.privacyPolicyVersion &&
      accepted.termsVersion == remote.termsVersion;
});

// ---------------------------------------------------------------------------
// Disclaimer Accepted Check (reads SharedPreferences directly — safe for splash)
// ---------------------------------------------------------------------------

/// Reads accepted versions directly from SharedPreferences (awaits completion)
/// and compares with remote versions. Safe to use in splash screen — no race.
final isDisclaimerAcceptedProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final dv = prefs.getString('accepted_disclaimer_version');
  final ppv = prefs.getString('accepted_privacy_policy_version');
  final tv = prefs.getString('accepted_terms_version');

  if (dv == null || ppv == null || tv == null) return false;

  final remote = await ref.watch(remoteVersionsProvider.future);
  return dv == remote.disclaimerVersion &&
      ppv == remote.privacyPolicyVersion &&
      tv == remote.termsVersion;
});

// ---------------------------------------------------------------------------
// Geo-blocking Provider
// ---------------------------------------------------------------------------

class GeoCheckResult {
  final bool isBlocked;
  final String? reason;

  const GeoCheckResult({required this.isBlocked, this.reason});
}

final geoCheckProvider = FutureProvider<GeoCheckResult>((ref) async {
  // ⚠️ TEMPORARY: Hardcoded to allow all regions.
  // Before publication, restore real GeoIP check via backend:
  //   1) Check locale countryCode for RU/BY
  //   2) Call backend GeoIP endpoint
  //   3) Return isBlocked: true with reason if restricted
  return const GeoCheckResult(isBlocked: false);
});
