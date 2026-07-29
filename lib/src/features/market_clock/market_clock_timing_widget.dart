import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
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

class TierStyle {
  final Color color;
  final String label;

  /// Full-length explanation for this tier. The widget only shows as much
  /// of this as fits (3 lines, ellipsis) — the detail card
  /// (market_clock_risk_detail_screen.dart) shows it in full. Currently
  /// short placeholder copy; swap in the longer real text here once it's
  /// written — no other code needs to change.
  final String description;

  const TierStyle({
    required this.color,
    required this.label,
    required this.description,
  });
}

const Map<RiskTier, TierStyle> _tierStyles = {
  RiskTier.low: TierStyle(
    color: ThemeV2.success,
    label: 'LOW RISK',
    description: 'Calm conditions — a good window for a planned trade.',
  ),
  RiskTier.moderate: TierStyle(
    color: ThemeV2.warning,
    label: 'MODERATE RISK',
    description:
        'Some risk factors elevated — a Limit Order is safer here.',
  ),
  RiskTier.high: TierStyle(
    color: ThemeV2.loss,
    label: 'HIGH RISK',
    description:
        'Multiple risk factors elevated — consider waiting this out.',
  ),
  RiskTier.closed: TierStyle(
    color: Colors.white70,
    label: 'MARKET CLOSED',
    description: 'No live trading right now — nothing to time.',
  ),
};

/// Public accessor so market_clock_risk_detail_screen.dart can show the
/// same label/color/description the widget uses, without exposing the
/// whole map.
TierStyle tierStyleFor(RiskTier tier) => _tierStyles[tier]!;

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
    final metrics = window.riskMetrics;
    final tier = window.riskTier;
    final style = _tierStyles[tier]!;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [dialLight, dialDark],
        ),
        borderRadius: FomoShieldTheme.cardRadius,
      ),
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
                  'FOMO SHIELD STATUS',
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
                _metricBar('Liquidity', metrics.liquidity),
                const SizedBox(height: 10),
                _metricBar('Volatility', metrics.volatility),
                const SizedBox(height: 10),
                _metricBar('News Risk', metrics.newsRisk),
                const SizedBox(height: 10),
                _metricBar('Beginner Safe', metrics.beginnerSafe),
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
                                    style.description,
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
                                'RISK SCORE',
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
