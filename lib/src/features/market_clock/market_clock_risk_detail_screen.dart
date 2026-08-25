import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../l10n/gen/app_localizations.dart';
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

class RiskStatusDetailScreen extends ConsumerWidget {
  final String windowId;
  const RiskStatusDetailScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final window = findWindowById(l10n, windowId);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.marketClockFomoShieldStatusTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 16,
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
        child: window == null
            ? const SizedBox()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final style = tierStyleFor(
                          l10n,
                          window.riskTierFor(l10n),
                        );
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
                                color: palette.textBody,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _Section(
                              label: l10n.marketClockRiskDetailWhyNowLabel,
                              body: window.riskMetricsFor(l10n).whyNow,
                              palette: palette,
                            ),
                            const SizedBox(height: 18),
                            _Section(
                              label: l10n.marketClockRiskDetailWhatToDoLabel,
                              body: window.riskMetricsFor(l10n).whatToDo,
                              palette: palette,
                              isLast: true,
                            ),
                          ],
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

class _Section extends StatelessWidget {
  final String label;
  final String body;
  final AppPalette palette;
  final bool isLast;
  const _Section({
    required this.label,
    required this.body,
    required this.palette,
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
              color: palette.accentPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: palette.textHeader,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
