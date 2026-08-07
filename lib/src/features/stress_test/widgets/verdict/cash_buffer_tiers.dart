// ---------------------------------------------------------------------------
// Cash Buffer verdict tiers — keyed by `entry.strategyCashBuffer`
// (computeStrategySubScores in psychology_engine.dart: cash % of total
// portfolio value, linear 0% → score 0 up to 10%+ → score 100, no penalty
// for holding more). Formula deliberately left unchanged — see 2026-08-07
// discussion: this measures an investor's readiness for opportunities /
// resilience to panic-selling, not "idle cash is bad." A cash position
// above 10% is explicitly NOT penalized further (could be saving for a
// house, pre-crash reserve, between investments, etc — the app can't see
// that context). Same 0-20/21-45/46-70/71-90/91-100 banding as Safety
// Marker/Concentration. Shown on Session Complete's "STRATEGY" card
// ("?" -> VerdictMarkerDetailScreen). Short intro-only copy for now (scale
// given 2026-08-07, full long-form article to follow tier-by-tier same as
// the other markers).
// ---------------------------------------------------------------------------

import 'verdict_tier.dart';

const VerdictTier _tierNoData = VerdictTier(
  title: 'No Cash Data Yet',
  intro:
      'This test ended without any positions — there\'s no cash buffer '
      'to measure yet.',
);

const VerdictTier _tier0to20 = VerdictTier(
  title: 'Fully Invested',
  intro:
      'Every dollar in your portfolio is currently invested.\n\n'
      'At first glance, that may sound like the ideal strategy.\n\n'
      'After all, invested money has the potential to grow, while cash '
      'sitting on the sidelines does not.\n\n'
      'But investing isn\'t only about maximizing returns.\n\n'
      'It\'s also about being prepared for opportunities.\n\n'
      'Without a cash reserve, your portfolio has very little '
      'flexibility.\n\n'
      'If the market suddenly experiences a sharp correction, an '
      'outstanding company becomes deeply undervalued, or an '
      'unexpected opportunity appears, you may have no capital '
      'available to act.\n\n'
      'Instead of buying when prices become more attractive, you\'re '
      'forced to watch from the sidelines—or sell existing investments '
      'to free up cash.\n\n'
      'Neither is an ideal position.\n\n'
      'Cash is often misunderstood.\n\n'
      'Some investors see it as "money doing nothing."\n\n'
      'Experienced investors often see it as money waiting for the '
      'right opportunity.\n\n'
      'A cash buffer isn\'t there to outperform the market.\n\n'
      'It\'s there to give you choices when the market becomes '
      'unpredictable.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Consider keeping a small portion of your portfolio in cash '
          'instead of investing every available dollar immediately.\n\n'
          'You don\'t need a large reserve.\n\n'
          'Even a modest cash buffer can provide valuable flexibility '
          'during periods of market volatility.\n\n'
          'When attractive opportunities appear, you\'ll be able to act '
          'with confidence rather than regret missing them.\n\n'
          'Think of cash as part of your investment strategy—not as '
          'money that has failed to find a job.\n\n'
          'Sometimes the smartest investment decision is simply being '
          'ready for the next one.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Being fully invested may feel productive.\n\n'
          'Being prepared is often even more valuable.\n\n'
          'Cash doesn\'t exist to maximize today\'s returns. It exists '
          'to give you the freedom to invest when tomorrow\'s '
          'opportunities arrive.',
    ),
  ],
);

const VerdictTier _tier21to45 = VerdictTier(
  title: 'Very Limited Flexibility',
  intro:
      'Your portfolio includes a small cash reserve, which is a step in '
      'the right direction.\n\n'
      'However, your available cash is still quite limited.\n\n'
      'It may be enough to make a small purchase, but probably not '
      'enough to take full advantage of a meaningful market correction '
      'or a rare investment opportunity.\n\n'
      'One of the biggest advantages of holding cash isn\'t earning a '
      'return.\n\n'
      'It\'s having the ability to act when others cannot.\n\n'
      'Markets don\'t announce when the next opportunity is coming.\n\n'
      'A strong company can become temporarily undervalued overnight '
      'because of disappointing headlines, economic uncertainty, or '
      'broad market fear.\n\n'
      'Investors with available cash have options.\n\n'
      'Investors who are fully invested often have to choose between '
      'selling existing positions or watching the opportunity pass '
      'by.\n\n'
      'That\'s why a cash reserve isn\'t simply about money.\n\n'
      'It\'s about flexibility.\n\n'
      'The larger your financial cushion, the more freedom you have to '
      'make decisions based on opportunity instead of necessity.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'You don\'t need to keep a large percentage of your portfolio '
          'in cash.\n\n'
          'A modest reserve is often enough.\n\n'
          'As your portfolio grows, consider gradually setting aside a '
          'small amount of new contributions instead of investing '
          'every dollar immediately.\n\n'
          'Over time, this creates a financial cushion that can be '
          'used whenever exceptional opportunities appear.\n\n'
          'The goal isn\'t to predict market crashes.\n\n'
          'The goal is simply to be ready if they happen.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'Opportunities don\'t matter if you can\'t afford to take '
          'them.\n\n'
          'A small cash reserve may seem quiet and unproductive '
          'today—but when the market offers exceptional value, it can '
          'become one of the most powerful assets in your portfolio.',
    ),
  ],
);

const VerdictTier _tier46to70 = VerdictTier(
  title: 'Building a Safety Buffer',
  intro:
      'Your portfolio has started developing a healthy cash '
      'reserve.\n\n'
      'You are no longer fully dependent on your current investments '
      'to handle every market situation. A portion of your capital '
      'remains available, giving you more flexibility when '
      'opportunities or unexpected events appear.\n\n'
      'This is an important step in building a disciplined investment '
      'strategy.\n\n'
      'Many investors focus only on what they own.\n\n'
      'Experienced investors also think about what they can do '
      'next.\n\n'
      'Markets rarely move in a straight line.\n\n'
      'Periods of uncertainty, fear, and volatility are a normal part '
      'of investing. During these moments, having available cash can '
      'turn market stress into potential opportunity.\n\n'
      'A strong company temporarily drops in price.\n\n'
      'A broad market correction creates attractive valuations.\n\n'
      'An unexpected event causes fear among investors.\n\n'
      'These situations can reward investors who have the patience and '
      'resources to act.\n\n'
      'A cash buffer doesn\'t guarantee better returns.\n\n'
      'But it gives you something extremely valuable:\n\n'
      'Options.',
  sections: [
    TierSection(
      label: 'How Can You Improve?',
      body:
          'Your current cash position is becoming useful, but continue '
          'thinking about its purpose.\n\n'
          'Cash should have a role in your strategy.\n\n'
          'Ask yourself:\n\n'
          'Is this money reserved for opportunities?\n'
          'Is this a temporary waiting position before investing?\n'
          'Does this amount match my personal investment goals?\n\n'
          'The goal isn\'t to keep as much cash as possible.\n\n'
          'The goal is to find a balance where you feel prepared '
          'without allowing too much capital to remain inactive for '
          'long periods.\n\n'
          'A good investor knows when to invest.\n\n'
          'A great investor also knows when to wait.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market rewards patience, but patience requires '
          'flexibility.\n\n'
          'A cash reserve doesn\'t mean you are afraid of investing—it '
          'means you are prepared when investing opportunities appear.',
    ),
  ],
);

const VerdictTier _tier71to90 = VerdictTier(
  title: 'Ready for Opportunities',
  intro:
      'Your portfolio shows a strong understanding of one of the most '
      'overlooked parts of investing: flexibility.\n\n'
      'You have built a meaningful cash reserve while still keeping '
      'the majority of your capital invested.\n\n'
      'This balance is what many long-term investors aim for.\n\n'
      'Your money is working in the market, but you also have '
      'resources available when unexpected opportunities appear.\n\n'
      'Markets are driven by emotions.\n\n'
      'Periods of excitement can push prices too high.\n\n'
      'Periods of fear can create situations where excellent '
      'businesses temporarily trade at attractive prices.\n\n'
      'The difference between investors often isn\'t who can find '
      'opportunities.\n\n'
      'It\'s who has the ability to act when those opportunities '
      'arrive.\n\n'
      'A cash buffer gives you that ability.\n\n'
      'It allows you to make decisions based on your strategy rather '
      'than emotions.\n\n'
      'Instead of thinking:\n\n'
      '"I wish I could buy more right now."\n\n'
      'You have the possibility to say:\n\n'
      '"I prepared for this moment."\n\n'
      'That mindset can make a significant difference during difficult '
      'market periods.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Continue treating cash as a strategic tool, not just money '
          'waiting to be invested.\n\n'
          'Have a clear purpose for your reserve:\n\n'
          'Is it for market corrections?\n'
          'Is it for adding to your strongest companies?\n'
          'Is it for unexpected opportunities?\n\n'
          'The most effective investors don\'t keep cash because they '
          'are afraid of the market.\n\n'
          'They keep cash because they respect uncertainty.\n\n'
          'Just remember that cash is a tool, not the final '
          'destination.\n\n'
          'Over very long periods, businesses and productive assets '
          'are usually the main drivers of wealth creation.\n\n'
          'The goal is not to hold cash forever.\n\n'
          'The goal is to have enough flexibility to use it when it '
          'matters most.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'A prepared investor doesn\'t need to predict the next market '
          'move.\n\n'
          'They simply need to be ready when the market creates an '
          'opportunity.\n\n'
          'Cash doesn\'t replace investing—it gives your investing '
          'strategy room to breathe.',
    ),
  ],
);

const VerdictTier _tier91to100 = VerdictTier(
  title: 'Cash Gives You Options',
  intro:
      'Your portfolio demonstrates excellent cash management '
      'discipline.\n\n'
      'You have created a meaningful reserve while still keeping your '
      'capital working in the market.\n\n'
      'This balance represents an important investment skill that '
      'many investors overlook.\n\n'
      'Building wealth isn\'t only about finding great companies.\n\n'
      'It\'s also about being prepared for uncertainty.\n\n'
      'Markets will experience periods of excitement, fear, '
      'corrections, and unexpected events.\n\n'
      'No investor can predict exactly when these moments will '
      'arrive.\n\n'
      'But prepared investors don\'t need perfect timing.\n\n'
      'They need flexibility.\n\n'
      'Your cash reserve provides that flexibility.\n\n'
      'It gives you the ability to:\n\n'
      'take advantage of attractive opportunities;\n'
      'add to high-quality companies during market declines;\n'
      'avoid making emotional decisions during periods of '
      'uncertainty.\n\n'
      'Cash is often viewed as a weakness because it doesn\'t produce '
      'the same returns as invested assets.\n\n'
      'But that is only one side of the story.\n\n'
      'Cash has a different purpose.\n\n'
      'It provides patience.\n\n'
      'It provides control.\n\n'
      'It provides the ability to act when others are forced to wait.',
  sections: [
    TierSection(
      label: 'How Can You Make It Even Better?',
      body:
          'Continue using cash as a strategic tool rather than simply '
          'letting it accumulate without a purpose.\n\n'
          'A strong investor knows why they are holding cash.\n\n'
          'Is it for market opportunities?\n'
          'For adding to existing positions?\n'
          'For maintaining flexibility during uncertain periods?\n\n'
          'Having a plan helps prevent two common mistakes:\n\n'
          'Investing everything because of fear of missing out.\n\n'
          'Or holding too much cash because of fear of investing.\n\n'
          'The ideal amount depends on your personal strategy, goals, '
          'and comfort with market volatility.\n\n'
          'Remember, cash is not meant to replace investing.\n\n'
          'It\'s meant to support better investing decisions.',
    ),
    TierSection(
      label: 'One Last Thought',
      body:
          'The market rewards those who stay invested.\n\n'
          'But opportunities often reward those who are prepared.\n\n'
          'Cash doesn\'t make your portfolio stronger by sitting '
          'still—it makes your strategy stronger by giving you the '
          'freedom to act when it matters most.',
    ),
  ],
);

/// Picks the verdict tier for Cash Buffer. [score] is 0.0-1.0 (same
/// convention as [VerdictArchiveEntry.strategyCashBuffer]); [holdingCount]
/// mirrors [VerdictArchiveEntry.holdingCount] — 0 means no positions were
/// ever opened.
VerdictTier cashBufferTierFor(double score, int holdingCount) {
  if (holdingCount <= 0) return _tierNoData;
  final pct = score * 100;
  if (pct <= 20) return _tier0to20;
  if (pct <= 45) return _tier21to45;
  if (pct <= 70) return _tier46to70;
  if (pct <= 90) return _tier71to90;
  return _tier91to100;
}
