// ---------------------------------------------------------------------------
// Discipline verdict tiers — keyed by `entry.discipline` (evaluateBuyTrade
// in psychology_engine.dart: a running behavioral score that only moves on
// BUY trades — starts at 50 neutral, +15/+8 for buying fear/recovery,
// −20 for buying macro hype, +5 bonus for keeping a 10%+ cash cushion
// after a dip buy, −10 for chasing a positive sector/company pump on the
// specific stock. Never touched by sells or by portfolio state — unlike
// Strategy/ETF/Cash Buffer, which are recomputed fresh from current
// holdings). Even 20-point bands (0-20/21-40/41-60/61-80/81-100) — NOT
// the 0-20/21-45/46-70/71-90/91-100 banding used by Safety
// Marker/Concentration/Cash Buffer, confirmed 2026-08-07. Shown on Session
// Complete's own "DISCIPLINE" card ("?" -> VerdictMarkerDetailScreen).
// Short intro-only copy for now (scale given 2026-08-07, full long-form
// article to follow tier-by-tier same as the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Trades Yet',
  intro:
      'This test ended without any buy trades — there\'s no buying '
      'behavior to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'Emotional Investor',
  intro:
      'Your investment decisions show a strong influence from market '
      'emotions.\n\n'
      'Investing is not only a test of financial knowledge.\n\n'
      'It is also a test of patience, discipline, and the ability to '
      'stay calm when the market becomes exciting or frightening.\n\n'
      'Your recent buying behavior suggests that emotions may '
      'sometimes be guiding your decisions more than a long-term '
      'strategy.\n\n'
      'This often happens during periods of strong market '
      'excitement.\n\n'
      'Prices are rising.\n\n'
      'Everyone is talking about a specific company or trend.\n\n'
      'The media is full of success stories.\n\n'
      'It can feel like the perfect moment to invest.\n\n'
      'But this is exactly when many investors make their biggest '
      'mistakes.\n\n'
      'Buying after a large price increase because of excitement can '
      'mean paying a premium when expectations are already extremely '
      'high.\n\n'
      'The problem is not buying successful companies.\n\n'
      'The problem is buying them without asking:\n\n'
      '"Am I investing because this business is attractive, or '
      'because everyone else is talking about it?"',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Before making a purchase, create a simple decision '
          'process.\n\n'
          'Ask yourself:\n\n'
          'Would I still buy this company if nobody was talking about '
          'it?\n'
          'Do I understand the business behind the stock price?\n'
          'Am I buying because of research or because I fear missing '
          'the opportunity?\n\n'
          'Strong investors do not try to avoid every opportunity.\n\n'
          'They try to separate real opportunities from emotional '
          'reactions.\n\n'
          'A useful habit is learning to wait.\n\n'
          'Sometimes the best investment decision is not buying '
          'immediately.\n\n'
          'Sometimes patience creates better opportunities than '
          'excitement.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market will always create exciting stories.\n\n'
          'But successful investing is rarely about following the '
          'loudest story.\n\n'
          'The strongest investors are not the ones who react '
          'fastest—they are the ones who can stay rational when '
          'everyone else becomes emotional.',
    ),
  ],
);

const VerdictTier _tier21to40 = VerdictTier(
  title: 'Learning Discipline',
  intro:
      'Your investment behavior shows that you are developing the '
      'habits of a disciplined investor, but emotional decisions may '
      'still influence some of your actions.\n\n'
      'You are no longer making purely impulsive decisions, but your '
      'investment process is still evolving.\n\n'
      'This stage is very common.\n\n'
      'Many investors understand the basic principles of investing:\n\n'
      'buy quality businesses;\n'
      'think long term;\n'
      'avoid unnecessary risks.\n\n'
      'But understanding these ideas and consistently following them '
      'are two different things.\n\n'
      'The market constantly tests investor discipline.\n\n'
      'When prices rise quickly, excitement appears.\n\n'
      'When prices fall sharply, fear takes over.\n\n'
      'The difficult part is not knowing what a disciplined investor '
      'should do.\n\n'
      'The difficult part is actually doing it when emotions are '
      'strongest.\n\n'
      'Your behavior shows signs of improvement, but there is still '
      'room to build a stronger decision-making process.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'The next step is creating rules that protect you from '
          'emotional decisions.\n\n'
          'Before buying, ask yourself:\n\n'
          'Am I buying because the business is attractive, or because '
          'the price is moving quickly?\n'
          'Would I still make this decision if the market was quiet?\n'
          'Do I have a reason for this purchase beyond recent '
          'performance?\n\n'
          'Another useful habit is keeping some flexibility.\n\n'
          'Great opportunities often appear when markets become '
          'uncomfortable.\n\n'
          'Investors who prepare in advance are usually better '
          'positioned than those who react emotionally in the '
          'moment.\n\n'
          'Discipline is not built from one perfect decision.\n\n'
          'It is built through repeating good decisions over time.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Becoming a disciplined investor is a process, not a single '
          'achievement.\n\n'
          'The goal is not to remove emotions completely—it is to '
          'make sure your strategy has a stronger voice than your '
          'emotions.',
    ),
  ],
);

const VerdictTier _tier41to60 = VerdictTier(
  title: 'Developing Investor',
  intro:
      'Your investment behavior shows a balanced approach.\n\n'
      'You are not consistently driven by market emotions, but you '
      'also have not yet developed a fully established discipline '
      'that guides every decision.\n\n'
      'This is a normal stage for many investors.\n\n'
      'Building a successful investment process takes time.\n\n'
      'It requires learning how to separate:\n\n'
      'opportunity from excitement;\n'
      'confidence from overconfidence;\n'
      'patience from hesitation.\n\n'
      'Your decisions show that you are beginning to understand the '
      'importance of timing and context.\n\n'
      'You are not simply reacting to every market movement, but '
      'there may still be moments when emotions influence your '
      'choices.\n\n'
      'The market constantly creates pressure.\n\n'
      'During strong rallies, it encourages investors to chase '
      'performance.\n\n'
      'During downturns, it encourages investors to wait for "perfect '
      'conditions."\n\n'
      'Both reactions can lead to missed opportunities.\n\n'
      'A disciplined investor understands that markets are '
      'unpredictable, but their own process can remain consistent.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Focus on building a repeatable investment routine.\n\n'
          'Before every purchase, define:\n\n'
          'Why am I buying this asset?\n'
          'What makes this company or investment attractive?\n'
          'Am I following my strategy or reacting to the current '
          'market mood?\n\n'
          'Try to judge decisions based on the reasoning behind '
          'them—not only on the result afterward.\n\n'
          'A good decision can sometimes lose money.\n\n'
          'A bad decision can sometimes make money.\n\n'
          'Discipline means focusing on the quality of the '
          'decision-making process.\n\n'
          'Over time, consistent habits become more valuable than '
          'individual wins or losses.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Every experienced investor was once learning how to '
          'control emotions and build confidence.\n\n'
          'Discipline is not something you are born with—it is a '
          'skill built through thousands of thoughtful decisions.',
    ),
  ],
);

const VerdictTier _tier61to80 = VerdictTier(
  title: 'Disciplined Investor',
  intro:
      'Your investment behavior demonstrates strong control over '
      'emotions and a thoughtful approach to decision-making.\n\n'
      'You understand one of the most difficult lessons in '
      'investing:\n\n'
      'The market does not reward the investor who reacts the '
      'fastest.\n\n'
      'It rewards the investor who can remain patient, analyze '
      'opportunities, and follow a clear strategy.\n\n'
      'Your buying decisions show that you are less influenced by '
      'short-term excitement and more focused on long-term '
      'reasoning.\n\n'
      'You appear more comfortable making decisions based on '
      'opportunity rather than emotion.\n\n'
      'When markets become uncertain, many investors freeze.\n\n'
      'When markets become exciting, many investors chase what is '
      'already popular.\n\n'
      'Your behavior shows a better balance.\n\n'
      'You recognize that fear can create opportunities, while '
      'excessive excitement can create unnecessary risk.\n\n'
      'This doesn\'t mean every decision will be perfect.\n\n'
      'No investor can predict the future.\n\n'
      'Discipline is not about always being right.\n\n'
      'It is about making decisions for the right reasons.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Continue strengthening the process behind your '
          'investments.\n\n'
          'Even disciplined investors can improve by regularly '
          'reviewing their decisions.\n\n'
          'Ask yourself:\n\n'
          'Did my original investment idea remain valid?\n'
          'Am I still following my long-term plan?\n'
          'Has my reason for owning this asset changed?\n\n'
          'Remember that discipline is not only about buying at the '
          'right moment.\n\n'
          'It is also about having the patience to hold quality '
          'investments through different market conditions.\n\n'
          'The strongest investors are not those who never make '
          'mistakes.\n\n'
          'They are those who have a process that helps them learn '
          'and improve.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Markets will always create fear and excitement.\n\n'
          'You cannot control those emotions around you.\n\n'
          'But you can control your response.\n\n'
          'A disciplined investor does not try to predict every '
          'market movement—they build habits that help them make '
          'better decisions regardless of the market environment.',
    ),
  ],
);

const VerdictTier _tier81to100 = VerdictTier(
  title: 'Contrarian Mindset',
  intro:
      'Your investment behavior demonstrates a high level of '
      'discipline and emotional control.\n\n'
      'You understand one of the hardest principles in investing:\n\n'
      'The best opportunities often appear when they feel the most '
      'uncomfortable.\n\n'
      'While many investors react to fear by selling and react to '
      'excitement by buying, your decisions show the ability to step '
      'back, analyze the situation, and act according to a '
      'strategy.\n\n'
      'You are not simply following the crowd.\n\n'
      'You recognize that markets are driven by emotions:\n\n'
      'Fear can push quality companies to attractive prices.\n\n'
      'Excitement can push expectations beyond realistic levels.\n\n'
      'A disciplined investor understands that price movements and '
      'business value are not always the same thing.\n\n'
      'When others focus only on what is happening today, you appear '
      'more focused on what could matter years from now.\n\n'
      'This mindset does not guarantee perfect results.\n\n'
      'No investor can predict every market movement.\n\n'
      'Even the most experienced investors make mistakes.\n\n'
      'The difference is that disciplined investors build a process '
      'that helps them avoid emotional decisions and stay focused on '
      'long-term goals.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Maintain the habits that helped you build this level of '
          'discipline.\n\n'
          'Continue asking important questions before every '
          'investment:\n\n'
          'Am I buying because the opportunity is attractive, or '
          'because everyone is excited?\n'
          'Does the business justify the price I am paying?\n'
          'Would I still make this decision if the market reacted '
          'negatively tomorrow?\n\n'
          'Remember that being a contrarian investor does not mean '
          'always going against the crowd.\n\n'
          'Sometimes the crowd is right.\n\n'
          'True discipline means having the confidence to disagree '
          'when the evidence supports it—and the humility to change '
          'your mind when the facts change.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market rewards patience, but patience requires '
          'courage.\n\n'
          'The greatest advantage an investor can have is not '
          'predicting the future—it is having the discipline to make '
          'rational decisions when emotions are at their strongest.',
    ),
  ],
);

/// Picks the verdict tier for Discipline. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.discipline]); [totalTrades] mirrors
/// [VerdictArchiveEntry.totalTrades] — 0 means no trade was ever made, so
/// the score never left its neutral 50 default.
VerdictTier disciplineTierFor(double score, int totalTrades) {
  if (totalTrades <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 40) return _tier21to40;
  if (pct <= 60) return _tier41to60;
  if (pct <= 80) return _tier61to80;
  return _tier81to100;
}
