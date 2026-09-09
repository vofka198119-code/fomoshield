import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund.dart';

// Creation date is real. Employee roster now lives in its own FundTeamCard
// (Phase 3, real fund_team_members data) instead of a stub count here —
// this card only keeps the Creator row, still a stub: showing the head's
// real nickname needs a "get employee_profile by arbitrary userId" lookup
// that doesn't exist yet (the head isn't a fund_team_members row, unlike
// every other employee, whose nickname the roster already joins in).
class FundInfoCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;

  const FundInfoCard({super.key, required this.fund, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final created = DateFormat.yMMMd(locale).format(fund.createdAt.toLocal());

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfFundDetailInfoTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 12),
          _row(l10n.etfFundDetailCreatedLabel, created),
          const SizedBox(height: 8),
          _row(l10n.etfFundDetailCreatorLabel, '—'),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: palette.textHeader,
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
        ),
      ),
    ],
  );
}
