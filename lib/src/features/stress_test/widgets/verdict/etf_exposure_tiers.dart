// ---------------------------------------------------------------------------
// ETF Exposure verdict tiers — keyed by the COUNT of distinct ETFs held
// (`etfExposureScoreForCount` in psychology_engine.dart), not their % of
// portfolio value — 2-3 is the ideal, more starts overlapping/duplicating.
// Shown on Session Complete's "STRATEGY" card ("?" -> VerdictMarkerDetailScreen).
// Short intro-only copy for now (scale given 2026-08-07, full long-form
// article to follow tier-by-tier same as the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureNoDataTitle,
  intro: l10n.verdictEtfExposureNoDataIntro,
);

VerdictTier _tier0(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureTier1Title,
  intro: l10n.verdictEtfExposureTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictEtfExposureTier1Section1Label,
      body: l10n.verdictEtfExposureTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictEtfExposureTier1Section2Label,
      body: l10n.verdictEtfExposureTier1Section2Body,
    ),
  ],
);

VerdictTier _tier1(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureTier2Title,
  intro: l10n.verdictEtfExposureTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictEtfExposureTier2Section1Label,
      body: l10n.verdictEtfExposureTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictEtfExposureTier2Section2Label,
      body: l10n.verdictEtfExposureTier2Section2Body,
    ),
  ],
);

VerdictTier _tier2to3(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureTier3Title,
  intro: l10n.verdictEtfExposureTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictEtfExposureTier3Section1Label,
      body: l10n.verdictEtfExposureTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictEtfExposureTier3Section2Label,
      body: l10n.verdictEtfExposureTier3Section2Body,
    ),
  ],
);

VerdictTier _tier4to6(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureTier4Title,
  intro: l10n.verdictEtfExposureTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictEtfExposureTier4Section1Label,
      body: l10n.verdictEtfExposureTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictEtfExposureTier4Section2Label,
      body: l10n.verdictEtfExposureTier4Section2Body,
    ),
  ],
);

VerdictTier _tier7plus(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictEtfExposureTier5Title,
  intro: l10n.verdictEtfExposureTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictEtfExposureTier5Section1Label,
      body: l10n.verdictEtfExposureTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictEtfExposureTier5Section2Label,
      body: l10n.verdictEtfExposureTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for ETF Exposure. [score] is the 0.0-1.0 value
/// produced by `etfExposureScoreForCount` (same convention as
/// [VerdictArchiveEntry.strategyEtf]); [holdingCount] mirrors
/// [VerdictArchiveEntry.holdingCount] — 0 means no positions were ever
/// opened. `etfExposureScoreForCount` only ever emits 5 fixed values
/// (10/35/95/85/70, one per count bucket) — match on those directly
/// rather than a range, so this stays exact if the curve is ever retuned.
VerdictTier etfExposureTierFor(AppLocalizations l10n, double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData(l10n);
  final pct = (score * 100).round();
  switch (pct) {
    case 10:
      return _tier0(l10n);
    case 35:
      return _tier1(l10n);
    case 85:
      return _tier4to6(l10n);
    case 70:
      return _tier7plus(l10n);
    default:
      return _tier2to3(l10n);
  }
}
