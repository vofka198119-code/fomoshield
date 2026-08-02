// ---------------------------------------------------------------------------
// Stress Test — Portfolio Balance detail screen. Reached via the chevron
// next to the Portfolio Balance widget's title on the main Stress Test
// screen (see StressTestAllocationChart).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../market_clock/market_clock_dial.dart' show dialLight, dialDark;

class StressTestPortfolioBalanceScreen extends StatelessWidget {
  final String sessionId;

  const StressTestPortfolioBalanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
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
        child: Container(
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
                    'PORTFOLIO BALANCE',
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
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
