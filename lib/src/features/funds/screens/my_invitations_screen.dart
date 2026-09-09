import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../providers/employee_providers.dart';
import '../widgets/invitation_detail_sheet.dart';

// ---------------------------------------------------------------------------
// My Invitations — ETF Fund Emulation, Phase 3. The analyst's own envelope
// list (docs/ETF_FUND_EMULATION.md's "Флоу приглашения"). Deliberately its
// OWN screen backed by GET /invitations/me, not folded into the app's
// existing Notifications feed — that feed is purely local/per-device
// (fed by pushAppNotification calls on THIS device), so it can never
// surface an invite another user's action created. Styled the same way
// (row list, tap → detail) per the phase plan's "structural analog" note,
// just with its own real backend-fetched data.
// ---------------------------------------------------------------------------

class MyInvitationsScreen extends ConsumerWidget {
  const MyInvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final invitationsAsync = ref.watch(myInvitationsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfInvitationsTitle,
          palette,
          GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
        ),
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
            if (invitations.isEmpty) {
              return Center(
                child: Text(
                  l10n.etfInvitationsEmpty,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              );
            }
            return RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async => ref.invalidate(myInvitationsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invitations.length,
                itemBuilder: (context, i) {
                  final invitation = invitations[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
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
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              joined
                                  ? l10n.etfInvitationAcceptedSnackbar
                                  : l10n.etfInvitationDeclinedSnackbar,
                            ),
                          ),
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
                                    invitation.fundName ??
                                        invitation.fundTicker ??
                                        '',
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
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
