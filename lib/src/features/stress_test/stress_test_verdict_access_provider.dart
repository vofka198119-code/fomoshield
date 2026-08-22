import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_providers.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';

// ---------------------------------------------------------------------------
// Verdict Access — the "one free look after Premium lapses" gate.
// ---------------------------------------------------------------------------
// Only applies to a verdict whose session was slot #2/#3 (wasPremiumSlot —
// see VerdictArchiveEntry) AND the user is currently free-tier. A slot #1
// verdict, or any verdict while still premium/admin, is always unlimited —
// this provider returns true immediately for those, no SharedPreferences
// touched at all.
//
// The check-and-consume side effect (marking the one free view as used)
// happens exactly once per sessionId, the first time this FutureProvider's
// future actually runs — Riverpod memoizes it, so re-watching from the
// same still-mounted VerdictScreen (e.g. a theme/locale rebuild) does NOT
// burn a second view. It only re-runs if the provider is disposed and
// re-read (e.g. leaving and re-entering the verdict screen), which is
// exactly the "re-visit" this gate is meant to catch.
// ---------------------------------------------------------------------------

String _viewedKey(String? uid, String sessionId) => uid != null
    ? 'verdict_viewed_after_lapse_${uid}_$sessionId'
    : 'verdict_viewed_after_lapse_$sessionId';

/// True = show the verdict normally. False = the one free look has already
/// been used — caller should show a "renew Premium" prompt instead.
final verdictAccessProvider = FutureProvider.family<bool, String>((
  ref,
  sessionId,
) async {
  final archive = ref.watch(verdictArchiveProvider);
  final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
    (e) => e?.sessionId == sessionId,
    orElse: () => null,
  );
  if (entry == null || !entry.wasPremiumSlot) return true;

  final tier = ref.watch(subscriptionTierProvider);
  if (tier == SubscriptionTier.premium || tier == SubscriptionTier.admin) {
    return true;
  }

  final uid = ref.read(currentUserProvider)?.id;
  final prefs = await SharedPreferences.getInstance();
  final key = _viewedKey(uid, sessionId);
  if (prefs.getBool(key) ?? false) return false;
  await prefs.setBool(key, true);
  return true;
});
