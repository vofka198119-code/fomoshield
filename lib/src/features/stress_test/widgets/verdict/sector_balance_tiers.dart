// ---------------------------------------------------------------------------
// Sector Balance verdict tiers — 6 states keyed by the Sector Balance bar's
// own score (`scores.sector` in computeStrategySubScores, = 1 - largest
// GICS sector's % of cost basis), shown on the Session Complete screen's
// "SECTOR BALANCE" card ("More" -> VerdictMarkerDetailScreen). Distinct
// from Sector Diversification (which is actually keyed by holdings COUNT,
// see sector_diversification_tiers.dart) — this one is the real
// %-of-capital-in-one-sector signal. 5 tiers confirmed 2026-08-06, same
// 0-20/21-45/46-70/71-90/91-100 banding as Safety Marker — no formula
// recalibration needed, the existing (1 - maxSectorPct) score already
// lines up with these bands. The 6th ("no data") is the "0 holdings" edge
// case. Short intro-only copy for now — full long-form articles land
// later, same as the other markers.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceNoDataTitle,
  intro: l10n.verdictSectorBalanceNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceTier1Title,
  intro: l10n.verdictSectorBalanceTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorBalanceTier1Section1Label,
      body: l10n.verdictSectorBalanceTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorBalanceTier1Section2Label,
      body: l10n.verdictSectorBalanceTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to45(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceTier2Title,
  intro: l10n.verdictSectorBalanceTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorBalanceTier2Section1Label,
      body: l10n.verdictSectorBalanceTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorBalanceTier2Section2Label,
      body: l10n.verdictSectorBalanceTier2Section2Body,
    ),
  ],
);

VerdictTier _tier46to70(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceTier3Title,
  intro: l10n.verdictSectorBalanceTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorBalanceTier3Section1Label,
      body: l10n.verdictSectorBalanceTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorBalanceTier3Section2Label,
      body: l10n.verdictSectorBalanceTier3Section2Body,
    ),
  ],
);

VerdictTier _tier71to90(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceTier4Title,
  intro: l10n.verdictSectorBalanceTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorBalanceTier4Section1Label,
      body: l10n.verdictSectorBalanceTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorBalanceTier4Section2Label,
      body: l10n.verdictSectorBalanceTier4Section2Body,
    ),
  ],
);

VerdictTier _tier91to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorBalanceTier5Title,
  intro: l10n.verdictSectorBalanceTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorBalanceTier5Section1Label,
      body: l10n.verdictSectorBalanceTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorBalanceTier5Section2Label,
      body: l10n.verdictSectorBalanceTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for the Sector Balance score. [score] is
/// 0.0-1.0 (same convention as [VerdictArchiveEntry.strategySector]);
/// [holdingCount] mirrors [VerdictArchiveEntry.holdingCount] — 0 means
/// no positions were ever opened.
VerdictTier sectorBalanceTierFor(AppLocalizations l10n, double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 45) return _tier21to45(l10n);
  if (pct <= 70) return _tier46to70(l10n);
  if (pct <= 90) return _tier71to90(l10n);
  return _tier91to100(l10n);
}
