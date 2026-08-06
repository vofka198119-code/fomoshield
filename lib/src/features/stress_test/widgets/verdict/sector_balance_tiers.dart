// ---------------------------------------------------------------------------
// Sector Balance verdict tiers — 6 states keyed by the Sector Balance bar's
// own score (`scores.sector` in computeStrategySubScores, = 1 - largest
// GICS sector's % of cost basis), shown on the Session Complete screen's
// "SECTOR BALANCE" card ("More" -> VerdictMarkerDetailScreen). Distinct
// from Sector Diversification (which is actually keyed by holdings COUNT,
// see sector_diversification_tiers.dart) — this one is the real
// %-of-capital-in-one-sector signal. 5 tiers confirmed 2026-08-06, same
// 0-20/21-45/46-70/71-90/91-100 banding as Safety Marker — no formula
// recalibration needed, the existing (1 - maxSectorPct) score already
// lines up with these bands. The 6th ("no data") is the "0 holdings" edge
// case. Short intro-only copy for now — full long-form articles land
// later, same as the other markers.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Sector Data Yet',
  intro:
      'This test ended without any positions — there\'s no sector '
      'concentration to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'One Sector Rules Them All',
  intro:
      'Your portfolio may contain excellent companies—but they\'re all '
      'standing on the same foundation.\n\n'
      'A large portion of your investments is concentrated in a single '
      'sector of the economy, which means your portfolio\'s future '
      'depends heavily on the success of one industry.\n\n'
      'This is known as sector concentration risk.\n\n'
      'The companies themselves may be financially strong.\n\n'
      'Their management teams may be excellent.\n\n'
      'Their products may lead the market.\n\n'
      'But if the entire industry faces unexpected challenges, even '
      'outstanding businesses often decline together.\n\n'
      'History has shown this many times.\n\n'
      'Technology, banking, real estate, energy, biotechnology—every '
      'sector has experienced periods of rapid growth followed by years '
      'of disappointing performance.\n\n'
      'The strongest companies often survive.\n\n'
      'Their share prices don\'t always escape the downturn.\n\n'
      'Markets don\'t ask whether your companies are good.\n\n'
      'They often ask whether investors still want exposure to that '
      'entire industry.\n\n'
      'When confidence disappears, an entire sector can fall '
      'together—even when many of its businesses remain fundamentally '
      'healthy.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Try looking beyond your favorite industry.\n\n'
          'Instead of asking:\n\n'
          '"Which is the best company in this sector?"\n\n'
          'Also ask:\n\n'
          '"Which important parts of the economy am I completely '
          'ignoring?"\n\n'
          'Healthcare.\n'
          'Financial services.\n'
          'Industrials.\n'
          'Consumer businesses.\n'
          'Energy.\n'
          'Utilities.\n'
          'Communication services.\n\n'
          'Each sector responds differently to changing economic '
          'conditions.\n\n'
          'Owning businesses across multiple industries helps ensure '
          'that your portfolio isn\'t relying on a single economic '
          'story to succeed.\n\n'
          'Diversification across sectors doesn\'t eliminate risk.\n\n'
          'It prevents one industry from deciding the fate of your '
          'entire portfolio.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A great company can still be part of a risky portfolio.\n\n'
          'Not because the business is weak—\n\n'
          'but because too many of your investments depend on the same '
          'part of the economy.\n\n'
          'Don\'t put all your confidence into one industry. Build a '
          'portfolio that can continue moving forward even when one '
          'sector falls behind.',
    ),
  ],
);

const VerdictTier _tier21to45 = VerdictTier(
  title: 'Too Much Faith in One Industry',
  intro:
      'Your portfolio is beginning to diversify, but one sector still '
      'carries far more weight than the others.\n\n'
      'While you own companies from multiple industries, a significant '
      'portion of your capital remains concentrated in a single area of '
      'the economy. If that sector experiences a prolonged downturn, '
      'your entire portfolio could feel the impact far more than you '
      'might expect.\n\n'
      'This doesn\'t mean you\'ve chosen bad companies.\n\n'
      'In fact, many of them may be exceptional businesses.\n\n'
      'The challenge is that even excellent companies often move in the '
      'same direction when they belong to the same industry.\n\n'
      'Strong earnings, product launches, interest rates, government '
      'regulations, technological changes, or shifts in investor '
      'sentiment can affect an entire sector at once.\n\n'
      'When that happens, owning several companies from the same '
      'industry doesn\'t always provide the diversification investors '
      'hope for.\n\n'
      'Sometimes it simply means taking the same risk multiple times.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Your portfolio doesn\'t need a complete overhaul.\n\n'
          'It simply needs better balance.\n\n'
          'The next time you invest, consider adding a company from a '
          'sector that currently has a much smaller presence in your '
          'portfolio.\n\n'
          'Instead of strengthening your largest position even further, '
          'strengthen one of your weakest.\n\n'
          'Over time, these small decisions can create a portfolio that '
          'is more resilient to unexpected market changes.\n\n'
          'The goal isn\'t to avoid your favorite industry.\n\n'
          'The goal is to avoid depending on it.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'It\'s perfectly fine to have a favorite sector.\n\n'
          'Just don\'t let it become your entire investment strategy.\n\n'
          'The strongest portfolios aren\'t built around one successful '
          'industry. They\'re built around an economy that never stops '
          'changing.',
    ),
  ],
);

const VerdictTier _tier46to70 = VerdictTier(
  title: 'A Better Balance Is Within Reach',
  intro:
      'Your portfolio is moving in the right direction.\n\n'
      'You\'ve already spread your investments across several sectors '
      'of the economy, which is an important step toward reducing '
      'risk. However, one industry still represents a noticeably '
      'larger share of your portfolio than the others.\n\n'
      'This isn\'t a major problem—but it\'s an opportunity to '
      'improve.\n\n'
      'Markets don\'t move in perfect harmony.\n\n'
      'Different sectors respond differently to economic conditions, '
      'interest rates, inflation, technological change, and consumer '
      'demand. While one industry may struggle for months or even '
      'years, another may continue growing under the very same '
      'conditions.\n\n'
      'That\'s why balance matters.\n\n'
      'A portfolio doesn\'t become stronger by finding one perfect '
      'sector.\n\n'
      'It becomes stronger by giving several sectors the opportunity to '
      'contribute to your long-term success.\n\n'
      'At the moment, your portfolio still leans a little too heavily '
      'toward one part of the economy.\n\n'
      'Fortunately, you\'re much closer to excellent diversification '
      'than poor diversification.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'You don\'t need to sell your existing investments.\n\n'
          'Instead, let your future purchases gradually improve the '
          'balance.\n\n'
          'When adding new companies, give a little more attention to '
          'sectors that currently make up a smaller portion of your '
          'portfolio.\n\n'
          'Over time, your allocation will naturally become more '
          'balanced without forcing unnecessary trades or creating '
          'taxable events.\n\n'
          'Small adjustments made consistently are often more effective '
          'than dramatic changes made all at once.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Diversification isn\'t about making every sector exactly the '
          'same size.\n\n'
          'It\'s about making sure no single industry has too much '
          'control over your financial future.\n\n'
          'Your portfolio already has a solid foundation.\n\n'
          'A few thoughtful investments in underrepresented sectors '
          'could make it even stronger for whatever the market brings '
          'next.',
    ),
  ],
);

const VerdictTier _tier71to90 = VerdictTier(
  title: 'Balanced Across the Economy',
  intro:
      'Your portfolio demonstrates a healthy level of sector '
      'diversification.\n\n'
      'No single industry dominates your investments, allowing '
      'different parts of the economy to contribute to your long-term '
      'results. This balanced approach helps reduce the impact that '
      'any one sector can have on your overall portfolio.\n\n'
      'That\'s an important advantage.\n\n'
      'Markets move in cycles.\n\n'
      'Technology won\'t lead forever.\n\n'
      'Healthcare won\'t always outperform.\n\n'
      'Financials, industrials, consumer companies, energy, utilities, '
      'and other sectors each have periods of strength and periods of '
      'weakness.\n\n'
      'No one can consistently predict which industry will outperform '
      'next.\n\n'
      'Fortunately, your portfolio doesn\'t have to.\n\n'
      'By spreading your investments across multiple sectors, you\'ve '
      'built a portfolio that is prepared for different economic '
      'environments instead of relying on a single prediction.\n\n'
      'This is exactly how diversification is meant to work.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Continue maintaining the balance you\'ve already created.\n\n'
          'As your portfolio grows, avoid allowing one rapidly growing '
          'sector to gradually dominate your investments.\n\n'
          'A quick review of your sector allocation from time to time '
          'is often enough to keep your portfolio well balanced.\n\n'
          'Also remember that sector diversification is only one part '
          'of building a resilient portfolio.\n\n'
          'The quality of the businesses you own remains just as '
          'important as the industries they belong to.\n\n'
          'Strong companies spread across multiple sectors create a '
          'stronger portfolio than simply owning many different '
          'industries.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A balanced portfolio doesn\'t try to predict which sector '
          'will win next.\n\n'
          'It prepares for the possibility that any sector can have its '
          'moment.\n\n'
          'You can\'t control where the next market leader will come '
          'from—but you can build a portfolio that\'s ready when it '
          'happens.',
    ),
  ],
);

const VerdictTier _tier91to100 = VerdictTier(
  title: 'No Single Sector Controls Your Future',
  intro:
      'Your portfolio reflects a well-balanced investment strategy.\n\n'
      'No single sector dominates your holdings, which means your '
      'long-term success isn\'t tied to the performance of one '
      'industry. Instead, your investments are spread across different '
      'parts of the economy, allowing your portfolio to benefit from a '
      'wide range of businesses, products, and economic cycles.\n\n'
      'This is one of the strongest forms of risk management available '
      'to long-term investors.\n\n'
      'Different industries thrive under different conditions.\n\n'
      'Technology may lead during periods of innovation.\n\n'
      'Healthcare often remains resilient during uncertain markets.\n\n'
      'Industrials may benefit from economic expansion.\n\n'
      'Consumer companies, financial services, utilities, and energy '
      'each have their own opportunities and challenges throughout the '
      'market cycle.\n\n'
      'Rather than trying to predict which sector will become '
      'tomorrow\'s winner, you\'ve built a portfolio that is prepared '
      'for many different outcomes.\n\n'
      'That\'s exactly how long-term investing should work.\n\n'
      'Your portfolio doesn\'t rely on being right about a single '
      'industry.\n\n'
      'It relies on the strength of the broader economy.',
  sections: [
    TierSection(
      label: 'Keep Protecting Your Balance',
      body:
          'As your portfolio grows, continue monitoring your sector '
          'allocation from time to time.\n\n'
          'Sometimes a rapidly growing sector can naturally become much '
          'larger than the rest of your portfolio without you even '
          'noticing.\n\n'
          'Maintaining balance doesn\'t require frequent trading.\n\n'
          'Often, simply directing new investments toward '
          'underrepresented sectors is enough to keep your portfolio '
          'well diversified.\n\n'
          'Remember, diversification isn\'t a one-time decision.\n\n'
          'It\'s an ongoing habit.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The future rarely rewards only one industry.\n\n'
          'Innovation shifts.\n\n'
          'Economic cycles change.\n\n'
          'New leaders emerge while yesterday\'s leaders slow down.\n\n'
          'You don\'t need to know which sector will outperform '
          'next.\n\n'
          'You\'ve built a portfolio that doesn\'t depend on a single '
          'answer.\n\n'
          'The strongest portfolios don\'t bet on one part of the '
          'economy. They grow alongside the economy itself.',
    ),
  ],
);

/// Picks the verdict tier for the Sector Balance score. [score] is
/// 0.0-1.0 (same convention as [VerdictArchiveEntry.strategySector]);
/// [holdingCount] mirrors [VerdictArchiveEntry.holdingCount] — 0 means
/// no positions were ever opened.
VerdictTier sectorBalanceTierFor(double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 45) return _tier21to45;
  if (pct <= 70) return _tier46to70;
  if (pct <= 90) return _tier71to90;
  return _tier91to100;
}
