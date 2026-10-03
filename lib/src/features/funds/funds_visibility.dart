import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_providers.dart';

// ---------------------------------------------------------------------------
// One switch for the whole Funds (ETF) module
// ---------------------------------------------------------------------------
// The module merged into master on 2026-10-03, while none of it has been
// device-tested — the fund bankruptcy flow in particular has never run end to
// end. Master is the branch releases are cut from, and production access was
// days away, so shipping it visible would have put a half-proven feature in
// front of real users the first time a build went out.
//
// Admin-only until it's been exercised properly. To open it up, change this
// one line to `true` (or to a premium check) — every entry point reads it:
// the Home card, Search's Funds lane, and the /funds/* routes themselves,
// which redirect rather than merely hide, so a stale deep link can't walk in
// behind the UI.
// ---------------------------------------------------------------------------

final fundsVisibleProvider = Provider<bool>((ref) {
  return ref.watch(isAdminProvider);
});
