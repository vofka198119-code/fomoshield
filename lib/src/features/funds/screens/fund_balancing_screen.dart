import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../models/fund.dart';
import '../models/fund_drift.dart';
import '../models/fund_target_weight.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_allocation_summary_card.dart';
import '../widgets/fund_drift_card.dart';
import '../widgets/fund_rebalance_card.dart';
import '../widgets/fund_targets_summary_card.dart';

// ---------------------------------------------------------------------------
// Balancing — everything about PROPORTIONS in one place, reached from the
// management panel's circle-shortcut row (2026-10-08 ask: "соберём всё по
// этой теме в новое окно").
//
// Three parts: what the fund holds right now (the same allocation card the
// Charts screen shows — reused, not reimplemented, so the two cannot drift),
// how far that has wandered from the plan, and the plan itself. The fourth —
// a rebalance that turns the gap into trade proposals — comes next.
//
// Named "Балансировка" rather than "Планирование": the screen is about
// "it is like this, it should be like that, bring it into line", and that
// reads off the word at a glance.
// ---------------------------------------------------------------------------

class FundBalancingScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundBalancingScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundBalancingScreen> createState() =>
      _FundBalancingScreenState();
}

class _FundBalancingScreenState extends ConsumerState<FundBalancingScreen> {
  /// The head always may; anyone else needs the permission granted to them.
  /// Mirrored server-side — this only decides whether the controls are live.
  bool _canEdit(FundDetail fund, List<dynamic> team) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return false;
    if (fund.headUserId == userId) return true;
    for (final member in team) {
      if (member.userId == userId && member.status == 'active') {
        return member.permissions['canSetTargets'] == true;
      }
    }
    return false;
  }

  /// A rebalance is a pile of proposals, so the right to start one is the
  /// right to propose. Same shape as [_canEdit], different flag.
  bool _canPropose(FundDetail fund, List<dynamic> team) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return false;
    if (fund.headUserId == userId) return true;
    for (final member in team) {
      if (member.userId == userId && member.status == 'active') {
        return member.permissions['canPropose'] == true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));
    final targetsAsync = ref.watch(fundTargetsProvider(widget.fundId));
    final teamAsync = ref.watch(fundTeamProvider(widget.fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfBalancingScreenTitle,
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
          data: (fund) => RefreshIndicator(
            color: palette.accentPrimary,
            onRefresh: () async {
              ref.invalidate(fundDetailProvider(widget.fundId));
              ref.invalidate(fundTargetsProvider(widget.fundId));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                FundAllocationSummaryCard(
                  fundId: widget.fundId,
                  holdings: fund.holdings,
                  palette: palette,
                  l10n: l10n,
                ),
                const SizedBox(height: 12),
                // The reading sits between the two lists it compares: what
                // the fund holds above it, the plan it is measured against
                // below. It reads the SAVED plan, so an edit in progress
                // does not move the distance until it is saved — the number
                // means "how far the fund is from the plan it has", not
                // "from the plan you are typing".
                FundDriftCard(
                  drift: FundDrift.from(
                    holdings: fund.holdings,
                    targets:
                        targetsAsync.valueOrNull ?? const <FundTargetWeight>[],
                  ),
                  palette: palette,
                  l10n: l10n,
                ),
                const SizedBox(height: 12),
                // Acting on the drift sits directly under the reading of it,
                // and above the plan — "this is the distance, here is what
                // closes it, here is the plan it closes towards".
                FundRebalanceCard(
                  fundId: widget.fundId,
                  palette: palette,
                  l10n: l10n,
                  canPropose: _canPropose(
                    fund,
                    teamAsync.valueOrNull ?? const [],
                  ),
                ),
                const SizedBox(height: 12),
                FundTargetsSummaryCard(
                  fundId: widget.fundId,
                  // An unreadable target list (a 403, or still loading) is
                  // shown as "none set" rather than blocking the screen —
                  // the allocation above is worth seeing either way.
                  targets:
                      targetsAsync.valueOrNull ?? const <FundTargetWeight>[],
                  palette: palette,
                  l10n: l10n,
                  canEdit: _canEdit(fund, teamAsync.valueOrNull ?? const []),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
