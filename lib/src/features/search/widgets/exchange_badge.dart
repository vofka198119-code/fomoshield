import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/services/finnhub_service.dart' show isEtfSecurityType;

// ---------------------------------------------------------------------------
// Exchange & Type Badge
// ---------------------------------------------------------------------------

class ExchangeBadge extends StatelessWidget {
  final String symbol;
  final String type;

  /// Needed for the fallback-exchange badge only. The US/London/ETF badges
  /// are saturated colors that read on any backdrop; the fallback used
  /// ThemeV2.textSecondary, which is near-black and disappeared completely
  /// on the dark themes (Black & White's lower gradient, Graphite, Luxury
  /// Gold) — Search is one of the two screens where that was reported.
  final AppPalette palette;

  const ExchangeBadge({
    super.key,
    required this.symbol,
    required this.type,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isEtf = isEtfSecurityType(type);
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
              : palette.textBody,
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
