import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/send_invite_sheet.dart';

// ---------------------------------------------------------------------------
// Hiring Marketplace — ETF Fund Emulation, Phase 3. Every available analyst
// profile except this fund's own current roster (see
// employeeService.js's listMarketplace). Head-only screen, reached from
// Fund Detail's "Hire" button — tapping a card sends an invite.
// ---------------------------------------------------------------------------

class EmployeeMarketplaceScreen extends ConsumerWidget {
  final String fundId;

  const EmployeeMarketplaceScreen({super.key, required this.fundId});

  Future<void> _openInvite(
    BuildContext context,
    WidgetRef ref,
    AppPalette palette,
    EmployeeProfile profile,
  ) async {
    final fund = ref.read(fundDetailProvider(fundId)).valueOrNull;
    final sent = await showSendInviteSheet(
      context: context,
      ref: ref,
      fundId: fundId,
      profile: profile,
      palette: palette,
      initialMessage: fund?.lastInviteMessage,
    );
    if (sent == true && context.mounted) {
      ref.invalidate(employeeMarketplaceProvider(fundId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.etfSendInviteSuccessSnackbar),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final marketplaceAsync = ref.watch(employeeMarketplaceProvider(fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfMarketplaceTitle,
          palette,
          GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: marketplaceAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfMarketplaceErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (profiles) {
            if (profiles.isEmpty) {
              return Center(
                child: Text(
                  l10n.etfMarketplaceEmpty,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              );
            }
            return RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async =>
                  ref.invalidate(employeeMarketplaceProvider(fundId)),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: profiles.length,
                itemBuilder: (context, i) {
                  final profile = profiles[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CardFrame(
                      decoration: FomoShieldTheme.cardDecoration,
                      palette: palette,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: palette.accentPrimary
                                .withValues(alpha: 0.2),
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
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () =>
                                _openInvite(context, ref, palette, profile),
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
