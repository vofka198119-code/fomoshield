import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'supabase_providers.dart';

// ---------------------------------------------------------------------------
// "Is this `free` reading real, or just a DB fetch that hasn't landed?"
// ---------------------------------------------------------------------------
// subscriptionTierProvider reports `free` both for a genuinely free user and
// while the subscription fetch is still in flight or has timed out. Anything
// that GRANTS on premium can ignore the difference — it re-renders when the
// real tier lands. Anything that TAKES SOMETHING AWAY cannot: acting on the
// early `free` punishes a paying user for the length of a network round-trip.
// subscriptionTierResolvedProvider exists to tell the two apart, and its own
// doc comment says to gate every such downgrade on it.
//
// The three payout clocks (Portfolio's weekly deposit, Stress Test's weekly
// top-up and its dividends) did not. All three pin their clock to "now" on a
// free reading so no backlog accrues while lapsed — correct for a real lapse,
// and silent theft of an accrued week on a bad connection. Nothing surfaces
// it: no error, no message, the payout simply never arrives.
//
// The rule, decided 2026-10-03: a `free` reading we could not confirm is not
// acted on at all — no credit, no pin, no "subscription paused" notice — until
// the tier has been unconfirmable for a full day straight. Any single
// successful read in that window resets the countdown. A day of genuine
// silence is then taken at face value.
//
// The trade this makes, deliberately: a lapsed user who stays offline for over
// a day may accrue a little simulated money they weren't owed. That is a far
// smaller harm than quietly erasing a week from someone who paid.
// ---------------------------------------------------------------------------

/// How long the tier must stay unconfirmable before `free` is believed.
const Duration freeReadingGracePeriod = Duration(hours: 24);

String _unknownSinceKey(String uid) => 'tier_unknown_since_$uid';

/// Whether a `free` tier reading may be acted on right now.
///
/// `false` means: do nothing this round — don't credit, don't pin a clock,
/// don't tell the user anything changed. The next check-in (every 20s while a
/// relevant screen is open, and on every app open) tries again.
Future<bool> freeReadingIsTrustworthy(WidgetRef ref) async {
  // Nobody signed in — there is no subscription question to answer, and
  // nothing of theirs to pin.
  final uid = ref.read(currentUserProvider)?.id;
  if (uid == null) return false;

  final prefs = await SharedPreferences.getInstance();
  final key = _unknownSinceKey(uid);

  if (ref.read(subscriptionTierResolvedProvider)) {
    // Confirmed — by the DB, by the admin email, or by being signed out.
    // Clear any countdown so a later outage starts from scratch.
    await prefs.remove(key);
    return true;
  }

  final raw = prefs.getString(key);
  final since = raw != null ? DateTime.tryParse(raw) : null;
  if (since == null) {
    await prefs.setString(key, DateTime.now().toIso8601String());
    return false;
  }
  return DateTime.now().difference(since) >= freeReadingGracePeriod;
}
