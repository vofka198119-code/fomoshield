import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../models/fund.dart';
import '../models/fund_target_weight.dart';
import '../providers/employee_providers.dart';
import '../providers/fund_providers.dart';
import '../widgets/fund_target_editor.dart';
import '../../../core/overlay/app_banner.dart';

// ---------------------------------------------------------------------------
// Setting the plan, on a screen of its own.
//
// It used to live inline on the Balancing screen, under two other cards, so
// reaching the steppers meant scrolling past everything the plan is compared
// against, and leaving an edit meant scrolling back. His call (2026-10-10):
// the Balancing screen should carry a short card that says what target
// weights are and a button that opens this — the same shape the rebalance
// card has.
// ---------------------------------------------------------------------------

class FundTargetsScreen extends ConsumerStatefulWidget {
  final String fundId;

  const FundTargetsScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundTargetsScreen> createState() => _FundTargetsScreenState();
}

class _FundTargetsScreenState extends ConsumerState<FundTargetsScreen> {
  bool _saving = false;

  Future<void> _save(List<FundTargetWeight> targets) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      await ref
          .read(fundApiServiceProvider)
          .setFundTargets(widget.fundId, targets);
      ref.invalidate(fundTargetsProvider(widget.fundId));
      if (!mounted) return;
      showAppBanner(l10n.etfBalancingSavedMessage, tone: AppBannerTone.success);
    } catch (_) {
      if (!mounted) return;
      showAppBanner(l10n.etfBalancingSaveError, tone: AppBannerTone.failure);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
        // The house screen-title style (DESIGN_TOKENS §7): 20px, w800,
        // letterSpacing 1.5, centred.
        title: themedHeaderText(
          l10n.etfBalancingTargetTitle,
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
              FundTargetEditor(
                holdings: fund.holdings,
                initialTargets:
                    targetsAsync.valueOrNull ?? const <FundTargetWeight>[],
                palette: palette,
                l10n: l10n,
                canEdit: _canEdit(fund, teamAsync.valueOrNull ?? const []),
                saving: _saving,
                onSave: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
