import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
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
import '../fund_labels.dart' show roleLabelFor, treasurerBudgetMoney;

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

  Future<void> _close(
    WidgetRef ref,
    String vacancyId,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(employeeApiServiceProvider)
          .closeVacancy(fundId, vacancyId);
      ref.invalidate(fundVacanciesProvider(fundId));
      ref.invalidate(vacancyBoardProvider);
      showAppBanner(l10n.etfVacancyClosedMessage, tone: AppBannerTone.info);
    } catch (_) {
      showAppBanner(l10n.etfVacancyErrorGeneric, tone: AppBannerTone.failure);
    }
  }

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
                  for (final vacancy in vacancies)
                    _vacancyRow(ref, l10n, vacancy),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
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

  /// Same two-line shape as FundTeamCard's member row: what it is on top,
  /// the detail under it, the action on the right.
  Widget _vacancyRow(WidgetRef ref, AppLocalizations l10n, FundVacancy v) {
    final detail = <String>[
      if ((v.pitch ?? '').isNotEmpty) v.pitch!.trim(),
      if (v.offeredLimitAmount != null && v.offeredLimitAmount! > 0)
        l10n.etfVacancyCardBudget(treasurerBudgetMoney(v.offeredLimitAmount!)),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleLabelFor(l10n, v.role),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: palette.textBody,
                    ),
                  ),
              ],
            ),
          ),
          if (v.isOpen)
            TextButton(
              onPressed: () => _close(ref, v.id, l10n),
              child: Text(
                l10n.etfVacancyCloseButton,
                style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
              ),
            )
          else
            Text(
              v.status == 'filled'
                  ? l10n.etfVacancyStatusFilled
                  : l10n.etfVacancyStatusClosed,
              style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
            ),
        ],
      ),
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
