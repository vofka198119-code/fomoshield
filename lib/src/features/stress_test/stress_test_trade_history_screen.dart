// ---------------------------------------------------------------------------
// Stress Test — full Trade History screen. Reached via the "More" button on
// the Trade History card on the main Stress Test screen. Lists every trade
// for the active session; tapping a row opens the trade detail screen.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import '../../shared/widgets/trade_history_tile.dart';
import '../assets/screens/stock_detail/widgets/stock_detail_helpers.dart';
import 'stress_test_engine.dart';

class StressTestTradeHistoryScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestTradeHistoryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));

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
          'TRADE HISTORY',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: session == null
          ? const Center(child: Text('Session not found'))
          : session.trades.isEmpty
          ? const Center(child: Text('No trades yet'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: FomoShieldTheme.cardDecoration,
                clipBehavior: Clip.antiAlias,
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
                              companyName: stressTestCompanyName(trade.symbol),
                              isBuy: trade.isBuy,
                              totalValue: trade.shares * trade.price,
                              showDivider: i != session.trades.length - 1,
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
    );
  }
}
