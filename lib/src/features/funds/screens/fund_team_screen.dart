import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_team_card.dart';
import '../widgets/vacancy_card.dart';

// ---------------------------------------------------------------------------
// Fund Team — FundTeamCard's own screen (2026-09-11), split out of
// FundManagementScreen's inline body so the "Сотрудники" shortcut in that
// screen's own circle-shortcut row has a real destination, mirroring
// EmployeeHubScreen's own hub-plus-shortcuts pattern.
// ---------------------------------------------------------------------------

class FundTeamScreen extends ConsumerWidget {
  final String fundId;

  const FundTeamScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));
    final currentUserId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfEmployeeHubTeamRow,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: fundAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (fund) {
            final isHead = fund.headUserId == currentUserId;
            return RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async => ref.invalidate(fundTeamProvider(fundId)),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  FundTeamCard(
                    fundId: fund.id,
                    isHead: isHead,
                    palette: palette,
                    headNickname: fund.headNickname,
                    headUserId: fund.headUserId,
                  ),
                  // Hiring has two halves and they belong on one screen: who
                  // is already here, and what the fund is advertising for.
                  // Head-only -- an employee viewing the roster has no say
                  // in the adverts (migration 036).
                  if (isHead) ...[
                    const SizedBox(height: 24),
                    _vacancySection(context, ref, fund.id, palette, l10n),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _vacancySection(
    BuildContext context,
    WidgetRef ref,
    String fundId,
    AppPalette palette,
    AppLocalizations l10n,
  ) {
    final vacanciesAsync = ref.watch(fundVacanciesProvider(fundId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.etfVacancyFundSectionTitle,
                style: FomoShieldTheme.cardTitle().copyWith(
                  color: palette.textHeader,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/funds/$fundId/post-vacancy'),
              icon: Icon(
                Icons.add_rounded,
                size: 18,
                color: palette.accentPrimary,
              ),
              label: Text(
                l10n.etfVacancyPostButton,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: palette.accentPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...vacanciesAsync.when(
          loading: () => [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: palette.accentPrimary),
              ),
            ),
          ],
          error: (_, _) => [
            Text(
              l10n.etfVacancyErrorGeneric,
              style: GoogleFonts.inter(fontSize: 12.5, color: palette.textBody),
            ),
          ],
          data: (vacancies) {
            if (vacancies.isEmpty) {
              return [
                Text(
                  l10n.etfVacancyFundSectionEmpty,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.35,
                    color: palette.textBody,
                  ),
                ),
              ];
            }
            return [
              for (final vacancy in vacancies) ...[
                VacancyCard(
                  vacancy: vacancy,
                  palette: palette,
                  showFund: false,
                  onClose: vacancy.isOpen
                      ? () => _close(ref, fundId, vacancy.id, l10n)
                      : null,
                ),
                const SizedBox(height: 10),
              ],
            ];
          },
        ),
      ],
    );
  }

  Future<void> _close(
    WidgetRef ref,
    String fundId,
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
}
