// ---------------------------------------------------------------------------
// Safety Marker verdict tiers — 6 states keyed by the cost-basis-weighted
// average FS Score of every holding's FIRST purchase (see
// safetyMarkerFor()/entryFsScore in psychology_engine.dart), shown on the
// Session Complete screen's "SAFETY MARKER" card ("More" ->
// VerdictMarkerDetailScreen). 5 tiers confirmed 2026-08-06. The 6th
// ("no data") isn't part of that scale — it's the "no holding's FS Score
// ever resolved" edge case (empty portfolio, or the async fetch never
// landed before the test completed).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';
import '../../../../l10n/gen/app_localizations.dart';

VerdictTier _tierNoData(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerNoDataTitle,
  intro: l10n.verdictSafetyMarkerNoDataIntro,
);

VerdictTier _tier0to20(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerTier1Title,
  intro: l10n.verdictSafetyMarkerTier1Intro,
  sections: [
    TierSection(
      label: l10n.verdictSafetyMarkerTier1Section1Label,
      body: l10n.verdictSafetyMarkerTier1Section1Body,
    ),
    TierSection(
      label: l10n.verdictSafetyMarkerTier1Section2Label,
      body: l10n.verdictSafetyMarkerTier1Section2Body,
    ),
  ],
);

VerdictTier _tier21to45(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerTier2Title,
  intro: l10n.verdictSafetyMarkerTier2Intro,
  sections: [
    TierSection(
      label: l10n.verdictSafetyMarkerTier2Section1Label,
      body: l10n.verdictSafetyMarkerTier2Section1Body,
    ),
    TierSection(
      label: l10n.verdictSafetyMarkerTier2Section2Label,
      body: l10n.verdictSafetyMarkerTier2Section2Body,
    ),
  ],
);

VerdictTier _tier46to70(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerTier3Title,
  intro: l10n.verdictSafetyMarkerTier3Intro,
  sections: [
    TierSection(
      label: l10n.verdictSafetyMarkerTier3Section1Label,
      body: l10n.verdictSafetyMarkerTier3Section1Body,
    ),
    TierSection(
      label: l10n.verdictSafetyMarkerTier3Section2Label,
      body: l10n.verdictSafetyMarkerTier3Section2Body,
    ),
  ],
);

VerdictTier _tier71to90(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerTier4Title,
  intro: l10n.verdictSafetyMarkerTier4Intro,
  sections: [
    TierSection(
      label: l10n.verdictSafetyMarkerTier4Section1Label,
      body: l10n.verdictSafetyMarkerTier4Section1Body,
    ),
    TierSection(
      label: l10n.verdictSafetyMarkerTier4Section2Label,
      body: l10n.verdictSafetyMarkerTier4Section2Body,
    ),
  ],
);

VerdictTier _tier91to100(AppLocalizations l10n) => VerdictTier(
  title: l10n.verdictSafetyMarkerTier5Title,
  intro: l10n.verdictSafetyMarkerTier5Intro,
  sections: [
    TierSection(
      label: l10n.verdictSafetyMarkerTier5Section1Label,
      body: l10n.verdictSafetyMarkerTier5Section1Body,
    ),
    TierSection(
      label: l10n.verdictSafetyMarkerTier5Section2Label,
      body: l10n.verdictSafetyMarkerTier5Section2Body,
    ),
  ],
);

/// Picks the verdict tier for a Safety Marker score. [score] is 0.0-1.0
/// (same convention as [VerdictArchiveEntry.safetyMarker]); [hasData]
/// mirrors [VerdictArchiveEntry.safetyMarkerHasData].
VerdictTier safetyMarkerTierFor(AppLocalizations l10n, double score, bool hasData) {
  if (!hasData) return _tierNoData(l10n);
  final pct = score * 100;
  if (pct <= 20) return _tier0to20(l10n);
  if (pct <= 45) return _tier21to45(l10n);
  if (pct <= 70) return _tier46to70(l10n);
  if (pct <= 90) return _tier71to90(l10n);
  return _tier91to100(l10n);
}
