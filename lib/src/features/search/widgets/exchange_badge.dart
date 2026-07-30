import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// Exchange & Type Badge
// ---------------------------------------------------------------------------

class ExchangeBadge extends StatelessWidget {
  final String symbol;
  final String type;

  const ExchangeBadge({super.key, required this.symbol, required this.type});

  @override
  Widget build(BuildContext context) {
    // Finnhub/our local index label ETFs "ETP" (Exchange Traded Product),
    // not "ETF" — checking only 'ETF' silently hid the badge for almost
    // every real fund (confirmed live 2026-07-29: SPY/QQQ/VOO all "ETP").
    final isEtf = type.toUpperCase() == 'ETF' || type.toUpperCase() == 'ETP';
    final exchange = symbol.contains('.')
        ? symbol.split('.').last.toUpperCase()
        : 'US';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _badge(
          exchange,
          exchange == 'US'
              ? ThemeV2.primary
              : exchange == 'L'
              ? const Color(0xFF9B59B6)
              : ThemeV2.textSecondary,
        ),
        if (isEtf) ...[
          const SizedBox(width: 4),
          _badge('ETF', ThemeV2.warning),
        ],
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
