// ---------------------------------------------------------------------------
// Panic verdict tiers — keyed by `entry.panicResistance` (evaluateSellTrade
// in psychology_engine.dart: a running behavioral score that only moves on
// SELL trades — starts at 50 neutral. +5 flat for realizing ANY profit
// (size doesn't matter — this scores behavior, not the trade's quality).
// 0 change for selling at breakeven. A realized loss is penalized by
// `severity = lossPct * 0.5 + bottomProximity * 0.5`, penalty = severity
// * 30 (max -30) — lossPct is the loss relative to cost basis,
// bottomProximity is how close the sale was to the symbol's LIFETIME low
// across the whole test, not just the current epoch. Separately, surviving
// a Black Swan/catastrophe epoch without selling into it gives a flat +15
// (see recordCatastropheSurvived in psychology_profile.dart) — a one-off
// per-epoch bonus, not tied to a specific trade. Discipline's pair marker:
// Discipline judges the BUY decision, Panic judges behavior under
// pressure on the SELL side — same even 20-point banding
// (0-20/21-40/41-60/61-80/81-100) as Discipline, confirmed 2026-08-07.
// Shown on Session Complete's own "PANIC" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Trades Yet',
  intro:
      'This test ended without any trades — there\'s no selling '
      'behavior to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'Panic Seller',
  intro:
      'Your selling behavior shows signs that fear may sometimes '
      'influence your investment decisions.\n\n'
      'Investing is not only about choosing good companies.\n\n'
      'It is also about having the patience and emotional control to '
      'stay with your decisions when the market becomes '
      'uncomfortable.\n\n'
      'One of the most difficult moments for any investor is watching '
      'a position decline.\n\n'
      'The natural reaction is to think:\n\n'
      '"Maybe I made a mistake. Maybe I should get out before it gets '
      'worse."\n\n'
      'Sometimes selling is the right decision.\n\n'
      'A company can lose its competitive advantage.\n\n'
      'The business conditions can change.\n\n'
      'The original investment idea may no longer be valid.\n\n'
      'But selling only because the price is falling is a different '
      'situation.\n\n'
      'The biggest losses for many investors do not come from buying '
      'bad companies.\n\n'
      'They come from abandoning good investments during the most '
      'stressful moments.\n\n'
      'A panic sale often happens when fear reaches its highest '
      'point.\n\n'
      'Unfortunately, this is also the moment when many quality '
      'assets are trading at their lowest prices.\n\n'
      'Your score suggests that some selling decisions may have '
      'happened during periods of strong pressure, possibly close to '
      'the worst moments of the decline.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before selling a position at a loss, create a clear '
          'checklist.\n\n'
          'Ask yourself:\n\n'
          'Has the business actually become worse?\n'
          'Has the original reason for buying changed?\n'
          'Am I making this decision because of new information or '
          'because I am afraid?\n\n'
          'Try separating the stock price from the business itself.\n\n'
          'A falling price does not automatically mean a broken '
          'company.\n\n'
          'Sometimes the market is simply reacting emotionally.\n\n'
          'Another useful habit is creating rules before problems '
          'appear.\n\n'
          'For example:\n\n'
          'Why would I sell this company?\n'
          'What conditions would make me change my opinion?\n'
          'How much volatility am I prepared to accept?\n\n'
          'A plan created during calm periods is often more reliable '
          'than a decision made during panic.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market will test every investor.\n\n'
          'Prices will fall.\n\n'
          'Bad news will appear.\n\n'
          'Fear will become loud.\n\n'
          'The goal is not to never feel fear—the goal is to avoid '
          'letting fear make your investment decisions for you.',
    ),
  ],
);

const VerdictTier _tier21to40 = VerdictTier(
  title: 'Emotional Selling',
  intro:
      'Your investment behavior shows that you are learning to '
      'manage difficult market situations, but emotions may still '
      'influence some selling decisions.\n\n'
      'Selling is one of the hardest parts of investing.\n\n'
      'Buying a company often feels exciting.\n\n'
      'Holding during good times feels easy.\n\n'
      'But watching a position decline tests patience, confidence, '
      'and trust in your own analysis.\n\n'
      'Your history suggests that some decisions may have been '
      'influenced by short-term pressure rather than a complete '
      'reassessment of the investment.\n\n'
      'This does not mean every losing trade was a mistake.\n\n'
      'Good investors sometimes sell at a loss.\n\n'
      'The difference is why they sell.\n\n'
      'A disciplined investor may accept a loss because:\n\n'
      'the business changed;\n'
      'the original investment idea is no longer valid;\n'
      'a better opportunity appeared.\n\n'
      'An emotional sale happens when the main reason is:\n\n'
      '"I cannot handle this decline anymore."\n\n'
      'The market often creates the strongest emotions near the most '
      'difficult moments.\n\n'
      'Fear becomes louder.\n\n'
      'Confidence disappears.\n\n'
      'And many investors exit exactly when patience becomes the '
      'most valuable skill.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before selling during a decline, try to slow down the '
          'decision process.\n\n'
          'Ask yourself:\n\n'
          'Am I selling because the company became weaker?\n'
          'Or am I selling because the stock price makes me '
          'uncomfortable?\n'
          'Would I still make this decision if the market was not '
          'showing daily price movements?\n\n'
          'Create your selling rules before emotions appear.\n\n'
          'A good investment plan should include not only:\n\n'
          '"When should I buy?"\n\n'
          'but also:\n\n'
          '"When should I sell?"\n\n'
          'Remember that temporary price declines are a normal part '
          'of investing.\n\n'
          'The important question is not:\n\n'
          '"Did the price fall?"\n\n'
          'The important question is:\n\n'
          '"Has the reason I invested changed?"',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Every investor feels fear.\n\n'
          'The difference between experienced investors and beginners '
          'is not the absence of fear.\n\n'
          'It is the ability to make decisions with a clear mind even '
          'when fear is present.',
    ),
  ],
);

const VerdictTier _tier41to60 = VerdictTier(
  title: 'Learning Patience',
  intro:
      'Your selling behavior shows that you are developing better '
      'control over emotional decisions, but your ability to stay '
      'calm during difficult market periods is still improving.\n\n'
      'You are no longer reacting purely from fear, but some '
      'situations may still create uncertainty and pressure.\n\n'
      'This is a very common stage for investors.\n\n'
      'Learning to invest successfully is not only about knowing what '
      'to buy.\n\n'
      'It is also about learning when not to act.\n\n'
      'Markets constantly create situations that challenge '
      'confidence:\n\n'
      'A good company falls because of temporary market fear.\n\n'
      'A strong investment declines because the entire sector is '
      'under pressure.\n\n'
      'Negative headlines create uncertainty.\n\n'
      'In these moments, many investors feel the need to do something '
      'immediately.\n\n'
      'But sometimes the most disciplined decision is simply waiting '
      'and gathering more information.\n\n'
      'Your behavior suggests that you are building this skill, but '
      'there is still room to strengthen your patience.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before selling during a difficult period, try separating '
          'emotions from facts.\n\n'
          'Ask yourself:\n\n'
          'Has the company fundamentally changed?\n'
          'Is the investment idea still valid?\n'
          'Am I reacting to temporary market noise?\n\n'
          'Remember that volatility is a normal part of investing.\n\n'
          'Even excellent companies experience periods of decline.\n\n'
          'A useful habit is reviewing your original reason for '
          'buying.\n\n'
          'If the reason is still valid, a lower price does not '
          'automatically mean a mistake.\n\n'
          'Patience does not mean holding everything forever.\n\n'
          'It means giving a good investment enough time to prove '
          'itself while staying ready to change your decision when '
          'the facts truly change.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Successful investors are not those who never experience '
          'uncertainty.\n\n'
          'They are those who learn how to handle uncertainty without '
          'making rushed decisions.\n\n'
          'Patience is not doing nothing—it is choosing your actions '
          'carefully when the market tries to pressure you.',
    ),
  ],
);

const VerdictTier _tier61to80 = VerdictTier(
  title: 'Steady Investor',
  intro:
      'Your selling behavior demonstrates good emotional control and '
      'a growing ability to handle market uncertainty.\n\n'
      'You understand one of the most important lessons in '
      'investing:\n\n'
      'A falling stock price does not automatically mean a bad '
      'investment.\n\n'
      'Many investors can stay confident when markets are rising.\n\n'
      'The real test comes during difficult periods.\n\n'
      'When prices decline, negative headlines appear, and '
      'uncertainty increases, emotional decisions become much more '
      'tempting.\n\n'
      'Your behavior suggests that you are usually able to avoid '
      'panic reactions and give your investments time to develop.\n\n'
      'You appear more focused on the reasons behind your investments '
      'rather than short-term price movements.\n\n'
      'This does not mean every decision is perfect.\n\n'
      'No investor avoids mistakes completely.\n\n'
      'The difference is that disciplined investors do not let '
      'temporary market fear become the main reason for their '
      'actions.\n\n'
      'They evaluate the situation, review the facts, and make '
      'decisions based on their strategy.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Continue strengthening your decision-making process.\n\n'
          'Before selling a position, ask yourself:\n\n'
          'Has the business changed, or only the stock price?\n'
          'Would I still believe this was a good company if the '
          'market was closed tomorrow?\n'
          'Am I selling because of new information or because of '
          'temporary fear?\n\n'
          'Remember that patience does not mean refusing to sell.\n\n'
          'Sometimes selling is the correct decision.\n\n'
          'The key difference is the reason behind it.\n\n'
          'A strong investor sells because the investment thesis '
          'changed.\n\n'
          'An emotional investor sells because the market became '
          'uncomfortable.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Markets will always create moments of uncertainty.\n\n'
          'The ability to stay calm during those moments is a '
          'powerful investing advantage.\n\n'
          'A steady investor does not ignore risk—they understand it, '
          'evaluate it, and respond with a clear mind instead of '
          'fear.',
    ),
  ],
);

const VerdictTier _tier81to100 = VerdictTier(
  title: 'Market Survivor',
  intro:
      'Your investment behavior demonstrates a very high level of '
      'emotional control and patience during difficult market '
      'conditions.\n\n'
      'You understand one of the hardest lessons in investing:\n\n'
      'A temporary decline is not always a permanent loss.\n\n'
      'Many investors can stay confident when markets are rising.\n\n'
      'The real challenge appears when everything moves in the '
      'opposite direction.\n\n'
      'Prices fall.\n\n'
      'Negative headlines dominate the news.\n\n'
      'Fear spreads among investors.\n\n'
      'During these moments, emotions often become stronger than '
      'analysis.\n\n'
      'Your behavior shows that you are capable of staying focused '
      'during periods of extreme pressure.\n\n'
      'Instead of reacting immediately to falling prices, you appear '
      'to give your investments time and evaluate situations more '
      'carefully.\n\n'
      'This is one of the biggest differences between short-term '
      'reactions and long-term investing.\n\n'
      'A strong investor understands that market crashes are not '
      'only periods of risk.\n\n'
      'They can also create opportunities.\n\n'
      'When others are forced to make emotional decisions, patient '
      'investors often have the greatest advantage.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Continue protecting the habits that created this level of '
          'discipline.\n\n'
          'Even experienced investors should regularly review their '
          'decisions.\n\n'
          'Ask yourself:\n\n'
          'Has the business changed, or only the market price?\n'
          'Am I still confident in the original investment idea?\n'
          'Am I making this decision based on facts or emotions?\n\n'
          'Remember that patience does not mean holding every '
          'investment forever.\n\n'
          'A great investor is not afraid to change their mind when '
          'the facts change.\n\n'
          'The goal is not to avoid every mistake.\n\n'
          'The goal is to avoid making decisions because of temporary '
          'fear.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Every market cycle creates moments when investors are '
          'tested.\n\n'
          'Some investors react to fear.\n\n'
          'Others use patience as their advantage.\n\n'
          'The greatest strength of a long-term investor is not '
          'avoiding storms—it is having the discipline to stay '
          'focused while they pass.',
    ),
  ],
);

/// Picks the verdict tier for Panic. [score] is 0.0-1.0 (same convention
/// as [VerdictArchiveEntry.panicResistance]); [totalTrades] mirrors
/// [VerdictArchiveEntry.totalTrades] — 0 means no trade was ever made, so
/// the score never left its neutral 50 default.
VerdictTier panicTierFor(double score, int totalTrades) {
  if (totalTrades <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 40) return _tier21to40;
  if (pct <= 60) return _tier41to60;
  if (pct <= 80) return _tier61to80;
  return _tier81to100;
}
