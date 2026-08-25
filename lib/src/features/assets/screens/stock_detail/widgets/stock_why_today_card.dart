import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../../core/theme/typography_helpers.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/themed_header.dart';
import '../../../../../core/theme/themed_divider.dart';
import '../../../../../shared/widgets/card_frame.dart';
import '../../../../../core/supabase/supabase_providers.dart';
import '../../../../market_clock/market_clock_dial.dart'
    show darkCardDecoration;
import '../../../../stress_test/stress_test_models.dart'
    show TickExplanation, PriceContribution;
import '../../../../../shared/utils/currency_format.dart';
import '../../../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Stress Test "Why Today" card — dark dialLight/dialDark family (matches
// Psychology Meter's marker cards: psychology_marker_card.dart +
// allocation_bar_row.dart). Factor bars keep their own semantic colors
// (Market/Sector/News/Hype/Noise, FomoShieldTheme.factor*) rather than a
// single gold fill, since that color-coding is meaningful elsewhere
// (verdict trade breakdown).
//
// Shows all 5 real contribution factors now, not 4 — [TickExplanation.
// contributions] has always had a hypePct ("Sector Trend": a whole
// GICS-sector move, hype/hype_event.dart) that this card never displayed,
// so the bars never actually summed to the visible 100%.
//
// Explanation text is driven by the real dominant factor (+ the real
// epoch scenario when Market dominates) but deliberately phrased as a
// hint/possibility, never a flat factual claim like "the bull scenario is
// active" — the simulation's internal mechanics aren't meant to be
// legible to the user. Copy in [_hintCopy] is a first draft; the wording
// is the user's to finalize.
// ---------------------------------------------------------------------------

enum _WhyTodayHint {
  noData,
  marketBull,
  marketSideways,
  marketBear,
  marketVolatility,
  marketRecovery,
  marketBlackSwan,
  marketCrash,
  sector,
  news,
  hype,
  noise,
}

Map<_WhyTodayHint, String> _hintCopyFor(AppLocalizations l10n) => {
  _WhyTodayHint.noData: l10n.whyTodayCardHintNoData,
  _WhyTodayHint.marketBull: l10n.whyTodayCardHintMarketBull,
  _WhyTodayHint.marketSideways: l10n.whyTodayCardHintMarketSideways,
  _WhyTodayHint.marketBear: l10n.whyTodayCardHintMarketBear,
  _WhyTodayHint.marketVolatility: l10n.whyTodayCardHintMarketVolatility,
  _WhyTodayHint.marketRecovery: l10n.whyTodayCardHintMarketRecovery,
  _WhyTodayHint.marketBlackSwan: l10n.whyTodayCardHintMarketBlackSwan,
  _WhyTodayHint.marketCrash: l10n.whyTodayCardHintMarketCrash,
  _WhyTodayHint.sector: l10n.whyTodayCardHintSector,
  _WhyTodayHint.news: l10n.whyTodayCardHintNews,
  _WhyTodayHint.hype: l10n.whyTodayCardHintHype,
  _WhyTodayHint.noise: l10n.whyTodayCardHintNoise,
};

class StockWhyTodayCard extends ConsumerWidget {
  final String sessionId;
  final String symbol;
  final double priceChange;
  final double priceChangePercent;
  final bool isPositive;
  final TickExplanation? latestExplanation;

  /// Weighted-average breakdown across the same window [priceChange]/
  /// [priceChangePercent] cover (see aggregatePriceContributions in
  /// stress_test_models.dart) — used for the bars/hint instead of
  /// [latestExplanation]'s single instant, so a factor that clearly drove
  /// the period (e.g. a News event ramping in) doesn't read as 0% just
  /// because the most recent tick alone wasn't the one moving it. Falls
  /// back to [latestExplanation]'s own contributions when not supplied.
  final PriceContribution? aggregatedContributions;
  final AppPalette palette;

  const StockWhyTodayCard({
    super.key,
    required this.sessionId,
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.isPositive,
    required this.palette,
    this.latestExplanation,
    this.aggregatedContributions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = ref.watch(isAdminProvider);
    final contributions =
        aggregatedContributions ?? latestExplanation?.contributions;
    final marketPct = contributions?.marketPct ?? 0;
    final sectorPct = contributions?.sectorPct ?? 0;
    final newsPct = contributions?.newsPct ?? 0;
    final hypePct = contributions?.hypePct ?? 0;
    final noisePct = contributions?.noisePct ?? 0;

    return CardFrame(
      showTopBar: false,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
      decoration: darkCardDecoration(),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              themedGoldGradient(
                Text(
                  l10n.whyTodayCardTitle,
                  style: FomoShieldTheme.cardTitle(Colors.white),
                ),
                palette,
              ),
              // Admin-only — this button (and the detail screen behind it,
              // with the raw per-tick factor breakdown) is an engine
              // debugging tool, not a real user-facing feature.
              if (isAdmin)
                GestureDetector(
                  onTap: () =>
                      context.push('/stress-test/$sessionId/stock/$symbol/why'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.whyTodayCardButtonLabel,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          palette.dividerGradient != null
              ? themedDivider(palette, indent: 0, endIndent: 0)
              : Divider(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _changeBox(
                  label: l10n.whyTodayCardTodaysChangeLabel,
                  value: formatUsdSigned(priceChange),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _changeBox(
                  label: l10n.whyTodayCardPercentChangeLabel,
                  value:
                      '${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _factorBar(
            l10n.whyTodayCardFactorMarketTrends,
            marketPct / 100,
            FomoShieldTheme.factorMarket,
          ),
          const SizedBox(height: 12),
          _factorBar(
            l10n.whyTodayCardFactorSector,
            sectorPct / 100,
            FomoShieldTheme.factorSector,
          ),
          const SizedBox(height: 12),
          _factorBar(
            l10n.whyTodayCardFactorNews,
            newsPct / 100,
            FomoShieldTheme.factorNews,
          ),
          const SizedBox(height: 12),
          _factorBar(
            l10n.whyTodayCardFactorSectorHype,
            hypePct / 100,
            FomoShieldTheme.factorHype,
          ),
          const SizedBox(height: 12),
          _factorBar(
            l10n.whyTodayCardFactorNoise,
            noisePct / 100,
            FomoShieldTheme.factorNoise,
          ),
          const SizedBox(height: 16),
          Text(
            _hintCopyFor(l10n)[_resolveHint(
              contributions == null,
              marketPct,
              sectorPct,
              newsPct,
              hypePct,
              noisePct,
            )]!,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Picks a hint key from whichever real factor dominates this tick's
  /// breakdown — Market's hint further branches on the real epoch
  /// scenario so a bull run and a crash don't share one vague line,
  /// without ever naming the scenario outright in the copy itself.
  _WhyTodayHint _resolveHint(
    bool noData,
    double marketPct,
    double sectorPct,
    double newsPct,
    double hypePct,
    double noisePct,
  ) {
    if (noData) return _WhyTodayHint.noData;

    final entries = <MapEntry<_WhyTodayHint, double>>[
      MapEntry(_WhyTodayHint.marketBull, marketPct),
      MapEntry(_WhyTodayHint.sector, sectorPct),
      MapEntry(_WhyTodayHint.news, newsPct),
      MapEntry(_WhyTodayHint.hype, hypePct),
      MapEntry(_WhyTodayHint.noise, noisePct),
    ];
    entries.sort((a, b) => b.value.compareTo(a.value));
    final dominant = entries.first.key;

    if (dominant != _WhyTodayHint.marketBull) return dominant;

    return switch (latestExplanation?.scenario) {
      'bull' => _WhyTodayHint.marketBull,
      'sideways' => _WhyTodayHint.marketSideways,
      'bear' => _WhyTodayHint.marketBear,
      'volatility' => _WhyTodayHint.marketVolatility,
      'recovery' => _WhyTodayHint.marketRecovery,
      'blackSwan' => _WhyTodayHint.marketBlackSwan,
      'crash' => _WhyTodayHint.marketCrash,
      _ => _WhyTodayHint.marketBull,
    };
  }

  Widget _changeBox({required String label, required String value}) {
    final color = isPositive ? ThemeV2.success : ThemeV2.loss;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: interNums(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _factorBar(String label, double fraction, Color color) {
    final clamped = fraction.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 104,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: clamped),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            '${(clamped * 100).round()}%',
            textAlign: TextAlign.right,
            style: interNums(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
