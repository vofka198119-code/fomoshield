// ---------------------------------------------------------------------------
// Disclaimer Footer
// ---------------------------------------------------------------------------
// Shows a small legal disclaimer at the bottom of main screens.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

class DisclaimerFooter extends StatelessWidget {
  /// Optional theme palette — when it sets [AppPalette.disclaimerColor]
  /// (only Black & White does, 2026-09-05), that color replaces the
  /// shared muted-gray treatment below. Null (the default) is a no-op —
  /// every existing call site is unaffected unless it opts in.
  final AppPalette? palette;

  const DisclaimerFooter({super.key, this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Text(
        AppLocalizations.of(context)!.disclaimerFooter,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 10,
          // Decision (2026-08-23, Luxury Gold pilot): this exact color —
          // ThemeV2.textSecondary at 50% alpha — reads fine as-is against
          // the new dark backdrop on Home and is the reference/canonical
          // treatment for fine-print/disclaimer text under Luxury Gold
          // too. Left un-themed on purpose rather than wiring a theme-
          // specific color — don't "fix" it further unless it actually
          // looks bad. Black & White's white cards made it read too faint
          // there (2026-09-05), hence [AppPalette.disclaimerColor].
          color: palette?.disclaimerColor ?? ThemeV2.textSecondary.withValues(alpha: 0.5),
          height: 1.4,
        ),
      ),
    );
  }
}

