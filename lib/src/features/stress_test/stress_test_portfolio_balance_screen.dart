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
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_button.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../market_clock/market_clock_dial.dart' show darkCardDecoration;
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'stress_test_portfolio_balance_widget_order_provider.dart';
import 'stress_test_naming.dart';
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
    final l10n = AppLocalizations.of(context)!;
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));
    final widgetConfigs = ref.watch(
      portfolioBalanceWidgetOrderProvider(sessionId),
    );
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.portfolioBalanceScreenTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (session != null) ...[
                for (int i = 0; i < visibleWidgets.length; i++) ...[
                  StaggerFadeIn(
                    index: i,
                    child: _buildWidgetById(
                      visibleWidgets[i].id,
                      session,
                      palette,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Add widgets button ───────────────────────────
                Center(
                  child: themedAddWidgetsButton(
                    context,
                    palette,
                    label: l10n.homeAddWidgets,
                    onTap: () => _showWidgetSettingsSheet(context, ref),
                  ),
                ),

                // ── Educational disclaimer ───────────────────────
                _educationalDisclaimer(l10n, palette),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetById(
    String id,
    StressTestSession session,
    AppPalette palette,
  ) {
    switch (id) {
      case 'portfolio_health':
        return StressTestPortfolioHealthCard(
          session: session,
          palette: palette,
        );
      case 'asset_allocation':
        return _AssetAllocationBarsCard(session: session, palette: palette);
      case 'diversification_indicator':
        return StressTestSectorAllocationCard(
          session: session,
          palette: palette,
        );
      case 'diversification_progress':
        return StressTestAssetCountCard(session: session, palette: palette);
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

    final palette = resolveAppPalette(ref.read(themeVariantProvider));

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => StressTestPortfolioBalanceWidgetSettingsSheet(
        initialConfigs: currentConfigs,
        notifier: notifier,
        palette: palette,
      ),
    );
  }

  // Same centered title+body shape as order_config_section.dart's
  // Simulated Trading disclaimer ("Company Card style"). Color is the
  // same fixed muted gray as DisclaimerFooter's reference treatment
  // (2026-08-25: unify every card-level disclaimer to that one look) —
  // NOT palette-based (palette param kept for the caller's other uses).
  Widget _educationalDisclaimer(AppLocalizations l10n, AppPalette palette) {
    final disclaimerColor = ThemeV2.textSecondary.withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            l10n.portfolioBalanceScreenDisclaimerTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: disclaimerColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.portfolioBalanceScreenDisclaimerBody,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: disclaimerColor,
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
class _AssetAllocationBarsCard extends ConsumerWidget {
  final StressTestSession session;
  final AppPalette palette;

  const _AssetAllocationBarsCard({
    required this.session,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: BorderRadius.circular(20),
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      palette: palette,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  themedGoldGradient(
                    Text(
                      l10n.portfolioBalanceScreenAssetAllocationTitle,
                      style: FomoShieldTheme.cardTitle(Colors.white).copyWith(
                        shadows: palette.titleShadow != null
                            ? [palette.titleShadow!]
                            : null,
                      ),
                    ),
                    palette,
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
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
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
                      name: resolveStressTestCompanyName(ref, item.symbol),
                      percent: item.value / totalInvested * 100,
                      palette: palette,
                      dangerZoneGradient: true,
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
