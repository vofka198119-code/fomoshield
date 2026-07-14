// ---------------------------------------------------------------------------
// BadgeWidget — Reusable pill badge (Design Bible Part 7 — .badge)
// ---------------------------------------------------------------------------
// Pill-форма с border-radius 999px, цвета для фаз рынка:
//   bull / bear / sideways / crash
// Также используется для бейджей событий и скора.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import 'guardian/guardian_data.dart';

/// Pill badge with market phase colors.
///
/// ```dart
/// BadgeWidget(text: 'BULL', state: GuardianState.bull)
/// BadgeWidget(text: 'EVENT', color: FomoShieldTheme.primary)
/// ```
class BadgeWidget extends StatelessWidget {
  /// Display text (e.g. 'BULL', 'CRASH', '+2 more').
  final String text;

  /// Background color. If null, uses [FomoShieldTheme] phase color.
  final Color? color;

  /// Text color. Defaults to [color] or phase color.
  final Color? textColor;

  /// Market state for automatic color selection.
  final GuardianState? state;

  const BadgeWidget({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.state,
  });

  Color _resolveColor() {
    if (color != null) return color!;
    if (state != null) {
      return switch (state!) {
        GuardianState.bull => FomoShieldTheme.bull,
        GuardianState.bear => FomoShieldTheme.bear,
        GuardianState.sideways => FomoShieldTheme.sideways,
        GuardianState.crash => FomoShieldTheme.crash,
        GuardianState.volatility => FomoShieldTheme.volatility,
        GuardianState.blackSwan => FomoShieldTheme.blackSwan,
        GuardianState.recovery => FomoShieldTheme.recovery,
        GuardianState.hype => FomoShieldTheme.bull,
        GuardianState.speculation => FomoShieldTheme.volatility,
      };
    }
    return FomoShieldTheme.textLight;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: bgColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: FomoShieldTheme.fsCaption,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textColor ?? bgColor,
        ),
      ),
    );
  }
}
