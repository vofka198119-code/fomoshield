import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// Market Closed Dialog — shown when a Market order is attempted with
// Extended Hours off and the real exchange isn't open. Offers a one-tap
// switch to a Limit order instead of just blocking the user.
// ---------------------------------------------------------------------------

/// Returns true if the user tapped "Place Limit Order Instead".
Future<bool> showMarketClosedDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ThemeV2.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: ThemeV2.primary, size: 22),
          const SizedBox(width: 10),
          Text(
            'Market Closed',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
        ],
      ),
      content: Text(
        'Sorry, the market is currently closed, so Market orders can\'t be '
        'filled right now.\n\n'
        'You can still place a Limit order — it will wait and execute once '
        'the market reopens. Or turn on Extended Hours to trade around the '
        'clock.',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: ThemeV2.textSecondary,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            'OK',
            style: GoogleFonts.inter(color: ThemeV2.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            'Place Limit Order Instead',
            style: GoogleFonts.inter(
              color: ThemeV2.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
