import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/overlay/app_sheet.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/numeric_keypad.dart';
import '../../../shared/widgets/ringed_company_logo.dart';
import '../models/fund.dart';
import '../models/fund_target_weight.dart';

// ---------------------------------------------------------------------------
// Target weights, edited. Modelled on Trading 212's pie editor: one row per
// company, a minus/plus stepper, and a running total that has to reach 100.
//
// No money anywhere — his explicit call (2026-10-08). This widget is about
// proportions, and the position's value and P&L already sit in the allocation
// card above it; repeating them here would only pull the eye away from the
// one number that matters, the gap between actual and target.
//
// Whole-percent steps, two-decimal storage. The buttons move by 1 because
// that is what a finger wants; the fractions arrive from redistribution,
// which rarely lands on round numbers.
// ---------------------------------------------------------------------------

class FundTargetEditor extends StatefulWidget {
  final List<FundHolding> holdings;
  final List<FundTargetWeight> initialTargets;
  final AppPalette palette;
  final AppLocalizations l10n;
  final bool canEdit;
  final bool saving;
  final Future<void> Function(List<FundTargetWeight>) onSave;

  const FundTargetEditor({
    super.key,
    required this.holdings,
    required this.initialTargets,
    required this.palette,
    required this.l10n,
    required this.canEdit,
    required this.saving,
    required this.onSave,
  });

  @override
  State<FundTargetEditor> createState() => _FundTargetEditorState();
}

class _FundTargetEditorState extends State<FundTargetEditor> {
  /// Symbol -> percent. A symbol absent from here has no target, which is
  /// the same thing as a target of zero — see Migration 034.
  late Map<String, double> _targets;

  @override
  void initState() {
    super.initState();
    _targets = {
      for (final t in widget.initialTargets) t.symbol: t.targetPercent,
    };
  }

  @override
  void didUpdateWidget(FundTargetEditor old) {
    super.didUpdateWidget(old);
    // Only reseed when the saved set actually changed — otherwise a rebuild
    // from an unrelated provider would throw away edits in progress.
    if (old.initialTargets != widget.initialTargets) {
      _targets = {
        for (final t in widget.initialTargets) t.symbol: t.targetPercent,
      };
    }
  }

  /// Every company the editor offers a row for: what the fund holds, plus
  /// anything that already has a target. The second half matters because a
  /// target may outlive its position, and may exist for a company the fund
  /// has not bought yet.
  List<String> get _symbols {
    final set = <String>{
      ...widget.holdings.map((h) => h.symbol),
      ..._targets.keys,
    };
    final list = set.toList();
    // Heaviest target first, like Trading 212's "sorted by target weight";
    // companies with no target fall to the bottom, alphabetically.
    list.sort((a, b) {
      final ta = _targets[a] ?? -1;
      final tb = _targets[b] ?? -1;
      if (ta != tb) return tb.compareTo(ta);
      return a.compareTo(b);
    });
    return list;
  }

  double get _total => _targets.values.fold<double>(0, (sum, v) => sum + v);

  double _actualPercent(String symbol) {
    final total = widget.holdings.fold<double>(0, (s, h) => s + h.value);
    if (total <= 0) return 0;
    final holding = widget.holdings.where((h) => h.symbol == symbol);
    if (holding.isEmpty) return 0;
    return holding.first.value / total * 100;
  }

  void _bump(String symbol, int delta) {
    if (!widget.canEdit) return;
    setState(() {
      final next = ((_targets[symbol] ?? 0) + delta).clamp(0, 100).toDouble();
      // Zero removes the row rather than storing a zero — the table refuses
      // one anyway, and "no opinion" is the absence of a target.
      if (next <= 0) {
        _targets.remove(symbol);
      } else {
        _targets[symbol] = next;
      }
    });
  }

  /// Tap the number between the steppers to type one. The buttons move by
  /// whole percents, which is right for nudging and hopeless for "make this
  /// exactly 12.75" — his ask, 2026-10-08.
  ///
  /// The app's own NumericKeypad in a themed sheet, NOT an AlertDialog with
  /// a TextField: the first attempt summoned the system keyboard over a
  /// white stock input box and looked like it belonged to a different
  /// program. The same keypad already serves order entry and Set Goal.
  /// Keeps what is being typed inside what a target can be: at most two
  /// decimals, never above 100. Enforced as the keys are pressed rather than
  /// only on accept (his ask, 2026-10-08) — a field that silently rewrites
  /// your number afterwards is worse than one that never took it.
  ///
  /// Done here and not in NumericKeypad: that widget is shared with order
  /// entry and Set Goal, where neither limit belongs.
  void _clampTyped(TextEditingController c) {
    var text = c.text;
    final dot = text.indexOf('.');
    if (dot >= 0 && text.length - dot - 1 > 2) {
      text = text.substring(0, dot + 3);
    }
    final value = double.tryParse(text);
    if (value != null && value > 100) text = '100';
    // The keypad only ever appends, so there is no cursor to preserve.
    if (text != c.text) c.text = text;
  }

  Future<void> _typeValue(String symbol) async {
    if (!widget.canEdit || widget.saving) return;
    final palette = widget.palette;
    final l10n = widget.l10n;
    final current = _targets[symbol];
    final controller = TextEditingController(
      text: current == null ? '' : current.toStringAsFixed(2),
    );

    final entered = await showAppSheet<String>(
      context: context,
      palette: palette,
      padded: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // No drag handle of our own: NumericKeypad brings one, and two
              // of them a finger's width apart reads as a mistake. Swiping
              // the keypad's closes this sheet, keeping the value.
              const SizedBox(height: 20),
              Text(
                '$symbol — ${l10n.etfBalancingEnterTitle}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.textBody,
                ),
              ),
              const SizedBox(height: 8),
              // The value being typed, large and centred, the way order
              // entry shows an amount above the same grid.
              Text(
                controller.text.isEmpty ? '—' : '${controller.text}%',
                style: interNums(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 16),
              NumericKeypad(
                controller: controller,
                onChanged: () => setSheet(() => _clampTyped(controller)),
                onDone: () => Navigator.pop(ctx, controller.text),
                palette: palette,
                header: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, controller.text),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentPrimary,
                        foregroundColor: labelColorOn(palette.accentPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.commonOk,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
    // The keypad only emits digits and one separator, but a comma can still
    // arrive from a value typed before this screen existed.
    final parsed = double.tryParse(entered.replaceAll(',', '.').trim());
    // Unparseable input leaves the row alone rather than zeroing it — a
    // mistyped value should cost nothing.
    if (parsed == null) return;
    setState(() {
      final clamped = parsed.clamp(0, 100).toDouble();
      final rounded = (clamped * 100).round() / 100;
      if (rounded <= 0) {
        _targets.remove(symbol);
      } else {
        _targets[symbol] = rounded;
      }
    });
  }

  /// Brings the total to 100 by scaling every target by the same factor —
  /// the excess comes off the heavy ones hardest, the light ones barely
  /// notice, and the ratios between them are untouched. Same rule as the
  /// redistribution on a sale: proportional, so the plan is rescaled rather
  /// than rewritten.
  ///
  /// Was "spread evenly" first, which threw the plan away and started over
  /// — not what the button is for (corrected 2026-10-08). The equal split
  /// survives only for a fund with no targets at all: there is no shape to
  /// preserve yet, so there is nothing to scale.
  void _evenOut() {
    if (!widget.canEdit) return;

    if (_targets.isEmpty) {
      final symbols = widget.holdings.map((h) => h.symbol).toList();
      if (symbols.isEmpty) return;
      setState(() {
        final each = (100 / symbols.length * 100).floor() / 100;
        _targets = {for (final s in symbols) s: each};
        _settleCrumb();
      });
      return;
    }

    final total = _total;
    if (total <= 0) return;
    setState(() {
      final factor = 100 / total;
      _targets = {
        for (final e in _targets.entries)
          e.key: (e.value * factor * 100).round() / 100,
      };
      // Scaling to two decimals lands near 100, rarely on it. The crumb is
      // too small to show and too annoying to leave.
      _targets.removeWhere((_, v) => v <= 0);
      _settleCrumb();
    });
  }

  /// Pushes whatever is left of 100 into the largest target, so the total
  /// reads exactly 100 instead of 99.99.
  void _settleCrumb() {
    if (_targets.isEmpty) return;
    final crumb = (100 - _total * 100).round() / 100;
    if (crumb == 0) return;
    final heaviest = _targets.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final adjusted = ((heaviest.value + crumb) * 100).round() / 100;
    if (adjusted > 0) _targets[heaviest.key] = adjusted;
  }

  /// Whether anything has actually changed since the last save. Compared
  /// against the saved set rather than tracked with a flag, so an edit that
  /// walks back to where it started counts as no edit — nudging a target up
  /// and down again should leave the button asleep.
  ///
  /// The tolerance is half of the stored precision: two values that both
  /// round to the same hundredth are the same value.
  bool get _isDirty {
    final saved = {
      for (final t in widget.initialTargets) t.symbol: t.targetPercent,
    };
    if (saved.length != _targets.length) return true;
    for (final entry in _targets.entries) {
      final before = saved[entry.key];
      if (before == null || (before - entry.value).abs() > 0.005) return true;
    }
    return false;
  }

  /// Puts every number back the way it was saved. His ask, 2026-10-10: after
  /// touching the steppers there was no way out of the edit except leaving
  /// the screen and hoping nothing had been kept.
  void _revert() {
    setState(() {
      _targets = {
        for (final t in widget.initialTargets) t.symbol: t.targetPercent,
      };
    });
  }

  bool get _canSave {
    if (!widget.canEdit || widget.saving) return false;
    // Nothing to save is not a thing to offer — his ask, 2026-10-10: after a
    // save the button went on looking ready, which reads as "something is
    // still unsaved" when nothing is.
    if (!_isDirty) return false;
    if (_targets.isEmpty) return true; // clearing the plan is allowed
    return (_total - 100).abs() <= 1;
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final l10n = widget.l10n;
    final symbols = _symbols;

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.etfBalancingTargetTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          const SizedBox(height: 10),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 14),
          if (symbols.isEmpty)
            Text(
              l10n.etfBalancingNoHoldings,
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            )
          else ...[
            if (_targets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.etfBalancingNoTargets,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                ),
              ),
            for (final symbol in symbols) _row(symbol),
            const SizedBox(height: 6),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 12),
            _totalRow(),
            if (widget.canEdit) ...[
              const SizedBox(height: 10),
              _hint(),
              const SizedBox(height: 12),
              _buttons(),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                l10n.etfBalancingReadOnlyNote,
                style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _row(String symbol) {
    final palette = widget.palette;
    final target = _targets[symbol];
    final actual = _actualPercent(symbol);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Smaller than the rebalance list's, because this row also carries
          // two steppers and a tappable value and still has to fit a narrow
          // phone.
          RingedCompanyLogo(symbol: symbol, palette: palette, size: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
                // Actual against target, the Trading 212 reading: what it
                // is, then what it should be — and the two halves must not
                // share a colour, or the line reads as one grey number and
                // the eye slides off it (seen on-device 2026-10-08).
                // Accent for the fact, muted for the plan. The windowGradient
                // guard is the same one FundBalanceCard uses: a theme whose
                // accent is near-black would vanish on this card.
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${actual.toStringAsFixed(2)}%',
                        style: interNums(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: palette.actualFigureColour,
                        ),
                      ),
                      // Green is the target, the theme's accent is where the
                      // fund actually stands — his colour scheme, 2026-10-08.
                      // Two different questions, two colours.
                      if (target != null) ...[
                        TextSpan(
                          text: '  /  ',
                          style: interNums(
                            fontSize: 12,
                            color: palette.textBody,
                          ),
                        ),
                        TextSpan(
                          text: '${target.toStringAsFixed(2)}%',
                          style: interNums(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ThemeV2.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          _stepButton(Icons.remove_rounded, () => _bump(symbol, -1)),
          GestureDetector(
            onTap: () => _typeValue(symbol),
            // Transparent fill so the whole 58px box takes the tap, not just
            // the glyphs — a four-character number is a small target.
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 58,
              height: 32,
              child: Center(
                child: Text(
                  target == null ? '—' : '${target.toStringAsFixed(2)}%',
                  textAlign: TextAlign.center,
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
              ),
            ),
          ),
          _stepButton(Icons.add_rounded, () => _bump(symbol, 1)),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    final palette = widget.palette;
    final enabled = widget.canEdit && !widget.saving;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: palette.border.withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? palette.textHeader
              : palette.textBody.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _totalRow() {
    final palette = widget.palette;
    final l10n = widget.l10n;
    final leftover = 100 - _total;
    final settled = leftover.abs() <= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.etfBalancingTotalLabel,
              style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
            ),
            Text(
              '${_total.toStringAsFixed(2)}%',
              style: interNums(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: settled ? ThemeV2.success : ThemeV2.warning,
              ),
            ),
          ],
        ),
        // Only worth saying while it is unsettled — the number above already
        // tells the story once it adds up.
        if (!settled && _targets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              // Past 100 it is not "unallocated" — a negative amount of
              // unallocated space is a riddle, not a hint.
              leftover < 0
                  ? '${l10n.etfBalancingOverAllocated}: '
                        '${(-leftover).toStringAsFixed(2)}%'
                  : '${l10n.etfBalancingUnallocated}: '
                        '${leftover.toStringAsFixed(2)}%',
              style: interNums(fontSize: 12, color: ThemeV2.warning),
            ),
          ),
      ],
    );
  }

  /// Says what the button would do, in the direction it would do it. Only
  /// while there is something to do — once the total is 100 the button is
  /// disabled and a standing explanation would just be noise.
  Widget _hint() {
    final l10n = widget.l10n;
    final leftover = 100 - _total;
    if (leftover.abs() <= 0.009) return const SizedBox.shrink();
    final text = _targets.isEmpty
        ? l10n.etfBalancingSeedHint
        : leftover < 0
        ? l10n.etfBalancingOverHint
        : l10n.etfBalancingUnderHint;
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 12, color: widget.palette.textBody),
    );
  }

  Widget _buttons() {
    final palette = widget.palette;
    final l10n = widget.l10n;
    final settled = (100 - _total).abs() <= 0.009;

    return Column(
      children: [
        // Secondary, and only while there is something to even out.
        // The app's one secondary-action pill (Home, Market Clock, Stress
        // Test all use it), not a second cancel-looking button.
        if (!settled) ...[
          Center(
            child: themedAddWidgetsButton(
              context,
              palette,
              icon: Icons.balance_rounded,
              label: l10n.etfBalancingAutoButton,
              onTap: widget.saving ? () {} : _evenOut,
            ),
          ),
          const SizedBox(height: 12),
        ],
        // The pair every editor in the app should end with: the way out on
        // the left, the commitment on the right. Both asleep when nothing
        // has changed — there is nothing to undo and nothing to save.
        Row(
          children: [
            Expanded(
              child: cancelButton(
                palette: palette,
                label: l10n.orderConfirmCancelButton,
                onTap: (_isDirty && !widget.saving) ? _revert : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: brandCtaButton(
                palette: palette,
                label: l10n.etfBalancingSaveButton,
                busy: widget.saving,
                onTap: _canSave
                    ? () => widget.onSave([
                        for (final e in _targets.entries)
                          FundTargetWeight(
                            symbol: e.key,
                            targetPercent: e.value,
                          ),
                      ])
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
