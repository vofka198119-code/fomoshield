import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../monetization/monetization_modal.dart';

// ---------------------------------------------------------------------------
// Company Encyclopedia paywall — shown to a free-tier user tapping a locked
// article row. Two ways in: watch two short ads (reuses the existing
// CompanyAdOverlay, shown twice back to back — see company_encyclopedia_
// widget.dart's caller), or go Premium (reuses the app's existing
// monetization modal rather than building a second upgrade flow).
// ---------------------------------------------------------------------------

/// Returns true if the user chose "watch ads", false/null otherwise
/// (dismissed, or chose "Go Premium" — that flow has its own modal and
/// doesn't unlock reading on its own since the upgrade itself is a stub).
Future<bool?> showCompanyEncyclopediaPaywallSheet(
  BuildContext context,
  WidgetRef ref,
  AppPalette palette,
) {
  final l10n = AppLocalizations.of(context)!;
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
            Icon(
              Icons.auto_stories_rounded,
              color: palette.accentPrimary,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.companyEncyclopediaPaywallTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.companyEncyclopediaPaywallBody,
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
                  l10n.companyDetailWatchAdButton,
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
                  showMonetizationModal(context, ref);
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
                  l10n.companyEncyclopediaGoPremiumButton,
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
