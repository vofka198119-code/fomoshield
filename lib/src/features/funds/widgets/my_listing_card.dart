import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';

// ---------------------------------------------------------------------------
// My Listing — am I visible on the exchange, and the one button that changes
// it. Above the tabs on the exchange screen, because it is true of you
// whichever side you are looking at.
//
// The answer used to be a switch buried in the CV form, labelled as a
// setting; a user who filled in a CV had no way to tell whether anything had
// happened ("не вижу кнопку разместить вашу анкету", 2026-10-10). It writes
// the same availableForHire that switch does -- one flag, two doors.
// ---------------------------------------------------------------------------

class MyListingCard extends ConsumerStatefulWidget {
  final AppPalette palette;

  const MyListingCard({super.key, required this.palette});

  @override
  ConsumerState<MyListingCard> createState() => _MyListingCardState();
}

class _MyListingCardState extends ConsumerState<MyListingCard> {
  bool _busy = false;

  Future<void> _toggle(EmployeeProfile profile) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
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
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = widget.palette;
    final profile = ref.watch(myEmployeeProfileProvider).valueOrNull;
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
      onPressed = _busy ? null : () => _toggle(profile);
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: brandCtaButton(
              palette: palette,
              label: buttonLabel,
              onTap: onPressed,
              busy: _busy,
            ),
          ),
        ],
      ),
    );
  }
}
