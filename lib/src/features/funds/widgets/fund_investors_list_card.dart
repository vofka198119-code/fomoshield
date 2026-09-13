import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/more_less_pill.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund_investor.dart';

// ---------------------------------------------------------------------------
// FundInvestorsListCard — Investors screen's second widget (2026-09-13
// ask), styled like FundManagementHoldingsCard (title/divider/rows, same
// CardFrame shell and themedRowDivider between rows) but with "+20 forever"
// pagination instead of that widget's/Portfolio's binary More(N)/Less
// toggle -- explicitly a different pattern here since the investor count
// can grow much larger than any of those lists. No company logo (there
// isn't one for a person) -- the identity avatar is the exact
// nickname-initial CircleAvatar recipe from employee_marketplace_screen.dart
// instead. Server already sorts by invested descending.
// ---------------------------------------------------------------------------
class FundInvestorsListCard extends StatefulWidget {
  final List<FundInvestor> investors;
  final AppPalette palette;

  const FundInvestorsListCard({
    super.key,
    required this.investors,
    required this.palette,
  });

  @override
  State<FundInvestorsListCard> createState() => _FundInvestorsListCardState();
}

class _FundInvestorsListCardState extends State<FundInvestorsListCard> {
  static const int _pageSize = 20;
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final investors = widget.investors;
    final display = investors.take(_visibleCount).toList();
    final remaining = investors.length - display.length;

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: themedHeaderText(
                l10n.etfInvestorsListTitle,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
            ),
          ),
          if (investors.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.etfInvestorsListEmptyText,
                style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
              ),
            )
          else ...[
            themedDivider(palette),
            for (int i = 0; i < display.length; i++)
              _InvestorRow(
                investor: display[i],
                showDivider: i < display.length - 1,
                palette: palette,
              ),
            if (remaining > 0)
              MoreLessPill(
                label: l10n.commonMoreCount(
                  remaining < _pageSize ? remaining : _pageSize,
                ),
                onTap: () => setState(() => _visibleCount += _pageSize),
                palette: palette,
              )
            else
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _InvestorRow extends StatelessWidget {
  final FundInvestor investor;
  final bool showDivider;
  final AppPalette palette;

  const _InvestorRow({
    required this.investor,
    required this.showDivider,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nickname = investor.nickname ?? '—';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: palette.accentPrimary.withValues(alpha: 0.2),
                child: Text(
                  nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: palette.accentPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: palette.textHeader,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.fundUnitsCount(
                        investor.unitsHeld.toStringAsFixed(4),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: palette.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  themedPriceText(
                    formatUsd(investor.invested),
                    palette,
                    interNums(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${investor.percentOfFund.toStringAsFixed(1)}%',
                    style: interNums(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) themedRowDivider(palette),
      ],
    );
  }
}
