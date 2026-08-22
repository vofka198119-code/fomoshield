// ---------------------------------------------------------------------------
// Concentration verdict tiers — 6 states keyed by the Strategy pillar's
// Concentration signal (`scores.concentration` in computeStrategySubScores,
// = 1 − the single largest HOLDING's %-of-cost-basis — one specific
// company, not a sector), shown on Session Complete's "CONCENTRATION"
// card ("More" -> VerdictMarkerDetailScreen). 5 tiers confirmed 2026-08-06,
// same 0-20/21-45/46-70/71-90/91-100 banding as Safety Marker/Sector
// Balance — no formula recalibration needed. The 6th ("no data") is the
// "0 holdings" edge case. Short intro-only copy for now.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationNoDataTitle,
  intro: l10n.verdictConcentrationNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationTier1Title,
  intro: l10n.verdictConcentrationTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictConcentrationTier1Section1Label,
      body: l10n.verdictConcentrationTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictConcentrationTier1Section2Label,
      body: l10n.verdictConcentrationTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to45(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationTier2Title,
  intro: l10n.verdictConcentrationTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictConcentrationTier2Section1Label,
      body: l10n.verdictConcentrationTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictConcentrationTier2Section2Label,
      body: l10n.verdictConcentrationTier2Section2Body,
    ),
  ],
);

VerdictTier _tier46to70(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationTier3Title,
  intro: l10n.verdictConcentrationTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictConcentrationTier3Section1Label,
      body: l10n.verdictConcentrationTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictConcentrationTier3Section2Label,
      body: l10n.verdictConcentrationTier3Section2Body,
    ),
  ],
);

VerdictTier _tier71to90(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationTier4Title,
  intro: l10n.verdictConcentrationTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictConcentrationTier4Section1Label,
      body: l10n.verdictConcentrationTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictConcentrationTier4Section2Label,
      body: l10n.verdictConcentrationTier4Section2Body,
    ),
  ],
);

VerdictTier _tier91to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictConcentrationTier5Title,
  intro: l10n.verdictConcentrationTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictConcentrationTier5Section1Label,
      body: l10n.verdictConcentrationTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictConcentrationTier5Section2Label,
      body: l10n.verdictConcentrationTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for the Concentration score. [score] is
/// 0.0-1.0 (same convention as [VerdictArchiveEntry.strategyConcentration]);
/// [holdingCount] mirrors [VerdictArchiveEntry.holdingCount] — 0 means no
/// positions were ever opened.
VerdictTier concentrationTierFor(AppLocalizations l10n, double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 45) return _tier21to45(l10n);
  if (pct <= 70) return _tier46to70(l10n);
  if (pct <= 90) return _tier71to90(l10n);
  return _tier91to100(l10n);
}
