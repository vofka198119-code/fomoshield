import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../models/fund_succession_offer.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/invitation_detail_sheet.dart';
import '../widgets/succession_offer_card.dart';
import '../widgets/succession_offer_sheet.dart';
import '../../../core/overlay/app_banner.dart';

// ---------------------------------------------------------------------------
// My Invitations — ETF Fund Emulation, Phase 3. The analyst's own envelope
// list (docs/ETF_FUND_EMULATION.md's "Флоу приглашения"). Deliberately its
// OWN screen backed by GET /invitations/me, not folded into the app's
// existing Notifications feed — that feed is purely local/per-device
// (fed by pushAppNotification calls on THIS device), so it can never
// surface an invite another user's action created. Styled the same way
// (row list, tap → detail) per the phase plan's "structural analog" note,
// just with its own real backend-fetched data.
//
// Also hosts Phase B's fund-succession offers (SuccessionOfferCard), kept
// ABOVE the ordinary envelopes: same "someone is offering you something,
// act before it expires" semantics, but far rarer and far more consequential,
// so it never gets its own mostly-empty screen. An offer failing to load
// must not take the invitations list down with it — the two async values
// are resolved independently, not folded into one combined future.
// ---------------------------------------------------------------------------

class MyInvitationsScreen extends ConsumerWidget {
  const MyInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final invitationsAsync = ref.watch(myInvitationsProvider);
    final offers = ref.watch(mySuccessionOffersProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfInvitationsTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.badge_outlined, color: palette.textHeader),
            tooltip: l10n.etfEmployeeProfileButtonLabel,
            onPressed: () => context.push('/funds/employee-profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: invitationsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfInvitationsErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (invitations) {
            if (invitations.isEmpty && offers.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.etfInvitationsEmpty,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: palette.textBody),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () =>
                            context.push('/funds/employee-profile'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: palette.accentPrimary),
                        ),
                        child: Text(
                          l10n.etfEmployeeProfileButtonLabel,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: palette.accentPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async {
                ref.invalidate(myInvitationsProvider);
                ref.invalidate(mySuccessionOffersProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final offer in offers)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SuccessionOfferCard(
                        offer: offer,
                        palette: palette,
                        onTap: () => _openOffer(context, ref, offer, palette),
                      ),
                    ),
                  for (final invitation in invitations)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _invitationTile(
                        context,
                        ref,
                        invitation,
                        palette,
                        l10n,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tapping a succession offer. Only a fresh acceptance (true) is worth a
  /// snackbar — dismissing the sheet returns null and should stay silent.
  Future<void> _openOffer(
    BuildContext context,
    WidgetRef ref,
    FundSuccessionOffer offer,
    AppPalette palette,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showSuccessionOfferSheet(
      context: context,
      ref: ref,
      offer: offer,
      palette: palette,
    );
    if (result == null) return;
    ref.invalidate(mySuccessionOffersProvider);
    // A deputy accepting inside their own window IS the new head already,
    // so it also changes what the funds list and Home's tile should show.
    if (result == SuccessionAcceptResult.becameHead) {
      ref.invalidate(fundsListProvider);
      ref.invalidate(fundDetailProvider(offer.fundId));
    }
    if (!context.mounted) return;
    showAppBanner(
      result == SuccessionAcceptResult.becameHead
          ? l10n.etfSuccessionBecameHeadSnackbar
          : l10n.etfSuccessionAcceptedSnackbar,
      tone: AppBannerTone.success,
    );
  }

  Widget _invitationTile(
    BuildContext context,
    WidgetRef ref,
    FundInvitation invitation,
    AppPalette palette,
    AppLocalizations l10n,
  ) {
    return InkWell(
      borderRadius: FomoShieldTheme.cardRadius,
      onTap: () async {
        final joined = await showInvitationDetailSheet(
          context: context,
          ref: ref,
          invitation: invitation,
          palette: palette,
        );
        if (joined == null) return;
        ref.invalidate(myInvitationsProvider);
        if (joined) {
          // New team membership -- without this, the fund's own Team
          // screen and this user's employment history kept showing
          // pre-join state until a fresh (non-cached) mount.
          ref.invalidate(fundTeamProvider(invitation.fundId));
          ref.invalidate(myEmploymentHistoryProvider);
        }
        if (!context.mounted) return;
        showAppBanner(
          joined
              ? l10n.etfInvitationAcceptedSnackbar
              : l10n.etfInvitationDeclinedSnackbar,
          tone: AppBannerTone.success,
        );
      },
      child: CardFrame(
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.fundName ?? invitation.fundTicker ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: palette.textHeader,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invitation.message,
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
            if (invitation.fundApproxAum != null) ...[
              const SizedBox(width: 8),
              Text(
                formatUsd(invitation.fundApproxAum!),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
