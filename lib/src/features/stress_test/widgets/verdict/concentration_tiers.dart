// ---------------------------------------------------------------------------
// Concentration verdict tiers — 6 states keyed by the Strategy pillar's
// Concentration signal (`scores.concentration` in computeStrategySubScores,
// = 1 − the single largest HOLDING's %-of-cost-basis — one specific
// company, not a sector), shown on Session Complete's "CONCENTRATION"
// card ("More" -> VerdictMarkerDetailScreen). 5 tiers confirmed 2026-08-06,
// same 0-20/21-45/46-70/71-90/91-100 banding as Safety Marker/Sector
// Balance — no formula recalibration needed. The 6th ("no data") is the
// "0 holdings" edge case. Short intro-only copy for now.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Position Data Yet',
  intro:
      'This test ended without any positions — there\'s no concentration '
      'to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'One Company Holds Your Future',
  intro:
      'Your portfolio may contain several excellent investments—but one '
      'company stands far above the rest.\n\n'
      'A single position represents such a large portion of your '
      'invested capital that its success or failure will have a '
      'disproportionate impact on your entire portfolio.\n\n'
      'This is known as concentration risk.\n\n'
      'The company itself may be outstanding.\n\n'
      'It may be profitable, financially healthy, and a leader in its '
      'industry.\n\n'
      'But no business is immune to unexpected challenges.\n\n'
      'A disappointing earnings report.\n\n'
      'A major product delay.\n\n'
      'New competition.\n\n'
      'Regulatory changes.\n\n'
      'Economic uncertainty.\n\n'
      'Any of these events can cause even the strongest companies to '
      'lose significant value in a short period of time.\n\n'
      'When too much of your portfolio depends on one stock, you\'re no '
      'longer investing in a collection of businesses.\n\n'
      'You\'re placing a large part of your financial future on a '
      'single decision.\n\n'
      'Even legendary companies have experienced difficult years.\n\n'
      'History has repeatedly shown that today\'s market leader is not '
      'guaranteed to remain tomorrow\'s winner.\n\n'
      'Great businesses deserve confidence.\n\n'
      'They should never require blind faith.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'You don\'t need to sell your favorite company.\n\n'
          'If you truly believe in its long-term future, there\'s '
          'nothing wrong with making it one of your largest holdings.\n\n'
          'The key is making sure it isn\'t carrying your entire '
          'portfolio.\n\n'
          'As you continue investing, consider directing new money '
          'toward other high-quality businesses instead of adding even '
          'more to your largest position.\n\n'
          'Over time, your portfolio will naturally become more '
          'balanced while allowing your strongest conviction to remain '
          'an important part of your strategy.\n\n'
          'A diversified portfolio doesn\'t reduce your confidence.\n\n'
          'It reduces the consequences of being wrong.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Every great investor has favorite companies.\n\n'
          'The difference is that experienced investors rarely allow '
          'one stock to determine the outcome of their entire '
          'portfolio.\n\n'
          'Believe in great businesses—but never let a single company '
          'hold your financial future in its hands.',
    ),
  ],
);

const VerdictTier _tier21to45 = VerdictTier(
  title: 'Too Much Confidence in One Stock',
  intro:
      'Your portfolio is becoming more diversified, but one investment '
      'still represents a much larger share of your capital than the '
      'rest.\n\n'
      'This doesn\'t necessarily mean you\'ve chosen the wrong '
      'company.\n\n'
      'In fact, it may be one of the strongest businesses in your '
      'portfolio.\n\n'
      'The risk comes from relying too heavily on a single '
      'investment.\n\n'
      'No matter how successful a company appears today, every '
      'business will eventually face challenges.\n\n'
      'Markets change.\n\n'
      'Competition evolves.\n\n'
      'Consumer demand shifts.\n\n'
      'New technologies emerge.\n\n'
      'Even the world\'s most respected companies have experienced '
      'periods of disappointing performance.\n\n'
      'When one stock carries a large portion of your portfolio, those '
      'temporary setbacks can have an outsized effect on your overall '
      'results.\n\n'
      'That\'s why concentration risk is about position size—not '
      'company quality.\n\n'
      'A fantastic business can still become a risky investment if too '
      'much of your portfolio depends on it.\n\n'
      'Owning more shares of your favorite company doesn\'t always make '
      'your portfolio stronger.\n\n'
      'Sometimes it simply makes it less resilient.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'You don\'t need to reduce your confidence in your largest '
          'holding.\n\n'
          'Instead, allow the rest of your portfolio to catch up.\n\n'
          'As you make future investments, consider allocating new '
          'capital to other financially strong companies rather than '
          'continuing to increase your biggest position.\n\n'
          'This gradually improves your balance without forcing '
          'unnecessary sales.\n\n'
          'Over time, your portfolio becomes driven by the combined '
          'strength of many businesses instead of the performance of '
          'just one.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'It\'s perfectly reasonable to have a favorite company.\n\n'
          'Just don\'t let it become your entire investment strategy.\n\n'
          'The strongest portfolios aren\'t built around one '
          'exceptional business—they\'re built around many great '
          'businesses working together.',
    ),
  ],
);

const VerdictTier _tier46to70 = VerdictTier(
  title: 'A Portfolio Finding Its Balance',
  intro:
      'Your portfolio is moving toward a healthier balance.\n\n'
      'No single company completely dominates your investments, but '
      'one position still carries noticeably more weight than the '
      'others. While this isn\'t a major concern, it does mean that '
      'one business still has more influence over your long-term '
      'results than it probably should.\n\n'
      'This is a common stage for many investors.\n\n'
      'After all, when a company consistently delivers strong '
      'financial results, it\'s only natural to feel confident '
      'investing more money into it.\n\n'
      'Confidence is important.\n\n'
      'Overconfidence is where risk begins.\n\n'
      'Even exceptional businesses experience difficult periods.\n\n'
      'A change in leadership, slowing growth, increased competition, '
      'changing regulations, or an unexpected economic downturn can '
      'temporarily affect even the strongest companies.\n\n'
      'If one position grows too large, those setbacks become '
      'portfolio-wide events instead of ordinary fluctuations.\n\n'
      'Fortunately, your portfolio is already well on its way to '
      'avoiding that problem.\n\n'
      'A few thoughtful investments in other high-quality companies '
      'can make a significant difference without changing the overall '
      'strategy you\'ve built.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'There\'s no need to reduce your largest position simply '
          'because it\'s your largest.\n\n'
          'Instead, focus on creating better balance over time.\n\n'
          'As you continue investing, give slightly more attention to '
          'companies that currently represent a smaller part of your '
          'portfolio.\n\n'
          'Allow your future contributions—not emotional reactions—to '
          'shape your allocation.\n\n'
          'This approach keeps your investment strategy disciplined '
          'while naturally reducing concentration risk.\n\n'
          'Remember, every new investment is an opportunity to '
          'strengthen your portfolio—not just increase the size of '
          'your favorite holding.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Your goal isn\'t to find one company that carries your '
          'portfolio.\n\n'
          'It\'s to build a collection of outstanding businesses that '
          'succeed together.\n\n'
          'A portfolio becomes stronger when its success is shared '
          'across many companies—not concentrated in just one.',
    ),
  ],
);

const VerdictTier _tier71to90 = VerdictTier(
  title: 'Balanced Position Sizing',
  intro:
      'Your portfolio demonstrates a strong understanding of risk '
      'management.\n\n'
      'No single company has enough influence to determine the success '
      'or failure of your entire investment strategy. While some '
      'positions are naturally larger than others, your capital is '
      'distributed in a way that allows multiple businesses to '
      'contribute to your long-term results.\n\n'
      'This is an important milestone.\n\n'
      'Many investors spend years searching for the "perfect stock" '
      'and gradually allow one position to grow so large that it '
      'begins to dominate their portfolio.\n\n'
      'You have taken a different approach.\n\n'
      'Rather than depending on a single company to carry your future '
      'returns, you\'ve built a portfolio where success can come from '
      'multiple sources.\n\n'
      'That doesn\'t mean every company will perform equally well.\n\n'
      'Some will exceed expectations.\n\n'
      'Others may disappoint.\n\n'
      'That\'s perfectly normal.\n\n'
      'The strength of a balanced portfolio comes from knowing that a '
      'setback in one investment doesn\'t automatically become a '
      'setback for your entire financial plan.\n\n'
      'This gives your portfolio something every investor needs:\n\n'
      'Resilience.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'The most important thing now is maintaining the balance '
          'you\'ve already created.\n\n'
          'As your investments grow, keep an eye on positions that '
          'begin significantly outperforming the rest of the '
          'portfolio.\n\n'
          'Sometimes concentration risk develops slowly.\n\n'
          'A company performs exceptionally well, its share price '
          'rises for years, and before long it represents a much '
          'larger portion of the portfolio than originally intended.\n\n'
          'Regular reviews can help ensure that today\'s balanced '
          'portfolio remains balanced in the future.\n\n'
          'You don\'t need perfect equality between positions.\n\n'
          'You simply want to avoid allowing one company to gain too '
          'much control over your long-term outcome.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A great portfolio doesn\'t need a hero.\n\n'
          'It doesn\'t need one stock to save the day.\n\n'
          'Instead, it relies on the combined strength of many '
          'well-chosen businesses working together over time.\n\n'
          'When no single company can make or break your future, your '
          'portfolio becomes stronger, more stable, and better '
          'prepared for the unexpected.',
    ),
  ],
);

const VerdictTier _tier91to100 = VerdictTier(
  title: 'No Single Company Controls Your Success',
  intro:
      'Your portfolio reflects a disciplined and well-balanced approach '
      'to investing.\n\n'
      'No individual company has been allowed to dominate your '
      'investments. Instead of placing all your confidence in a single '
      'business, you\'ve spread your capital across multiple '
      'high-quality companies, allowing each one to contribute to your '
      'long-term success.\n\n'
      'This is one of the most effective ways to manage investment '
      'risk.\n\n'
      'No matter how successful a company appears today, its future is '
      'never guaranteed.\n\n'
      'Market leaders can lose their competitive edge.\n\n'
      'Industries evolve.\n\n'
      'Consumer preferences change.\n\n'
      'Unexpected events can challenge even the strongest '
      'businesses.\n\n'
      'By avoiding excessive concentration in any single position, '
      'you\'ve accepted one of the most important realities of '
      'investing:\n\n'
      'No company deserves complete control over your financial '
      'future.\n\n'
      'That\'s a mindset shared by many experienced long-term '
      'investors.\n\n'
      'They understand that building wealth isn\'t about finding one '
      'stock that changes everything.\n\n'
      'It\'s about owning a collection of outstanding businesses that '
      'work together through different market conditions and '
      'different stages of the economy.\n\n'
      'Your portfolio reflects that philosophy.\n\n'
      'Rather than relying on one company to produce extraordinary '
      'returns, you\'ve built a structure where success is shared '
      'across many carefully selected investments.',
  sections: [
    TierSection(
      label: 'Keep Protecting Your Balance',
      body:
          'As your portfolio continues to grow, remember that '
          'concentration risk can appear without making a single new '
          'purchase.\n\n'
          'A company that performs exceptionally well may naturally '
          'become a much larger position over time.\n\n'
          'Review your allocation occasionally and make sure your '
          'portfolio still reflects your original strategy.\n\n'
          'Often, simply directing new investments toward your smaller '
          'positions is enough to maintain a healthy balance.\n\n'
          'The goal isn\'t to keep every position identical.\n\n'
          'The goal is to ensure that no single investment becomes '
          'more important than the portfolio itself.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Every company tells part of your investment story.\n\n'
          'None of them should write the entire ending.\n\n'
          'The strongest portfolios aren\'t built around one brilliant '
          'investment—they\'re built around many great decisions '
          'working together over time.',
    ),
  ],
);

/// Picks the verdict tier for the Concentration score. [score] is
/// 0.0-1.0 (same convention as [VerdictArchiveEntry.strategyConcentration]);
/// [holdingCount] mirrors [VerdictArchiveEntry.holdingCount] — 0 means no
/// positions were ever opened.
VerdictTier concentrationTierFor(double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 45) return _tier21to45;
  if (pct <= 70) return _tier46to70;
  if (pct <= 90) return _tier71to90;
  return _tier91to100;
}
