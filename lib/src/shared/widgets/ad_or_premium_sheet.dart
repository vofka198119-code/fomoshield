import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../features/monetization/monetization_modal.dart';

// ---------------------------------------------------------------------------
// Generic "watch an ad or go Premium" bottom sheet — the shared UI shell
// behind every ad-gate in the app (Company Encyclopedia unlock, Stress
// Test/Portfolio order gate, ...). Callers own the counter/eligibility
// logic and only ask this sheet to present the choice.
// ---------------------------------------------------------------------------

/// Returns true if the user chose "watch ad(s)", false/null otherwise
/// (dismissed, or chose "Go Premium" — that flow has its own modal and
/// doesn't unlock anything on its own since the upgrade itself is a stub).
Future<bool?> showAdOrPremiumSheet(
  BuildContext context,
  WidgetRef ref, {
  required AppPalette palette,
  required IconData icon,
  required String title,
  required String body,
  required String watchAdLabel,
  required String goPremiumLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Icon(icon, color: palette.accentPrimary, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: palette.textBody,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  watchAdLabel,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx, false);
                  // "Watch Ad" is already this sheet's own button above —
                  // voluntary skips the modal's redundant Watch Ad option.
                  showMonetizationModal(
                    context,
                    ref,
                    trigger: MonetizationTrigger.voluntary,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.accentPrimary,
                  side: BorderSide(color: palette.accentPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  goPremiumLabel,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
