// ---------------------------------------------------------------------------
// Discipline verdict tiers — keyed by `entry.discipline` (evaluateBuyTrade
// in psychology_engine.dart: a running behavioral score that only moves on
// BUY trades — starts at 50 neutral, +15/+8 for buying fear/recovery,
// −20 for buying macro hype, +5 bonus for keeping a 10%+ cash cushion
// after a dip buy, −10 for chasing a positive sector/company pump on the
// specific stock. Never touched by sells or by portfolio state — unlike
// Strategy/ETF/Cash Buffer, which are recomputed fresh from current
// holdings). Even 20-point bands (0-20/21-40/41-60/61-80/81-100) — NOT
// the 0-20/21-45/46-70/71-90/91-100 banding used by Safety
// Marker/Concentration/Cash Buffer, confirmed 2026-08-07. Shown on Session
// Complete's own "DISCIPLINE" card ("?" -> VerdictMarkerDetailScreen).
// Short intro-only copy for now (scale given 2026-08-07, full long-form
// article to follow tier-by-tier same as the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineNoDataTitle,
  intro: l10n.verdictDisciplineNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineTier1Title,
  intro: l10n.verdictDisciplineTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictDisciplineTier1Section1Label,
      body: l10n.verdictDisciplineTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictDisciplineTier1Section2Label,
      body: l10n.verdictDisciplineTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to40(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineTier2Title,
  intro: l10n.verdictDisciplineTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictDisciplineTier2Section1Label,
      body: l10n.verdictDisciplineTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictDisciplineTier2Section2Label,
      body: l10n.verdictDisciplineTier2Section2Body,
    ),
  ],
);

VerdictTier _tier41to60(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineTier3Title,
  intro: l10n.verdictDisciplineTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictDisciplineTier3Section1Label,
      body: l10n.verdictDisciplineTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictDisciplineTier3Section2Label,
      body: l10n.verdictDisciplineTier3Section2Body,
    ),
  ],
);

VerdictTier _tier61to80(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineTier4Title,
  intro: l10n.verdictDisciplineTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictDisciplineTier4Section1Label,
      body: l10n.verdictDisciplineTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictDisciplineTier4Section2Label,
      body: l10n.verdictDisciplineTier4Section2Body,
    ),
  ],
);

VerdictTier _tier81to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictDisciplineTier5Title,
  intro: l10n.verdictDisciplineTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictDisciplineTier5Section1Label,
      body: l10n.verdictDisciplineTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictDisciplineTier5Section2Label,
      body: l10n.verdictDisciplineTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for Discipline. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.discipline]); [totalTrades] mirrors
/// [VerdictArchiveEntry.totalTrades] — 0 means no trade was ever made, so
/// the score never left its neutral 50 default.
VerdictTier disciplineTierFor(AppLocalizations l10n, double score, int totalTrades) {
  if (totalTrades <= 0) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 40) return _tier21to40(l10n);
  if (pct <= 60) return _tier41to60(l10n);
  if (pct <= 80) return _tier61to80(l10n);
  return _tier81to100(l10n);
}
