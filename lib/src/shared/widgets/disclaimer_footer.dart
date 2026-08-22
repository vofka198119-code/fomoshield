// ---------------------------------------------------------------------------
// Disclaimer Footer
// ---------------------------------------------------------------------------
// Shows a small legal disclaimer at the bottom of main screens.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../l10n/gen/app_localizations.dart';

class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Text(
        AppLocalizations.of(context)!.disclaimerFooter,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: ThemeV2.textSecondary.withValues(alpha: 0.5),
          height: 1.4,
        ),
      ),
    );
  }
}

