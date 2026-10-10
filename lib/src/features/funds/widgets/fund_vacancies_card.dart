import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund_vacancy.dart';
import '../providers/employee_providers.dart';
import '../fund_labels.dart' show roleLabelFor;

// ---------------------------------------------------------------------------
// Fund Vacancies Card — what this fund is advertising, sitting under the
// roster on the team screen because hiring has two halves and they belong
// together: who is already here, and who is still wanted.
//
// Built to FundTeamCard's own shape rather than a new one — card, uppercase
// title with its action on the same row, divider, then rows. The first
// version put the title loose on the background beside that card and looked
// unfinished next to it; he said so, and he was right.
//
// Head-only. An employee reading the roster has no say in the adverts.
// ---------------------------------------------------------------------------

class FundVacanciesCard extends ConsumerWidget {
  final String fundId;
  final AppPalette palette;

  const FundVacanciesCard({
    super.key,
    required this.fundId,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vacanciesAsync = ref.watch(fundVacanciesProvider(fundId));

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfVacancyFundSectionTitle.toUpperCase(),
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 4),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 12),
          vacanciesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _note(l10n.etfVacancyErrorGeneric),
            data: (vacancies) {
              if (vacancies.isEmpty) {
                return _note(l10n.etfVacancyFundSectionEmpty);
              }
              return Column(
                children: [
                  for (var i = 0; i < vacancies.length; i++) ...[
                    if (i > 0) ...[
                      const SizedBox(height: 14),
                      themedDivider(palette, indent: 0, endIndent: 0),
                      const SizedBox(height: 14),
                    ],
                    _vacancyRow(context, l10n, vacancies[i]),
                  ],
                ],
              );
            },
          ),
          // Room between the last advert's own button and the card's: pressed
          // together they read as a pair of choices about the same advert.
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: brandCtaButton(
              palette: palette,
              label: l10n.etfVacancyPostTitle,
              onTap: () => context.push('/funds/$fundId/post-vacancy'),
            ),
          ),
        ],
      ),
    );
  }

  /// One advert as he asked for it (2026-10-10): what state it is in, in
  /// colour; what the job is; and one wide way in. The pitch is deliberately
  /// NOT here -- it belongs on the advert's own screen, and in a list it only
  /// made two rows run together.
  Widget _vacancyRow(
    BuildContext context,
    AppLocalizations l10n,
    FundVacancy v,
  ) {
    final active = v.isOpen;
    final statusColor = active ? ThemeV2.success : ThemeV2.loss;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              active ? Icons.circle : Icons.pause_circle_filled_rounded,
              size: active ? 9 : 14,
              color: statusColor,
            ),
            const SizedBox(width: 7),
            Text(
              active
                  ? l10n.etfVacancyStatusActive
                  : l10n.etfVacancyStatusPaused,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          roleLabelFor(l10n, v.role),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: palette.textHeader,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: brandCtaButton(
            palette: palette,
            label: l10n.etfVacancyEditButton,
            onTap: () => context.push('/funds/$fundId/vacancies/${v.id}'),
            fontSize: 13,
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _note(String text) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 12.5,
      height: 1.35,
      color: palette.textBody,
    ),
  );
}
