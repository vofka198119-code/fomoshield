// ---------------------------------------------------------------------------
// Simulated Trading & Non-Brokerage Disclaimer — shared between the
// order entry screens (buy/sell) and Stress Test's own Company Card, so
// the same legal text appears verbatim wherever the user can place a trade.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';

class SimulatedTradingDisclaimer extends StatelessWidget {
  const SimulatedTradingDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          Text(
            'Simulated Trading & Non-Brokerage Disclaimer',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This application is not a registered broker-dealer, investment '
            'advisor, or financial institution, and does not provide order '
            'execution services for real financial markets.\n\n'
            'All buy and sell operations are performed exclusively on a '
            'simulated account using virtual currency (Paper Trading). '
            'Transactions executed within this app are intended solely for '
            'educational purposes, do not result in the purchase or '
            'ownership of actual securities, create no shareholder rights, '
            'and carry no real-world financial or legal force.',
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
