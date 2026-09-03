import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/themed_border.dart';

// ---------------------------------------------------------------------------
// More/Less Pill — the expand/collapse toggle used at the bottom of preview
// lists across Home/Portfolio/Stress Test widgets (Holdings, Trade History,
// allocation legends, Market Timeline, etc.). Bundles the themed pill fill
// ([moreLessPillStyle]) with the same [themedBorder] ring every other
// widget/window in the app gets — previously missing here, each call site
// hand-rolling its own Container instead.
// ---------------------------------------------------------------------------

class MoreLessPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final AppPalette palette;
  final EdgeInsetsGeometry margin;

  const MoreLessPill({
    super.key,
    required this.label,
    required this.onTap,
    required this.palette,
    this.margin = const EdgeInsets.fromLTRB(16, 6, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    final (gradient, background, textColor) = moreLessPillStyle(palette);
    final radius = BorderRadius.circular(10);
    return GestureDetector(
      onTap: onTap,
      child: themedBorder(
        palette: palette,
        borderRadius: radius,
        margin: margin,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            color: background,
            borderRadius: radius,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
