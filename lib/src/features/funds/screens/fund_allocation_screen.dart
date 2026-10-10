import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_asset_allocation_card.dart';

// ---------------------------------------------------------------------------
// What the fund holds, on a screen of its own.
//
// It used to expand in place on the Balancing screen, which pushed the plan
// and the rebalance below the fold as soon as it was opened. His call
// (2026-10-10): "вынес бы его в отдельную карточку, а не раскрывал в карточке
// балансировка".
//
// The card itself is reused untouched — the same one the Charts screen
// shows, so the two can never disagree about what the fund holds.
// ---------------------------------------------------------------------------

class FundAllocationScreen extends ConsumerWidget {
  final String fundId;

  const FundAllocationScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfAssetAllocationChartTitle,
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
          data: (fund) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              FundAssetAllocationCard(
                holdings: fund.holdings,
                palette: palette,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
