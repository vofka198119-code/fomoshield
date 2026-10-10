import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/overlay/app_banner.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import 'send_invite_sheet.dart';

// ---------------------------------------------------------------------------
// Candidates lane — the people side of the exchange, lifted out of the old
// EmployeeMarketplaceScreen when the two halves were merged into one screen
// (2026-10-10: "ты увел в две разные стороны то что должно быть одно целое").
//
// [fundId] is the fund doing the hiring, and it is what turns browsing into
// hiring: with it, the lane drops that fund's own roster and offers Invite on
// every card; without it -- an employee looking at who else is out there --
// it is a plain list. Nobody is hidden from anyone either way; only the
// ability to act changes.
// ---------------------------------------------------------------------------

class CandidatesLane extends ConsumerWidget {
  final AppPalette palette;
  final String? fundId;

  const CandidatesLane({super.key, required this.palette, this.fundId});

  Future<void> _openInvite(
    BuildContext context,
    WidgetRef ref,
    EmployeeProfile profile,
  ) async {
    final id = fundId;
    if (id == null) return;
    final fund = ref.read(fundDetailProvider(id)).valueOrNull;
    final sent = await showSendInviteSheet(
      context: context,
      ref: ref,
      fundId: id,
      profile: profile,
      palette: palette,
      initialMessage: fund?.lastInviteMessage,
    );
    if (sent == true && context.mounted) {
      ref.invalidate(employeeMarketplaceProvider(id));
      showAppBanner(
        AppLocalizations.of(context)!.etfSendInviteSuccessSnackbar,
        tone: AppBannerTone.success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final candidatesAsync = ref.watch(employeeMarketplaceProvider(fundId));

    return RefreshIndicator(
      color: palette.accentPrimary,
      onRefresh: () async =>
          ref.invalidate(employeeMarketplaceProvider(fundId)),
      child: candidatesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: palette.accentPrimary),
        ),
        error: (_, _) => _note(l10n.etfMarketplaceErrorMessage),
        data: (profiles) {
          if (profiles.isEmpty) return _note(l10n.etfMarketplaceEmpty);
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: profiles.length,
            itemBuilder: (context, i) =>
                _candidate(context, ref, l10n, profiles[i]),
          );
        },
      ),
    );
  }

  Widget _candidate(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    EmployeeProfile profile,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: palette.accentPrimary.withValues(alpha: 0.2),
              child: Text(
                profile.nickname.isNotEmpty
                    ? profile.nickname[0].toUpperCase()
                    : '?',
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
                children: [
                  Text(
                    profile.nickname,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (profile.bio?.isNotEmpty ?? false)
                        ? profile.bio!
                        : l10n.etfMarketplaceBioFallback,
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
            if (fundId != null) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _openInvite(context, ref, profile),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: palette.accentPrimary),
                ),
                child: Text(
                  l10n.etfMarketplaceInviteButton,
                  style: GoogleFonts.inter(
                    color: palette.accentPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _note(String text) => ListView(
    padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
    children: [
      Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          height: 1.4,
          color: palette.textBody,
        ),
      ),
    ],
  );
}
