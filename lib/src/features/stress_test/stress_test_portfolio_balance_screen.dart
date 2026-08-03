// ---------------------------------------------------------------------------
// Stress Test — Portfolio Balance detail screen. Reached via the chevron
// next to the Portfolio Balance widget's title on the main Stress Test
// screen (see StressTestAllocationChart). Hosts several widgets, built one
// at a time per user direction — Portfolio Health (dashboard-style 4-gauge
// summary) is pinned first, followed by the raw breakdown widgets.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import '../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import 'widgets/allocation_bar_row.dart';
import 'widgets/stress_test_sector_allocation_widget.dart';
import 'widgets/stress_test_asset_count_widget.dart';
import 'widgets/stress_test_portfolio_health_widget.dart';

class StressTestPortfolioBalanceScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestPortfolioBalanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'PORTFOLIO BALANCE',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (session != null) ...[
              StaggerFadeIn(
                index: 0,
                child: StressTestPortfolioHealthCard(session: session),
              ),
              const SizedBox(height: 16),
              StaggerFadeIn(
                index: 1,
                child: _AssetAllocationBarsCard(session: session),
              ),
              const SizedBox(height: 16),
              StaggerFadeIn(
                index: 2,
                child: StressTestSectorAllocationCard(session: session),
              ),
              const SizedBox(height: 16),
              StaggerFadeIn(
                index: 3,
                child: StressTestAssetCountCard(session: session),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// First widget on this screen: one horizontal gold bar per holding,
/// company name on the left (ellipsized), share of portfolio (0-100%) as
/// the bar's fill, percentage number at the end — same read as a workload
/// chart. Shows every holding, not just a preview — this is the detail
/// screen the ring's legend "More" button can't fully replace.
class _AssetAllocationBarsCard extends StatelessWidget {
  final StressTestSession session;

  const _AssetAllocationBarsCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final holdings = session.holdings;
    final invested = <({String symbol, double value})>[];
    double totalInvested = 0;
    for (final h in holdings) {
      final price = session.currentPrices[h.symbol] ?? h.entryPrice;
      final val = h.shares * price;
      invested.add((symbol: h.symbol, value: val));
      totalInvested += val;
    }
    invested.sort((a, b) => b.value.compareTo(a.value));
    final hasData = invested.isNotEmpty && totalInvested > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dialLight, dialDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Text(
                'ASSET ALLOCATION %',
                style: FomoShieldTheme.cardTitle(Colors.white),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          if (hasData)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: Column(
                children: [
                  for (final item in invested)
                    AllocationBarRow(
                      name: stressTestCompanyName(item.symbol),
                      percent: item.value / totalInvested * 100,
                    ),
                ],
              ),
            )
          else
            const SizedBox(height: 60),
        ],
      ),
    );
  }
}
