// ---------------------------------------------------------------------------
// Sector Diversification verdict tiers — 6 states keyed by final holdings
// count, shown on the Session Complete screen's "SECTOR DIVERSIFICATION"
// card ("More" -> VerdictMarkerDetailScreen). 5 tiers match the boundaries
// tuned into psychology_engine.dart's diversificationStops (Count Balance
// bar on the Psychology Meter's Diversification widget) — keep both in
// sync if the ranges ever change. The 6th (0 holdings) isn't part of that
// table; it's the "test ended with no purchases" edge case.
//
// Layout template for the long-form copy is market_period_detail_screen.dart
// (Market Clock's phase detail screen, e.g. Pre-Market): title, flowing
// intro paragraphs, then labeled sub-sections (caps brand-color label +
// body) for things like "How can you improve?" / "One last thought". Only
// tier 1 has full copy so far — the rest still carry their short one-line
// placeholder as `intro` with no sections, filled in one at a time.
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierEmpty = VerdictTier(
  title: 'No Positions Opened',
  intro:
      'This test ended without a single purchase — there\'s nothing yet '
      'to diversify.',
);

const VerdictTier _tier1to2 = VerdictTier(
  title: 'Not All Your Eggs in One Basket',
  intro:
      'Your portfolio has placed almost all of its trust in just one or '
      'two sectors of the economy. It\'s an understandable decision. When '
      'a particular industry is booming, it can feel like you\'ve found '
      'the obvious winner. The thought naturally follows:\n\n'
      '"Why invest anywhere else if all the biggest opportunities are '
      'right here?"\n\n'
      'The problem is that the market rarely follows a single script.\n\n'
      'Today, investors are excited about artificial intelligence. Before '
      'that, it was electric vehicles. Earlier, it was internet companies, '
      'biotechnology, clean energy, and many other industries that once '
      'seemed unstoppable. Some of them truly changed the world—but '
      'almost every one of them also experienced periods when prices fell '
      'dramatically and investor confidence quickly turned into '
      'uncertainty.\n\n'
      'The issue isn\'t the sector you chose.\n\n'
      'The issue is that the future of your entire portfolio now depends '
      'on a single idea.\n\n'
      'If that one sector runs into trouble, nearly all of your '
      'investments will feel the impact at the same time.\n\n'
      'Imagine flying in an aircraft powered by only one engine. As long '
      'as everything works, the flight is smooth. But if that engine '
      'fails, there isn\'t much left to rely on.\n\n'
      'A well-built investment portfolio works differently. It\'s more '
      'like an aircraft with multiple independent systems. If one part '
      'struggles, the others continue doing their job, helping keep the '
      'entire portfolio stable.\n\n'
      'That\'s exactly why experienced investors spread their money '
      'across different sectors of the economy. Technology, healthcare, '
      'financials, industrials, consumer goods, utilities, energy—these '
      'industries don\'t move in perfect harmony. When one sector has a '
      'difficult year, another may continue growing or simply remain '
      'stable. That balance helps reduce the impact of unexpected events.',
  sections: [
    TierSection(
      label: 'How can you improve?',
      body:
          'Don\'t try to predict the single winning sector of the next '
          'decade. Even professional investors rarely get that right '
          'consistently.\n\n'
          'Instead, build your portfolio one step at a time.\n\n'
          'Keep investing in the sector you believe in—but gradually add '
          'exposure to other parts of the economy. You don\'t need to buy '
          'everything at once. Every new investment is an opportunity to '
          'make your portfolio a little more balanced and a little more '
          'resilient.\n\n'
          'Before making your next purchase, ask yourself one simple '
          'question:\n\n'
          '"If my favorite sector stopped growing for the next three '
          'years, would my portfolio still be in good shape?"\n\n'
          'If that question makes you uncomfortable, it\'s probably time '
          'to broaden your investments.',
    ),
    TierSection(
      label: 'One last thought',
      body:
          'Diversification is rarely exciting.\n\n'
          'It doesn\'t make headlines. It doesn\'t promise overnight '
          'wealth. In fact, it can even feel a little boring.\n\n'
          'But diversification isn\'t designed for the days when '
          'everything is going up.\n\n'
          'It\'s designed for the days when the market reminds everyone '
          'that no sector, no matter how exciting, rises forever.\n\n'
          'A successful investor doesn\'t build a portfolio around a '
          'single hope. They build it to survive many different futures.',
    ),
  ],
);

const VerdictTier _tier3to4 = VerdictTier(
  title: 'A Strong Foundation, But There\'s Still Room to Grow',
  intro:
      'Your portfolio is already moving in the right direction.\n\n'
      'Instead of relying on a single industry, you\'ve spread your '
      'investments across several sectors of the economy. That\'s an '
      'important step because it reduces the risk of one disappointing '
      'industry dragging down your entire portfolio.\n\n'
      'Many investors never get this far.\n\n'
      'However, your portfolio still relies almost entirely on individual '
      'companies.\n\n'
      'Even the strongest businesses can experience unexpected setbacks. '
      'A weak earnings report, new competition, regulatory changes, a '
      'lawsuit, or simply a shift in market sentiment can cause an '
      'individual stock to struggle for months—or even years.\n\n'
      'This is where a broad-market ETF can quietly become one of the '
      'most valuable investments in your portfolio.\n\n'
      'Think of an ETF as the foundation beneath your house.\n\n'
      'You probably don\'t admire the foundation every day. It isn\'t '
      'exciting. It doesn\'t make headlines. Nobody talks about it at '
      'family dinners.\n\n'
      'But when the weather turns bad, you\'re very happy it\'s there.\n\n'
      'A broad-market ETF spreads your investment across hundreds—or '
      'even thousands—of companies with a single purchase. It doesn\'t '
      'replace individual stocks. Instead, it helps balance them. While '
      'one company may disappoint, many others continue doing their job '
      'behind the scenes.\n\n'
      'This creates a portfolio that is often more stable, easier to '
      'manage, and less dependent on the success of a handful of '
      'companies.',
  sections: [
    TierSection(
      label: 'How can you improve?',
      body:
          'You\'ve already done the difficult part by diversifying across '
          'multiple sectors.\n\n'
          'Now consider adding at least one broad-market ETF to '
          'strengthen the overall structure of your portfolio.\n\n'
          'You don\'t need to replace the companies you believe in.\n\n'
          'Simply allow an ETF to become the stable core around which the '
          'rest of your investments can grow.\n\n'
          'Many experienced long-term investors build their portfolios '
          'this way:\n\n'
          'A solid ETF provides broad market exposure.\n'
          'Individual companies are added around it to pursue additional '
          'growth opportunities.\n\n'
          'This combination offers the best of both worlds—stability '
          'from the market as a whole and the potential for stronger '
          'returns from carefully selected businesses.',
    ),
    TierSection(
      label: 'One last thought',
      body:
          'A well-diversified portfolio isn\'t measured only by how many '
          'sectors it owns.\n\n'
          'It\'s also measured by how many different risks it avoids.\n\n'
          'Individual companies can surprise you. An entire market is '
          'much harder to surprise.',
    ),
  ],
);

const VerdictTier _tier5to15 = VerdictTier(
  title: 'A Portfolio Built to Weather the Storm',
  intro:
      'Your portfolio looks thoughtfully constructed rather than '
      'randomly assembled.\n\n'
      'Your investments are spread across multiple sectors of the '
      'economy, meaning your long-term success doesn\'t depend on a '
      'single industry or one big idea. Technology may lead today, while '
      'healthcare, industrials, financials, or consumer companies could '
      'take the spotlight tomorrow. No one can consistently predict '
      'which sector will outperform next—but you\'ve already prepared '
      'for different possibilities.\n\n'
      'That\'s exactly what diversification is meant to do.\n\n'
      'When one sector faces a difficult period, others may continue '
      'growing or simply remain stable. This balance helps reduce the '
      'impact of unexpected market events and makes your portfolio more '
      'resilient during times of volatility.\n\n'
      'Most importantly, you resisted the temptation to bet everything '
      'on a single trend. Instead of trying to identify one future '
      'winner, you\'ve given your investments the opportunity to grow '
      'across several parts of the economy. That approach may not '
      'deliver the highest return every single year, but it greatly '
      'improves your chances of achieving consistent long-term '
      'results.\n\n'
      'Great investors don\'t focus only on how much they can make.\n\n'
      'They also focus on staying invested through every market cycle.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Even a strong portfolio can still be improved.\n\n'
          'If you already own a broad-market ETF, you\'ve built a solid '
          'foundation. If not, consider adding one. A single diversified '
          'ETF can become the stable core of your portfolio while your '
          'individual stock picks provide additional growth '
          'opportunities.\n\n'
          'There\'s one more habit that experienced investors often '
          'develop.\n\n'
          'You don\'t have to invest every available dollar the moment '
          'it becomes available.\n\n'
          'Keeping a small cash reserve isn\'t a sign of hesitation—it\'s '
          'a sign of preparation.\n\n'
          'When the market suddenly declines, that reserve gives you the '
          'freedom to buy quality companies at more attractive prices '
          'instead of watching great opportunities pass by.\n\n'
          'Cash sitting on the sidelines isn\'t always idle money.\n\n'
          'Sometimes it\'s future opportunity waiting for the right '
          'moment.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Diversification protects you from relying on a single '
          'sector.\n\n'
          'A broad-market ETF spreads your risk across hundreds of '
          'companies.\n\n'
          'A small cash reserve gives you the flexibility to act when '
          'others are driven by fear.\n\n'
          'Individually, these habits may seem simple.\n\n'
          'Together, they create the kind of portfolio that is built '
          'not only to grow—but to endure.\n\n'
          'Successful investors don\'t prepare only for rising markets. '
          'They also prepare for the opportunities that appear when '
          'markets fall.',
    ),
  ],
);

const VerdictTier _tier16to24 = VerdictTier(
  title: 'Diversification Done Right',
  intro:
      'You\'ve built a portfolio that reflects patience, balance, and '
      'long-term thinking.\n\n'
      'Your investments are spread across multiple sectors of the '
      'economy, reducing your dependence on any single industry or '
      'market trend. Rather than trying to predict one future winner, '
      'you\'ve prepared your portfolio for many possible outcomes.\n\n'
      'This is exactly what diversification is designed to achieve.\n\n'
      'When technology slows down, healthcare may continue growing. '
      'When consumer spending weakens, utilities or defensive businesses '
      'may provide stability. No one knows which sector will lead next '
      'year, but your portfolio doesn\'t need to rely on a single '
      'prediction.\n\n'
      'You\'ve built a structure that is designed to adapt rather than '
      'guess.\n\n'
      'That is one of the strongest habits a long-term investor can '
      'develop.',
  sections: [
    TierSection(
      label: 'One Important Reminder',
      body:
          'Good sector diversification doesn\'t automatically mean every '
          'investment is a good one.\n\n'
          'A portfolio can be perfectly diversified across industries '
          'while still containing companies with weak business models, '
          'excessive debt, declining revenues, or highly speculative '
          'business strategies.\n\n'
          'Diversification protects you from concentrating your money in '
          'one part of the economy.\n\n'
          'It does not protect you from buying poor-quality '
          'businesses.\n\n'
          'This is especially important when investing in highly '
          'speculative companies.\n\n'
          'Early-stage biotechnology firms, pre-revenue startups, meme '
          'stocks, and businesses that rely more on future promises than '
          'proven results can experience extreme price swings. Some may '
          'become incredible success stories.\n\n'
          'Many others never reach profitability.\n\n'
          'Owning companies simply because they belong to different '
          'sectors isn\'t enough.\n\n'
          'Each investment should earn its place in your portfolio '
          'through the strength of its business, not just the '
          'excitement surrounding its story.',
    ),
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Continue reviewing your companies—not just your sector '
          'allocation.\n\n'
          'Ask yourself questions like:\n\n'
          'Does this company have a sustainable business?\n'
          'Is it consistently generating revenue and profits?\n'
          'Does it carry manageable debt?\n'
          'Would I still want to own this business if the share price '
          'stopped rising for several years?\n\n'
          'These questions often reveal far more than a rising stock '
          'chart.\n\n'
          'Remember, diversification should never become an excuse to '
          'buy companies blindly.\n\n'
          'A portfolio filled with weak businesses doesn\'t become '
          'strong simply because they operate in different industries.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Diversification protects your portfolio.\n\n'
          'Quality protects your investments.\n\n'
          'Discipline protects your future.\n\n'
          'When all three work together, you\'re no longer just buying '
          'stocks.\n\n'
          'You\'re building an investment portfolio designed to grow, '
          'adapt, and endure for decades.',
    ),
  ],
);

const VerdictTier _tier25plus = VerdictTier(
  title: 'From a Portfolio to a Zoo',
  intro:
      'Diversification is one of the most important principles of '
      'long-term investing.\n\n'
      'But like many good ideas, it can be taken too far.\n\n'
      'Your portfolio now contains so many individual companies that '
      'keeping track of them all becomes a challenge in itself.\n\n'
      'At some point, diversification stops reducing risk and starts '
      'reducing your ability to understand what you actually own.\n\n'
      'After all, it\'s difficult to follow earnings reports, financial '
      'results, product launches, management changes, and industry '
      'developments for dozens of businesses at the same time.\n\n'
      'Eventually, your investments begin managing you instead of the '
      'other way around.\n\n'
      'A well-built portfolio doesn\'t need to own everything.\n\n'
      'It needs to own enough.',
  sections: [
    TierSection(
      label: 'More Companies Doesn\'t Always Mean Less Risk',
      body:
          'Many new investors believe that buying more stocks '
          'automatically makes a portfolio safer.\n\n'
          'In reality, there comes a point where each additional company '
          'adds very little protection while making the portfolio '
          'significantly more difficult to understand and manage.\n\n'
          'Imagine trying to care for three pets.\n\n'
          'That\'s manageable.\n\n'
          'Now imagine trying to care for thirty.\n\n'
          'Sooner or later, someone isn\'t getting enough attention.\n\n'
          'The same happens with investments.\n\n'
          'If you no longer remember why you bought a company—or don\'t '
          'notice when its business begins to deteriorate—it may no '
          'longer deserve a place in your portfolio.',
    ),
    TierSection(
      label: 'Quality Always Comes Before Quantity',
      body:
          'Owning thirty average businesses is rarely better than owning '
          'fifteen outstanding ones that you truly understand.\n\n'
          'Every company in your portfolio should have a clear reason '
          'for being there.\n\n'
          'If the only answer is...\n\n'
          '"Because I wanted more diversification."\n\n'
          '...it may be worth asking whether that position is actually '
          'improving your portfolio—or simply making it more '
          'complicated.\n\n'
          'Remember, diversification is about reducing unnecessary '
          'risk.\n\n'
          'It is not about collecting as many ticker symbols as '
          'possible.',
    ),
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Take some time to review your holdings.\n\n'
          'Ask yourself:\n\n'
          'Do I still understand this company\'s business?\n'
          'Would I buy this company again today?\n'
          'Does this investment add something unique to my portfolio?\n'
          'Or is it simply another company that overlaps with several '
          'others I already own?\n\n'
          'If two companies serve nearly the same purpose, you may not '
          'need both.\n\n'
          'A simpler portfolio is often easier to monitor, easier to '
          'understand, and easier to stick with during difficult '
          'markets.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A portfolio is not a stamp collection.\n\n'
          'You don\'t earn extra points for owning the most companies.\n\n'
          'You earn them by owning businesses you understand and are '
          'confident holding through both good times and bad.\n\n'
          'The goal isn\'t to own everything. The goal is to know why '
          'you own each investment.',
    ),
  ],
);

/// Picks the verdict tier for a final holdings count.
VerdictTier diversificationTierForCount(int holdingCount) {
  if (holdingCount <= 0) return _tierEmpty;
  if (holdingCount <= 2) return _tier1to2;
  if (holdingCount <= 4) return _tier3to4;
  if (holdingCount <= 15) return _tier5to15;
  if (holdingCount <= 24) return _tier16to24;
  return _tier25plus;
}
