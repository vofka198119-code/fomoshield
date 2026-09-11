import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_team_card.dart';

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
                  FundTeamCard(fundId: fund.id, isHead: isHead, palette: palette),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
