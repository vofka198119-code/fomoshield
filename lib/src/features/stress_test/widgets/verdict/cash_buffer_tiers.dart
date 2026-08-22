// ---------------------------------------------------------------------------
// Cash Buffer verdict tiers — keyed by `entry.strategyCashBuffer`
// (computeStrategySubScores in psychology_engine.dart: cash % of total
// portfolio value, linear 0% → score 0 up to 10%+ → score 100, no penalty
// for holding more). Formula deliberately left unchanged — see 2026-08-07
// discussion: this measures an investor's readiness for opportunities /
// resilience to panic-selling, not "idle cash is bad." A cash position
// above 10% is explicitly NOT penalized further (could be saving for a
// house, pre-crash reserve, between investments, etc — the app can't see
// that context). Same 0-20/21-45/46-70/71-90/91-100 banding as Safety
// Marker/Concentration. Shown on Session Complete's "STRATEGY" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferNoDataTitle,
  intro: l10n.verdictCashBufferNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferTier1Title,
  intro: l10n.verdictCashBufferTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictCashBufferTier1Section1Label,
      body: l10n.verdictCashBufferTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictCashBufferTier1Section2Label,
      body: l10n.verdictCashBufferTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to45(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferTier2Title,
  intro: l10n.verdictCashBufferTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictCashBufferTier2Section1Label,
      body: l10n.verdictCashBufferTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictCashBufferTier2Section2Label,
      body: l10n.verdictCashBufferTier2Section2Body,
    ),
  ],
);

VerdictTier _tier46to70(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferTier3Title,
  intro: l10n.verdictCashBufferTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictCashBufferTier3Section1Label,
      body: l10n.verdictCashBufferTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictCashBufferTier3Section2Label,
      body: l10n.verdictCashBufferTier3Section2Body,
    ),
  ],
);

VerdictTier _tier71to90(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferTier4Title,
  intro: l10n.verdictCashBufferTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictCashBufferTier4Section1Label,
      body: l10n.verdictCashBufferTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictCashBufferTier4Section2Label,
      body: l10n.verdictCashBufferTier4Section2Body,
    ),
  ],
);

VerdictTier _tier91to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictCashBufferTier5Title,
  intro: l10n.verdictCashBufferTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictCashBufferTier5Section1Label,
      body: l10n.verdictCashBufferTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictCashBufferTier5Section2Label,
      body: l10n.verdictCashBufferTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for Cash Buffer. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.strategyCashBuffer]); [holdingCount]
/// mirrors [VerdictArchiveEntry.holdingCount] — 0 means no positions were
/// ever opened.
VerdictTier cashBufferTierFor(AppLocalizations l10n, double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 45) return _tier21to45(l10n);
  if (pct <= 70) return _tier46to70(l10n);
  if (pct <= 90) return _tier71to90(l10n);
  return _tier91to100(l10n);
}
