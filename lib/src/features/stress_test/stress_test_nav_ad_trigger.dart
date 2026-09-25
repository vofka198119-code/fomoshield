import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ads/ad_providers.dart';
import '../../core/supabase/supabase_providers.dart';
import 'stress_test_ad_provider.dart';

/// Increments the shared Stress Test navigation counter and shows an
/// interstitial if this screen change crosses the threshold. No-ops for
/// Premium/Admin. Deliberately NOT called from OrderEntryScreen or the
/// session hub (StressTestScreen) — see fomoshield_admob_plan_2026_09_22
/// memory for which screens count and why.
///
/// Every call site is a screen's own `initState` — modifying
/// `stressTestAdProvider`'s state synchronously from there throws
/// Riverpod's "Tried to modify a provider while the widget tree was
/// building" (confirmed live 2026-09-22: `StateNotifier.state=` called
/// from `StatefulElement._firstBuild` via `initState`). `Future(() {...})`
/// is Riverpod's own suggested fix for exactly this — defers the actual
/// increment to right after the current build finishes.
void maybeShowStressTestNavAd(WidgetRef ref) {
  debugPrint('🎬 maybeShowStressTestNavAd: scheduled');
  Future(() async {
    // Awaits the real tier instead of racing subscriptionTierProvider's
    // async DB fetch — see resolveSubscriptionTier's doc comment. Fires
    // on every Stress Test screen's initState, including right after a
    // cold start, same race class as the App Open ad fix (59d18aa/
    // 63314eb).
    final tier = await resolveSubscriptionTier(ref);
    debugPrint('🎬 maybeShowStressTestNavAd: tier=$tier');
    if (tier.isPremiumOrAdmin) {
      debugPrint('🎬 maybeShowStressTestNavAd: skipped (premium/admin)');
      return;
    }
    final trigger = await ref
        .read(stressTestAdProvider.notifier)
        .incrementAndCheck();
    debugPrint('🎬 maybeShowStressTestNavAd: incrementAndCheck -> $trigger');
    if (trigger) {
      debugPrint('🎬 maybeShowStressTestNavAd: showInterstitial()');
      ref.read(adServiceProvider).showInterstitial();
    }
  });
}

/// Drop this anywhere in a `ConsumerWidget` Stress Test screen's tree (it
/// renders nothing) to call [maybeShowStressTestNavAd] exactly once, when
/// this screen is first built — a `StatefulWidget`'s own `initState` runs
/// exactly once per route push regardless of the parent widget's type, so
/// this works the same as calling it directly from `initState` on the
/// screens that have one.
class StressTestNavAdTrigger extends ConsumerStatefulWidget {
  const StressTestNavAdTrigger({super.key});

  @override
  ConsumerState<StressTestNavAdTrigger> createState() =>
      _StressTestNavAdTriggerState();
}

class _StressTestNavAdTriggerState
    extends ConsumerState<StressTestNavAdTrigger> {
  @override
  void initState() {
    super.initState();
    maybeShowStressTestNavAd(ref);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
