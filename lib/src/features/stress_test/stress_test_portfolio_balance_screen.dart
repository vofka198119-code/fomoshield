// ---------------------------------------------------------------------------
// Stress Test — Portfolio Balance detail screen. Reached via the chevron
// next to the Portfolio Balance widget's title on the main Stress Test
// screen (see StressTestAllocationChart). Hosts several widgets, built one
// at a time per user direction — Portfolio Health (dashboard-style 4-gauge
// summary) is pinned first, followed by the raw breakdown widgets.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../market_clock/market_clock_dial.dart' show dialLight, dialDark;
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_portfolio_balance_widget_order_provider.dart';
import '../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import 'widgets/allocation_bar_row.dart';
import 'widgets/stress_test_sector_allocation_widget.dart';
import 'widgets/stress_test_asset_count_widget.dart';
import 'widgets/stress_test_portfolio_health_widget.dart';
import 'widgets/stress_test_portfolio_balance_widget_settings_sheet.dart';

class StressTestPortfolioBalanceScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestPortfolioBalanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));
    final widgetConfigs = ref.watch(
      portfolioBalanceWidgetOrderProvider(sessionId),
    );
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
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
              for (int i = 0; i < visibleWidgets.length; i++) ...[
                StaggerFadeIn(
                  index: i,
                  child: _buildWidgetById(visibleWidgets[i].id, session),
                ),
                const SizedBox(height: 16),
              ],

              // ── Add widgets button ───────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: () => _showWidgetSettingsSheet(context, ref),
                  icon: const Icon(
                    Icons.add_rounded,
                    color: ThemeV2.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Add widgets',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(
                        color: ThemeV2.primary,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Educational disclaimer ───────────────────────
              _educationalDisclaimer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetById(String id, StressTestSession session) {
    switch (id) {
      case 'portfolio_health':
        return StressTestPortfolioHealthCard(session: session);
      case 'asset_allocation':
        return _AssetAllocationBarsCard(session: session);
      case 'diversification_indicator':
        return StressTestSectorAllocationCard(session: session);
      case 'diversification_progress':
        return StressTestAssetCountCard(session: session);
      default:
        return const SizedBox.shrink();
    }
  }

  void _showWidgetSettingsSheet(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(
      portfolioBalanceWidgetOrderProvider(sessionId).notifier,
    );
    final currentConfigs = ref.read(
      portfolioBalanceWidgetOrderProvider(sessionId),
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => StressTestPortfolioBalanceWidgetSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
      ),
    );
  }

  // Same centered title+body shape as order_config_section.dart's
  // Simulated Trading disclaimer ("Company Card style").
  Widget _educationalDisclaimer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            'Educational Disclaimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This application is intended to help users learn about '
            'investing and portfolio management. All scores, indicators, '
            'simulations, and educational content are provided for '
            'informational purposes only and should not be interpreted as '
            'financial advice or investment recommendations.\n\n'
            'The app does not tell you what to buy, sell, or hold. Its '
            'purpose is to explain investment concepts, visualize '
            'portfolio characteristics, and support learning through '
            'educational tools.\n\n'
            'Investing involves risk, and the value of investments can '
            'rise or fall. Past performance and simulated results are not '
            'guarantees of future performance. Always perform your own '
            'research and, when appropriate, seek advice from a licensed '
            'financial professional before making investment decisions.\n\n'
            'By using this application, you acknowledge that all '
            'investment decisions remain your sole responsibility.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: ThemeV2.textPrimary,
              height: 1.5,
            ),
          ),
        ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ASSET ALLOCATION %',
                    style: FomoShieldTheme.cardTitle(Colors.white),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.push('/metric-info/asset-allocation-pct'),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.help_outline_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
