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
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/numeric_keypad.dart';
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

  /// Companies he has unticked. Sent with every recalculation and with the
  /// proposal itself, so what is filed is what he was looking at.
  final Set<String> _excluded = {};

  /// 'cash' mode only: how much of the free cash to put to work. Null means
  /// all of it, which is also what the screen starts with.
  double? _amount;

  /// The fund's free cash, learnt from the first plan — the ceiling for the
  /// amount field and the number shown when nothing has been typed.
  double _cash = 0;

  bool get _isCashMode => widget.mode == 'cash';

  @override
  void initState() {
    super.initState();
    _plan = _load();
  }

  Future<RebalancePlan> _load() async {
    final plan = await ref
        .read(fundApiServiceProvider)
        .previewRebalance(
          widget.fundId,
          widget.mode,
          exclude: _excluded.toList(),
          amount: _amount,
        );
    _cash = plan.cash;
    return plan;
  }

  /// Every tick recalculates on the server rather than in the phone: the
  /// numbers in the proposal have to be the numbers he approved, and only
  /// one of the two can be the authority.
  void _toggle(String symbol) {
    setState(() {
      if (!_excluded.remove(symbol)) _excluded.add(symbol);
      _plan = _load();
    });
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

  /// How much of the free cash to spend. The app's own keypad in a themed
  /// sheet — the same one the target editor and order entry use; a system
  /// keyboard over a white box would belong to a different program.
  Future<void> _editAmount() async {
    final palette = resolveAppPalette(ref.read(themeVariantProvider));
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: (_amount ?? _cash).toStringAsFixed(2),
    );

    final entered = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: palette.card,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.etfRebalanceAmountLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textBody,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.text.isEmpty
                    ? '—'
                    : formatUsd(double.tryParse(controller.text) ?? 0),
                style: interNums(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${l10n.etfRebalanceAmountAvailable} ${formatUsd(_cash)}',
                style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
              ),
              const SizedBox(height: 16),
              NumericKeypad(
                controller: controller,
                onChanged: () => setSheet(() {
                  // Never more than the fund has — a number it cannot spend
                  // would only be silently cut down later.
                  final typed = double.tryParse(controller.text);
                  if (typed != null && typed > _cash) {
                    controller.text = _cash.toStringAsFixed(2);
                  }
                }),
                onDone: () => Navigator.pop(ctx, controller.text),
                palette: palette,
                header: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: brandCtaButton(
                      palette: palette,
                      label: l10n.commonOk,
                      height: 44,
                      onTap: () => Navigator.pop(ctx, controller.text),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (entered == null) return;
    final parsed = double.tryParse(entered.replaceAll(',', '.').trim());
    if (parsed == null || parsed <= 0) return;
    setState(() {
      _amount = parsed.clamp(0, _cash).toDouble();
      _plan = _load();
    });
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
            exclude: _excluded.toList(),
            amount: _amount,
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
                    // Only the free-cash route takes an amount: in the other
                    // one the size of the trades is decided by the drift, not
                    // by what anyone feels like spending (his call).
                    if (_isCashMode) ...[
                      InkWell(
                        onTap: _proposing ? null : _editAmount,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.etfRebalanceAmountLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: palette.textBody,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    formatUsd(_amount ?? plan.cash),
                                    style: interNums(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textHeader,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 16,
                                    color: palette.textBody,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      themedDivider(palette, indent: 0, endIndent: 0),
                      const SizedBox(height: 14),
                    ],
                    RebalanceLegsList(
                      legs: plan.legs,
                      palette: palette,
                      l10n: l10n,
                      untouched: plan.untouched,
                      onToggle: _proposing ? null : _toggle,
                    ),
                    // What the batch will not fix — rounding dust when
                    // everything is ticked, the price of his choice when it
                    // is not.
                    if (plan.residual != null &&
                        plan.residual!.gap.abs() >= 0.01) ...[
                      const SizedBox(height: 6),
                      themedDivider(palette, indent: 0, endIndent: 0),
                      const SizedBox(height: 12),
                      Text(
                        l10n.etfRebalanceResidual(
                          plan.residual!.symbol,
                          plan.residual!.gap.abs().toStringAsFixed(2),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: palette.textBody,
                        ),
                      ),
                    ],
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
