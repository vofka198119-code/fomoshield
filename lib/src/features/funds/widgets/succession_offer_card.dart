import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_succession_offer.dart';

// ---------------------------------------------------------------------------
// Succession Offer Card — the row My Invitations shows above the ordinary
// invite envelopes (Phase B). Visually separated from them on purpose: an
// invite is a job offer, this is "the head vanished, the fund may be
// yours" — same list, different weight. Borrows proposal_card.dart's own
// accent-ring avatar + alpha-0.12 status pill rather than inventing a
// third badge look.
// ---------------------------------------------------------------------------

class SuccessionOfferCard extends StatelessWidget {
  final FundSuccessionOffer offer;
  final AppPalette palette;
  final VoidCallback onTap;

  const SuccessionOfferCard({
    super.key,
    required this.offer,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: FomoShieldTheme.cardRadius,
      onTap: onTap,
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: palette.accentPrimary, width: 1.5),
              ),
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 20,
                color: palette.accentPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.etfSuccessionCardSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: palette.textBody,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _pill(l10n.etfSuccessionDaysLeft(offer.daysLeft)),
                      if (offer.alreadyAccepted)
                        _pill(l10n.etfSuccessionAppliedPill),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: palette.accentPrimary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: palette.accentPrimary,
      ),
    ),
  );
}
