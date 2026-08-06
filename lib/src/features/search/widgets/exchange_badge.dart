import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/services/finnhub_service.dart' show isEtfSecurityType;

// ---------------------------------------------------------------------------
// Exchange & Type Badge
// ---------------------------------------------------------------------------

class ExchangeBadge extends StatelessWidget {
  final String symbol;
  final String type;

  const ExchangeBadge({super.key, required this.symbol, required this.type});

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
