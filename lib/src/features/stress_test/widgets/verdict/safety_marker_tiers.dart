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
      'Some good companies start to appear.\n\n'
      'But a significant share of your capital is still sitting in weak '
      'businesses.\n\n'
      'You\'re betting more on potential than on quality.',
);

const VerdictTier _tier46to70 = VerdictTier(
  title: 'A Portfolio with Potential',
  intro:
      'This is where it gets interesting. This is already a reasonable '
      'portfolio. Some companies are good. Some are average. A few are '
      'questionable.\n\n'
      'In other words: you\'re already paying attention to fundamentals, '
      'but you sometimes let a good story win over cold, hard numbers.',
);

const VerdictTier _tier71to90 = VerdictTier(
  title: 'Quality Comes First',
  intro:
      'This is where experience starts to show. Most of your companies '
      'have:\n\n'
      '✔ Consistent profits\n'
      '✔ Strong margins\n'
      '✔ A healthy balance sheet\n'
      '✔ Reasonable debt levels\n'
      '✔ A business model you can actually explain\n\n'
      'In other words, you already know how to pick a good business.',
);

const VerdictTier _tier91to100 = VerdictTier(
  title: 'Investing in Businesses, Not Stories',
  intro:
      'You invest in businesses—not promises.\n\n'
      'You\'ve stopped buying good stories. You buy companies that '
      'actually work.\n\n'
      'These are exactly the kinds of businesses that have built '
      'investor wealth for decades.',
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
