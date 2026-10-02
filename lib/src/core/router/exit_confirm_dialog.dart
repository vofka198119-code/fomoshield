import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/gen/app_localizations.dart';
import '../theme/theme_v2.dart';

// Guards the system back button at the bottom-nav root.
//
// Back there doesn't close the app — _AppShell routes it to
// moveTaskToBack(), which only minimizes it (see MainActivity.kt). But on
// Xiaomi/HyperOS a minimized app is often evicted from memory soon after,
// so an accidental tap still ends in a cold start that loses where the user
// was (2026-10-02 report: "бывает перезапускается с нуля"). We can't stop
// the OS from reclaiming memory; we can stop the accidental tap.
//
// Styled after the Delete Account dialog in profile_screen.dart — plain
// AlertDialog, Inter, ThemeV2 colors — so it doesn't read as a stranger.

// Repeated back taps land while the dialog is already up; without this the
// second one stacks a duplicate behind the first.
bool _isOpen = false;

Future<bool> confirmExitApp(BuildContext context) async {
  if (_isOpen) return false;
  _isOpen = true;
  try {
    final l10n = AppLocalizations.of(context)!;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.exitAppTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          l10n.exitAppBody,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.exitAppStay,
              style: GoogleFonts.inter(color: ThemeV2.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.exitAppLeave,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    return leave == true;
  } finally {
    _isOpen = false;
  }
}
