// ---------------------------------------------------------------------------
// ETF Exposure verdict tiers — keyed by the COUNT of distinct ETFs held
// (`etfExposureScoreForCount` in psychology_engine.dart), not their % of
// portfolio value — 2-3 is the ideal, more starts overlapping/duplicating.
// Shown on Session Complete's "STRATEGY" card ("?" -> VerdictMarkerDetailScreen).
// Short intro-only copy for now (scale given 2026-08-07, full long-form
// article to follow tier-by-tier same as the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No ETF Data Yet',
  intro:
      'This test ended without any positions — there\'s no ETF exposure '
      'to measure yet.',
);

const VerdictTier _tier0 = VerdictTier(
  title: 'No Safety Net',
  intro:
      'Your portfolio is built entirely from individual stocks, with no '
      'exchange-traded funds (ETFs) to provide broader market '
      'exposure.\n\n'
      'This isn\'t necessarily a bad strategy.\n\n'
      'Many successful investors have built impressive portfolios using '
      'only individual companies.\n\n'
      'The challenge is that this approach asks much more from you.\n\n'
      'Every investment decision becomes your responsibility.\n\n'
      'You must identify strong businesses, avoid weak ones, manage '
      'diversification, monitor risk, and accept that a single mistake '
      'can have a much greater impact on your long-term results.\n\n'
      'An ETF works differently.\n\n'
      'Instead of relying on the success of one company, it allows you '
      'to invest in dozens—or even hundreds—of businesses through a '
      'single investment.\n\n'
      'If one company struggles, the others continue contributing to '
      'the portfolio.\n\n'
      'This built-in diversification is one of the main reasons ETFs '
      'have become so popular among long-term investors.\n\n'
      'Without at least one broad-market ETF, your portfolio has no '
      'automatic safety net.\n\n'
      'Its success depends entirely on your ability to consistently '
      'select winning companies over many years.\n\n'
      'That\'s a difficult challenge—even for experienced investors.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Consider adding a broad-market ETF as a foundation for your '
          'portfolio.\n\n'
          'An ETF doesn\'t replace individual stock investing.\n\n'
          'It complements it.\n\n'
          'Think of it as the stable core of your investment strategy, '
          'while individual companies become opportunities to seek '
          'additional growth.\n\n'
          'Many long-term investors combine both approaches:\n\n'
          'A diversified ETF provides stability.\n\n'
          'Carefully selected companies provide the potential to '
          'outperform the market.\n\n'
          'Together, they create a portfolio that is both resilient and '
          'flexible.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'You don\'t need an ETF because individual stocks are bad.\n\n'
          'You need one because no investor can predict every future '
          'winner.\n\n'
          'A single ETF won\'t make your portfolio exciting—but it can '
          'make it significantly more resilient for the decades ahead.',
    ),
  ],
);

const VerdictTier _tier1 = VerdictTier(
  title: 'A Step Toward Stability',
  intro:
      'Your portfolio now includes an ETF, and that\'s an important '
      'step toward building a more resilient investment strategy.\n\n'
      'By adding broad market exposure, you\'ve reduced your dependence '
      'on individual companies and introduced an investment designed to '
      'spread risk across many businesses.\n\n'
      'That\'s exactly what ETFs do best.\n\n'
      'While individual stocks can deliver exceptional returns, they '
      'can also disappoint for reasons that are impossible to '
      'predict.\n\n'
      'An ETF helps balance that uncertainty by investing in a large '
      'group of companies instead of relying on the success of just '
      'one.\n\n'
      'Think of it as adding a strong foundation beneath the rest of '
      'your portfolio.\n\n'
      'At the same time, a single ETF is only the beginning.\n\n'
      'Your portfolio still relies primarily on individual stock '
      'selection, meaning your long-term performance will continue to '
      'depend on the quality of the businesses you choose.\n\n'
      'The ETF provides stability.\n\n'
      'Your stock selections provide the opportunity for additional '
      'growth.\n\n'
      'Together, they create a healthier balance than either approach '
      'alone.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Your portfolio is already moving in the right direction.\n\n'
          'As it grows, consider whether a second ETF could complement '
          'your existing one.\n\n'
          'For example, investors often combine a broad-market ETF with '
          'another fund focused on international markets, small-cap '
          'companies, bonds, or another area that isn\'t already '
          'represented.\n\n'
          'The goal isn\'t to collect ETFs.\n\n'
          'The goal is to make sure each one adds something genuinely '
          'different to your portfolio.\n\n'
          'Quality matters more than quantity.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'One ETF won\'t eliminate investment risk.\n\n'
          'Nothing can.\n\n'
          'But it can reduce the impact of unexpected events while '
          'giving your portfolio a stronger foundation to build '
          'upon.\n\n'
          'A solid investment strategy doesn\'t rely on one perfect '
          'company—it starts with a portfolio that can weather many '
          'different market conditions.',
    ),
  ],
);

const VerdictTier _tier2to3 = VerdictTier(
  title: 'A Strong Core',
  intro:
      'Your portfolio includes a healthy number of ETFs, creating a '
      'solid foundation for long-term investing.\n\n'
      'Rather than relying entirely on individual stock selection, '
      'you\'ve chosen to combine broad market exposure with the '
      'flexibility to invest in companies you believe in. This is a '
      'strategy used by many experienced investors because it balances '
      'growth potential with sensible risk management.\n\n'
      'ETFs offer something individual stocks cannot.\n\n'
      'Instant diversification.\n\n'
      'With just a few funds, you can gain exposure to hundreds—or '
      'even thousands—of companies across different industries, '
      'countries, and sectors of the economy.\n\n'
      'This helps reduce the impact that any single company can have '
      'on your overall portfolio while allowing the broader market to '
      'work in your favor over time.\n\n'
      'Your portfolio reflects that philosophy well.\n\n'
      'At the same time, you\'ve avoided another common mistake—'
      'collecting too many ETFs.\n\n'
      'Every fund in your portfolio appears to have a purpose instead '
      'of simply adding more investments for the sake of '
      'diversification.\n\n'
      'That\'s an important distinction.\n\n'
      'A carefully chosen ETF should expand your exposure, not repeat '
      'what you already own.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'The key now isn\'t adding more ETFs.\n\n'
          'It\'s understanding what each one actually holds.\n\n'
          'Before purchasing another fund, ask yourself:\n\n'
          'Does this ETF provide exposure I don\'t already have?\n'
          'Am I adding diversification, or simply buying many of the '
          'same companies again?\n'
          'Does this fund serve a clear purpose within my '
          'portfolio?\n\n'
          'A small collection of well-chosen ETFs is often more '
          'effective than owning dozens of overlapping funds.\n\n'
          'Remember, every investment should have a job.\n\n'
          'If an ETF doesn\'t improve your portfolio in a meaningful '
          'way, it probably doesn\'t need to be there.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Great portfolios aren\'t measured by how many ETFs they '
          'contain.\n\n'
          'They\'re measured by how well those ETFs work together.\n\n'
          'A few carefully selected funds can provide the foundation '
          'for decades of investing—without making your portfolio '
          'unnecessarily complicated.',
    ),
  ],
);

const VerdictTier _tier4to6 = VerdictTier(
  title: 'Broadly Diversified',
  intro:
      'Your portfolio includes several ETFs, giving you exposure to a '
      'wide range of companies and markets.\n\n'
      'That\'s a positive sign.\n\n'
      'By investing through multiple funds, you\'ve reduced the risk of '
      'relying too heavily on individual businesses and created a '
      'portfolio that can benefit from different parts of the global '
      'economy.\n\n'
      'However, there comes a point where adding more ETFs doesn\'t '
      'always add more diversification.\n\n'
      'Many popular funds hold the same companies.\n\n'
      'For example, it\'s common for several U.S. equity ETFs to own '
      'large positions in businesses like Apple, Microsoft, NVIDIA, '
      'Amazon, and other market leaders.\n\n'
      'Although the fund names may be different, much of the '
      'underlying portfolio can look surprisingly similar.\n\n'
      'This is known as overlapping exposure.\n\n'
      'It creates the impression of greater diversification while, in '
      'reality, many of your investments are following the same group '
      'of companies.\n\n'
      'Your portfolio is still well diversified, but it\'s worth making '
      'sure each ETF contributes something unique rather than '
      'repeating what you already own.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Before adding another ETF, take a moment to understand what '
          'it actually contains.\n\n'
          'Ask yourself:\n\n'
          'Does this fund invest in companies I don\'t already own '
          'through another ETF?\n'
          'Does it provide exposure to a different region, sector, or '
          'asset class?\n'
          'Is it adding genuine diversification, or simply increasing '
          'my exposure to the same businesses?\n\n'
          'Sometimes replacing two similar ETFs with one broader fund '
          'can simplify your portfolio while providing nearly identical '
          'market exposure.\n\n'
          'A portfolio doesn\'t become stronger simply because it '
          'contains more funds.\n\n'
          'It becomes stronger when every investment has a clear '
          'purpose.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'More ETFs don\'t always mean more diversification.\n\n'
          'Sometimes they simply mean owning the same companies several '
          'times under different names.\n\n'
          'The goal isn\'t to collect funds—it\'s to build a portfolio '
          'where every ETF adds something valuable that wasn\'t already '
          'there.',
    ),
  ],
);

const VerdictTier _tier7plus = VerdictTier(
  title: 'Broad Diversification, Simple Strategy',
  intro:
      'Your portfolio contains a large number of ETFs, giving you '
      'exposure to a wide range of markets, industries, and '
      'companies.\n\n'
      'There\'s nothing inherently wrong with this approach.\n\n'
      'In fact, many investors choose to build their entire portfolio '
      'using ETFs because they offer excellent diversification, low '
      'maintenance, and broad exposure to the global economy.\n\n'
      'However, more ETFs don\'t automatically create a better '
      'portfolio.\n\n'
      'Beyond a certain point, many funds begin investing in the same '
      'companies.\n\n'
      'A U.S. market ETF, an S&P 500 ETF, a Large Cap ETF, and a '
      'Growth ETF may all hold significant positions in businesses '
      'like Apple, Microsoft, NVIDIA, Amazon, and other market '
      'leaders.\n\n'
      'Although your portfolio appears highly diversified, the '
      'underlying investments may overlap far more than you realize.\n\n'
      'There\'s another trade-off worth understanding.\n\n'
      'ETFs are designed to follow the market—not beat it.\n\n'
      'They provide steady, diversified exposure, but they rarely '
      'deliver exceptional returns on their own.\n\n'
      'That\'s why many investors combine a small number of broad ETFs '
      'with carefully selected individual companies.\n\n'
      'The ETFs provide stability.\n\n'
      'The individual businesses provide the opportunity to outperform '
      'the market.\n\n'
      'Neither approach is universally better.\n\n'
      'They simply represent different investment philosophies.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Instead of asking whether you need another ETF, ask whether '
          'each ETF has a unique purpose.\n\n'
          'Does it give you exposure to a market you don\'t already '
          'own?\n\n'
          'Or is it simply another way of buying many of the same '
          'companies?\n\n'
          'If your goal is a simple, long-term portfolio, a handful of '
          'carefully selected ETFs is often enough.\n\n'
          'If your goal is to outperform the market through stock '
          'selection, consider allowing your strongest individual '
          'companies to play a larger role while keeping ETFs as the '
          'stable core of your portfolio.\n\n'
          'The objective isn\'t to own more funds.\n\n'
          'It\'s to make every fund earn its place.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A portfolio made entirely of ETFs can be an excellent '
          'long-term strategy.\n\n'
          'A portfolio combining ETFs and outstanding businesses can '
          'also be an excellent strategy.\n\n'
          'The important question isn\'t how many ETFs you own.\n\n'
          'It\'s whether each one adds something your portfolio didn\'t '
          'already have.\n\n'
          'Diversification is powerful. Complexity isn\'t always '
          'necessary.',
    ),
  ],
);

/// Picks the verdict tier for ETF Exposure. [score] is the 0.0-1.0 value
/// produced by `etfExposureScoreForCount` (same convention as
/// [VerdictArchiveEntry.strategyEtf]); [holdingCount] mirrors
/// [VerdictArchiveEntry.holdingCount] — 0 means no positions were ever
/// opened. `etfExposureScoreForCount` only ever emits 5 fixed values
/// (10/35/95/85/70, one per count bucket) — match on those directly
/// rather than a range, so this stays exact if the curve is ever retuned.
VerdictTier etfExposureTierFor(double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData;
  final pct = (score * 100).round();
  switch (pct) {
    case 10:
      return _tier0;
    case 35:
      return _tier1;
    case 85:
      return _tier4to6;
    case 70:
      return _tier7plus;
    default:
      return _tier2to3;
  }
}
