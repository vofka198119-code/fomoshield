import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_providers.dart';
import '../../shared/services/user_data_service.dart';
import 'stress_test_dca_provider.dart';
import 'stress_test_dividend_provider.dart';

// ---------------------------------------------------------------------------
// Stress Test funding flags — device ↔ server
// ---------------------------------------------------------------------------
// The weekly top-up (DCA) and dividend-simulation markers live in two
// device-local stores beside the session, deliberately (see either
// provider's header for why they aren't fields on StressTestSession). Until
// Migration 032 that was the whole story, so a reinstall brought the session
// back from Supabase with its funding silently stripped — the payouts simply
// stopped, with nothing on screen to say so.
//
// These two functions are the bridge. Both are fire-and-forget by design:
// the device copy is what the payout checks actually read, so a failed or
// slow server round-trip never blocks a credit, it just delays the backup.
// ---------------------------------------------------------------------------

const String _dcaKey = 'dca';
const String _dividendsKey = 'dividends';

/// Pushes both stores to user_data.stress_test_funding. Call after anything
/// that changes them: opting in at setup, and each credited period.
Future<void> pushStressTestFunding(WidgetRef ref) async {
  final uid = ref.read(currentUserProvider)?.id;
  if (uid == null) return;
  final service = ref.read(userDataServiceProvider);
  await service.saveStressTestFunding(uid, {
    _dcaKey: await exportDcaStore(uid),
    _dividendsKey: await exportDividendStore(uid),
  });
  // The Home rows read these through stressTestFundingFlagsProvider below;
  // without this a just-opted-in session shows no funding lines until the
  // next app start.
  ref.invalidate(stressTestFundingFlagsProvider);
}

/// Merges the server copy into the device's. Called once per login, from
/// userDataSyncProvider, alongside the session restore it belongs with.
Future<void> applyStressTestFunding(
  String uid,
  Map<String, dynamic> funding,
) async {
  final dca = funding[_dcaKey];
  if (dca is Map) {
    await importDcaStore(uid, Map<String, dynamic>.from(dca));
  }
  final dividends = funding[_dividendsKey];
  if (dividends is Map) {
    await importDividendStore(uid, Map<String, dynamic>.from(dividends));
  }
}

// ---------------------------------------------------------------------------
// Read side, for the UI
// ---------------------------------------------------------------------------
// Both stores are async (SharedPreferences), and the Home "active
// simulations" rows build synchronously — hence a FutureProvider rather than
// reading the stores inline. Invalidated wholesale by [pushStressTestFunding]
// so a fresh opt-in shows up immediately instead of on the next app start.

class StressTestFundingFlags {
  /// Simulated weekly deposits (the Custom-duration DCA option).
  final bool weeklyTopUp;
  final bool dividends;

  const StressTestFundingFlags({
    required this.weeklyTopUp,
    required this.dividends,
  });

  bool get any => weeklyTopUp || dividends;

  static const none = StressTestFundingFlags(
    weeklyTopUp: false,
    dividends: false,
  );
}

final stressTestFundingFlagsProvider =
    FutureProvider.family<StressTestFundingFlags, String>((
      ref,
      sessionId,
    ) async {
      final uid = ref.watch(currentUserProvider)?.id;
      final dca = await exportDcaStore(uid);
      final dividends = await exportDividendStore(uid);
      final dividendEntry = dividends[sessionId];
      return StressTestFundingFlags(
        weeklyTopUp: dca.containsKey(sessionId),
        dividends: dividendEntry is Map && dividendEntry['enabled'] == true,
      );
    });

