import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../features/market_clock/market_clock_dial.dart';
import '../../../features/market_clock/market_clock_engine.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';

// ---------------------------------------------------------------------------
// Market Clock Widget — Home mini card. Same instrument-panel dial as the
// full Market Clock screen (market_clock_screen.dart), scaled down, with a
// compact status readout next to it. Tapping anywhere opens the full screen.
// ---------------------------------------------------------------------------

class MarketClockWidget extends ConsumerStatefulWidget {
  const MarketClockWidget({super.key});

  @override
  ConsumerState<MarketClockWidget> createState() => _MarketClockWidgetState();
}

class _MarketClockWidgetState extends ConsumerState<MarketClockWidget> {
  late Timer _timer;
  late MarketClockState _state;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recompute on every call, not just the first — didChangeDependencies
    // fires again whenever an inherited dependency (the app's Locale
    // included) changes, and _state bakes the current l10n's strings
    // straight into MarketWindow. Gating this behind _initialized used to
    // freeze the active phase's headline at whatever locale was active on
    // this widget's first build (e.g. a still-settling locale at cold
    // start) until the timer's own next tick happened to catch up — only
    // the timer start itself needs the once-only guard.
    final l10n = AppLocalizations.of(context)!;
    _state = resolveMarketClockState(l10n, nowInNewYork());
    if (_initialized) return;
    _initialized = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _state = resolveMarketClockState(l10n, nowInNewYork()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final window = _state.window;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return InkWell(
      onTap: () => context.push('/market-clock'),
      borderRadius: FomoShieldTheme.cardRadius,
      child: CardFrame(
        padding: EdgeInsets.zero,
        decoration: marketClockCardDecoration(palette: palette),
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  // This card is unconditionally dark in BOTH themes (its
                  // own pre-existing "instrument panel" look under
                  // Standard; the universal Luxury card gradient under
                  // Luxury — CardFrame swaps to that automatically once a
                  // palette with cardGradient is passed). White base text
                  // stays correct either way; only the gold ShaderMask is
                  // conditional. Don't use themedHeaderText's own
                  // Standard-theme fallback here — it assumes a light
                  // backdrop (accentPrimary/green), which this card never
                  // has.
                  themedGoldGradient(
                    Text(
                      AppLocalizations.of(context)!.marketClockTitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: palette.onWindow ?? Colors.white,
                        letterSpacing: 1.2,
                        shadows: palette.titleShadow != null
                            ? [palette.titleShadow!]
                            : null,
                      ),
                    ),
                    palette,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
            // Same always-dark reasoning as the title above — themedDivider's
            // own Standard-theme fallback (near-black) would be invisible
            // here, so only borrow its Luxury gradient, not its default.
            palette.dividerGradient != null
                ? themedDivider(palette)
                : Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.1),
                  ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                AppLocalizations.of(context)!.marketClockNewYorkTime,
                // Matches the canonical small-label style (see Portfolio's
                // BALANCE/CASH cell labels) — size/spacing always, color
                // only under Luxury (this card is always dark, so the
                // Standard-theme fallback stays dialBrassLight, not
                // palette.accentPrimary/green, which would repeat the
                // low-contrast pitfall documented elsewhere).
                style: GoogleFonts.inter(
                  fontSize: palette.windowGradient != null ? 10 : 9,
                  fontWeight: FontWeight.w700,
                  // marketClockAccent != null is Midnight Sea's own signal
                  // (paired with its re-themed dial) — plain white beats
                  // the brass label on its now-blue instrument panel.
                  color: palette.windowGradient != null
                      ? (palette.onWindow ?? palette.accentPrimary)
                      : palette.marketClockAccent != null
                          ? Colors.white
                          : dialBrassLight.withValues(alpha: 0.7),
                  letterSpacing: palette.windowGradient != null ? 0.6 : 0.8,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MarketClockDial(
                    state: _state,
                    size: 88,
                    ringStroke: 4,
                    palette: palette,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              window.emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                window.shortHeadline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: palette.marketClockAccent != null
                                      ? (palette.onWindow ?? Colors.white)
                                      : dialIvory,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          window.shortDetail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          // REVISED 2026-08-25: was palette.textBody (Muted
                          // Silver) — read as flat gray. This card is
                          // always-dark in BOTH themes (see pitfall notes),
                          // so — same as Shield Signal's mood-panel body
                          // text (shield_signal_widget.dart) — plain white
                          // is the correct fix under Luxury too, not a
                          // palette field (textHeader would be near-black
                          // under Standard, textBody was gray under
                          // Luxury). Standard's own dialIvory@70% is
                          // untouched.
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: palette.windowGradient != null ||
                                    palette.marketClockAccent != null
                                ? (palette.onWindow ?? Colors.white)
                                    .withValues(alpha: 0.85)
                                : dialIvory.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          window.timeRangeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: palette.marketClockAccent != null
                                ? (palette.onWindow ?? Colors.white)
                                : dialBrassLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
