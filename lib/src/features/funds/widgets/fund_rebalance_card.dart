import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/rebalance_leg.dart';
import '../providers/fund_providers.dart';
import 'rebalance_legs_list.dart';

// ---------------------------------------------------------------------------
// The two ways to act on the drift, and the only place either of them starts.
// Phase 4's entry point (2026-10-10).
//
// Neither button does anything on its own: both fetch the plan and show it,
// and only a second, deliberate tap files it as a proposal. A button that
// proposed thirty trades on one tap would be a trap, however clearly it was
// labelled.
// ---------------------------------------------------------------------------

class FundRebalanceCard extends ConsumerStatefulWidget {
  final String fundId;
  final AppPalette palette;
  final AppLocalizations l10n;

  /// Whether this person may propose trades at all. Mirrored server-side —
  /// this only decides whether the buttons are offered.
  final bool canPropose;

  const FundRebalanceCard({
    super.key,
    required this.fundId,
    required this.palette,
    required this.l10n,
    required this.canPropose,
  });

  @override
  ConsumerState<FundRebalanceCard> createState() => _FundRebalanceCardState();
}

class _FundRebalanceCardState extends ConsumerState<FundRebalanceCard> {
  String? _busyMode;

  Future<void> _start(String mode) async {
    if (_busyMode != null) return;
    setState(() => _busyMode = mode);
    final l10n = widget.l10n;
    try {
      final plan = await ref
          .read(fundApiServiceProvider)
          .previewRebalance(widget.fundId, mode);
      if (!mounted) return;
      if (plan.isEmpty) {
        _say(_emptyReason(plan));
        return;
      }
      await _showPlan(plan);
    } catch (_) {
      if (mounted) _say(l10n.etfRebalanceError, isError: true);
    } finally {
      if (mounted) setState(() => _busyMode = null);
    }
  }

  /// Why there is nothing to do, in the words that fit the actual cause.
  String _emptyReason(RebalancePlan plan) {
    final l10n = widget.l10n;
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

  void _say(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ThemeV2.loss : null,
      ),
    );
  }

  Future<void> _showPlan(RebalancePlan plan) async {
    final palette = widget.palette;
    final l10n = widget.l10n;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: palette.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              themedHeaderText(
                l10n.etfRebalanceSheetTitle,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
              const SizedBox(height: 4),
              Text(
                plan.mode == 'cash'
                    ? l10n.etfRebalanceModeCash
                    : l10n.etfRebalanceModeFull,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: palette.textBody,
                ),
              ),
              const SizedBox(height: 10),
              themedDivider(palette, indent: 0, endIndent: 0),
              const SizedBox(height: 12),
              // The list can run to forty companies, so it scrolls inside the
              // sheet while the buttons below stay put.
              Flexible(
                child: SingleChildScrollView(
                  child: RebalanceLegsList(
                    legs: plan.legs,
                    palette: palette,
                    l10n: l10n,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: palette.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        // The app's own cancel wording, reused — the
                        // order confirmation sheet says it the same way.
                        l10n.orderConfirmCancelButton,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentPrimary,
                        foregroundColor: labelColorOn(palette.accentPrimary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.etfRebalanceConfirmButton,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    await _propose(plan.mode);
  }

  Future<void> _propose(String mode) async {
    final l10n = widget.l10n;
    setState(() => _busyMode = mode);
    try {
      final count = await ref
          .read(fundApiServiceProvider)
          .proposeRebalance(
            widget.fundId,
            mode,
            justification: mode == 'cash'
                ? l10n.etfRebalanceModeCash
                : l10n.etfRebalanceModeFull,
          );
      // The proposals screen is where it lives now, so its list has to be
      // re-read rather than showing one that predates the batch.
      ref.invalidate(fundProposalsProvider(widget.fundId));
      if (!mounted) return;
      _say('${l10n.etfRebalanceCreated} — ${l10n.etfRebalanceLegCount(count)}');
    } catch (_) {
      if (mounted) _say(l10n.etfRebalanceError, isError: true);
    } finally {
      if (mounted) setState(() => _busyMode = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.canPropose) return const SizedBox.shrink();
    final palette = widget.palette;
    final l10n = widget.l10n;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfRebalanceButton,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          _option(
            mode: 'cash',
            title: l10n.etfRebalanceModeCash,
            hint: l10n.etfRebalanceModeCashHint,
          ),
          const SizedBox(height: 12),
          _option(
            mode: 'full',
            title: l10n.etfRebalanceModeFull,
            hint: l10n.etfRebalanceModeFullHint,
          ),
        ],
      ),
    );
  }

  Widget _option({
    required String mode,
    required String title,
    required String hint,
  }) {
    final palette = widget.palette;
    final busy = _busyMode == mode;
    final disabled = _busyMode != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: disabled ? null : () => _start(mode),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: palette.border),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: busy
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.accentPrimary,
                    ),
                  )
                : Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: palette.textHeader,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
        ),
      ],
    );
  }
}
