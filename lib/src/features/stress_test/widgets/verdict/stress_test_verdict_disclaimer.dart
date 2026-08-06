// ---------------------------------------------------------------------------
// Stress Test — Verdict/Psychology Meter disclaimer. Mandatory: every
// screen that shows verdict scores, tier copy, or psychology-marker
// analysis ends with this — Session Complete (verdict_screen.dart), the
// generic per-marker "More" screen (verdict_marker_detail_screen.dart),
// and the Psychology Meter detail screen
// (stress_test_psychology_meter_screen.dart). One per screen, at the
// bottom — not per small condensed widget/card.
//
// Same centered title+body shape as stress_test_portfolio_balance_screen's
// _educationalDisclaimer() ("Company Card style"), but this is a distinct,
// stress-test-verdict-specific text — don't merge the two.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';

class StressTestVerdictDisclaimer extends StatelessWidget {
  const StressTestVerdictDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            'Disclaimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Please note: the stress test results, scores, insights, and '
            'written feedback provided by this application are intended '
            'for educational and informational purposes only.\n\n'
            'All verdicts are generated automatically by analyzing your '
            'decisions within simulated market scenarios inspired by '
            'historical market events and generally accepted long-term '
            'investing principles. While every effort has been made to '
            'create realistic simulations, they cannot account for every '
            'factor that may influence real financial markets.\n\n'
            'Past market events and historical performance do not '
            'guarantee that similar conditions or outcomes will occur in '
            'the future. Real-world market behavior may differ '
            'significantly from the scenarios presented in this '
            'application. Any similarities between the simulations and '
            'actual market events should be viewed solely as educational '
            'examples and not as predictions or forecasts.\n\n'
            'This application does not provide investment, financial, '
            'legal, or tax advice and should not be interpreted as a '
            'recommendation to buy, sell, or hold any security, asset, or '
            'financial instrument.\n\n'
            'All investment decisions are made solely by the user and '
            'remain the user\'s sole responsibility. The developers of '
            'this application accept no liability for any financial '
            'losses, lost profits, investment outcomes, or any direct, '
            'indirect, incidental, or consequential damages resulting '
            'from the use of this application, its content, or decisions '
            'made based on the information provided.\n\n'
            'The primary purpose of this application is to help users '
            'better understand the fundamentals of investing, portfolio '
            'diversification, risk management, long-term investing '
            'principles, and the psychological aspects of investment '
            'decision-making. All content is provided exclusively for '
            'educational purposes and should not be considered a '
            'substitute for professional financial advice or a guide for '
            'making real-world investment decisions.',
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
