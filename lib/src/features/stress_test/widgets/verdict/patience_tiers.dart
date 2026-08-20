// ---------------------------------------------------------------------------
// Patience verdict tiers — keyed by `entry.patience`. A running behavioral
// score, starts at 50 neutral, moves on only two triggers (see
// psychology_engine.dart's evaluateSellTrade and psychology_profile.dart's
// recordCatastropheSurvived/recordHeldThroughCatastrophe, called from
// trades_engine.dart / noise_engine.dart):
//   +5  any realized SELL profit, flat regardless of size (paired 1:1
//       with Panic's own +5 profit bonus — same event)
//   +30 total, one-off per catastrophe epoch: fires the instant a Black
//       Swan/catastrophe epoch begins IF the investor still holds
//       positions and hasn't sold anything yet this catastrophe — +10 via
//       recordCatastropheSurvived (alongside Panic's own +15) and +20 via
//       recordHeldThroughCatastrophe, both gated by the same
//       catastropheSurvivalRecorded flag so it can only fire once per
//       catastrophe, right at its start — not after it's over.
// Third of the 3 behavioral pillars: Discipline judges the buy, Panic
// judges the sell under pressure, Patience judges the ability to do
// nothing when doing nothing is the hardest choice. Same even 20-point
// banding (0-20/21-40/41-60/61-80/81-100) as Discipline/Panic, confirmed
// 2026-08-07. Shown on Session Complete's own "PATIENCE" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceNoDataTitle,
  intro: l10n.verdictPatienceNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceTier1Title,
  intro: l10n.verdictPatienceTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictPatienceTier1Section1Label,
      body: l10n.verdictPatienceTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictPatienceTier1Section2Label,
      body: l10n.verdictPatienceTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to40(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceTier2Title,
  intro: l10n.verdictPatienceTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictPatienceTier2Section1Label,
      body: l10n.verdictPatienceTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictPatienceTier2Section2Label,
      body: l10n.verdictPatienceTier2Section2Body,
    ),
  ],
);

VerdictTier _tier41to60(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceTier3Title,
  intro: l10n.verdictPatienceTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictPatienceTier3Section1Label,
      body: l10n.verdictPatienceTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictPatienceTier3Section2Label,
      body: l10n.verdictPatienceTier3Section2Body,
    ),
  ],
);

VerdictTier _tier61to80(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceTier4Title,
  intro: l10n.verdictPatienceTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictPatienceTier4Section1Label,
      body: l10n.verdictPatienceTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictPatienceTier4Section2Label,
      body: l10n.verdictPatienceTier4Section2Body,
    ),
  ],
);

VerdictTier _tier81to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictPatienceTier5Title,
  intro: l10n.verdictPatienceTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictPatienceTier5Section1Label,
      body: l10n.verdictPatienceTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictPatienceTier5Section2Label,
      body: l10n.verdictPatienceTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for Patience. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.patience]); [totalTrades] mirrors
/// [VerdictArchiveEntry.totalTrades] — 0 means no trade was ever made, so
/// the score never left its neutral 50 default.
VerdictTier patienceTierFor(AppLocalizations l10n, double score, int totalTrades) {
  if (totalTrades <= 0) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 40) return _tier21to40(l10n);
  if (pct <= 60) return _tier41to60(l10n);
  if (pct <= 80) return _tier61to80(l10n);
  return _tier81to100(l10n);
}
