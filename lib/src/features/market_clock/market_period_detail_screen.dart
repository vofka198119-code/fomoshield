import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_button.dart';
import '../../l10n/gen/app_localizations.dart';
import '../stress_test/stress_test_hub_screen.dart';
import 'market_clock_engine.dart';

class MarketPeriodDetailScreen extends ConsumerWidget {
  final String windowId;
  const MarketPeriodDetailScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final window = findWindowById(l10n, windowId);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          window?.shortHeadline.toUpperCase() ??
              l10n.marketPeriodDetailFallbackTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: window == null
            ? const SizedBox()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          window.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            window.fullTitle,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: palette.textHeader,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      window.timeRangeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: palette.accentPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      label: l10n.marketPeriodDetailWhatsHappeningLabel,
                      body: window.whatHappens,
                      palette: palette,
                    ),
                    _Section(
                      label: l10n.marketPeriodDetailWhyDoesItMatterLabel,
                      body: window.whyItMatters,
                      palette: palette,
                    ),
                    if (window.dangerForBeginner != null)
                      _Section(
                        label: l10n.marketPeriodDetailWhatCanGoWrongLabel,
                        body: window.dangerForBeginner!,
                        palette: palette,
                      ),
                    _Section(
                      label: l10n.marketPeriodDetailWhatShouldBeginnersDoLabel,
                      body: window.whatToDo,
                      isLast:
                          window.stressTestPromoTitle == null &&
                          window.fomoShieldTip == null,
                      palette: palette,
                    ),
                    if (window.stressTestPromoTitle != null &&
                        window.stressTestPromoBody != null) ...[
                      _StressTestPromo(
                        title: window.stressTestPromoTitle!,
                        body: window.stressTestPromoBody!,
                        palette: palette,
                      ),
                      const SizedBox(height: 18),
                    ],
                    if (window.fomoShieldTip != null)
                      _TipCallout(body: window.fomoShieldTip!, palette: palette),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String body;
  final bool isLast;
  final AppPalette palette;
  const _Section({
    required this.label,
    required this.body,
    required this.palette,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.accentPrimary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: palette.textHeader,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Callout shown only on non-trading windows (weekend/holiday), nudging the
/// user toward Stress Test with a direct link while the real market is
/// closed.
class _StressTestPromo extends StatelessWidget {
  final String title;
  final String body;
  final AppPalette palette;
  const _StressTestPromo({
    required this.title,
    required this.body,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: palette.windowGradient,
        // Was a hardcoded ThemeV2.surface (Standard's own light card
        // color) — invisible under Midnight Sea, whose palette.textHeader/
        // textBody are plain white: white text on a white box read as an
        // empty block (confirmed on-device 2026-09-02). palette.card is
        // the correct per-theme fallback (identical to ThemeV2.surface
        // for Standard, since that's literally its own value there).
        color: palette.windowGradient == null ? palette.card : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: palette.textHeader,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: palette.textBody,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            // Was a plain ElevatedButton with a hardcoded ThemeV2.primary
            // (Standard's own green) fill. Rebuilt on themedDarkCtaButtonShell
            // — same shell every other "dark CTA" button in the app uses —
            // so a theme that sets windowGradient/buttonGradient (Midnight
            // Sea: radial window fill + gradient border + cardGlow shadow,
            // 2026-09-02) picks that up automatically; standardDecoration
            // keeps Standard's flat green exactly as it was.
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const StressTestHubScreen()),
                ),
                child: themedDarkCtaButtonShell(
                  palette: palette,
                  borderRadius: BorderRadius.circular(12),
                  standardDecoration: BoxDecoration(
                    color: palette.accentPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.marketPeriodDetailOpenStressTestButton,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: themedDarkCtaContentColor(palette),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlighted callout for the closing "F.O.M.O. Shield Tip" — distinct from
/// the plain label+body sections above it, since it's a branded takeaway
/// rather than another explanatory section.
class _TipCallout extends StatelessWidget {
  final String body;
  final AppPalette palette;
  const _TipCallout({required this.body, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: palette.windowGradient,
        color: palette.windowGradient == null
            ? palette.accentPrimary.withValues(alpha: 0.08)
            : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.accentPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                l10n.marketPeriodDetailFomoShieldTipLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: palette.accentPrimary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: palette.textHeader,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
