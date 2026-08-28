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
import '../../shared/widgets/stagger_fade_in.dart';
import '../../shared/widgets/trade_history_tile.dart';
import 'stress_test_engine.dart';
import 'stress_test_naming.dart';

class StressTestTradeHistoryScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestTradeHistoryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));
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
                  showTopBar: false,
                  padding: EdgeInsets.zero,
                  decoration: FomoShieldTheme.cardDecoration,
                  palette: palette,
                  child: Column(
                    children: [
                      for (int i = 0; i < session.trades.length; i++)
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
                                showDivider: i != session.trades.length - 1,
                                palette: palette,
                                onTap: () => context.push(
                                  '/stress-test/$sessionId/trade-detail',
                                  extra: trade,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
