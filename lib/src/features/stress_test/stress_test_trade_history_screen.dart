// ---------------------------------------------------------------------------
// Stress Test — full Trade History screen. Reached via the "More" button on
// the Trade History card on the main Stress Test screen. Lists every trade
// for the active session; tapping a row opens the trade detail screen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../shared/widgets/card_frame.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/more_less_pill.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../../shared/widgets/trade_history_tile.dart';
import 'stress_test_engine.dart';
import 'stress_test_naming.dart';

// Rows are revealed 6 at a time (MoreLessPill below the list) instead of
// all at once — same reasoning as the Portfolio counterpart
// (portfolio_trade_history_screen.dart) and search/widgets/company_list_screen.dart.
const int _revealBatchSize = 6;

class StressTestTradeHistoryScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const StressTestTradeHistoryScreen({super.key, required this.sessionId});

  @override
  ConsumerState<StressTestTradeHistoryScreen> createState() =>
      _StressTestTradeHistoryScreenState();
}

class _StressTestTradeHistoryScreenState
    extends ConsumerState<StressTestTradeHistoryScreen> {
  int _revealedCount = _revealBatchSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(widget.sessionId));
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.tradeHistoryTitle,
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
        child: session == null
            ? Center(
                child: Text(
                  l10n.stressTestTradeHistoryScreenSessionNotFound,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : session.trades.isEmpty
            ? Center(
                child: Text(
                  l10n.stressTestTradeHistoryScreenNoTradesYet,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: CardFrame(
                  padding: EdgeInsets.zero,
                  decoration: FomoShieldTheme.cardDecoration,
                  palette: palette,
                  child: Column(
                    children: [
                      for (
                        int i = 0,
                            revealed = _revealedCount.clamp(
                              0,
                              session.trades.length,
                            );
                        i < revealed;
                        i++
                      )
                        Builder(
                          builder: (context) {
                            final trade =
                                session.trades[session.trades.length - 1 - i];
                            return StaggerFadeIn(
                              index: i,
                              child: TradeHistoryTile(
                                symbol: trade.symbol,
                                companyName: resolveStressTestCompanyName(
                                  ref,
                                  trade.symbol,
                                ),
                                isBuy: trade.isBuy,
                                totalValue: trade.shares * trade.price,
                                showDivider: i != revealed - 1,
                                palette: palette,
                                onTap: () => context.push(
                                  '/stress-test/${widget.sessionId}/trade-detail',
                                  extra: trade,
                                ),
                              ),
                            );
                          },
                        ),
                      if (_revealedCount < session.trades.length)
                        MoreLessPill(
                          label: l10n.commonMoreCount(
                            session.trades.length - _revealedCount,
                          ),
                          onTap: () => setState(
                            () => _revealedCount += _revealBatchSize,
                          ),
                          palette: palette,
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
