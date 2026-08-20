// ---------------------------------------------------------------------------
// Verdict Marker Detail Screen — full praise/mistake breakdown for a single
// Psychology Meter marker (Discipline, Panic, Patience, Strategy,
// Diversification), reached via "More" on that marker's VerdictMarkerCard
// on the Session Complete screen. One generic screen keyed by markerId,
// same pattern as MetricInfoScreen's /metric-info/:id.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'stress_test_engine.dart';
import 'stress_test_models.dart';
import 'widgets/verdict/sector_diversification_tiers.dart';
import 'widgets/verdict/safety_marker_tiers.dart';
import 'widgets/verdict/sector_balance_tiers.dart';
import 'widgets/verdict/concentration_tiers.dart';
import 'widgets/verdict/etf_exposure_tiers.dart';
import 'widgets/verdict/cash_buffer_tiers.dart';
import 'widgets/verdict/discipline_tiers.dart';
import 'widgets/verdict/panic_tiers.dart';
import 'widgets/verdict/patience_tiers.dart';
import 'widgets/verdict/verdict_tier.dart';
import 'widgets/verdict/stress_test_verdict_disclaimer.dart';

class _MarkerInfo {
  final String label;
  final double Function(VerdictArchiveEntry) score;
  const _MarkerInfo(this.label, this.score);
}

const Map<String, _MarkerInfo> _markers = {
  'discipline': _MarkerInfo('Discipline', _disciplineScore),
  'panic': _MarkerInfo('Panic', _panicScore),
  'patience': _MarkerInfo('Patience', _patienceScore),
  'sector-diversification': _MarkerInfo(
    'Sector Diversification',
    _sectorDiversificationScore,
  ),
  'safety-marker': _MarkerInfo('Safety Marker', _safetyMarkerScore),
  'sector-balance': _MarkerInfo('Sector Balance', _sectorBalanceScore),
  'concentration': _MarkerInfo('Concentration', _concentrationScore),
  'etf-exposure': _MarkerInfo('ETF Exposure', _etfExposureScore),
  'cash-buffer': _MarkerInfo('Cash Buffer', _cashBufferScore),
};

double _disciplineScore(VerdictArchiveEntry e) => e.discipline;
double _panicScore(VerdictArchiveEntry e) => e.panicResistance;
double _patienceScore(VerdictArchiveEntry e) => e.patience;
double _sectorDiversificationScore(VerdictArchiveEntry e) =>
    e.strategyDiversification;
double _safetyMarkerScore(VerdictArchiveEntry e) => e.safetyMarker;
double _sectorBalanceScore(VerdictArchiveEntry e) => e.strategySector;
double _concentrationScore(VerdictArchiveEntry e) => e.strategyConcentration;
double _etfExposureScore(VerdictArchiveEntry e) => e.strategyEtf;
double _cashBufferScore(VerdictArchiveEntry e) => e.strategyCashBuffer;

/// Picks the long-form tier content for markers that have one — null for
/// markers still on the generic threshold-based placeholder.
VerdictTier? _tierFor(
  AppLocalizations l10n,
  String markerId,
  VerdictArchiveEntry entry,
) {
  switch (markerId) {
    case 'sector-diversification':
      return diversificationTierForCount(l10n, entry.holdingCount);
    case 'safety-marker':
      return safetyMarkerTierFor(
        l10n,
        entry.safetyMarker,
        entry.safetyMarkerHasData,
      );
    case 'sector-balance':
      return sectorBalanceTierFor(l10n, entry.strategySector, entry.holdingCount);
    case 'concentration':
      return concentrationTierFor(
        l10n,
        entry.strategyConcentration,
        entry.holdingCount,
      );
    case 'etf-exposure':
      return etfExposureTierFor(l10n, entry.strategyEtf, entry.holdingCount);
    case 'cash-buffer':
      return cashBufferTierFor(
        l10n,
        entry.strategyCashBuffer,
        entry.holdingCount,
      );
    case 'discipline':
      return disciplineTierFor(l10n, entry.discipline, entry.totalTrades);
    case 'panic':
      return panicTierFor(l10n, entry.panicResistance, entry.totalTrades);
    case 'patience':
      return patienceTierFor(l10n, entry.patience, entry.totalTrades);
    default:
      return null;
  }
}

class VerdictMarkerDetailScreen extends ConsumerWidget {
  final String sessionId;
  final String markerId;

  const VerdictMarkerDetailScreen({
    super.key,
    required this.sessionId,
    required this.markerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final archive = ref.watch(verdictArchiveProvider);
    final entry = archive.cast<VerdictArchiveEntry?>().firstWhere(
      (e) => e?.sessionId == sessionId,
      orElse: () => null,
    );
    final marker = _markers[markerId];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          (marker?.label ?? 'Verdict').toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: (entry == null || marker == null)
            ? Center(child: Text(l10n.verdictMarkerNotAvailable))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _MarkerDetailBody(
                  label: marker.label,
                  score: marker.score(entry),
                  tier: _tierFor(l10n, markerId, entry),
                ),
              ),
      ),
    );
  }
}

class _MarkerDetailBody extends StatelessWidget {
  final String label;
  final double score; // 0.0-1.0
  final VerdictTier? tier;

  const _MarkerDetailBody({
    required this.label,
    required this.score,
    this.tier,
  });

  Color get _color {
    if (score >= 0.7) return ThemeV2.success;
    if (score >= 0.4) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = (score * 100).clamp(0.0, 100.0);
    final color = _color;

    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: FomoShieldTheme.card,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 3),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percent.round()}',
                  style: interNums(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    l10n.companyDetailFsScoreLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (tier != null)
          _TierArticle(tier: tier!, accentColor: color)
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: FomoShieldTheme.cardDecoration,
            child: Text(
              l10n.verdictMarkerFeedbackComingSoon(label),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: ThemeV2.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        const StressTestVerdictDisclaimer(),
      ],
    );
  }
}

/// Long-form tier copy — same visual template as
/// market_period_detail_screen.dart's phase detail page: a bold title,
/// flowing intro paragraphs, then labeled sub-sections (caps brand-color
/// label + body) for things like "How can you improve?".
class _TierArticle extends StatelessWidget {
  final VerdictTier tier;
  final Color accentColor;

  const _TierArticle({required this.tier, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tier.title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: accentColor,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          tier.intro,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: ThemeV2.textPrimary,
            height: 1.6,
          ),
        ),
        for (final section in tier.sections) ...[
          const SizedBox(height: 20),
          Text(
            section.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}
