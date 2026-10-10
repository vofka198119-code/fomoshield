import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../widgets/vacancy_card.dart';

// ---------------------------------------------------------------------------
// Vacancy Board — the employee exchange, replacing the ComingSoonScreen that
// used to sit behind the hub's "Вакансии" shortcut (found 2026-10-10: the
// whole candidate-facing half of hiring was a stub, and the one action a
// candidate needs -- putting their CV on the board -- was a switch buried in
// the CV form, where nobody would look for it).
//
// Two things, in the order they matter to whoever opened this screen:
// am I visible to the funds, and who is hiring. The first is a card, not a
// setting: it says outright what state you are in and offers the one button
// that changes it. It writes the same `availableForHire` field the CV form
// toggles -- one flag, two doors.
//
// Open to everyone, head or not (his requirement). A head sees the same
// board; their own fund's adverts are managed from the fund's team screen,
// where the rest of hiring already lives.
// ---------------------------------------------------------------------------

class VacancyBoardScreen extends ConsumerStatefulWidget {
  const VacancyBoardScreen({super.key});

  @override
  ConsumerState<VacancyBoardScreen> createState() => _VacancyBoardScreenState();
}

class _VacancyBoardScreenState extends ConsumerState<VacancyBoardScreen> {
  bool _togglingListing = false;

  /// Flips `availableForHire` through the same endpoint the CV form uses, so
  /// there is one writer and no second meaning of "listed". The nickname is
  /// required by the endpoint and is the account's own, already set before
  /// any screen is reachable (Migration 017).
  Future<void> _toggleListing(EmployeeProfile profile) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _togglingListing = true);
    final next = !profile.availableForHire;
    try {
      await ref
          .read(employeeApiServiceProvider)
          .saveMyProfile(
            nickname: profile.nickname,
            bio: profile.bio,
            language: profile.language,
            desiredRole: profile.desiredRole,
            availableForHire: next,
          );
      ref.invalidate(myEmployeeProfileProvider);
      showAppBanner(
        next
            ? l10n.etfVacancyPublishedMessage
            : l10n.etfVacancyWithdrawnMessage,
        tone: next ? AppBannerTone.success : AppBannerTone.info,
      );
    } catch (_) {
      showAppBanner(l10n.etfVacancyProfileError, tone: AppBannerTone.failure);
    } finally {
      if (mounted) setState(() => _togglingListing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final boardAsync = ref.watch(vacancyBoardProvider);
    final profileAsync = ref.watch(myEmployeeProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfVacancyBoardTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: palette.accentPrimary,
          onRefresh: () async {
            ref.invalidate(vacancyBoardProvider);
            ref.invalidate(myEmployeeProfileProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _myListingCard(palette, l10n, profileAsync.valueOrNull),
              const SizedBox(height: 20),
              Text(
                l10n.etfVacancyOpenSectionTitle,
                style: FomoShieldTheme.cardTitle().copyWith(
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 10),
              ...boardAsync.when(
                loading: () => [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                ],
                error: (_, _) => [_note(palette, l10n.etfVacancyErrorGeneric)],
                data: (vacancies) {
                  if (vacancies.isEmpty) {
                    return [_note(palette, l10n.etfVacancyBoardEmpty)];
                  }
                  return [
                    for (final vacancy in vacancies) ...[
                      VacancyCard(
                        vacancy: vacancy,
                        palette: palette,
                        onTap: () => context.push('/funds/${vacancy.fundId}'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Says which of the three states you are in -- no CV, listed, hidden --
  /// and offers exactly the action that state allows.
  Widget _myListingCard(
    AppPalette palette,
    AppLocalizations l10n,
    EmployeeProfile? profile,
  ) {
    final listed = profile?.availableForHire ?? false;
    final String body;
    final String buttonLabel;
    final VoidCallback? onPressed;
    if (profile == null) {
      body = l10n.etfVacancyMyProfileNone;
      buttonLabel = l10n.etfVacancyFillProfileButton;
      onPressed = () => context.push('/funds/employee-profile');
    } else {
      body = listed
          ? l10n.etfVacancyMyProfileListed
          : l10n.etfVacancyMyProfileHidden;
      buttonLabel = listed
          ? l10n.etfVacancyWithdrawButton
          : l10n.etfVacancyPublishButton;
      onPressed = _togglingListing ? null : () => _toggleListing(profile);
    }

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                listed
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 18,
                color: listed ? ThemeV2.success : palette.textBody,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.etfVacancyMyProfileTitle,
                style: FomoShieldTheme.cardTitle().copyWith(
                  color: palette.textHeader,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.35,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: ThemeV2.buttonHeight,
            child: _button(palette, buttonLabel, onPressed),
          ),
        ],
      ),
    );
  }

  Widget _button(AppPalette palette, String label, VoidCallback? onPressed) {
    final radius = ThemeV2.borderRadiusMedium;
    final contentColor = themedDarkCtaContentColor(palette);
    return Material(
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
          onTap: onPressed,
          child: Center(
            child: _togglingListing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: contentColor,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: contentColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _note(AppPalette palette, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 13,
        height: 1.4,
        color: palette.textBody,
      ),
    ),
  );
}
