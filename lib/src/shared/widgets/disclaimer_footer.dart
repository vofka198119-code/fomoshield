// ---------------------------------------------------------------------------
// Disclaimer Footer
// ---------------------------------------------------------------------------
// Shows a small legal disclaimer at the bottom of main screens.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class DisclaimerFooter extends StatelessWidget {
  const DisclaimerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Text(
        'Disclaimer: F.O.M.O. Shield is for educational and entertainment '
        'purposes only. We are not registered investment advisors. All trading '
        'decisions are solely your responsibility. Past performance does not '
        'guarantee future results.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: AppTheme.textDim.withValues(alpha: 0.5),
          height: 1.4,
        ),
      ),
    );
  }
}
