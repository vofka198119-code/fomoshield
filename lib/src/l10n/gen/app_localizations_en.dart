// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navPortfolio => 'Portfolio';

  @override
  String get navStressTest => 'Stress Test';

  @override
  String get navProfile => 'Profile';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languagePickerSubtitle =>
      'Choose the language for the app\'s interface.';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authSignInSubtitle =>
      'Sign in to continue investing with discipline';

  @override
  String get authSignUpSubtitle =>
      'Start your journey to disciplined investing';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authCreateAccountButton => 'Create Account';

  @override
  String get authOr => 'or';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authPleaseFillFields => 'Please fill in all fields';

  @override
  String get authEmailAlreadyRegistered =>
      'A user with this email is already registered.';

  @override
  String get authEmailAlreadyRegisteredGoogle =>
      'This email is already registered. Try signing in, or use \"Continue with Google\" if that\'s how you signed up.';

  @override
  String get authCheckEmailConfirm =>
      'Please check your email to confirm registration.';

  @override
  String get authSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get authGoogleSignInFailed =>
      'Google sign-in failed. Please try again.';

  @override
  String authTooManyAttempts(int seconds) {
    return 'Too many attempts. Try again in $seconds seconds.';
  }

  @override
  String authWaitSeconds(int seconds) {
    return 'Please wait $seconds seconds before trying again.';
  }

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileNotSignedIn => 'Not signed in';

  @override
  String get profileAdminBadge => 'ADMIN';

  @override
  String get profilePremiumBadge => 'PREMIUM';

  @override
  String get profilePreferencesSection => 'Preferences';

  @override
  String get profileStatisticsSection => 'Statistics';

  @override
  String get profileStatDays => 'Days';

  @override
  String get profileStatCompanies => 'Companies';

  @override
  String get profileStatTests => 'Tests';

  @override
  String get profileLegalSection => 'Legal';

  @override
  String get profilePrivacyPolicy => 'Privacy Policy';

  @override
  String get profileTermsOfUse => 'Terms of Use';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteAccountTitle => 'Delete Account?';

  @override
  String get profileDeleteAccountBody =>
      'You\'ll have 14 days to restore your account after this. If you don\'t restore it within that window, your account and all your data — portfolios, watchlist, stress test history — will be permanently erased, with no way to recover it.';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileDelete => 'Delete';

  @override
  String get profileDeleteFailed =>
      'Could not delete account. Please try again.';

  @override
  String get premiumActive => 'Premium Active';

  @override
  String get premiumLifetime => 'Lifetime subscription';

  @override
  String get premiumExpired => 'Subscription expired';

  @override
  String premiumDaysRemaining(int days) {
    return '${days}d remaining';
  }

  @override
  String get premiumExpiredBadge => 'EXPIRED';

  @override
  String premiumDaysBadge(int days) {
    return '${days}d';
  }

  @override
  String get premiumBenefitSearches => 'Unlimited daily searches';

  @override
  String get premiumBenefitPortfolios => 'Up to 3 portfolios';

  @override
  String get premiumBenefitCapital => '\$50,000 starting capital';

  @override
  String get premiumBenefitStressTests => 'Up to 5 stress tests';

  @override
  String get premiumBenefitAdFree => 'Ad-free experience';

  @override
  String get tradeBuy => 'BUY';

  @override
  String get tradeSell => 'SELL';

  @override
  String get tradeDetailTitle => 'TRADE DETAIL';

  @override
  String get tradeNotFound => 'Trade not found';

  @override
  String get tradeOrderTypeLabel => 'Order Type';

  @override
  String get tradeMarketType => 'Market';

  @override
  String get tradeLimitPriceLabel => 'Limit Price';

  @override
  String get tradeStopPriceLabel => 'Stop Price';

  @override
  String get tradeSharesBoughtLabel => 'Shares Bought';

  @override
  String get tradeSharesSoldLabel => 'Shares Sold';

  @override
  String get tradePricePerShareLabel => 'Price per Share';

  @override
  String get tradeTotalValueLabel => 'Total Value';

  @override
  String get tradeDateLabel => 'Date';

  @override
  String get tradeRealizedPnlLabel => 'Realized P&L';

  @override
  String get disclaimerFooter =>
      'Disclaimer: F.O.M.O. Shield is for educational and entertainment purposes only. We are not registered investment advisors. All trading decisions are solely your responsibility. Past performance does not guarantee future results.';

  @override
  String get homeAddWidgets => 'Add widgets';

  @override
  String get homeWidgetSettingsTitle => 'Widget Settings';

  @override
  String get homeReset => 'Reset';

  @override
  String get homeWidgetShieldSignal => 'Shield Signal';

  @override
  String get homeWidgetWatchlist => 'Watchlist';

  @override
  String get homeWidgetMarketClock => 'Market Clock';

  @override
  String get homeWidgetPortfolio => 'My Portfolio';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get shieldSignalTitle => 'SHIELD SIGNAL';

  @override
  String get shieldSignalChange => 'CHANGE';

  @override
  String get shieldSignalChangePercent => 'CHANGE %';

  @override
  String get moodBullishTitle => 'Bullish Momentum';

  @override
  String get moodBullishBody =>
      'Buyers are clearly leading today\'s market. Strong demand is pushing prices higher across many companies, and positive news or growing optimism is encouraging investors to keep buying. Momentum is on the bulls\' side — just remember, even strong trends eventually slow down, so avoid chasing prices out of excitement.';

  @override
  String get moodSteadyClimbTitle => 'Steady Climb';

  @override
  String get moodSteadyClimbBody =>
      'Buyers have a slight advantage today. Demand is a little stronger than selling pressure, pushing the index higher. The move is healthy and controlled, with no signs of panic or excessive excitement — confidence is slowly building.';

  @override
  String get moodWaitingTitle => 'Waiting for Direction';

  @override
  String get moodWaitingBody =>
      'The market is taking a breath. Buyers and sellers are evenly matched, so prices are moving very little. Nothing unusual is happening right now — investors are simply waiting for the next piece of important news before choosing a direction.';

  @override
  String get moodCautionTitle => 'Growing Caution';

  @override
  String get moodCautionBody =>
      'Sellers have gained a small advantage. The market is drifting lower, but there are no signs of panic. Small pullbacks like this are a normal part of investing.';

  @override
  String get moodStormTitle => 'Storm Warning';

  @override
  String get moodStormBody =>
      'Fear is spreading through the market. Selling pressure is much stronger than buying, causing prices to fall quickly. Sharp declines can feel uncomfortable, but emotional decisions often make difficult days even worse.';

  @override
  String get watchlistTitle => 'WATCHLIST';

  @override
  String get watchlistEmpty => 'Nothing here yet';

  @override
  String get marketClockTitle => 'MARKET CLOCK';

  @override
  String get marketClockNewYorkTime => 'NEW YORK TIME';

  @override
  String get portfolioWidgetNoPortfolio => 'No portfolio';

  @override
  String get portfolioWidgetTitle => 'PORTFOLIO';

  @override
  String get portfolioBalanceLabel => 'PORTFOLIO BALANCE';

  @override
  String get portfolioCashLabel => 'CASH AVAILABLE';

  @override
  String get portfolioUnrealizedPnl => 'UNREALIZED P&L';

  @override
  String get targetLabel => 'TARGET';

  @override
  String get stressTestWidgetTitle => 'MY STRESS TEST';

  @override
  String get stressTestActiveTests => 'Active Tests';

  @override
  String get stressTestMyResults => 'MY RESULTS';

  @override
  String stressTestMoreCompleted(int count) {
    return '+$count more completed';
  }

  @override
  String get stressTestNoActiveTests => 'No active tests';

  @override
  String get stressTestStartNewTest => 'Start a new test from the bottom panel';

  @override
  String get stressTestGoPremium => 'GO PREMIUM';

  @override
  String get stressTestPremiumLowercase => 'premium';

  @override
  String stressTestActiveLabel(String duration) {
    return 'Active — $duration';
  }

  @override
  String get stressTestHubTitle => 'STRESS TEST';

  @override
  String get stressTestCompletedTestsSheetTitle => 'Completed Tests';

  @override
  String get stressTestActiveTestsTitle => 'ACTIVE TESTS';

  @override
  String get stressTestCompletedTestsTitle => 'COMPLETED TESTS';

  @override
  String get stressTestNoCompletedTestsYet => 'No completed tests yet';

  @override
  String get stressTestNoTestsYet => 'No stress tests yet';

  @override
  String get stressTestNoTestsHint =>
      'Tap the button above to start your first test';

  @override
  String get stressTestNewTest => 'New Stress Test';

  @override
  String stressTestActiveCountFree(int active, int max) {
    return '$active/$max active · Premium = 5 at once';
  }

  @override
  String get stressTestEmotionalResilience => 'Test your emotional resilience';

  @override
  String get stressTestLimitReachedTitle => 'Stress test limit reached';

  @override
  String get stressTestMaxSessionsReached =>
      'Maximum active test sessions reached';

  @override
  String stressTestArchiveSummary(String amount, int holdings, int trades) {
    return 'Final: $amount · $holdings holdings · $trades trades';
  }

  @override
  String get stressTestSessionNotFound => 'Session not found';

  @override
  String get stressTestSetupTitle => 'Stress Test Setup';

  @override
  String get stressTestDurationSectionTitle => 'TEST DURATION';

  @override
  String get stressTestStartButton => 'START STRESS TEST';

  @override
  String get stressTestSlot1Free =>
      'Test slot 1/2 free · Upgrade for 5 at once & no ads';

  @override
  String get stressTestSlot2Free =>
      'Test slot 2/2 free · Premium = 5 at once, no ads';

  @override
  String get stressTestAvailableCash => 'Available Cash';

  @override
  String stressTestOfTotal(String amount) {
    return 'of $amount total';
  }

  @override
  String stressTestCustomDays(int days) {
    return 'Custom ($days days)';
  }

  @override
  String get stressTestInfiniteMinWeeks => 'Infinite — Min. 2 weeks';

  @override
  String get stressTestPremiumFeatureTitle => 'Premium Feature';

  @override
  String get stressTestPremiumFeatureBody =>
      'This test duration is available exclusively to Premium subscribers. Upgrade to unlock unlimited possibilities.';

  @override
  String get stressTestUpgradeToPremium => 'Upgrade to Premium';

  @override
  String get stressTestNotNow => 'Not now';

  @override
  String get stressTestCustomDurationTitle => 'Custom Test Duration';

  @override
  String get stressTestCustomDurationWarning =>
      'Once started, a custom-duration test cannot be interrupted or stopped early. The simulation will run for the full period you select below.';

  @override
  String stressTestDaysCount(int days) {
    return '$days days';
  }

  @override
  String get stressTestMinDays => 'Min: 5 days';

  @override
  String get stressTestMaxDays => 'Max: 365 days';

  @override
  String get commonApply => 'Apply';

  @override
  String get stressTestPremiumFeatureAllCaps => 'PREMIUM FEATURE';

  @override
  String get stressTestRiskDisclaimerTitle => 'RISK & SIMULATION DISCLAIMER';

  @override
  String get stressTestScrollToAgree => 'Scroll to the end to agree';

  @override
  String get stressTestReadFullDisclaimer =>
      'You have read the full disclaimer';

  @override
  String get stressTestIAgreeStart => 'I Agree — Start Test';

  @override
  String get stressTestDisclaimerIntro =>
      'This stress test uses a specialized algorithmic engine that simulates extreme market scenarios, including prolonged bear trends, systemic crises, and complete financial market collapses.';

  @override
  String get stressTestDisclaimerAck =>
      'Before starting the simulation, please read and acknowledge the following:';

  @override
  String get stressTestBulletScenarios =>
      'Simulated Scenarios — The crashes, crises, and market movements generated by the engine are hypothetical mathematical models. They are designed to test portfolio resilience under stress and do not constitute a forecast of real market behavior.';

  @override
  String get stressTestBulletNotAdvice =>
      'Not Financial Advice — The final verdict, analytics, and any conclusions drawn from this test are for informational and educational purposes only. They do not constitute personalized investment advice, a recommendation to buy or sell assets, or any form of financial solicitation.';

  @override
  String get stressTestBulletObjective =>
      'Objective Mathematical Assessment — The final verdict and scoring are generated automatically. Our engine is built on recognized scientific methods (including Monte Carlo simulation, tail-risk analysis, and modern portfolio stress-testing models). The algorithm is fully independent: it eliminates human bias, emotion, or third-party commercial interests. However, it is important to remember that any mathematical model has its limitations and cannot predict absolutely every real-market scenario.';

  @override
  String get stressTestBulletLiability =>
      'Limitation of Liability — A positive test result (i.e., your portfolio successfully \"survived\" a simulated market crash) does not guarantee similar real-world performance. The platform and its developers assume no responsibility for your investment decisions, nor for any direct or indirect losses, including but not limited to loss of capital in real markets.';

  @override
  String get stressTestBulletPastPerformance =>
      'Past performance within this simulator does not guarantee, predict, or reflect real-world market outcomes. All trading activities in real life carry substantial risk and are made solely at your own discretion and responsibility.';

  @override
  String get stressTestEndOfDisclaimer => '▸ End of Disclaimer';

  @override
  String get stressTestUnlimitedTesting => 'Unlimited Testing';

  @override
  String get stressTestInfiniteUpsellBody =>
      'The Infinite duration stress test is available exclusively to Premium subscribers. Upgrade to unlock:';

  @override
  String get stressTestUpsellUnlimitedDuration => 'Unlimited test duration';

  @override
  String get stressTestUpsellFullCrashScenarios =>
      'Full market crash scenarios';

  @override
  String get stressTestUpsellAdvancedAnalytics =>
      'Advanced portfolio analytics';

  @override
  String get stressTestAccessTitle => 'Stress test access';

  @override
  String get stressTestPortfolioTitle => 'STRESS TEST PORTFOLIO';

  @override
  String get stressTestNotStartedYet => 'Test not started yet';

  @override
  String get stressTestGoBackToSetup => 'Go back to setup and start the test';

  @override
  String get stressTestGoToSetup => 'Go to Setup';

  @override
  String get stressTestStartBuildingPortfolio =>
      'Start Building Your Portfolio';

  @override
  String get stressTestTapToAddFirstPosition =>
      'Tap the + button to search stocks\nand add your first position.';

  @override
  String get stressTestSearchStocksHint => 'Search stocks to add...';

  @override
  String get stressTestGetVerdict => 'GET PSYCHOLOGIST VERDICT';

  @override
  String get stressTestNoAssetsYet => 'No assets yet';

  @override
  String get stressTestNoActivePositions => 'No active positions';

  @override
  String get stressTestTapToAddFirstAsset =>
      'Tap + to search and add your first asset';

  @override
  String get stressTestTapToBuyAssets => 'Tap (+) to buy assets';

  @override
  String get stressTestTestComplete => 'Test Complete';

  @override
  String get stressTestTimeRemaining => 'Time Remaining';

  @override
  String get stressTestElapsedTime => 'Elapsed Time';

  @override
  String stressTestCountdown(
    String days,
    String hours,
    String minutes,
    String seconds,
  ) {
    return '${days}d ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String stressTestEpochNumber(int number) {
    return 'Epoch #$number';
  }

  @override
  String get stressTestFinishTestButton => 'FINISH TEST';

  @override
  String get stressTestFinishTest => 'Finish Test';

  @override
  String get stressTestFinishTestConfirm =>
      'End this test now and get your verdict? This can\'t be undone.';

  @override
  String get stressTestFinalBalance => 'FINAL BALANCE';

  @override
  String get stressTestViewVerdict => 'VIEW PSYCHOLOGIST VERDICT';

  @override
  String get stressTestWidgetPortfolioBalance => 'Portfolio Balance';

  @override
  String get stressTestWidgetCashAvailable => 'Cash Available';

  @override
  String get stressTestWidgetPsychologyMeter => 'Psychology Meter';

  @override
  String get stressTestWidgetHoldings => 'Holdings';

  @override
  String get stressTestWidgetPriceChart => 'Price Chart';

  @override
  String get stressTestWidgetEpochs => 'Epochs';

  @override
  String get stressTestWidgetTradeHistory => 'Trade History';

  @override
  String get stressTestWidgetLimitOrders => 'My Limit Orders';

  @override
  String get stressTestWidgetTimer => 'Timer';

  @override
  String get stressTestInvestmentDisclaimerTitle =>
      'INVESTMENT DISCLAIMER\n& LIMITATION OF LIABILITY';

  @override
  String get stressTestInvestmentDisclaimerBody =>
      'This verdict is generated automatically by a mathematical model based solely on your simulated historical behavior within this closed testing environment. It is provided for educational and illustrative purposes only and does NOT constitute personalized investment, legal, or financial advice. Past performance within this simulator does not guarantee, predict, or reflect real-world market outcomes. Final financial decisions, asset purchases, or trading activities in real life carry substantial risk and are made solely at your own discretion and responsibility. The creators of F.O.M.O. Shield accept no liability for financial losses incurred in real-world trading.';

  @override
  String get stressTestIUnderstandAccept => 'I Understand & Accept';

  @override
  String get stressTestPsychologyMeterTitle => 'PSYCHOLOGY METER';

  @override
  String get stressTestStrategyScore => 'Strategy Score';

  @override
  String get stressTestPsychologyScore => 'Psychology Score';

  @override
  String get stressTestScoreLabel => 'SCORE';

  @override
  String get stressTestAnalyticsTotalTrades => 'Total Trades';

  @override
  String get stressTestAnalyticsTradesBuy => 'Trades Buy';

  @override
  String get stressTestAnalyticsTradesSell => 'Trades Sell';

  @override
  String get stressTestAnalyticsUnrealizedPnl => 'Unrealized P&L';

  @override
  String get stressTestAnalyticsRealizedPnl => 'Realized P&L';

  @override
  String get stressTestPriceChartTitle => 'PRICE CHART';

  @override
  String get stressTestChartNotEnoughData => 'Not enough data yet';

  @override
  String get stressTestChartNotEnoughDataForPeriod =>
      'Not enough data for this period';

  @override
  String get searchTitle => 'SEARCH';

  @override
  String get searchHint => 'Search ticker or company...';

  @override
  String get searchNoResults => 'No results';

  @override
  String get searchApiExhausted =>
      'The API key may be exhausted. Try again shortly.';

  @override
  String get searchErrorConnectionTimeout =>
      'Connection timed out. Check your internet.';

  @override
  String get searchErrorServerNotResponding =>
      'Server not responding. Try again.';

  @override
  String get searchErrorNoInternet => 'No internet connection.';

  @override
  String get searchErrorRateLimited =>
      'API limit reached. Please try again later.';

  @override
  String get searchErrorGeneric => 'Couldn\'t load results. Try again.';

  @override
  String get searchTopSp500 => 'TOP S&P 500';

  @override
  String get searchRecentlyViewed => 'RECENTLY VIEWED';

  @override
  String get searchTopCompaniesBuilding =>
      'Top companies list is still being built on the server.';

  @override
  String get searchTopCompaniesLoadError =>
      'Couldn\'t load top companies. Pull to retry shortly.';

  @override
  String get portfolioRenameMenu => 'Rename Portfolio';

  @override
  String get portfolioResetMenu => 'Reset Portfolio';

  @override
  String get portfolioDeleteMenu => 'Delete Portfolio';

  @override
  String get portfolioNoPortfoliosYet => 'No portfolios yet';

  @override
  String portfolioCreateFirstMsg(String amount) {
    return 'Create your first virtual portfolio\nwith $amount starting balance';
  }

  @override
  String get portfolioCreateButton => 'Create Portfolio';

  @override
  String get portfolioNameHint => 'e.g. Tech Growth';

  @override
  String get portfolioSave => 'Save';

  @override
  String get portfolioResetDialogTitle => 'Reset Portfolio?';

  @override
  String get portfolioResetDialogBody =>
      'All holdings and history will be cleared.\nBalance will be restored to its original amount.';

  @override
  String get portfolioDeleteDialogTitle => 'Delete Portfolio?';

  @override
  String get portfolioDeleteDialogBody =>
      'All holdings and history will be lost.';

  @override
  String get portfolioCannotDeleteLast =>
      'Cannot delete the last portfolio. Create a new one first.';

  @override
  String get portfolioNewDialogTitle => 'New Portfolio';

  @override
  String get portfolioFreeLimitOne =>
      'FREE limit: 1 portfolio. Upgrade to Premium (3).';

  @override
  String portfolioMaxReached(int max) {
    return 'Max $max portfolios reached.';
  }

  @override
  String get portfolioCreate => 'Create';

  @override
  String get portfolioAdditionalPromoTitle => 'Additional portfolio';

  @override
  String get portfolioSwitchedPromoTitle => 'Portfolio switched';

  @override
  String get portfolioCreateNewSlot => 'Create New Portfolio';

  @override
  String get commonFailedToLoad => 'Failed to load';

  @override
  String get commonOther => 'Other';

  @override
  String get commonLess => 'Less';

  @override
  String commonMoreCount(int count) {
    return 'More ($count)';
  }

  @override
  String get balanceRingLabel => 'BALANCE';

  @override
  String get targetGoalLabel => 'GOAL';

  @override
  String get targetLeftToGoal => 'LEFT TO GOAL';

  @override
  String get targetChangeGoal => 'Change Goal';

  @override
  String get targetSelectGoal => 'Select Goal';

  @override
  String get holdingsTitle => 'HOLDINGS';

  @override
  String get holdingsEmpty => 'No holdings yet';

  @override
  String get holdingsEmptyHint => 'Tap + to search and add your first holding';

  @override
  String sharesCount(String count) {
    return '$count shares';
  }

  @override
  String get tradeHistoryTitle => 'TRADE HISTORY';

  @override
  String get myLimitOrdersTitle => 'MY LIMIT ORDERS';

  @override
  String get myLimitOrdersSheetTitle => 'My Limit Orders';

  @override
  String get myLimitOrdersEmpty => 'You currently have no active orders';

  @override
  String myLimitOrdersSeeAll(int count) {
    return 'See all $count orders';
  }

  @override
  String get gicsSectorTechnology => 'Technology';

  @override
  String get gicsSectorFinancials => 'Financials';

  @override
  String get gicsSectorHealthCare => 'Health Care';

  @override
  String get gicsSectorConsumerDiscretionary => 'Consumer Discretionary';

  @override
  String get gicsSectorConsumerStaples => 'Consumer Staples';

  @override
  String get gicsSectorEnergy => 'Energy';

  @override
  String get gicsSectorIndustrials => 'Industrials';

  @override
  String get gicsSectorMaterials => 'Materials';

  @override
  String get gicsSectorCommunicationServices => 'Communication Services';

  @override
  String get gicsSectorRealEstate => 'Real Estate';

  @override
  String get gicsSectorUtilities => 'Utilities';

  @override
  String get testDuration1Week => '1 Week';

  @override
  String get testDuration1Month => '1 Month';

  @override
  String get testDuration3Months => '3 Months';

  @override
  String get testDurationInfinite => 'Infinite';

  @override
  String get testDurationCustom => 'Custom';

  @override
  String get stressTestAddAsset => 'Add Asset';

  @override
  String get stressTestConfirmPurchase => 'Confirm Purchase';

  @override
  String get stressTestSearchCompanyHint =>
      'Search company (e.g. Apple, Cola)...';

  @override
  String get stressTestSearchFailedError =>
      'Search failed. Check your connection.';

  @override
  String get stressTestTypeMinChars => 'Type at least 2 characters to search';

  @override
  String get stressTestNoResultsFound => 'No results found';

  @override
  String stressTestNoPriceData(String symbol) {
    return 'No price data available for $symbol.';
  }

  @override
  String stressTestFetchPriceError(String symbol) {
    return 'Could not fetch price for $symbol.';
  }

  @override
  String get stressTestNotEnoughCashError =>
      'Not enough cash or unable to trade.';

  @override
  String stressTestCurrentPriceLabel(String price) {
    return 'Current price: $price';
  }

  @override
  String get stressTestHowMuchInvest => 'How much do you want to invest?';

  @override
  String stressTestExceedsCash(String cash) {
    return 'Exceeds available cash ($cash)';
  }

  @override
  String stressTestBuyAmountWorth(String amount) {
    return 'Buy $amount worth';
  }

  @override
  String get stressTestChooseAnotherCompany => 'Choose another company';

  @override
  String get verdictTradeBreakdownTitle => 'TRADE BREAKDOWN';

  @override
  String get verdictSessionNotFound => 'Session not found';

  @override
  String get verdictTestDurationLabel => 'Test Duration';

  @override
  String verdictDurationDays(int days) {
    return '$days days';
  }

  @override
  String get verdictStatisticsTitle => 'STATISTICS';

  @override
  String get verdictTotalTradesLabel => 'Total Trades';

  @override
  String get verdictBoughtLabel => 'Bought';

  @override
  String get verdictSoldLabel => 'Sold';

  @override
  String get verdictTotalAssetsTitle => 'TOTAL ASSETS';

  @override
  String get verdictAssetsHeldTotalLabel => 'Assets Held (Total)';

  @override
  String get verdictAssetsAtEndLabel => 'Assets at Test End';

  @override
  String get verdictFinancialSummaryTitle => 'FINANCIAL SUMMARY';

  @override
  String get verdictStartingAmountLabel => 'Starting Amount';

  @override
  String get verdictTotalPnlLabel => 'Total P&L (Realized + Unrealized)';

  @override
  String verdictProfitableSellsLabel(int count) {
    return 'Profitable Sells ($count)';
  }

  @override
  String verdictLosingSellsLabel(int count) {
    return 'Losing Sells ($count)';
  }

  @override
  String get verdictFinalBalanceLabel => 'Final Balance';

  @override
  String get verdictScenariosTitle => 'SCENARIOS EXPERIENCED';

  @override
  String get verdictScenarioBull => 'Bull Trend';

  @override
  String get verdictScenarioBear => 'Bear Trend';

  @override
  String get verdictScenarioSideways => 'Sideways Market';

  @override
  String get verdictScenarioVolatility => 'Volatility';

  @override
  String get verdictScenarioRecovery => 'Recovery';

  @override
  String get verdictScenarioHype => 'Market Hype';

  @override
  String get verdictScenarioSpeculation => 'Speculation';

  @override
  String get verdictScenarioBlackSwan => 'Black Swan';

  @override
  String get verdictScenarioCrash => 'Crash';

  @override
  String get verdictCompaniesTitle => 'COMPANIES';

  @override
  String get verdictNoCompaniesTraded => 'No companies traded.';

  @override
  String get verdictNoTradesYet => 'No trades yet.';

  @override
  String get verdictTradeBreakdownDisclaimerTitle => 'Disclaimer';

  @override
  String get verdictTradeBreakdownDisclaimerBody =>
      'The results of this stress test are solely the results of a computer-generated simulation and are provided for educational and training purposes only. They are based on model-defined scenarios and historical market events and do not represent, predict, or guarantee the performance of any portfolio under real-world market conditions.\n\nActual market behavior, individual companies, and financial assets may differ substantially from the results of the simulation. Past market events and performance do not guarantee similar outcomes in the future.\n\nAny scores, ratings, verdicts, or other indicators presented in the test do not constitute investment, financial, or other professional advice, nor do they constitute a recommendation, offer, or solicitation to buy or sell any financial asset or serve as a basis for making investment decisions.\n\nAny decision made using or taking into account information provided by the application is made solely at the user\'s own discretion and risk. We do not guarantee profits and are not responsible for any financial losses, damages, or lost profits resulting from the use of the simulation or its results.\n\nThe purpose of the stress test is to help users learn about market scenarios, investment principles, and their own behavior in a simulated environment — not to predict the future.';
}
