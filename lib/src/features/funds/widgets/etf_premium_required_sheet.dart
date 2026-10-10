import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_sheet.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../monetization/monetization_modal.dart';

// ---------------------------------------------------------------------------
// ETF Premium-Required Sheet — shown AFTER the onboarding tutorial (not
// before it, per the author), if the user still isn't Premium/admin once
// they reach the point of actually creating a fund. Deliberately NOT the
// generic monetization_modal.dart sheet — that one's built around the
// search-limit "watch an ad for +15 searches" reward, which makes no sense
// for permanently unlocking fund creation.
//
// "Subscribe" used to be a stub showing a "Premium — coming soon!" snackbar,
// written before any purchase flow existed. Real Play Billing has been live
// on master since 2026-09-20, so on the 2026-10-03 merge it was pointed at
// the real paywall instead (MonetizationTrigger.voluntary — the generic
// pitch, since no limit was actually hit here).
// ---------------------------------------------------------------------------

Future<void> showEtfPremiumRequiredSheet(BuildContext context, WidgetRef ref) {
  final palette = resolveAppPalette(ref.read(themeVariantProvider));
  return showAppSheet<void>(
    context: context,
    palette: palette,
    builder: (_) => _EtfPremiumRequiredSheet(palette: palette, parentRef: ref),
  );
}

class _EtfPremiumRequiredSheet extends StatelessWidget {
  final AppPalette palette;

  /// The ref from the opening call site — this sheet is a plain
  /// StatelessWidget, and the Upgrade button needs one to reach the real
  /// paywall.
  final WidgetRef parentRef;

  const _EtfPremiumRequiredSheet({
    required this.palette,
    required this.parentRef,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // The card, its corners and every inset are the shell's now
    // (app_sheet.dart). The grab handle went with them: no other sheet in
    // this module has one, and the panel closes on a tap outside either way.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: palette.accentPrimary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: palette.accentPrimary,
            size: 32,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.etfPremiumRequiredTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.etfPremiumRequiredDescription,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: palette.textHeader,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _sheetButton(
          palette: palette,
          label: l10n.monetizationModalUpgradeButton,
          onTap: () {
            Navigator.pop(context);
            showMonetizationModal(
              context,
              parentRef,
              trigger: MonetizationTrigger.voluntary,
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: palette.textBody),
            child: Text(
              l10n.verdictBackToHome,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sheetButton({
    required AppPalette palette,
    required String label,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(ThemeV2.buttonRadius);
    return SizedBox(
      width: double.infinity,
      height: ThemeV2.buttonHeight,
      child: Material(
        type: MaterialType.transparency,
        child: themedDarkCtaButtonShell(
          palette: palette,
          borderRadius: radius,
          standardDecoration: BoxDecoration(
            color: ThemeV2.primary,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themedDarkCtaContentColor(palette),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
