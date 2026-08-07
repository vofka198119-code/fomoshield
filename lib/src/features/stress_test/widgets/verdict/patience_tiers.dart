// ---------------------------------------------------------------------------
// Patience verdict tiers — keyed by `entry.patience`. A running behavioral
// score, starts at 50 neutral, moves on only two triggers (see
// psychology_engine.dart's evaluateSellTrade and psychology_profile.dart's
// recordCatastropheSurvived/recordHeldThroughCatastrophe, called from
// trades_engine.dart / noise_engine.dart):
//   +5  any realized SELL profit, flat regardless of size (paired 1:1
//       with Panic's own +5 profit bonus — same event)
//   +30 total, one-off per catastrophe epoch: fires the instant a Black
//       Swan/catastrophe epoch begins IF the investor still holds
//       positions and hasn't sold anything yet this catastrophe — +10 via
//       recordCatastropheSurvived (alongside Panic's own +15) and +20 via
//       recordHeldThroughCatastrophe, both gated by the same
//       catastropheSurvivalRecorded flag so it can only fire once per
//       catastrophe, right at its start — not after it's over.
// Third of the 3 behavioral pillars: Discipline judges the buy, Panic
// judges the sell under pressure, Patience judges the ability to do
// nothing when doing nothing is the hardest choice. Same even 20-point
// banding (0-20/21-40/41-60/61-80/81-100) as Discipline/Panic, confirmed
// 2026-08-07. Shown on Session Complete's own "PATIENCE" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Trades Yet',
  intro:
      'This test ended without any trades — there\'s no waiting '
      'behavior to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'Impatient Investor',
  intro:
      'Your investing behavior shows that patience may be one of the '
      'biggest areas for improvement.\n\n'
      'Investing is not only about finding good opportunities.\n\n'
      'It is also about giving your decisions enough time to work.\n\n'
      'The market constantly creates pressure to act:\n\n'
      'Prices move every day.\n\n'
      'News creates uncertainty.\n\n'
      'Other investors share their success stories.\n\n'
      'During these moments, it can feel like doing something is '
      'always better than waiting.\n\n'
      'But in investing, unnecessary actions can sometimes become the '
      'biggest mistake.\n\n'
      'A good investment does not always move higher immediately.\n\n'
      'Even strong companies can experience:\n\n'
      'temporary declines;\n'
      'difficult market conditions;\n'
      'periods when investors lose confidence.\n\n'
      'Your score suggests that you may sometimes react too quickly '
      'instead of allowing your investment ideas enough time to '
      'develop.\n\n'
      'The problem is not making changes.\n\n'
      'Successful investors sometimes sell, adjust, and improve their '
      'portfolios.\n\n'
      'The important question is:\n\n'
      '"Am I changing my decision because the facts changed, or '
      'because the situation became uncomfortable?"',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before making a quick decision, try creating a short '
          'waiting period.\n\n'
          'Ask yourself:\n\n'
          'Has the company actually become weaker?\n'
          'Did something fundamental change?\n'
          'Am I reacting to temporary market noise?\n'
          'Would I make the same decision if I ignored today\'s price '
          'movement?\n\n'
          'Try separating movement from meaning.\n\n'
          'A falling price does not always mean a bad investment.\n\n'
          'A rising price does not always mean a good investment.\n\n'
          'Strong investors understand that time is an important part '
          'of the investment process.\n\n'
          'Another useful habit is creating your rules before '
          'emotions appear:\n\n'
          'What would make me sell?\n'
          'How long am I willing to wait?\n'
          'What conditions would change my original idea?\n\n'
          'A calm plan created during normal conditions is much '
          'stronger than a decision made under pressure.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market rewards investors who can stay focused when '
          'others become impatient.\n\n'
          'Patience does not mean doing nothing.\n\n'
          'It means having the confidence to wait when waiting is the '
          'smartest decision.',
    ),
  ],
);

const VerdictTier _tier21to40 = VerdictTier(
  title: 'Short-Term Thinking',
  intro:
      'Your investing behavior shows that you are building patience, '
      'but difficult market situations may still create pressure '
      'that influences some of your decisions.\n\n'
      'You understand the importance of staying invested, but your '
      'actions suggest that uncertainty can sometimes make you want '
      'to change direction too quickly.\n\n'
      'This is a very common stage for investors.\n\n'
      'Many people understand the idea of long-term investing:\n\n'
      'buy quality assets;\n'
      'stay invested;\n'
      'ignore short-term noise.\n\n'
      'But understanding the concept and applying it during stressful '
      'moments are two different things.\n\n'
      'The market constantly tests patience.\n\n'
      'A company can have strong fundamentals, but the stock price '
      'may decline because of:\n\n'
      'market fear;\n'
      'economic uncertainty;\n'
      'temporary bad news;\n'
      'negative sentiment.\n\n'
      'During these periods, it is easy to focus only on the falling '
      'price and forget the original reason for the investment.\n\n'
      'Your score suggests that you sometimes allow short-term events '
      'to have too much influence on long-term decisions.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'The next step is developing a stronger connection between '
          'your investment decisions and your original strategy.\n\n'
          'Before making changes, ask yourself:\n\n'
          'Did the company actually become worse?\n'
          'Is this a permanent problem or a temporary situation?\n'
          'Would I still want to own this business if the price '
          'movement was hidden from me?\n\n'
          'Try reviewing your investments based on the business, not '
          'only the chart.\n\n'
          'A temporary decline can create discomfort.\n\n'
          'But discomfort alone is not always a reason to act.\n\n'
          'Remember:\n\n'
          'A long-term investor is not rewarded for reacting to every '
          'market movement.\n\n'
          'They are rewarded for making thoughtful decisions and '
          'allowing good ideas enough time to work.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market moves faster than any investor can predict.\n\n'
          'Trying to react to every movement often creates '
          'unnecessary mistakes.\n\n'
          'Patience is the ability to give your strategy enough time '
          'to prove itself instead of constantly changing direction '
          'with every market wave.',
    ),
  ],
);

const VerdictTier _tier41to60 = VerdictTier(
  title: 'Building Patience',
  intro:
      'Your investing behavior shows that you are developing the '
      'ability to stay calm during market uncertainty, but your '
      'patience is still a skill that continues to grow.\n\n'
      'You are beginning to understand an important investing '
      'principle:\n\n'
      'Not every market movement requires a reaction.\n\n'
      'Successful investing often requires the ability to wait.\n\n'
      'Wait for the right opportunity.\n\n'
      'Wait for the market to recognize value.\n\n'
      'Wait for a good business decision to develop over time.\n\n'
      'Your behavior suggests that you are not constantly reacting '
      'emotionally, but some situations may still create uncertainty '
      'and make you question your decisions.\n\n'
      'This is a normal stage of development for investors.\n\n'
      'The market rarely moves in a straight line.\n\n'
      'Even strong investments experience periods of:\n\n'
      'slow growth;\n'
      'temporary declines;\n'
      'negative sentiment;\n'
      'uncertainty.\n\n'
      'The challenge is learning when action is necessary and when '
      'patience is the better choice.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Continue building a clear decision process before making '
          'changes.\n\n'
          'When you feel the urge to sell or adjust your portfolio, '
          'ask:\n\n'
          'Is the business becoming weaker, or is the market simply '
          'reacting?\n'
          'Has my original investment idea changed?\n'
          'Am I making this decision because of facts or because of '
          'discomfort?\n\n'
          'Try to evaluate your investments based on the long-term '
          'picture.\n\n'
          'A temporary decline can feel uncomfortable, but discomfort '
          'is not always a signal that something is wrong.\n\n'
          'At the same time, patience does not mean ignoring '
          'problems.\n\n'
          'A patient investor still reviews decisions and changes '
          'direction when the facts truly change.\n\n'
          'The goal is not to hold everything forever.\n\n'
          'The goal is to avoid unnecessary actions caused by '
          'short-term emotions.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Patience is built through experience.\n\n'
          'Every market decline, every uncertain moment, and every '
          'difficult decision is a chance to improve.\n\n'
          'A patient investor is not someone who never acts.\n\n'
          'A patient investor knows when action is necessary—and when '
          'waiting is the smartest decision.',
    ),
  ],
);

const VerdictTier _tier61to80 = VerdictTier(
  title: 'Patient Investor',
  intro:
      'Your investing behavior demonstrates a strong ability to '
      'remain calm and focused during uncertain market conditions.\n\n'
      'You understand one of the most important lessons in long-term '
      'investing:\n\n'
      'Not every problem in the market requires immediate action.\n\n'
      'Many investors feel pressure to constantly make decisions.\n\n'
      'When prices rise, they feel the need to buy more.\n\n'
      'When prices fall, they feel the need to protect themselves.\n\n'
      'But experienced investors understand that sometimes the best '
      'decision is simply waiting and allowing time to work.\n\n'
      'Your behavior suggests that you are able to separate temporary '
      'market movements from real changes in the quality of an '
      'investment.\n\n'
      'You are more likely to evaluate situations instead of '
      'immediately reacting to emotions.\n\n'
      'This is a valuable skill because markets are designed to test '
      'investor patience.\n\n'
      'There will always be:\n\n'
      'unexpected declines;\n'
      'negative headlines;\n'
      'periods of uncertainty;\n'
      'moments when confidence is challenged.\n\n'
      'The ability to stay focused during these periods can become '
      'one of the biggest advantages an investor has.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Continue developing your investment process and protect '
          'the habits that created this level of patience.\n\n'
          'Before making changes, continue asking:\n\n'
          'Has the business actually changed?\n'
          'Is the original investment idea still valid?\n'
          'Am I making this decision because of new information or '
          'because of temporary market emotions?\n\n'
          'Remember that patience does not mean refusing to make '
          'decisions.\n\n'
          'A patient investor is still willing to sell when the facts '
          'change.\n\n'
          'The difference is that decisions come from analysis, not '
          'pressure.\n\n'
          'Keep focusing on the long-term picture instead of reacting '
          'to every short-term movement.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Markets will always create moments that test your '
          'confidence.\n\n'
          'The advantage does not belong to the investor who reacts '
          'to every change.\n\n'
          'It belongs to the investor who can stay focused, wait for '
          'the right moment, and allow good decisions enough time to '
          'work.',
    ),
  ],
);

const VerdictTier _tier81to100 = VerdictTier(
  title: 'Long-Term Mindset',
  intro:
      'Your investing behavior demonstrates an exceptional level of '
      'patience and emotional control.\n\n'
      'You understand one of the most powerful advantages in '
      'investing:\n\n'
      'Time is not just something investors wait for — it is '
      'something they use.\n\n'
      'Many investors focus on predicting the next market movement.\n\n'
      'They try to find the perfect entry point.\n\n'
      'They react to every headline.\n\n'
      'They worry about every temporary decline.\n\n'
      'But long-term investors understand that successful investing '
      'is often built through consistency, preparation, and the '
      'ability to stay focused when the market becomes '
      'unpredictable.\n\n'
      'Your behavior shows that you are capable of avoiding '
      'unnecessary reactions during difficult periods.\n\n'
      'Instead of immediately responding to fear or uncertainty, you '
      'allow your investment decisions time to develop.\n\n'
      'This is especially important during major market '
      'disruptions.\n\n'
      'When fear spreads, many investors make decisions based on '
      'emotion.\n\n'
      'They sell because they want to stop the discomfort.\n\n'
      'A patient investor understands that uncertainty is part of '
      'investing.\n\n'
      'They evaluate the situation, review the facts, and avoid '
      'changing direction simply because the market becomes '
      'stressful.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Maintaining patience is a strength, but even patient '
          'investors should continue reviewing their decisions.\n\n'
          'Remember:\n\n'
          'Patience does not mean holding every investment forever.\n\n'
          'A strong long-term investor still asks:\n\n'
          'Has the business changed?\n'
          'Is my original investment idea still valid?\n'
          'Am I holding because of confidence or because I refuse to '
          'admit a mistake?\n\n'
          'The goal is not to avoid every sale.\n\n'
          'The goal is to make sure decisions come from analysis '
          'rather than emotion.\n\n'
          'Continue balancing patience with awareness.\n\n'
          'The best investors are calm, but they are never careless.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market will always create moments of fear, excitement, '
          'and uncertainty.\n\n'
          'You cannot control the market.\n\n'
          'But you can control how you respond to it.\n\n'
          'The greatest advantage of a long-term investor is not '
          'predicting every storm.\n\n'
          'It is having the patience and confidence to stay focused '
          'while the storm passes.',
    ),
  ],
);

/// Picks the verdict tier for Patience. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.patience]); [totalTrades] mirrors
/// [VerdictArchiveEntry.totalTrades] — 0 means no trade was ever made, so
/// the score never left its neutral 50 default.
VerdictTier patienceTierFor(double score, int totalTrades) {
  if (totalTrades <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 40) return _tier21to40;
  if (pct <= 60) return _tier41to60;
  if (pct <= 80) return _tier61to80;
  return _tier81to100;
}
