// ---------------------------------------------------------------------------
// Disclaimer Footer
// ---------------------------------------------------------------------------
// Shows a small legal disclaimer at the bottom of main screens.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../l10n/gen/app_localizations.dart';
import 'disclaimer_style.dart';

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
          // Colour comes from resolveDisclaimerColor — see its doc comment
          // for why the old 50%-alpha treatment was replaced 2026-09-26.
          color: resolveDisclaimerColor(palette),
          height: 1.4,
        ),
      ),
    );
  }
}

