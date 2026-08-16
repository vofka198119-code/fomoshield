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
}
