import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../providers/fund_providers.dart';
import '../providers/employee_providers.dart';
import '../widgets/fund_delete_dialog.dart';
import '../widgets/fund_team_card.dart';

// ---------------------------------------------------------------------------
// Fund Management — the head/team-facing screen, split out from
// FundDetailScreen (which stays the public, anyone-in-search-sees-this
// card). This one is reached only through Home's "My Fund" shortcut (a
// head) for now; team members don't yet have their own entry point into it
// (Phase 4 — trade proposals/blotter — is where their working screen
// actually gets built out). Everything here today is just the isHead-gated
// controls that used to live inline in FundDetailScreen: the team roster's
// Hire/Terminate actions and the delete-fund flow.
// ---------------------------------------------------------------------------

class FundManagementScreen extends ConsumerWidget {
  final String fundId;

  const FundManagementScreen({super.key, required this.fundId});

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
        title: fundAsync.maybeWhen(
          data: (fund) => themedHeaderText(
            fund.ticker,
            palette,
            GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          fundAsync.maybeWhen(
            data: (fund) => fund.headUserId == currentUserId
                ? IconButton(
                    icon: Icon(Icons.delete_outline, color: palette.textBody),
                    onPressed: () =>
                        showFundDeleteFlow(context, ref, fund.id, palette),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
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
            final teamAsync = ref.watch(fundTeamProvider(fund.id));

            Widget buildBody() => RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async => ref.invalidate(fundDetailProvider(fundId)),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  // Same header/action/divider structure as every other
                  // card here (see FundTeamCard right below) — not a
                  // one-off hero heading.
                  CardFrame(
                    decoration: FomoShieldTheme.cardDecoration,
                    palette: palette,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: themedHeaderText(
                                // cardTitle() is styled for caps (see its
                                // own doc comment) — static labels are
                                // typed in caps in the .arb directly, but
                                // this is dynamic user-entered fund name,
                                // so it needs .toUpperCase() at the call
                                // site instead (same convention as
                                // stress_test_screen.dart's session title).
                                fund.name.toUpperCase(),
                                palette,
                                FomoShieldTheme.cardTitle(),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.push('/funds/${fund.id}'),
                              child: Text(
                                l10n.etfFundManagementViewPublicButton,
                                style: GoogleFonts.inter(
                                  color: palette.accentPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        themedDivider(palette, indent: 0, endIndent: 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FundTeamCard(fundId: fund.id, isHead: isHead, palette: palette),
                ],
              ),
            );

            if (isHead) return buildBody();

            return teamAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: palette.accentPrimary),
              ),
              error: (_, _) => Center(
                child: Text(
                  l10n.etfFundManagementAccessDenied,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              ),
              data: (team) {
                final isMember = team.any(
                  (m) => m.userId == currentUserId && !m.isPendingTermination,
                );
                if (!isMember) {
                  return Center(
                    child: Text(
                      l10n.etfFundManagementAccessDenied,
                      style: GoogleFonts.inter(color: palette.textBody),
                    ),
                  );
                }
                return buildBody();
              },
            );
          },
        ),
      ),
    );
  }
}
