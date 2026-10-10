import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/rebalance_leg.dart';
import '../providers/fund_providers.dart';
import '../widgets/rebalance_legs_list.dart';

// ---------------------------------------------------------------------------
// What the rebalance would do — a screen, not a sheet.
//
// The first version slid up from the bottom, which was wrong twice over: it
// is a page of content with a decision at the end, and the app opens those by
// pushing a screen (Watchlist → a company's card is the pattern he named,
// 2026-10-10). A swipe-up panel also fights with the list inside it.
//
// The plan is fetched here rather than on the card behind it, so the button
// that brings you here does nothing but navigate, and everything that can go
// wrong — no plan, nothing adrift, a company with no price — is explained on
// the screen that was opened to explain it.
// ---------------------------------------------------------------------------

class FundRebalancePreviewScreen extends ConsumerStatefulWidget {
  final String fundId;
  final String mode; // 'cash' | 'full'

  const FundRebalancePreviewScreen({
    super.key,
    required this.fundId,
    required this.mode,
  });

  @override
  ConsumerState<FundRebalancePreviewScreen> createState() =>
      _FundRebalancePreviewScreenState();
}

class _FundRebalancePreviewScreenState
    extends ConsumerState<FundRebalancePreviewScreen> {
  late Future<RebalancePlan> _plan;
  bool _proposing = false;

  @override
  void initState() {
    super.initState();
    _plan = ref
        .read(fundApiServiceProvider)
        .previewRebalance(widget.fundId, widget.mode);
  }

  String _emptyReason(RebalancePlan plan, AppLocalizations l10n) {
    switch (plan.reason) {
      case 'no_targets':
        return l10n.etfRebalanceNoTargets;
      case 'missing_prices':
        return l10n.etfRebalanceMissingPrices(
          plan.skipped.map((s) => s.symbol).join(', '),
        );
      default:
        return l10n.etfRebalanceNothingToDo;
    }
  }

  Future<void> _propose() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _proposing = true);
    try {
      final count = await ref
          .read(fundApiServiceProvider)
          .proposeRebalance(
            widget.fundId,
            widget.mode,
            justification: widget.mode == 'cash'
                ? l10n.etfRebalanceModeCash
                : l10n.etfRebalanceModeFull,
          );
      // The batch lives in the proposals list now, so that list has to be
      // re-read rather than showing one that predates it.
      ref.invalidate(fundProposalsProvider(widget.fundId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.etfRebalanceCreated} — ${l10n.etfRebalanceLegCount(count)}',
          ),
        ),
      );
      // Back to the Balancing screen: the decision is made and this screen
      // has nothing left to say.
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _proposing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.etfRebalanceError),
          backgroundColor: ThemeV2.loss,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        // The noun, not the verb on the button that opened this — screen
        // titles in this app are "БАЛАНСИРОВКА", "ПОРТФЕЛЬ" (DESIGN_TOKENS
        // §7: one key per UI role, even when the words are close).
        title: themedHeaderText(
          l10n.etfRebalanceProposalTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<RebalancePlan>(
          future: _plan,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: palette.accentPrimary),
              );
            }
            if (snapshot.hasError) {
              return _message(palette, l10n.etfRebalanceError);
            }
            final plan = snapshot.data!;
            if (plan.isEmpty) {
              return _message(palette, _emptyReason(plan, l10n));
            }
            return _content(palette, l10n, plan);
          },
        ),
      ),
    );
  }

  Widget _message(AppPalette palette, String text) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
      ),
    ),
  );

  Widget _content(
    AppPalette palette,
    AppLocalizations l10n,
    RebalancePlan plan,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              CardFrame(
                decoration: FomoShieldTheme.cardDecoration,
                palette: palette,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    themedHeaderText(
                      plan.mode == 'cash'
                          ? l10n.etfRebalanceModeCash
                          : l10n.etfRebalanceModeFull,
                      palette,
                      FomoShieldTheme.cardTitle(),
                    ),
                    const SizedBox(height: 10),
                    themedDivider(palette, indent: 0, endIndent: 0),
                    const SizedBox(height: 14),
                    RebalanceLegsList(
                      legs: plan.legs,
                      palette: palette,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // The decision sits on the screen, not at the end of the scroll — a
        // forty-company list would otherwise hide it.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: cancelButton(
                  palette: palette,
                  label: l10n.orderConfirmCancelButton,
                  onTap: _proposing ? null : () => context.pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: brandCtaButton(
                  palette: palette,
                  label: l10n.etfRebalanceConfirmButton,
                  busy: _proposing,
                  onTap: _proposing ? null : _propose,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
