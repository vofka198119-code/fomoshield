import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_engine.dart';
import 'market_clock_risk_engine.dart';
import 'market_clock_timing_widget.dart' show tierStyleFor;

// ---------------------------------------------------------------------------
// FOMO Shield Status — description detail card. Reached by tapping the
// description window on the FOMO Shield Status widget (Market Clock).
// Shows THIS WINDOW's full "Why Now?" / "What Should You Do?" text
// (RiskMetrics.whyNow/whatToDo in market_clock_risk_engine.dart) — the
// widget itself only shows a 3-line truncated preview of whyNow. Label/
// color still come from the tier (tierStyleFor).
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
                          const SizedBox(height: 20),
                          _Section(
                            label: 'Why Now?',
                            body: window.riskMetrics.whyNow,
                          ),
                          const SizedBox(height: 18),
                          _Section(
                            label: 'What Should You Do?',
                            body: window.riskMetrics.whatToDo,
                            isLast: true,
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

class _Section extends StatelessWidget {
  final String label;
  final String body;
  final bool isLast;
  const _Section({
    required this.label,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
