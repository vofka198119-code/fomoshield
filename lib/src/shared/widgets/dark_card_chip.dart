import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/themed_border.dart';

// ---------------------------------------------------------------------------
// The small label pill that sits on a dark card — a company's sector, a
// fund's ticker, an employee's position. One widget because there is one
// look, and because the two hand-copied versions had already drifted from
// the original in the way that mattered most (2026-10-09).
//
// The fill is an opaque pale mint, NOT the accent at 15%. On a light card
// those look nearly the same; on this card's dark green the tinted version
// is the card itself, and the accent-green text on accent-green tint is
// unreadable — which is exactly what the fund management panel and the
// employee profile shipped with until it was spotted on the phone. Blending
// the tint over white instead gives a pale box that reads on the dark card,
// and keeps the accent text as the thing the eye lands on.
//
// Under a theme with a borderGradient (Luxury Gold and company) the ring and
// the windowGradient fill take over, same as everywhere else.
// ---------------------------------------------------------------------------

class DarkCardChip extends StatelessWidget {
  final String label;
  final AppPalette palette;

  const DarkCardChip({super.key, required this.label, required this.palette});

  @override
  Widget build(BuildContext context) {
    final hasThemedBorder = palette.borderGradient != null;
    return themedBorder(
      palette: palette,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: hasThemedBorder
              ? null
              : Color.alphaBlend(ThemeV2.primaryBg, Colors.white),
          gradient: hasThemedBorder ? palette.windowGradient : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: palette.accentPrimary,
          ),
        ),
      ),
    );
  }
}
