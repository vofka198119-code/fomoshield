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

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Safety Data Yet',
  intro:
      'This test doesn\'t have enough data to score the quality of what '
      'was bought — either no positions were opened, or the fundamentals '
      'for those companies hadn\'t finished loading before the test '
      'ended.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'Building on Hopes, Not Businesses',
  intro:
      'Your portfolio shows a clear pattern: many of your investments '
      'are based more on future expectations than on the strength of '
      'the businesses themselves.\n\n'
      'Every company begins with an idea. Some of those ideas grow into '
      'world-changing businesses. Others never become profitable at '
      'all.\n\n'
      'The challenge is that the stock market often rewards exciting '
      'stories long before those stories become successful '
      'businesses.\n\n'
      'Companies with little or no profit, weak financial health, '
      'declining revenue, excessive debt, or business models that have '
      'yet to prove themselves can experience dramatic price swings. '
      'They may occasionally deliver extraordinary returns—but they '
      'also carry a much higher risk of permanent losses.\n\n'
      'Owning several of these companies at the same time doesn\'t '
      'reduce that risk. It simply spreads your money across multiple '
      'uncertain outcomes.\n\n'
      'This is especially common with highly speculative industries '
      'such as early-stage biotechnology, pre-revenue technology '
      'companies, space exploration startups, meme stocks, and '
      'businesses whose valuations depend primarily on future '
      'expectations rather than current performance.\n\n'
      'There\'s nothing wrong with believing in innovation.\n\n'
      'Many of today\'s largest companies once started as ambitious '
      'ideas.\n\n'
      'The difference is that successful long-term investors don\'t buy '
      'a company simply because its story sounds exciting. They look '
      'for evidence that the business is becoming stronger over '
      'time.\n\n'
      'Growing revenue.\n'
      'Healthy profit margins.\n'
      'Reasonable debt.\n'
      'Positive cash flow.\n'
      'Consistent execution.\n\n'
      'These fundamentals often matter far more than headlines or '
      'social media excitement.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before buying a company, try asking yourself a few simple '
          'questions.\n\n'
          'Is this company already generating sustainable profits?\n'
          'Does its business continue to grow year after year?\n'
          'Can it survive difficult economic conditions?\n'
          'Am I investing because I understand the business—or because '
          'I hope the future will be extraordinary?\n\n'
          'Sometimes the most exciting investment isn\'t the strongest '
          'one.\n\n'
          'And sometimes the strongest business isn\'t the one making '
          'the loudest headlines.\n\n'
          'You don\'t have to avoid higher-risk companies completely.\n\n'
          'However, they should represent only a small portion of a '
          'portfolio built on stable, financially healthy businesses.\n\n'
          'Strong foundations allow great ideas to become '
          'opportunities—not unnecessary risks.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Innovation creates possibilities.\n\n'
          'Strong businesses create long-term wealth.\n\n'
          'The most successful investors learn to tell the '
          'difference.\n\n'
          'Don\'t invest only in what could become great. Invest in '
          'companies that are already proving they can succeed.',
    ),
  ],
);

const VerdictTier _tier21to45 = VerdictTier(
  title: 'High Risk, High Expectations',
  intro:
      'Your portfolio shows a mix of promising businesses and highly '
      'speculative investments.\n\n'
      'You\'ve started looking beyond headlines, but many of your '
      'decisions still place a great deal of trust in what a company '
      'might become rather than what it has already achieved.\n\n'
      'There is nothing wrong with investing in future potential.\n\n'
      'Every successful company was once an ambitious idea.\n\n'
      'The challenge is that not every ambitious idea becomes a '
      'successful business.\n\n'
      'Many companies spend years chasing profitability. Some never '
      'reach it. Others rely heavily on debt, repeatedly issue new '
      'shares to raise capital, or continue operating without '
      'generating sustainable cash flow. While a small number '
      'eventually become market leaders, many fail long before reaching '
      'that point.\n\n'
      'As an investor, your goal isn\'t to predict every future success '
      'story.\n\n'
      'Your goal is to improve the odds that the businesses you own can '
      'survive long enough to become one.\n\n'
      'At the moment, your portfolio still leans more toward optimism '
      'than financial strength.\n\n'
      'That doesn\'t make it a bad portfolio—but it does make it a '
      'riskier one.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'When evaluating a company, try spending less time asking:\n\n'
          '"How much could this stock go up?"\n\n'
          'And more time asking:\n\n'
          'Is the company consistently profitable?\n'
          'Is revenue growing because the business is improving—not '
          'simply because of temporary excitement?\n'
          'Can the company support itself without constantly raising '
          'new capital?\n'
          'Does management have a proven record of delivering '
          'results?\n\n'
          'Sometimes the strongest investments don\'t look exciting at '
          'first.\n\n'
          'They quietly build profits, strengthen their balance sheets, '
          'and reward patient investors over many years.\n\n'
          'You don\'t need to eliminate every speculative company from '
          'your portfolio.\n\n'
          'Just make sure they\'re the exception—not the foundation.\n\n'
          'Let financially healthy businesses carry the weight of your '
          'portfolio, while higher-risk ideas remain carefully '
          'controlled opportunities.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Hope can be part of an investment.\n\n'
          'It should never be the entire investment strategy.\n\n'
          'The strongest portfolios aren\'t built on the companies with '
          'the biggest promises—they\'re built on the companies that '
          'consistently deliver on them.',
    ),
  ],
);

const VerdictTier _tier46to70 = VerdictTier(
  title: 'A Portfolio with Potential',
  intro:
      'Your portfolio shows clear progress.\n\n'
      'Most of your investments are backed by companies with solid '
      'business foundations, while a smaller number still carry higher '
      'levels of uncertainty. This balance suggests you\'re beginning to '
      'look beyond market excitement and pay closer attention to the '
      'strength of the businesses you invest in.\n\n'
      'That\'s an important step.\n\n'
      'Successful investing isn\'t about finding companies with the '
      'most exciting stories.\n\n'
      'It\'s about identifying businesses that can continue creating '
      'value year after year.\n\n'
      'Strong companies often share similar characteristics. They '
      'generate consistent revenue, maintain healthy profit margins, '
      'manage debt responsibly, and continue growing even when market '
      'conditions become difficult.\n\n'
      'Your portfolio already reflects many of these qualities.\n\n'
      'However, there are still a few companies whose future depends '
      'more on expectations than proven financial performance.\n\n'
      'That doesn\'t automatically make them bad investments.\n\n'
      'Some speculative companies eventually become tomorrow\'s market '
      'leaders.\n\n'
      'The challenge is that it\'s impossible to know in advance which '
      'ones will succeed and which ones won\'t.\n\n'
      'This is why experienced investors usually build the majority of '
      'their portfolio around businesses that have already demonstrated '
      'financial strength, while limiting exposure to companies that '
      'are still trying to prove themselves.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'As your portfolio grows, try making business quality one of '
          'your main investment filters.\n\n'
          'Before buying a company, look beyond the share price.\n\n'
          'Ask yourself:\n\n'
          'Is this business consistently profitable?\n'
          'Does it generate healthy cash flow?\n'
          'Is debt under control?\n'
          'Has management demonstrated the ability to execute its '
          'strategy over time?\n'
          'Would I still want to own this company if its stock price '
          'didn\'t move for the next three years?\n\n'
          'The answers to these questions often reveal far more than '
          'short-term market enthusiasm.\n\n'
          'Remember, a strong investment is built on a strong '
          'business—not simply on a popular stock.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A great company doesn\'t have to be exciting.\n\n'
          'It has to be resilient.\n\n'
          'The market often rewards excitement for a while.\n\n'
          'It rewards strong businesses for much longer.\n\n'
          'The more your decisions are guided by business quality '
          'instead of market excitement, the stronger your portfolio '
          'becomes.',
    ),
  ],
);

const VerdictTier _tier71to90 = VerdictTier(
  title: 'Quality Comes First',
  intro:
      'Your portfolio reflects a disciplined approach to investing.\n\n'
      'The companies you\'ve selected are generally supported by strong '
      'financial foundations rather than short-term market excitement. '
      'Instead of chasing headlines or popular trends, you\'ve focused '
      'on businesses that have already demonstrated their ability to '
      'generate revenue, earn profits, manage debt responsibly, and '
      'create long-term value.\n\n'
      'This is one of the most important habits successful investors '
      'develop.\n\n'
      'The market is full of exciting stories.\n\n'
      'Some promise revolutionary technologies.\n\n'
      'Others promise to change entire industries.\n\n'
      'A few eventually do.\n\n'
      'Many never live up to those expectations.\n\n'
      'Strong businesses don\'t need extraordinary promises to attract '
      'investors. They earn confidence through consistent execution, '
      'financial stability, and years of proven performance.\n\n'
      'Your portfolio reflects that mindset.\n\n'
      'Rather than relying on hope, you\'ve built much of your '
      'portfolio around companies that have already shown they can '
      'survive economic downturns, adapt to changing markets, and '
      'continue growing over time.\n\n'
      'No company is completely risk-free.\n\n'
      'Even the strongest businesses experience difficult years, '
      'disappointing earnings, or unexpected challenges.\n\n'
      'However, financially healthy companies are often far better '
      'equipped to recover from those setbacks than businesses that are '
      'already struggling to survive.\n\n'
      'That difference becomes especially valuable during periods of '
      'market uncertainty.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Keep doing what you\'re already doing—but never stop asking '
          'questions.\n\n'
          'Even outstanding companies deserve regular review.\n\n'
          'Markets evolve.\n\n'
          'Industries change.\n\n'
          'New competitors emerge.\n\n'
          'Before adding a new investment, ask yourself:\n\n'
          'Is this company still financially strong?\n'
          'Has its business improved over the past few years?\n'
          'Does it continue creating value for shareholders?\n'
          'Would I still feel comfortable owning this business during a '
          'difficult market downturn?\n\n'
          'A strong portfolio isn\'t built by finding perfect '
          'companies.\n\n'
          'It\'s built by consistently choosing businesses that '
          'continue earning your confidence.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Great investors don\'t search for perfect stocks.\n\n'
          'They search for exceptional businesses.\n\n'
          'Stock prices rise and fall every day.\n\n'
          'Strong businesses continue building value long after today\'s '
          'headlines have been forgotten.\n\n'
          'When you invest in quality businesses, you\'re investing in '
          'companies that have already learned how to survive, adapt, '
          'and grow.',
    ),
  ],
);

const VerdictTier _tier91to100 = VerdictTier(
  title: 'Investing in Businesses, Not Stories',
  intro:
      'You invest in businesses—not promises.\n\n'
      'Your portfolio reflects the mindset of a long-term investor.\n\n'
      'Rather than chasing excitement, market hype, or the latest '
      'investment trend, you\'ve consistently chosen companies with '
      'strong financial foundations and proven business performance.\n\n'
      'These businesses don\'t rely solely on bold promises or '
      'optimistic forecasts.\n\n'
      'They generate real revenue.\n\n'
      'They produce sustainable profits.\n\n'
      'They manage debt responsibly.\n\n'
      'They reward shareholders through disciplined capital '
      'allocation.\n\n'
      'Most importantly, they have demonstrated an ability to adapt, '
      'compete, and grow through changing market conditions.\n\n'
      'That doesn\'t guarantee every investment will succeed.\n\n'
      'No company is immune to economic downturns, unexpected '
      'challenges, or periods of poor performance.\n\n'
      'However, businesses with strong fundamentals are often far '
      'better equipped to overcome those obstacles than companies that '
      'are still searching for a viable business model.\n\n'
      'This is one of the biggest differences between investing and '
      'speculating.\n\n'
      'Speculation asks:\n\n'
      '"What could this company become?"\n\n'
      'Investing asks:\n\n'
      '"What has this company already proven it can do?"\n\n'
      'Your portfolio suggests you\'re asking the second question more '
      'often.\n\n'
      'That habit has helped many successful investors build wealth '
      'over decades—not by predicting the future, but by owning '
      'businesses capable of creating value year after year.',
  sections: [
    TierSection(
      label: 'Keep Thinking Like a Business Owner',
      body:
          'Even outstanding companies deserve regular review.\n\n'
          'Markets change.\n\n'
          'Industries evolve.\n\n'
          'Competitive advantages can weaken over time.\n\n'
          'Continue looking beyond the share price.\n\n'
          'Review financial statements.\n\n'
          'Follow earnings reports.\n\n'
          'Pay attention to debt levels, profitability, cash flow, and '
          'management decisions.\n\n'
          'The strongest investors don\'t buy great companies and '
          'forget about them forever.\n\n'
          'They continue making sure those companies remain great '
          'businesses.\n\n'
          'Remember, a high-quality company today must continue earning '
          'that reputation tomorrow.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A stock is more than a ticker symbol.\n\n'
          'Behind every share is a real business, real employees, real '
          'customers, and real financial results.\n\n'
          'The market may reward exciting stories for a season.\n\n'
          'But over the long run, it has consistently rewarded '
          'businesses that create lasting value.\n\n'
          'The greatest investment isn\'t finding the next headline. '
          'It\'s owning companies that continue proving their worth '
          'long after the headlines have faded.',
    ),
  ],
);

/// Picks the verdict tier for a Safety Marker score. [score] is 0.0-1.0
/// (same convention as [VerdictArchiveEntry.safetyMarker]); [hasData]
/// mirrors [VerdictArchiveEntry.safetyMarkerHasData].
VerdictTier safetyMarkerTierFor(double score, bool hasData) {
  if (!hasData) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 45) return _tier21to45;
  if (pct <= 70) return _tier46to70;
  if (pct <= 90) return _tier71to90;
  return _tier91to100;
}
