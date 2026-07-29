import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_engine.dart';
import 'market_clock_risk_engine.dart';
import 'market_clock_timing_widget.dart' show tierStyleFor;

// ---------------------------------------------------------------------------
// FOMO Shield Status — description detail card. Reached by tapping the
// description window on the FOMO Shield Status widget (Market Clock).
// Shows that tier's full, untruncated description — the widget itself only
// shows as much as fits in 3 lines. Currently reuses the same short
// placeholder copy as the widget; once the user supplies the real, longer
// per-tier text, it only needs to change in one place (tierStyleFor's
// description field in market_clock_timing_widget.dart).
// ---------------------------------------------------------------------------

class RiskStatusDetailScreen extends StatelessWidget {
  final String windowId;
  const RiskStatusDetailScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context) {
    final window = findWindowById(windowId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'FOMO SHIELD STATUS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: window == null
          ? const SizedBox()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final style = tierStyleFor(window.riskTier);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style.label,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: style.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            window.shortHeadline,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            style.description,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: ThemeV2.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
