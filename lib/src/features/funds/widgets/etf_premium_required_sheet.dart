import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// ETF Premium-Required Sheet — shown AFTER the onboarding tutorial (not
// before it, per the author), if the user still isn't Premium/admin once
// they reach the point of actually creating a fund. Deliberately NOT the
// generic monetization_modal.dart sheet — that one's built around the
// search-limit "watch an ad for +15 searches" reward, which makes no sense
// for permanently unlocking fund creation. "Subscribe" is a stub (no real
// IAP wired up yet, same as monetization_modal.dart's own Premium button —
// see project memory on Play Store IAP being unfinished) until Premium
// purchase is actually implemented.
// ---------------------------------------------------------------------------

Future<void> showEtfPremiumRequiredSheet(BuildContext context, WidgetRef ref) {
  final palette = resolveAppPalette(ref.read(themeVariantProvider));
  return showModalBottomSheet(
    context: context,
    backgroundColor: palette.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) => _EtfPremiumRequiredSheet(palette: palette),
  );
}

class _EtfPremiumRequiredSheet extends StatelessWidget {
  final AppPalette palette;

  const _EtfPremiumRequiredSheet({required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: palette.textBody.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
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
            style: GoogleFonts.inter(fontSize: 14, color: palette.textHeader, height: 1.5),
          ),
          const SizedBox(height: 28),
          _sheetButton(
            palette: palette,
            label: l10n.monetizationModalUpgradeButton,
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.monetizationModalComingSoon),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
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
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
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
          standardDecoration: BoxDecoration(color: ThemeV2.primary, borderRadius: radius),
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
