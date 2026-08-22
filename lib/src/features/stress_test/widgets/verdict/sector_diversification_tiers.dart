// ---------------------------------------------------------------------------
// Sector Diversification verdict tiers — 6 states keyed by final holdings
// count, shown on the Session Complete screen's "SECTOR DIVERSIFICATION"
// card ("More" -> VerdictMarkerDetailScreen). 5 tiers match the boundaries
// tuned into psychology_engine.dart's diversificationStops (Count Balance
// bar on the Psychology Meter's Diversification widget) — keep both in
// sync if the ranges ever change. The 6th (0 holdings) isn't part of that
// table; it's the "test ended with no purchases" edge case.
//
// Layout template for the long-form copy is market_period_detail_screen.dart
// (Market Clock's phase detail screen, e.g. Pre-Market): title, flowing
// intro paragraphs, then labeled sub-sections (caps brand-color label +
// body) for things like "How can you improve?" / "One last thought". Only
// tier 1 has full copy so far — the rest still carry their short one-line
// placeholder as `intro` with no sections, filled in one at a time.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierEmpty(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationNoDataTitle,
  intro: l10n.verdictSectorDiversificationNoDataIntro,
);

VerdictTier _tier1to2(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationTier1Title,
  intro: l10n.verdictSectorDiversificationTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorDiversificationTier1Section1Label,
      body: l10n.verdictSectorDiversificationTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier1Section2Label,
      body: l10n.verdictSectorDiversificationTier1Section2Body,
    ),
  ],
);

VerdictTier _tier3to4(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationTier2Title,
  intro: l10n.verdictSectorDiversificationTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorDiversificationTier2Section1Label,
      body: l10n.verdictSectorDiversificationTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier2Section2Label,
      body: l10n.verdictSectorDiversificationTier2Section2Body,
    ),
  ],
);

VerdictTier _tier5to15(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationTier3Title,
  intro: l10n.verdictSectorDiversificationTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorDiversificationTier3Section1Label,
      body: l10n.verdictSectorDiversificationTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier3Section2Label,
      body: l10n.verdictSectorDiversificationTier3Section2Body,
    ),
  ],
);

VerdictTier _tier16to24(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationTier4Title,
  intro: l10n.verdictSectorDiversificationTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorDiversificationTier4Section1Label,
      body: l10n.verdictSectorDiversificationTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier4Section2Label,
      body: l10n.verdictSectorDiversificationTier4Section2Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier4Section3Label,
      body: l10n.verdictSectorDiversificationTier4Section3Body,
    ),
  ],
);

VerdictTier _tier25plus(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSectorDiversificationTier5Title,
  intro: l10n.verdictSectorDiversificationTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictSectorDiversificationTier5Section1Label,
      body: l10n.verdictSectorDiversificationTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier5Section2Label,
      body: l10n.verdictSectorDiversificationTier5Section2Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier5Section3Label,
      body: l10n.verdictSectorDiversificationTier5Section3Body,
    ),
    TierSection(
      label: l10n.verdictSectorDiversificationTier5Section4Label,
      body: l10n.verdictSectorDiversificationTier5Section4Body,
    ),
  ],
);

/// Picks the verdict tier for a final holdings count.
VerdictTier diversificationTierForCount(AppLocalizations l10n, int holdingCount) {
  if (holdingCount <= 0) return _tierEmpty(l10n);
  if (holdingCount <= 2) return _tier1to2(l10n);
  if (holdingCount <= 4) return _tier3to4(l10n);
  if (holdingCount <= 15) return _tier5to15(l10n);
  if (holdingCount <= 24) return _tier16to24(l10n);
  return _tier25plus(l10n);
}
