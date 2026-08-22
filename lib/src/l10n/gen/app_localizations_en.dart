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
  String get updateChecking => 'Checking for updates...';

  @override
  String get updateUpToDate => "You're on the latest version";

  @override
  String get updateNewVersionAvailable => 'New Version Available';

  @override
  String updateYouHavePrevious(String version) =>
      'v$version (you have a previous version)';

  @override
  String get updateDownloadAndInstall => 'Download & Install';

  @override
  String get updateMaybeLater => 'Maybe Later';

  @override
  String updateDownloading(String version) => 'Downloading v$version...';

  @override
  String get updateCancel => 'Cancel';

  @override
  String get updateReadyToInstall => 'Ready to Install';

  @override
  String get updateInstall => 'Install';

  @override
  String get updateViewOnGithub => 'View on GitHub';

  @override
  String get updateInstallFailed =>
      'Couldn\'t install. Enable "Install unknown apps" for ScanCo in system settings and try again.';

  @override
  String get updateOpenSettings => 'Open settings';

  @override
  String get updateFromStore => 'Update from Store';

  @override
  String get updateRestarting => 'Restarting to apply the update…';

  @override
  String get updateDownloadApk => 'Download APK';

  @override
  String get updateDownloadIpa => 'Download IPA';

  @override
  String get updateDownloadPackage => 'Download package';

  @override
  String get updateOpenFailed =>
      'Downloaded — open the file from your Downloads folder.';

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
  String get searchOtherSector => 'OTHER';

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
  String get setGoalScreenTitleSet => 'SET GOAL';

  @override
  String get setGoalScreenTitleChange => 'CHANGE GOAL';

  @override
  String get setGoalScreenPrompt =>
      'What total portfolio value do you want to reach?';

  @override
  String setGoalScreenSubtitle(String amount) {
    return 'This is your target total balance, not extra profit on top. Minimum $amount.';
  }

  @override
  String get setGoalScreenSaveButton => 'Save Goal';

  @override
  String setGoalScreenMinimumTargetError(String amount) {
    return 'Minimum target is $amount';
  }

  @override
  String get setGoalScreenNotifTitleSet => 'Goal Set';

  @override
  String get setGoalScreenNotifTitleUpdated => 'Goal Updated';

  @override
  String setGoalScreenNotifDetailSet(String amount) {
    return 'Target set to $amount';
  }

  @override
  String setGoalScreenNotifDetailUpdated(String amount, String signed) {
    return 'New target $amount ($signed)';
  }

  @override
  String get verdictAccessLockedTitle => 'Renew Premium to view again';

  @override
  String get verdictAccessLockedDetail =>
      'You\'ve already used your one free look at this verdict after Premium expired. Renew Premium to view it again.';

  @override
  String get fundingModeTitle => 'How do you want to fund this test?';

  @override
  String get fundingModeLumpSumTitle => 'All at once';

  @override
  String get fundingModeLumpSumDetail =>
      'Start with the full \$15,000 right away.';

  @override
  String get fundingModeDcaTitle => 'Weekly deposits';

  @override
  String get fundingModeDcaDetail =>
      'Start with \$2,500, then simulate adding \$200 every week.';

  @override
  String get weeklyPayoutTitle => 'Weekly Deposit';

  @override
  String weeklyPayoutDetail(String amount) {
    return '$amount added to your portfolio — tap to view.';
  }

  @override
  String get weeklyPayoutPausedTitle => 'Weekly Deposit Paused';

  @override
  String get weeklyPayoutPausedDetail =>
      'Your premium subscription lapsed, so the weekly deposit is on hold — renew to resume it.';

  @override
  String get subscriptionUpgradedTitle => 'Welcome to Premium';

  @override
  String get subscriptionUpgradedDetail =>
      'Your account is now Premium — enjoy the extra perks.';

  @override
  String get subscriptionDowngradedTitle => 'Premium Expired';

  @override
  String get subscriptionDowngradedDetail =>
      'Your Premium subscription has ended — you\'re back on the Free plan.';

  @override
  String get portfolioTradeHistoryScreenPortfolioNotFound =>
      'Portfolio not found';

  @override
  String get portfolioTradeHistoryScreenNoTradesYet => 'No trades yet';

  @override
  String get portfolioWidgetsSettingsSheetTitle => 'Portfolio Widgets';

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

  @override
  String get verdictCashBufferNoDataTitle => 'No Cash Data Yet';

  @override
  String get verdictCashBufferNoDataIntro =>
      'This test ended without any positions — there\'s no cash buffer to measure yet.';

  @override
  String get verdictCashBufferTier1Title => 'Fully Invested';

  @override
  String get verdictCashBufferTier1Intro =>
      'Every dollar in your portfolio is currently invested.\n\nAt first glance, that may sound like the ideal strategy.\n\nAfter all, invested money has the potential to grow, while cash sitting on the sidelines does not.\n\nBut investing isn\'t only about maximizing returns.\n\nIt\'s also about being prepared for opportunities.\n\nWithout a cash reserve, your portfolio has very little flexibility.\n\nIf the market suddenly experiences a sharp correction, an outstanding company becomes deeply undervalued, or an unexpected opportunity appears, you may have no capital available to act.\n\nInstead of buying when prices become more attractive, you\'re forced to watch from the sidelines—or sell existing investments to free up cash.\n\nNeither is an ideal position.\n\nCash is often misunderstood.\n\nSome investors see it as \"money doing nothing.\"\n\nExperienced investors often see it as money waiting for the right opportunity.\n\nA cash buffer isn\'t there to outperform the market.\n\nIt\'s there to give you choices when the market becomes unpredictable.';

  @override
  String get verdictCashBufferTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictCashBufferTier1Section1Body =>
      'Consider keeping a small portion of your portfolio in cash instead of investing every available dollar immediately.\n\nYou don\'t need a large reserve.\n\nEven a modest cash buffer can provide valuable flexibility during periods of market volatility.\n\nWhen attractive opportunities appear, you\'ll be able to act with confidence rather than regret missing them.\n\nThink of cash as part of your investment strategy—not as money that has failed to find a job.\n\nSometimes the smartest investment decision is simply being ready for the next one.';

  @override
  String get verdictCashBufferTier1Section2Label => 'One Last Thought';

  @override
  String get verdictCashBufferTier1Section2Body =>
      'Being fully invested may feel productive.\n\nBeing prepared is often even more valuable.\n\nCash doesn\'t exist to maximize today\'s returns. It exists to give you the freedom to invest when tomorrow\'s opportunities arrive.';

  @override
  String get verdictCashBufferTier2Title => 'Very Limited Flexibility';

  @override
  String get verdictCashBufferTier2Intro =>
      'Your portfolio includes a small cash reserve, which is a step in the right direction.\n\nHowever, your available cash is still quite limited.\n\nIt may be enough to make a small purchase, but probably not enough to take full advantage of a meaningful market correction or a rare investment opportunity.\n\nOne of the biggest advantages of holding cash isn\'t earning a return.\n\nIt\'s having the ability to act when others cannot.\n\nMarkets don\'t announce when the next opportunity is coming.\n\nA strong company can become temporarily undervalued overnight because of disappointing headlines, economic uncertainty, or broad market fear.\n\nInvestors with available cash have options.\n\nInvestors who are fully invested often have to choose between selling existing positions or watching the opportunity pass by.\n\nThat\'s why a cash reserve isn\'t simply about money.\n\nIt\'s about flexibility.\n\nThe larger your financial cushion, the more freedom you have to make decisions based on opportunity instead of necessity.';

  @override
  String get verdictCashBufferTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictCashBufferTier2Section1Body =>
      'You don\'t need to keep a large percentage of your portfolio in cash.\n\nA modest reserve is often enough.\n\nAs your portfolio grows, consider gradually setting aside a small amount of new contributions instead of investing every dollar immediately.\n\nOver time, this creates a financial cushion that can be used whenever exceptional opportunities appear.\n\nThe goal isn\'t to predict market crashes.\n\nThe goal is simply to be ready if they happen.';

  @override
  String get verdictCashBufferTier2Section2Label => 'One Last Thought';

  @override
  String get verdictCashBufferTier2Section2Body =>
      'Opportunities don\'t matter if you can\'t afford to take them.\n\nA small cash reserve may seem quiet and unproductive today—but when the market offers exceptional value, it can become one of the most powerful assets in your portfolio.';

  @override
  String get verdictCashBufferTier3Title => 'Building a Safety Buffer';

  @override
  String get verdictCashBufferTier3Intro =>
      'Your portfolio has started developing a healthy cash reserve.\n\nYou are no longer fully dependent on your current investments to handle every market situation. A portion of your capital remains available, giving you more flexibility when opportunities or unexpected events appear.\n\nThis is an important step in building a disciplined investment strategy.\n\nMany investors focus only on what they own.\n\nExperienced investors also think about what they can do next.\n\nMarkets rarely move in a straight line.\n\nPeriods of uncertainty, fear, and volatility are a normal part of investing. During these moments, having available cash can turn market stress into potential opportunity.\n\nA strong company temporarily drops in price.\n\nA broad market correction creates attractive valuations.\n\nAn unexpected event causes fear among investors.\n\nThese situations can reward investors who have the patience and resources to act.\n\nA cash buffer doesn\'t guarantee better returns.\n\nBut it gives you something extremely valuable:\n\nOptions.';

  @override
  String get verdictCashBufferTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictCashBufferTier3Section1Body =>
      'Your current cash position is becoming useful, but continue thinking about its purpose.\n\nCash should have a role in your strategy.\n\nAsk yourself:\n\nIs this money reserved for opportunities?\nIs this a temporary waiting position before investing?\nDoes this amount match my personal investment goals?\n\nThe goal isn\'t to keep as much cash as possible.\n\nThe goal is to find a balance where you feel prepared without allowing too much capital to remain inactive for long periods.\n\nA good investor knows when to invest.\n\nA great investor also knows when to wait.';

  @override
  String get verdictCashBufferTier3Section2Label => 'One Last Thought';

  @override
  String get verdictCashBufferTier3Section2Body =>
      'The market rewards patience, but patience requires flexibility.\n\nA cash reserve doesn\'t mean you are afraid of investing—it means you are prepared when investing opportunities appear.';

  @override
  String get verdictCashBufferTier4Title => 'Ready for Opportunities';

  @override
  String get verdictCashBufferTier4Intro =>
      'Your portfolio shows a strong understanding of one of the most overlooked parts of investing: flexibility.\n\nYou have built a meaningful cash reserve while still keeping the majority of your capital invested.\n\nThis balance is what many long-term investors aim for.\n\nYour money is working in the market, but you also have resources available when unexpected opportunities appear.\n\nMarkets are driven by emotions.\n\nPeriods of excitement can push prices too high.\n\nPeriods of fear can create situations where excellent businesses temporarily trade at attractive prices.\n\nThe difference between investors often isn\'t who can find opportunities.\n\nIt\'s who has the ability to act when those opportunities arrive.\n\nA cash buffer gives you that ability.\n\nIt allows you to make decisions based on your strategy rather than emotions.\n\nInstead of thinking:\n\n\"I wish I could buy more right now.\"\n\nYou have the possibility to say:\n\n\"I prepared for this moment.\"\n\nThat mindset can make a significant difference during difficult market periods.';

  @override
  String get verdictCashBufferTier4Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictCashBufferTier4Section1Body =>
      'Continue treating cash as a strategic tool, not just money waiting to be invested.\n\nHave a clear purpose for your reserve:\n\nIs it for market corrections?\nIs it for adding to your strongest companies?\nIs it for unexpected opportunities?\n\nThe most effective investors don\'t keep cash because they are afraid of the market.\n\nThey keep cash because they respect uncertainty.\n\nJust remember that cash is a tool, not the final destination.\n\nOver very long periods, businesses and productive assets are usually the main drivers of wealth creation.\n\nThe goal is not to hold cash forever.\n\nThe goal is to have enough flexibility to use it when it matters most.';

  @override
  String get verdictCashBufferTier4Section2Label => 'One Last Thought';

  @override
  String get verdictCashBufferTier4Section2Body =>
      'A prepared investor doesn\'t need to predict the next market move.\n\nThey simply need to be ready when the market creates an opportunity.\n\nCash doesn\'t replace investing—it gives your investing strategy room to breathe.';

  @override
  String get verdictCashBufferTier5Title => 'Cash Gives You Options';

  @override
  String get verdictCashBufferTier5Intro =>
      'Your portfolio demonstrates excellent cash management discipline.\n\nYou have created a meaningful reserve while still keeping your capital working in the market.\n\nThis balance represents an important investment skill that many investors overlook.\n\nBuilding wealth isn\'t only about finding great companies.\n\nIt\'s also about being prepared for uncertainty.\n\nMarkets will experience periods of excitement, fear, corrections, and unexpected events.\n\nNo investor can predict exactly when these moments will arrive.\n\nBut prepared investors don\'t need perfect timing.\n\nThey need flexibility.\n\nYour cash reserve provides that flexibility.\n\nIt gives you the ability to:\n\ntake advantage of attractive opportunities;\nadd to high-quality companies during market declines;\navoid making emotional decisions during periods of uncertainty.\n\nCash is often viewed as a weakness because it doesn\'t produce the same returns as invested assets.\n\nBut that is only one side of the story.\n\nCash has a different purpose.\n\nIt provides patience.\n\nIt provides control.\n\nIt provides the ability to act when others are forced to wait.';

  @override
  String get verdictCashBufferTier5Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictCashBufferTier5Section1Body =>
      'Continue using cash as a strategic tool rather than simply letting it accumulate without a purpose.\n\nA strong investor knows why they are holding cash.\n\nIs it for market opportunities?\nFor adding to existing positions?\nFor maintaining flexibility during uncertain periods?\n\nHaving a plan helps prevent two common mistakes:\n\nInvesting everything because of fear of missing out.\n\nOr holding too much cash because of fear of investing.\n\nThe ideal amount depends on your personal strategy, goals, and comfort with market volatility.\n\nRemember, cash is not meant to replace investing.\n\nIt\'s meant to support better investing decisions.';

  @override
  String get verdictCashBufferTier5Section2Label => 'One Last Thought';

  @override
  String get verdictCashBufferTier5Section2Body =>
      'The market rewards those who stay invested.\n\nBut opportunities often reward those who are prepared.\n\nCash doesn\'t make your portfolio stronger by sitting still—it makes your strategy stronger by giving you the freedom to act when it matters most.';

  @override
  String get verdictConcentrationNoDataTitle => 'No Position Data Yet';

  @override
  String get verdictConcentrationNoDataIntro =>
      'This test ended without any positions — there\'s no concentration to measure yet.';

  @override
  String get verdictConcentrationTier1Title => 'One Company Holds Your Future';

  @override
  String get verdictConcentrationTier1Intro =>
      'Your portfolio may contain several excellent investments—but one company stands far above the rest.\n\nA single position represents such a large portion of your invested capital that its success or failure will have a disproportionate impact on your entire portfolio.\n\nThis is known as concentration risk.\n\nThe company itself may be outstanding.\n\nIt may be profitable, financially healthy, and a leader in its industry.\n\nBut no business is immune to unexpected challenges.\n\nA disappointing earnings report.\n\nA major product delay.\n\nNew competition.\n\nRegulatory changes.\n\nEconomic uncertainty.\n\nAny of these events can cause even the strongest companies to lose significant value in a short period of time.\n\nWhen too much of your portfolio depends on one stock, you\'re no longer investing in a collection of businesses.\n\nYou\'re placing a large part of your financial future on a single decision.\n\nEven legendary companies have experienced difficult years.\n\nHistory has repeatedly shown that today\'s market leader is not guaranteed to remain tomorrow\'s winner.\n\nGreat businesses deserve confidence.\n\nThey should never require blind faith.';

  @override
  String get verdictConcentrationTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictConcentrationTier1Section1Body =>
      'You don\'t need to sell your favorite company.\n\nIf you truly believe in its long-term future, there\'s nothing wrong with making it one of your largest holdings.\n\nThe key is making sure it isn\'t carrying your entire portfolio.\n\nAs you continue investing, consider directing new money toward other high-quality businesses instead of adding even more to your largest position.\n\nOver time, your portfolio will naturally become more balanced while allowing your strongest conviction to remain an important part of your strategy.\n\nA diversified portfolio doesn\'t reduce your confidence.\n\nIt reduces the consequences of being wrong.';

  @override
  String get verdictConcentrationTier1Section2Label => 'One Last Thought';

  @override
  String get verdictConcentrationTier1Section2Body =>
      'Every great investor has favorite companies.\n\nThe difference is that experienced investors rarely allow one stock to determine the outcome of their entire portfolio.\n\nBelieve in great businesses—but never let a single company hold your financial future in its hands.';

  @override
  String get verdictConcentrationTier2Title =>
      'Too Much Confidence in One Stock';

  @override
  String get verdictConcentrationTier2Intro =>
      'Your portfolio is becoming more diversified, but one investment still represents a much larger share of your capital than the rest.\n\nThis doesn\'t necessarily mean you\'ve chosen the wrong company.\n\nIn fact, it may be one of the strongest businesses in your portfolio.\n\nThe risk comes from relying too heavily on a single investment.\n\nNo matter how successful a company appears today, every business will eventually face challenges.\n\nMarkets change.\n\nCompetition evolves.\n\nConsumer demand shifts.\n\nNew technologies emerge.\n\nEven the world\'s most respected companies have experienced periods of disappointing performance.\n\nWhen one stock carries a large portion of your portfolio, those temporary setbacks can have an outsized effect on your overall results.\n\nThat\'s why concentration risk is about position size—not company quality.\n\nA fantastic business can still become a risky investment if too much of your portfolio depends on it.\n\nOwning more shares of your favorite company doesn\'t always make your portfolio stronger.\n\nSometimes it simply makes it less resilient.';

  @override
  String get verdictConcentrationTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictConcentrationTier2Section1Body =>
      'You don\'t need to reduce your confidence in your largest holding.\n\nInstead, allow the rest of your portfolio to catch up.\n\nAs you make future investments, consider allocating new capital to other financially strong companies rather than continuing to increase your biggest position.\n\nThis gradually improves your balance without forcing unnecessary sales.\n\nOver time, your portfolio becomes driven by the combined strength of many businesses instead of the performance of just one.';

  @override
  String get verdictConcentrationTier2Section2Label => 'One Last Thought';

  @override
  String get verdictConcentrationTier2Section2Body =>
      'It\'s perfectly reasonable to have a favorite company.\n\nJust don\'t let it become your entire investment strategy.\n\nThe strongest portfolios aren\'t built around one exceptional business—they\'re built around many great businesses working together.';

  @override
  String get verdictConcentrationTier3Title =>
      'A Portfolio Finding Its Balance';

  @override
  String get verdictConcentrationTier3Intro =>
      'Your portfolio is moving toward a healthier balance.\n\nNo single company completely dominates your investments, but one position still carries noticeably more weight than the others. While this isn\'t a major concern, it does mean that one business still has more influence over your long-term results than it probably should.\n\nThis is a common stage for many investors.\n\nAfter all, when a company consistently delivers strong financial results, it\'s only natural to feel confident investing more money into it.\n\nConfidence is important.\n\nOverconfidence is where risk begins.\n\nEven exceptional businesses experience difficult periods.\n\nA change in leadership, slowing growth, increased competition, changing regulations, or an unexpected economic downturn can temporarily affect even the strongest companies.\n\nIf one position grows too large, those setbacks become portfolio-wide events instead of ordinary fluctuations.\n\nFortunately, your portfolio is already well on its way to avoiding that problem.\n\nA few thoughtful investments in other high-quality companies can make a significant difference without changing the overall strategy you\'ve built.';

  @override
  String get verdictConcentrationTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictConcentrationTier3Section1Body =>
      'There\'s no need to reduce your largest position simply because it\'s your largest.\n\nInstead, focus on creating better balance over time.\n\nAs you continue investing, give slightly more attention to companies that currently represent a smaller part of your portfolio.\n\nAllow your future contributions—not emotional reactions—to shape your allocation.\n\nThis approach keeps your investment strategy disciplined while naturally reducing concentration risk.\n\nRemember, every new investment is an opportunity to strengthen your portfolio—not just increase the size of your favorite holding.';

  @override
  String get verdictConcentrationTier3Section2Label => 'One Last Thought';

  @override
  String get verdictConcentrationTier3Section2Body =>
      'Your goal isn\'t to find one company that carries your portfolio.\n\nIt\'s to build a collection of outstanding businesses that succeed together.\n\nA portfolio becomes stronger when its success is shared across many companies—not concentrated in just one.';

  @override
  String get verdictConcentrationTier4Title => 'Balanced Position Sizing';

  @override
  String get verdictConcentrationTier4Intro =>
      'Your portfolio demonstrates a strong understanding of risk management.\n\nNo single company has enough influence to determine the success or failure of your entire investment strategy. While some positions are naturally larger than others, your capital is distributed in a way that allows multiple businesses to contribute to your long-term results.\n\nThis is an important milestone.\n\nMany investors spend years searching for the \"perfect stock\" and gradually allow one position to grow so large that it begins to dominate their portfolio.\n\nYou have taken a different approach.\n\nRather than depending on a single company to carry your future returns, you\'ve built a portfolio where success can come from multiple sources.\n\nThat doesn\'t mean every company will perform equally well.\n\nSome will exceed expectations.\n\nOthers may disappoint.\n\nThat\'s perfectly normal.\n\nThe strength of a balanced portfolio comes from knowing that a setback in one investment doesn\'t automatically become a setback for your entire financial plan.\n\nThis gives your portfolio something every investor needs:\n\nResilience.';

  @override
  String get verdictConcentrationTier4Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictConcentrationTier4Section1Body =>
      'The most important thing now is maintaining the balance you\'ve already created.\n\nAs your investments grow, keep an eye on positions that begin significantly outperforming the rest of the portfolio.\n\nSometimes concentration risk develops slowly.\n\nA company performs exceptionally well, its share price rises for years, and before long it represents a much larger portion of the portfolio than originally intended.\n\nRegular reviews can help ensure that today\'s balanced portfolio remains balanced in the future.\n\nYou don\'t need perfect equality between positions.\n\nYou simply want to avoid allowing one company to gain too much control over your long-term outcome.';

  @override
  String get verdictConcentrationTier4Section2Label => 'One Last Thought';

  @override
  String get verdictConcentrationTier4Section2Body =>
      'A great portfolio doesn\'t need a hero.\n\nIt doesn\'t need one stock to save the day.\n\nInstead, it relies on the combined strength of many well-chosen businesses working together over time.\n\nWhen no single company can make or break your future, your portfolio becomes stronger, more stable, and better prepared for the unexpected.';

  @override
  String get verdictConcentrationTier5Title =>
      'No Single Company Controls Your Success';

  @override
  String get verdictConcentrationTier5Intro =>
      'Your portfolio reflects a disciplined and well-balanced approach to investing.\n\nNo individual company has been allowed to dominate your investments. Instead of placing all your confidence in a single business, you\'ve spread your capital across multiple high-quality companies, allowing each one to contribute to your long-term success.\n\nThis is one of the most effective ways to manage investment risk.\n\nNo matter how successful a company appears today, its future is never guaranteed.\n\nMarket leaders can lose their competitive edge.\n\nIndustries evolve.\n\nConsumer preferences change.\n\nUnexpected events can challenge even the strongest businesses.\n\nBy avoiding excessive concentration in any single position, you\'ve accepted one of the most important realities of investing:\n\nNo company deserves complete control over your financial future.\n\nThat\'s a mindset shared by many experienced long-term investors.\n\nThey understand that building wealth isn\'t about finding one stock that changes everything.\n\nIt\'s about owning a collection of outstanding businesses that work together through different market conditions and different stages of the economy.\n\nYour portfolio reflects that philosophy.\n\nRather than relying on one company to produce extraordinary returns, you\'ve built a structure where success is shared across many carefully selected investments.';

  @override
  String get verdictConcentrationTier5Section1Label =>
      'Keep Protecting Your Balance';

  @override
  String get verdictConcentrationTier5Section1Body =>
      'As your portfolio continues to grow, remember that concentration risk can appear without making a single new purchase.\n\nA company that performs exceptionally well may naturally become a much larger position over time.\n\nReview your allocation occasionally and make sure your portfolio still reflects your original strategy.\n\nOften, simply directing new investments toward your smaller positions is enough to maintain a healthy balance.\n\nThe goal isn\'t to keep every position identical.\n\nThe goal is to ensure that no single investment becomes more important than the portfolio itself.';

  @override
  String get verdictConcentrationTier5Section2Label => 'One Last Thought';

  @override
  String get verdictConcentrationTier5Section2Body =>
      'Every company tells part of your investment story.\n\nNone of them should write the entire ending.\n\nThe strongest portfolios aren\'t built around one brilliant investment—they\'re built around many great decisions working together over time.';

  @override
  String get verdictDisciplineNoDataTitle => 'No Trades Yet';

  @override
  String get verdictDisciplineNoDataIntro =>
      'This test ended without any buy trades — there\'s no buying behavior to measure yet.';

  @override
  String get verdictDisciplineTier1Title => 'Emotional Investor';

  @override
  String get verdictDisciplineTier1Intro =>
      'Your investment decisions show a strong influence from market emotions.\n\nInvesting is not only a test of financial knowledge.\n\nIt is also a test of patience, discipline, and the ability to stay calm when the market becomes exciting or frightening.\n\nYour recent buying behavior suggests that emotions may sometimes be guiding your decisions more than a long-term strategy.\n\nThis often happens during periods of strong market excitement.\n\nPrices are rising.\n\nEveryone is talking about a specific company or trend.\n\nThe media is full of success stories.\n\nIt can feel like the perfect moment to invest.\n\nBut this is exactly when many investors make their biggest mistakes.\n\nBuying after a large price increase because of excitement can mean paying a premium when expectations are already extremely high.\n\nThe problem is not buying successful companies.\n\nThe problem is buying them without asking:\n\n\"Am I investing because this business is attractive, or because everyone else is talking about it?\"';

  @override
  String get verdictDisciplineTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictDisciplineTier1Section1Body =>
      'Before making a purchase, create a simple decision process.\n\nAsk yourself:\n\nWould I still buy this company if nobody was talking about it?\nDo I understand the business behind the stock price?\nAm I buying because of research or because I fear missing the opportunity?\n\nStrong investors do not try to avoid every opportunity.\n\nThey try to separate real opportunities from emotional reactions.\n\nA useful habit is learning to wait.\n\nSometimes the best investment decision is not buying immediately.\n\nSometimes patience creates better opportunities than excitement.';

  @override
  String get verdictDisciplineTier1Section2Label => 'One Last Thought';

  @override
  String get verdictDisciplineTier1Section2Body =>
      'The market will always create exciting stories.\n\nBut successful investing is rarely about following the loudest story.\n\nThe strongest investors are not the ones who react fastest—they are the ones who can stay rational when everyone else becomes emotional.';

  @override
  String get verdictDisciplineTier2Title => 'Learning Discipline';

  @override
  String get verdictDisciplineTier2Intro =>
      'Your investment behavior shows that you are developing the habits of a disciplined investor, but emotional decisions may still influence some of your actions.\n\nYou are no longer making purely impulsive decisions, but your investment process is still evolving.\n\nThis stage is very common.\n\nMany investors understand the basic principles of investing:\n\nbuy quality businesses;\nthink long term;\navoid unnecessary risks.\n\nBut understanding these ideas and consistently following them are two different things.\n\nThe market constantly tests investor discipline.\n\nWhen prices rise quickly, excitement appears.\n\nWhen prices fall sharply, fear takes over.\n\nThe difficult part is not knowing what a disciplined investor should do.\n\nThe difficult part is actually doing it when emotions are strongest.\n\nYour behavior shows signs of improvement, but there is still room to build a stronger decision-making process.';

  @override
  String get verdictDisciplineTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictDisciplineTier2Section1Body =>
      'The next step is creating rules that protect you from emotional decisions.\n\nBefore buying, ask yourself:\n\nAm I buying because the business is attractive, or because the price is moving quickly?\nWould I still make this decision if the market was quiet?\nDo I have a reason for this purchase beyond recent performance?\n\nAnother useful habit is keeping some flexibility.\n\nGreat opportunities often appear when markets become uncomfortable.\n\nInvestors who prepare in advance are usually better positioned than those who react emotionally in the moment.\n\nDiscipline is not built from one perfect decision.\n\nIt is built through repeating good decisions over time.';

  @override
  String get verdictDisciplineTier2Section2Label => 'One Last Thought';

  @override
  String get verdictDisciplineTier2Section2Body =>
      'Becoming a disciplined investor is a process, not a single achievement.\n\nThe goal is not to remove emotions completely—it is to make sure your strategy has a stronger voice than your emotions.';

  @override
  String get verdictDisciplineTier3Title => 'Developing Investor';

  @override
  String get verdictDisciplineTier3Intro =>
      'Your investment behavior shows a balanced approach.\n\nYou are not consistently driven by market emotions, but you also have not yet developed a fully established discipline that guides every decision.\n\nThis is a normal stage for many investors.\n\nBuilding a successful investment process takes time.\n\nIt requires learning how to separate:\n\nopportunity from excitement;\nconfidence from overconfidence;\npatience from hesitation.\n\nYour decisions show that you are beginning to understand the importance of timing and context.\n\nYou are not simply reacting to every market movement, but there may still be moments when emotions influence your choices.\n\nThe market constantly creates pressure.\n\nDuring strong rallies, it encourages investors to chase performance.\n\nDuring downturns, it encourages investors to wait for \"perfect conditions.\"\n\nBoth reactions can lead to missed opportunities.\n\nA disciplined investor understands that markets are unpredictable, but their own process can remain consistent.';

  @override
  String get verdictDisciplineTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictDisciplineTier3Section1Body =>
      'Focus on building a repeatable investment routine.\n\nBefore every purchase, define:\n\nWhy am I buying this asset?\nWhat makes this company or investment attractive?\nAm I following my strategy or reacting to the current market mood?\n\nTry to judge decisions based on the reasoning behind them—not only on the result afterward.\n\nA good decision can sometimes lose money.\n\nA bad decision can sometimes make money.\n\nDiscipline means focusing on the quality of the decision-making process.\n\nOver time, consistent habits become more valuable than individual wins or losses.';

  @override
  String get verdictDisciplineTier3Section2Label => 'One Last Thought';

  @override
  String get verdictDisciplineTier3Section2Body =>
      'Every experienced investor was once learning how to control emotions and build confidence.\n\nDiscipline is not something you are born with—it is a skill built through thousands of thoughtful decisions.';

  @override
  String get verdictDisciplineTier4Title => 'Disciplined Investor';

  @override
  String get verdictDisciplineTier4Intro =>
      'Your investment behavior demonstrates strong control over emotions and a thoughtful approach to decision-making.\n\nYou understand one of the most difficult lessons in investing:\n\nThe market does not reward the investor who reacts the fastest.\n\nIt rewards the investor who can remain patient, analyze opportunities, and follow a clear strategy.\n\nYour buying decisions show that you are less influenced by short-term excitement and more focused on long-term reasoning.\n\nYou appear more comfortable making decisions based on opportunity rather than emotion.\n\nWhen markets become uncertain, many investors freeze.\n\nWhen markets become exciting, many investors chase what is already popular.\n\nYour behavior shows a better balance.\n\nYou recognize that fear can create opportunities, while excessive excitement can create unnecessary risk.\n\nThis doesn\'t mean every decision will be perfect.\n\nNo investor can predict the future.\n\nDiscipline is not about always being right.\n\nIt is about making decisions for the right reasons.';

  @override
  String get verdictDisciplineTier4Section1Label => 'How Can You Improve?';

  @override
  String get verdictDisciplineTier4Section1Body =>
      'Continue strengthening the process behind your investments.\n\nEven disciplined investors can improve by regularly reviewing their decisions.\n\nAsk yourself:\n\nDid my original investment idea remain valid?\nAm I still following my long-term plan?\nHas my reason for owning this asset changed?\n\nRemember that discipline is not only about buying at the right moment.\n\nIt is also about having the patience to hold quality investments through different market conditions.\n\nThe strongest investors are not those who never make mistakes.\n\nThey are those who have a process that helps them learn and improve.';

  @override
  String get verdictDisciplineTier4Section2Label => 'One Last Thought';

  @override
  String get verdictDisciplineTier4Section2Body =>
      'Markets will always create fear and excitement.\n\nYou cannot control those emotions around you.\n\nBut you can control your response.\n\nA disciplined investor does not try to predict every market movement—they build habits that help them make better decisions regardless of the market environment.';

  @override
  String get verdictDisciplineTier5Title => 'Contrarian Mindset';

  @override
  String get verdictDisciplineTier5Intro =>
      'Your investment behavior demonstrates a high level of discipline and emotional control.\n\nYou understand one of the hardest principles in investing:\n\nThe best opportunities often appear when they feel the most uncomfortable.\n\nWhile many investors react to fear by selling and react to excitement by buying, your decisions show the ability to step back, analyze the situation, and act according to a strategy.\n\nYou are not simply following the crowd.\n\nYou recognize that markets are driven by emotions:\n\nFear can push quality companies to attractive prices.\n\nExcitement can push expectations beyond realistic levels.\n\nA disciplined investor understands that price movements and business value are not always the same thing.\n\nWhen others focus only on what is happening today, you appear more focused on what could matter years from now.\n\nThis mindset does not guarantee perfect results.\n\nNo investor can predict every market movement.\n\nEven the most experienced investors make mistakes.\n\nThe difference is that disciplined investors build a process that helps them avoid emotional decisions and stay focused on long-term goals.';

  @override
  String get verdictDisciplineTier5Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictDisciplineTier5Section1Body =>
      'Maintain the habits that helped you build this level of discipline.\n\nContinue asking important questions before every investment:\n\nAm I buying because the opportunity is attractive, or because everyone is excited?\nDoes the business justify the price I am paying?\nWould I still make this decision if the market reacted negatively tomorrow?\n\nRemember that being a contrarian investor does not mean always going against the crowd.\n\nSometimes the crowd is right.\n\nTrue discipline means having the confidence to disagree when the evidence supports it—and the humility to change your mind when the facts change.';

  @override
  String get verdictDisciplineTier5Section2Label => 'One Last Thought';

  @override
  String get verdictDisciplineTier5Section2Body =>
      'The market rewards patience, but patience requires courage.\n\nThe greatest advantage an investor can have is not predicting the future—it is having the discipline to make rational decisions when emotions are at their strongest.';

  @override
  String get verdictEtfExposureNoDataTitle => 'No ETF Data Yet';

  @override
  String get verdictEtfExposureNoDataIntro =>
      'This test ended without any positions — there\'s no ETF exposure to measure yet.';

  @override
  String get verdictEtfExposureTier1Title => 'No Safety Net';

  @override
  String get verdictEtfExposureTier1Intro =>
      'Your portfolio is built entirely from individual stocks, with no exchange-traded funds (ETFs) to provide broader market exposure.\n\nThis isn\'t necessarily a bad strategy.\n\nMany successful investors have built impressive portfolios using only individual companies.\n\nThe challenge is that this approach asks much more from you.\n\nEvery investment decision becomes your responsibility.\n\nYou must identify strong businesses, avoid weak ones, manage diversification, monitor risk, and accept that a single mistake can have a much greater impact on your long-term results.\n\nAn ETF works differently.\n\nInstead of relying on the success of one company, it allows you to invest in dozens—or even hundreds—of businesses through a single investment.\n\nIf one company struggles, the others continue contributing to the portfolio.\n\nThis built-in diversification is one of the main reasons ETFs have become so popular among long-term investors.\n\nWithout at least one broad-market ETF, your portfolio has no automatic safety net.\n\nIts success depends entirely on your ability to consistently select winning companies over many years.\n\nThat\'s a difficult challenge—even for experienced investors.';

  @override
  String get verdictEtfExposureTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictEtfExposureTier1Section1Body =>
      'Consider adding a broad-market ETF as a foundation for your portfolio.\n\nAn ETF doesn\'t replace individual stock investing.\n\nIt complements it.\n\nThink of it as the stable core of your investment strategy, while individual companies become opportunities to seek additional growth.\n\nMany long-term investors combine both approaches:\n\nA diversified ETF provides stability.\n\nCarefully selected companies provide the potential to outperform the market.\n\nTogether, they create a portfolio that is both resilient and flexible.';

  @override
  String get verdictEtfExposureTier1Section2Label => 'One Last Thought';

  @override
  String get verdictEtfExposureTier1Section2Body =>
      'You don\'t need an ETF because individual stocks are bad.\n\nYou need one because no investor can predict every future winner.\n\nA single ETF won\'t make your portfolio exciting—but it can make it significantly more resilient for the decades ahead.';

  @override
  String get verdictEtfExposureTier2Title => 'A Step Toward Stability';

  @override
  String get verdictEtfExposureTier2Intro =>
      'Your portfolio now includes an ETF, and that\'s an important step toward building a more resilient investment strategy.\n\nBy adding broad market exposure, you\'ve reduced your dependence on individual companies and introduced an investment designed to spread risk across many businesses.\n\nThat\'s exactly what ETFs do best.\n\nWhile individual stocks can deliver exceptional returns, they can also disappoint for reasons that are impossible to predict.\n\nAn ETF helps balance that uncertainty by investing in a large group of companies instead of relying on the success of just one.\n\nThink of it as adding a strong foundation beneath the rest of your portfolio.\n\nAt the same time, a single ETF is only the beginning.\n\nYour portfolio still relies primarily on individual stock selection, meaning your long-term performance will continue to depend on the quality of the businesses you choose.\n\nThe ETF provides stability.\n\nYour stock selections provide the opportunity for additional growth.\n\nTogether, they create a healthier balance than either approach alone.';

  @override
  String get verdictEtfExposureTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictEtfExposureTier2Section1Body =>
      'Your portfolio is already moving in the right direction.\n\nAs it grows, consider whether a second ETF could complement your existing one.\n\nFor example, investors often combine a broad-market ETF with another fund focused on international markets, small-cap companies, bonds, or another area that isn\'t already represented.\n\nThe goal isn\'t to collect ETFs.\n\nThe goal is to make sure each one adds something genuinely different to your portfolio.\n\nQuality matters more than quantity.';

  @override
  String get verdictEtfExposureTier2Section2Label => 'One Last Thought';

  @override
  String get verdictEtfExposureTier2Section2Body =>
      'One ETF won\'t eliminate investment risk.\n\nNothing can.\n\nBut it can reduce the impact of unexpected events while giving your portfolio a stronger foundation to build upon.\n\nA solid investment strategy doesn\'t rely on one perfect company—it starts with a portfolio that can weather many different market conditions.';

  @override
  String get verdictEtfExposureTier3Title => 'A Strong Core';

  @override
  String get verdictEtfExposureTier3Intro =>
      'Your portfolio includes a healthy number of ETFs, creating a solid foundation for long-term investing.\n\nRather than relying entirely on individual stock selection, you\'ve chosen to combine broad market exposure with the flexibility to invest in companies you believe in. This is a strategy used by many experienced investors because it balances growth potential with sensible risk management.\n\nETFs offer something individual stocks cannot.\n\nInstant diversification.\n\nWith just a few funds, you can gain exposure to hundreds—or even thousands—of companies across different industries, countries, and sectors of the economy.\n\nThis helps reduce the impact that any single company can have on your overall portfolio while allowing the broader market to work in your favor over time.\n\nYour portfolio reflects that philosophy well.\n\nAt the same time, you\'ve avoided another common mistake—collecting too many ETFs.\n\nEvery fund in your portfolio appears to have a purpose instead of simply adding more investments for the sake of diversification.\n\nThat\'s an important distinction.\n\nA carefully chosen ETF should expand your exposure, not repeat what you already own.';

  @override
  String get verdictEtfExposureTier3Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictEtfExposureTier3Section1Body =>
      'The key now isn\'t adding more ETFs.\n\nIt\'s understanding what each one actually holds.\n\nBefore purchasing another fund, ask yourself:\n\nDoes this ETF provide exposure I don\'t already have?\nAm I adding diversification, or simply buying many of the same companies again?\nDoes this fund serve a clear purpose within my portfolio?\n\nA small collection of well-chosen ETFs is often more effective than owning dozens of overlapping funds.\n\nRemember, every investment should have a job.\n\nIf an ETF doesn\'t improve your portfolio in a meaningful way, it probably doesn\'t need to be there.';

  @override
  String get verdictEtfExposureTier3Section2Label => 'One Last Thought';

  @override
  String get verdictEtfExposureTier3Section2Body =>
      'Great portfolios aren\'t measured by how many ETFs they contain.\n\nThey\'re measured by how well those ETFs work together.\n\nA few carefully selected funds can provide the foundation for decades of investing—without making your portfolio unnecessarily complicated.';

  @override
  String get verdictEtfExposureTier4Title => 'Broadly Diversified';

  @override
  String get verdictEtfExposureTier4Intro =>
      'Your portfolio includes several ETFs, giving you exposure to a wide range of companies and markets.\n\nThat\'s a positive sign.\n\nBy investing through multiple funds, you\'ve reduced the risk of relying too heavily on individual businesses and created a portfolio that can benefit from different parts of the global economy.\n\nHowever, there comes a point where adding more ETFs doesn\'t always add more diversification.\n\nMany popular funds hold the same companies.\n\nFor example, it\'s common for several U.S. equity ETFs to own large positions in businesses like Apple, Microsoft, NVIDIA, Amazon, and other market leaders.\n\nAlthough the fund names may be different, much of the underlying portfolio can look surprisingly similar.\n\nThis is known as overlapping exposure.\n\nIt creates the impression of greater diversification while, in reality, many of your investments are following the same group of companies.\n\nYour portfolio is still well diversified, but it\'s worth making sure each ETF contributes something unique rather than repeating what you already own.';

  @override
  String get verdictEtfExposureTier4Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictEtfExposureTier4Section1Body =>
      'Before adding another ETF, take a moment to understand what it actually contains.\n\nAsk yourself:\n\nDoes this fund invest in companies I don\'t already own through another ETF?\nDoes it provide exposure to a different region, sector, or asset class?\nIs it adding genuine diversification, or simply increasing my exposure to the same businesses?\n\nSometimes replacing two similar ETFs with one broader fund can simplify your portfolio while providing nearly identical market exposure.\n\nA portfolio doesn\'t become stronger simply because it contains more funds.\n\nIt becomes stronger when every investment has a clear purpose.';

  @override
  String get verdictEtfExposureTier4Section2Label => 'One Last Thought';

  @override
  String get verdictEtfExposureTier4Section2Body =>
      'More ETFs don\'t always mean more diversification.\n\nSometimes they simply mean owning the same companies several times under different names.\n\nThe goal isn\'t to collect funds—it\'s to build a portfolio where every ETF adds something valuable that wasn\'t already there.';

  @override
  String get verdictEtfExposureTier5Title =>
      'Broad Diversification, Simple Strategy';

  @override
  String get verdictEtfExposureTier5Intro =>
      'Your portfolio contains a large number of ETFs, giving you exposure to a wide range of markets, industries, and companies.\n\nThere\'s nothing inherently wrong with this approach.\n\nIn fact, many investors choose to build their entire portfolio using ETFs because they offer excellent diversification, low maintenance, and broad exposure to the global economy.\n\nHowever, more ETFs don\'t automatically create a better portfolio.\n\nBeyond a certain point, many funds begin investing in the same companies.\n\nA U.S. market ETF, an S&P 500 ETF, a Large Cap ETF, and a Growth ETF may all hold significant positions in businesses like Apple, Microsoft, NVIDIA, Amazon, and other market leaders.\n\nAlthough your portfolio appears highly diversified, the underlying investments may overlap far more than you realize.\n\nThere\'s another trade-off worth understanding.\n\nETFs are designed to follow the market—not beat it.\n\nThey provide steady, diversified exposure, but they rarely deliver exceptional returns on their own.\n\nThat\'s why many investors combine a small number of broad ETFs with carefully selected individual companies.\n\nThe ETFs provide stability.\n\nThe individual businesses provide the opportunity to outperform the market.\n\nNeither approach is universally better.\n\nThey simply represent different investment philosophies.';

  @override
  String get verdictEtfExposureTier5Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictEtfExposureTier5Section1Body =>
      'Instead of asking whether you need another ETF, ask whether each ETF has a unique purpose.\n\nDoes it give you exposure to a market you don\'t already own?\n\nOr is it simply another way of buying many of the same companies?\n\nIf your goal is a simple, long-term portfolio, a handful of carefully selected ETFs is often enough.\n\nIf your goal is to outperform the market through stock selection, consider allowing your strongest individual companies to play a larger role while keeping ETFs as the stable core of your portfolio.\n\nThe objective isn\'t to own more funds.\n\nIt\'s to make every fund earn its place.';

  @override
  String get verdictEtfExposureTier5Section2Label => 'One Last Thought';

  @override
  String get verdictEtfExposureTier5Section2Body =>
      'A portfolio made entirely of ETFs can be an excellent long-term strategy.\n\nA portfolio combining ETFs and outstanding businesses can also be an excellent strategy.\n\nThe important question isn\'t how many ETFs you own.\n\nIt\'s whether each one adds something your portfolio didn\'t already have.\n\nDiversification is powerful. Complexity isn\'t always necessary.';

  @override
  String get verdictPanicNoDataTitle => 'No Trades Yet';

  @override
  String get verdictPanicNoDataIntro =>
      'This test ended without any trades — there\'s no selling behavior to measure yet.';

  @override
  String get verdictPanicTier1Title => 'Panic Seller';

  @override
  String get verdictPanicTier1Intro =>
      'Your selling behavior shows signs that fear may sometimes influence your investment decisions.\n\nInvesting is not only about choosing good companies.\n\nIt is also about having the patience and emotional control to stay with your decisions when the market becomes uncomfortable.\n\nOne of the most difficult moments for any investor is watching a position decline.\n\nThe natural reaction is to think:\n\n\"Maybe I made a mistake. Maybe I should get out before it gets worse.\"\n\nSometimes selling is the right decision.\n\nA company can lose its competitive advantage.\n\nThe business conditions can change.\n\nThe original investment idea may no longer be valid.\n\nBut selling only because the price is falling is a different situation.\n\nThe biggest losses for many investors do not come from buying bad companies.\n\nThey come from abandoning good investments during the most stressful moments.\n\nA panic sale often happens when fear reaches its highest point.\n\nUnfortunately, this is also the moment when many quality assets are trading at their lowest prices.\n\nYour score suggests that some selling decisions may have happened during periods of strong pressure, possibly close to the worst moments of the decline.';

  @override
  String get verdictPanicTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictPanicTier1Section1Body =>
      'Before selling a position at a loss, create a clear checklist.\n\nAsk yourself:\n\nHas the business actually become worse?\nHas the original reason for buying changed?\nAm I making this decision because of new information or because I am afraid?\n\nTry separating the stock price from the business itself.\n\nA falling price does not automatically mean a broken company.\n\nSometimes the market is simply reacting emotionally.\n\nAnother useful habit is creating rules before problems appear.\n\nFor example:\n\nWhy would I sell this company?\nWhat conditions would make me change my opinion?\nHow much volatility am I prepared to accept?\n\nA plan created during calm periods is often more reliable than a decision made during panic.';

  @override
  String get verdictPanicTier1Section2Label => 'One Last Thought';

  @override
  String get verdictPanicTier1Section2Body =>
      'The market will test every investor.\n\nPrices will fall.\n\nBad news will appear.\n\nFear will become loud.\n\nThe goal is not to never feel fear—the goal is to avoid letting fear make your investment decisions for you.';

  @override
  String get verdictPanicTier2Title => 'Emotional Selling';

  @override
  String get verdictPanicTier2Intro =>
      'Your investment behavior shows that you are learning to manage difficult market situations, but emotions may still influence some selling decisions.\n\nSelling is one of the hardest parts of investing.\n\nBuying a company often feels exciting.\n\nHolding during good times feels easy.\n\nBut watching a position decline tests patience, confidence, and trust in your own analysis.\n\nYour history suggests that some decisions may have been influenced by short-term pressure rather than a complete reassessment of the investment.\n\nThis does not mean every losing trade was a mistake.\n\nGood investors sometimes sell at a loss.\n\nThe difference is why they sell.\n\nA disciplined investor may accept a loss because:\n\nthe business changed;\nthe original investment idea is no longer valid;\na better opportunity appeared.\n\nAn emotional sale happens when the main reason is:\n\n\"I cannot handle this decline anymore.\"\n\nThe market often creates the strongest emotions near the most difficult moments.\n\nFear becomes louder.\n\nConfidence disappears.\n\nAnd many investors exit exactly when patience becomes the most valuable skill.';

  @override
  String get verdictPanicTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictPanicTier2Section1Body =>
      'Before selling during a decline, try to slow down the decision process.\n\nAsk yourself:\n\nAm I selling because the company became weaker?\nOr am I selling because the stock price makes me uncomfortable?\nWould I still make this decision if the market was not showing daily price movements?\n\nCreate your selling rules before emotions appear.\n\nA good investment plan should include not only:\n\n\"When should I buy?\"\n\nbut also:\n\n\"When should I sell?\"\n\nRemember that temporary price declines are a normal part of investing.\n\nThe important question is not:\n\n\"Did the price fall?\"\n\nThe important question is:\n\n\"Has the reason I invested changed?\"';

  @override
  String get verdictPanicTier2Section2Label => 'One Last Thought';

  @override
  String get verdictPanicTier2Section2Body =>
      'Every investor feels fear.\n\nThe difference between experienced investors and beginners is not the absence of fear.\n\nIt is the ability to make decisions with a clear mind even when fear is present.';

  @override
  String get verdictPanicTier3Title => 'Learning Patience';

  @override
  String get verdictPanicTier3Intro =>
      'Your selling behavior shows that you are developing better control over emotional decisions, but your ability to stay calm during difficult market periods is still improving.\n\nYou are no longer reacting purely from fear, but some situations may still create uncertainty and pressure.\n\nThis is a very common stage for investors.\n\nLearning to invest successfully is not only about knowing what to buy.\n\nIt is also about learning when not to act.\n\nMarkets constantly create situations that challenge confidence:\n\nA good company falls because of temporary market fear.\n\nA strong investment declines because the entire sector is under pressure.\n\nNegative headlines create uncertainty.\n\nIn these moments, many investors feel the need to do something immediately.\n\nBut sometimes the most disciplined decision is simply waiting and gathering more information.\n\nYour behavior suggests that you are building this skill, but there is still room to strengthen your patience.';

  @override
  String get verdictPanicTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictPanicTier3Section1Body =>
      'Before selling during a difficult period, try separating emotions from facts.\n\nAsk yourself:\n\nHas the company fundamentally changed?\nIs the investment idea still valid?\nAm I reacting to temporary market noise?\n\nRemember that volatility is a normal part of investing.\n\nEven excellent companies experience periods of decline.\n\nA useful habit is reviewing your original reason for buying.\n\nIf the reason is still valid, a lower price does not automatically mean a mistake.\n\nPatience does not mean holding everything forever.\n\nIt means giving a good investment enough time to prove itself while staying ready to change your decision when the facts truly change.';

  @override
  String get verdictPanicTier3Section2Label => 'One Last Thought';

  @override
  String get verdictPanicTier3Section2Body =>
      'Successful investors are not those who never experience uncertainty.\n\nThey are those who learn how to handle uncertainty without making rushed decisions.\n\nPatience is not doing nothing—it is choosing your actions carefully when the market tries to pressure you.';

  @override
  String get verdictPanicTier4Title => 'Steady Investor';

  @override
  String get verdictPanicTier4Intro =>
      'Your selling behavior demonstrates good emotional control and a growing ability to handle market uncertainty.\n\nYou understand one of the most important lessons in investing:\n\nA falling stock price does not automatically mean a bad investment.\n\nMany investors can stay confident when markets are rising.\n\nThe real test comes during difficult periods.\n\nWhen prices decline, negative headlines appear, and uncertainty increases, emotional decisions become much more tempting.\n\nYour behavior suggests that you are usually able to avoid panic reactions and give your investments time to develop.\n\nYou appear more focused on the reasons behind your investments rather than short-term price movements.\n\nThis does not mean every decision is perfect.\n\nNo investor avoids mistakes completely.\n\nThe difference is that disciplined investors do not let temporary market fear become the main reason for their actions.\n\nThey evaluate the situation, review the facts, and make decisions based on their strategy.';

  @override
  String get verdictPanicTier4Section1Label => 'How Can You Improve?';

  @override
  String get verdictPanicTier4Section1Body =>
      'Continue strengthening your decision-making process.\n\nBefore selling a position, ask yourself:\n\nHas the business changed, or only the stock price?\nWould I still believe this was a good company if the market was closed tomorrow?\nAm I selling because of new information or because of temporary fear?\n\nRemember that patience does not mean refusing to sell.\n\nSometimes selling is the correct decision.\n\nThe key difference is the reason behind it.\n\nA strong investor sells because the investment thesis changed.\n\nAn emotional investor sells because the market became uncomfortable.';

  @override
  String get verdictPanicTier4Section2Label => 'One Last Thought';

  @override
  String get verdictPanicTier4Section2Body =>
      'Markets will always create moments of uncertainty.\n\nThe ability to stay calm during those moments is a powerful investing advantage.\n\nA steady investor does not ignore risk—they understand it, evaluate it, and respond with a clear mind instead of fear.';

  @override
  String get verdictPanicTier5Title => 'Market Survivor';

  @override
  String get verdictPanicTier5Intro =>
      'Your investment behavior demonstrates a very high level of emotional control and patience during difficult market conditions.\n\nYou understand one of the hardest lessons in investing:\n\nA temporary decline is not always a permanent loss.\n\nMany investors can stay confident when markets are rising.\n\nThe real challenge appears when everything moves in the opposite direction.\n\nPrices fall.\n\nNegative headlines dominate the news.\n\nFear spreads among investors.\n\nDuring these moments, emotions often become stronger than analysis.\n\nYour behavior shows that you are capable of staying focused during periods of extreme pressure.\n\nInstead of reacting immediately to falling prices, you appear to give your investments time and evaluate situations more carefully.\n\nThis is one of the biggest differences between short-term reactions and long-term investing.\n\nA strong investor understands that market crashes are not only periods of risk.\n\nThey can also create opportunities.\n\nWhen others are forced to make emotional decisions, patient investors often have the greatest advantage.';

  @override
  String get verdictPanicTier5Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictPanicTier5Section1Body =>
      'Continue protecting the habits that created this level of discipline.\n\nEven experienced investors should regularly review their decisions.\n\nAsk yourself:\n\nHas the business changed, or only the market price?\nAm I still confident in the original investment idea?\nAm I making this decision based on facts or emotions?\n\nRemember that patience does not mean holding every investment forever.\n\nA great investor is not afraid to change their mind when the facts change.\n\nThe goal is not to avoid every mistake.\n\nThe goal is to avoid making decisions because of temporary fear.';

  @override
  String get verdictPanicTier5Section2Label => 'One Last Thought';

  @override
  String get verdictPanicTier5Section2Body =>
      'Every market cycle creates moments when investors are tested.\n\nSome investors react to fear.\n\nOthers use patience as their advantage.\n\nThe greatest strength of a long-term investor is not avoiding storms—it is having the discipline to stay focused while they pass.';

  @override
  String get verdictPatienceNoDataTitle => 'No Trades Yet';

  @override
  String get verdictPatienceNoDataIntro =>
      'This test ended without any trades — there\'s no waiting behavior to measure yet.';

  @override
  String get verdictPatienceTier1Title => 'Impatient Investor';

  @override
  String get verdictPatienceTier1Intro =>
      'Your investing behavior shows that patience may be one of the biggest areas for improvement.\n\nInvesting is not only about finding good opportunities.\n\nIt is also about giving your decisions enough time to work.\n\nThe market constantly creates pressure to act:\n\nPrices move every day.\n\nNews creates uncertainty.\n\nOther investors share their success stories.\n\nDuring these moments, it can feel like doing something is always better than waiting.\n\nBut in investing, unnecessary actions can sometimes become the biggest mistake.\n\nA good investment does not always move higher immediately.\n\nEven strong companies can experience:\n\ntemporary declines;\ndifficult market conditions;\nperiods when investors lose confidence.\n\nYour score suggests that you may sometimes react too quickly instead of allowing your investment ideas enough time to develop.\n\nThe problem is not making changes.\n\nSuccessful investors sometimes sell, adjust, and improve their portfolios.\n\nThe important question is:\n\n\"Am I changing my decision because the facts changed, or because the situation became uncomfortable?\"';

  @override
  String get verdictPatienceTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictPatienceTier1Section1Body =>
      'Before making a quick decision, try creating a short waiting period.\n\nAsk yourself:\n\nHas the company actually become weaker?\nDid something fundamental change?\nAm I reacting to temporary market noise?\nWould I make the same decision if I ignored today\'s price movement?\n\nTry separating movement from meaning.\n\nA falling price does not always mean a bad investment.\n\nA rising price does not always mean a good investment.\n\nStrong investors understand that time is an important part of the investment process.\n\nAnother useful habit is creating your rules before emotions appear:\n\nWhat would make me sell?\nHow long am I willing to wait?\nWhat conditions would change my original idea?\n\nA calm plan created during normal conditions is much stronger than a decision made under pressure.';

  @override
  String get verdictPatienceTier1Section2Label => 'One Last Thought';

  @override
  String get verdictPatienceTier1Section2Body =>
      'The market rewards investors who can stay focused when others become impatient.\n\nPatience does not mean doing nothing.\n\nIt means having the confidence to wait when waiting is the smartest decision.';

  @override
  String get verdictPatienceTier2Title => 'Short-Term Thinking';

  @override
  String get verdictPatienceTier2Intro =>
      'Your investing behavior shows that you are building patience, but difficult market situations may still create pressure that influences some of your decisions.\n\nYou understand the importance of staying invested, but your actions suggest that uncertainty can sometimes make you want to change direction too quickly.\n\nThis is a very common stage for investors.\n\nMany people understand the idea of long-term investing:\n\nbuy quality assets;\nstay invested;\nignore short-term noise.\n\nBut understanding the concept and applying it during stressful moments are two different things.\n\nThe market constantly tests patience.\n\nA company can have strong fundamentals, but the stock price may decline because of:\n\nmarket fear;\neconomic uncertainty;\ntemporary bad news;\nnegative sentiment.\n\nDuring these periods, it is easy to focus only on the falling price and forget the original reason for the investment.\n\nYour score suggests that you sometimes allow short-term events to have too much influence on long-term decisions.';

  @override
  String get verdictPatienceTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictPatienceTier2Section1Body =>
      'The next step is developing a stronger connection between your investment decisions and your original strategy.\n\nBefore making changes, ask yourself:\n\nDid the company actually become worse?\nIs this a permanent problem or a temporary situation?\nWould I still want to own this business if the price movement was hidden from me?\n\nTry reviewing your investments based on the business, not only the chart.\n\nA temporary decline can create discomfort.\n\nBut discomfort alone is not always a reason to act.\n\nRemember:\n\nA long-term investor is not rewarded for reacting to every market movement.\n\nThey are rewarded for making thoughtful decisions and allowing good ideas enough time to work.';

  @override
  String get verdictPatienceTier2Section2Label => 'One Last Thought';

  @override
  String get verdictPatienceTier2Section2Body =>
      'The market moves faster than any investor can predict.\n\nTrying to react to every movement often creates unnecessary mistakes.\n\nPatience is the ability to give your strategy enough time to prove itself instead of constantly changing direction with every market wave.';

  @override
  String get verdictPatienceTier3Title => 'Building Patience';

  @override
  String get verdictPatienceTier3Intro =>
      'Your investing behavior shows that you are developing the ability to stay calm during market uncertainty, but your patience is still a skill that continues to grow.\n\nYou are beginning to understand an important investing principle:\n\nNot every market movement requires a reaction.\n\nSuccessful investing often requires the ability to wait.\n\nWait for the right opportunity.\n\nWait for the market to recognize value.\n\nWait for a good business decision to develop over time.\n\nYour behavior suggests that you are not constantly reacting emotionally, but some situations may still create uncertainty and make you question your decisions.\n\nThis is a normal stage of development for investors.\n\nThe market rarely moves in a straight line.\n\nEven strong investments experience periods of:\n\nslow growth;\ntemporary declines;\nnegative sentiment;\nuncertainty.\n\nThe challenge is learning when action is necessary and when patience is the better choice.';

  @override
  String get verdictPatienceTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictPatienceTier3Section1Body =>
      'Continue building a clear decision process before making changes.\n\nWhen you feel the urge to sell or adjust your portfolio, ask:\n\nIs the business becoming weaker, or is the market simply reacting?\nHas my original investment idea changed?\nAm I making this decision because of facts or because of discomfort?\n\nTry to evaluate your investments based on the long-term picture.\n\nA temporary decline can feel uncomfortable, but discomfort is not always a signal that something is wrong.\n\nAt the same time, patience does not mean ignoring problems.\n\nA patient investor still reviews decisions and changes direction when the facts truly change.\n\nThe goal is not to hold everything forever.\n\nThe goal is to avoid unnecessary actions caused by short-term emotions.';

  @override
  String get verdictPatienceTier3Section2Label => 'One Last Thought';

  @override
  String get verdictPatienceTier3Section2Body =>
      'Patience is built through experience.\n\nEvery market decline, every uncertain moment, and every difficult decision is a chance to improve.\n\nA patient investor is not someone who never acts.\n\nA patient investor knows when action is necessary—and when waiting is the smartest decision.';

  @override
  String get verdictPatienceTier4Title => 'Patient Investor';

  @override
  String get verdictPatienceTier4Intro =>
      'Your investing behavior demonstrates a strong ability to remain calm and focused during uncertain market conditions.\n\nYou understand one of the most important lessons in long-term investing:\n\nNot every problem in the market requires immediate action.\n\nMany investors feel pressure to constantly make decisions.\n\nWhen prices rise, they feel the need to buy more.\n\nWhen prices fall, they feel the need to protect themselves.\n\nBut experienced investors understand that sometimes the best decision is simply waiting and allowing time to work.\n\nYour behavior suggests that you are able to separate temporary market movements from real changes in the quality of an investment.\n\nYou are more likely to evaluate situations instead of immediately reacting to emotions.\n\nThis is a valuable skill because markets are designed to test investor patience.\n\nThere will always be:\n\nunexpected declines;\nnegative headlines;\nperiods of uncertainty;\nmoments when confidence is challenged.\n\nThe ability to stay focused during these periods can become one of the biggest advantages an investor has.';

  @override
  String get verdictPatienceTier4Section1Label => 'How Can You Improve?';

  @override
  String get verdictPatienceTier4Section1Body =>
      'Continue developing your investment process and protect the habits that created this level of patience.\n\nBefore making changes, continue asking:\n\nHas the business actually changed?\nIs the original investment idea still valid?\nAm I making this decision because of new information or because of temporary market emotions?\n\nRemember that patience does not mean refusing to make decisions.\n\nA patient investor is still willing to sell when the facts change.\n\nThe difference is that decisions come from analysis, not pressure.\n\nKeep focusing on the long-term picture instead of reacting to every short-term movement.';

  @override
  String get verdictPatienceTier4Section2Label => 'One Last Thought';

  @override
  String get verdictPatienceTier4Section2Body =>
      'Markets will always create moments that test your confidence.\n\nThe advantage does not belong to the investor who reacts to every change.\n\nIt belongs to the investor who can stay focused, wait for the right moment, and allow good decisions enough time to work.';

  @override
  String get verdictPatienceTier5Title => 'Long-Term Mindset';

  @override
  String get verdictPatienceTier5Intro =>
      'Your investing behavior demonstrates an exceptional level of patience and emotional control.\n\nYou understand one of the most powerful advantages in investing:\n\nTime is not just something investors wait for — it is something they use.\n\nMany investors focus on predicting the next market movement.\n\nThey try to find the perfect entry point.\n\nThey react to every headline.\n\nThey worry about every temporary decline.\n\nBut long-term investors understand that successful investing is often built through consistency, preparation, and the ability to stay focused when the market becomes unpredictable.\n\nYour behavior shows that you are capable of avoiding unnecessary reactions during difficult periods.\n\nInstead of immediately responding to fear or uncertainty, you allow your investment decisions time to develop.\n\nThis is especially important during major market disruptions.\n\nWhen fear spreads, many investors make decisions based on emotion.\n\nThey sell because they want to stop the discomfort.\n\nA patient investor understands that uncertainty is part of investing.\n\nThey evaluate the situation, review the facts, and avoid changing direction simply because the market becomes stressful.';

  @override
  String get verdictPatienceTier5Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictPatienceTier5Section1Body =>
      'Maintaining patience is a strength, but even patient investors should continue reviewing their decisions.\n\nRemember:\n\nPatience does not mean holding every investment forever.\n\nA strong long-term investor still asks:\n\nHas the business changed?\nIs my original investment idea still valid?\nAm I holding because of confidence or because I refuse to admit a mistake?\n\nThe goal is not to avoid every sale.\n\nThe goal is to make sure decisions come from analysis rather than emotion.\n\nContinue balancing patience with awareness.\n\nThe best investors are calm, but they are never careless.';

  @override
  String get verdictPatienceTier5Section2Label => 'One Last Thought';

  @override
  String get verdictPatienceTier5Section2Body =>
      'The market will always create moments of fear, excitement, and uncertainty.\n\nYou cannot control the market.\n\nBut you can control how you respond to it.\n\nThe greatest advantage of a long-term investor is not predicting every storm.\n\nIt is having the patience and confidence to stay focused while the storm passes.';

  @override
  String get verdictSafetyMarkerNoDataTitle => 'No Safety Data Yet';

  @override
  String get verdictSafetyMarkerNoDataIntro =>
      'This test doesn\'t have enough data to score the quality of what was bought — either no positions were opened, or the fundamentals for those companies hadn\'t finished loading before the test ended.';

  @override
  String get verdictSafetyMarkerTier1Title =>
      'Building on Hopes, Not Businesses';

  @override
  String get verdictSafetyMarkerTier1Intro =>
      'Your portfolio shows a clear pattern: many of your investments are based more on future expectations than on the strength of the businesses themselves.\n\nEvery company begins with an idea. Some of those ideas grow into world-changing businesses. Others never become profitable at all.\n\nThe challenge is that the stock market often rewards exciting stories long before those stories become successful businesses.\n\nCompanies with little or no profit, weak financial health, declining revenue, excessive debt, or business models that have yet to prove themselves can experience dramatic price swings. They may occasionally deliver extraordinary returns—but they also carry a much higher risk of permanent losses.\n\nOwning several of these companies at the same time doesn\'t reduce that risk. It simply spreads your money across multiple uncertain outcomes.\n\nThis is especially common with highly speculative industries such as early-stage biotechnology, pre-revenue technology companies, space exploration startups, meme stocks, and businesses whose valuations depend primarily on future expectations rather than current performance.\n\nThere\'s nothing wrong with believing in innovation.\n\nMany of today\'s largest companies once started as ambitious ideas.\n\nThe difference is that successful long-term investors don\'t buy a company simply because its story sounds exciting. They look for evidence that the business is becoming stronger over time.\n\nGrowing revenue.\nHealthy profit margins.\nReasonable debt.\nPositive cash flow.\nConsistent execution.\n\nThese fundamentals often matter far more than headlines or social media excitement.';

  @override
  String get verdictSafetyMarkerTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictSafetyMarkerTier1Section1Body =>
      'Before buying a company, try asking yourself a few simple questions.\n\nIs this company already generating sustainable profits?\nDoes its business continue to grow year after year?\nCan it survive difficult economic conditions?\nAm I investing because I understand the business—or because I hope the future will be extraordinary?\n\nSometimes the most exciting investment isn\'t the strongest one.\n\nAnd sometimes the strongest business isn\'t the one making the loudest headlines.\n\nYou don\'t have to avoid higher-risk companies completely.\n\nHowever, they should represent only a small portion of a portfolio built on stable, financially healthy businesses.\n\nStrong foundations allow great ideas to become opportunities—not unnecessary risks.';

  @override
  String get verdictSafetyMarkerTier1Section2Label => 'One Last Thought';

  @override
  String get verdictSafetyMarkerTier1Section2Body =>
      'Innovation creates possibilities.\n\nStrong businesses create long-term wealth.\n\nThe most successful investors learn to tell the difference.\n\nDon\'t invest only in what could become great. Invest in companies that are already proving they can succeed.';

  @override
  String get verdictSafetyMarkerTier2Title => 'High Risk, High Expectations';

  @override
  String get verdictSafetyMarkerTier2Intro =>
      'Your portfolio shows a mix of promising businesses and highly speculative investments.\n\nYou\'ve started looking beyond headlines, but many of your decisions still place a great deal of trust in what a company might become rather than what it has already achieved.\n\nThere is nothing wrong with investing in future potential.\n\nEvery successful company was once an ambitious idea.\n\nThe challenge is that not every ambitious idea becomes a successful business.\n\nMany companies spend years chasing profitability. Some never reach it. Others rely heavily on debt, repeatedly issue new shares to raise capital, or continue operating without generating sustainable cash flow. While a small number eventually become market leaders, many fail long before reaching that point.\n\nAs an investor, your goal isn\'t to predict every future success story.\n\nYour goal is to improve the odds that the businesses you own can survive long enough to become one.\n\nAt the moment, your portfolio still leans more toward optimism than financial strength.\n\nThat doesn\'t make it a bad portfolio—but it does make it a riskier one.';

  @override
  String get verdictSafetyMarkerTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictSafetyMarkerTier2Section1Body =>
      'When evaluating a company, try spending less time asking:\n\n\"How much could this stock go up?\"\n\nAnd more time asking:\n\nIs the company consistently profitable?\nIs revenue growing because the business is improving—not simply because of temporary excitement?\nCan the company support itself without constantly raising new capital?\nDoes management have a proven record of delivering results?\n\nSometimes the strongest investments don\'t look exciting at first.\n\nThey quietly build profits, strengthen their balance sheets, and reward patient investors over many years.\n\nYou don\'t need to eliminate every speculative company from your portfolio.\n\nJust make sure they\'re the exception—not the foundation.\n\nLet financially healthy businesses carry the weight of your portfolio, while higher-risk ideas remain carefully controlled opportunities.';

  @override
  String get verdictSafetyMarkerTier2Section2Label => 'One Last Thought';

  @override
  String get verdictSafetyMarkerTier2Section2Body =>
      'Hope can be part of an investment.\n\nIt should never be the entire investment strategy.\n\nThe strongest portfolios aren\'t built on the companies with the biggest promises—they\'re built on the companies that consistently deliver on them.';

  @override
  String get verdictSafetyMarkerTier3Title => 'A Portfolio with Potential';

  @override
  String get verdictSafetyMarkerTier3Intro =>
      'Your portfolio shows clear progress.\n\nMost of your investments are backed by companies with solid business foundations, while a smaller number still carry higher levels of uncertainty. This balance suggests you\'re beginning to look beyond market excitement and pay closer attention to the strength of the businesses you invest in.\n\nThat\'s an important step.\n\nSuccessful investing isn\'t about finding companies with the most exciting stories.\n\nIt\'s about identifying businesses that can continue creating value year after year.\n\nStrong companies often share similar characteristics. They generate consistent revenue, maintain healthy profit margins, manage debt responsibly, and continue growing even when market conditions become difficult.\n\nYour portfolio already reflects many of these qualities.\n\nHowever, there are still a few companies whose future depends more on expectations than proven financial performance.\n\nThat doesn\'t automatically make them bad investments.\n\nSome speculative companies eventually become tomorrow\'s market leaders.\n\nThe challenge is that it\'s impossible to know in advance which ones will succeed and which ones won\'t.\n\nThis is why experienced investors usually build the majority of their portfolio around businesses that have already demonstrated financial strength, while limiting exposure to companies that are still trying to prove themselves.';

  @override
  String get verdictSafetyMarkerTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictSafetyMarkerTier3Section1Body =>
      'As your portfolio grows, try making business quality one of your main investment filters.\n\nBefore buying a company, look beyond the share price.\n\nAsk yourself:\n\nIs this business consistently profitable?\nDoes it generate healthy cash flow?\nIs debt under control?\nHas management demonstrated the ability to execute its strategy over time?\nWould I still want to own this company if its stock price didn\'t move for the next three years?\n\nThe answers to these questions often reveal far more than short-term market enthusiasm.\n\nRemember, a strong investment is built on a strong business—not simply on a popular stock.';

  @override
  String get verdictSafetyMarkerTier3Section2Label => 'One Last Thought';

  @override
  String get verdictSafetyMarkerTier3Section2Body =>
      'A great company doesn\'t have to be exciting.\n\nIt has to be resilient.\n\nThe market often rewards excitement for a while.\n\nIt rewards strong businesses for much longer.\n\nThe more your decisions are guided by business quality instead of market excitement, the stronger your portfolio becomes.';

  @override
  String get verdictSafetyMarkerTier4Title => 'Quality Comes First';

  @override
  String get verdictSafetyMarkerTier4Intro =>
      'Your portfolio reflects a disciplined approach to investing.\n\nThe companies you\'ve selected are generally supported by strong financial foundations rather than short-term market excitement. Instead of chasing headlines or popular trends, you\'ve focused on businesses that have already demonstrated their ability to generate revenue, earn profits, manage debt responsibly, and create long-term value.\n\nThis is one of the most important habits successful investors develop.\n\nThe market is full of exciting stories.\n\nSome promise revolutionary technologies.\n\nOthers promise to change entire industries.\n\nA few eventually do.\n\nMany never live up to those expectations.\n\nStrong businesses don\'t need extraordinary promises to attract investors. They earn confidence through consistent execution, financial stability, and years of proven performance.\n\nYour portfolio reflects that mindset.\n\nRather than relying on hope, you\'ve built much of your portfolio around companies that have already shown they can survive economic downturns, adapt to changing markets, and continue growing over time.\n\nNo company is completely risk-free.\n\nEven the strongest businesses experience difficult years, disappointing earnings, or unexpected challenges.\n\nHowever, financially healthy companies are often far better equipped to recover from those setbacks than businesses that are already struggling to survive.\n\nThat difference becomes especially valuable during periods of market uncertainty.';

  @override
  String get verdictSafetyMarkerTier4Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictSafetyMarkerTier4Section1Body =>
      'Keep doing what you\'re already doing—but never stop asking questions.\n\nEven outstanding companies deserve regular review.\n\nMarkets evolve.\n\nIndustries change.\n\nNew competitors emerge.\n\nBefore adding a new investment, ask yourself:\n\nIs this company still financially strong?\nHas its business improved over the past few years?\nDoes it continue creating value for shareholders?\nWould I still feel comfortable owning this business during a difficult market downturn?\n\nA strong portfolio isn\'t built by finding perfect companies.\n\nIt\'s built by consistently choosing businesses that continue earning your confidence.';

  @override
  String get verdictSafetyMarkerTier4Section2Label => 'One Last Thought';

  @override
  String get verdictSafetyMarkerTier4Section2Body =>
      'Great investors don\'t search for perfect stocks.\n\nThey search for exceptional businesses.\n\nStock prices rise and fall every day.\n\nStrong businesses continue building value long after today\'s headlines have been forgotten.\n\nWhen you invest in quality businesses, you\'re investing in companies that have already learned how to survive, adapt, and grow.';

  @override
  String get verdictSafetyMarkerTier5Title =>
      'Investing in Businesses, Not Stories';

  @override
  String get verdictSafetyMarkerTier5Intro =>
      'You invest in businesses—not promises.\n\nYour portfolio reflects the mindset of a long-term investor.\n\nRather than chasing excitement, market hype, or the latest investment trend, you\'ve consistently chosen companies with strong financial foundations and proven business performance.\n\nThese businesses don\'t rely solely on bold promises or optimistic forecasts.\n\nThey generate real revenue.\n\nThey produce sustainable profits.\n\nThey manage debt responsibly.\n\nThey reward shareholders through disciplined capital allocation.\n\nMost importantly, they have demonstrated an ability to adapt, compete, and grow through changing market conditions.\n\nThat doesn\'t guarantee every investment will succeed.\n\nNo company is immune to economic downturns, unexpected challenges, or periods of poor performance.\n\nHowever, businesses with strong fundamentals are often far better equipped to overcome those obstacles than companies that are still searching for a viable business model.\n\nThis is one of the biggest differences between investing and speculating.\n\nSpeculation asks:\n\n\"What could this company become?\"\n\nInvesting asks:\n\n\"What has this company already proven it can do?\"\n\nYour portfolio suggests you\'re asking the second question more often.\n\nThat habit has helped many successful investors build wealth over decades—not by predicting the future, but by owning businesses capable of creating value year after year.';

  @override
  String get verdictSafetyMarkerTier5Section1Label =>
      'Keep Thinking Like a Business Owner';

  @override
  String get verdictSafetyMarkerTier5Section1Body =>
      'Even outstanding companies deserve regular review.\n\nMarkets change.\n\nIndustries evolve.\n\nCompetitive advantages can weaken over time.\n\nContinue looking beyond the share price.\n\nReview financial statements.\n\nFollow earnings reports.\n\nPay attention to debt levels, profitability, cash flow, and management decisions.\n\nThe strongest investors don\'t buy great companies and forget about them forever.\n\nThey continue making sure those companies remain great businesses.\n\nRemember, a high-quality company today must continue earning that reputation tomorrow.';

  @override
  String get verdictSafetyMarkerTier5Section2Label => 'One Last Thought';

  @override
  String get verdictSafetyMarkerTier5Section2Body =>
      'A stock is more than a ticker symbol.\n\nBehind every share is a real business, real employees, real customers, and real financial results.\n\nThe market may reward exciting stories for a season.\n\nBut over the long run, it has consistently rewarded businesses that create lasting value.\n\nThe greatest investment isn\'t finding the next headline. It\'s owning companies that continue proving their worth long after the headlines have faded.';

  @override
  String get verdictSectorBalanceNoDataTitle => 'No Sector Data Yet';

  @override
  String get verdictSectorBalanceNoDataIntro =>
      'This test ended without any positions — there\'s no sector concentration to measure yet.';

  @override
  String get verdictSectorBalanceTier1Title => 'One Sector Rules Them All';

  @override
  String get verdictSectorBalanceTier1Intro =>
      'Your portfolio may contain excellent companies—but they\'re all standing on the same foundation.\n\nA large portion of your investments is concentrated in a single sector of the economy, which means your portfolio\'s future depends heavily on the success of one industry.\n\nThis is known as sector concentration risk.\n\nThe companies themselves may be financially strong.\n\nTheir management teams may be excellent.\n\nTheir products may lead the market.\n\nBut if the entire industry faces unexpected challenges, even outstanding businesses often decline together.\n\nHistory has shown this many times.\n\nTechnology, banking, real estate, energy, biotechnology—every sector has experienced periods of rapid growth followed by years of disappointing performance.\n\nThe strongest companies often survive.\n\nTheir share prices don\'t always escape the downturn.\n\nMarkets don\'t ask whether your companies are good.\n\nThey often ask whether investors still want exposure to that entire industry.\n\nWhen confidence disappears, an entire sector can fall together—even when many of its businesses remain fundamentally healthy.';

  @override
  String get verdictSectorBalanceTier1Section1Label => 'How Can You Improve?';

  @override
  String get verdictSectorBalanceTier1Section1Body =>
      'Try looking beyond your favorite industry.\n\nInstead of asking:\n\n\"Which is the best company in this sector?\"\n\nAlso ask:\n\n\"Which important parts of the economy am I completely ignoring?\"\n\nHealthcare.\nFinancial services.\nIndustrials.\nConsumer businesses.\nEnergy.\nUtilities.\nCommunication services.\n\nEach sector responds differently to changing economic conditions.\n\nOwning businesses across multiple industries helps ensure that your portfolio isn\'t relying on a single economic story to succeed.\n\nDiversification across sectors doesn\'t eliminate risk.\n\nIt prevents one industry from deciding the fate of your entire portfolio.';

  @override
  String get verdictSectorBalanceTier1Section2Label => 'One Last Thought';

  @override
  String get verdictSectorBalanceTier1Section2Body =>
      'A great company can still be part of a risky portfolio.\n\nNot because the business is weak—\n\nbut because too many of your investments depend on the same part of the economy.\n\nDon\'t put all your confidence into one industry. Build a portfolio that can continue moving forward even when one sector falls behind.';

  @override
  String get verdictSectorBalanceTier2Title => 'Too Much Faith in One Industry';

  @override
  String get verdictSectorBalanceTier2Intro =>
      'Your portfolio is beginning to diversify, but one sector still carries far more weight than the others.\n\nWhile you own companies from multiple industries, a significant portion of your capital remains concentrated in a single area of the economy. If that sector experiences a prolonged downturn, your entire portfolio could feel the impact far more than you might expect.\n\nThis doesn\'t mean you\'ve chosen bad companies.\n\nIn fact, many of them may be exceptional businesses.\n\nThe challenge is that even excellent companies often move in the same direction when they belong to the same industry.\n\nStrong earnings, product launches, interest rates, government regulations, technological changes, or shifts in investor sentiment can affect an entire sector at once.\n\nWhen that happens, owning several companies from the same industry doesn\'t always provide the diversification investors hope for.\n\nSometimes it simply means taking the same risk multiple times.';

  @override
  String get verdictSectorBalanceTier2Section1Label => 'How Can You Improve?';

  @override
  String get verdictSectorBalanceTier2Section1Body =>
      'Your portfolio doesn\'t need a complete overhaul.\n\nIt simply needs better balance.\n\nThe next time you invest, consider adding a company from a sector that currently has a much smaller presence in your portfolio.\n\nInstead of strengthening your largest position even further, strengthen one of your weakest.\n\nOver time, these small decisions can create a portfolio that is more resilient to unexpected market changes.\n\nThe goal isn\'t to avoid your favorite industry.\n\nThe goal is to avoid depending on it.';

  @override
  String get verdictSectorBalanceTier2Section2Label => 'One Last Thought';

  @override
  String get verdictSectorBalanceTier2Section2Body =>
      'It\'s perfectly fine to have a favorite sector.\n\nJust don\'t let it become your entire investment strategy.\n\nThe strongest portfolios aren\'t built around one successful industry. They\'re built around an economy that never stops changing.';

  @override
  String get verdictSectorBalanceTier3Title =>
      'A Better Balance Is Within Reach';

  @override
  String get verdictSectorBalanceTier3Intro =>
      'Your portfolio is moving in the right direction.\n\nYou\'ve already spread your investments across several sectors of the economy, which is an important step toward reducing risk. However, one industry still represents a noticeably larger share of your portfolio than the others.\n\nThis isn\'t a major problem—but it\'s an opportunity to improve.\n\nMarkets don\'t move in perfect harmony.\n\nDifferent sectors respond differently to economic conditions, interest rates, inflation, technological change, and consumer demand. While one industry may struggle for months or even years, another may continue growing under the very same conditions.\n\nThat\'s why balance matters.\n\nA portfolio doesn\'t become stronger by finding one perfect sector.\n\nIt becomes stronger by giving several sectors the opportunity to contribute to your long-term success.\n\nAt the moment, your portfolio still leans a little too heavily toward one part of the economy.\n\nFortunately, you\'re much closer to excellent diversification than poor diversification.';

  @override
  String get verdictSectorBalanceTier3Section1Label => 'How Can You Improve?';

  @override
  String get verdictSectorBalanceTier3Section1Body =>
      'You don\'t need to sell your existing investments.\n\nInstead, let your future purchases gradually improve the balance.\n\nWhen adding new companies, give a little more attention to sectors that currently make up a smaller portion of your portfolio.\n\nOver time, your allocation will naturally become more balanced without forcing unnecessary trades or creating taxable events.\n\nSmall adjustments made consistently are often more effective than dramatic changes made all at once.';

  @override
  String get verdictSectorBalanceTier3Section2Label => 'One Last Thought';

  @override
  String get verdictSectorBalanceTier3Section2Body =>
      'Diversification isn\'t about making every sector exactly the same size.\n\nIt\'s about making sure no single industry has too much control over your financial future.\n\nYour portfolio already has a solid foundation.\n\nA few thoughtful investments in underrepresented sectors could make it even stronger for whatever the market brings next.';

  @override
  String get verdictSectorBalanceTier4Title => 'Balanced Across the Economy';

  @override
  String get verdictSectorBalanceTier4Intro =>
      'Your portfolio demonstrates a healthy level of sector diversification.\n\nNo single industry dominates your investments, allowing different parts of the economy to contribute to your long-term results. This balanced approach helps reduce the impact that any one sector can have on your overall portfolio.\n\nThat\'s an important advantage.\n\nMarkets move in cycles.\n\nTechnology won\'t lead forever.\n\nHealthcare won\'t always outperform.\n\nFinancials, industrials, consumer companies, energy, utilities, and other sectors each have periods of strength and periods of weakness.\n\nNo one can consistently predict which industry will outperform next.\n\nFortunately, your portfolio doesn\'t have to.\n\nBy spreading your investments across multiple sectors, you\'ve built a portfolio that is prepared for different economic environments instead of relying on a single prediction.\n\nThis is exactly how diversification is meant to work.';

  @override
  String get verdictSectorBalanceTier4Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictSectorBalanceTier4Section1Body =>
      'Continue maintaining the balance you\'ve already created.\n\nAs your portfolio grows, avoid allowing one rapidly growing sector to gradually dominate your investments.\n\nA quick review of your sector allocation from time to time is often enough to keep your portfolio well balanced.\n\nAlso remember that sector diversification is only one part of building a resilient portfolio.\n\nThe quality of the businesses you own remains just as important as the industries they belong to.\n\nStrong companies spread across multiple sectors create a stronger portfolio than simply owning many different industries.';

  @override
  String get verdictSectorBalanceTier4Section2Label => 'One Last Thought';

  @override
  String get verdictSectorBalanceTier4Section2Body =>
      'A balanced portfolio doesn\'t try to predict which sector will win next.\n\nIt prepares for the possibility that any sector can have its moment.\n\nYou can\'t control where the next market leader will come from—but you can build a portfolio that\'s ready when it happens.';

  @override
  String get verdictSectorBalanceTier5Title =>
      'No Single Sector Controls Your Future';

  @override
  String get verdictSectorBalanceTier5Intro =>
      'Your portfolio reflects a well-balanced investment strategy.\n\nNo single sector dominates your holdings, which means your long-term success isn\'t tied to the performance of one industry. Instead, your investments are spread across different parts of the economy, allowing your portfolio to benefit from a wide range of businesses, products, and economic cycles.\n\nThis is one of the strongest forms of risk management available to long-term investors.\n\nDifferent industries thrive under different conditions.\n\nTechnology may lead during periods of innovation.\n\nHealthcare often remains resilient during uncertain markets.\n\nIndustrials may benefit from economic expansion.\n\nConsumer companies, financial services, utilities, and energy each have their own opportunities and challenges throughout the market cycle.\n\nRather than trying to predict which sector will become tomorrow\'s winner, you\'ve built a portfolio that is prepared for many different outcomes.\n\nThat\'s exactly how long-term investing should work.\n\nYour portfolio doesn\'t rely on being right about a single industry.\n\nIt relies on the strength of the broader economy.';

  @override
  String get verdictSectorBalanceTier5Section1Label =>
      'Keep Protecting Your Balance';

  @override
  String get verdictSectorBalanceTier5Section1Body =>
      'As your portfolio grows, continue monitoring your sector allocation from time to time.\n\nSometimes a rapidly growing sector can naturally become much larger than the rest of your portfolio without you even noticing.\n\nMaintaining balance doesn\'t require frequent trading.\n\nOften, simply directing new investments toward underrepresented sectors is enough to keep your portfolio well diversified.\n\nRemember, diversification isn\'t a one-time decision.\n\nIt\'s an ongoing habit.';

  @override
  String get verdictSectorBalanceTier5Section2Label => 'One Last Thought';

  @override
  String get verdictSectorBalanceTier5Section2Body =>
      'The future rarely rewards only one industry.\n\nInnovation shifts.\n\nEconomic cycles change.\n\nNew leaders emerge while yesterday\'s leaders slow down.\n\nYou don\'t need to know which sector will outperform next.\n\nYou\'ve built a portfolio that doesn\'t depend on a single answer.\n\nThe strongest portfolios don\'t bet on one part of the economy. They grow alongside the economy itself.';

  @override
  String get verdictSectorDiversificationNoDataTitle => 'No Positions Opened';

  @override
  String get verdictSectorDiversificationNoDataIntro =>
      'This test ended without a single purchase — there\'s nothing yet to diversify.';

  @override
  String get verdictSectorDiversificationTier1Title =>
      'Not All Your Eggs in One Basket';

  @override
  String get verdictSectorDiversificationTier1Intro =>
      'Your portfolio has placed almost all of its trust in just one or two sectors of the economy. It\'s an understandable decision. When a particular industry is booming, it can feel like you\'ve found the obvious winner. The thought naturally follows:\n\n\"Why invest anywhere else if all the biggest opportunities are right here?\"\n\nThe problem is that the market rarely follows a single script.\n\nToday, investors are excited about artificial intelligence. Before that, it was electric vehicles. Earlier, it was internet companies, biotechnology, clean energy, and many other industries that once seemed unstoppable. Some of them truly changed the world—but almost every one of them also experienced periods when prices fell dramatically and investor confidence quickly turned into uncertainty.\n\nThe issue isn\'t the sector you chose.\n\nThe issue is that the future of your entire portfolio now depends on a single idea.\n\nIf that one sector runs into trouble, nearly all of your investments will feel the impact at the same time.\n\nImagine flying in an aircraft powered by only one engine. As long as everything works, the flight is smooth. But if that engine fails, there isn\'t much left to rely on.\n\nA well-built investment portfolio works differently. It\'s more like an aircraft with multiple independent systems. If one part struggles, the others continue doing their job, helping keep the entire portfolio stable.\n\nThat\'s exactly why experienced investors spread their money across different sectors of the economy. Technology, healthcare, financials, industrials, consumer goods, utilities, energy—these industries don\'t move in perfect harmony. When one sector has a difficult year, another may continue growing or simply remain stable. That balance helps reduce the impact of unexpected events.';

  @override
  String get verdictSectorDiversificationTier1Section1Label =>
      'How can you improve?';

  @override
  String get verdictSectorDiversificationTier1Section1Body =>
      'Don\'t try to predict the single winning sector of the next decade. Even professional investors rarely get that right consistently.\n\nInstead, build your portfolio one step at a time.\n\nKeep investing in the sector you believe in—but gradually add exposure to other parts of the economy. You don\'t need to buy everything at once. Every new investment is an opportunity to make your portfolio a little more balanced and a little more resilient.\n\nBefore making your next purchase, ask yourself one simple question:\n\n\"If my favorite sector stopped growing for the next three years, would my portfolio still be in good shape?\"\n\nIf that question makes you uncomfortable, it\'s probably time to broaden your investments.';

  @override
  String get verdictSectorDiversificationTier1Section2Label =>
      'One last thought';

  @override
  String get verdictSectorDiversificationTier1Section2Body =>
      'Diversification is rarely exciting.\n\nIt doesn\'t make headlines. It doesn\'t promise overnight wealth. In fact, it can even feel a little boring.\n\nBut diversification isn\'t designed for the days when everything is going up.\n\nIt\'s designed for the days when the market reminds everyone that no sector, no matter how exciting, rises forever.\n\nA successful investor doesn\'t build a portfolio around a single hope. They build it to survive many different futures.';

  @override
  String get verdictSectorDiversificationTier2Title =>
      'A Strong Foundation, But There\'s Still Room to Grow';

  @override
  String get verdictSectorDiversificationTier2Intro =>
      'Your portfolio is already moving in the right direction.\n\nInstead of relying on a single industry, you\'ve spread your investments across several sectors of the economy. That\'s an important step because it reduces the risk of one disappointing industry dragging down your entire portfolio.\n\nMany investors never get this far.\n\nHowever, your portfolio still relies almost entirely on individual companies.\n\nEven the strongest businesses can experience unexpected setbacks. A weak earnings report, new competition, regulatory changes, a lawsuit, or simply a shift in market sentiment can cause an individual stock to struggle for months—or even years.\n\nThis is where a broad-market ETF can quietly become one of the most valuable investments in your portfolio.\n\nThink of an ETF as the foundation beneath your house.\n\nYou probably don\'t admire the foundation every day. It isn\'t exciting. It doesn\'t make headlines. Nobody talks about it at family dinners.\n\nBut when the weather turns bad, you\'re very happy it\'s there.\n\nA broad-market ETF spreads your investment across hundreds—or even thousands—of companies with a single purchase. It doesn\'t replace individual stocks. Instead, it helps balance them. While one company may disappoint, many others continue doing their job behind the scenes.\n\nThis creates a portfolio that is often more stable, easier to manage, and less dependent on the success of a handful of companies.';

  @override
  String get verdictSectorDiversificationTier2Section1Label =>
      'How can you improve?';

  @override
  String get verdictSectorDiversificationTier2Section1Body =>
      'You\'ve already done the difficult part by diversifying across multiple sectors.\n\nNow consider adding at least one broad-market ETF to strengthen the overall structure of your portfolio.\n\nYou don\'t need to replace the companies you believe in.\n\nSimply allow an ETF to become the stable core around which the rest of your investments can grow.\n\nMany experienced long-term investors build their portfolios this way:\n\nA solid ETF provides broad market exposure.\nIndividual companies are added around it to pursue additional growth opportunities.\n\nThis combination offers the best of both worlds—stability from the market as a whole and the potential for stronger returns from carefully selected businesses.';

  @override
  String get verdictSectorDiversificationTier2Section2Label =>
      'One last thought';

  @override
  String get verdictSectorDiversificationTier2Section2Body =>
      'A well-diversified portfolio isn\'t measured only by how many sectors it owns.\n\nIt\'s also measured by how many different risks it avoids.\n\nIndividual companies can surprise you. An entire market is much harder to surprise.';

  @override
  String get verdictSectorDiversificationTier3Title =>
      'A Portfolio Built to Weather the Storm';

  @override
  String get verdictSectorDiversificationTier3Intro =>
      'Your portfolio looks thoughtfully constructed rather than randomly assembled.\n\nYour investments are spread across multiple sectors of the economy, meaning your long-term success doesn\'t depend on a single industry or one big idea. Technology may lead today, while healthcare, industrials, financials, or consumer companies could take the spotlight tomorrow. No one can consistently predict which sector will outperform next—but you\'ve already prepared for different possibilities.\n\nThat\'s exactly what diversification is meant to do.\n\nWhen one sector faces a difficult period, others may continue growing or simply remain stable. This balance helps reduce the impact of unexpected market events and makes your portfolio more resilient during times of volatility.\n\nMost importantly, you resisted the temptation to bet everything on a single trend. Instead of trying to identify one future winner, you\'ve given your investments the opportunity to grow across several parts of the economy. That approach may not deliver the highest return every single year, but it greatly improves your chances of achieving consistent long-term results.\n\nGreat investors don\'t focus only on how much they can make.\n\nThey also focus on staying invested through every market cycle.';

  @override
  String get verdictSectorDiversificationTier3Section1Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictSectorDiversificationTier3Section1Body =>
      'Even a strong portfolio can still be improved.\n\nIf you already own a broad-market ETF, you\'ve built a solid foundation. If not, consider adding one. A single diversified ETF can become the stable core of your portfolio while your individual stock picks provide additional growth opportunities.\n\nThere\'s one more habit that experienced investors often develop.\n\nYou don\'t have to invest every available dollar the moment it becomes available.\n\nKeeping a small cash reserve isn\'t a sign of hesitation—it\'s a sign of preparation.\n\nWhen the market suddenly declines, that reserve gives you the freedom to buy quality companies at more attractive prices instead of watching great opportunities pass by.\n\nCash sitting on the sidelines isn\'t always idle money.\n\nSometimes it\'s future opportunity waiting for the right moment.';

  @override
  String get verdictSectorDiversificationTier3Section2Label =>
      'One Last Thought';

  @override
  String get verdictSectorDiversificationTier3Section2Body =>
      'Diversification protects you from relying on a single sector.\n\nA broad-market ETF spreads your risk across hundreds of companies.\n\nA small cash reserve gives you the flexibility to act when others are driven by fear.\n\nIndividually, these habits may seem simple.\n\nTogether, they create the kind of portfolio that is built not only to grow—but to endure.\n\nSuccessful investors don\'t prepare only for rising markets. They also prepare for the opportunities that appear when markets fall.';

  @override
  String get verdictSectorDiversificationTier4Title =>
      'Diversification Done Right';

  @override
  String get verdictSectorDiversificationTier4Intro =>
      'You\'ve built a portfolio that reflects patience, balance, and long-term thinking.\n\nYour investments are spread across multiple sectors of the economy, reducing your dependence on any single industry or market trend. Rather than trying to predict one future winner, you\'ve prepared your portfolio for many possible outcomes.\n\nThis is exactly what diversification is designed to achieve.\n\nWhen technology slows down, healthcare may continue growing. When consumer spending weakens, utilities or defensive businesses may provide stability. No one knows which sector will lead next year, but your portfolio doesn\'t need to rely on a single prediction.\n\nYou\'ve built a structure that is designed to adapt rather than guess.\n\nThat is one of the strongest habits a long-term investor can develop.';

  @override
  String get verdictSectorDiversificationTier4Section1Label =>
      'One Important Reminder';

  @override
  String get verdictSectorDiversificationTier4Section1Body =>
      'Good sector diversification doesn\'t automatically mean every investment is a good one.\n\nA portfolio can be perfectly diversified across industries while still containing companies with weak business models, excessive debt, declining revenues, or highly speculative business strategies.\n\nDiversification protects you from concentrating your money in one part of the economy.\n\nIt does not protect you from buying poor-quality businesses.\n\nThis is especially important when investing in highly speculative companies.\n\nEarly-stage biotechnology firms, pre-revenue startups, meme stocks, and businesses that rely more on future promises than proven results can experience extreme price swings. Some may become incredible success stories.\n\nMany others never reach profitability.\n\nOwning companies simply because they belong to different sectors isn\'t enough.\n\nEach investment should earn its place in your portfolio through the strength of its business, not just the excitement surrounding its story.';

  @override
  String get verdictSectorDiversificationTier4Section2Label =>
      'How Can You Make It Even Better?';

  @override
  String get verdictSectorDiversificationTier4Section2Body =>
      'Continue reviewing your companies—not just your sector allocation.\n\nAsk yourself questions like:\n\nDoes this company have a sustainable business?\nIs it consistently generating revenue and profits?\nDoes it carry manageable debt?\nWould I still want to own this business if the share price stopped rising for several years?\n\nThese questions often reveal far more than a rising stock chart.\n\nRemember, diversification should never become an excuse to buy companies blindly.\n\nA portfolio filled with weak businesses doesn\'t become strong simply because they operate in different industries.';

  @override
  String get verdictSectorDiversificationTier4Section3Label =>
      'One Last Thought';

  @override
  String get verdictSectorDiversificationTier4Section3Body =>
      'Diversification protects your portfolio.\n\nQuality protects your investments.\n\nDiscipline protects your future.\n\nWhen all three work together, you\'re no longer just buying stocks.\n\nYou\'re building an investment portfolio designed to grow, adapt, and endure for decades.';

  @override
  String get verdictSectorDiversificationTier5Title =>
      'From a Portfolio to a Zoo';

  @override
  String get verdictSectorDiversificationTier5Intro =>
      'Diversification is one of the most important principles of long-term investing.\n\nBut like many good ideas, it can be taken too far.\n\nYour portfolio now contains so many individual companies that keeping track of them all becomes a challenge in itself.\n\nAt some point, diversification stops reducing risk and starts reducing your ability to understand what you actually own.\n\nAfter all, it\'s difficult to follow earnings reports, financial results, product launches, management changes, and industry developments for dozens of businesses at the same time.\n\nEventually, your investments begin managing you instead of the other way around.\n\nA well-built portfolio doesn\'t need to own everything.\n\nIt needs to own enough.';

  @override
  String get verdictSectorDiversificationTier5Section1Label =>
      'More Companies Doesn\'t Always Mean Less Risk';

  @override
  String get verdictSectorDiversificationTier5Section1Body =>
      'Many new investors believe that buying more stocks automatically makes a portfolio safer.\n\nIn reality, there comes a point where each additional company adds very little protection while making the portfolio significantly more difficult to understand and manage.\n\nImagine trying to care for three pets.\n\nThat\'s manageable.\n\nNow imagine trying to care for thirty.\n\nSooner or later, someone isn\'t getting enough attention.\n\nThe same happens with investments.\n\nIf you no longer remember why you bought a company—or don\'t notice when its business begins to deteriorate—it may no longer deserve a place in your portfolio.';

  @override
  String get verdictSectorDiversificationTier5Section2Label =>
      'Quality Always Comes Before Quantity';

  @override
  String get verdictSectorDiversificationTier5Section2Body =>
      'Owning thirty average businesses is rarely better than owning fifteen outstanding ones that you truly understand.\n\nEvery company in your portfolio should have a clear reason for being there.\n\nIf the only answer is...\n\n\"Because I wanted more diversification.\"\n\n...it may be worth asking whether that position is actually improving your portfolio—or simply making it more complicated.\n\nRemember, diversification is about reducing unnecessary risk.\n\nIt is not about collecting as many ticker symbols as possible.';

  @override
  String get verdictSectorDiversificationTier5Section3Label =>
      'How Can You Improve?';

  @override
  String get verdictSectorDiversificationTier5Section3Body =>
      'Take some time to review your holdings.\n\nAsk yourself:\n\nDo I still understand this company\'s business?\nWould I buy this company again today?\nDoes this investment add something unique to my portfolio?\nOr is it simply another company that overlaps with several others I already own?\n\nIf two companies serve nearly the same purpose, you may not need both.\n\nA simpler portfolio is often easier to monitor, easier to understand, and easier to stick with during difficult markets.';

  @override
  String get verdictSectorDiversificationTier5Section4Label =>
      'One Last Thought';

  @override
  String get verdictSectorDiversificationTier5Section4Body =>
      'A portfolio is not a stamp collection.\n\nYou don\'t earn extra points for owning the most companies.\n\nYou earn them by owning businesses you understand and are confident holding through both good times and bad.\n\nThe goal isn\'t to own everything. The goal is to know why you own each investment.';

  @override
  String get verdictMarkerNotAvailable => 'Not available.';

  @override
  String verdictMarkerFeedbackComingSoon(String label) {
    return 'Detailed feedback for $label is coming soon.';
  }

  @override
  String get verdictTitle => 'Verdict';

  @override
  String get verdictNotAvailable =>
      'Verdict not available — complete the test first.';

  @override
  String get verdictSessionCompleteTitle => 'SESSION COMPLETE';

  @override
  String get verdictContinueLearning => 'Continue Learning';

  @override
  String get verdictBackToHome => 'Back to Home';

  @override
  String get verdictGuardianVerdictLabel => 'GUARDIAN\'S VERDICT';

  @override
  String get verdictGuardianHeadline => 'YOU MADE IT THROUGH';

  @override
  String get verdictGuardianShortText =>
      'Your stress test is complete. You experienced different market conditions and saw how your portfolio and decisions responded. Now it\'s time to see what your results reveal about your investment behavior.';

  @override
  String get verdictViewYourAnalysis => 'View your analysis →';

  @override
  String get verdictHoldingsLabel => 'Holdings';

  @override
  String get verdictFinalPnlLabel => 'Final P&L';

  @override
  String get verdictStartingCashLabel => 'Starting Cash';

  @override
  String get stressTestVerdictNoDataTitle => 'No Data';

  @override
  String get stressTestVerdictNoDataDescription => 'Session data not found.';

  @override
  String get stressTestVerdictPanicTitle => 'PANIC — Fear-Driven Investor';

  @override
  String get stressTestVerdictPanicDescription =>
      'You let fear dictate your actions, selling assets at the worst possible moment and locking in losses. The data shows you sold at the bottom at least twice while the market was in decline. Emotional discipline is the cornerstone of successful investing. Consider setting stop-loss limits and sticking to a predefined strategy rather than reacting to short-term market noise.';

  @override
  String get stressTestVerdictFomoTitle => 'FOMO — Momentum Chaser';

  @override
  String get stressTestVerdictFomoDescription =>
      'You exhibit classic FOMO (Fear Of Missing Out) behavior, buying assets near their peak prices. This pattern of chasing green candles often leads to overpaying for assets. Successful investors buy when there is \"blood in the streets,\" not when euphoria takes over. Try dollar-cost averaging instead of lump-sum buying at all-time highs.';

  @override
  String get stressTestVerdictActiveTraderTitle =>
      'ACTIVE TRADER — High-Frequency Risk';

  @override
  String stressTestVerdictActiveTraderDescription(int totalTrades) {
    return 'You executed over $totalTrades trades in this simulation. While trading activity can be profitable, it also incurs significant costs through commissions, slippage, and taxes. More importantly, frequent trading often crosses the line from methodical investing to dopamine-driven speculation. Consider whether each trade has a clear thesis behind it.';
  }

  @override
  String get stressTestVerdictPatientShieldTitle =>
      'PATIENT SHIELD — Disciplined Investor';

  @override
  String get stressTestVerdictPatientShieldDescription =>
      'You demonstrated remarkable discipline by making few, well-timed trades, holding through volatility, and avoiding panic selling. This patient, long-term approach is the hallmark of legendary investors.';

  @override
  String get stressTestVerdictAbsoluteShieldTitle =>
      'ABSOLUTE SHIELD — Master of Emotions';

  @override
  String get stressTestVerdictAbsoluteShieldExtra =>
      'Exceptional: You not only survived a Black Swan event — you bought the dip and held steady. This is the rarest and most profitable investing mindset. You have earned the ABSOLUTE SHIELD badge.';

  @override
  String get stressTestVerdictBalancedTitle => 'BALANCED — Developing Investor';

  @override
  String get stressTestVerdictBalancedDescription =>
      'Your trading patterns show a mix of behaviors. While you avoided major emotional pitfalls, there is room for improvement in your decision-making process. Focus on building a systematic approach to investing that minimizes emotional reactions.';

  @override
  String get tradesEngineTestNotActive => 'Test not active';

  @override
  String get tradesEnginePriceNotAvailable => 'Price not available';

  @override
  String get tradesEngineSlotFrozen =>
      'This test is frozen — renew Premium to buy or sell here again.';

  @override
  String get tradesEngineInvalidAmount => 'Invalid amount';

  @override
  String get tradesEngineInsufficientCash => 'Insufficient cash';

  @override
  String get tradesEngineInsufficientShares => 'Insufficient shares';

  @override
  String get commonRetry => 'Retry';

  @override
  String get watchlistLimitFree =>
      'FREE limit: 30 companies. Upgrade to Premium (50).';

  @override
  String watchlistLimitMax(int max) {
    return 'Max $max companies reached.';
  }

  @override
  String get companyDetailTitle => 'COMPANY OVERVIEW';

  @override
  String get companyDetailSponsoredTitle => 'Sponsored content';

  @override
  String get companyDetailWatchAdBody =>
      'Please watch a short ad to continue viewing company details.';

  @override
  String get companyDetailWatchAdButton => 'Watch 3s Ad';

  @override
  String get companyDetailUpgradeNoAds => 'Upgrade to Premium — no ads';

  @override
  String get companyDetailLoadError => 'Could not load company data';

  @override
  String get companyDetailLoadErrorBody =>
      'The market data API may be temporarily unavailable. Please try again.';

  @override
  String get companyDetailNoPortfolios =>
      'No portfolios yet. Create one first.';

  @override
  String get companyDetailSelectPortfolioTitle => 'Select Portfolio';

  @override
  String companyDetailSelectPortfolioBodyBuy(String symbol) {
    return 'Where do you want to buy $symbol?';
  }

  @override
  String companyDetailSelectPortfolioBodySell(String symbol) {
    return 'Where do you want to sell $symbol?';
  }

  @override
  String get companyDetailChangeLabel => 'CHANGE';

  @override
  String companyDetailChangePeriodLabel(String period) {
    return 'CHANGE ($period)';
  }

  @override
  String get commonNotAvailable => 'N/A';

  @override
  String get companyDetailKeyMetricsTitle => 'KEY METRICS';

  @override
  String get companyDetailMetricPe => 'P/E';

  @override
  String get companyDetailMetricDividendYield => 'Dividend Yield';

  @override
  String get companyDetailMetricNetMargin => 'Net Margin';

  @override
  String get companyDetailMetricOperatingMargin => 'Operating Margin';

  @override
  String get companyDetailMetricGrossMargin => 'Gross Margin';

  @override
  String get companyDetailMetricRoe => 'ROE';

  @override
  String get companyDetailPriceLabel => 'PRICE';

  @override
  String get companyDetailFsScoreLabel => 'FS SCORE';

  @override
  String get companyDetailPhasePreMarket => 'PRE-MARKET';

  @override
  String get companyDetailPhaseMarketOpen => 'MARKET OPEN';

  @override
  String get companyDetailPhasePostMarket => 'POST-MARKET';

  @override
  String get companyDetailPhaseMarketClosed => 'MARKET CLOSED';

  @override
  String get companyDetailPositionTitle => 'MY INVESTMENTS';

  @override
  String get companyDetailAssetValueLabel => 'Asset Value';

  @override
  String get companyDetailSharesLabel => 'Shares';

  @override
  String get companyDetailAvgCostLabel => 'Avg Cost';

  @override
  String get companyDetailLimitOrdersTitle => 'LIMIT ORDERS';

  @override
  String companyDetailSymbolLimitOrdersTitle(String symbol) {
    return '$symbol Limit Orders';
  }

  @override
  String companyDetailDividendTrapPenalty(int pts) {
    return 'Dividend trap penalty: -$pts pts';
  }

  @override
  String companyDetailCatastrophicLossPenalty(int pts) {
    return 'Catastrophic loss penalty: -$pts pts (net margin below -100%)';
  }

  @override
  String get companyDetailLegalDisclaimerMethodology =>
      'Legal Disclaimer & Methodology';

  @override
  String get companyDetailMarkerValuation => 'Valuation';

  @override
  String get companyDetailMarkerFinancialHealth => 'Financial Health';

  @override
  String get companyDetailMarkerGrowthPotential => 'Growth Potential';

  @override
  String get companyDetailMarkerEfficiency => 'Efficiency';

  @override
  String get companyDetailMarkerHistoricalTrend => 'Historical Trend';

  @override
  String get companyDetailMarkerShareholderReturns => 'Shareholder Returns';

  @override
  String get companyDetailMarkerDescValuation => 'P/E vs sector average';

  @override
  String get companyDetailMarkerDescFinancialHealth => 'Debt/Equity ratio';

  @override
  String get companyDetailMarkerDescGrowth => 'Revenue & EPS 5Y growth';

  @override
  String get companyDetailMarkerDescEfficiency => 'Net margin & ROE';

  @override
  String get companyDetailMarkerDescHistoricalTrend => '5Y share price CAGR';

  @override
  String get companyDetailMarkerDescShareholderReturns =>
      'Dividends & buybacks';

  @override
  String get companyDetailRatingExcellent => 'Excellent';

  @override
  String get companyDetailRatingGood => 'Good';

  @override
  String get companyDetailRatingAverage => 'Average';

  @override
  String get companyDetailRatingWeak => 'Weak';

  @override
  String get companyDetailRatingPoor => 'Poor';

  @override
  String get companyWidgetPriceHeader => 'Price & Header';

  @override
  String get companyWidgetKeyMetrics => 'Key Metrics';

  @override
  String get companyWidgetFinancialScore => 'Financial Score';

  @override
  String get companyWidgetPosition => 'Your Position';

  @override
  String get companyWidgetLimitOrders => 'Limit Orders';

  @override
  String companyDetailCashAvailable(String cash) {
    return '$cash available';
  }

  @override
  String get companyDetailAcademicDisclaimerTitle =>
      'Educational & Academic Disclaimer';

  @override
  String get companyDetailAcademicDisclaimerBody =>
      'The methodology, definitions, and analytical principles presented here are based on standard corporate finance theory and valuation frameworks taught in leading business schools. Provided strictly for educational purposes.';

  @override
  String get companyDetailAdTitle => 'Sponsored Ad';

  @override
  String get companyDetailAdContinuing => 'Continuing in a moment…';

  @override
  String get companyDetailNoPriceDataAvailable => 'No price data available';

  @override
  String get companyDetailChartLoadError => 'Failed to load chart';

  @override
  String get companyDetailChartNotEnoughData => 'Not enough data';

  @override
  String get commonOk => 'OK';

  @override
  String get orderEntryTabMarket => 'Market';

  @override
  String get orderEntryTabLimit => 'Limit';

  @override
  String get orderEntryExtendedHoursTitle => 'Extended Hours';

  @override
  String get orderEntryExtendedHoursSubtitle =>
      'Off: trade only while the real market is open';

  @override
  String get orderEntrySimulatedDisclaimerTitle =>
      'Simulated Trading & Non-Brokerage Disclaimer';

  @override
  String get orderEntrySimulatedDisclaimerBody =>
      'This application is not a registered broker-dealer, investment advisor, or financial institution, and does not provide order execution services for real financial markets.\n\nAll buy and sell operations are performed exclusively on a simulated account using virtual currency (Paper Trading). Transactions executed within this app are intended solely for educational purposes, do not result in the purchase or ownership of actual securities, create no shareholder rights, and carry no real-world financial or legal force.';

  @override
  String get orderEntryUnitUsd => 'USD';

  @override
  String get orderEntryUnitShares => 'Shares';

  @override
  String orderEntryApproxShares(String shares) {
    return '≈ $shares shares';
  }

  @override
  String get orderEntryLimitPriceTitle => 'LIMIT PRICE';

  @override
  String get orderEntryLimitPriceHintBuy =>
      'Choose a price below the current price for Buy orders';

  @override
  String get orderEntryLimitPriceHintSell =>
      'Choose a price above the current price for Sell orders';

  @override
  String get orderEntryCostLabel => 'Cost:';

  @override
  String get orderEntryQtyLabel => 'Qty:';

  @override
  String orderEntrySharesAbbrev(String shares) {
    return '$shares sh.';
  }

  @override
  String get orderEntryPlaceOrder => 'Place Order';

  @override
  String get orderEntryMarketClosedTitle => 'Market Closed';

  @override
  String get orderEntryMarketClosedBody =>
      'Sorry, the market is currently closed, so Market orders can\'t be filled right now.\n\nYou can still place a Limit order — it will wait and execute once the market reopens. Or turn on Extended Hours to trade around the clock.';

  @override
  String get orderEntryPlaceLimitInstead => 'Place Limit Order Instead';

  @override
  String get orderEntryEnterAmount => 'Enter an amount';

  @override
  String get orderEntryInvalidQuantity => 'Invalid quantity';

  @override
  String get orderEntryEnterValidLimitPrice => 'Enter a valid limit price';

  @override
  String orderEntryNotEnoughCash(String cash) {
    return 'Not enough available cash — $cash free (some is reserved for pending orders)';
  }

  @override
  String get orderEntryInfoMarket =>
      'Market orders execute at the best available price. Execution is guaranteed, but the final price may differ from expectations.';

  @override
  String get orderEntryInfoLimit =>
      'Limit orders execute only at the specified price or better. Partial or full execution is not guaranteed.';

  @override
  String get orderEntryInfoStop =>
      'Stop orders activate when the stop price is reached, then execute as a market order.';

  @override
  String get orderEntryInfoStopLimit =>
      'Stop-limit orders activate when the stop price is reached, then execute as a limit order.';

  @override
  String get stressTestOrderInfoMarket =>
      'Market orders execute at the best available simulated price. Execution is guaranteed, but the final price may differ from expectations.';

  @override
  String get stressTestOrderInfoLimit =>
      'Limit orders execute only once the simulated price reaches your chosen price or better. Execution is not guaranteed.';

  @override
  String get orderEntryHoldingsLimitTitle => 'Limit Reached';

  @override
  String orderEntryHoldingsLimitBody(int max) {
    return 'You\'ve exceeded the allowed limit on asset purchases for this portfolio ($max companies).';
  }

  @override
  String get orderEntryHoldingsLimitPromoTitle =>
      'Portfolio holding limit reached';

  @override
  String get orderEntryPriceLoadError => 'Could not load the current price';

  @override
  String get companyDetailDisclaimerTitle =>
      'Educational Purpose & Legal Disclaimer';

  @override
  String get companyDetailDisclaimerBody =>
      'This application operates strictly as an educational simulator designed to help users learn how to analyze and understand business fundamentals. Evaluation scores and analytics are derived from public corporate financial filings, as well as academic frameworks from leading universities and established financial literacy textbooks.\n\nDisplayed market prices and metrics may be delayed, estimated, or differ from live exchange prices. Content within this app does not constitute a solicitation, recommendation, or offer to buy or sell any financial security. All trading decisions are made solely and independently by the user. The developers do not provide financial services and bear no liability for any potential lost profits, financial losses, or loss of real-world capital.\n\nContinued use of this application constitutes your full acknowledgment and acceptance of this disclaimer, including the release of developers from any liability. Failure to read this disclaimer does not exempt the user from compliance nor provide grounds for any claims, disputes, or legal actions.';

  @override
  String get metricInfoPeTitle => 'P/E';

  @override
  String get metricInfoPeSubtitle => 'Price-to-Earnings Ratio';

  @override
  String get metricInfoPeSection1Header => 'What is P/E?';

  @override
  String get metricInfoPeSection1Body =>
      'The Price-to-Earnings Ratio (P/E) compares a company\'s stock price to the amount of profit it earns.\n\nIn simple terms: P/E shows how much investors are willing to pay today for every \$1 of the company\'s annual earnings. It is one of the most widely used valuation metrics in the stock market.';

  @override
  String get metricInfoPeSection2Header => 'How is it calculated?';

  @override
  String get metricInfoPeSection2Body =>
      'Formula\nP/E = Share Price ÷ Earnings Per Share (EPS)\n\nExample\nShare Price = \$100\nEarnings Per Share = \$5\nP/E = 100 ÷ 5 = 20\n\nThis means investors are currently paying \$20 for every \$1 of annual profit.';

  @override
  String get metricInfoPeSection3Header => 'What does it tell you?';

  @override
  String get metricInfoPeSection3Body =>
      'P/E helps answer one important question: \"Is this company expensive or cheap compared to its earnings?\"\n\nGenerally:\n• Lower P/E = lower valuation\n• Higher P/E = higher valuation\n\nHowever, a low P/E is not automatically good, and a high P/E is not automatically bad. Context always matters.';

  @override
  String get metricInfoPeSection4Header => 'What is considered a good P/E?';

  @override
  String get metricInfoPeSection4Body =>
      'There is no perfect number, because every industry is different.\n\nBelow 10 — Often considered very cheap. Possible reasons: market pessimism, declining business, temporary problems, or a hidden opportunity. Requires careful research.\n\n10–20 — Often considered a reasonable valuation for mature companies. Common among stable businesses such as consumer goods, banks, and industrial companies.\n\n20–30 — Investors expect future earnings growth, a strong competitive position, and a reliable business model. The company is becoming more expensive.\n\nAbove 30 — The market expects significant future growth. Common among technology companies, fast-growing businesses, and innovative industries. These companies can perform very well — but they also carry higher expectations.';

  @override
  String get metricInfoPeSection5Header =>
      'Why can a high P/E be completely normal?';

  @override
  String get metricInfoPeSection5Body =>
      'Imagine two companies.\n\nCompany A — Profit grows 2% per year, P/E = 12\nCompany B — Profit grows 35% per year, P/E = 40\n\nAt first glance, Company B looks very expensive. But if its profits continue growing rapidly, today\'s high valuation may become reasonable over time. Investors are paying not only for today\'s earnings — but also for tomorrow\'s potential.';

  @override
  String get metricInfoPeSection6Header => 'Why can a low P/E be dangerous?';

  @override
  String get metricInfoPeSection6Body =>
      'A low P/E may indicate that investors expect problems. Possible reasons include: falling sales, declining profits, large debt, loss of market share, legal issues, or poor management.\n\nSometimes the market is simply reacting to risks that are not immediately obvious. This is known as a Value Trap — a stock that appears cheap but continues to perform poorly.';

  @override
  String get metricInfoPeSection7Header => 'What if the P/E is negative?';

  @override
  String get metricInfoPeSection7Body =>
      'A negative P/E means the company reported a loss instead of a profit. This does not necessarily mean the company is failing.\n\nPossible reasons include: heavy investment in future growth, building new factories, expanding into new markets, acquiring another company, a temporary economic downturn, or one-time accounting expenses.\n\nMany successful companies have experienced periods of negative earnings before returning to profitability.';

  @override
  String get metricInfoPeSection8Header => 'What is \"Hype\"?';

  @override
  String get metricInfoPeSection8Body =>
      'Sometimes investors become extremely optimistic about a company. The stock price rises much faster than the company\'s actual earnings, so the P/E ratio becomes very high.\n\nThis often happens when investors expect revolutionary technology, Artificial Intelligence growth, new breakthrough products, or massive future expansion. A high P/E driven by excitement is often called market hype.\n\nIf the company fails to meet those high expectations, the stock price can fall sharply — even if the business remains healthy.';

  @override
  String get metricInfoPeSection9Header => 'Common mistakes beginners make';

  @override
  String get metricInfoPeSection9Body =>
      '• Buying only because the P/E is low.\n• Avoiding every company with a high P/E.\n• Comparing companies from completely different industries.\n• Ignoring profit growth.\n• Ignoring debt levels.\n• Making investment decisions based on a single metric.';

  @override
  String get metricInfoPeSection10Header => 'P/E has limitations';

  @override
  String get metricInfoPeSection10Body =>
      'P/E works best for companies that consistently earn profits. It is less useful for startups, companies with temporary losses, businesses with highly cyclical earnings, or firms experiencing major restructuring.\n\nFor these companies, investors often rely on additional valuation metrics.';

  @override
  String get metricInfoPeSection11Header => 'Best used together with';

  @override
  String get metricInfoPeSection11Body =>
      'P/E should never be viewed alone. Combine it with: Revenue Growth, Net Margin, Operating Margin, ROE, Debt Levels, Free Cash Flow, and Dividend Yield.\n\nLooking at several metrics together provides a much clearer picture of a company\'s financial health.';

  @override
  String get metricInfoPeSection12Header => 'Real-world analogy';

  @override
  String get metricInfoPeSection12Body =>
      'Imagine two apartment buildings.\n\nBuilding A — Price: \$500,000, Annual rental income: \$50,000\nBuilding B — Price: \$1,000,000, Annual rental income: \$50,000\n\nBuilding A appears much cheaper. But if Building B is located in the center of a rapidly growing city where rental income is expected to double in a few years, the higher price may be justified.\n\nStocks work in a similar way.';

  @override
  String get metricInfoPeSection13Header => 'Key Takeaway';

  @override
  String get metricInfoPeSection13Body =>
      'P/E measures how much investors are paying for each dollar of a company\'s earnings. It is an excellent starting point for evaluating a stock — but it should never be used as the only factor when making an investment decision.';

  @override
  String get metricInfoDividendYieldTitle => 'Dividend Yield';

  @override
  String get metricInfoDividendYieldSubtitle =>
      'Annual Dividend Income vs. Share Price';

  @override
  String get metricInfoDividendYieldSection1Header => 'What is Dividend Yield?';

  @override
  String get metricInfoDividendYieldSection1Body =>
      'Dividend Yield shows how much cash a company pays its shareholders each year relative to the current stock price.\n\nIn simple terms: Dividend Yield tells you how much annual income you receive from dividends for every \$100 invested in the stock. It is one of the most important metrics for income investors.';

  @override
  String get metricInfoDividendYieldSection2Header => 'How is it calculated?';

  @override
  String get metricInfoDividendYieldSection2Body =>
      'Formula\nDividend Yield = Annual Dividend per Share ÷ Share Price × 100%\n\nExample\nAnnual Dividend = \$2.40\nShare Price = \$100\nDividend Yield = 2.4%\n\nThis means that for every \$100 invested, you receive approximately \$2.40 per year in dividends (before taxes).';

  @override
  String get metricInfoDividendYieldSection3Header => 'What does it tell you?';

  @override
  String get metricInfoDividendYieldSection3Body =>
      'Dividend Yield measures the income potential of a stock.\n\nGenerally:\n• Higher Yield = Higher dividend income\n• Lower Yield = Lower dividend income\n\nHowever, a higher dividend yield is not always better.';

  @override
  String get metricInfoDividendYieldSection4Header =>
      'What is considered a good Dividend Yield?';

  @override
  String get metricInfoDividendYieldSection4Body =>
      'There is no universal \"best\" number.\n\n0% — The company pays no dividend. Common for growth companies, startups, and many technology companies. Instead of paying shareholders, these businesses reinvest profits to grow faster.\n\n1%–2% — A relatively small dividend. Often seen in companies focused on long-term growth while still rewarding shareholders.\n\n2%–4% — Generally considered a healthy and sustainable range. Many high-quality companies fall into this category.\n\n4%–6% — A relatively high dividend. Can be attractive, but investors should check whether the company can continue paying it.\n\nAbove 6% — Requires extra attention. Sometimes the dividend is genuinely generous. Sometimes the stock price has fallen sharply, making the yield appear unusually high. This can be a warning sign rather than a bargain.';

  @override
  String get metricInfoDividendYieldSection5Header =>
      'Why isn\'t a high Dividend Yield always good?';

  @override
  String get metricInfoDividendYieldSection5Body =>
      'Dividend Yield increases whenever dividends increase, or the stock price falls.\n\nImagine this example.\n\nYesterday — Price = \$100, Dividend = \$4, Yield = 4%\nToday — Price falls to \$50, Dividend stays \$4, Yield becomes 8%\n\nThe dividend hasn\'t improved. The stock simply became much cheaper. Investors may be worried about the company\'s future.';

  @override
  String get metricInfoDividendYieldSection6Header =>
      'Can a company have a 0% Dividend Yield and still be excellent?';

  @override
  String get metricInfoDividendYieldSection6Body =>
      'Absolutely. Many successful companies choose not to pay dividends. Instead, they use their profits to: develop new products, expand internationally, build new factories, acquire competitors, or invest in research and innovation.\n\nIf those investments generate higher future profits, shareholders may benefit through rising stock prices instead of dividend payments.';

  @override
  String get metricInfoDividendYieldSection7Header =>
      'Can Dividend Yield decrease?';

  @override
  String get metricInfoDividendYieldSection7Body =>
      'Yes. Reasons include: the stock price rises faster than dividends, the company reduces its dividend, or the company temporarily suspends dividend payments.\n\nA lower yield does not automatically indicate a weaker company.';

  @override
  String get metricInfoDividendYieldSection8Header =>
      'Can Dividend Yield increase?';

  @override
  String get metricInfoDividendYieldSection8Body =>
      'Yes. Possible reasons: the company raises its dividend, the stock price declines, or both occur simultaneously.\n\nThis is why investors should always determine why the yield changed.';

  @override
  String get metricInfoDividendYieldSection9Header => 'What is a Dividend Cut?';

  @override
  String get metricInfoDividendYieldSection9Body =>
      'A Dividend Cut occurs when a company reduces the amount of money it pays shareholders. Companies may cut dividends because they need cash for: paying debt, surviving an economic downturn, funding major investments, or protecting the business during difficult periods.\n\nA dividend cut is not always a sign of failure. Sometimes it is a responsible financial decision that strengthens the company over the long term.';

  @override
  String get metricInfoDividendYieldSection10Header =>
      'Why do some companies never pay dividends?';

  @override
  String get metricInfoDividendYieldSection10Body =>
      'Many growth companies believe that every dollar earned can generate even greater returns if reinvested into the business. For example: expanding into new markets, hiring more employees, developing new technology, or increasing production capacity.\n\nIn these cases, investors expect capital appreciation instead of dividend income.';

  @override
  String get metricInfoDividendYieldSection11Header =>
      'Common mistakes beginners make';

  @override
  String get metricInfoDividendYieldSection11Body =>
      '• Buying the stock with the highest Dividend Yield.\n• Assuming dividends are guaranteed forever.\n• Ignoring the company\'s earnings and cash flow.\n• Comparing dividend yields across completely different industries.\n• Focusing only on income while ignoring business quality.';

  @override
  String get metricInfoDividendYieldSection12Header =>
      'Best used together with';

  @override
  String get metricInfoDividendYieldSection12Body =>
      'Dividend Yield becomes much more meaningful when combined with: Dividend Payout Ratio, Earnings Growth, Free Cash Flow, P/E Ratio, Net Margin, and Debt Levels.\n\nThese metrics help determine whether the dividend is sustainable.';

  @override
  String get metricInfoDividendYieldSection13Header => 'Real-world analogy';

  @override
  String get metricInfoDividendYieldSection13Body =>
      'Imagine buying a rental apartment.\n\nApartment A costs \$200,000 and generates \$6,000 per year in rent. Rental Yield = 3%\n\nApartment B costs \$200,000 and generates \$12,000 per year. Rental Yield = 6%\n\nApartment B looks much more attractive. But if the building requires expensive repairs or tenants are leaving, the higher rental yield may come with higher risk.\n\nDividend investing works much the same way.';

  @override
  String get metricInfoDividendYieldSection14Header => 'Key Takeaway';

  @override
  String get metricInfoDividendYieldSection14Body =>
      'Dividend Yield measures the annual dividend income you receive relative to the current stock price. A higher yield can be attractive, but the quality and sustainability of those dividends are far more important than the percentage itself.';

  @override
  String get metricInfoNetMarginTitle => 'Net Margin';

  @override
  String get metricInfoNetMarginSubtitle => 'Profit Kept After All Expenses';

  @override
  String get metricInfoNetMarginSection1Header => 'What is Net Margin?';

  @override
  String get metricInfoNetMarginSection1Body =>
      'Net Margin measures how much profit a company keeps after paying all of its expenses. These expenses include: cost of products, employee salaries, rent, taxes, interest on debt, operating expenses, and all other business costs.\n\nIn simple terms: Net Margin shows how much money the company actually keeps from every dollar of sales. It is often considered one of the best indicators of a company\'s overall profitability.';

  @override
  String get metricInfoNetMarginSection2Header => 'How is it calculated?';

  @override
  String get metricInfoNetMarginSection2Body =>
      'Formula\nNet Margin = Net Income ÷ Revenue × 100%\n\nExample\nRevenue = \$100 million\nNet Income = \$20 million\nNet Margin = 20%\n\nThis means the company keeps \$20 in profit for every \$100 of sales.';

  @override
  String get metricInfoNetMarginSection3Header => 'What does it tell you?';

  @override
  String get metricInfoNetMarginSection3Body =>
      'Net Margin measures how efficiently a company converts revenue into actual profit.\n\nGenerally:\n• Higher Margin = More profitable business\n• Lower Margin = Less profitable business\n\nCompanies with strong Net Margins usually have: efficient operations, strong pricing power, good cost control, and healthy business models.';

  @override
  String get metricInfoNetMarginSection4Header =>
      'What is considered a good Net Margin?';

  @override
  String get metricInfoNetMarginSection4Body =>
      'There is no universal standard because industries are very different.\n\nBelow 5% — Usually considered a low profit margin. Common in businesses with intense competition or thin margins, e.g. grocery stores, airlines, retail chains.\n\n5%–10% — Healthy for many traditional businesses.\n\n10%–20% — Very good profitability. Many successful companies consistently operate in this range.\n\nAbove 20% — Excellent profitability. Often found in companies with strong brands, software businesses, luxury products, or high-value technology.\n\nAbove 30% — Exceptional. Usually indicates an outstanding business model or a company with significant competitive advantages.';

  @override
  String get metricInfoNetMarginSection5Header =>
      'Why is a high Net Margin important?';

  @override
  String get metricInfoNetMarginSection5Body =>
      'A company with a high Net Margin has more flexibility. It can: invest in growth, increase dividends, buy back shares, survive difficult economic periods, or continue investing during recessions.\n\nHigher profitability often means a stronger and more resilient business.';

  @override
  String get metricInfoNetMarginSection6Header =>
      'Why isn\'t a low Net Margin always bad?';

  @override
  String get metricInfoNetMarginSection6Body =>
      'Some industries naturally operate with low margins. For example, a supermarket may earn only 2% Net Margin but sell billions of dollars of products every year. Small profits on enormous sales can still produce substantial earnings.\n\nThis is why Net Margin should always be compared with companies in the same industry.';

  @override
  String get metricInfoNetMarginSection7Header => 'Can Net Margin be negative?';

  @override
  String get metricInfoNetMarginSection7Body =>
      'Yes. A negative Net Margin means the company lost money during the reporting period. However, this does not automatically mean the business is failing.\n\nPossible reasons include: heavy investments, economic recession, one-time legal expenses, factory construction, acquisitions, temporary restructuring, or currency losses.\n\nMany successful companies have experienced temporary negative margins before returning to profitability.';

  @override
  String get metricInfoNetMarginSection8Header =>
      'What causes Net Margin to improve?';

  @override
  String get metricInfoNetMarginSection8Body =>
      'Net Margin usually increases when a company: sells more products, raises prices, reduces costs, improves efficiency, pays less interest, or lowers operating expenses.\n\nConsistently improving margins often indicate excellent management.';

  @override
  String get metricInfoNetMarginSection9Header =>
      'What causes Net Margin to decline?';

  @override
  String get metricInfoNetMarginSection9Body =>
      'Profit margins may shrink because of: rising production costs, higher wages, inflation, increased competition, falling sales, higher interest rates, or unexpected expenses.\n\nA temporary decline is normal. A long-term downward trend deserves closer attention.';

  @override
  String get metricInfoNetMarginSection10Header =>
      'Why is comparing industries important?';

  @override
  String get metricInfoNetMarginSection10Body =>
      'Different industries have completely different business models. For example, a supermarket may have a 2% Net Margin and still be an excellent business, while a software company with a 2% Net Margin would likely have serious profitability issues.\n\nAlways compare companies with their direct competitors.';

  @override
  String get metricInfoNetMarginSection11Header =>
      'Common mistakes beginners make';

  @override
  String get metricInfoNetMarginSection11Body =>
      '• Assuming every company should have the same Net Margin.\n• Comparing technology companies with retailers.\n• Ignoring long-term trends.\n• Looking at only one year\'s results.\n• Ignoring why margins changed.';

  @override
  String get metricInfoNetMarginSection12Header => 'Best used together with';

  @override
  String get metricInfoNetMarginSection12Body =>
      'Net Margin becomes even more useful when combined with: Gross Margin, Operating Margin, ROE, Revenue Growth, Free Cash Flow, P/E Ratio, and Debt Levels.\n\nTogether, these metrics provide a much more complete picture of a company\'s financial health.';

  @override
  String get metricInfoNetMarginSection13Header => 'Real-world analogy';

  @override
  String get metricInfoNetMarginSection13Body =>
      'Imagine two restaurants.\n\nRestaurant A earns \$1,000,000 in annual sales but keeps only \$20,000 in profit. Net Margin = 2%\n\nRestaurant B earns the same \$1,000,000 but keeps \$200,000. Net Margin = 20%\n\nBoth restaurants generate the same revenue, but Restaurant B is far more efficient and profitable. That\'s exactly what Net Margin helps investors understand.';

  @override
  String get metricInfoNetMarginSection14Header => 'Key Takeaway';

  @override
  String get metricInfoNetMarginSection14Body =>
      'Net Margin measures how much profit a company keeps after paying all expenses. Higher margins generally indicate a stronger, more efficient, and more financially healthy business, but comparisons should always be made within the same industry.';

  @override
  String get metricInfoOperatingMarginTitle => 'Operating Margin';

  @override
  String get metricInfoOperatingMarginSubtitle =>
      'Core Business Profit Before Interest and Taxes';

  @override
  String get metricInfoOperatingMarginSection1Header =>
      'What is Operating Margin?';

  @override
  String get metricInfoOperatingMarginSection1Body =>
      'Operating Margin measures how much profit a company earns from its core business operations before paying interest on debt and taxes. Unlike Net Margin, Operating Margin focuses only on how efficiently the business itself is run.\n\nIn simple terms: Operating Margin shows how much money the company keeps from every dollar of sales before financing costs and taxes. Many professional investors consider this one of the best measures of management efficiency.';

  @override
  String get metricInfoOperatingMarginSection2Header => 'How is it calculated?';

  @override
  String get metricInfoOperatingMarginSection2Body =>
      'Formula\nOperating Margin = Operating Income ÷ Revenue × 100%\n\nExample\nRevenue = \$100 million\nOperating Income = \$25 million\nOperating Margin = 25%\n\nThis means that after paying for all operating expenses, the company keeps \$25 for every \$100 of sales, before interest and taxes.';

  @override
  String get metricInfoOperatingMarginSection3Header =>
      'What does it tell you?';

  @override
  String get metricInfoOperatingMarginSection3Body =>
      'Operating Margin measures how profitable the company\'s core business really is. It answers questions like: is management controlling costs? Is the business efficient? Can the company generate healthy profits from its everyday operations?\n\nA strong Operating Margin usually indicates a well-managed company.';

  @override
  String get metricInfoOperatingMarginSection4Header =>
      'What is Operating Income?';

  @override
  String get metricInfoOperatingMarginSection4Body =>
      'Operating Income is the profit remaining after paying for: cost of goods sold (COGS), employee salaries, rent, marketing, research & development, administrative expenses, and other operating costs.\n\nIt does not include: interest payments, income taxes, or one-time extraordinary gains or losses.\n\nThis makes Operating Margin a cleaner measure of business performance.';

  @override
  String get metricInfoOperatingMarginSection5Header =>
      'What is considered a good Operating Margin?';

  @override
  String get metricInfoOperatingMarginSection5Body =>
      'Different industries have different standards.\n\nBelow 5% — Generally considered low. Common in businesses with intense competition.\n\n5%–10% — Healthy for many traditional companies.\n\n10%–20% — Strong operating performance. Many successful businesses consistently achieve margins in this range.\n\nAbove 20% — Excellent. Often indicates strong pricing power, efficient management, or competitive advantages.\n\nAbove 30% — Outstanding. Usually found in software companies, luxury brands, or businesses with exceptionally efficient operations.';

  @override
  String get metricInfoOperatingMarginSection6Header =>
      'Why is Operating Margin important?';

  @override
  String get metricInfoOperatingMarginSection6Body =>
      'Unlike Net Margin, Operating Margin removes factors that management doesn\'t fully control, such as tax rates, interest expenses, and debt structure. This allows investors to evaluate the quality of the company\'s actual business operations.\n\nTwo companies may have different Net Margins simply because one has more debt. Operating Margin helps remove that distortion.';

  @override
  String get metricInfoOperatingMarginSection7Header =>
      'Why can Operating Margin be low?';

  @override
  String get metricInfoOperatingMarginSection7Body =>
      'A lower Operating Margin does not automatically mean a weak company. Possible reasons include: heavy investment in growth, launching new products, expanding into new markets, higher marketing spending, rising labor costs, or temporary inflation.\n\nSometimes these investments lead to much stronger profits in the future.';

  @override
  String get metricInfoOperatingMarginSection8Header =>
      'Can Operating Margin be negative?';

  @override
  String get metricInfoOperatingMarginSection8Body =>
      'Yes. A negative Operating Margin means the company\'s core business is currently losing money before even paying interest or taxes.\n\nPossible reasons include: weak sales, high production costs, poor cost control, major expansion, economic downturn, or temporary restructuring.\n\nA single negative quarter is not necessarily alarming. However, consistently negative Operating Margins deserve careful investigation.';

  @override
  String get metricInfoOperatingMarginSection9Header =>
      'Why do investors like stable Operating Margins?';

  @override
  String get metricInfoOperatingMarginSection9Body =>
      'A company with stable or improving Operating Margins often demonstrates: strong management, consistent pricing power, good cost control, and sustainable competitive advantages.\n\nLong-term stability is often more valuable than one exceptionally high result.';

  @override
  String get metricInfoOperatingMarginSection10Header =>
      'Why should you compare companies in the same industry?';

  @override
  String get metricInfoOperatingMarginSection10Body =>
      'Operating Margins vary dramatically between industries. For example, a supermarket may operate with a 4% Operating Margin and still be an excellent business, while a software company with a 4% Operating Margin would likely have serious profitability issues.\n\nIndustry comparisons are essential.';

  @override
  String get metricInfoOperatingMarginSection11Header =>
      'Common mistakes beginners make';

  @override
  String get metricInfoOperatingMarginSection11Body =>
      '• Confusing Operating Margin with Net Margin.\n• Comparing companies from different industries.\n• Ignoring long-term trends.\n• Assuming one unusually high year represents normal performance.\n• Looking only at one financial metric.';

  @override
  String get metricInfoOperatingMarginSection12Header =>
      'Best used together with';

  @override
  String get metricInfoOperatingMarginSection12Body =>
      'Operating Margin becomes much more powerful when analyzed alongside: Gross Margin, Net Margin, Revenue Growth, ROE, Free Cash Flow, Debt Levels, and P/E Ratio.\n\nTogether, these metrics provide a comprehensive view of business quality.';

  @override
  String get metricInfoOperatingMarginSection13Header => 'Real-world analogy';

  @override
  String get metricInfoOperatingMarginSection13Body =>
      'Imagine two delivery companies. Both generate \$100 million in revenue.\n\nCompany A spends \$85 million operating its business. Operating Margin = 15%\n\nCompany B spends only \$70 million. Operating Margin = 30%\n\nEven before paying taxes or interest, Company B is running a much more efficient business. That efficiency often leads to stronger long-term performance.';

  @override
  String get metricInfoOperatingMarginSection14Header => 'Key Takeaway';

  @override
  String get metricInfoOperatingMarginSection14Body =>
      'Operating Margin measures how profitable a company\'s core business is before interest and taxes. A higher Operating Margin generally indicates better operational efficiency, stronger cost control, and a healthier underlying business model.';

  @override
  String get metricInfoGrossMarginTitle => 'Gross Margin';

  @override
  String get metricInfoGrossMarginSubtitle =>
      'Profit After Direct Production Costs';

  @override
  String get metricInfoGrossMarginSection1Header => 'What is Gross Margin?';

  @override
  String get metricInfoGrossMarginSection1Body =>
      'Gross Margin measures how much money a company keeps after paying only the direct costs of producing its products or services. These direct costs are known as Cost of Goods Sold (COGS).\n\nIn simple terms: Gross Margin shows how profitable a company\'s products are before paying for salaries, marketing, rent, taxes, interest, and other operating expenses. It is one of the first indicators of a company\'s pricing power and production efficiency.';

  @override
  String get metricInfoGrossMarginSection2Header => 'How is it calculated?';

  @override
  String get metricInfoGrossMarginSection2Body =>
      'Formula\nGross Margin = (Revenue − Cost of Goods Sold) ÷ Revenue × 100%\n\nExample\nRevenue = \$100 million\nCost of Goods Sold = \$60 million\nGross Profit = \$40 million\nGross Margin = 40%\n\nThis means the company keeps \$40 from every \$100 of sales before paying any operating expenses.';

  @override
  String get metricInfoGrossMarginSection3Header =>
      'What is Cost of Goods Sold (COGS)?';

  @override
  String get metricInfoGrossMarginSection3Body =>
      'COGS includes the direct costs required to produce a product or provide a service. Examples include: raw materials, manufacturing costs, factory labor, packaging, shipping to warehouses, and production equipment directly used to make products.\n\nCOGS does not include: office salaries, advertising, research & development, taxes, interest payments, or administrative expenses.';

  @override
  String get metricInfoGrossMarginSection4Header => 'What does it tell you?';

  @override
  String get metricInfoGrossMarginSection4Body =>
      'Gross Margin answers one simple question: \"How profitable is the product itself?\"\n\nA high Gross Margin usually means the company can produce its products at a relatively low cost compared to the selling price.';

  @override
  String get metricInfoGrossMarginSection5Header =>
      'What is considered a good Gross Margin?';

  @override
  String get metricInfoGrossMarginSection5Body =>
      'The answer depends on the industry.\n\nBelow 20% — Typically found in industries with intense price competition, e.g. grocery stores, food wholesalers, fuel distributors.\n\n20%–40% — Healthy for many traditional manufacturers.\n\n40%–60% — Strong profitability. Common among companies with valuable brands or premium products.\n\nAbove 60% — Excellent. Frequently seen in software companies, luxury brands, pharmaceutical companies, and technology businesses.\n\nAbove 80% — Exceptional. Usually indicates that the product costs very little to produce while customers are willing to pay a premium price.';

  @override
  String get metricInfoGrossMarginSection6Header =>
      'Why is a high Gross Margin important?';

  @override
  String get metricInfoGrossMarginSection6Body =>
      'A company with a high Gross Margin has more money available to pay for: marketing, employee salaries, research & development, expansion, debt payments, or dividends.\n\nHigh Gross Margins give businesses greater flexibility during difficult economic periods.';

  @override
  String get metricInfoGrossMarginSection7Header =>
      'Why isn\'t a low Gross Margin always bad?';

  @override
  String get metricInfoGrossMarginSection7Body =>
      'Some industries naturally have low Gross Margins. For example, a supermarket may earn only 15% Gross Margin, but because it sells millions of products every day, it can still generate significant profits.\n\nBusiness models matter. Always compare companies within the same industry.';

  @override
  String get metricInfoGrossMarginSection8Header =>
      'Can Gross Margin decrease?';

  @override
  String get metricInfoGrossMarginSection8Body =>
      'Yes. Common reasons include: rising material costs, higher wages, increased shipping costs, inflation, discounts offered to customers, stronger competition, or supply chain disruptions.\n\nA declining Gross Margin often signals that production is becoming more expensive or pricing power is weakening.';

  @override
  String get metricInfoGrossMarginSection9Header =>
      'Can Gross Margin increase?';

  @override
  String get metricInfoGrossMarginSection9Body =>
      'Absolutely. Possible reasons include: higher product prices, lower production costs, better supplier contracts, improved manufacturing efficiency, selling more premium products, or economies of scale.\n\nImproving Gross Margins often indicate a strengthening business.';

  @override
  String get metricInfoGrossMarginSection10Header =>
      'Why do investors monitor Gross Margin trends?';

  @override
  String get metricInfoGrossMarginSection10Body =>
      'A single year\'s Gross Margin tells only part of the story. What\'s more important is whether the margin is increasing, stable, or declining.\n\nA company with steadily improving Gross Margins is often becoming more competitive and more efficient.';

  @override
  String get metricInfoGrossMarginSection11Header =>
      'Common mistakes beginners make';

  @override
  String get metricInfoGrossMarginSection11Body =>
      '• Thinking Gross Margin equals overall profit.\n• Comparing completely different industries.\n• Ignoring changes over time.\n• Looking only at one year\'s results.\n• Forgetting that operating expenses still need to be paid.';

  @override
  String get metricInfoGrossMarginSection12Header =>
      'How is Gross Margin different from Operating Margin and Net Margin?';

  @override
  String get metricInfoGrossMarginSection12Body =>
      'Think of profitability as three stages.\n\nGross Margin — How profitable is the product itself?\n\nOperating Margin — How profitable is the entire business operation?\n\nNet Margin — How much profit remains after absolutely everything has been paid?\n\nThese three margins together tell the complete story of a company\'s profitability.';

  @override
  String get metricInfoGrossMarginSection13Header => 'Best used together with';

  @override
  String get metricInfoGrossMarginSection13Body =>
      'Gross Margin becomes much more valuable when combined with: Operating Margin, Net Margin, Revenue Growth, ROE, Free Cash Flow, and P/E Ratio.\n\nTogether they help investors understand where a company\'s profits are being earned — and where they are being spent.';

  @override
  String get metricInfoGrossMarginSection14Header => 'Real-world analogy';

  @override
  String get metricInfoGrossMarginSection14Body =>
      'Imagine a bakery sells a cake for \$100. The ingredients cost \$35.\n\nGross Profit = \$65\nGross Margin = 65%\n\nHowever, the bakery still has to pay: employee wages, rent, electricity, advertising, and taxes. Only after paying those expenses does the business know its true profit.\n\nGross Margin simply measures how profitable the cake itself is before all those additional costs.';

  @override
  String get metricInfoGrossMarginSection15Header => 'Key Takeaway';

  @override
  String get metricInfoGrossMarginSection15Body =>
      'Gross Margin measures how much money a company keeps after paying the direct costs of producing its products or services. A higher Gross Margin generally indicates stronger pricing power, better production efficiency, and greater financial flexibility — but it should always be compared with companies in the same industry.';

  @override
  String get metricInfoRoeTitle => 'ROE';

  @override
  String get metricInfoRoeSubtitle => 'Return on Equity';

  @override
  String get metricInfoRoeSection1Header => 'What is ROE?';

  @override
  String get metricInfoRoeSection1Body =>
      'Return on Equity (ROE) measures how efficiently a company generates profit using the money invested by its shareholders.\n\nIn simple terms: ROE shows how much profit the company earns for every \$1 of shareholders\' equity. It is one of the most important indicators of management efficiency and business quality.';

  @override
  String get metricInfoRoeSection2Header => 'How is it calculated?';

  @override
  String get metricInfoRoeSection2Body =>
      'Formula\nROE = Net Income ÷ Shareholders\' Equity × 100%\n\nExample\nNet Income = \$20 million\nShareholders\' Equity = \$100 million\nROE = 20%\n\nThis means the company generated 20 cents of profit for every \$1 invested by shareholders.';

  @override
  String get metricInfoRoeSection3Header => 'What is Shareholders\' Equity?';

  @override
  String get metricInfoRoeSection3Body =>
      'Shareholders\' Equity represents the value that belongs to the company\'s owners after all debts have been paid. It is calculated as:\n\nAssets − Liabilities = Shareholders\' Equity\n\nThink of it as the company\'s net worth. If the business sold all of its assets and paid every debt, whatever remained would belong to the shareholders.';

  @override
  String get metricInfoRoeSection4Header => 'What does ROE tell you?';

  @override
  String get metricInfoRoeSection4Body =>
      'ROE measures how effectively management uses shareholders\' money. A higher ROE generally means the company is producing more profit without requiring large amounts of additional investment.\n\nCompanies with consistently high ROE often have: strong business models, efficient management, competitive advantages, and high profitability.';

  @override
  String get metricInfoRoeSection5Header => 'What is considered a good ROE?';

  @override
  String get metricInfoRoeSection5Body =>
      'The answer depends on the industry, but general guidelines are:\n\nBelow 5% — Usually considered weak. The company is generating relatively little profit from shareholders\' capital.\n\n5%–10% — Acceptable. Common among slower-growing or highly competitive businesses.\n\n10%–15% — Healthy. Many established companies operate in this range.\n\n15%–20% — Very strong. Often indicates a high-quality business.\n\nAbove 20% — Excellent. Companies that consistently maintain ROE above 20% often have durable competitive advantages.\n\nAbove 30% — Exceptional, but requires closer examination. Sometimes a very high ROE reflects an outstanding business. Other times, it may simply result from very high debt.';

  @override
  String get metricInfoRoeSection6Header => 'Why can a high ROE be misleading?';

  @override
  String get metricInfoRoeSection6Body =>
      'A company can increase ROE in two very different ways.\n\nGood reason — It becomes more profitable.\n\nRisky reason — It borrows large amounts of money.\n\nWhen debt increases, Shareholders\' Equity becomes smaller relative to total assets. A smaller equity base can make ROE appear much higher — even if the business itself has not improved.\n\nFor this reason, ROE should always be analyzed together with Debt Levels.';

  @override
  String get metricInfoRoeSection7Header =>
      'Can a low ROE still be acceptable?';

  @override
  String get metricInfoRoeSection7Body =>
      'Yes. Young companies often invest heavily in: new factories, research, expansion, or new products. These investments increase Shareholders\' Equity before they begin generating significant profits.\n\nAs a result, ROE may remain low for several years while the business is still growing.';

  @override
  String get metricInfoRoeSection8Header => 'Can ROE be negative?';

  @override
  String get metricInfoRoeSection8Body =>
      'Yes. A negative ROE means the company reported a net loss. However, this does not automatically mean the company is failing.\n\nPossible reasons include: temporary recession, major investments, one-time accounting losses, acquisitions, restructuring, or extraordinary expenses.\n\nThe important question is whether profitability is expected to recover.';

  @override
  String get metricInfoRoeSection9Header => 'Why do investors like stable ROE?';

  @override
  String get metricInfoRoeSection9Body =>
      'One excellent year means very little. A company that consistently generates ROE around 18–21% over many years demonstrates stable management and a durable business model.\n\nConsistency is often more valuable than occasional spikes.';

  @override
  String get metricInfoRoeSection10Header => 'Common mistakes beginners make';

  @override
  String get metricInfoRoeSection10Body =>
      '• Looking only at one year\'s ROE.\n• Ignoring debt.\n• Comparing unrelated industries.\n• Assuming every high ROE is a sign of quality.\n• Ignoring long-term trends.';

  @override
  String get metricInfoRoeSection11Header => 'Best used together with';

  @override
  String get metricInfoRoeSection11Body =>
      'ROE becomes much more powerful when combined with: Debt to Equity, Net Margin, Operating Margin, Gross Margin, Free Cash Flow, Revenue Growth, and P/E Ratio.\n\nThese metrics help determine whether high profitability is sustainable.';

  @override
  String get metricInfoRoeSection12Header => 'Real-world analogy';

  @override
  String get metricInfoRoeSection12Body =>
      'Imagine two business owners. Both invested \$100,000 into their companies.\n\nOwner A earns \$8,000 per year. ROE = 8%\n\nOwner B earns \$25,000. ROE = 25%\n\nOwner B is using the same amount of invested capital much more efficiently. That is exactly what ROE measures.';

  @override
  String get metricInfoRoeSection13Header =>
      'Why long-term investors watch ROE closely';

  @override
  String get metricInfoRoeSection13Body =>
      'Many successful long-term investors favor companies that consistently generate high ROE over many years.\n\nWhy? Because consistently high ROE may indicate: strong management, durable competitive advantages, efficient use of capital, and a business capable of generating long-term value for shareholders.\n\nThat said, high ROE should always be checked against reasonable debt levels — see below.';

  @override
  String get metricInfoRoeSection14Header => 'Key Takeaway';

  @override
  String get metricInfoRoeSection14Body =>
      'ROE measures how efficiently a company turns shareholders\' money into profit. A consistently high ROE often signals a high-quality business, but investors should always check whether that performance is driven by genuine profitability or excessive debt.';

  @override
  String get metricInfoValuationTitle => 'Valuation';

  @override
  String get metricInfoValuationSubtitle =>
      'How Fairly the Market Is Pricing the Company';

  @override
  String get metricInfoValuationSection1Header => 'What is Valuation?';

  @override
  String get metricInfoValuationSection1Body =>
      'Valuation measures how fairly the market is pricing a company based on its financial performance and compared to other companies in the same industry.\n\nIn simple terms: it helps you understand whether investors may be paying too much—or too little—for the company\'s stock.\n\nHowever, an expensive stock is not always a bad investment, and a cheap stock is not always a good one.';

  @override
  String get metricInfoValuationSection2Header => 'Why is Valuation important?';

  @override
  String get metricInfoValuationSection2Body =>
      'When investors buy a stock, they are buying more than the company\'s current business—they are also buying expectations for its future.\n\nSometimes expectations become overly optimistic, causing the stock price to rise much faster than the company\'s actual performance.\n\nAt other times, the market becomes overly pessimistic, allowing high-quality companies to trade below what many investors believe is their fair value.\n\nValuation helps investors judge whether the current price appears reasonable.';

  @override
  String get metricInfoValuationSection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoValuationSection3Body =>
      'A high Valuation score suggests that the company\'s current market price appears reasonable relative to its financial performance and compared with similar companies.\n\nIt does not guarantee that the stock will rise, but it generally indicates a lower risk of overpaying.';

  @override
  String get metricInfoValuationSection4Header => 'What does a low score mean?';

  @override
  String get metricInfoValuationSection4Body =>
      'A low Valuation score may indicate that investors are paying a premium for the company\'s shares.\n\nThis increases the risk that future expectations are already reflected in the stock price.\n\nIf the company fails to meet those expectations, the stock may decline—even if the business itself remains healthy.';

  @override
  String get metricInfoValuationSection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoValuationSection5Body =>
      'Some companies trade at premium valuations for many years because they have:\n\n• Strong competitive advantages\n• Rapid earnings growth\n• Market leadership\n• Innovative products\n• High investor confidence\n\nIn these cases, a higher valuation may be fully justified.';

  @override
  String get metricInfoValuationSection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoValuationSection6Body =>
      'Even if a company appears attractively valued, there is no guarantee that its stock price will increase.\n\nSometimes the market is already aware of risks that are not yet fully reflected in financial reports.\n\nThat is why Valuation should always be considered alongside financial strength, profitability, and future growth potential.';

  @override
  String get metricInfoValuationSection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoValuationSection7Body =>
      'Valuation helps estimate the risk of overpaying, but it does not measure the overall quality of a business.\n\nA company should always be evaluated using multiple financial indicators rather than relying on valuation alone.';

  @override
  String get metricInfoValuationSection8Header => 'Key Takeaway';

  @override
  String get metricInfoValuationSection8Body =>
      'Valuation helps determine whether a company\'s current market price appears fair relative to its financial performance. It is a valuable tool for identifying the risk of overpaying, but it should never be used as the only factor when evaluating an investment.';

  @override
  String get metricInfoFinancialHealthTitle => 'Financial Health';

  @override
  String get metricInfoFinancialHealthSubtitle =>
      'Stability and Ability to Manage Debt';

  @override
  String get metricInfoFinancialHealthSection1Header =>
      'What is Financial Health?';

  @override
  String get metricInfoFinancialHealthSection1Body =>
      'Financial Health evaluates a company\'s overall financial stability and its ability to manage debt and long-term obligations.\n\nIn simple terms: it helps determine whether a company has a strong financial foundation or may face increased financial risk in the future.\n\nA financially healthy company is generally better prepared to navigate economic downturns, invest in future growth, and adapt to changing market conditions.';

  @override
  String get metricInfoFinancialHealthSection2Header =>
      'Why is Financial Health important?';

  @override
  String get metricInfoFinancialHealthSection2Body =>
      'Every business needs money to operate and grow.\n\nSome companies rely mostly on their own resources, while others depend heavily on borrowed money.\n\nDebt is not necessarily bad—it can help a business expand, build new facilities, or acquire competitors. However, excessive debt can become a serious burden, especially during periods of slower growth or higher interest rates.\n\nFinancial Health helps investors understand how resilient a company may be under different economic conditions.';

  @override
  String get metricInfoFinancialHealthSection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoFinancialHealthSection3Body =>
      'A high Financial Health score suggests that the company appears financially stable and is managing its obligations responsibly.\n\nCompanies with strong financial health are generally in a better position to:\n\n• Invest in future growth\n• Handle unexpected challenges\n• Continue operations during economic downturns\n• Maintain financial flexibility\n\nWhile no company is completely risk-free, a stronger financial position often provides greater long-term stability.';

  @override
  String get metricInfoFinancialHealthSection4Header =>
      'What does a low score mean?';

  @override
  String get metricInfoFinancialHealthSection4Body =>
      'A low Financial Health score may indicate that the company is carrying a higher level of financial risk.\n\nThis could reduce its flexibility and make it more vulnerable during difficult economic periods.\n\nCompanies with weaker financial health may face challenges such as:\n\n• Higher borrowing costs\n• Reduced ability to invest\n• Greater pressure during recessions\n• Increased sensitivity to rising interest rates\n\nA lower score does not necessarily mean the company is in trouble, but it deserves closer attention.';

  @override
  String get metricInfoFinancialHealthSection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoFinancialHealthSection5Body =>
      'Some industries naturally rely on higher levels of debt.\n\nFor example:\n\n• Utilities\n• Telecommunications\n• Real estate\n• Infrastructure companies\n\nThese businesses often generate stable cash flows that allow them to manage larger debt levels safely.\n\nAs a result, financial health should always be considered within the context of the company\'s industry and business model.';

  @override
  String get metricInfoFinancialHealthSection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoFinancialHealthSection6Body =>
      'Even financially strong companies can face unexpected challenges.\n\nMarket disruptions, changing consumer demand, poor management decisions, or global economic events can affect any business.\n\nFinancial Health reduces risk—it does not eliminate it.';

  @override
  String get metricInfoFinancialHealthSection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoFinancialHealthSection7Body =>
      'Financial Health reflects a company\'s ability to remain stable over time, but it is only one part of the overall picture.\n\nA company should also be evaluated based on its profitability, valuation, growth potential, and operational efficiency.\n\nLooking at all these factors together provides a much more balanced assessment.';

  @override
  String get metricInfoFinancialHealthSection8Header => 'Key Takeaway';

  @override
  String get metricInfoFinancialHealthSection8Body =>
      'Financial Health measures the overall financial strength and stability of a company. Businesses with stronger financial foundations are generally better equipped to manage uncertainty, support future growth, and withstand economic challenges, but no single indicator should be used in isolation.';

  @override
  String get metricInfoGrowthPotentialTitle => 'Growth Potential';

  @override
  String get metricInfoGrowthPotentialSubtitle =>
      'How Consistently the Business Has Expanded';

  @override
  String get metricInfoGrowthPotentialSection1Header =>
      'What is Growth Potential?';

  @override
  String get metricInfoGrowthPotentialSection1Body =>
      'Growth Potential evaluates how consistently a company has expanded its business over time by increasing its revenue and earnings.\n\nIn simple terms: it helps determine whether a company is growing, standing still, or gradually losing momentum.\n\nGrowing companies often have more opportunities to increase their value over the long term, although growth is never guaranteed.';

  @override
  String get metricInfoGrowthPotentialSection2Header =>
      'Why is Growth Potential important?';

  @override
  String get metricInfoGrowthPotentialSection2Body =>
      'A successful company should not only be profitable today—it should also have the ability to grow in the future.\n\nBusiness growth may come from:\n\n• Selling more products\n• Expanding into new markets\n• Launching new services\n• Increasing market share\n• Improving operational performance\n\nConsistent growth often reflects strong demand, effective management, and a healthy business strategy.';

  @override
  String get metricInfoGrowthPotentialSection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoGrowthPotentialSection3Body =>
      'A high Growth Potential score suggests that the company has demonstrated strong and consistent business growth over time.\n\nCompanies with higher growth potential are often better positioned to:\n\n• Increase future earnings\n• Expand their operations\n• Strengthen their competitive position\n• Create long-term value for shareholders\n\nConsistent growth is generally viewed as a positive sign of business quality.';

  @override
  String get metricInfoGrowthPotentialSection4Header =>
      'What does a low score mean?';

  @override
  String get metricInfoGrowthPotentialSection4Body =>
      'A low Growth Potential score may indicate that business expansion has slowed or become inconsistent.\n\nPossible reasons include:\n\n• Slower customer demand\n• Increased competition\n• Market saturation\n• Economic challenges\n• Company-specific issues\n\nA lower score does not necessarily mean the business is weak, but it may suggest fewer growth opportunities in the near future.';

  @override
  String get metricInfoGrowthPotentialSection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoGrowthPotentialSection5Body =>
      'Not every successful company needs to grow rapidly.\n\nMany mature businesses focus on:\n\n• Stable earnings\n• Reliable dividends\n• Strong cash flow\n• Long-term consistency\n\nThese companies may deliver attractive long-term returns even without rapid expansion.';

  @override
  String get metricInfoGrowthPotentialSection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoGrowthPotentialSection6Body =>
      'Rapid growth often comes with higher expectations.\n\nIf future growth slows, investors may react negatively, even if the company continues to perform well.\n\nGrowth can also become more difficult as companies become larger and more established.\n\nFor this reason, sustainable growth is generally more valuable than short periods of exceptional performance.';

  @override
  String get metricInfoGrowthPotentialSection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoGrowthPotentialSection7Body =>
      'Growth should always be evaluated together with profitability and financial stability.\n\nA company that grows rapidly while consistently generating healthy profits is often in a stronger position than one that grows quickly but struggles financially.\n\nLong-term consistency is usually more important than short-term acceleration.';

  @override
  String get metricInfoGrowthPotentialSection8Header => 'Key Takeaway';

  @override
  String get metricInfoGrowthPotentialSection8Body =>
      'Growth Potential measures how consistently a company has expanded its business over time. Strong and sustainable growth can create long-term opportunities, but it should always be considered alongside profitability, financial health, and overall business quality.';

  @override
  String get metricInfoEfficiencyTitle => 'Efficiency';

  @override
  String get metricInfoEfficiencySubtitle =>
      'How Effectively Revenue Becomes Profit';

  @override
  String get metricInfoEfficiencySection1Header => 'What is Profitability?';

  @override
  String get metricInfoEfficiencySection1Body =>
      'Profitability measures how effectively a company turns its revenue into profit.\n\nIn simple terms: it helps determine whether a company is making money efficiently—or simply generating a lot of sales with little profit.\n\nA profitable company is generally better positioned to invest in growth, reward shareholders, and navigate challenging economic conditions.';

  @override
  String get metricInfoEfficiencySection2Header =>
      'Why is Profitability important?';

  @override
  String get metricInfoEfficiencySection2Body =>
      'Revenue alone does not tell the full story.\n\nA company may generate billions of dollars in sales but keep only a small portion as profit.\n\nAnother company may generate lower revenue but operate much more efficiently, producing stronger and more consistent earnings.\n\nProfitability helps investors understand the quality of a company\'s business model.';

  @override
  String get metricInfoEfficiencySection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoEfficiencySection3Body =>
      'A high Profitability score suggests that the company consistently converts a meaningful portion of its revenue into profit.\n\nCompanies with strong profitability are often better positioned to:\n\n• Invest in future growth\n• Expand their operations\n• Pay dividends\n• Repurchase shares\n• Build financial reserves\n• Withstand economic downturns\n\nConsistently profitable businesses often demonstrate efficient management and strong competitive advantages.';

  @override
  String get metricInfoEfficiencySection4Header =>
      'What does a low score mean?';

  @override
  String get metricInfoEfficiencySection4Body =>
      'A low Profitability score may indicate that the company is struggling to generate healthy profits.\n\nPossible reasons include:\n\n• Rising operating costs\n• Intense competition\n• Weak pricing power\n• Declining demand\n• Poor cost management\n• Temporary business challenges\n\nLower profitability may reduce a company\'s ability to grow or respond to unexpected financial pressures.';

  @override
  String get metricInfoEfficiencySection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoEfficiencySection5Body =>
      'Some businesses naturally operate with lower profit margins.\n\nExamples include:\n\n• Supermarkets\n• Airlines\n• Wholesale distributors\n• Large retail chains\n\nThese industries often rely on very high sales volumes rather than large profits on each sale.\n\nA lower profitability score should always be evaluated within the context of the company\'s industry.';

  @override
  String get metricInfoEfficiencySection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoEfficiencySection6Body =>
      'Strong profitability today does not guarantee strong profitability tomorrow.\n\nChanging market conditions, increased competition, higher costs, or economic slowdowns can all reduce future earnings.\n\nInvestors should look for companies that have demonstrated consistent profitability over many years, rather than relying on a single strong reporting period.';

  @override
  String get metricInfoEfficiencySection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoEfficiencySection7Body =>
      'Profitability is one of the strongest indicators of business quality, but it should never be viewed in isolation.\n\nA complete evaluation should also consider:\n\n• Financial Health\n• Growth Potential\n• Valuation\n• Operational Efficiency\n\nLooking at these factors together provides a much clearer understanding of a company\'s long-term prospects.';

  @override
  String get metricInfoEfficiencySection8Header => 'Key Takeaway';

  @override
  String get metricInfoEfficiencySection8Body =>
      'Profitability measures how efficiently a company converts revenue into profit. Businesses with strong and consistent profitability are often better equipped to grow, invest, and withstand economic challenges, but profitability should always be evaluated alongside other aspects of financial performance.';

  @override
  String get metricInfoHistoricalTrendTitle => 'Historical Trend';

  @override
  String get metricInfoHistoricalTrendSubtitle =>
      'How the Market Has Rewarded the Company Over Time';

  @override
  String get metricInfoHistoricalTrendSection1Header =>
      'What is Market Confidence?';

  @override
  String get metricInfoHistoricalTrendSection1Body =>
      'Market Confidence reflects how investors currently perceive a company based on its overall performance, stability, and future prospects.\n\nIn simple terms: it helps determine whether the market has confidence in the company\'s future or is becoming more cautious.\n\nInvestor confidence can strongly influence a stock\'s price, especially over the short and medium term.';

  @override
  String get metricInfoHistoricalTrendSection2Header =>
      'Why is Market Confidence important?';

  @override
  String get metricInfoHistoricalTrendSection2Body =>
      'The stock market is driven by both facts and expectations.\n\nA company may report excellent financial results, but if investors expect even better performance, the stock price can still fall.\n\nLikewise, a company with average results may see its stock rise if investors believe its future is improving.\n\nMarket Confidence helps investors understand how the market is currently viewing the business.';

  @override
  String get metricInfoHistoricalTrendSection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoHistoricalTrendSection3Body =>
      'A high Market Confidence score suggests that investors generally have a positive view of the company\'s future.\n\nCompanies with strong market confidence often benefit from:\n\n• Positive investor sentiment\n• Stable long-term expectations\n• Strong reputation\n• Confidence in management\n• Optimism about future growth\n\nHigher confidence can make it easier for a company to raise capital and attract long-term investors.';

  @override
  String get metricInfoHistoricalTrendSection4Header =>
      'What does a low score mean?';

  @override
  String get metricInfoHistoricalTrendSection4Body =>
      'A low Market Confidence score may indicate that investors are becoming more cautious.\n\nPossible reasons include:\n\n• Slowing business growth\n• Weak financial results\n• Increased competition\n• Industry uncertainty\n• Economic concerns\n• Company-specific challenges\n\nLower confidence does not necessarily mean the company is performing poorly, but it often signals increased uncertainty.';

  @override
  String get metricInfoHistoricalTrendSection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoHistoricalTrendSection5Body =>
      'Investor sentiment can change quickly.\n\nSometimes the market reacts emotionally to short-term news, temporary setbacks, or broader economic conditions.\n\nStrong companies occasionally experience periods of lower confidence before recovering as business conditions improve.\n\nFor long-term investors, temporary pessimism may even create attractive opportunities.';

  @override
  String get metricInfoHistoricalTrendSection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoHistoricalTrendSection6Body =>
      'High investor confidence can sometimes become excessive.\n\nWhen expectations become unrealistically optimistic, stock prices may rise much faster than the underlying business.\n\nIf future results fail to meet those expectations, investor confidence can decline rapidly, leading to increased price volatility.\n\nConfidence should always be supported by strong business fundamentals.';

  @override
  String get metricInfoHistoricalTrendSection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoHistoricalTrendSection7Body =>
      'Market Confidence reflects how investors currently feel about a company, but market sentiment can change much faster than the business itself.\n\nFor a balanced investment decision, Market Confidence should always be considered together with:\n\n• Valuation\n• Financial Health\n• Growth Potential\n• Profitability\n• Operational Efficiency\n\nStrong companies are built on solid fundamentals—not on market optimism alone.';

  @override
  String get metricInfoHistoricalTrendSection8Header => 'Key Takeaway';

  @override
  String get metricInfoHistoricalTrendSection8Body =>
      'Market Confidence reflects how investors currently view a company\'s future. Positive sentiment can support stock performance, while declining confidence may increase uncertainty. However, investor sentiment should always be evaluated alongside the company\'s underlying financial strength and long-term business quality.';

  @override
  String get metricInfoCapitalReturnTitle => 'Shareholder Returns';

  @override
  String get metricInfoCapitalReturnSubtitle => 'Dividends and Share Buybacks';

  @override
  String get metricInfoCapitalReturnSection1Header =>
      'What are Shareholder Returns?';

  @override
  String get metricInfoCapitalReturnSection1Body =>
      'Shareholder Returns evaluate how a company rewards its shareholders by returning value through dividends and share buybacks.\n\nIn simple terms: it helps determine how effectively a company shares its financial success with investors.\n\nSome companies reward shareholders by paying regular dividends, while others choose to repurchase their own shares. Many successful businesses use both approaches.';

  @override
  String get metricInfoCapitalReturnSection2Header =>
      'Why are Shareholder Returns important?';

  @override
  String get metricInfoCapitalReturnSection2Body =>
      'When a company generates profits, management must decide how to use that money.\n\nCommon options include:\n\n• Investing in future growth\n• Reducing debt\n• Building cash reserves\n• Paying dividends\n• Repurchasing company shares\n\nReturning capital to shareholders can demonstrate financial strength and confidence in the company\'s future.';

  @override
  String get metricInfoCapitalReturnSection3Header =>
      'What does a high score mean?';

  @override
  String get metricInfoCapitalReturnSection3Body =>
      'A high Shareholder Returns score suggests that the company has a consistent and shareholder-friendly approach to returning value.\n\nThis may include:\n\n• Reliable dividend payments\n• Sustainable dividend growth\n• Thoughtful share repurchase programs\n• A balanced capital allocation strategy\n\nCompanies with strong shareholder return policies often focus on creating long-term value rather than short-term results.';

  @override
  String get metricInfoCapitalReturnSection4Header =>
      'What does a low score mean?';

  @override
  String get metricInfoCapitalReturnSection4Body =>
      'A low Shareholder Returns score does not necessarily indicate poor business quality.\n\nPossible reasons include:\n\n• Reinvesting profits into future growth\n• Expanding operations\n• Developing new products\n• Acquiring other businesses\n• Strengthening the balance sheet\n\nMany successful companies choose to reinvest their earnings instead of returning cash directly to shareholders.';

  @override
  String get metricInfoCapitalReturnSection5Header =>
      'Why isn\'t a low score always bad?';

  @override
  String get metricInfoCapitalReturnSection5Body =>
      'Fast-growing companies often generate better long-term returns by investing in their own business rather than paying dividends or buying back shares.\n\nIf those investments produce higher future earnings, shareholders may benefit through long-term stock price appreciation instead of immediate cash distributions.\n\nGrowth-focused companies frequently follow this strategy during their expansion years.';

  @override
  String get metricInfoCapitalReturnSection6Header =>
      'Why isn\'t a high score always a guarantee?';

  @override
  String get metricInfoCapitalReturnSection6Body =>
      'Returning cash to shareholders is generally positive—but only when it is financially sustainable.\n\nFor example:\n\n• A company may pay an unusually high dividend that cannot be maintained.\n• A business may repurchase shares while taking on excessive debt.\n\nCapital returned to shareholders should never weaken the company\'s long-term financial stability.\n\nHealthy shareholder returns should be supported by strong earnings, cash flow, and a solid financial position.';

  @override
  String get metricInfoCapitalReturnSection7Header =>
      'What should investors pay attention to?';

  @override
  String get metricInfoCapitalReturnSection7Body =>
      'Shareholder Returns should be viewed as part of the company\'s overall capital allocation strategy.\n\nA company that balances:\n\n• Business investment\n• Financial stability\n• Sustainable dividends\n• Responsible share buybacks\n\nis often creating greater long-term value for its shareholders.\n\nThere is no single \"best\" approach. The right strategy depends on the company\'s stage of growth, industry, and long-term objectives.';

  @override
  String get metricInfoCapitalReturnSection8Header => 'Key Takeaway';

  @override
  String get metricInfoCapitalReturnSection8Body =>
      'Shareholder Returns measure how a company rewards investors through dividends and share buybacks. Strong shareholder returns often reflect disciplined financial management, but they should always be supported by healthy earnings, sustainable cash flow, and a solid financial foundation.';

  @override
  String get metricInfoFsScoreLegalTitle => 'Legal Disclaimer';

  @override
  String get metricInfoFsScoreLegalSubtitle =>
      'Financial Scoring & Market Data';

  @override
  String get metricInfoFsScoreLegalSection1Body =>
      'The financial evaluation metrics (including FS Score) displayed in this application are calculated automatically using mathematical algorithms applied to publicly accessible market data and corporate financial disclosures (such as 10-K, 10-Q SEC filings).\n\nThese scores are strictly analytical outputs intended for educational and market research simulation. They do not constitute investment advice, financial recommendations, credit ratings, or endorsements of any security or entity.\n\nNeither the app nor its developers warrant the accuracy, completeness, or timeliness of the underlying data or calculated metrics. Users assume full responsibility for any trading or investment decisions made independently outside of this educational simulator.';

  @override
  String get metricInfoPortfolioHealthTitle => 'Portfolio Health';

  @override
  String get metricInfoPortfolioHealthSubtitle =>
      'Overall Portfolio Quality Assessment';

  @override
  String get metricInfoPortfolioHealthSection1Body =>
      'Portfolio Health provides an overall assessment of your portfolio\'s structure and investment quality. Instead of reviewing many separate statistics, this widget combines several important indicators into a single summary that helps you understand whether your portfolio follows healthy investing principles.\n\nA strong portfolio is not determined only by profit or loss. Even a portfolio that is currently making money can contain hidden weaknesses, such as too much money invested in one company or too many investments concentrated in a single industry. These risks may not be obvious during a rising market, but they can become much more noticeable when market conditions change.\n\nThe Portfolio Health widget analyzes different aspects of your portfolio, including diversification, concentration, sector balance, and overall stability. Each indicator contributes to the final picture and helps identify areas that may need improvement.\n\nA higher score generally means your investments are spread more effectively, reducing unnecessary risk and making your portfolio more resilient to unexpected market events. A lower score does not necessarily mean your portfolio is bad, but it may suggest that some adjustments could improve its balance and reduce exposure to avoidable risks.\n\nThis widget is designed to help investors focus on building a healthier portfolio over time rather than reacting to short-term market movements.';

  @override
  String get metricInfoAssetAllocationPctTitle => 'Asset Allocation %';

  @override
  String get metricInfoAssetAllocationPctSubtitle =>
      'How Your Capital Is Distributed';

  @override
  String get metricInfoAssetAllocationPctSection1Body =>
      'Asset Allocation shows exactly how your investment capital is distributed among the individual companies you own.\n\nEvery percentage displayed represents the portion of your total portfolio invested in a specific company. As stock prices change over time, these percentages also change automatically. A company that performs very well may gradually become a much larger part of your portfolio, even if you never purchase additional shares.\n\nMonitoring asset allocation is important because excessive concentration can increase risk. If one company represents a large percentage of your investments, the success or failure of that single business will have a much greater influence on your overall portfolio.\n\nA balanced allocation helps reduce dependence on any individual company. While there is no perfect distribution that fits every investor, avoiding extremely large positions can help create a more stable investment portfolio over the long term.\n\nThis widget allows you to quickly identify your largest holdings, monitor how your portfolio evolves, and decide whether your allocation still matches your investment goals.';

  @override
  String get metricInfoDiversificationIndicatorTitle =>
      'Diversification Indicator';

  @override
  String get metricInfoDiversificationIndicatorSubtitle =>
      'Sector Balance Across Your Holdings';

  @override
  String get metricInfoDiversificationIndicatorSection1Body =>
      'Diversification Indicator measures how your investments are distributed across different sectors of the economy.\n\nEvery company belongs to a particular industry or business sector, such as Technology, Healthcare, Financial Services, Consumer Goods, Energy, Industrials, Utilities, or Real Estate. Different sectors often perform differently depending on economic conditions, interest rates, consumer demand, or global events.\n\nIf most of your money is invested in only one sector, your portfolio becomes more vulnerable to problems affecting that industry. For example, a decline in technology companies may have a significant impact if your portfolio consists mainly of technology stocks.\n\nA portfolio spread across multiple sectors can reduce this type of risk because different industries may perform differently during the same period. While one sector struggles, another may remain stable or continue growing.\n\nThis widget helps you understand which sectors make up your portfolio, identify areas that may be overrepresented, and discover sectors that are currently missing. Building sector diversification gradually can improve the overall balance of your investments without requiring you to own a very large number of companies.';

  @override
  String get metricInfoDiversificationProgressTitle =>
      'Diversification Progress';

  @override
  String get metricInfoDiversificationProgressSubtitle =>
      'Building a Broader Portfolio Over Time';

  @override
  String get metricInfoDiversificationProgressSection1Body =>
      'Diversification Progress tracks how your portfolio grows by measuring the number of different companies you own.\n\nFor many long-term investors, diversification is built gradually over months or even years. Every new investment has the potential to increase the variety of businesses represented in the portfolio and reduce dependence on any single company.\n\nOwning only a few companies means that each investment has a greater influence on your portfolio\'s performance. As the number of holdings increases, the impact of one company\'s poor performance usually becomes smaller, creating a more balanced investment structure.\n\nHowever, diversification is not simply about buying as many companies as possible. A portfolio with many businesses from the same industry may still be poorly diversified. True diversification combines both the number of companies and the variety of sectors they represent.\n\nThis widget allows you to monitor your progress toward building a broader portfolio. Watching this number grow over time can encourage disciplined investing and remind you that diversification is a gradual process rather than something achieved in a single day.\n\nAs your portfolio expands, this widget provides a simple visual indication of how far you have progressed on your long-term diversification journey.';

  @override
  String get metricInfoPsychologyDisciplineTitle => 'Discipline';

  @override
  String get metricInfoPsychologyDisciplineSubtitle =>
      'Buying With a Plan, Not With Emotion';

  @override
  String get metricInfoPsychologyDisciplineSection1Header =>
      'What Is Investment Discipline?';

  @override
  String get metricInfoPsychologyDisciplineSection1Body =>
      'Investment discipline is the ability to make decisions based on a strategy rather than emotions.\n\nThe market constantly creates situations that test investors:\n\nWhen prices rise quickly — excitement appears and the fear of missing out begins.\n\nWhen markets fall — fear appears and investors often hesitate or panic.\n\nMany investment mistakes do not happen because people lack investing knowledge.\n\nThey happen because emotions push investors to change their decisions at the worst possible moments.\n\nDiscipline helps investors stay committed to their strategy regardless of what is happening around them.';

  @override
  String get metricInfoPsychologyDisciplineSection2Header => 'A Simple Example';

  @override
  String get metricInfoPsychologyDisciplineSection2Body =>
      'Imagine two investors.\n\nThey both have the same amount of money and access to the same information.';

  @override
  String get metricInfoPsychologyDisciplineSection3Header => 'Investor A';

  @override
  String get metricInfoPsychologyDisciplineSection3Body =>
      'The market is rising quickly.\n\nThe news is full of stories about one popular company.\n\nEveryone is talking about its future potential.\n\nThe investor buys because they are afraid of missing the opportunity.\n\nA few months later, the market changes.\n\nThe stock price falls.\n\nThe investor sells because fear takes over.\n\nTheir decisions are controlled by emotions.';

  @override
  String get metricInfoPsychologyDisciplineSection4Header => 'Investor B';

  @override
  String get metricInfoPsychologyDisciplineSection4Body =>
      'Before buying, they ask important questions:\n\nWhy am I buying this company?\nHas the real value of the business changed?\nDoes this purchase fit my investment strategy?\n\nWhen the market rises, they don\'t buy simply because everyone is excited.\n\nWhen the market falls, they look for opportunities.\n\nTheir decisions are based on a process, not market emotions.';

  @override
  String get metricInfoPsychologyDisciplineSection5Header =>
      'What Does This Widget Track?';

  @override
  String get metricInfoPsychologyDisciplineSection5Body =>
      'This widget analyzes your buying history and evaluates how closely your actions follow the principles of disciplined investing.\n\nIt does not only look at the outcome of your investments.\n\nIt looks at the conditions and environment in which your decisions were made.';

  @override
  String get metricInfoPsychologyDisciplineSection6Header =>
      'Buying During Market Fear';

  @override
  String get metricInfoPsychologyDisciplineSection6Body =>
      'Buying during:\n\nmarket declines;\nfinancial crises;\nperiods of extreme uncertainty;\n\ncan demonstrate the ability to act when many investors are afraid.';

  @override
  String get metricInfoPsychologyDisciplineSection7Header =>
      'Buying During Market Excitement';

  @override
  String get metricInfoPsychologyDisciplineSection7Body =>
      'Buying during:\n\nmarket hype;\nrapid price increases;\nmassive attention around a specific theme;\n\ncan indicate an emotional decision and the desire to avoid missing out.';

  @override
  String get metricInfoPsychologyDisciplineSection8Header =>
      'Risk Control During Opportunities';

  @override
  String get metricInfoPsychologyDisciplineSection8Body =>
      'Even a good investment idea requires good execution.\n\nA strong investor does not only recognize opportunities.\n\nThey also manage position sizes and maintain flexibility.\n\nFor example, buying during a market decline while keeping a cash reserve shows a more controlled and thoughtful approach.';

  @override
  String get metricInfoPsychologyDisciplineSection9Header =>
      'What Does This Widget Teach?';

  @override
  String get metricInfoPsychologyDisciplineSection9Body =>
      'This widget teaches one of the most important skills of a long-term investor:\n\nManaging not only your portfolio, but also your own behavior.\n\nBecause the market cannot be controlled.\n\nYou cannot control:\n\nnews;\nthe economy;\nprice movements;\nthe emotions of other investors.\n\nBut you can control:\n\nyour decisions;\nyour strategy;\nyour reaction to events.';

  @override
  String get metricInfoPsychologyDisciplineSection10Header => 'The Main Idea';

  @override
  String get metricInfoPsychologyDisciplineSection10Body =>
      'A successful investor is not someone who never makes mistakes.\n\nEveryone makes mistakes.\n\nA successful investor is someone who can continue making rational decisions even when the market creates maximum pressure.\n\nYour strategy shows what you buy.\n\nYour discipline shows why you buy it.';

  @override
  String get metricInfoPsychologyPanicTitle => 'Panic';

  @override
  String get metricInfoPsychologyPanicSubtitle =>
      'Selling Calmly, Not Selling Scared';

  @override
  String get metricInfoPsychologyPanicSection1Header =>
      'What Is Panic in Investing?';

  @override
  String get metricInfoPsychologyPanicSection1Body =>
      'Panic in investing is not simply feeling fear.\n\nFear is a natural reaction when money is involved.\n\nEvery investor experiences uncertainty when prices fall.\n\nThe problem begins when fear starts controlling decisions.\n\nA falling stock price does not automatically mean a bad investment.\n\nSometimes a declining price means:\n\nthe entire market is under pressure;\ninvestors are temporarily afraid;\na good company is becoming cheaper.\n\nBut during stressful periods, many investors make decisions based on emotions instead of analysis.\n\nThey sell because the situation feels uncomfortable.\n\nThey sell because they want to stop the pain.\n\nThey sell because they believe the decline will continue forever.\n\nThis is one of the most common mistakes in investing.';

  @override
  String get metricInfoPsychologyPanicSection2Header => 'A Simple Example';

  @override
  String get metricInfoPsychologyPanicSection2Body =>
      'Imagine an investor buys shares of a strong company.\n\nThe business is growing.\n\nThe financial results are healthy.\n\nThe long-term idea remains unchanged.\n\nBut then the market enters a difficult period.\n\nThe stock price falls:\n\n-20%.\n\nThen:\n\n-35%.\n\nNegative headlines appear everywhere.\n\nMany investors become afraid.';

  @override
  String get metricInfoPsychologyPanicSection3Header => 'Investor A';

  @override
  String get metricInfoPsychologyPanicSection3Body =>
      'The falling price creates stress.\n\nThey think:\n\n\"I cannot handle this loss anymore.\"\n\nThey sell near the worst moment.\n\nA few months later, the market begins recovering.\n\nThe problem was not only the price decline.\n\nThe problem was making a decision at the moment when emotions were strongest.';

  @override
  String get metricInfoPsychologyPanicSection4Header => 'Investor B';

  @override
  String get metricInfoPsychologyPanicSection4Body =>
      'They review the original investment idea.\n\nThey ask:\n\nDid the company become weaker?\nDid the business model change?\nIs this a temporary market reaction?\n\nIf the investment reason is still valid, they remain patient.\n\nThey understand that volatility is part of investing.';

  @override
  String get metricInfoPsychologyPanicSection5Header =>
      'What Does This Widget Track?';

  @override
  String get metricInfoPsychologyPanicSection5Body =>
      'This widget analyzes your selling behavior and evaluates how you react during difficult market situations.\n\nIt does not judge every losing sale as a mistake.\n\nSelling at a loss can sometimes be the correct decision.\n\nA smart investor may sell because:\n\nthe business fundamentals changed;\nthe original investment idea is no longer valid;\na better opportunity appeared.\n\nThe important question is:\n\nWhy did you sell?';

  @override
  String get metricInfoPsychologyPanicSection6Header => 'Selling During Fear';

  @override
  String get metricInfoPsychologyPanicSection6Body =>
      'The system looks at whether sales happened during periods of extreme market pressure.\n\nSelling close to major declines can indicate an emotional reaction, especially if the investment later recovers.';

  @override
  String get metricInfoPsychologyPanicSection7Header =>
      'Ability to Accept Volatility';

  @override
  String get metricInfoPsychologyPanicSection7Body =>
      'Successful investors understand that price movement is normal.\n\nStrong companies can experience temporary declines.\n\nThis widget helps measure whether you can separate temporary market noise from real problems with an investment.';

  @override
  String get metricInfoPsychologyPanicSection8Header =>
      'Surviving Extreme Market Events';

  @override
  String get metricInfoPsychologyPanicSection8Body =>
      'The strongest test of an investor often comes during crises.\n\nMarket crashes create:\n\nuncertainty;\nfear;\npressure to act.\n\nInvestors who can survive these periods without emotional decisions demonstrate one of the most valuable skills in investing:\n\npatience.';

  @override
  String get metricInfoPsychologyPanicSection9Header =>
      'What Does This Widget Teach?';

  @override
  String get metricInfoPsychologyPanicSection9Body =>
      'This widget teaches that investing is not only about choosing the right assets.\n\nIt is also about controlling your reactions when things do not go according to plan.\n\nYou cannot control:\n\nmarket crashes;\nnegative news;\ntemporary price declines.\n\nBut you can control:\n\nyour decisions;\nyour preparation;\nyour response to uncertainty.';

  @override
  String get metricInfoPsychologyPanicSection10Header => 'The Main Idea';

  @override
  String get metricInfoPsychologyPanicSection10Body =>
      'A great investor is not someone who never experiences fear.\n\nEveryone feels fear.\n\nThe difference is what happens next.\n\nSome investors allow fear to make decisions for them.\n\nOthers use patience, analysis, and a clear strategy.\n\nYour portfolio shows what you own.\n\nYour Discipline shows how you buy.\n\nYour Panic score shows how you behave when the market tests you.';

  @override
  String get metricInfoPsychologyPatienceTitle => 'Patience';

  @override
  String get metricInfoPsychologyPatienceSubtitle =>
      'Letting Positions Play Out';

  @override
  String get metricInfoPsychologyPatienceSection1Header =>
      'What Is Investment Patience?';

  @override
  String get metricInfoPsychologyPatienceSection1Body =>
      'Investment patience is the ability to stay focused on a long-term plan without making unnecessary decisions because of short-term market movements.\n\nMany investors believe that successful investing is about finding the perfect moment to buy or sell.\n\nBut in reality, one of the biggest advantages an investor has is time.\n\nThe market constantly creates situations that test patience:\n\nprices move up and down;\nunexpected news appears;\nother investors become excited or afraid;\ngood companies sometimes experience difficult periods.\n\nDuring these moments, investors often feel pressure to act.\n\nThey want to change something.\n\nThey want to fix the situation.\n\nBut sometimes the best decision is not making a decision at all.';

  @override
  String get metricInfoPsychologyPatienceSection2Header => 'A Simple Example';

  @override
  String get metricInfoPsychologyPatienceSection2Body =>
      'Imagine two investors who bought shares of the same strong company.\n\nThe business continues growing.\n\nThe financial results remain healthy.\n\nBut the market enters a difficult period and the stock price declines.';

  @override
  String get metricInfoPsychologyPatienceSection3Header => 'Investor A';

  @override
  String get metricInfoPsychologyPatienceSection3Body =>
      'The falling price creates stress.\n\nThey think:\n\n\"Maybe I made a mistake. I should do something.\"\n\nThey sell because the situation feels uncomfortable.\n\nLater, the company recovers.\n\nThe problem was not the temporary decline.\n\nThe problem was not allowing the original investment idea enough time.';

  @override
  String get metricInfoPsychologyPatienceSection4Header => 'Investor B';

  @override
  String get metricInfoPsychologyPatienceSection4Body =>
      'They review the situation.\n\nThey ask:\n\nDid the business become weaker?\nHas the original reason for investing changed?\nIs this a company problem or only market fear?\n\nIf the investment idea remains valid, they stay patient.\n\nThey understand that short-term volatility is a normal part of long-term investing.';

  @override
  String get metricInfoPsychologyPatienceSection5Header =>
      'What Does This Widget Track?';

  @override
  String get metricInfoPsychologyPatienceSection5Body =>
      'This widget analyzes your investing behavior and measures your ability to remain patient during different market situations.\n\nIt does not simply measure how long you hold an investment.\n\nHolding a bad company for many years is not patience.\n\nTrue patience means:\n\nGiving good decisions enough time to work while staying ready to react when the facts truly change.';

  @override
  String get metricInfoPsychologyPatienceSection6Header =>
      'Ability to Avoid Unnecessary Actions';

  @override
  String get metricInfoPsychologyPatienceSection6Body =>
      'The market creates constant movement.\n\nEvery price change can create an emotional reaction.\n\nThis widget evaluates whether your decisions are based on:\n\nnew information;\nchanges in business quality;\na clear investment reason;\nor simply on temporary market pressure.';

  @override
  String get metricInfoPsychologyPatienceSection7Header =>
      'Ability to Stay Calm During Crisis';

  @override
  String get metricInfoPsychologyPatienceSection7Body =>
      'The strongest test of patience appears during extreme events.\n\nMarket crashes create:\n\nfear;\nuncertainty;\npressure to sell.\n\nMany investors make their biggest mistakes during these moments because they focus only on the current situation.\n\nA patient investor understands that difficult periods are part of investing.';

  @override
  String get metricInfoPsychologyPatienceSection8Header =>
      'Taking Profit Without Greed';

  @override
  String get metricInfoPsychologyPatienceSection8Body =>
      'Patience is not only about holding.\n\nIt is also about knowing when enough is enough.\n\nA disciplined investor can accept a successful result without waiting forever for a perfect exit.\n\nMarkets rarely provide perfect timing.';

  @override
  String get metricInfoPsychologyPatienceSection9Header =>
      'What Does This Widget Teach?';

  @override
  String get metricInfoPsychologyPatienceSection9Body =>
      'This widget teaches one of the most important lessons in investing:\n\nTime is one of the greatest advantages an investor can have.\n\nYou cannot control:\n\ndaily price movements;\nmarket emotions;\neconomic events.\n\nBut you can control:\n\nyour reactions;\nyour decision process;\nyour ability to stay focused.';

  @override
  String get metricInfoPsychologyPatienceSection10Header => 'The Main Idea';

  @override
  String get metricInfoPsychologyPatienceSection10Body =>
      'Patience does not mean ignoring problems.\n\nIt does not mean holding every investment forever.\n\nIt means understanding the difference between temporary market noise and real changes that require action.\n\nThe best investors are not those who make the most decisions.\n\nThey are those who make the right decisions and give them enough time to work.\n\nYour Discipline shows how you enter the market.\n\nYour Panic score shows how you react under pressure.\n\nYour Patience score shows whether you can let time become your advantage.';

  @override
  String get metricInfoPsychologyStrategyTitle => 'Strategy';

  @override
  String get metricInfoPsychologyStrategySubtitle =>
      'How Your Portfolio Is Built';

  @override
  String get metricInfoPsychologyStrategySection1Header =>
      'What Is an Investment Strategy?';

  @override
  String get metricInfoPsychologyStrategySection1Body =>
      'An investment strategy is not just a list of companies you own.\n\nIt is a system of rules that guides your decisions.\n\nA strong strategy answers questions like:\n\nWhat am I buying?\nWhy am I buying it?\nHow do I manage risk?\nWhat will I do during a market decline?\nHow will I react when new opportunities appear?';

  @override
  String get metricInfoPsychologyStrategySection2Header => 'A Simple Example';

  @override
  String get metricInfoPsychologyStrategySection2Body =>
      'Two investors can own the same stocks.\n\nBut their strategies can be completely different.';

  @override
  String get metricInfoPsychologyStrategySection3Header => 'Investor A';

  @override
  String get metricInfoPsychologyStrategySection3Body =>
      'Buys companies because their prices are rising.\n\nFollows every headline.\n\nBuys after strong price increases because of fear of missing out.\n\nSells during market declines because of panic.\n\nThey own investments, but they don\'t have a system.';

  @override
  String get metricInfoPsychologyStrategySection4Header => 'Investor B';

  @override
  String get metricInfoPsychologyStrategySection4Body =>
      'Buys strong businesses.\n\nManages position sizes.\n\nKeeps a cash reserve.\n\nUses ETFs for additional diversification.\n\nHas a plan for different market situations.\n\nThey don\'t simply own stocks.\n\nThey have a strategy.';

  @override
  String get metricInfoPsychologyStrategySection5Header =>
      'What Does This Widget Track?';

  @override
  String get metricInfoPsychologyStrategySection5Body =>
      'This widget analyzes whether your investing approach follows the principles of long-term portfolio management.\n\nIt evaluates:';

  @override
  String get metricInfoPsychologyStrategySection6Header =>
      'Quality of Your Investments';

  @override
  String get metricInfoPsychologyStrategySection6Body =>
      'Are you investing in strong businesses with sustainable models?\n\nOr are you taking excessive risks hoping for quick returns?';

  @override
  String get metricInfoPsychologyStrategySection7Header =>
      'Balance Between Growth and Protection';

  @override
  String get metricInfoPsychologyStrategySection7Body =>
      'A portfolio should not only perform well during good markets.\n\nIt should also have the ability to survive difficult periods.';

  @override
  String get metricInfoPsychologyStrategySection8Header =>
      'Preparation for Opportunities';

  @override
  String get metricInfoPsychologyStrategySection8Body =>
      'Investors without a plan often make emotional decisions.\n\nInvestors with a strategy understand:\n\nwhen to wait;\nwhen to invest;\nwhen to review their decisions.';

  @override
  String get metricInfoPsychologyStrategySection9Header => 'The Main Idea';

  @override
  String get metricInfoPsychologyStrategySection9Body =>
      'Successful investing is not about finding one perfect stock.\n\nIt is about building a system that helps you make reasonable decisions again and again.\n\nYou cannot control the market.\n\nBut you can control your actions.';

  @override
  String get metricInfoInvestorScoreTitle => 'Psychology & Strategy Scores';

  @override
  String get metricInfoInvestorScoreSubtitle =>
      'Two Sides of Your Investment Behavior';

  @override
  String get metricInfoInvestorScoreSection1Header =>
      'What Do These Widgets Show?';

  @override
  String get metricInfoInvestorScoreSection1Body =>
      'Your investment behavior is evaluated as two separate scores, not one blended number.\n\nThey do not measure:\n\nhow much money you made;\nhow fast your portfolio grew;\nwhether you will make a profit in the future.\n\nInstead, each answers its own question:\n\n\"Psychology Score\" — how closely does your behavior during the test match the habits of a disciplined investor?\n\n\"Strategy Score\" — how well is your portfolio actually built, independent of how you behaved while building it?';

  @override
  String get metricInfoInvestorScoreSection2Header =>
      'Why Two Scores Instead of One?';

  @override
  String get metricInfoInvestorScoreSection2Body =>
      'A trader can behave perfectly — no panic selling, no chasing headlines, plenty of patience — while still holding a badly built portfolio: everything in one stock, no cash reserve, no ETFs. The opposite is also possible: a well-diversified portfolio assembled through impulsive, emotional trades.\n\nBlending both into a single number let one side hide problems on the other. Keeping them separate means each score tells you something you can actually act on.';

  @override
  String get metricInfoInvestorScoreSection3Header =>
      '🧠 PSYCHOLOGY SCORE — Discipline, Panic, Patience';

  @override
  String get metricInfoInvestorScoreSection3Body =>
      'How you behaved during the test: whether you followed a plan, how you reacted to market drops, and whether you gave your decisions time to play out.';

  @override
  String get metricInfoInvestorScoreSection4Header =>
      '📊 STRATEGY SCORE — Concentration, ETF Exposure, Cash Buffer, Sector Balance, Diversification, Safety Marker';

  @override
  String get metricInfoInvestorScoreSection4Body =>
      'How your portfolio is actually built, right now — independent of the decisions that got it there.';

  @override
  String get metricInfoInvestorScoreSection5Header =>
      '🧩 Diversification — How Your Portfolio Is Built';

  @override
  String get metricInfoInvestorScoreSection5Body =>
      'This indicator evaluates:\n\nhow your investments are distributed;\nwhether your portfolio depends too heavily on one company or idea;\nhow well your portfolio is protected from a single mistake.\n\nA strong investor understands:\n\nOwning one great company can be a good decision.\n\nBut building an entire portfolio around one idea creates unnecessary risk.';

  @override
  String get metricInfoInvestorScoreSection6Header =>
      '🧩 Strategy — How You Manage Your Portfolio';

  @override
  String get metricInfoInvestorScoreSection6Body =>
      'This indicator evaluates:\n\nasset balance;\nETF exposure;\ncash reserves;\nrisk management.\n\nA strong strategy helps prevent situations like:\n\n\"I bought everything I liked, and now I don\'t know what to do next.\"\n\nA portfolio is not only about what you own.\n\nIt is also about how you prepare for different market situations.';

  @override
  String get metricInfoInvestorScoreSection7Header =>
      '🧩 Discipline — How You Make Investment Decisions';

  @override
  String get metricInfoInvestorScoreSection7Body =>
      'This indicator analyzes:\n\nwhether you buy during fear or excitement;\nwhether you follow your strategy;\nwhether your decisions are based on logic or emotions.\n\nOne of the most common investor mistakes is:\n\nBuying when everyone already feels confident.\n\nDiscipline helps investors search for opportunities instead of simply following the crowd.';

  @override
  String get metricInfoInvestorScoreSection8Header =>
      '🧩 Panic — How You React During Market Declines';

  @override
  String get metricInfoInvestorScoreSection8Body =>
      'This indicator shows:\n\nwhether you sell under pressure;\nhow you handle market downturns;\nwhether you can separate temporary declines from real problems.\n\nMarket declines are unavoidable.\n\nThe important question is not:\n\n\"Will the market fall?\"\n\nThe important question is:\n\n\"How will I react when it does?\"';

  @override
  String get metricInfoInvestorScoreSection9Header =>
      '🧩 Patience — Whether You Can Let Time Work';

  @override
  String get metricInfoInvestorScoreSection9Body =>
      'This indicator evaluates:\n\nyour ability to wait;\nwhether you avoid unnecessary decisions;\nwhether you can stay focused during difficult periods.\n\nSometimes the best investment decision is not making a decision.\n\nPatience allows good ideas enough time to develop.';

  @override
  String get metricInfoInvestorScoreSection10Header =>
      'How Should You Understand Your Scores?';

  @override
  String get metricInfoInvestorScoreSection10Body =>
      'The same 5 tiers apply to both scores independently — a 75 Psychology Score and a 75 Strategy Score mean the same thing about each side of your investing, they just don\'t have to match each other.\n\n🔴 0–20 — Beginner Investor\nYour investment process is currently strongly influenced by emotions and short-term reactions. The main goal is not finding perfect investments — the first step is building strong investment habits.\n\n🟠 21–40 — Developing Investor\nYou understand many basic investment concepts, but market situations may still influence some decisions. The next step: create clear rules and learn to follow them consistently.\n\n🟡 41–60 — Balanced Investor\nYou have built a solid foundation. You understand the importance of strategy and risk management. However, some market situations may still create pressure.\n\n🟢 61–80 — Disciplined Investor\nYour behavior shows strong investment habits. You are able to control emotions, evaluate risks, and make more thoughtful decisions.\n\n⭐ 81–100 — Experienced Investor Mindset\nYour actions demonstrate a high level of investment maturity. You understand the importance of long-term thinking, the power of discipline, and the need for risk control. However, a high score does not mean perfection — markets can always surprise investors. The greatest advantage is the ability to continue making rational decisions in changing conditions.';

  @override
  String get metricInfoInvestorScoreSection11Header =>
      'The Main Purpose of This Widget';

  @override
  String get metricInfoInvestorScoreSection11Body =>
      'These scores are not designed to tell you:\n\n\"You are a good investor.\"\n\nor\n\n\"You are a bad investor.\"\n\nTheir purpose is to show:\n\n\"Which investment habits are helping you, and which ones may limit your long-term progress.\"\n\nEvery investor can improve both scores.\n\nNot by trying to predict every market movement.\n\nBut by improving their own decision-making process.';

  @override
  String get metricInfoInvestorScoreSection12Header => 'Final Thought';

  @override
  String get metricInfoInvestorScoreSection12Body =>
      'The market cannot be controlled.\n\nYou cannot control:\n\nnews;\nprices;\neconomic cycles.\n\nBut you can control:\n\nyour strategy;\nyour decisions;\nyour discipline.\n\nYour portfolio shows what you own.\n\nYour Psychology Score shows how you\'re deciding. Your Strategy Score shows what you\'re building. Together, they show what kind of investor you are becoming.';

  @override
  String get metricInfoPsychologyDiversificationTitle => 'Diversification';

  @override
  String get metricInfoPsychologyDiversificationSubtitle =>
      'Spreading Risk Across Your Portfolio';

  @override
  String get metricInfoPsychologyDiversificationSection1Header =>
      'What Is Diversification?';

  @override
  String get metricInfoPsychologyDiversificationSection1Body =>
      'Diversification is a way to reduce portfolio risk by spreading your investments across different assets.\n\nIn simple words:\n\nDon\'t put all your eggs in one basket.\n\nIf one basket falls, you lose everything.\n\nBut if you have several baskets, a problem with one of them does not destroy the entire result.\n\nIn investing, this means:\n\nowning different companies;\ninvesting across different industries;\navoiding dependence on one single stock.';

  @override
  String get metricInfoPsychologyDiversificationSection2Header =>
      'A Simple Example';

  @override
  String get metricInfoPsychologyDiversificationSection2Body =>
      'Imagine an investor has \$15,000.\n\nScenario 1:\n\nThey invest everything into one company.\n\nIf that company performs well, the results can be excellent.\n\nBut if the business faces problems, the entire portfolio suffers together with it.\n\nOne disappointing report.\n\nOne management mistake.\n\nOne unexpected crisis.\n\nThe full impact falls on a single investment.\n\nScenario 2:\n\nThe same \$15,000 is distributed across different companies:\n\ntechnology;\nhealthcare;\nconsumer goods;\nfinancial services;\nindustrial companies.\n\nNow, problems in one industry do not necessarily damage the entire portfolio.\n\nSome companies may struggle while others continue to perform well.';

  @override
  String get metricInfoPsychologyDiversificationSection3Header =>
      'But Diversification Is Not Simply Buying Many Stocks';

  @override
  String get metricInfoPsychologyDiversificationSection3Body =>
      'Many beginner investors think:\n\n\"I own 20 companies, so my portfolio is safe.\"\n\nBut this is not always true.\n\nYou can own 20 different companies and still have a highly concentrated portfolio.\n\nFor example:\n\n20 companies from the artificial intelligence sector.\n\nTechnically, you own many businesses.\n\nBut if the AI industry experiences a major decline, your entire portfolio may fall at the same time.\n\nTrue diversification is not about quantity.\n\nIt is about balance.';

  @override
  String get metricInfoPsychologyDiversificationSection4Header =>
      'What Does This Widget Track?';

  @override
  String get metricInfoPsychologyDiversificationSection4Body =>
      'This widget analyzes how well your portfolio is distributed.\n\nIt looks at several important elements:';

  @override
  String get metricInfoPsychologyDiversificationSection5Header =>
      'Number of Companies';

  @override
  String get metricInfoPsychologyDiversificationSection5Body =>
      'Too few companies can make your portfolio dependent on only a few decisions.\n\nBut too many companies can turn your portfolio into a collection of random assets that become difficult to monitor.';

  @override
  String get metricInfoPsychologyDiversificationSection6Header =>
      'Sector Distribution';

  @override
  String get metricInfoPsychologyDiversificationSection6Body =>
      'Different industries react differently to economic conditions.\n\nWhen one sector experiences pressure, another may remain stronger.\n\nThat is why it is important not only to ask:\n\n\"How many companies do I own?\"\n\nBut also:\n\n\"What types of businesses and industries do these companies represent?\"';

  @override
  String get metricInfoPsychologyDiversificationSection7Header =>
      'Individual Position Concentration';

  @override
  String get metricInfoPsychologyDiversificationSection7Body =>
      'Even a strong portfolio can become risky if one company represents too much of your capital.\n\nYour favorite company may be an excellent business.\n\nBut even great companies can face unexpected challenges.';

  @override
  String get metricInfoPsychologyDiversificationSection8Header =>
      'The Main Idea';

  @override
  String get metricInfoPsychologyDiversificationSection8Body =>
      'Good diversification does not mean buying everything.\n\nIt means creating a portfolio where one mistake, one company, or one industry cannot destroy your entire investment journey.\n\nThe goal of diversification is not to remove all risk.\n\nThat is impossible.\n\nThe goal is to make risk manageable.';

  @override
  String get metricInfoGuardianVerdictTitle => 'GUARDIAN\'S VERDICT';

  @override
  String get metricInfoGuardianVerdictSubtitle =>
      'Congratulations — you have completed your portfolio stress test.';

  @override
  String get metricInfoGuardianVerdictSection1Header => 'Stress Test Complete';

  @override
  String get metricInfoGuardianVerdictSection1Body =>
      'During the simulation, you experienced different market periods and scenarios based on patterns observed throughout real market history. Events that can unfold over months or even years in the real world were accelerated in the simulation, allowing you to experience their effects in a much shorter period of time.\n\nYou saw how your portfolio could behave under very different conditions:\n\n📈 Market growth\n➖ Sideways markets and uncertainty\n📉 Market declines\n🔄 Recovery after a downturn\n🚀 Market hype\n🎲 Speculative movements\n⚠️ Crisis scenarios\n🦢 Rare extreme events and Black Swan scenarios\n\nEach of these market phases has its own characteristics.\n\nHype is not simply a rising price.\n\nSpeculation is not the same as long-term investing.\n\nA market decline does not automatically mean that a business is becoming weaker.\n\nAnd strong price growth does not automatically mean that an asset has become a better investment.\n\nDuring the test, you have already seen these patterns in action. Some of them you may have recognized immediately. Others may have passed unnoticed. That is why one test may not be enough.\n\nTry running different stress tests again. Change your portfolio and observe how your decisions and portfolio behavior change under different market conditions.\n\nOver time, you may become better at recognizing different market phases and understanding why the same action can have a very different meaning depending on the situation.';

  @override
  String get metricInfoGuardianVerdictSection2Header =>
      'One Important Thing to Remember';

  @override
  String get metricInfoGuardianVerdictSection2Body =>
      'Neither in the real world nor in our simulator can anyone know with certainty which direction the market will take tomorrow.\n\nNo one can reliably predict: when a period of growth will end; when a decline will begin; how deep a decline will become; when recovery will start; which sector will become the next leader; which unexpected event will change market sentiment.\n\nThat is why this test is not designed to teach you how to predict the market. It is designed to teach you something more useful: how to understand possible market scenarios and observe your own behavior when they occur.';

  @override
  String get metricInfoGuardianVerdictSection3Header => 'Train, Don\'t Predict';

  @override
  String get metricInfoGuardianVerdictSection3Body =>
      'Use the simulator as a training environment. Run different scenarios. Observe your decisions. Watch what happens to your portfolio as market conditions change.\n\nMost importantly, learn to recognize the classic mistakes investors have been studying for decades: chasing hype, FOMO, poor diversification, excessive concentration, panic selling, having no cash reserve, constantly trying to time the market, and making decisions based on emotions.\n\nAnd there is an important distinction: this is about investing, not trading. A trader and a long-term investor may look at the same market, but their goals, time horizons, and approaches to risk can be very different. Our simulator is not designed to teach you to constantly buy and sell. It is designed to help you understand long-term investment behavior and develop better decision-making habits.';

  @override
  String get metricInfoGuardianVerdictSection4Header =>
      'Now, Let\'s Look at Your Results';

  @override
  String get metricInfoGuardianVerdictSection4Body =>
      'Below, you will find a detailed analysis of your actions and your portfolio throughout the simulation. Each indicator is based on your actual decisions and the events that occurred during the test.\n\nThe system analyzes: which assets you selected; how diversified your portfolio was; when you bought; when you sold; how you behaved during market declines; how frequently you changed your positions; whether you demonstrated patience; how you managed risk and your cash reserve; how closely your behavior matched the principles of disciplined long-term investing.\n\nYour actions are processed through an objective algorithmic analysis that produces individual behavioral indicators and an overall investor profile.\n\nThis is not about simply telling you \"You did this right.\" or \"You did this wrong.\" Instead, the system shows: what happened, why it matters, and which investment skill you may want to develop further.\n\nYour result should therefore not be treated as a final judgment. It is not a prediction of your future financial results, and it is not a measure of you as a person. It is a snapshot of your behavior within this particular simulation.\n\nAnd if you don\'t like your result — that\'s actually a good thing. Because here, you have an opportunity that is much harder to get in real life: make mistakes in the simulator, study your decisions, try again, and gradually learn to recognize and avoid classic investment mistakes before they become real-world problems.';

  @override
  String get marketClockWindowEarlyPreMarketShortHeadline => 'Early Pre-Market';

  @override
  String get marketClockWindowEarlyPreMarketShortDetail =>
      'Low liquidity, risky spreads';

  @override
  String get marketClockWindowEarlyPreMarketFullTitle => 'Early Pre-Market';

  @override
  String get marketClockWindowEarlyPreMarketWhatHappens =>
      'This is the earliest stage of trading. The stock market hasn\'t officially opened yet, but electronic trading has already begun.\n\nAt this time, the market is mostly active with large investment funds, institutional traders, and companies reacting to overnight news.\n\nThere are very few regular investors trading, which makes the market feel quiet and almost empty.\n\nImagine walking into a supermarket an hour before it officially opens. Only a few people are inside, some shelves are still being stocked, and prices don\'t always reflect what they\'ll be later in the day.\n\nThat\'s exactly what the market is like during the Early Pre-Market.';

  @override
  String get marketClockWindowEarlyPreMarketWhyItMatters =>
      'The biggest issue during this session is low liquidity.\n\nThere simply aren\'t many buyers and sellers available.\n\nBecause of that, the difference between the buying price and the selling price (called the spread) can become surprisingly large.\n\nFor example, a stock may have closed yesterday at \$100, but the next available seller may only be willing to sell it for \$102.\n\nIf you place a Market Order, your broker may execute the trade at that much higher price.\n\nYou could lose money before the trading day has even begun.';

  @override
  String get marketClockWindowEarlyPreMarketDangerForBeginner =>
      'Prices can jump sharply after a single large trade because there aren\'t enough orders to keep prices stable.\n\nThis often creates dramatic moves on the chart that disappear once more traders join the market.\n\nMany beginners see a sudden spike and think:\n\n\"The stock is taking off! I have to buy right now!\"\n\nA few minutes later, the excitement fades and the price returns to where it started.';

  @override
  String get marketClockWindowEarlyPreMarketWhatToDo =>
      'If you\'re investing for the long term, the best decision is usually to wait.\n\nIf you absolutely need to buy or sell during this session, always use a Limit Order.\n\nA Limit Order lets you choose the maximum price you\'re willing to pay, protecting you from unexpected price jumps.';

  @override
  String get marketClockWindowEarlyPreMarketFomoShieldTip =>
      'If it feels like you\'re about to miss an incredible opportunity, you\'re probably looking at a low-liquidity move.\n\nDon\'t rush.\n\nOnce the regular market opens, prices often become much more stable.';

  @override
  String get marketClockWindowPreMarketReportsShortHeadline =>
      'Pre-Market & News';

  @override
  String get marketClockWindowPreMarketReportsShortDetail =>
      'High risk, earnings releases';

  @override
  String get marketClockWindowPreMarketReportsFullTitle => 'Pre-Market';

  @override
  String get marketClockWindowPreMarketReportsWhatHappens =>
      'The market is waking up.\n\nMore investors begin placing trades, banks analyze overnight developments, and traders prepare for the opening bell.\n\nThis is also when many companies release their quarterly earnings, while the U.S. government often publishes important economic reports such as inflation, employment, and GDP data.\n\nOne news release can move a stock by 10–20% before the market officially opens.';

  @override
  String get marketClockWindowPreMarketReportsWhyItMatters =>
      'This is the period when the market tries to answer one important question:\n\n\"Is today\'s news good or bad?\"\n\nThousands of investors read the same information but reach completely different conclusions.\n\nSome start buying.\n\nOthers begin selling.\n\nSome decide to lock in profits.\n\nAs a result, prices can change direction several times within just a few minutes.';

  @override
  String get marketClockWindowPreMarketReportsDangerForBeginner =>
      'This session is driven by emotions.\n\nA beginner may see a stock rising 12% before the opening bell and think:\n\n\"If I don\'t buy now, I\'ll miss the opportunity.\"\n\nTen minutes later, additional details appear...\n\nThe stock suddenly drops instead.\n\nSituations like this happen far more often than most beginners expect.';

  @override
  String get marketClockWindowPreMarketReportsWhatToDo =>
      'Use this time to prepare, not to react.\n\nCheck which companies are reporting earnings today.\n\nRead the news.\n\nReview your investment plan.\n\nBut don\'t try to predict where prices will move over the next five minutes.';

  @override
  String get marketClockWindowPreMarketReportsFomoShieldTip =>
      'Successful investors don\'t need to react first.\n\nMaking calm, informed decisions is almost always better than chasing fast-moving prices.';

  @override
  String get marketClockWindowOpeningBellShortHeadline => 'Opening Bell';

  @override
  String get marketClockWindowOpeningBellShortDetail =>
      'Peak volatility, opening chaos';

  @override
  String get marketClockWindowOpeningBellFullTitle => 'Opening Bell';

  @override
  String get marketClockWindowOpeningBellWhatHappens =>
      'The New York Stock Exchange officially opens.\n\nMillions of investors from around the world begin trading at the same time.\n\nOrders that were placed overnight and during Pre-Market are executed.\n\nBanks, pension funds, investment firms, trading algorithms, and individual investors all become active together.\n\nBillions of dollars change hands during the first hour of trading.';

  @override
  String get marketClockWindowOpeningBellWhyItMatters =>
      'This is usually the busiest hour of the entire trading day.\n\nPrices can move quickly in both directions.\n\nAt first, it may look like the market has no clear direction.\n\nIn reality, it\'s simply trying to find a fair price after processing all the overnight news.';

  @override
  String get marketClockWindowOpeningBellDangerForBeginner =>
      'The first 15–30 minutes are often called the most volatile part of the day.\n\nEven if you\'ve chosen an excellent company, its stock price may briefly fall before continuing higher later.\n\nMany beginners panic when they see those early red numbers and sell quality investments for no good reason.';

  @override
  String get marketClockWindowOpeningBellWhatToDo =>
      'If you\'re new to investing, there\'s usually no need to trade immediately after the opening bell.\n\nWaiting just 20–30 minutes often allows the market to settle down.\n\nOnce the initial wave of emotions passes, price movements become much easier to understand.';

  @override
  String get marketClockWindowOpeningBellFomoShieldTip =>
      'The market stays open all day.\n\nGreat opportunities rarely disappear within the first few minutes, but emotional mistakes can last much longer.';

  @override
  String get marketClockWindowMorningSessionShortHeadline => 'Morning Trend';

  @override
  String get marketClockWindowMorningSessionShortDetail =>
      'Best time for calm trading';

  @override
  String get marketClockWindowMorningSessionFullTitle => 'Morning Session';

  @override
  String get marketClockWindowMorningSessionWhatHappens =>
      'The first hour of trading is over, and the market has finally settled down.\n\nMost of the emotional buying and selling has already happened. Large investment funds have made their decisions and are now carrying out their plans more steadily.\n\nIf they decided to buy this morning, they\'ll likely continue buying throughout the session. If they decided to sell, they\'ll do it in a more controlled way.\n\nPrice movements become smoother, and the market\'s overall direction is much easier to recognize.\n\nThis is when the market stops reacting emotionally and starts behaving more rationally.';

  @override
  String get marketClockWindowMorningSessionWhyItMatters =>
      'Many experienced investors consider this one of the best times to trade.\n\nThere are plenty of buyers and sellers, which means orders are filled quickly and at fair prices.\n\nThe difference between the buying and selling price (the spread) is usually very small, and unexpected price swings become less common.\n\nIf the market has chosen a direction for the day, it\'s often much easier to see it during this session.';

  @override
  String get marketClockWindowMorningSessionDangerForBeginner =>
      'This is one of the safest periods of the trading day, but beginners still make one common mistake.\n\nThey see that a stock has already moved a little and think:\n\n\"I missed my chance.\"\n\nOr they notice a small pullback and assume something is wrong with the company.\n\nIn reality, small price movements are completely normal.\n\nA stock doesn\'t need to stay perfectly still to be a good long-term investment.';

  @override
  String get marketClockWindowMorningSessionWhatToDo =>
      'If you\'re investing for the long term, this is often one of the best times to place your planned trades.\n\nThe market has already shown its direction, liquidity is high, and prices tend to be more stable than they were during the opening minutes.\n\nStick to your investment plan instead of reacting to every small movement.';

  @override
  String get marketClockWindowMorningSessionFomoShieldTip =>
      'Good investing rarely requires perfect timing.\n\nIf you\'ve done your research and understand why you\'re buying a company, a calm market is usually your best friend.';

  @override
  String get marketClockWindowLunchHourShortHeadline => 'Lunch Hour';

  @override
  String get marketClockWindowLunchHourShortDetail =>
      'Quiet lull, low activity';

  @override
  String get marketClockWindowLunchHourFullTitle => 'Lunch Hour';

  @override
  String get marketClockWindowLunchHourWhatHappens =>
      'This is usually the quietest part of the trading day.\n\nMany professional traders take a lunch break, portfolio managers step away from their desks, and European markets begin closing for the day.\n\nWith fewer active participants, trading volume drops noticeably.\n\nIf the market felt like a rushing river this morning, it now feels more like a calm lake.';

  @override
  String get marketClockWindowLunchHourWhyItMatters =>
      'When fewer people are trading, prices tend to move much more slowly.\n\nMany stocks spend this period moving sideways without any clear direction.\n\nThis isn\'t a sign that something is wrong.\n\nIt\'s simply a natural part of the market\'s daily rhythm.\n\nNot every hour needs to be exciting.';

  @override
  String get marketClockWindowLunchHourDangerForBeginner =>
      'Ironically, the biggest risk during Lunch Hour is boredom.\n\nMany beginners open their investing app, notice that nothing exciting is happening, and feel the urge to place a trade anyway.\n\nThey aren\'t buying because they found a great investment.\n\nThey\'re buying simply because they want to do something.\n\nThese emotional \"boredom trades\" often become expensive lessons.';

  @override
  String get marketClockWindowLunchHourWhatToDo =>
      'If you\'re following a long-term investment plan, it\'s perfectly fine to make your scheduled purchases during this session.\n\nIf you\'re just watching the market, use the quieter hours wisely.\n\nRead company reports.\n\nResearch businesses you\'re interested in.\n\nOr simply take a break yourself.\n\nSometimes, the best trade is the one you never make.';

  @override
  String get marketClockWindowLunchHourFomoShieldTip =>
      'You don\'t have to trade every day to become a successful investor.\n\nPatience is one of the most valuable skills you can develop.';

  @override
  String get marketClockWindowMidAfternoonShortHeadline => 'Afternoon Session';

  @override
  String get marketClockWindowMidAfternoonShortDetail =>
      'Steady trading, Fed reactions';

  @override
  String get marketClockWindowMidAfternoonFullTitle => 'Mid-Afternoon';

  @override
  String get marketClockWindowMidAfternoonWhatHappens =>
      'The market begins to wake up again.\n\nTraders return to their desks, trading activity increases, and prices become more active once again.\n\nOn certain days, this is also when the U.S. Federal Reserve (the Fed) announces interest rate decisions or other important economic updates.\n\nThese announcements can change the mood of the entire market within minutes.\n\nOn quieter days, the market simply continues the trend that was established earlier in the morning.';

  @override
  String get marketClockWindowMidAfternoonWhyItMatters =>
      'By this point, the market has already absorbed most of the morning\'s news.\n\nIf new economic data is released, large investors may quickly adjust their positions.\n\nThis can create another wave of strong price movements.\n\nUnderstanding what\'s happening during this period helps you avoid being surprised by sudden volatility.';

  @override
  String get marketClockWindowMidAfternoonDangerForBeginner =>
      'On a normal trading day, this session is relatively calm.\n\nHowever, on days when the Federal Reserve makes important announcements, volatility can increase dramatically.\n\nStocks, indexes, and even the entire market may change direction within minutes.\n\nMany beginners see these sudden moves and jump into the market without understanding what caused them.\n\nUnfortunately, prices often reverse just as quickly.';

  @override
  String get marketClockWindowMidAfternoonWhatToDo =>
      'Before placing a trade, take a quick look at the economic calendar.\n\nIf an important Federal Reserve announcement or major economic report is scheduled, consider waiting until the market has had time to react.\n\nOn regular trading days, this is another excellent period for calm and well-planned investing.';

  @override
  String get marketClockWindowMidAfternoonFomoShieldTip =>
      'Experienced investors know that they don\'t have to trade every market event.\n\nSometimes protecting your money simply means waiting for the market to become clear again.';

  @override
  String get marketClockWindowPowerHourShortHeadline => 'Power Hour';

  @override
  String get marketClockWindowPowerHourShortDetail =>
      'Final push, heavy volume';

  @override
  String get marketClockWindowPowerHourFullTitle => 'Power Hour';

  @override
  String get marketClockWindowPowerHourWhatHappens =>
      'The trading day is coming to an end.\n\nFor the market, this is like the final minutes of a championship game—everyone wants to finish strong.\n\nDay traders begin closing their positions to avoid overnight risk.\n\nLarge investment funds rebalance their portfolios before the closing bell.\n\nTrading algorithms execute thousands of remaining orders.\n\nAs a result, trading activity increases rapidly, and the market becomes much more energetic.';

  @override
  String get marketClockWindowPowerHourWhyItMatters =>
      'Power Hour is usually the second busiest period of the entire trading day.\n\nTrading volume rises sharply, and price movements often become stronger and more decisive.\n\nStocks that spent most of the day moving sideways may suddenly break out in one direction.\n\nMany daily highs and lows are set during the final hour before the market closes.';

  @override
  String get marketClockWindowPowerHourDangerForBeginner =>
      'High activity also means higher volatility.\n\nA stock that looked stable all afternoon can suddenly jump or fall several percent within minutes.\n\nMany beginners mistake these fast moves for the beginning of a major trend.\n\nThey rush to buy because they fear missing out...\n\nOr they panic and sell because they believe a crash has started.\n\nIn reality, these moves are often caused by traders closing positions before the market closes—not by a change in the company\'s long-term value.';

  @override
  String get marketClockWindowPowerHourWhatToDo =>
      'If you\'re following a well-prepared investment plan, this can be a perfectly reasonable time to buy or sell.\n\nHowever, never make a decision simply because a price suddenly starts moving faster.\n\nBefore placing an order, ask yourself one simple question:\n\n\"Am I following my investment plan, or am I reacting to emotions?\"\n\nIf the answer is emotions, it\'s usually better to wait.';

  @override
  String get marketClockWindowPowerHourFomoShieldTip =>
      'Not every dramatic price move is a great opportunity.\n\nSometimes the smartest investor is simply the one who stays calm while everyone else is rushing.';

  @override
  String get marketClockWindowAfterHoursShortHeadline => 'After-Hours';

  @override
  String get marketClockWindowAfterHoursShortDetail =>
      'Market closed, evening earnings';

  @override
  String get marketClockWindowAfterHoursFullTitle => 'After-Hours';

  @override
  String get marketClockWindowAfterHoursWhatHappens =>
      'The regular trading session has officially ended.\n\nFor many people, it looks like the stock market is closed.\n\nIn reality, electronic trading continues during the After-Hours session.\n\nThis is also when many of the world\'s largest companies release their quarterly earnings reports.\n\nCompanies like Apple, Microsoft, Amazon, Alphabet, Meta, and many others often publish their results shortly after the closing bell.\n\nInvestors immediately begin reacting to the news.';

  @override
  String get marketClockWindowAfterHoursWhyItMatters =>
      'A single earnings report can completely change how investors value a company.\n\nIf the results are better than expected, the stock may jump 10–20%.\n\nIf the company disappoints investors, the price can fall just as quickly.\n\nThe challenge is that far fewer people are trading after hours.\n\nWith lower liquidity, even relatively small orders can move prices significantly.';

  @override
  String get marketClockWindowAfterHoursDangerForBeginner =>
      'After-Hours trading is one of the riskiest times for beginners.\n\nImagine a stock closed at \$100.\n\nAfter the earnings report, the next available seller wants \$112, while the highest buyer is only offering \$108.\n\nThe gap between buying and selling prices becomes unusually wide.\n\nIf you place a Market Order, you may end up paying far more than you expected.\n\nThe first reaction to earnings is also heavily driven by emotion.\n\nMany investors read the headlines before they fully understand the report.\n\nPrices can swing dramatically several times before settling down.';

  @override
  String get marketClockWindowAfterHoursWhatToDo =>
      'There\'s usually no reason to rush.\n\nUse this time to read the earnings report, understand what actually happened, and see how experienced investors are interpreting the results.\n\nVery often, the market finds a much more reasonable price after the regular session opens the next day.\n\nPatience is usually rewarded.';

  @override
  String get marketClockWindowAfterHoursFomoShieldTip =>
      'Missing the first five minutes after an earnings report rarely changes your long-term success.\n\nMaking a calm decision is usually far more valuable than making a fast one.';

  @override
  String get marketClockWindowClosedShortHeadline => 'Exchange Closed';

  @override
  String get marketClockWindowClosedShortDetail => 'No trading overnight';

  @override
  String get marketClockWindowClosedFullTitle => 'Market Closed';

  @override
  String get marketClockWindowClosedWhatHappens =>
      'The market is now completely closed.\n\nRegular trading has ended, and no new trades are being executed.\n\nBehind the scenes, exchanges process millions of completed transactions, update records, and prepare their systems for the next trading day.\n\nFor investors, this is the quietest part of the day.\n\nPrices stop moving.\n\nThe noise disappears.\n\nAnd for the first time all day, there\'s no pressure to make immediate decisions.';

  @override
  String get marketClockWindowClosedWhyItMatters =>
      'This is the perfect time to think clearly.\n\nWithout constantly watching prices rise and fall, it\'s much easier to focus on what really matters.\n\nMany experienced investors spend more time researching companies after the market closes than they spend actually trading.\n\nThe best investment decisions are often made when the market is quiet—not when it\'s moving.';

  @override
  String get marketClockWindowClosedDangerForBeginner =>
      'The biggest mistake beginners make during Market Closed isn\'t trading.\n\nIt\'s overthinking.\n\nMany people spend hours reading endless headlines, trying to predict exactly what the market will do tomorrow.\n\nThe truth is simple:\n\nNobody knows.\n\nGood news doesn\'t always push prices higher.\n\nBad news doesn\'t always make stocks fall.\n\nTrying to predict every move usually creates unnecessary stress.';

  @override
  String get marketClockWindowClosedWhatToDo =>
      'Use this quiet time wisely.\n\nReview your portfolio.\n\nRead company earnings and annual reports.\n\nLearn more about the businesses you own—or plan to own.\n\nCheck whether your investments still match your long-term goals.\n\nAnd finally...\n\nGet some rest.\n\nThe market will always be there tomorrow, and clear decisions are much easier to make with a fresh mind.';

  @override
  String get marketClockWindowClosedFomoShieldTip =>
      'The best investors aren\'t the ones who spend all day watching charts.\n\nThey\'re the ones who truly understand the businesses they invest in—and have the patience to stick with their plan.';

  @override
  String get marketClockWindowWeekendClosedShortHeadline => 'Weekend';

  @override
  String get marketClockWindowWeekendClosedShortDetail =>
      'Markets reopen Monday';

  @override
  String get marketClockWindowWeekendClosedFullTitle => 'Weekend';

  @override
  String get marketClockWindowWeekendClosedTimeRangeLabel =>
      'Saturday – Sunday';

  @override
  String get marketClockWindowWeekendClosedWhatHappens =>
      'The U.S. stock market is closed for the weekend.\n\nNo stocks are being bought or sold, prices aren\'t changing, and new orders won\'t be executed until the market reopens.\n\nThis is a normal part of the market\'s schedule. Even the world\'s largest financial markets need time to pause.';

  @override
  String get marketClockWindowWeekendClosedWhyItMatters =>
      'While the market is closed, the world keeps moving.\n\nCompanies continue running their businesses.\n\nEconomic news is released.\n\nPolitical events can happen.\n\nBy Monday morning, all of that information is reflected in stock prices.\n\nThis is why markets sometimes open noticeably higher or lower after the weekend.';

  @override
  String get marketClockWindowWeekendClosedDangerForBeginner =>
      'Many beginners spend the entire weekend worrying about what the market might do on Monday.\n\nThey constantly read headlines and try to predict every possible outcome.\n\nThe truth is that no one knows exactly how the market will open.\n\nTrying to guess every move usually creates stress—not better investment decisions.';

  @override
  String get marketClockWindowWeekendClosedWhatToDo =>
      'Weekends are a great opportunity to become a better investor.\n\nReview your portfolio.\n\nRead about the companies you own.\n\nLearn something new about investing.\n\nOr simply take a break and enjoy your weekend.\n\nA clear mind often leads to better decisions than watching charts all day.';

  @override
  String get marketClockWindowWeekendClosedFomoShieldTip =>
      'Real markets may be closed today, but learning never takes a day off.';

  @override
  String get marketClockWindowWeekendClosedStressTestPromoTitle =>
      'While the market is closed...';

  @override
  String get marketClockWindowWeekendClosedStressTestPromoBody =>
      'The Stress Test is always available.\n\nPractice building portfolios, reacting to market events, and making investment decisions without risking real money.\n\nThe simulator is designed to help you understand how markets behave and build discipline before investing in live markets.\n\nEvery trade inside Stress Test is completely independent of real market prices, so you can experiment, learn from mistakes, and improve with confidence.';

  @override
  String get marketClockWindowMarketHolidayShortHeadline => 'Market Holiday';

  @override
  String get marketClockWindowMarketHolidayShortDetail =>
      'Exchange closed for a holiday';

  @override
  String get marketClockWindowMarketHolidayFullTitle => 'Market Holiday';

  @override
  String get marketClockWindowMarketHolidayTimeRangeLabel => 'All day';

  @override
  String get marketClockWindowMarketHolidayWhatHappens =>
      'Today the U.S. stock market is closed because of an official exchange holiday.\n\nNo regular trading takes place, and orders will wait until the next trading session.\n\nThis happens several times each year during major U.S. holidays.';

  @override
  String get marketClockWindowMarketHolidayWhyItMatters =>
      'A market holiday is not the same as a market problem.\n\nNothing unusual is happening.\n\nTrading simply pauses according to the exchange calendar.\n\nHowever, news can still be released while the market is closed.\n\nWhen trading resumes, prices may adjust to everything that happened during the break.';

  @override
  String get marketClockWindowMarketHolidayDangerForBeginner =>
      'Some beginners think the market is \"frozen\" because something bad has happened.\n\nIn reality, exchange holidays are planned well in advance.\n\nThere\'s no reason to worry just because trading is paused for the day.';

  @override
  String get marketClockWindowMarketHolidayWhatToDo =>
      'Take advantage of the quieter day.\n\nRead company reports.\n\nReview your investment goals.\n\nOrganize your watchlist.\n\nOr spend some time improving your investing knowledge.\n\nEvery experienced investor started by learning.';

  @override
  String get marketClockWindowMarketHolidayFomoShieldTip =>
      'The best investors don\'t improve only when the market is open.\n\nThey improve every day.';

  @override
  String get marketClockWindowMarketHolidayStressTestPromoTitle =>
      'Keep practicing';

  @override
  String get marketClockWindowMarketHolidayStressTestPromoBody =>
      'Although the live market is closed, the Stress Test remains fully available.\n\nIt\'s the perfect place to practice buying, selling, portfolio management, and emotional discipline without risking real money.\n\nYou can explore different strategies, make mistakes safely, and better understand how markets react in different situations.\n\nWhen the real market opens again, you\'ll return with more experience and greater confidence.';

  @override
  String get marketClockWindowEarlyCloseSessionShortHeadline =>
      'Early Close Day';

  @override
  String get marketClockWindowEarlyCloseSessionShortDetail =>
      'Market closes at 1:00 PM ET';

  @override
  String get marketClockWindowEarlyCloseSessionFullTitle => 'Early Close Day';

  @override
  String get marketClockWindowEarlyCloseSessionWhatHappens =>
      'Today the exchange is operating on a shortened schedule and will close at 1:00 PM ET instead of 4:00 PM.';

  @override
  String get marketClockWindowEarlyCloseSessionWhyItMatters =>
      'There\'s less time to get orders filled — trading activity and volume compress into a shorter window.';

  @override
  String get marketClockWindowEarlyCloseSessionDangerForBeginner =>
      'It\'s easy to forget about the early close and place an order that won\'t execute today.';

  @override
  String get marketClockWindowEarlyCloseSessionWhatToDo =>
      'Plan your trades ahead of time and don\'t leave important orders for the second half of the day.';

  @override
  String get marketClockWindowEarlyCloseSessionStressTestPromoTitle =>
      'Try it risk-free first';

  @override
  String get marketClockWindowEarlyCloseSessionStressTestPromoBody =>
      'A shortened, faster-moving session can feel unfamiliar. Practice it in Stress Test — no real money on the line, just real market conditions to learn from.';

  @override
  String get marketClockRiskEarlyPreMarketWhyNow =>
      'The market has only just started to wake up. There are very few buyers and sellers, so even small trades can move prices much more than usual. Liquidity is low, spreads are wide, and prices may not reflect a company\'s true value.';

  @override
  String get marketClockRiskEarlyPreMarketWhatToDo =>
      'Unless you have a specific reason to trade, it\'s usually better to wait. Use this quiet time to review your watchlist, read company news, and prepare your plan for the day. If you must trade, always consider using a Limit Order instead of a Market Order.';

  @override
  String get marketClockRiskPreMarketReportsWhyNow =>
      'Trading activity increases as more participants enter the market. This is also when many companies publish earnings reports and important U.S. economic data is released. Prices often react quickly and may continue changing as investors digest the news.';

  @override
  String get marketClockRiskPreMarketReportsWhatToDo =>
      'Focus on understanding the news rather than reacting to it immediately. Review earnings reports, check the economic calendar, and see how the market responds before making a decision.';

  @override
  String get marketClockRiskOpeningBellWhyNow =>
      'The regular trading session begins and millions of overnight orders are executed at once. Trading volume is extremely high, but so is volatility. The market is searching for a fair price after processing all the overnight information.';

  @override
  String get marketClockRiskOpeningBellWhatToDo =>
      'For beginners, patience is often the best strategy. Give the market 20-30 minutes to settle before making planned long-term investments. Avoid making decisions based on the first sharp price movements.';

  @override
  String get marketClockRiskMorningSessionWhyNow =>
      'The early volatility has faded, liquidity remains high, and price movements become more stable. This is often one of the most balanced periods of the trading day.';

  @override
  String get marketClockRiskMorningSessionWhatToDo =>
      'If you\'re investing for the long term, this is generally one of the best times to execute your planned purchases. Continue focusing on company fundamentals rather than short-term price fluctuations.';

  @override
  String get marketClockRiskLunchHourWhyNow =>
      'Trading activity slows as many professional traders step away for lunch. Price movements become quieter and the market often moves sideways.';

  @override
  String get marketClockRiskLunchHourWhatToDo =>
      'This is a good time to research companies, review financial statements, or make planned long-term investments without feeling rushed. Don\'t trade simply because the market seems quiet.';

  @override
  String get marketClockRiskMidAfternoonWhyNow =>
      'Activity picks up again as traders return. On certain days, Federal Reserve announcements or important economic reports can significantly increase volatility.';

  @override
  String get marketClockRiskMidAfternoonWhatToDo =>
      'Before placing a trade, check whether major economic events are scheduled. On normal days, this is another comfortable period for long-term investing. On Fed days, consider waiting until the market reacts.';

  @override
  String get marketClockRiskPowerHourWhyNow =>
      'The final hour of trading is highly active as day traders close positions and investment funds rebalance portfolios. Strong price movements are common.';

  @override
  String get marketClockRiskPowerHourWhatToDo =>
      'Avoid chasing fast-moving prices. If you\'re making a planned investment, stick to your strategy rather than reacting to late-day excitement.';

  @override
  String get marketClockRiskAfterHoursWhyNow =>
      'Many companies release earnings after the market closes. At the same time, fewer traders are active, which can lead to large price swings and wider spreads.';

  @override
  String get marketClockRiskAfterHoursWhatToDo =>
      'This is usually a better time to read earnings reports and analyze the news than to trade. Waiting until the next regular session often leads to calmer and more informed decisions.';

  @override
  String get marketClockRiskEarlyCloseSessionWhyNow =>
      'Today the U.S. stock market is operating on a shortened schedule.\n\nMany institutional investors, banks, and professional traders finish their work earlier than usual, so market activity gradually decreases as the day goes on. With fewer participants, some stocks may trade less actively, while others can experience unexpected price movements due to lower trading volume.\n\nThe biggest risk is a false sense of calm. Although the market may appear quiet, lower participation means that even relatively small trades can have a greater impact on prices. Bid-ask spreads may widen, and price movements can become less predictable.\n\nAnother important factor is that many investors prefer to reduce or close positions before a long holiday weekend to avoid holding risk while the market is closed. This can create additional selling pressure, even when there is no negative news about a company.';

  @override
  String get marketClockRiskEarlyCloseSessionWhatToDo =>
      'If you\'re investing for the long term and your decision has already been made, a shortened trading day is not necessarily a reason to avoid investing.\n\nHowever, if your trade isn\'t time-sensitive, waiting until the next full trading session often provides better liquidity and more stable market conditions.\n\nUse the extra time to review your watchlist, read company reports, or practice in Stress Test.\n\nAn early market close isn\'t a reason to rush your decisions. Sometimes the smartest move is simply to wait for the next full trading day, when the market returns to normal conditions.';

  @override
  String get marketClockRiskClosedWhyNow =>
      'The market is closed and no trades are taking place. This is the perfect opportunity to step away from price movements and focus on learning.';

  @override
  String get marketClockRiskClosedWhatToDo =>
      'Review your portfolio, read company reports, and prepare your plan for the next trading day. You can also practice in Stress Test, where every trade is simulated and completely independent of the live market.';

  @override
  String get marketClockRiskWeekendHolidayWhyNow =>
      'The stock market is closed, but the world keeps moving. News, politics, and company announcements continue, even though no trading takes place.';

  @override
  String get marketClockRiskWeekendHolidayWhatToDo =>
      'Take the opportunity to learn without pressure. Explore new companies, improve your investing knowledge, or practice in Stress Test. It\'s a safe environment where you can build confidence, develop discipline, and test ideas without risking real money.';

  @override
  String get marketClockNewYorkTimeTitle => 'NEW YORK TIME';

  @override
  String get marketClockMacroPhasePreMarketLabel => 'PRE-MARKET';

  @override
  String get marketClockMacroPhaseMarketOpenLabel => 'MARKET OPEN';

  @override
  String get marketClockMacroPhaseAfterHoursLabel => 'AFTER HOURS';

  @override
  String get marketClockMacroPhaseMarketClosedLabel => 'MARKET CLOSED';

  @override
  String marketClockCountdownEnds(String time) {
    return 'Ends $time';
  }

  @override
  String marketClockCountdownStarts(String time) {
    return 'Starts $time';
  }

  @override
  String get marketClockWidgetDisplayNameNyTime => 'New York Time';

  @override
  String get marketClockWidgetDisplayNameMarketPhase => 'Market Phase';

  @override
  String get marketClockWidgetDisplayNameTimingIndicator =>
      'FOMO Shield Status';

  @override
  String get marketPhaseWidgetTitle => 'MARKET PHASE';

  @override
  String get marketPhaseWidgetDetailsTooltip => 'Details';

  @override
  String get marketClockFomoShieldStatusTitle => 'FOMO SHIELD STATUS';

  @override
  String get marketClockRiskDetailWhyNowLabel => 'Why Now?';

  @override
  String get marketClockRiskDetailWhatToDoLabel => 'What Should You Do?';

  @override
  String get marketClockScreenTitle => 'MARKET CLOCK';

  @override
  String get marketClockAddWidgetsButton => 'Add widgets';

  @override
  String get marketClockRiskTierLowLabel => 'LOW RISK';

  @override
  String get marketClockRiskTierModerateLabel => 'MODERATE RISK';

  @override
  String get marketClockRiskTierHighLabel => 'HIGH RISK';

  @override
  String get marketClockRiskTierClosedLabel => 'MARKET CLOSED';

  @override
  String get marketClockMetricLiquidity => 'Liquidity';

  @override
  String get marketClockMetricVolatility => 'Volatility';

  @override
  String get marketClockMetricNewsRisk => 'News Risk';

  @override
  String get marketClockMetricFomoShield => 'F.O.M.O. Shield';

  @override
  String get marketClockRiskScoreLabel => 'RISK SCORE';

  @override
  String get marketClockWidgetSettingsTitle => 'Widget Settings';

  @override
  String get marketClockWidgetSettingsReset => 'Reset';

  @override
  String get marketPeriodDetailFallbackTitle => 'PERIOD';

  @override
  String get marketPeriodDetailWhatsHappeningLabel => 'What\'s Happening?';

  @override
  String get marketPeriodDetailWhyDoesItMatterLabel => 'Why Does It Matter?';

  @override
  String get marketPeriodDetailWhatCanGoWrongLabel => 'What Can Go Wrong?';

  @override
  String get marketPeriodDetailWhatShouldBeginnersDoLabel =>
      'What Should Beginners Do?';

  @override
  String get marketPeriodDetailOpenStressTestButton => 'Open Stress Test';

  @override
  String get marketPeriodDetailFomoShieldTipLabel => 'F.O.M.O. SHIELD TIP';

  @override
  String get marketPhasesScreenTitle => 'MARKET PHASES';

  @override
  String get marketPhasesScreenNowBadge => 'NOW';

  @override
  String get marketPhasesScreenMoreLink => 'More';

  @override
  String get assetsScreenTitle => 'Assets';

  @override
  String get assetsScreenNoAssets => 'No assets';

  @override
  String get assetsScreenTotalValueLabel => 'TOTAL VALUE';

  @override
  String get assetsScreenStartCashLabel => 'START CASH';

  @override
  String get assetsScreenSortValue => 'Value';

  @override
  String get assetsScreenSortMarketPrice => 'Market Price';

  @override
  String get assetsScreenDevPhaseLabel => 'PHASE';

  @override
  String get assetsScreenDevTempLabel => 'TEMP';

  @override
  String get assetsScreenDevFatigueLabel => 'FATIGUE';

  @override
  String get assetsScreenDevSeedLabel => 'SEED';

  @override
  String get assetsScreenDevTickLabel => 'TICK';

  @override
  String assetsScreenDevNewsLabel(String symbol) {
    return 'NEWS $symbol';
  }

  @override
  String assetsScreenDevHypeLabel(String sector) {
    return 'HYPE $sector';
  }

  @override
  String assetsScreenDevTimeLeftHm(int hours, int minutes) {
    return '${hours}h${minutes}m left';
  }

  @override
  String assetsScreenDevTimeLeftM(int minutes) {
    return '${minutes}m left';
  }

  @override
  String get assetsScreenDevTimeEnding => 'ending';

  @override
  String get stockDetailAppBarTitle => 'COMPANY CARD';

  @override
  String whyTodayScreenAppBarTitle(String symbol) {
    return '$symbol DIAGNOSTICS';
  }

  @override
  String get whyTodayScreenTodaysChangeTitle => 'TODAY\'S CHANGE';

  @override
  String get whyTodayScreenDollarsLabel => 'DOLLARS';

  @override
  String get whyTodayScreenPercentLabel => 'PERCENT';

  @override
  String get whyTodayScreenThisTickTitle => 'THIS TICK — FACTOR BREAKDOWN';

  @override
  String get whyTodayScreenWholePeriodTitle =>
      'WHOLE PERIOD — FACTOR BREAKDOWN';

  @override
  String whyTodayScreenWholePeriodSubtitle(int tickCount) {
    return 'Weighted by each tick\'s own price move — $tickCount ticks since first purchase.';
  }

  @override
  String whyTodayScreenWholePeriodSubtitleRecentOnly(int tickCount) {
    return 'Weighted by each tick\'s own price move — $tickCount ticks since first purchase (recent only — no cache yet).';
  }

  @override
  String get whyTodayScreenRawDriftTitle => 'RAW DRIFT VALUES (LATEST TICK)';

  @override
  String get whyTodayScreenRawDriftSubtitle =>
      'Unnormalized — before the 5 factors above are scaled to sum to 100%.';

  @override
  String get whyTodayScreenFactorMarketTrends => 'Market Trends';

  @override
  String get whyTodayScreenFactorSector => 'Sector';

  @override
  String get whyTodayScreenFactorNews => 'News';

  @override
  String get whyTodayScreenFactorSectorHype => 'Sector Hype';

  @override
  String get whyTodayScreenFactorNoise => 'Noise';

  @override
  String get whyTodayScreenRawMarketDrift => 'Market drift';

  @override
  String get whyTodayScreenRawSectorDrift => 'Sector drift';

  @override
  String get whyTodayScreenRawHype => 'Hype';

  @override
  String get whyTodayScreenNewsAndHypeTitle => 'NEWS & SECTOR HYPE';

  @override
  String get whyTodayScreenMarketPhaseTitle => 'MARKET PHASE / EPOCHS';

  @override
  String whyTodayScreenNewsLiveLabel(String headline) {
    return 'News — LIVE: $headline';
  }

  @override
  String whyTodayScreenTargetDetail(String percent) {
    return '$percent% target';
  }

  @override
  String get whyTodayScreenSectorHypeLiveLabel => 'Sector Hype — LIVE';

  @override
  String whyTodayScreenSectorTargetDetail(String percent) {
    return '$percent% sector target';
  }

  @override
  String whyTodayScreenRemainingHm(int hours, int minutes) {
    return '≈${hours}h ${minutes}m left';
  }

  @override
  String whyTodayScreenRemainingM(int minutes) {
    return '≈${minutes}m left';
  }

  @override
  String get whyTodayScreenWrappingUp => 'wrapping up';

  @override
  String whyTodayScreenNewsHistoryTitle(int count) {
    return 'NEWS HISTORY ($count)';
  }

  @override
  String get whyTodayScreenNoNewsEpisodes => 'No News episodes yet.';

  @override
  String whyTodayScreenSectorHypeHistoryTitle(int count) {
    return 'SECTOR HYPE HISTORY ($count)';
  }

  @override
  String get whyTodayScreenNoHypeEpisodes => 'No Sector Hype episodes yet.';

  @override
  String whyTodayScreenEpochSingle(int num) {
    return 'Epoch $num';
  }

  @override
  String whyTodayScreenEpochRange(int start, int end) {
    return 'Epoch $start–$end';
  }

  @override
  String whyTodayScreenEpochScenario(int num, String scenario) {
    return 'Epoch $num — $scenario';
  }

  @override
  String get whyTodayScreenActiveLabel => 'active';

  @override
  String get whyTodayScreenTicksTitle => 'Ticks';

  @override
  String whyTodayScreenFactorMoved(String factor, int percent) {
    return '$factor moved by $percent%';
  }

  @override
  String get whyTodayScreenEmptyStateMessage =>
      'No tick data yet for this position.';

  @override
  String get stockLimitOrdersTitle => 'LIMIT ORDERS';

  @override
  String stockLimitOrdersSeeAll(int count) {
    return 'See all $count orders';
  }

  @override
  String stockLimitOrdersSheetTitle(String symbol) {
    return '$symbol Limit Orders';
  }

  @override
  String get stockPositionCardTitle => 'YOUR POSITION';

  @override
  String get stockPositionCardAssetValueLabel => 'Asset Value';

  @override
  String get stockPositionCardSharesLabel => 'Shares';

  @override
  String get stockPositionCardUnrealizedPnlLabel => 'Unrealized P&L';

  @override
  String get stockPositionCardAvgCostLabel => 'Avg Cost';

  @override
  String get stockSparklineChartTitle => 'PRICE CHART';

  @override
  String get whyTodayCardTitle => 'WHY TODAY';

  @override
  String get whyTodayCardButtonLabel => 'Why today?';

  @override
  String get whyTodayCardTodaysChangeLabel => 'TODAY\'S CHANGE';

  @override
  String get whyTodayCardPercentChangeLabel => 'PERCENT CHANGE';

  @override
  String get whyTodayCardFactorMarketTrends => 'Market Trends';

  @override
  String get whyTodayCardFactorSector => 'Sector';

  @override
  String get whyTodayCardFactorNews => 'News';

  @override
  String get whyTodayCardFactorSectorHype => 'Sector Hype';

  @override
  String get whyTodayCardFactorNoise => 'Noise';

  @override
  String get whyTodayCardHintNoData =>
      'Not enough data yet for this position — check back after the next price tick for a read on what might be moving it.';

  @override
  String get whyTodayCardHintMarketBull =>
      'Broad market strength may be lifting this position along with the wider trend today.';

  @override
  String get whyTodayCardHintMarketSideways =>
      'The wider market looks range-bound right now, which could be keeping this position relatively flat.';

  @override
  String get whyTodayCardHintMarketBear =>
      'A broader market pullback may be weighing on this position along with the rest of the market.';

  @override
  String get whyTodayCardHintMarketVolatility =>
      'Choppy, directionless market conditions could be behind today\'s swings.';

  @override
  String get whyTodayCardHintMarketRecovery =>
      'The market may be steadying after a recent shock, which could explain today\'s move.';

  @override
  String get whyTodayCardHintMarketBlackSwan =>
      'An unusual, sharp market-wide shock may be driving today\'s move — worth watching closely.';

  @override
  String get whyTodayCardHintMarketCrash =>
      'A steep market-wide selloff may be weighing heavily on this position right now.';

  @override
  String get whyTodayCardHintSector =>
      'This move may be tied to how this position\'s sector is trading relative to the rest of the market.';

  @override
  String get whyTodayCardHintNews =>
      'Company-specific news — possibly something like an earnings report — could be behind today\'s move.';

  @override
  String get whyTodayCardHintHype =>
      'A broader wave of attention across this position\'s whole sector may be driving today\'s move.';

  @override
  String get whyTodayCardHintNoise =>
      'Today\'s move looks like ordinary day-to-day price fluctuation, without one single clear driver.';

  @override
  String stressTestOrderRowBuyLine(String quantity) {
    return 'Buy $quantity shares';
  }

  @override
  String stressTestOrderRowSellLine(String quantity) {
    return 'Sell $quantity shares';
  }

  @override
  String stressTestOrderRowLimitPriceLine(String price) {
    return 'Limit Price $price';
  }

  @override
  String get monetizationModalTitle => 'Search limit reached';

  @override
  String get monetizationModalDescription =>
      'You\'ve used all your free searches. Upgrade to Premium for unlimited searches or watch an ad to get 15 more.';

  @override
  String get monetizationModalUpgradeButton => 'Upgrade to Premium';

  @override
  String get monetizationModalWatchAdButton => 'Watch Ad (+15 searches)';

  @override
  String get monetizationModalCounterResetAdmin =>
      '🔧 Counter reset to 15 (admin)';

  @override
  String get monetizationModalResetCounterAdmin => 'Reset counter (admin)';

  @override
  String get monetizationModalSponsoredAd => 'Sponsored Ad';

  @override
  String get monetizationModalRewardText => 'Your reward: +15 free searches';

  @override
  String monetizationModalSecondsRemaining(int seconds) {
    return '${seconds}s remaining';
  }

  @override
  String get monetizationModalSkip => 'Skip';

  @override
  String get monetizationModalComingSoon =>
      '🏗️ Premium subscription — coming soon!';

  @override
  String get monetizationModalRewardEarned => '✓ Earned 15 more searches!';

  @override
  String get premiumPromoOverlayBarrierLabel => 'Premium promo overlay';

  @override
  String get premiumPromoOverlayDefaultTitle => 'Premium feature';

  @override
  String get premiumPromoOverlayBadge => 'PREMIUM';

  @override
  String get premiumPromoOverlaySubtitle => 'Upgrade to unlock this and more';

  @override
  String get premiumPromoOverlayFeatureAdFree => 'Completely ad‑free';

  @override
  String premiumPromoOverlaySecondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String premiumPromoOverlayClosingIn(int seconds) {
    return 'Closing in ${seconds}s…';
  }

  @override
  String get premiumPromoOverlayClose => 'Close';

  @override
  String get disclaimerScreenTitle => 'Disclaimer';

  @override
  String get disclaimerScreenAccessRestricted => 'Access Restricted';

  @override
  String get disclaimerScreenAppWillClose => 'The app will now close';

  @override
  String get disclaimerScreenCloseAppButton => 'Close App';

  @override
  String get disclaimerScreenImportantNoticeTitle => 'Important Notice';

  @override
  String get disclaimerScreenImportantNoticeBody =>
      'F.O.M.O. Shield is an educational tool designed to help investors understand market behavior and their own decision-making patterns. It does not provide financial advice, investment recommendations, or any form of financial advisory services.';

  @override
  String get disclaimerScreenFsScoresTitle => 'Independence of FS Scores';

  @override
  String get disclaimerScreenFsScoresBody =>
      'FS Scores and all related analytical materials are the result of F.O.M.O. Shield\'s proprietary analysis based on mathematical models and publicly available data. We do not receive compensation from companies for inclusion in the ratings or for rating changes. FS Scores are not a recommendation to buy, sell, or hold any security.';

  @override
  String get disclaimerScreenDataSourcesTitle => 'Data Sources';

  @override
  String get disclaimerScreenDataSourcesBody =>
      'Market data is provided by Finnhub and Wikipedia APIs. While we strive for accuracy, we cannot guarantee that all data is complete, accurate, or up-to-date. Past performance is not indicative of future results. Stress test scenarios are simulations based on mathematical models and historical patterns.';

  @override
  String get disclaimerScreenPrivacyTitle => 'Privacy';

  @override
  String get disclaimerScreenPrivacyBody =>
      'We collect minimal data necessary for app functionality: your email address (for account creation) and the data you generate inside the app (portfolios, watchlist, simulations). We do not sell your data to third parties.';

  @override
  String get disclaimerScreenTermsUpdatesTitle => 'Terms Updates';

  @override
  String get disclaimerScreenTermsUpdatesBody =>
      'We reserve the right to update this disclaimer, Terms of Service, and Privacy Policy. In case of changes, the app will notify you and require re-acceptance of the updated terms to continue.';

  @override
  String get disclaimerScreenAcceptPrefix =>
      'I confirm that I am at least 18 years old and I fully accept this Disclaimer, the ';

  @override
  String get disclaimerScreenTermsOfServiceLink => 'Terms of Service';

  @override
  String get disclaimerScreenAcceptAndThe => ', and the ';

  @override
  String get disclaimerScreenPrivacyPolicyLink => 'Privacy Policy';

  @override
  String get disclaimerScreenAcceptButton => 'I Accept';

  @override
  String get disclaimerScreenLinkFailed =>
      'Couldn\'t open the link. Please check your internet connection.';

  @override
  String get accountRestoreScreenRestoreFailed =>
      'Could not restore your account. Please try again.';

  @override
  String get accountRestoreScreenTitle => 'Account Scheduled for Deletion';

  @override
  String accountRestoreScreenDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count days left to restore this account',
      one: 'You have $count day left to restore this account',
    );
    return '$_temp0';
  }

  @override
  String accountRestoreScreenDeletionWarningSuffix(String date) {
    return ' — after $date it will be permanently erased, with no way to recover it';
  }

  @override
  String get accountRestoreScreenAboutToErase =>
      'This account is about to be permanently erased, with no way to recover it.';

  @override
  String get accountRestoreScreenRestoreButton => 'Restore Account';

  @override
  String get forgotPasswordScreenEnterEmail =>
      'Please enter your email address';

  @override
  String forgotPasswordScreenWaitSeconds(int seconds) {
    return 'Please wait $seconds seconds before requesting again.';
  }

  @override
  String get forgotPasswordScreenTitle => 'Reset password';

  @override
  String get forgotPasswordScreenSubtitle =>
      'Enter your email and we\'ll send you a link\nto reset your password.';

  @override
  String get forgotPasswordScreenCheckEmail => 'Check your email';

  @override
  String get forgotPasswordScreenSentMessage =>
      'If this email is registered in our system, we\'ve sent a password reset link to it.';

  @override
  String get forgotPasswordScreenDevModeNote =>
      'Dev mode: reset link is logged in the debug console.';

  @override
  String get forgotPasswordScreenSendButton => 'Send Reset Link';

  @override
  String get forgotPasswordScreenBackToSignIn => 'Back to Sign In';

  @override
  String get authGoogleNoIdToken => 'Google did not return an ID token.';

  @override
  String get watchlistFullScreenEmptyTitle => 'No companies yet';

  @override
  String get watchlistFullScreenEmptySubtitle =>
      'Tap + to search and add companies';

  @override
  String get watchlistFullScreenSearchButton => 'Search companies';

  @override
  String orderRowTilePriceLabel(String orderType, String price) {
    return '$orderType Price $price';
  }

  @override
  String get orderCancelDialogTitle => 'Cancel Order?';

  @override
  String get orderCancelDialogBody =>
      'Are you sure you want to cancel this order?';

  @override
  String get orderCancelDialogNo => 'No';

  @override
  String get orderCancelDialogYes => 'Yes';

  @override
  String orderAmountSectionApproxUsd(String amount) {
    return '≈ $amount';
  }

  @override
  String get orderEntryNotifYouBought => 'You Bought';

  @override
  String get orderEntryNotifYouSold => 'You Sold';

  @override
  String orderEntryNotifFilledDetail(
    String quantity,
    String companyName,
    String price,
  ) {
    return '$quantity shares of $companyName at $price';
  }

  @override
  String get orderEntryNotifBuyWord => 'Buy';

  @override
  String get orderEntryNotifSellWord => 'Sell';

  @override
  String orderEntryNotifOrderPlacedTitle(String orderType, String buyOrSell) {
    return '$orderType $buyOrSell Order Placed';
  }

  @override
  String orderEntryNotifPendingDetailBase(String quantity, String companyName) {
    return '$quantity shares of $companyName';
  }

  @override
  String orderEntryNotifAtPrice(String price) {
    return ' at $price';
  }

  @override
  String get orderEntryNotifPendingSuffix => ' — Pending';
}
