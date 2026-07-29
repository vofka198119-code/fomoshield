import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Buy Timing widget (id: 'timing_indicator') — 3rd Market Clock widget.
// Reads the current window's [TradeSafety] classification (see
// market_clock_engine.dart) and shows a simple, non-technical readout: is
// right now a calm moment for a planned trade, or a volatile/illiquid one
// worth waiting out. Same card shell as MarketPhaseWidget.
// ---------------------------------------------------------------------------

class _SafetyStyle {
  final Color color;
  final IconData icon;
  final String label;
  final String description;

  const _SafetyStyle({
    required this.color,
    required this.icon,
    required this.label,
    required this.description,
  });
}

const Map<TradeSafety, _SafetyStyle> _safetyStyles = {
  TradeSafety.safe: _SafetyStyle(
    color: ThemeV2.success,
    icon: Icons.check_circle_rounded,
    label: 'SAFE TO TRADE',
    description: 'Calm, stable session — a good window for a planned trade.',
  ),
  TradeSafety.caution: _SafetyStyle(
    color: ThemeV2.warning,
    icon: Icons.error_outline_rounded,
    label: 'USE CAUTION',
    description: 'Some volatility possible — a Limit Order is safer here.',
  ),
  TradeSafety.risky: _SafetyStyle(
    color: ThemeV2.loss,
    icon: Icons.bolt_rounded,
    label: 'HIGH RISK — WAIT',
    description: 'Wide spreads and sharp swings — consider waiting it out.',
  ),
  TradeSafety.closed: _SafetyStyle(
    color: ThemeV2.textSecondary,
    icon: Icons.nights_stay_rounded,
    label: 'MARKET CLOSED',
    description: 'No live trading right now — nothing to time.',
  ),
};

class BuyTimingWidget extends StatelessWidget {
  final MarketWindow window;
  const BuyTimingWidget({super.key, required this.window});

  @override
  Widget build(BuildContext context) {
    final safety = window.tradeSafety;
    final style = _safetyStyles[safety]!;

    return Container(
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/market-clock/period/${window.id}'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Text('BUY TIMING', style: FomoShieldTheme.cardTitle()),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: ThemeV2.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: style.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style.icon, color: style.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style.label,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: style.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            style.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ThemeV2.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SafetyBar(current: safety),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Traffic-light style bar: Risky — Caution — Safe. The segment matching
/// the current [TradeSafety] is highlighted; the rest are dimmed. When the
/// market is closed, all three dim equally (there's no "position" to show).
class _SafetyBar extends StatelessWidget {
  final TradeSafety current;
  const _SafetyBar({required this.current});

  @override
  Widget build(BuildContext context) {
    const segments = [
      (TradeSafety.risky, ThemeV2.loss),
      (TradeSafety.caution, ThemeV2.warning),
      (TradeSafety.safe, ThemeV2.success),
    ];

    return Row(
      children: [
        for (int i = 0; i < segments.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: segments[i].$1 == current
                    ? segments[i].$2
                    : segments[i].$2.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
