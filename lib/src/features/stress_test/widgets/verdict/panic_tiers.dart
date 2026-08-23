// ---------------------------------------------------------------------------
// Panic verdict tiers — keyed by `entry.panicResistance` (evaluateSellTrade
// in psychology_engine.dart: a running behavioral score that only moves on
// SELL trades — starts at 50 neutral. +5 flat for realizing ANY profit
// (size doesn't matter — this scores behavior, not the trade's quality).
// 0 change for selling at breakeven. A realized loss is penalized by
// `severity = lossPct * 0.5 + bottomProximity * 0.5`, penalty = severity
// * 30 (max -30) — lossPct is the loss relative to cost basis,
// bottomProximity is how close the sale was to the symbol's LIFETIME low
// across the whole test, not just the current epoch. Separately, surviving
// a Black Swan/catastrophe epoch without selling into it gives a flat +15
// (see recordCatastropheSurvived in psychology_profile.dart) — a one-off
// per-epoch bonus, not tied to a specific trade. Discipline's pair marker:
// Discipline judges the BUY decision, Panic judges behavior under
// pressure on the SELL side — same even 20-point banding
// (0-20/21-40/41-60/61-80/81-100) as Discipline, confirmed 2026-08-07.
// Shown on Session Complete's own "PANIC" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicNoDataTitle,
  intro: l10n.verdictPanicNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicTier1Title,
  intro: l10n.verdictPanicTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictPanicTier1Section1Label,
      body: l10n.verdictPanicTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictPanicTier1Section2Label,
      body: l10n.verdictPanicTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to40(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicTier2Title,
  intro: l10n.verdictPanicTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictPanicTier2Section1Label,
      body: l10n.verdictPanicTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictPanicTier2Section2Label,
      body: l10n.verdictPanicTier2Section2Body,
    ),
  ],
);

VerdictTier _tier41to60(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicTier3Title,
  intro: l10n.verdictPanicTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictPanicTier3Section1Label,
      body: l10n.verdictPanicTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictPanicTier3Section2Label,
      body: l10n.verdictPanicTier3Section2Body,
    ),
  ],
);

VerdictTier _tier61to80(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicTier4Title,
  intro: l10n.verdictPanicTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictPanicTier4Section1Label,
      body: l10n.verdictPanicTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictPanicTier4Section2Label,
      body: l10n.verdictPanicTier4Section2Body,
    ),
  ],
);

VerdictTier _tier81to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPanicTier5Title,
  intro: l10n.verdictPanicTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictPanicTier5Section1Label,
      body: l10n.verdictPanicTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictPanicTier5Section2Label,
      body: l10n.verdictPanicTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for Panic. [score] is 0.0-1.0 (same convention
/// as [VerdictArchiveEntry.panicResistance]); [hasData] mirrors
/// [VerdictArchiveEntry.panicHasData] — false means the score never left
/// its neutral 50 default (panicResistance only moves on a sell or a
/// catastrophe event, not on buys, so a trade count alone can't tell).
VerdictTier panicTierFor(AppLocalizations l10n, double score, bool hasData) {
  if (!hasData) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 40) return _tier21to40(l10n);
  if (pct <= 60) return _tier41to60(l10n);
  if (pct <= 80) return _tier61to80(l10n);
  return _tier81to100(l10n);
}
