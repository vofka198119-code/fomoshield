import 'market_clock_engine.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// FOMO Shield Status — per-window risk metrics
// ---------------------------------------------------------------------------
// Feeds the "FOMO SHIELD STATUS" widget (market_clock_timing_widget.dart):
// 4 sub-metrics (Liquidity, Volatility, News Risk, F.O.M.O. Shield) per
// window, a per-WINDOW two-part explanation (not per-tier — each of the
// 9+3 windows gets its own text, same granularity as
// market_clock_engine.dart's whatHappens/dangerForBeginner), and a
// composite 0-100 risk score (with an optional manual override once the
// user supplies their own approximate number per window). The 3-tier label
// (LOW/MODERATE/HIGH/CLOSED) is still derived from the score and lives in
// market_clock_timing_widget.dart — only its COLOR/LABEL are tier-based
// now, not the explanation text. Kept in its own file so this
// widget-specific algorithm doesn't bloat the core time/phase engine.
//
// All windows now carry real, user-provided copy (source: ChatGPT-drafted,
// handed over one window per message, 2026-07-29) — no placeholder text
// remains.
// ---------------------------------------------------------------------------

class RiskMetrics {
  /// 0-100, higher = easier to get filled near the quoted price.
  final int liquidity;

  /// 0-100, higher = wider/faster price swings right now.
  final int volatility;

  /// 0-100, higher = more likely a headline moves price sharply this window.
  final int newsRisk;

  /// 0-100, higher = more protection this window naturally offers a
  /// beginner (was called "Beginner Safe" before the visual rename to
  /// match the widget's own "F.O.M.O. Shield" branding — same meaning).
  final int fomoShield;

  /// "Why Now?" — why conditions look like this right now. The widget
  /// shows a 3-line truncated preview of THIS field; the detail card
  /// (market_clock_risk_detail_screen.dart) shows it in full.
  final String whyNow;

  /// "What Should You Do?" — plain-language advice for this window. Only
  /// shown on the full detail card, not in the widget's preview.
  final String whatToDo;

  /// Manual override for [score], in case the user's own approximate
  /// per-window number doesn't match the formula below. `null` (the
  /// default for every window right now) means "use the computed score".
  final int? scoreOverride;

  const RiskMetrics({
    required this.liquidity,
    required this.volatility,
    required this.newsRisk,
    required this.fomoShield,
    required this.whyNow,
    required this.whatToDo,
    this.scoreOverride,
  });

  /// Composite 0-100 score — higher means riskier. Simple average of the
  /// four signals, inverting the two "good" ones (liquidity, fomoShield)
  /// so all four point the same direction (higher = worse). Overridden by
  /// [scoreOverride] when set.
  int get score =>
      scoreOverride ??
      (((100 - liquidity) + volatility + newsRisk + (100 - fomoShield)) / 4)
          .round();
}

enum RiskTier { low, moderate, high, closed }

extension MarketWindowRisk on MarketWindow {
  RiskMetrics riskMetricsFor(AppLocalizations l10n) {
    switch (id) {
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'early-pre-market':
        return RiskMetrics(
          liquidity: 20,
          volatility: 75,
          newsRisk: 40,
          fomoShield: 30,
          whyNow: l10n.marketClockRiskEarlyPreMarketWhyNow,
          whatToDo: l10n.marketClockRiskEarlyPreMarketWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'pre-market-reports':
        return RiskMetrics(
          liquidity: 55,
          volatility: 80,
          newsRisk: 90,
          fomoShield: 45,
          whyNow: l10n.marketClockRiskPreMarketReportsWhyNow,
          whatToDo: l10n.marketClockRiskPreMarketReportsWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'opening-bell':
        return RiskMetrics(
          liquidity: 100,
          volatility: 95,
          newsRisk: 75,
          fomoShield: 35,
          whyNow: l10n.marketClockRiskOpeningBellWhyNow,
          whatToDo: l10n.marketClockRiskOpeningBellWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'morning-session':
        return RiskMetrics(
          liquidity: 95,
          volatility: 35,
          newsRisk: 30,
          fomoShield: 95,
          whyNow: l10n.marketClockRiskMorningSessionWhyNow,
          whatToDo: l10n.marketClockRiskMorningSessionWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'lunch-hour':
        return RiskMetrics(
          liquidity: 65,
          volatility: 20,
          newsRisk: 15,
          fomoShield: 90,
          whyNow: l10n.marketClockRiskLunchHourWhyNow,
          whatToDo: l10n.marketClockRiskLunchHourWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted). Volatility/
      // News Risk are the "normal day" baseline — the user's source notes
      // they spike to ~90 on days with a major Fed announcement, but the
      // widget only shows one static number per window, so that nuance
      // lives in the text below instead of a second set of bar values.
      case 'mid-afternoon':
        return RiskMetrics(
          liquidity: 85,
          volatility: 45,
          newsRisk: 50,
          fomoShield: 80,
          whyNow: l10n.marketClockRiskMidAfternoonWhyNow,
          whatToDo: l10n.marketClockRiskMidAfternoonWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'power-hour':
        return RiskMetrics(
          liquidity: 100,
          volatility: 85,
          newsRisk: 40,
          fomoShield: 55,
          whyNow: l10n.marketClockRiskPowerHourWhyNow,
          whatToDo: l10n.marketClockRiskPowerHourWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'after-hours':
        return RiskMetrics(
          liquidity: 25,
          volatility: 90,
          newsRisk: 95,
          fomoShield: 25,
          whyNow: l10n.marketClockRiskAfterHoursWhyNow,
          whatToDo: l10n.marketClockRiskAfterHoursWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted). Source text
      // had 3 sections + a closing tip (Why/Risks/What to do/Tip) — merged
      // into this model's 2 fields rather than adding a 3rd field + tip
      // just for this one (rare, Black Friday/Christmas Eve-only) window:
      // Risks folded into whyNow, the closing Shield Tip appended to
      // whatToDo.
      case 'early-close-session':
        return RiskMetrics(
          liquidity: 70,
          volatility: 55,
          newsRisk: 25,
          fomoShield: 70,
          whyNow: l10n.marketClockRiskEarlyCloseSessionWhyNow,
          whatToDo: l10n.marketClockRiskEarlyCloseSessionWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted) — the
      // nightly closed window specifically (20:00-04:00 on a normal
      // trading day). Weekend/holiday get their own distinct copy below;
      // the user asked for different text for those, not the same one.
      case 'closed':
        return RiskMetrics(
          liquidity: 0,
          volatility: 0,
          newsRisk: 10,
          fomoShield: 100,
          whyNow: l10n.marketClockRiskClosedWhyNow,
          whatToDo: l10n.marketClockRiskClosedWhatToDo,
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted) — covers
      // both weekend-closed and market-holiday (user gave one shared text
      // for "Weekend / Market Holiday").
      default:
        return RiskMetrics(
          liquidity: 0,
          volatility: 0,
          newsRisk: 20,
          fomoShield: 100,
          whyNow: l10n.marketClockRiskWeekendHolidayWhyNow,
          whatToDo: l10n.marketClockRiskWeekendHolidayWhatToDo,
        );
    }
  }

  RiskTier riskTierFor(AppLocalizations l10n) {
    if (phase == MarketPhase.closed) return RiskTier.closed;
    final s = riskMetricsFor(l10n).score;
    if (s < 35) return RiskTier.low;
    if (s < 60) return RiskTier.moderate;
    return RiskTier.high;
  }
}
