import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// News Scenario — localized text lookup
// ---------------------------------------------------------------------------
// news_event.dart's `newsScenarios` table stays English-only: it's read
// deep in the tick loop (noise_engine.dart), which never has a
// BuildContext to resolve AppLocalizations from (see project memory's
// "notification text has no BuildContext" note). Consumers that DO have
// real l10n access — the notifications screen/popup, the Why Diagnostics
// live-event row — resolve display text through here instead of reading
// NewsEvent.headline/description directly, keyed by the scenario's index
// in the `newsScenarios` list (NewsEvent.scenarioIndex).
// ---------------------------------------------------------------------------

String newsScenarioHeadline(AppLocalizations l10n, int index) {
  switch (index) {
    case 0:
      return l10n.newsScenario0Headline;
    case 1:
      return l10n.newsScenario1Headline;
    case 2:
      return l10n.newsScenario2Headline;
    case 3:
      return l10n.newsScenario3Headline;
    case 4:
      return l10n.newsScenario4Headline;
    case 5:
      return l10n.newsScenario5Headline;
    case 6:
      return l10n.newsScenario6Headline;
    case 7:
      return l10n.newsScenario7Headline;
    case 8:
      return l10n.newsScenario8Headline;
    case 9:
      return l10n.newsScenario9Headline;
    case 10:
      return l10n.newsScenario10Headline;
    case 11:
      return l10n.newsScenario11Headline;
    case 12:
      return l10n.newsScenario12Headline;
    case 13:
      return l10n.newsScenario13Headline;
    case 14:
      return l10n.newsScenario14Headline;
    case 15:
      return l10n.newsScenario15Headline;
    case 16:
      return l10n.newsScenario16Headline;
    case 17:
      return l10n.newsScenario17Headline;
    case 18:
      return l10n.newsScenario18Headline;
    case 19:
      return l10n.newsScenario19Headline;
    case 20:
      return l10n.newsScenario20Headline;
    case 21:
      return l10n.newsScenario21Headline;
    case 22:
      return l10n.newsScenario22Headline;
    case 23:
      return l10n.newsScenario23Headline;
    case 24:
      return l10n.newsScenario24Headline;
    default:
      return l10n.newsScenario0Headline;
  }
}

String newsScenarioDescription(AppLocalizations l10n, int index) {
  switch (index) {
    case 0:
      return l10n.newsScenario0Description;
    case 1:
      return l10n.newsScenario1Description;
    case 2:
      return l10n.newsScenario2Description;
    case 3:
      return l10n.newsScenario3Description;
    case 4:
      return l10n.newsScenario4Description;
    case 5:
      return l10n.newsScenario5Description;
    case 6:
      return l10n.newsScenario6Description;
    case 7:
      return l10n.newsScenario7Description;
    case 8:
      return l10n.newsScenario8Description;
    case 9:
      return l10n.newsScenario9Description;
    case 10:
      return l10n.newsScenario10Description;
    case 11:
      return l10n.newsScenario11Description;
    case 12:
      return l10n.newsScenario12Description;
    case 13:
      return l10n.newsScenario13Description;
    case 14:
      return l10n.newsScenario14Description;
    case 15:
      return l10n.newsScenario15Description;
    case 16:
      return l10n.newsScenario16Description;
    case 17:
      return l10n.newsScenario17Description;
    case 18:
      return l10n.newsScenario18Description;
    case 19:
      return l10n.newsScenario19Description;
    case 20:
      return l10n.newsScenario20Description;
    case 21:
      return l10n.newsScenario21Description;
    case 22:
      return l10n.newsScenario22Description;
    case 23:
      return l10n.newsScenario23Description;
    case 24:
      return l10n.newsScenario24Description;
    default:
      return l10n.newsScenario0Description;
  }
}
