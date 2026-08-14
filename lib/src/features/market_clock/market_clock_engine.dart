import 'dart:math' show pi;

// ---------------------------------------------------------------------------
// Market Clock engine — pure Dart, no network/UI. Computes NYSE trading
// phases, the 9 copy "windows", and the US market holiday calendar.
//
// Times below are always America/New_York wall-clock time ("ET"), computed
// manually (US DST: 2nd Sunday of March – 1st Sunday of November) rather
// than via a timezone-database package, since that's the only zone this
// feature ever needs and the DST rule has been stable since 2007.
// ---------------------------------------------------------------------------

enum MarketPhase { closed, preMarket, marketOpen, afterHours }

class MarketWindow {
  final String id;
  final String emoji;
  final String shortHeadline;
  final String shortDetail;
  final String fullTitle;
  final String timeRangeLabel;
  final MarketPhase phase;
  final int startMinute;
  final int endMinute;
  final String whatHappens;
  final String whyItMatters;
  final String? dangerForBeginner;
  final String whatToDo;
  final String? fomoShieldTip;
  // Shown only on non-trading windows (weekend/holiday) — nudges the user
  // toward Stress Test while the real market is closed.
  final String? stressTestPromoTitle;
  final String? stressTestPromoBody;

  const MarketWindow({
    required this.id,
    required this.emoji,
    required this.shortHeadline,
    required this.shortDetail,
    required this.fullTitle,
    required this.timeRangeLabel,
    required this.phase,
    required this.startMinute,
    required this.endMinute,
    required this.whatHappens,
    required this.whyItMatters,
    this.dangerForBeginner,
    required this.whatToDo,
    this.fomoShieldTip,
    this.stressTestPromoTitle,
    this.stressTestPromoBody,
  });
}

const List<MarketWindow> marketWindows = [
  MarketWindow(
    id: 'early-pre-market',
    emoji: '🌙',
    shortHeadline: 'Early Pre-Market',
    shortDetail: 'Low liquidity, risky spreads',
    fullTitle: 'Early Pre-Market',
    timeRangeLabel: '04:00 – 07:00',
    phase: MarketPhase.preMarket,
    startMinute: 240,
    endMinute: 420,
    whatHappens:
        'This is the earliest stage of trading. The stock market hasn\'t officially opened yet, but electronic trading has already begun.\n\n'
        'At this time, the market is mostly active with large investment funds, institutional traders, and companies reacting to overnight news.\n\n'
        'There are very few regular investors trading, which makes the market feel quiet and almost empty.\n\n'
        'Imagine walking into a supermarket an hour before it officially opens. Only a few people are inside, some shelves are still being stocked, and prices don\'t always reflect what they\'ll be later in the day.\n\n'
        'That\'s exactly what the market is like during the Early Pre-Market.',
    whyItMatters:
        'The biggest issue during this session is low liquidity.\n\n'
        'There simply aren\'t many buyers and sellers available.\n\n'
        'Because of that, the difference between the buying price and the selling price (called the spread) can become surprisingly large.\n\n'
        'For example, a stock may have closed yesterday at \$100, but the next available seller may only be willing to sell it for \$102.\n\n'
        'If you place a Market Order, your broker may execute the trade at that much higher price.\n\n'
        'You could lose money before the trading day has even begun.',
    dangerForBeginner:
        'Prices can jump sharply after a single large trade because there aren\'t enough orders to keep prices stable.\n\n'
        'This often creates dramatic moves on the chart that disappear once more traders join the market.\n\n'
        'Many beginners see a sudden spike and think:\n\n'
        '"The stock is taking off! I have to buy right now!"\n\n'
        'A few minutes later, the excitement fades and the price returns to where it started.',
    whatToDo:
        'If you\'re investing for the long term, the best decision is usually to wait.\n\n'
        'If you absolutely need to buy or sell during this session, always use a Limit Order.\n\n'
        'A Limit Order lets you choose the maximum price you\'re willing to pay, protecting you from unexpected price jumps.',
    fomoShieldTip:
        'If it feels like you\'re about to miss an incredible opportunity, you\'re probably looking at a low-liquidity move.\n\n'
        'Don\'t rush.\n\n'
        'Once the regular market opens, prices often become much more stable.',
  ),
  MarketWindow(
    id: 'pre-market-reports',
    emoji: '☕',
    shortHeadline: 'Pre-Market & News',
    shortDetail: 'High risk, earnings releases',
    fullTitle: 'Pre-Market',
    timeRangeLabel: '07:00 – 09:30',
    phase: MarketPhase.preMarket,
    startMinute: 420,
    endMinute: 570,
    whatHappens:
        'The market is waking up.\n\n'
        'More investors begin placing trades, banks analyze overnight developments, and traders prepare for the opening bell.\n\n'
        'This is also when many companies release their quarterly earnings, while the U.S. government often publishes important economic reports such as inflation, employment, and GDP data.\n\n'
        'One news release can move a stock by 10–20% before the market officially opens.',
    whyItMatters:
        'This is the period when the market tries to answer one important question:\n\n'
        '"Is today\'s news good or bad?"\n\n'
        'Thousands of investors read the same information but reach completely different conclusions.\n\n'
        'Some start buying.\n\n'
        'Others begin selling.\n\n'
        'Some decide to lock in profits.\n\n'
        'As a result, prices can change direction several times within just a few minutes.',
    dangerForBeginner:
        'This session is driven by emotions.\n\n'
        'A beginner may see a stock rising 12% before the opening bell and think:\n\n'
        '"If I don\'t buy now, I\'ll miss the opportunity."\n\n'
        'Ten minutes later, additional details appear...\n\n'
        'The stock suddenly drops instead.\n\n'
        'Situations like this happen far more often than most beginners expect.',
    whatToDo:
        'Use this time to prepare, not to react.\n\n'
        'Check which companies are reporting earnings today.\n\n'
        'Read the news.\n\n'
        'Review your investment plan.\n\n'
        'But don\'t try to predict where prices will move over the next five minutes.',
    fomoShieldTip:
        'Successful investors don\'t need to react first.\n\n'
        'Making calm, informed decisions is almost always better than chasing fast-moving prices.',
  ),
  MarketWindow(
    id: 'opening-bell',
    emoji: '🔔',
    shortHeadline: 'Opening Bell',
    shortDetail: 'Peak volatility, opening chaos',
    fullTitle: 'Opening Bell',
    timeRangeLabel: '09:30 – 10:30',
    phase: MarketPhase.marketOpen,
    startMinute: 570,
    endMinute: 630,
    whatHappens:
        'The New York Stock Exchange officially opens.\n\n'
        'Millions of investors from around the world begin trading at the same time.\n\n'
        'Orders that were placed overnight and during Pre-Market are executed.\n\n'
        'Banks, pension funds, investment firms, trading algorithms, and individual investors all become active together.\n\n'
        'Billions of dollars change hands during the first hour of trading.',
    whyItMatters:
        'This is usually the busiest hour of the entire trading day.\n\n'
        'Prices can move quickly in both directions.\n\n'
        'At first, it may look like the market has no clear direction.\n\n'
        'In reality, it\'s simply trying to find a fair price after processing all the overnight news.',
    dangerForBeginner:
        'The first 15–30 minutes are often called the most volatile part of the day.\n\n'
        'Even if you\'ve chosen an excellent company, its stock price may briefly fall before continuing higher later.\n\n'
        'Many beginners panic when they see those early red numbers and sell quality investments for no good reason.',
    whatToDo:
        'If you\'re new to investing, there\'s usually no need to trade immediately after the opening bell.\n\n'
        'Waiting just 20–30 minutes often allows the market to settle down.\n\n'
        'Once the initial wave of emotions passes, price movements become much easier to understand.',
    fomoShieldTip:
        'The market stays open all day.\n\n'
        'Great opportunities rarely disappear within the first few minutes, but emotional mistakes can last much longer.',
  ),
  MarketWindow(
    id: 'morning-session',
    emoji: '📈',
    shortHeadline: 'Morning Trend',
    shortDetail: 'Best time for calm trading',
    fullTitle: 'Morning Session',
    timeRangeLabel: '10:30 – 12:00',
    phase: MarketPhase.marketOpen,
    startMinute: 630,
    endMinute: 720,
    whatHappens:
        'The first hour of trading is over, and the market has finally settled down.\n\n'
        'Most of the emotional buying and selling has already happened. Large investment funds have made their decisions and are now carrying out their plans more steadily.\n\n'
        'If they decided to buy this morning, they\'ll likely continue buying throughout the session. If they decided to sell, they\'ll do it in a more controlled way.\n\n'
        'Price movements become smoother, and the market\'s overall direction is much easier to recognize.\n\n'
        'This is when the market stops reacting emotionally and starts behaving more rationally.',
    whyItMatters:
        'Many experienced investors consider this one of the best times to trade.\n\n'
        'There are plenty of buyers and sellers, which means orders are filled quickly and at fair prices.\n\n'
        'The difference between the buying and selling price (the spread) is usually very small, and unexpected price swings become less common.\n\n'
        'If the market has chosen a direction for the day, it\'s often much easier to see it during this session.',
    dangerForBeginner:
        'This is one of the safest periods of the trading day, but beginners still make one common mistake.\n\n'
        'They see that a stock has already moved a little and think:\n\n'
        '"I missed my chance."\n\n'
        'Or they notice a small pullback and assume something is wrong with the company.\n\n'
        'In reality, small price movements are completely normal.\n\n'
        'A stock doesn\'t need to stay perfectly still to be a good long-term investment.',
    whatToDo:
        'If you\'re investing for the long term, this is often one of the best times to place your planned trades.\n\n'
        'The market has already shown its direction, liquidity is high, and prices tend to be more stable than they were during the opening minutes.\n\n'
        'Stick to your investment plan instead of reacting to every small movement.',
    fomoShieldTip:
        'Good investing rarely requires perfect timing.\n\n'
        'If you\'ve done your research and understand why you\'re buying a company, a calm market is usually your best friend.',
  ),
  MarketWindow(
    id: 'lunch-hour',
    emoji: '🥪',
    shortHeadline: 'Lunch Hour',
    shortDetail: 'Quiet lull, low activity',
    fullTitle: 'Lunch Hour',
    timeRangeLabel: '12:00 – 14:00',
    phase: MarketPhase.marketOpen,
    startMinute: 720,
    endMinute: 840,
    whatHappens:
        'This is usually the quietest part of the trading day.\n\n'
        'Many professional traders take a lunch break, portfolio managers step away from their desks, and European markets begin closing for the day.\n\n'
        'With fewer active participants, trading volume drops noticeably.\n\n'
        'If the market felt like a rushing river this morning, it now feels more like a calm lake.',
    whyItMatters:
        'When fewer people are trading, prices tend to move much more slowly.\n\n'
        'Many stocks spend this period moving sideways without any clear direction.\n\n'
        'This isn\'t a sign that something is wrong.\n\n'
        'It\'s simply a natural part of the market\'s daily rhythm.\n\n'
        'Not every hour needs to be exciting.',
    dangerForBeginner:
        'Ironically, the biggest risk during Lunch Hour is boredom.\n\n'
        'Many beginners open their investing app, notice that nothing exciting is happening, and feel the urge to place a trade anyway.\n\n'
        'They aren\'t buying because they found a great investment.\n\n'
        'They\'re buying simply because they want to do something.\n\n'
        'These emotional "boredom trades" often become expensive lessons.',
    whatToDo:
        'If you\'re following a long-term investment plan, it\'s perfectly fine to make your scheduled purchases during this session.\n\n'
        'If you\'re just watching the market, use the quieter hours wisely.\n\n'
        'Read company reports.\n\n'
        'Research businesses you\'re interested in.\n\n'
        'Or simply take a break yourself.\n\n'
        'Sometimes, the best trade is the one you never make.',
    fomoShieldTip:
        'You don\'t have to trade every day to become a successful investor.\n\n'
        'Patience is one of the most valuable skills you can develop.',
  ),
  MarketWindow(
    id: 'mid-afternoon',
    emoji: '📊',
    shortHeadline: 'Afternoon Session',
    shortDetail: 'Steady trading, Fed reactions',
    fullTitle: 'Mid-Afternoon',
    timeRangeLabel: '14:00 – 15:30',
    phase: MarketPhase.marketOpen,
    startMinute: 840,
    endMinute: 930,
    whatHappens:
        'The market begins to wake up again.\n\n'
        'Traders return to their desks, trading activity increases, and prices become more active once again.\n\n'
        'On certain days, this is also when the U.S. Federal Reserve (the Fed) announces interest rate decisions or other important economic updates.\n\n'
        'These announcements can change the mood of the entire market within minutes.\n\n'
        'On quieter days, the market simply continues the trend that was established earlier in the morning.',
    whyItMatters:
        'By this point, the market has already absorbed most of the morning\'s news.\n\n'
        'If new economic data is released, large investors may quickly adjust their positions.\n\n'
        'This can create another wave of strong price movements.\n\n'
        'Understanding what\'s happening during this period helps you avoid being surprised by sudden volatility.',
    dangerForBeginner:
        'On a normal trading day, this session is relatively calm.\n\n'
        'However, on days when the Federal Reserve makes important announcements, volatility can increase dramatically.\n\n'
        'Stocks, indexes, and even the entire market may change direction within minutes.\n\n'
        'Many beginners see these sudden moves and jump into the market without understanding what caused them.\n\n'
        'Unfortunately, prices often reverse just as quickly.',
    whatToDo:
        'Before placing a trade, take a quick look at the economic calendar.\n\n'
        'If an important Federal Reserve announcement or major economic report is scheduled, consider waiting until the market has had time to react.\n\n'
        'On regular trading days, this is another excellent period for calm and well-planned investing.',
    fomoShieldTip:
        'Experienced investors know that they don\'t have to trade every market event.\n\n'
        'Sometimes protecting your money simply means waiting for the market to become clear again.',
  ),
  MarketWindow(
    id: 'power-hour',
    emoji: '⚡',
    shortHeadline: 'Power Hour',
    shortDetail: 'Final push, heavy volume',
    fullTitle: 'Power Hour',
    timeRangeLabel: '15:30 – 16:00',
    phase: MarketPhase.marketOpen,
    startMinute: 930,
    endMinute: 960,
    whatHappens:
        'The trading day is coming to an end.\n\n'
        'For the market, this is like the final minutes of a championship game—everyone wants to finish strong.\n\n'
        'Day traders begin closing their positions to avoid overnight risk.\n\n'
        'Large investment funds rebalance their portfolios before the closing bell.\n\n'
        'Trading algorithms execute thousands of remaining orders.\n\n'
        'As a result, trading activity increases rapidly, and the market becomes much more energetic.',
    whyItMatters:
        'Power Hour is usually the second busiest period of the entire trading day.\n\n'
        'Trading volume rises sharply, and price movements often become stronger and more decisive.\n\n'
        'Stocks that spent most of the day moving sideways may suddenly break out in one direction.\n\n'
        'Many daily highs and lows are set during the final hour before the market closes.',
    dangerForBeginner:
        'High activity also means higher volatility.\n\n'
        'A stock that looked stable all afternoon can suddenly jump or fall several percent within minutes.\n\n'
        'Many beginners mistake these fast moves for the beginning of a major trend.\n\n'
        'They rush to buy because they fear missing out...\n\n'
        'Or they panic and sell because they believe a crash has started.\n\n'
        'In reality, these moves are often caused by traders closing positions before the market closes—not by a change in the company\'s long-term value.',
    whatToDo:
        'If you\'re following a well-prepared investment plan, this can be a perfectly reasonable time to buy or sell.\n\n'
        'However, never make a decision simply because a price suddenly starts moving faster.\n\n'
        'Before placing an order, ask yourself one simple question:\n\n'
        '"Am I following my investment plan, or am I reacting to emotions?"\n\n'
        'If the answer is emotions, it\'s usually better to wait.',
    fomoShieldTip:
        'Not every dramatic price move is a great opportunity.\n\n'
        'Sometimes the smartest investor is simply the one who stays calm while everyone else is rushing.',
  ),
  MarketWindow(
    id: 'after-hours',
    emoji: '🌙',
    shortHeadline: 'After-Hours',
    shortDetail: 'Market closed, evening earnings',
    fullTitle: 'After-Hours',
    timeRangeLabel: '16:00 – 20:00',
    phase: MarketPhase.afterHours,
    startMinute: 960,
    endMinute: 1200,
    whatHappens:
        'The regular trading session has officially ended.\n\n'
        'For many people, it looks like the stock market is closed.\n\n'
        'In reality, electronic trading continues during the After-Hours session.\n\n'
        'This is also when many of the world\'s largest companies release their quarterly earnings reports.\n\n'
        'Companies like Apple, Microsoft, Amazon, Alphabet, Meta, and many others often publish their results shortly after the closing bell.\n\n'
        'Investors immediately begin reacting to the news.',
    whyItMatters:
        'A single earnings report can completely change how investors value a company.\n\n'
        'If the results are better than expected, the stock may jump 10–20%.\n\n'
        'If the company disappoints investors, the price can fall just as quickly.\n\n'
        'The challenge is that far fewer people are trading after hours.\n\n'
        'With lower liquidity, even relatively small orders can move prices significantly.',
    dangerForBeginner:
        'After-Hours trading is one of the riskiest times for beginners.\n\n'
        'Imagine a stock closed at \$100.\n\n'
        'After the earnings report, the next available seller wants \$112, while the highest buyer is only offering \$108.\n\n'
        'The gap between buying and selling prices becomes unusually wide.\n\n'
        'If you place a Market Order, you may end up paying far more than you expected.\n\n'
        'The first reaction to earnings is also heavily driven by emotion.\n\n'
        'Many investors read the headlines before they fully understand the report.\n\n'
        'Prices can swing dramatically several times before settling down.',
    whatToDo:
        'There\'s usually no reason to rush.\n\n'
        'Use this time to read the earnings report, understand what actually happened, and see how experienced investors are interpreting the results.\n\n'
        'Very often, the market finds a much more reasonable price after the regular session opens the next day.\n\n'
        'Patience is usually rewarded.',
    fomoShieldTip:
        'Missing the first five minutes after an earnings report rarely changes your long-term success.\n\n'
        'Making a calm decision is usually far more valuable than making a fast one.',
  ),
  MarketWindow(
    id: 'closed',
    emoji: '🛑',
    shortHeadline: 'Exchange Closed',
    shortDetail: 'No trading overnight',
    fullTitle: 'Market Closed',
    timeRangeLabel: '20:00 – 04:00',
    phase: MarketPhase.closed,
    startMinute: 1200,
    endMinute: 1440 + 240, // wraps past midnight to 04:00 next day
    whatHappens:
        'The market is now completely closed.\n\n'
        'Regular trading has ended, and no new trades are being executed.\n\n'
        'Behind the scenes, exchanges process millions of completed transactions, update records, and prepare their systems for the next trading day.\n\n'
        'For investors, this is the quietest part of the day.\n\n'
        'Prices stop moving.\n\n'
        'The noise disappears.\n\n'
        'And for the first time all day, there\'s no pressure to make immediate decisions.',
    whyItMatters:
        'This is the perfect time to think clearly.\n\n'
        'Without constantly watching prices rise and fall, it\'s much easier to focus on what really matters.\n\n'
        'Many experienced investors spend more time researching companies after the market closes than they spend actually trading.\n\n'
        'The best investment decisions are often made when the market is quiet—not when it\'s moving.',
    dangerForBeginner:
        'The biggest mistake beginners make during Market Closed isn\'t trading.\n\n'
        'It\'s overthinking.\n\n'
        'Many people spend hours reading endless headlines, trying to predict exactly what the market will do tomorrow.\n\n'
        'The truth is simple:\n\n'
        'Nobody knows.\n\n'
        'Good news doesn\'t always push prices higher.\n\n'
        'Bad news doesn\'t always make stocks fall.\n\n'
        'Trying to predict every move usually creates unnecessary stress.',
    whatToDo:
        'Use this quiet time wisely.\n\n'
        'Review your portfolio.\n\n'
        'Read company earnings and annual reports.\n\n'
        'Learn more about the businesses you own—or plan to own.\n\n'
        'Check whether your investments still match your long-term goals.\n\n'
        'And finally...\n\n'
        'Get some rest.\n\n'
        'The market will always be there tomorrow, and clear decisions are much easier to make with a fresh mind.',
    fomoShieldTip:
        'The best investors aren\'t the ones who spend all day watching charts.\n\n'
        'They\'re the ones who truly understand the businesses they invest in—and have the patience to stick with their plan.',
  ),
];

/// Shown all day on weekends instead of the nightly `closed` window above —
/// that one's `timeRangeLabel` ("20:00 – 04:00") is only accurate for the
/// overnight gap on a normal trading day and reads as wrong/confusing if
/// shown at, say, 11:00 AM on a Sunday (real bug caught by the user
/// 2026-07-26: dial correctly showed 11:29 ET but the copy said
/// "20:00 – 04:00"). This window's label covers the whole day instead.
/// Split from a combined weekend/holiday window into its own entry so the
/// copy can speak specifically about the weekend — see [marketHolidayWindow]
/// for the exchange-holiday counterpart.
const weekendClosedWindow = MarketWindow(
  id: 'weekend-closed',
  emoji: '📅',
  shortHeadline: 'Weekend',
  shortDetail: 'Markets reopen Monday',
  fullTitle: 'Weekend',
  timeRangeLabel: 'Saturday – Sunday',
  phase: MarketPhase.closed,
  startMinute: 0,
  endMinute: 1440,
  whatHappens:
      'The U.S. stock market is closed for the weekend.\n\n'
      'No stocks are being bought or sold, prices aren\'t changing, and new orders won\'t be executed until the market reopens.\n\n'
      'This is a normal part of the market\'s schedule. Even the world\'s largest financial markets need time to pause.',
  whyItMatters:
      'While the market is closed, the world keeps moving.\n\n'
      'Companies continue running their businesses.\n\n'
      'Economic news is released.\n\n'
      'Political events can happen.\n\n'
      'By Monday morning, all of that information is reflected in stock prices.\n\n'
      'This is why markets sometimes open noticeably higher or lower after the weekend.',
  dangerForBeginner:
      'Many beginners spend the entire weekend worrying about what the market might do on Monday.\n\n'
      'They constantly read headlines and try to predict every possible outcome.\n\n'
      'The truth is that no one knows exactly how the market will open.\n\n'
      'Trying to guess every move usually creates stress—not better investment decisions.',
  whatToDo:
      'Weekends are a great opportunity to become a better investor.\n\n'
      'Review your portfolio.\n\n'
      'Read about the companies you own.\n\n'
      'Learn something new about investing.\n\n'
      'Or simply take a break and enjoy your weekend.\n\n'
      'A clear mind often leads to better decisions than watching charts all day.',
  fomoShieldTip:
      'Real markets may be closed today, but learning never takes a day off.',
  stressTestPromoTitle: 'While the market is closed...',
  stressTestPromoBody:
      'The Stress Test is always available.\n\n'
      'Practice building portfolios, reacting to market events, and making investment decisions without risking real money.\n\n'
      'The simulator is designed to help you understand how markets behave and build discipline before investing in live markets.\n\n'
      'Every trade inside Stress Test is completely independent of real market prices, so you can experiment, learn from mistakes, and improve with confidence.',
);

/// Shown all day on a full-closure exchange holiday (New Year's, MLK Day,
/// Independence Day, Thanksgiving, Christmas, etc.) — split out from
/// [weekendClosedWindow] so the copy can address a holiday specifically
/// rather than lumping it in with an ordinary weekend.
const marketHolidayWindow = MarketWindow(
  id: 'market-holiday',
  emoji: '🎉',
  shortHeadline: 'Market Holiday',
  shortDetail: 'Exchange closed for a holiday',
  fullTitle: 'Market Holiday',
  timeRangeLabel: 'All day',
  phase: MarketPhase.closed,
  startMinute: 0,
  endMinute: 1440,
  whatHappens:
      'Today the U.S. stock market is closed because of an official exchange holiday.\n\n'
      'No regular trading takes place, and orders will wait until the next trading session.\n\n'
      'This happens several times each year during major U.S. holidays.',
  whyItMatters:
      'A market holiday is not the same as a market problem.\n\n'
      'Nothing unusual is happening.\n\n'
      'Trading simply pauses according to the exchange calendar.\n\n'
      'However, news can still be released while the market is closed.\n\n'
      'When trading resumes, prices may adjust to everything that happened during the break.',
  dangerForBeginner:
      'Some beginners think the market is "frozen" because something bad has happened.\n\n'
      'In reality, exchange holidays are planned well in advance.\n\n'
      'There\'s no reason to worry just because trading is paused for the day.',
  whatToDo:
      'Take advantage of the quieter day.\n\n'
      'Read company reports.\n\n'
      'Review your investment goals.\n\n'
      'Organize your watchlist.\n\n'
      'Or spend some time improving your investing knowledge.\n\n'
      'Every experienced investor started by learning.',
  fomoShieldTip:
      'The best investors don\'t improve only when the market is open.\n\n'
      'They improve every day.',
  stressTestPromoTitle: 'Keep practicing',
  stressTestPromoBody:
      'Although the live market is closed, the Stress Test remains fully available.\n\n'
      'It\'s the perfect place to practice buying, selling, portfolio management, and emotional discipline without risking real money.\n\n'
      'You can explore different strategies, make mistakes safely, and better understand how markets react in different situations.\n\n'
      'When the real market opens again, you\'ll return with more experience and greater confidence.',
);

/// Shown instead of the normal Market-Open sub-windows on an early-close day
/// (Black Friday / Christmas Eve), covering the compressed 12:00–13:00 ET
/// stretch right before the 1:00 PM close. This is a v1 simplification —
/// the 5 normal sub-windows don't fit the shortened session, see
/// docs/MARKET_CLOCK_SPEC.md.
const earlyCloseWindow = MarketWindow(
  id: 'early-close-session',
  emoji: '⏳',
  shortHeadline: 'Early Close Day',
  shortDetail: 'Market closes at 1:00 PM ET',
  fullTitle: 'Early Close Day',
  timeRangeLabel: '12:00 – 13:00',
  phase: MarketPhase.marketOpen,
  startMinute: 720,
  endMinute: 780,
  whatHappens:
      'Today the exchange is operating on a shortened schedule and will close at 1:00 PM ET instead of 4:00 PM.',
  whyItMatters:
      'There\'s less time to get orders filled — trading activity and volume compress into a shorter window.',
  dangerForBeginner:
      'It\'s easy to forget about the early close and place an order that won\'t execute today.',
  whatToDo:
      'Plan your trades ahead of time and don\'t leave important orders for the second half of the day.',
  stressTestPromoTitle: 'Try it risk-free first',
  stressTestPromoBody:
      'A shortened, faster-moving session can feel unfamiliar. Practice it in Stress Test — no real money on the line, just real market conditions to learn from.',
);

MarketWindow? findWindowById(String id) {
  if (id == earlyCloseWindow.id) return earlyCloseWindow;
  if (id == weekendClosedWindow.id) return weekendClosedWindow;
  if (id == marketHolidayWindow.id) return marketHolidayWindow;
  for (final w in marketWindows) {
    if (w.id == id) return w;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Date/time helpers
// ---------------------------------------------------------------------------

DateTime nowInNewYork() {
  final utcNow = DateTime.now().toUtc();
  final offsetHours = _isEasternDaylightTime(utcNow) ? -4 : -5;
  return utcNow.add(Duration(hours: offsetHours));
}

bool _isEasternDaylightTime(DateTime utc) {
  final year = utc.year;
  final dstStartUtc = DateTime.utc(
    year,
    3,
    _nthWeekdayDay(year, 3, DateTime.sunday, 2),
    7,
  );
  final dstEndUtc = DateTime.utc(
    year,
    11,
    _nthWeekdayDay(year, 11, DateTime.sunday, 1),
    6,
  );
  return !utc.isBefore(dstStartUtc) && utc.isBefore(dstEndUtc);
}

int _nthWeekdayDay(int year, int month, int weekday, int n) {
  final first = DateTime(year, month, 1);
  final firstWeekdayOffset = (weekday - first.weekday + 7) % 7;
  return 1 + firstWeekdayOffset + (n - 1) * 7;
}

int _lastWeekdayDay(int year, int month, int weekday) {
  final firstOfNextMonth = month == 12
      ? DateTime(year + 1, 1, 1)
      : DateTime(year, month + 1, 1);
  final lastDay = firstOfNextMonth.subtract(const Duration(days: 1));
  final diff = (lastDay.weekday - weekday + 7) % 7;
  return lastDay.day - diff;
}

/// Anonymous Gregorian algorithm (Meeus/Jones/Butcher).
DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

DateTime _observedFixed(DateTime date) {
  if (date.weekday == DateTime.saturday)
    return date.subtract(const Duration(days: 1));
  if (date.weekday == DateTime.sunday) return date.add(const Duration(days: 1));
  return date;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool isWeekend(DateTime dateEt) =>
    dateEt.weekday == DateTime.saturday || dateEt.weekday == DateTime.sunday;

/// Full-closure NYSE holidays. Nth-weekday and Easter-derived dates are
/// recomputed for [dateEt]'s year, not hardcoded — see docs/MARKET_CLOCK_SPEC.md
/// for the source list. Deliberately does NOT include Columbus Day / Veterans
/// Day — NYSE trades normally on those (bond-market-only holidays).
bool isFullClosureHoliday(DateTime dateEt) {
  final y = dateEt.year;
  final holidays = <DateTime>[
    _observedFixed(DateTime(y, 1, 1)), // New Year's Day
    DateTime(y, 1, _nthWeekdayDay(y, 1, DateTime.monday, 3)), // MLK Day
    DateTime(y, 2, _nthWeekdayDay(y, 2, DateTime.monday, 3)), // Presidents' Day
    _easterSunday(y).subtract(const Duration(days: 2)), // Good Friday
    DateTime(y, 5, _lastWeekdayDay(y, 5, DateTime.monday)), // Memorial Day
    _observedFixed(DateTime(y, 6, 19)), // Juneteenth
    _observedFixed(DateTime(y, 7, 4)), // Independence Day
    DateTime(y, 9, _nthWeekdayDay(y, 9, DateTime.monday, 1)), // Labor Day
    DateTime(
      y,
      11,
      _nthWeekdayDay(y, 11, DateTime.thursday, 4),
    ), // Thanksgiving
    _observedFixed(DateTime(y, 12, 25)), // Christmas Day
  ];
  return holidays.any((d) => _isSameDate(d, dateEt));
}

/// Black Friday + Christmas Eve (skipped if Dec 24 itself lands on a
/// weekend — approximates the "may not apply" caveat from the source list).
bool isEarlyCloseDay(DateTime dateEt) {
  final y = dateEt.year;
  final thanksgiving = DateTime(
    y,
    11,
    _nthWeekdayDay(y, 11, DateTime.thursday, 4),
  );
  final blackFriday = thanksgiving.add(const Duration(days: 1));
  final christmasEve = DateTime(y, 12, 24);
  if (_isSameDate(dateEt, blackFriday)) return true;
  if (_isSameDate(dateEt, christmasEve) && !isWeekend(christmasEve))
    return true;
  return false;
}

class MarketClockState {
  final DateTime nowEt;
  final MarketPhase phase;
  final MarketWindow window;
  final bool isHoliday;
  final bool isEarlyCloseDay;

  const MarketClockState({
    required this.nowEt,
    required this.phase,
    required this.window,
    required this.isHoliday,
    required this.isEarlyCloseDay,
  });
}

MarketClockState resolveMarketClockState(DateTime nowEt) {
  final minuteOfDay = nowEt.hour * 60 + nowEt.minute;

  if (isWeekend(nowEt)) {
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.closed,
      window: weekendClosedWindow,
      isHoliday: true,
      isEarlyCloseDay: false,
    );
  }

  if (isFullClosureHoliday(nowEt)) {
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.closed,
      window: marketHolidayWindow,
      isHoliday: true,
      isEarlyCloseDay: false,
    );
  }

  final earlyClose = isEarlyCloseDay(nowEt);

  if (earlyClose) {
    if (minuteOfDay < 240 || minuteOfDay >= 1200) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.closed,
        window: marketWindows.last,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 570) {
      final w = minuteOfDay < 420 ? marketWindows[0] : marketWindows[1];
      return MarketClockState(
        nowEt: nowEt,
        phase: w.phase,
        window: w,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 630) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: marketWindows[2],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 720) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: marketWindows[3],
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    if (minuteOfDay < 780) {
      return MarketClockState(
        nowEt: nowEt,
        phase: MarketPhase.marketOpen,
        window: earlyCloseWindow,
        isHoliday: false,
        isEarlyCloseDay: true,
      );
    }
    return MarketClockState(
      nowEt: nowEt,
      phase: MarketPhase.afterHours,
      window: marketWindows[7],
      isHoliday: false,
      isEarlyCloseDay: true,
    );
  }

  for (final w in marketWindows) {
    if (w.id == 'closed') continue;
    if (minuteOfDay >= w.startMinute && minuteOfDay < w.endMinute) {
      return MarketClockState(
        nowEt: nowEt,
        phase: w.phase,
        window: w,
        isHoliday: false,
        isEarlyCloseDay: false,
      );
    }
  }

  return MarketClockState(
    nowEt: nowEt,
    phase: MarketPhase.closed,
    window: marketWindows.last,
    isHoliday: false,
    isEarlyCloseDay: false,
  );
}

// ---------------------------------------------------------------------------
// Ring geometry — 24h circular mapping, midnight at the top, clockwise.
// Returns a plain angle; callers with a Flutter BuildContext use their own
// Offset/cos/sin (via dart:math, already imported here for reference).
// ---------------------------------------------------------------------------

double angleForMinuteOfDay(int minute) => (minute / 1440) * 2 * pi - pi / 2;
