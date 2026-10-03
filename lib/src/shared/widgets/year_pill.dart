import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/themed_border.dart';

// ---------------------------------------------------------------------------
// YearPill — the small "{year} ▾" chevron pill in a chart card's header,
// opening a year-picker bottom sheet (2026-09-13, first used on the fund
// Investors screen's two flow charts, now shared with the fund balance
// history chart too). Same recipe as fund_management_screen.dart's own
// _chip helper: themedBorder ring + windowGradient fill on themed
// variants, flat accentPrimary@15% tint on Standard.
// ---------------------------------------------------------------------------
class YearPill extends StatelessWidget {
  final int year;
  final VoidCallback onTap;
  final AppPalette palette;

  const YearPill({
    super.key,
    required this.year,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final hasThemedBorder = palette.borderGradient != null;
    return GestureDetector(
      onTap: onTap,
      child: themedBorder(
        palette: palette,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: hasThemedBorder
                ? null
                : palette.accentPrimary.withValues(alpha: 0.15),
            gradient: hasThemedBorder ? palette.windowGradient : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$year',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: palette.accentPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: palette.accentPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
