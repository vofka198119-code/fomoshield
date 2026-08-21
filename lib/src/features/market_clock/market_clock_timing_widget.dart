import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';
import 'market_clock_dial.dart';
import 'market_clock_engine.dart';
import 'market_clock_risk_engine.dart';

// ---------------------------------------------------------------------------
// FOMO Shield Status widget (id: 'timing_indicator') — 3rd Market Clock
// widget. Modeled on a user-provided reference mockup: a dark instrument-
// panel card with a composite Risk Score, 4 sub-metric bars (Liquidity /
// Volatility / News Risk / Beginner Safe), and a plain-language risk label
// + tip. Layout adapted for phone width per explicit feedback — the
// reference's side-by-side columns became bars-on-top, label+advice below.
// Risk-metrics data/logic lives in market_clock_risk_engine.dart, kept
// separate so this file stays purely visual.
// ---------------------------------------------------------------------------

/// Tier only drives the color/label banner now — the actual explanation
/// text is per-WINDOW (see RiskMetrics.description in
/// market_clock_risk_engine.dart), not per-tier, so two different windows
/// landing in the same tier show their own distinct text.
class TierStyle {
  final Color color;
  final String label;

  const TierStyle({required this.color, required this.label});
}

Map<RiskTier, TierStyle> _tierStylesFor(AppLocalizations l10n) => {
  RiskTier.low: TierStyle(
    color: ThemeV2.success,
    label: l10n.marketClockRiskTierLowLabel,
  ),
  RiskTier.moderate: TierStyle(
    color: ThemeV2.warning,
    label: l10n.marketClockRiskTierModerateLabel,
  ),
  RiskTier.high: TierStyle(
    color: ThemeV2.loss,
    label: l10n.marketClockRiskTierHighLabel,
  ),
  RiskTier.closed: TierStyle(
    color: Colors.white70,
    label: l10n.marketClockRiskTierClosedLabel,
  ),
};

/// Public accessor so market_clock_risk_detail_screen.dart can show the
/// same label/color the widget uses, without exposing the whole map.
TierStyle tierStyleFor(AppLocalizations l10n, RiskTier tier) =>
    _tierStylesFor(l10n)[tier]!;

/// Thin gold-bordered "window" — same instrument-panel language as the
/// clock's digital readout / corner panels (dialBrassLight border on a
/// dark, semi-transparent fill).
Widget _goldWindow({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: dialDark.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: dialBrassLight.withValues(alpha: 0.4)),
    ),
    child: child,
  );
}

class FomoShieldStatusWidget extends StatelessWidget {
  final MarketWindow window;
  const FomoShieldStatusWidget({super.key, required this.window});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metrics = window.riskMetricsFor(l10n);
    final tier = window.riskTierFor(l10n);
    final style = _tierStylesFor(l10n)[tier]!;

    return Container(
      decoration: darkCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: shield + title ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, color: dialBrassLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.marketClockFomoShieldStatusTitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: dialBrassLight.withValues(alpha: 0.3),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bars first (phone-friendly — full width) ────────
                _metricBar(l10n.marketClockMetricLiquidity, metrics.liquidity),
                const SizedBox(height: 10),
                _metricBar(
                  l10n.marketClockMetricVolatility,
                  metrics.volatility,
                ),
                const SizedBox(height: 10),
                _metricBar(l10n.marketClockMetricNewsRisk, metrics.newsRisk),
                const SizedBox(height: 10),
                _metricBar(
                  l10n.marketClockMetricFomoShield,
                  metrics.fomoShield,
                ),
                const SizedBox(height: 16),

                // ── Description window + Risk Score window, side by
                // side with a gap ───────────────────────────────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Description window — tappable, shows a
                      // truncated preview here and the full text on the
                      // detail card. ─────────────────────────────────
                      Expanded(
                        flex: 3,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.push(
                              '/market-clock/risk-status/${window.id}',
                            ),
                            child: _goldWindow(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          style.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: style.color,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 16,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    metrics.whyNow,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // ── Risk Score window — the number is the only
                      // colored/"indicator" text here, everything else
                      // white, centered in the box. ────────────────────
                      Expanded(
                        flex: 2,
                        child: _goldWindow(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                l10n.marketClockRiskScoreLabel,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: tier == RiskTier.closed
                                          ? '—'
                                          : '${metrics.score}',
                                      style: GoogleFonts.inter(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: style.color,
                                      ),
                                    ),
                                    if (tier != RiskTier.closed)
                                      TextSpan(
                                        text: '/100',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// All 4 bars now share the brand gold (dialBrassLight) — same accent as
  /// the clock face's ring — with a soft matching glow underneath, instead
  /// of the earlier per-metric semantic colors.
  Widget _metricBar(String label, int value) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: dialBrassLight.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(dialBrassLight),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
