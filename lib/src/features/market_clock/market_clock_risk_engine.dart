import 'market_clock_engine.dart';

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

  /// "Почему сейчас так?" — why conditions look like this right now.
  /// The widget shows a 3-line truncated preview of THIS field; the detail
  /// card (market_clock_risk_detail_screen.dart) shows it in full.
  final String whyNow;

  /// "Что лучше делать?" — plain-language advice for this window. Only
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
  RiskMetrics get riskMetrics {
    switch (id) {
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'early-pre-market':
        return const RiskMetrics(
          liquidity: 20,
          volatility: 75,
          newsRisk: 40,
          fomoShield: 30,
          whyNow:
              'The market has only just started to wake up. There are '
              'very few buyers and sellers, so even small trades can move '
              'prices much more than usual. Liquidity is low, spreads are '
              'wide, and prices may not reflect a company\'s true value.',
          whatToDo:
              'Unless you have a specific reason to trade, it\'s usually '
              'better to wait. Use this quiet time to review your '
              'watchlist, read company news, and prepare your plan for '
              'the day. If you must trade, always consider using a Limit '
              'Order instead of a Market Order.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'pre-market-reports':
        return const RiskMetrics(
          liquidity: 55,
          volatility: 80,
          newsRisk: 90,
          fomoShield: 45,
          whyNow:
              'Trading activity increases as more participants enter the '
              'market. This is also when many companies publish earnings '
              'reports and important U.S. economic data is released. '
              'Prices often react quickly and may continue changing as '
              'investors digest the news.',
          whatToDo:
              'Focus on understanding the news rather than reacting to '
              'it immediately. Review earnings reports, check the '
              'economic calendar, and see how the market responds before '
              'making a decision.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'opening-bell':
        return const RiskMetrics(
          liquidity: 100,
          volatility: 95,
          newsRisk: 75,
          fomoShield: 35,
          whyNow:
              'The regular trading session begins and millions of '
              'overnight orders are executed at once. Trading volume is '
              'extremely high, but so is volatility. The market is '
              'searching for a fair price after processing all the '
              'overnight information.',
          whatToDo:
              'For beginners, patience is often the best strategy. Give '
              'the market 20-30 minutes to settle before making planned '
              'long-term investments. Avoid making decisions based on '
              'the first sharp price movements.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'morning-session':
        return const RiskMetrics(
          liquidity: 95,
          volatility: 35,
          newsRisk: 30,
          fomoShield: 95,
          whyNow:
              'The early volatility has faded, liquidity remains high, '
              'and price movements become more stable. This is often one '
              'of the most balanced periods of the trading day.',
          whatToDo:
              'If you\'re investing for the long term, this is generally '
              'one of the best times to execute your planned purchases. '
              'Continue focusing on company fundamentals rather than '
              'short-term price fluctuations.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'lunch-hour':
        return const RiskMetrics(
          liquidity: 65,
          volatility: 20,
          newsRisk: 15,
          fomoShield: 90,
          whyNow:
              'Trading activity slows as many professional traders step '
              'away for lunch. Price movements become quieter and the '
              'market often moves sideways.',
          whatToDo:
              'This is a good time to research companies, review '
              'financial statements, or make planned long-term '
              'investments without feeling rushed. Don\'t trade simply '
              'because the market seems quiet.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted). Volatility/
      // News Risk are the "normal day" baseline — the user's source notes
      // they spike to ~90 on days with a major Fed announcement, but the
      // widget only shows one static number per window, so that nuance
      // lives in the text below instead of a second set of bar values.
      case 'mid-afternoon':
        return const RiskMetrics(
          liquidity: 85,
          volatility: 45,
          newsRisk: 50,
          fomoShield: 80,
          whyNow:
              'Activity picks up again as traders return. On certain '
              'days, Federal Reserve announcements or important economic '
              'reports can significantly increase volatility.',
          whatToDo:
              'Before placing a trade, check whether major economic '
              'events are scheduled. On normal days, this is another '
              'comfortable period for long-term investing. On Fed days, '
              'consider waiting until the market reacts.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'power-hour':
        return const RiskMetrics(
          liquidity: 100,
          volatility: 85,
          newsRisk: 40,
          fomoShield: 55,
          whyNow:
              'The final hour of trading is highly active as day traders '
              'close positions and investment funds rebalance '
              'portfolios. Strong price movements are common.',
          whatToDo:
              'Avoid chasing fast-moving prices. If you\'re making a '
              'planned investment, stick to your strategy rather than '
              'reacting to late-day excitement.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted).
      case 'after-hours':
        return const RiskMetrics(
          liquidity: 25,
          volatility: 90,
          newsRisk: 95,
          fomoShield: 25,
          whyNow:
              'Many companies release earnings after the market closes. '
              'At the same time, fewer traders are active, which can '
              'lead to large price swings and wider spreads.',
          whatToDo:
              'This is usually a better time to read earnings reports '
              'and analyze the news than to trade. Waiting until the '
              'next regular session often leads to calmer and more '
              'informed decisions.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted). Source text
      // had 3 sections + a closing tip (Why/Risks/What to do/Tip) — merged
      // into this model's 2 fields rather than adding a 3rd field + tip
      // just for this one (rare, Black Friday/Christmas Eve-only) window:
      // Risks folded into whyNow, the closing Shield Tip appended to
      // whatToDo.
      case 'early-close-session':
        return const RiskMetrics(
          liquidity: 70,
          volatility: 55,
          newsRisk: 25,
          fomoShield: 70,
          whyNow:
              'Today the U.S. stock market is operating on a shortened '
              'schedule.\n\n'
              'Many institutional investors, banks, and professional '
              'traders finish their work earlier than usual, so market '
              'activity gradually decreases as the day goes on. With '
              'fewer participants, some stocks may trade less actively, '
              'while others can experience unexpected price movements '
              'due to lower trading volume.\n\n'
              'The biggest risk is a false sense of calm. Although the '
              'market may appear quiet, lower participation means that '
              'even relatively small trades can have a greater impact on '
              'prices. Bid-ask spreads may widen, and price movements '
              'can become less predictable.\n\n'
              'Another important factor is that many investors prefer to '
              'reduce or close positions before a long holiday weekend '
              'to avoid holding risk while the market is closed. This '
              'can create additional selling pressure, even when there '
              'is no negative news about a company.',
          whatToDo:
              'If you\'re investing for the long term and your decision '
              'has already been made, a shortened trading day is not '
              'necessarily a reason to avoid investing.\n\n'
              'However, if your trade isn\'t time-sensitive, waiting '
              'until the next full trading session often provides '
              'better liquidity and more stable market conditions.\n\n'
              'Use the extra time to review your watchlist, read company '
              'reports, or practice in Stress Test.\n\n'
              'An early market close isn\'t a reason to rush your '
              'decisions. Sometimes the smartest move is simply to wait '
              'for the next full trading day, when the market returns to '
              'normal conditions.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted) — the
      // nightly closed window specifically (20:00-04:00 on a normal
      // trading day). Weekend/holiday get their own distinct copy below;
      // the user asked for different text for those, not the same one.
      case 'closed':
        return const RiskMetrics(
          liquidity: 0,
          volatility: 0,
          newsRisk: 10,
          fomoShield: 100,
          whyNow:
              'The market is closed and no trades are taking place. This '
              'is the perfect opportunity to step away from price '
              'movements and focus on learning.',
          whatToDo:
              'Review your portfolio, read company reports, and prepare '
              'your plan for the next trading day. You can also practice '
              'in Stress Test, where every trade is simulated and '
              'completely independent of the live market.',
        );
      // Real copy from the user, 2026-07-29 (ChatGPT-drafted) — covers
      // both weekend-closed and market-holiday (user gave one shared text
      // for "Weekend / Market Holiday").
      default:
        return const RiskMetrics(
          liquidity: 0,
          volatility: 0,
          newsRisk: 20,
          fomoShield: 100,
          whyNow:
              'The stock market is closed, but the world keeps moving. '
              'News, politics, and company announcements continue, even '
              'though no trading takes place.',
          whatToDo:
              'Take the opportunity to learn without pressure. Explore '
              'new companies, improve your investing knowledge, or '
              'practice in Stress Test. It\'s a safe environment where '
              'you can build confidence, develop discipline, and test '
              'ideas without risking real money.',
        );
    }
  }

  RiskTier get riskTier {
    if (phase == MarketPhase.closed) return RiskTier.closed;
    final s = riskMetrics.score;
    if (s < 35) return RiskTier.low;
    if (s < 60) return RiskTier.moderate;
    return RiskTier.high;
  }
}
