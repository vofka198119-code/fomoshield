import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';
import 'themed_border.dart';

// ---------------------------------------------------------------------------
// Themed "Add Widgets" button — the canonical treatment for every screen's
// widget-picker CTA (Home, Market Clock, Portfolio, Stress Test main +
// Portfolio Balance detail, Company Detail). Was six near-identical
// hand-rolled TextButton.icon blocks that had started to drift; unified
// 2026-08-25.
//
// Standard theme: unchanged flat TextButton.icon (accentPrimary outline,
// no fill) — byte-for-byte the pre-existing look.
// Luxury Gold: rebuilt as a "window"-style pill — gradient ring border
// (themedBorder, same as every widget's own card border) + radial
// windowGradient fill (same as every widget's inner windows) + flat
// cream (textHeader) icon/label instead of gold, so it reads as a real
// button rather than plain accent-colored text.
// ---------------------------------------------------------------------------

Widget themedAddWidgetsButton(
  BuildContext context,
  AppPalette palette, {
  required String label,
  required VoidCallback onTap,
}) {
  if (palette.windowGradient == null) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.add_rounded, color: palette.accentPrimary, size: 20),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: palette.accentPrimary,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: palette.accentPrimary, width: 0.5),
        ),
      ),
    );
  }
  final radius = BorderRadius.circular(30);
  return themedBorder(
    palette: palette,
    borderRadius: radius,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: palette.windowGradient,
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: palette.textHeader, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textHeader,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
