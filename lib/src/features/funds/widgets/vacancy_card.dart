import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_vacancy.dart';
import '../../../shared/widgets/dark_card_chip.dart';
import '../fund_labels.dart' show roleLabelFor, treasurerBudgetMoney;

// ---------------------------------------------------------------------------
// Vacancy Card — one advert, either on the exchange board (where it carries
// its fund and a candidate is comparing funds) or on a head's own list
// (where the fund is obvious and only the advert matters).
//
// Borrows the accent-ring avatar and the card frame from
// succession_offer_card.dart rather than inventing a third look for a row in
// a list, and the ticker pill is DarkCardChip, the shared one.
// ---------------------------------------------------------------------------

class VacancyCard extends StatelessWidget {
  final FundVacancy vacancy;
  final AppPalette palette;

  /// The board shows the fund; a head looking at their own adverts does not
  /// need to be told which fund they are in.
  final bool showFund;

  /// A head's own card gets "Withdraw"; the board's card does not.
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const VacancyCard({
    super.key,
    required this.vacancy,
    required this.palette,
    this.showFund = true,
    this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final v = vacancy;

    return InkWell(
      borderRadius: FomoShieldTheme.cardRadius,
      onTap: onTap,
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: palette.accentPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
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
                        roleLabelFor(l10n, v.role),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: palette.textHeader,
                        ),
                      ),
                      if (showFund && v.fundName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          v.fundName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: palette.textBody,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showFund && v.fundTicker != null)
                  DarkCardChip(palette: palette, label: v.fundTicker!),
                if (!v.isOpen) _statusPill(l10n),
              ],
            ),
            if ((v.pitch ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                v.pitch!,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.35,
                  color: palette.textBody,
                ),
              ),
            ],
            const SizedBox(height: 10),
            // The three facts a candidate weighs: how big the fund is, how
            // crowded the team already is, and what the advert promises.
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                if (showFund && v.fundCash != null)
                  _fact(Icons.savings_outlined, formatUsd(v.fundCash!)),
                if (showFund && v.fundTeamSize != null)
                  _fact(
                    Icons.groups_outlined,
                    l10n.etfVacancyCardTeamSize(v.fundTeamSize!, 5),
                  ),
                if (showFund && v.fundHeadNickname != null)
                  _fact(
                    Icons.person_outline_rounded,
                    l10n.etfVacancyCardHead(v.fundHeadNickname!),
                  ),
                if (v.offeredLimitAmount != null && v.offeredLimitAmount! > 0)
                  _fact(
                    Icons.bolt_rounded,
                    l10n.etfVacancyCardBudget(
                      treasurerBudgetMoney(v.offeredLimitAmount!),
                    ),
                    accent: true,
                  ),
              ],
            ),
            if (onClose != null && v.isOpen) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onClose,
                  child: Text(
                    l10n.etfVacancyCloseButton,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.loss,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill(AppLocalizations l10n) {
    final label = vacancy.status == 'filled'
        ? l10n.etfVacancyStatusFilled
        : l10n.etfVacancyStatusClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: palette.textBody.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: palette.textBody,
        ),
      ),
    );
  }

  Widget _fact(IconData icon, String text, {bool accent = false}) {
    final color = accent ? palette.accentPrimary : palette.textBody;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: accent ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
