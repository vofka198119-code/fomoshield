import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get navPortfolio;

  /// No description provided for @navStressTest.
  ///
  /// In en, this message translates to:
  /// **'Stress Test'**
  String get navStressTest;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystemDefault;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for the app\'s interface.'**
  String get languagePickerSubtitle;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue investing with discipline'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your journey to disciplined investing'**
  String get authSignUpSubtitle;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountButton;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authPleaseFillFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get authPleaseFillFields;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'A user with this email is already registered.'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authEmailAlreadyRegisteredGoogle.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in, or use \"Continue with Google\" if that\'s how you signed up.'**
  String get authEmailAlreadyRegisteredGoogle;

  /// No description provided for @authCheckEmailConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm registration.'**
  String get authCheckEmailConfirm;

  /// No description provided for @authSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authSomethingWentWrong;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailed;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} seconds.'**
  String authTooManyAttempts(int seconds);

  /// No description provided for @authWaitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Please wait {seconds} seconds before trying again.'**
  String authWaitSeconds(int seconds);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// No description provided for @profileNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get profileNotSignedIn;

  /// No description provided for @profileAdminBadge.
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get profileAdminBadge;

  /// No description provided for @profilePremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get profilePremiumBadge;

  /// No description provided for @profilePreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferencesSection;

  /// No description provided for @profileStatisticsSection.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileStatisticsSection;

  /// No description provided for @profileStatDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get profileStatDays;

  /// No description provided for @profileStatCompanies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get profileStatCompanies;

  /// No description provided for @profileStatTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get profileStatTests;

  /// No description provided for @profileLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileLegalSection;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get profileTermsOfUse;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll have 14 days to restore your account after this. If you don\'t restore it within that window, your account and all your data — portfolios, watchlist, stress test history — will be permanently erased, with no way to recover it.'**
  String get profileDeleteAccountBody;

  /// No description provided for @profileCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDelete;

  /// No description provided for @profileDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Please try again.'**
  String get profileDeleteFailed;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get premiumActive;

  /// No description provided for @premiumLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime subscription'**
  String get premiumLifetime;

  /// No description provided for @premiumExpired.
  ///
  /// In en, this message translates to:
  /// **'Subscription expired'**
  String get premiumExpired;

  /// No description provided for @premiumDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days}d remaining'**
  String premiumDaysRemaining(int days);

  /// No description provided for @premiumExpiredBadge.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get premiumExpiredBadge;

  /// No description provided for @premiumDaysBadge.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String premiumDaysBadge(int days);

  /// No description provided for @premiumBenefitSearches.
  ///
  /// In en, this message translates to:
  /// **'Unlimited daily searches'**
  String get premiumBenefitSearches;

  /// No description provided for @premiumBenefitPortfolios.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 portfolios'**
  String get premiumBenefitPortfolios;

  /// No description provided for @premiumBenefitCapital.
  ///
  /// In en, this message translates to:
  /// **'\$50,000 starting capital'**
  String get premiumBenefitCapital;

  /// No description provided for @premiumBenefitStressTests.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 stress tests'**
  String get premiumBenefitStressTests;

  /// No description provided for @premiumBenefitAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get premiumBenefitAdFree;

  /// No description provided for @tradeBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get tradeBuy;

  /// No description provided for @tradeSell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get tradeSell;

  /// No description provided for @tradeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'TRADE DETAIL'**
  String get tradeDetailTitle;

  /// No description provided for @tradeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Trade not found'**
  String get tradeNotFound;

  /// No description provided for @tradeOrderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order Type'**
  String get tradeOrderTypeLabel;

  /// No description provided for @tradeMarketType.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get tradeMarketType;

  /// No description provided for @tradeLimitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Limit Price'**
  String get tradeLimitPriceLabel;

  /// No description provided for @tradeStopPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop Price'**
  String get tradeStopPriceLabel;

  /// No description provided for @tradeSharesBoughtLabel.
  ///
  /// In en, this message translates to:
  /// **'Shares Bought'**
  String get tradeSharesBoughtLabel;

  /// No description provided for @tradeSharesSoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Shares Sold'**
  String get tradeSharesSoldLabel;

  /// No description provided for @tradePricePerShareLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per Share'**
  String get tradePricePerShareLabel;

  /// No description provided for @tradeTotalValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get tradeTotalValueLabel;

  /// No description provided for @tradeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tradeDateLabel;

  /// No description provided for @tradeRealizedPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L'**
  String get tradeRealizedPnlLabel;

  /// No description provided for @disclaimerFooter.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: F.O.M.O. Shield is for educational and entertainment purposes only. We are not registered investment advisors. All trading decisions are solely your responsibility. Past performance does not guarantee future results.'**
  String get disclaimerFooter;

  /// No description provided for @homeAddWidgets.
  ///
  /// In en, this message translates to:
  /// **'Add widgets'**
  String get homeAddWidgets;

  /// No description provided for @homeWidgetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get homeWidgetSettingsTitle;

  /// No description provided for @homeReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get homeReset;

  /// No description provided for @homeWidgetShieldSignal.
  ///
  /// In en, this message translates to:
  /// **'Shield Signal'**
  String get homeWidgetShieldSignal;

  /// No description provided for @homeWidgetWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get homeWidgetWatchlist;

  /// No description provided for @homeWidgetMarketClock.
  ///
  /// In en, this message translates to:
  /// **'Market Clock'**
  String get homeWidgetMarketClock;

  /// No description provided for @homeWidgetPortfolio.
  ///
  /// In en, this message translates to:
  /// **'My Portfolio'**
  String get homeWidgetPortfolio;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @shieldSignalTitle.
  ///
  /// In en, this message translates to:
  /// **'SHIELD SIGNAL'**
  String get shieldSignalTitle;

  /// No description provided for @shieldSignalChange.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get shieldSignalChange;

  /// No description provided for @shieldSignalChangePercent.
  ///
  /// In en, this message translates to:
  /// **'CHANGE %'**
  String get shieldSignalChangePercent;

  /// No description provided for @moodBullishTitle.
  ///
  /// In en, this message translates to:
  /// **'Bullish Momentum'**
  String get moodBullishTitle;

  /// No description provided for @moodBullishBody.
  ///
  /// In en, this message translates to:
  /// **'Buyers are clearly leading today\'s market. Strong demand is pushing prices higher across many companies, and positive news or growing optimism is encouraging investors to keep buying. Momentum is on the bulls\' side — just remember, even strong trends eventually slow down, so avoid chasing prices out of excitement.'**
  String get moodBullishBody;

  /// No description provided for @moodSteadyClimbTitle.
  ///
  /// In en, this message translates to:
  /// **'Steady Climb'**
  String get moodSteadyClimbTitle;

  /// No description provided for @moodSteadyClimbBody.
  ///
  /// In en, this message translates to:
  /// **'Buyers have a slight advantage today. Demand is a little stronger than selling pressure, pushing the index higher. The move is healthy and controlled, with no signs of panic or excessive excitement — confidence is slowly building.'**
  String get moodSteadyClimbBody;

  /// No description provided for @moodWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Direction'**
  String get moodWaitingTitle;

  /// No description provided for @moodWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'The market is taking a breath. Buyers and sellers are evenly matched, so prices are moving very little. Nothing unusual is happening right now — investors are simply waiting for the next piece of important news before choosing a direction.'**
  String get moodWaitingBody;

  /// No description provided for @moodCautionTitle.
  ///
  /// In en, this message translates to:
  /// **'Growing Caution'**
  String get moodCautionTitle;

  /// No description provided for @moodCautionBody.
  ///
  /// In en, this message translates to:
  /// **'Sellers have gained a small advantage. The market is drifting lower, but there are no signs of panic. Small pullbacks like this are a normal part of investing.'**
  String get moodCautionBody;

  /// No description provided for @moodStormTitle.
  ///
  /// In en, this message translates to:
  /// **'Storm Warning'**
  String get moodStormTitle;

  /// No description provided for @moodStormBody.
  ///
  /// In en, this message translates to:
  /// **'Fear is spreading through the market. Selling pressure is much stronger than buying, causing prices to fall quickly. Sharp declines can feel uncomfortable, but emotional decisions often make difficult days even worse.'**
  String get moodStormBody;

  /// No description provided for @watchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'WATCHLIST'**
  String get watchlistTitle;

  /// No description provided for @watchlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get watchlistEmpty;

  /// No description provided for @marketClockTitle.
  ///
  /// In en, this message translates to:
  /// **'MARKET CLOCK'**
  String get marketClockTitle;

  /// No description provided for @marketClockNewYorkTime.
  ///
  /// In en, this message translates to:
  /// **'NEW YORK TIME'**
  String get marketClockNewYorkTime;

  /// No description provided for @portfolioWidgetNoPortfolio.
  ///
  /// In en, this message translates to:
  /// **'No portfolio'**
  String get portfolioWidgetNoPortfolio;

  /// No description provided for @portfolioWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO'**
  String get portfolioWidgetTitle;

  /// No description provided for @portfolioBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO BALANCE'**
  String get portfolioBalanceLabel;

  /// No description provided for @portfolioCashLabel.
  ///
  /// In en, this message translates to:
  /// **'CASH AVAILABLE'**
  String get portfolioCashLabel;

  /// No description provided for @portfolioUnrealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'UNREALIZED P&L'**
  String get portfolioUnrealizedPnl;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get targetLabel;

  /// No description provided for @stressTestWidgetTitle.
  ///
  /// In en, this message translates to:
  /// **'MY STRESS TEST'**
  String get stressTestWidgetTitle;

  /// No description provided for @stressTestActiveTests.
  ///
  /// In en, this message translates to:
  /// **'Active Tests'**
  String get stressTestActiveTests;

  /// No description provided for @stressTestMyResults.
  ///
  /// In en, this message translates to:
  /// **'MY RESULTS'**
  String get stressTestMyResults;

  /// No description provided for @stressTestMoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'+{count} more completed'**
  String stressTestMoreCompleted(int count);

  /// No description provided for @stressTestNoActiveTests.
  ///
  /// In en, this message translates to:
  /// **'No active tests'**
  String get stressTestNoActiveTests;

  /// No description provided for @stressTestStartNewTest.
  ///
  /// In en, this message translates to:
  /// **'Start a new test from the bottom panel'**
  String get stressTestStartNewTest;

  /// No description provided for @stressTestGoPremium.
  ///
  /// In en, this message translates to:
  /// **'GO PREMIUM'**
  String get stressTestGoPremium;

  /// No description provided for @stressTestPremiumLowercase.
  ///
  /// In en, this message translates to:
  /// **'premium'**
  String get stressTestPremiumLowercase;

  /// No description provided for @stressTestActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active — {duration}'**
  String stressTestActiveLabel(String duration);

  /// No description provided for @stressTestHubTitle.
  ///
  /// In en, this message translates to:
  /// **'STRESS TEST'**
  String get stressTestHubTitle;

  /// No description provided for @stressTestCompletedTestsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed Tests'**
  String get stressTestCompletedTestsSheetTitle;

  /// No description provided for @stressTestActiveTestsTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TESTS'**
  String get stressTestActiveTestsTitle;

  /// No description provided for @stressTestCompletedTestsTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED TESTS'**
  String get stressTestCompletedTestsTitle;

  /// No description provided for @stressTestNoCompletedTestsYet.
  ///
  /// In en, this message translates to:
  /// **'No completed tests yet'**
  String get stressTestNoCompletedTestsYet;

  /// No description provided for @stressTestNoTestsYet.
  ///
  /// In en, this message translates to:
  /// **'No stress tests yet'**
  String get stressTestNoTestsYet;

  /// No description provided for @stressTestNoTestsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to start your first test'**
  String get stressTestNoTestsHint;

  /// No description provided for @stressTestNewTest.
  ///
  /// In en, this message translates to:
  /// **'New Stress Test'**
  String get stressTestNewTest;

  /// No description provided for @stressTestActiveCountFree.
  ///
  /// In en, this message translates to:
  /// **'{active}/{max} active · Premium = 5 at once'**
  String stressTestActiveCountFree(int active, int max);

  /// No description provided for @stressTestEmotionalResilience.
  ///
  /// In en, this message translates to:
  /// **'Test your emotional resilience'**
  String get stressTestEmotionalResilience;

  /// No description provided for @stressTestLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress test limit reached'**
  String get stressTestLimitReachedTitle;

  /// No description provided for @stressTestMaxSessionsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum active test sessions reached'**
  String get stressTestMaxSessionsReached;

  /// No description provided for @stressTestArchiveSummary.
  ///
  /// In en, this message translates to:
  /// **'Final: {amount} · {holdings} holdings · {trades} trades'**
  String stressTestArchiveSummary(String amount, int holdings, int trades);

  /// No description provided for @stressTestSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get stressTestSessionNotFound;

  /// No description provided for @stressTestSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress Test Setup'**
  String get stressTestSetupTitle;

  /// No description provided for @stressTestDurationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'TEST DURATION'**
  String get stressTestDurationSectionTitle;

  /// No description provided for @stressTestStartButton.
  ///
  /// In en, this message translates to:
  /// **'START STRESS TEST'**
  String get stressTestStartButton;

  /// No description provided for @stressTestSlot1Free.
  ///
  /// In en, this message translates to:
  /// **'Test slot 1/2 free · Upgrade for 5 at once & no ads'**
  String get stressTestSlot1Free;

  /// No description provided for @stressTestSlot2Free.
  ///
  /// In en, this message translates to:
  /// **'Test slot 2/2 free · Premium = 5 at once, no ads'**
  String get stressTestSlot2Free;

  /// No description provided for @stressTestAvailableCash.
  ///
  /// In en, this message translates to:
  /// **'Available Cash'**
  String get stressTestAvailableCash;

  /// No description provided for @stressTestOfTotal.
  ///
  /// In en, this message translates to:
  /// **'of {amount} total'**
  String stressTestOfTotal(String amount);

  /// No description provided for @stressTestCustomDays.
  ///
  /// In en, this message translates to:
  /// **'Custom ({days} days)'**
  String stressTestCustomDays(int days);

  /// No description provided for @stressTestInfiniteMinWeeks.
  ///
  /// In en, this message translates to:
  /// **'Infinite — Min. 2 weeks'**
  String get stressTestInfiniteMinWeeks;

  /// No description provided for @stressTestPremiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get stressTestPremiumFeatureTitle;

  /// No description provided for @stressTestPremiumFeatureBody.
  ///
  /// In en, this message translates to:
  /// **'This test duration is available exclusively to Premium subscribers. Upgrade to unlock unlimited possibilities.'**
  String get stressTestPremiumFeatureBody;

  /// No description provided for @stressTestUpgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get stressTestUpgradeToPremium;

  /// No description provided for @stressTestNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get stressTestNotNow;

  /// No description provided for @stressTestCustomDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Test Duration'**
  String get stressTestCustomDurationTitle;

  /// No description provided for @stressTestCustomDurationWarning.
  ///
  /// In en, this message translates to:
  /// **'Once started, a custom-duration test cannot be interrupted or stopped early. The simulation will run for the full period you select below.'**
  String get stressTestCustomDurationWarning;

  /// No description provided for @stressTestDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String stressTestDaysCount(int days);

  /// No description provided for @stressTestMinDays.
  ///
  /// In en, this message translates to:
  /// **'Min: 5 days'**
  String get stressTestMinDays;

  /// No description provided for @stressTestMaxDays.
  ///
  /// In en, this message translates to:
  /// **'Max: 365 days'**
  String get stressTestMaxDays;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @stressTestPremiumFeatureAllCaps.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM FEATURE'**
  String get stressTestPremiumFeatureAllCaps;

  /// No description provided for @stressTestRiskDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'RISK & SIMULATION DISCLAIMER'**
  String get stressTestRiskDisclaimerTitle;

  /// No description provided for @stressTestScrollToAgree.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the end to agree'**
  String get stressTestScrollToAgree;

  /// No description provided for @stressTestReadFullDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'You have read the full disclaimer'**
  String get stressTestReadFullDisclaimer;

  /// No description provided for @stressTestIAgreeStart.
  ///
  /// In en, this message translates to:
  /// **'I Agree — Start Test'**
  String get stressTestIAgreeStart;

  /// No description provided for @stressTestDisclaimerIntro.
  ///
  /// In en, this message translates to:
  /// **'This stress test uses a specialized algorithmic engine that simulates extreme market scenarios, including prolonged bear trends, systemic crises, and complete financial market collapses.'**
  String get stressTestDisclaimerIntro;

  /// No description provided for @stressTestDisclaimerAck.
  ///
  /// In en, this message translates to:
  /// **'Before starting the simulation, please read and acknowledge the following:'**
  String get stressTestDisclaimerAck;

  /// No description provided for @stressTestBulletScenarios.
  ///
  /// In en, this message translates to:
  /// **'Simulated Scenarios — The crashes, crises, and market movements generated by the engine are hypothetical mathematical models. They are designed to test portfolio resilience under stress and do not constitute a forecast of real market behavior.'**
  String get stressTestBulletScenarios;

  /// No description provided for @stressTestBulletNotAdvice.
  ///
  /// In en, this message translates to:
  /// **'Not Financial Advice — The final verdict, analytics, and any conclusions drawn from this test are for informational and educational purposes only. They do not constitute personalized investment advice, a recommendation to buy or sell assets, or any form of financial solicitation.'**
  String get stressTestBulletNotAdvice;

  /// No description provided for @stressTestBulletObjective.
  ///
  /// In en, this message translates to:
  /// **'Objective Mathematical Assessment — The final verdict and scoring are generated automatically. Our engine is built on recognized scientific methods (including Monte Carlo simulation, tail-risk analysis, and modern portfolio stress-testing models). The algorithm is fully independent: it eliminates human bias, emotion, or third-party commercial interests. However, it is important to remember that any mathematical model has its limitations and cannot predict absolutely every real-market scenario.'**
  String get stressTestBulletObjective;

  /// No description provided for @stressTestBulletLiability.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability — A positive test result (i.e., your portfolio successfully \"survived\" a simulated market crash) does not guarantee similar real-world performance. The platform and its developers assume no responsibility for your investment decisions, nor for any direct or indirect losses, including but not limited to loss of capital in real markets.'**
  String get stressTestBulletLiability;

  /// No description provided for @stressTestBulletPastPerformance.
  ///
  /// In en, this message translates to:
  /// **'Past performance within this simulator does not guarantee, predict, or reflect real-world market outcomes. All trading activities in real life carry substantial risk and are made solely at your own discretion and responsibility.'**
  String get stressTestBulletPastPerformance;

  /// No description provided for @stressTestEndOfDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'▸ End of Disclaimer'**
  String get stressTestEndOfDisclaimer;

  /// No description provided for @stressTestUnlimitedTesting.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Testing'**
  String get stressTestUnlimitedTesting;

  /// No description provided for @stressTestInfiniteUpsellBody.
  ///
  /// In en, this message translates to:
  /// **'The Infinite duration stress test is available exclusively to Premium subscribers. Upgrade to unlock:'**
  String get stressTestInfiniteUpsellBody;

  /// No description provided for @stressTestUpsellUnlimitedDuration.
  ///
  /// In en, this message translates to:
  /// **'Unlimited test duration'**
  String get stressTestUpsellUnlimitedDuration;

  /// No description provided for @stressTestUpsellFullCrashScenarios.
  ///
  /// In en, this message translates to:
  /// **'Full market crash scenarios'**
  String get stressTestUpsellFullCrashScenarios;

  /// No description provided for @stressTestUpsellAdvancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced portfolio analytics'**
  String get stressTestUpsellAdvancedAnalytics;

  /// No description provided for @stressTestAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Stress test access'**
  String get stressTestAccessTitle;

  /// No description provided for @stressTestPortfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'STRESS TEST PORTFOLIO'**
  String get stressTestPortfolioTitle;

  /// No description provided for @stressTestNotStartedYet.
  ///
  /// In en, this message translates to:
  /// **'Test not started yet'**
  String get stressTestNotStartedYet;

  /// No description provided for @stressTestGoBackToSetup.
  ///
  /// In en, this message translates to:
  /// **'Go back to setup and start the test'**
  String get stressTestGoBackToSetup;

  /// No description provided for @stressTestGoToSetup.
  ///
  /// In en, this message translates to:
  /// **'Go to Setup'**
  String get stressTestGoToSetup;

  /// No description provided for @stressTestStartBuildingPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Start Building Your Portfolio'**
  String get stressTestStartBuildingPortfolio;

  /// No description provided for @stressTestTapToAddFirstPosition.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to search stocks\nand add your first position.'**
  String get stressTestTapToAddFirstPosition;

  /// No description provided for @stressTestSearchStocksHint.
  ///
  /// In en, this message translates to:
  /// **'Search stocks to add...'**
  String get stressTestSearchStocksHint;

  /// No description provided for @stressTestGetVerdict.
  ///
  /// In en, this message translates to:
  /// **'GET PSYCHOLOGIST VERDICT'**
  String get stressTestGetVerdict;

  /// No description provided for @stressTestNoAssetsYet.
  ///
  /// In en, this message translates to:
  /// **'No assets yet'**
  String get stressTestNoAssetsYet;

  /// No description provided for @stressTestNoActivePositions.
  ///
  /// In en, this message translates to:
  /// **'No active positions'**
  String get stressTestNoActivePositions;

  /// No description provided for @stressTestTapToAddFirstAsset.
  ///
  /// In en, this message translates to:
  /// **'Tap + to search and add your first asset'**
  String get stressTestTapToAddFirstAsset;

  /// No description provided for @stressTestTapToBuyAssets.
  ///
  /// In en, this message translates to:
  /// **'Tap (+) to buy assets'**
  String get stressTestTapToBuyAssets;

  /// No description provided for @stressTestTestComplete.
  ///
  /// In en, this message translates to:
  /// **'Test Complete'**
  String get stressTestTestComplete;

  /// No description provided for @stressTestTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get stressTestTimeRemaining;

  /// No description provided for @stressTestElapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Elapsed Time'**
  String get stressTestElapsedTime;

  /// No description provided for @stressTestCountdown.
  ///
  /// In en, this message translates to:
  /// **'{days}d {hours}h {minutes}m {seconds}s'**
  String stressTestCountdown(
    String days,
    String hours,
    String minutes,
    String seconds,
  );

  /// No description provided for @stressTestEpochNumber.
  ///
  /// In en, this message translates to:
  /// **'Epoch #{number}'**
  String stressTestEpochNumber(int number);

  /// No description provided for @stressTestFinishTestButton.
  ///
  /// In en, this message translates to:
  /// **'FINISH TEST'**
  String get stressTestFinishTestButton;

  /// No description provided for @stressTestFinishTest.
  ///
  /// In en, this message translates to:
  /// **'Finish Test'**
  String get stressTestFinishTest;

  /// No description provided for @stressTestFinishTestConfirm.
  ///
  /// In en, this message translates to:
  /// **'End this test now and get your verdict? This can\'t be undone.'**
  String get stressTestFinishTestConfirm;

  /// No description provided for @stressTestFinalBalance.
  ///
  /// In en, this message translates to:
  /// **'FINAL BALANCE'**
  String get stressTestFinalBalance;

  /// No description provided for @stressTestViewVerdict.
  ///
  /// In en, this message translates to:
  /// **'VIEW PSYCHOLOGIST VERDICT'**
  String get stressTestViewVerdict;

  /// No description provided for @stressTestWidgetPortfolioBalance.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Balance'**
  String get stressTestWidgetPortfolioBalance;

  /// No description provided for @stressTestWidgetCashAvailable.
  ///
  /// In en, this message translates to:
  /// **'Cash Available'**
  String get stressTestWidgetCashAvailable;

  /// No description provided for @stressTestWidgetPsychologyMeter.
  ///
  /// In en, this message translates to:
  /// **'Psychology Meter'**
  String get stressTestWidgetPsychologyMeter;

  /// No description provided for @stressTestWidgetHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get stressTestWidgetHoldings;

  /// No description provided for @stressTestWidgetPriceChart.
  ///
  /// In en, this message translates to:
  /// **'Price Chart'**
  String get stressTestWidgetPriceChart;

  /// No description provided for @stressTestWidgetEpochs.
  ///
  /// In en, this message translates to:
  /// **'Epochs'**
  String get stressTestWidgetEpochs;

  /// No description provided for @stressTestWidgetTradeHistory.
  ///
  /// In en, this message translates to:
  /// **'Trade History'**
  String get stressTestWidgetTradeHistory;

  /// No description provided for @stressTestWidgetLimitOrders.
  ///
  /// In en, this message translates to:
  /// **'My Limit Orders'**
  String get stressTestWidgetLimitOrders;

  /// No description provided for @stressTestWidgetTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get stressTestWidgetTimer;

  /// No description provided for @stressTestInvestmentDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'INVESTMENT DISCLAIMER\n& LIMITATION OF LIABILITY'**
  String get stressTestInvestmentDisclaimerTitle;

  /// No description provided for @stressTestInvestmentDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This verdict is generated automatically by a mathematical model based solely on your simulated historical behavior within this closed testing environment. It is provided for educational and illustrative purposes only and does NOT constitute personalized investment, legal, or financial advice. Past performance within this simulator does not guarantee, predict, or reflect real-world market outcomes. Final financial decisions, asset purchases, or trading activities in real life carry substantial risk and are made solely at your own discretion and responsibility. The creators of F.O.M.O. Shield accept no liability for financial losses incurred in real-world trading.'**
  String get stressTestInvestmentDisclaimerBody;

  /// No description provided for @stressTestIUnderstandAccept.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Accept'**
  String get stressTestIUnderstandAccept;

  /// No description provided for @stressTestPsychologyMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'PSYCHOLOGY METER'**
  String get stressTestPsychologyMeterTitle;

  /// No description provided for @stressTestStrategyScore.
  ///
  /// In en, this message translates to:
  /// **'Strategy Score'**
  String get stressTestStrategyScore;

  /// No description provided for @stressTestPsychologyScore.
  ///
  /// In en, this message translates to:
  /// **'Psychology Score'**
  String get stressTestPsychologyScore;

  /// No description provided for @stressTestScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'SCORE'**
  String get stressTestScoreLabel;

  /// No description provided for @stressTestAnalyticsTotalTrades.
  ///
  /// In en, this message translates to:
  /// **'Total Trades'**
  String get stressTestAnalyticsTotalTrades;

  /// No description provided for @stressTestAnalyticsTradesBuy.
  ///
  /// In en, this message translates to:
  /// **'Trades Buy'**
  String get stressTestAnalyticsTradesBuy;

  /// No description provided for @stressTestAnalyticsTradesSell.
  ///
  /// In en, this message translates to:
  /// **'Trades Sell'**
  String get stressTestAnalyticsTradesSell;

  /// No description provided for @stressTestAnalyticsUnrealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Unrealized P&L'**
  String get stressTestAnalyticsUnrealizedPnl;

  /// No description provided for @stressTestAnalyticsRealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L'**
  String get stressTestAnalyticsRealizedPnl;

  /// No description provided for @stressTestPriceChartTitle.
  ///
  /// In en, this message translates to:
  /// **'PRICE CHART'**
  String get stressTestPriceChartTitle;

  /// No description provided for @stressTestChartNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get stressTestChartNotEnoughData;

  /// No description provided for @stressTestChartNotEnoughDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for this period'**
  String get stressTestChartNotEnoughDataForPeriod;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'SEARCH'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search ticker or company...'**
  String get searchHint;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get searchNoResults;

  /// No description provided for @searchApiExhausted.
  ///
  /// In en, this message translates to:
  /// **'The API key may be exhausted. Try again shortly.'**
  String get searchApiExhausted;

  /// No description provided for @searchErrorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check your internet.'**
  String get searchErrorConnectionTimeout;

  /// No description provided for @searchErrorServerNotResponding.
  ///
  /// In en, this message translates to:
  /// **'Server not responding. Try again.'**
  String get searchErrorServerNotResponding;

  /// No description provided for @searchErrorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get searchErrorNoInternet;

  /// No description provided for @searchErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'API limit reached. Please try again later.'**
  String get searchErrorRateLimited;

  /// No description provided for @searchErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load results. Try again.'**
  String get searchErrorGeneric;

  /// No description provided for @searchTopSp500.
  ///
  /// In en, this message translates to:
  /// **'TOP S&P 500'**
  String get searchTopSp500;

  /// No description provided for @searchRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY VIEWED'**
  String get searchRecentlyViewed;

  /// No description provided for @searchTopCompaniesBuilding.
  ///
  /// In en, this message translates to:
  /// **'Top companies list is still being built on the server.'**
  String get searchTopCompaniesBuilding;

  /// No description provided for @searchTopCompaniesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load top companies. Pull to retry shortly.'**
  String get searchTopCompaniesLoadError;

  /// No description provided for @portfolioRenameMenu.
  ///
  /// In en, this message translates to:
  /// **'Rename Portfolio'**
  String get portfolioRenameMenu;

  /// No description provided for @portfolioResetMenu.
  ///
  /// In en, this message translates to:
  /// **'Reset Portfolio'**
  String get portfolioResetMenu;

  /// No description provided for @portfolioDeleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete Portfolio'**
  String get portfolioDeleteMenu;

  /// No description provided for @portfolioNoPortfoliosYet.
  ///
  /// In en, this message translates to:
  /// **'No portfolios yet'**
  String get portfolioNoPortfoliosYet;

  /// No description provided for @portfolioCreateFirstMsg.
  ///
  /// In en, this message translates to:
  /// **'Create your first virtual portfolio\nwith {amount} starting balance'**
  String portfolioCreateFirstMsg(String amount);

  /// No description provided for @portfolioCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create Portfolio'**
  String get portfolioCreateButton;

  /// No description provided for @portfolioNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tech Growth'**
  String get portfolioNameHint;

  /// No description provided for @portfolioSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get portfolioSave;

  /// No description provided for @portfolioResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Portfolio?'**
  String get portfolioResetDialogTitle;

  /// No description provided for @portfolioResetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'All holdings and history will be cleared.\nBalance will be restored to its original amount.'**
  String get portfolioResetDialogBody;

  /// No description provided for @portfolioDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Portfolio?'**
  String get portfolioDeleteDialogTitle;

  /// No description provided for @portfolioDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'All holdings and history will be lost.'**
  String get portfolioDeleteDialogBody;

  /// No description provided for @portfolioCannotDeleteLast.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete the last portfolio. Create a new one first.'**
  String get portfolioCannotDeleteLast;

  /// No description provided for @portfolioNewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Portfolio'**
  String get portfolioNewDialogTitle;

  /// No description provided for @portfolioFreeLimitOne.
  ///
  /// In en, this message translates to:
  /// **'FREE limit: 1 portfolio. Upgrade to Premium (3).'**
  String get portfolioFreeLimitOne;

  /// No description provided for @portfolioMaxReached.
  ///
  /// In en, this message translates to:
  /// **'Max {max} portfolios reached.'**
  String portfolioMaxReached(int max);

  /// No description provided for @portfolioCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get portfolioCreate;

  /// No description provided for @portfolioAdditionalPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Additional portfolio'**
  String get portfolioAdditionalPromoTitle;

  /// No description provided for @portfolioSwitchedPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio switched'**
  String get portfolioSwitchedPromoTitle;

  /// No description provided for @portfolioCreateNewSlot.
  ///
  /// In en, this message translates to:
  /// **'Create New Portfolio'**
  String get portfolioCreateNewSlot;

  /// No description provided for @commonFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get commonFailedToLoad;

  /// No description provided for @commonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get commonOther;

  /// No description provided for @commonLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get commonLess;

  /// No description provided for @commonMoreCount.
  ///
  /// In en, this message translates to:
  /// **'More ({count})'**
  String commonMoreCount(int count);

  /// No description provided for @balanceRingLabel.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get balanceRingLabel;

  /// No description provided for @targetGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'GOAL'**
  String get targetGoalLabel;

  /// No description provided for @targetLeftToGoal.
  ///
  /// In en, this message translates to:
  /// **'LEFT TO GOAL'**
  String get targetLeftToGoal;

  /// No description provided for @targetChangeGoal.
  ///
  /// In en, this message translates to:
  /// **'Change Goal'**
  String get targetChangeGoal;

  /// No description provided for @targetSelectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select Goal'**
  String get targetSelectGoal;

  /// No description provided for @holdingsTitle.
  ///
  /// In en, this message translates to:
  /// **'HOLDINGS'**
  String get holdingsTitle;

  /// No description provided for @holdingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No holdings yet'**
  String get holdingsEmpty;

  /// No description provided for @holdingsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to search and add your first holding'**
  String get holdingsEmptyHint;

  /// No description provided for @sharesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shares'**
  String sharesCount(String count);

  /// No description provided for @tradeHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'TRADE HISTORY'**
  String get tradeHistoryTitle;

  /// No description provided for @myLimitOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'MY LIMIT ORDERS'**
  String get myLimitOrdersTitle;

  /// No description provided for @myLimitOrdersSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'My Limit Orders'**
  String get myLimitOrdersSheetTitle;

  /// No description provided for @myLimitOrdersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You currently have no active orders'**
  String get myLimitOrdersEmpty;

  /// No description provided for @myLimitOrdersSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all {count} orders'**
  String myLimitOrdersSeeAll(int count);

  /// No description provided for @gicsSectorTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get gicsSectorTechnology;

  /// No description provided for @gicsSectorFinancials.
  ///
  /// In en, this message translates to:
  /// **'Financials'**
  String get gicsSectorFinancials;

  /// No description provided for @gicsSectorHealthCare.
  ///
  /// In en, this message translates to:
  /// **'Health Care'**
  String get gicsSectorHealthCare;

  /// No description provided for @gicsSectorConsumerDiscretionary.
  ///
  /// In en, this message translates to:
  /// **'Consumer Discretionary'**
  String get gicsSectorConsumerDiscretionary;

  /// No description provided for @gicsSectorConsumerStaples.
  ///
  /// In en, this message translates to:
  /// **'Consumer Staples'**
  String get gicsSectorConsumerStaples;

  /// No description provided for @gicsSectorEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get gicsSectorEnergy;

  /// No description provided for @gicsSectorIndustrials.
  ///
  /// In en, this message translates to:
  /// **'Industrials'**
  String get gicsSectorIndustrials;

  /// No description provided for @gicsSectorMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get gicsSectorMaterials;

  /// No description provided for @gicsSectorCommunicationServices.
  ///
  /// In en, this message translates to:
  /// **'Communication Services'**
  String get gicsSectorCommunicationServices;

  /// No description provided for @gicsSectorRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get gicsSectorRealEstate;

  /// No description provided for @gicsSectorUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get gicsSectorUtilities;

  /// No description provided for @testDuration1Week.
  ///
  /// In en, this message translates to:
  /// **'1 Week'**
  String get testDuration1Week;

  /// No description provided for @testDuration1Month.
  ///
  /// In en, this message translates to:
  /// **'1 Month'**
  String get testDuration1Month;

  /// No description provided for @testDuration3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get testDuration3Months;

  /// No description provided for @testDurationInfinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get testDurationInfinite;

  /// No description provided for @testDurationCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get testDurationCustom;

  /// No description provided for @stressTestAddAsset.
  ///
  /// In en, this message translates to:
  /// **'Add Asset'**
  String get stressTestAddAsset;

  /// No description provided for @stressTestConfirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get stressTestConfirmPurchase;

  /// No description provided for @stressTestSearchCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Search company (e.g. Apple, Cola)...'**
  String get stressTestSearchCompanyHint;

  /// No description provided for @stressTestSearchFailedError.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check your connection.'**
  String get stressTestSearchFailedError;

  /// No description provided for @stressTestTypeMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search'**
  String get stressTestTypeMinChars;

  /// No description provided for @stressTestNoResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get stressTestNoResultsFound;

  /// No description provided for @stressTestNoPriceData.
  ///
  /// In en, this message translates to:
  /// **'No price data available for {symbol}.'**
  String stressTestNoPriceData(String symbol);

  /// No description provided for @stressTestFetchPriceError.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch price for {symbol}.'**
  String stressTestFetchPriceError(String symbol);

  /// No description provided for @stressTestNotEnoughCashError.
  ///
  /// In en, this message translates to:
  /// **'Not enough cash or unable to trade.'**
  String get stressTestNotEnoughCashError;

  /// No description provided for @stressTestCurrentPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current price: {price}'**
  String stressTestCurrentPriceLabel(String price);

  /// No description provided for @stressTestHowMuchInvest.
  ///
  /// In en, this message translates to:
  /// **'How much do you want to invest?'**
  String get stressTestHowMuchInvest;

  /// No description provided for @stressTestExceedsCash.
  ///
  /// In en, this message translates to:
  /// **'Exceeds available cash ({cash})'**
  String stressTestExceedsCash(String cash);

  /// No description provided for @stressTestBuyAmountWorth.
  ///
  /// In en, this message translates to:
  /// **'Buy {amount} worth'**
  String stressTestBuyAmountWorth(String amount);

  /// No description provided for @stressTestChooseAnotherCompany.
  ///
  /// In en, this message translates to:
  /// **'Choose another company'**
  String get stressTestChooseAnotherCompany;

  /// No description provided for @verdictTradeBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'TRADE BREAKDOWN'**
  String get verdictTradeBreakdownTitle;

  /// No description provided for @verdictSessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get verdictSessionNotFound;

  /// No description provided for @verdictTestDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Test Duration'**
  String get verdictTestDurationLabel;

  /// No description provided for @verdictDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String verdictDurationDays(int days);

  /// No description provided for @verdictStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get verdictStatisticsTitle;

  /// No description provided for @verdictTotalTradesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Trades'**
  String get verdictTotalTradesLabel;

  /// No description provided for @verdictBoughtLabel.
  ///
  /// In en, this message translates to:
  /// **'Bought'**
  String get verdictBoughtLabel;

  /// No description provided for @verdictSoldLabel.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get verdictSoldLabel;

  /// No description provided for @verdictTotalAssetsTitle.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ASSETS'**
  String get verdictTotalAssetsTitle;

  /// No description provided for @verdictAssetsHeldTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Assets Held (Total)'**
  String get verdictAssetsHeldTotalLabel;

  /// No description provided for @verdictAssetsAtEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Assets at Test End'**
  String get verdictAssetsAtEndLabel;

  /// No description provided for @verdictFinancialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'FINANCIAL SUMMARY'**
  String get verdictFinancialSummaryTitle;

  /// No description provided for @verdictStartingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Amount'**
  String get verdictStartingAmountLabel;

  /// No description provided for @verdictTotalPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Total P&L (Realized + Unrealized)'**
  String get verdictTotalPnlLabel;

  /// No description provided for @verdictProfitableSellsLabel.
  ///
  /// In en, this message translates to:
  /// **'Profitable Sells ({count})'**
  String verdictProfitableSellsLabel(int count);

  /// No description provided for @verdictLosingSellsLabel.
  ///
  /// In en, this message translates to:
  /// **'Losing Sells ({count})'**
  String verdictLosingSellsLabel(int count);

  /// No description provided for @verdictFinalBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Balance'**
  String get verdictFinalBalanceLabel;

  /// No description provided for @verdictScenariosTitle.
  ///
  /// In en, this message translates to:
  /// **'SCENARIOS EXPERIENCED'**
  String get verdictScenariosTitle;

  /// No description provided for @verdictScenarioBull.
  ///
  /// In en, this message translates to:
  /// **'Bull Trend'**
  String get verdictScenarioBull;

  /// No description provided for @verdictScenarioBear.
  ///
  /// In en, this message translates to:
  /// **'Bear Trend'**
  String get verdictScenarioBear;

  /// No description provided for @verdictScenarioSideways.
  ///
  /// In en, this message translates to:
  /// **'Sideways Market'**
  String get verdictScenarioSideways;

  /// No description provided for @verdictScenarioVolatility.
  ///
  /// In en, this message translates to:
  /// **'Volatility'**
  String get verdictScenarioVolatility;

  /// No description provided for @verdictScenarioRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery'**
  String get verdictScenarioRecovery;

  /// No description provided for @verdictScenarioHype.
  ///
  /// In en, this message translates to:
  /// **'Market Hype'**
  String get verdictScenarioHype;

  /// No description provided for @verdictScenarioSpeculation.
  ///
  /// In en, this message translates to:
  /// **'Speculation'**
  String get verdictScenarioSpeculation;

  /// No description provided for @verdictScenarioBlackSwan.
  ///
  /// In en, this message translates to:
  /// **'Black Swan'**
  String get verdictScenarioBlackSwan;

  /// No description provided for @verdictScenarioCrash.
  ///
  /// In en, this message translates to:
  /// **'Crash'**
  String get verdictScenarioCrash;

  /// No description provided for @verdictCompaniesTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPANIES'**
  String get verdictCompaniesTitle;

  /// No description provided for @verdictNoCompaniesTraded.
  ///
  /// In en, this message translates to:
  /// **'No companies traded.'**
  String get verdictNoCompaniesTraded;

  /// No description provided for @verdictNoTradesYet.
  ///
  /// In en, this message translates to:
  /// **'No trades yet.'**
  String get verdictNoTradesYet;

  /// No description provided for @verdictTradeBreakdownDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get verdictTradeBreakdownDisclaimerTitle;

  /// No description provided for @verdictTradeBreakdownDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'The results of this stress test are solely the results of a computer-generated simulation and are provided for educational and training purposes only. They are based on model-defined scenarios and historical market events and do not represent, predict, or guarantee the performance of any portfolio under real-world market conditions.\n\nActual market behavior, individual companies, and financial assets may differ substantially from the results of the simulation. Past market events and performance do not guarantee similar outcomes in the future.\n\nAny scores, ratings, verdicts, or other indicators presented in the test do not constitute investment, financial, or other professional advice, nor do they constitute a recommendation, offer, or solicitation to buy or sell any financial asset or serve as a basis for making investment decisions.\n\nAny decision made using or taking into account information provided by the application is made solely at the user\'s own discretion and risk. We do not guarantee profits and are not responsible for any financial losses, damages, or lost profits resulting from the use of the simulation or its results.\n\nThe purpose of the stress test is to help users learn about market scenarios, investment principles, and their own behavior in a simulated environment — not to predict the future.'**
  String get verdictTradeBreakdownDisclaimerBody;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @watchlistLimitFree.
  ///
  /// In en, this message translates to:
  /// **'FREE limit: 30 companies. Upgrade to Premium (50).'**
  String get watchlistLimitFree;

  /// No description provided for @watchlistLimitMax.
  ///
  /// In en, this message translates to:
  /// **'Max {max} companies reached.'**
  String watchlistLimitMax(int max);

  /// No description provided for @companyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'COMPANY OVERVIEW'**
  String get companyDetailTitle;

  /// No description provided for @companyDetailSponsoredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsored content'**
  String get companyDetailSponsoredTitle;

  /// No description provided for @companyDetailWatchAdBody.
  ///
  /// In en, this message translates to:
  /// **'Please watch a short ad to continue viewing company details.'**
  String get companyDetailWatchAdBody;

  /// No description provided for @companyDetailWatchAdButton.
  ///
  /// In en, this message translates to:
  /// **'Watch 3s Ad'**
  String get companyDetailWatchAdButton;

  /// No description provided for @companyDetailUpgradeNoAds.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium — no ads'**
  String get companyDetailUpgradeNoAds;

  /// No description provided for @companyDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load company data'**
  String get companyDetailLoadError;

  /// No description provided for @companyDetailLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The market data API may be temporarily unavailable. Please try again.'**
  String get companyDetailLoadErrorBody;

  /// No description provided for @companyDetailNoPortfolios.
  ///
  /// In en, this message translates to:
  /// **'No portfolios yet. Create one first.'**
  String get companyDetailNoPortfolios;

  /// No description provided for @companyDetailSelectPortfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Portfolio'**
  String get companyDetailSelectPortfolioTitle;

  /// No description provided for @companyDetailSelectPortfolioBodyBuy.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to buy {symbol}?'**
  String companyDetailSelectPortfolioBodyBuy(String symbol);

  /// No description provided for @companyDetailSelectPortfolioBodySell.
  ///
  /// In en, this message translates to:
  /// **'Where do you want to sell {symbol}?'**
  String companyDetailSelectPortfolioBodySell(String symbol);

  /// No description provided for @companyDetailChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'CHANGE'**
  String get companyDetailChangeLabel;

  /// No description provided for @companyDetailChangePeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'CHANGE ({period})'**
  String companyDetailChangePeriodLabel(String period);

  /// No description provided for @commonNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNotAvailable;

  /// No description provided for @companyDetailKeyMetricsTitle.
  ///
  /// In en, this message translates to:
  /// **'KEY METRICS'**
  String get companyDetailKeyMetricsTitle;

  /// No description provided for @companyDetailMetricPe.
  ///
  /// In en, this message translates to:
  /// **'P/E'**
  String get companyDetailMetricPe;

  /// No description provided for @companyDetailMetricDividendYield.
  ///
  /// In en, this message translates to:
  /// **'Dividend Yield'**
  String get companyDetailMetricDividendYield;

  /// No description provided for @companyDetailMetricNetMargin.
  ///
  /// In en, this message translates to:
  /// **'Net Margin'**
  String get companyDetailMetricNetMargin;

  /// No description provided for @companyDetailMetricOperatingMargin.
  ///
  /// In en, this message translates to:
  /// **'Operating Margin'**
  String get companyDetailMetricOperatingMargin;

  /// No description provided for @companyDetailMetricGrossMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross Margin'**
  String get companyDetailMetricGrossMargin;

  /// No description provided for @companyDetailMetricRoe.
  ///
  /// In en, this message translates to:
  /// **'ROE'**
  String get companyDetailMetricRoe;

  /// No description provided for @companyDetailPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get companyDetailPriceLabel;

  /// No description provided for @companyDetailFsScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'FS SCORE'**
  String get companyDetailFsScoreLabel;

  /// No description provided for @companyDetailPhasePreMarket.
  ///
  /// In en, this message translates to:
  /// **'PRE-MARKET'**
  String get companyDetailPhasePreMarket;

  /// No description provided for @companyDetailPhaseMarketOpen.
  ///
  /// In en, this message translates to:
  /// **'MARKET OPEN'**
  String get companyDetailPhaseMarketOpen;

  /// No description provided for @companyDetailPhasePostMarket.
  ///
  /// In en, this message translates to:
  /// **'POST-MARKET'**
  String get companyDetailPhasePostMarket;

  /// No description provided for @companyDetailPhaseMarketClosed.
  ///
  /// In en, this message translates to:
  /// **'MARKET CLOSED'**
  String get companyDetailPhaseMarketClosed;

  /// No description provided for @companyDetailPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'MY INVESTMENTS'**
  String get companyDetailPositionTitle;

  /// No description provided for @companyDetailAssetValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset Value'**
  String get companyDetailAssetValueLabel;

  /// No description provided for @companyDetailSharesLabel.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get companyDetailSharesLabel;

  /// No description provided for @companyDetailAvgCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg Cost'**
  String get companyDetailAvgCostLabel;

  /// No description provided for @companyDetailLimitOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'LIMIT ORDERS'**
  String get companyDetailLimitOrdersTitle;

  /// No description provided for @companyDetailSymbolLimitOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol} Limit Orders'**
  String companyDetailSymbolLimitOrdersTitle(String symbol);

  /// No description provided for @companyDetailDividendTrapPenalty.
  ///
  /// In en, this message translates to:
  /// **'Dividend trap penalty: -{pts} pts'**
  String companyDetailDividendTrapPenalty(int pts);

  /// No description provided for @companyDetailCatastrophicLossPenalty.
  ///
  /// In en, this message translates to:
  /// **'Catastrophic loss penalty: -{pts} pts (net margin below -100%)'**
  String companyDetailCatastrophicLossPenalty(int pts);

  /// No description provided for @companyDetailLegalDisclaimerMethodology.
  ///
  /// In en, this message translates to:
  /// **'Legal Disclaimer & Methodology'**
  String get companyDetailLegalDisclaimerMethodology;

  /// No description provided for @companyDetailMarkerValuation.
  ///
  /// In en, this message translates to:
  /// **'Valuation'**
  String get companyDetailMarkerValuation;

  /// No description provided for @companyDetailMarkerFinancialHealth.
  ///
  /// In en, this message translates to:
  /// **'Financial Health'**
  String get companyDetailMarkerFinancialHealth;

  /// No description provided for @companyDetailMarkerGrowthPotential.
  ///
  /// In en, this message translates to:
  /// **'Growth Potential'**
  String get companyDetailMarkerGrowthPotential;

  /// No description provided for @companyDetailMarkerEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get companyDetailMarkerEfficiency;

  /// No description provided for @companyDetailMarkerHistoricalTrend.
  ///
  /// In en, this message translates to:
  /// **'Historical Trend'**
  String get companyDetailMarkerHistoricalTrend;

  /// No description provided for @companyDetailMarkerShareholderReturns.
  ///
  /// In en, this message translates to:
  /// **'Shareholder Returns'**
  String get companyDetailMarkerShareholderReturns;

  /// No description provided for @companyDetailMarkerDescValuation.
  ///
  /// In en, this message translates to:
  /// **'P/E vs sector average'**
  String get companyDetailMarkerDescValuation;

  /// No description provided for @companyDetailMarkerDescFinancialHealth.
  ///
  /// In en, this message translates to:
  /// **'Debt/Equity ratio'**
  String get companyDetailMarkerDescFinancialHealth;

  /// No description provided for @companyDetailMarkerDescGrowth.
  ///
  /// In en, this message translates to:
  /// **'Revenue & EPS 5Y growth'**
  String get companyDetailMarkerDescGrowth;

  /// No description provided for @companyDetailMarkerDescEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Net margin & ROE'**
  String get companyDetailMarkerDescEfficiency;

  /// No description provided for @companyDetailMarkerDescHistoricalTrend.
  ///
  /// In en, this message translates to:
  /// **'5Y share price CAGR'**
  String get companyDetailMarkerDescHistoricalTrend;

  /// No description provided for @companyDetailMarkerDescShareholderReturns.
  ///
  /// In en, this message translates to:
  /// **'Dividends & buybacks'**
  String get companyDetailMarkerDescShareholderReturns;

  /// No description provided for @companyDetailRatingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get companyDetailRatingExcellent;

  /// No description provided for @companyDetailRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get companyDetailRatingGood;

  /// No description provided for @companyDetailRatingAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get companyDetailRatingAverage;

  /// No description provided for @companyDetailRatingWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get companyDetailRatingWeak;

  /// No description provided for @companyDetailRatingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get companyDetailRatingPoor;

  /// No description provided for @companyWidgetPriceHeader.
  ///
  /// In en, this message translates to:
  /// **'Price & Header'**
  String get companyWidgetPriceHeader;

  /// No description provided for @companyWidgetKeyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key Metrics'**
  String get companyWidgetKeyMetrics;

  /// No description provided for @companyWidgetFinancialScore.
  ///
  /// In en, this message translates to:
  /// **'Financial Score'**
  String get companyWidgetFinancialScore;

  /// No description provided for @companyWidgetPosition.
  ///
  /// In en, this message translates to:
  /// **'Your Position'**
  String get companyWidgetPosition;

  /// No description provided for @companyWidgetLimitOrders.
  ///
  /// In en, this message translates to:
  /// **'Limit Orders'**
  String get companyWidgetLimitOrders;

  /// No description provided for @companyDetailCashAvailable.
  ///
  /// In en, this message translates to:
  /// **'{cash} available'**
  String companyDetailCashAvailable(String cash);

  /// No description provided for @companyDetailAcademicDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Educational & Academic Disclaimer'**
  String get companyDetailAcademicDisclaimerTitle;

  /// No description provided for @companyDetailAcademicDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'The methodology, definitions, and analytical principles presented here are based on standard corporate finance theory and valuation frameworks taught in leading business schools. Provided strictly for educational purposes.'**
  String get companyDetailAcademicDisclaimerBody;

  /// No description provided for @companyDetailAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Sponsored Ad'**
  String get companyDetailAdTitle;

  /// No description provided for @companyDetailAdContinuing.
  ///
  /// In en, this message translates to:
  /// **'Continuing in a moment…'**
  String get companyDetailAdContinuing;

  /// No description provided for @companyDetailNoPriceDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No price data available'**
  String get companyDetailNoPriceDataAvailable;

  /// No description provided for @companyDetailChartLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chart'**
  String get companyDetailChartLoadError;

  /// No description provided for @companyDetailChartNotEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data'**
  String get companyDetailChartNotEnoughData;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @orderEntryTabMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get orderEntryTabMarket;

  /// No description provided for @orderEntryTabLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get orderEntryTabLimit;

  /// No description provided for @orderEntryExtendedHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Extended Hours'**
  String get orderEntryExtendedHoursTitle;

  /// No description provided for @orderEntryExtendedHoursSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off: trade only while the real market is open'**
  String get orderEntryExtendedHoursSubtitle;

  /// No description provided for @orderEntrySimulatedDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Simulated Trading & Non-Brokerage Disclaimer'**
  String get orderEntrySimulatedDisclaimerTitle;

  /// No description provided for @orderEntrySimulatedDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This application is not a registered broker-dealer, investment advisor, or financial institution, and does not provide order execution services for real financial markets.\n\nAll buy and sell operations are performed exclusively on a simulated account using virtual currency (Paper Trading). Transactions executed within this app are intended solely for educational purposes, do not result in the purchase or ownership of actual securities, create no shareholder rights, and carry no real-world financial or legal force.'**
  String get orderEntrySimulatedDisclaimerBody;

  /// No description provided for @orderEntryUnitUsd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get orderEntryUnitUsd;

  /// No description provided for @orderEntryUnitShares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get orderEntryUnitShares;

  /// No description provided for @orderEntryApproxShares.
  ///
  /// In en, this message translates to:
  /// **'≈ {shares} shares'**
  String orderEntryApproxShares(String shares);

  /// No description provided for @orderEntryLimitPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'LIMIT PRICE'**
  String get orderEntryLimitPriceTitle;

  /// No description provided for @orderEntryLimitPriceHintBuy.
  ///
  /// In en, this message translates to:
  /// **'Choose a price below the current price for Buy orders'**
  String get orderEntryLimitPriceHintBuy;

  /// No description provided for @orderEntryLimitPriceHintSell.
  ///
  /// In en, this message translates to:
  /// **'Choose a price above the current price for Sell orders'**
  String get orderEntryLimitPriceHintSell;

  /// No description provided for @orderEntryCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost:'**
  String get orderEntryCostLabel;

  /// No description provided for @orderEntryQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty:'**
  String get orderEntryQtyLabel;

  /// No description provided for @orderEntrySharesAbbrev.
  ///
  /// In en, this message translates to:
  /// **'{shares} sh.'**
  String orderEntrySharesAbbrev(String shares);

  /// No description provided for @orderEntryPlaceOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get orderEntryPlaceOrder;

  /// No description provided for @orderEntryMarketClosedTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Closed'**
  String get orderEntryMarketClosedTitle;

  /// No description provided for @orderEntryMarketClosedBody.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the market is currently closed, so Market orders can\'t be filled right now.\n\nYou can still place a Limit order — it will wait and execute once the market reopens. Or turn on Extended Hours to trade around the clock.'**
  String get orderEntryMarketClosedBody;

  /// No description provided for @orderEntryPlaceLimitInstead.
  ///
  /// In en, this message translates to:
  /// **'Place Limit Order Instead'**
  String get orderEntryPlaceLimitInstead;

  /// No description provided for @orderEntryEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get orderEntryEnterAmount;

  /// No description provided for @orderEntryInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Invalid quantity'**
  String get orderEntryInvalidQuantity;

  /// No description provided for @orderEntryEnterValidLimitPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid limit price'**
  String get orderEntryEnterValidLimitPrice;

  /// No description provided for @orderEntryNotEnoughCash.
  ///
  /// In en, this message translates to:
  /// **'Not enough available cash — {cash} free (some is reserved for pending orders)'**
  String orderEntryNotEnoughCash(String cash);

  /// No description provided for @orderEntryInfoMarket.
  ///
  /// In en, this message translates to:
  /// **'Market orders execute at the best available price. Execution is guaranteed, but the final price may differ from expectations.'**
  String get orderEntryInfoMarket;

  /// No description provided for @orderEntryInfoLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit orders execute only at the specified price or better. Partial or full execution is not guaranteed.'**
  String get orderEntryInfoLimit;

  /// No description provided for @orderEntryInfoStop.
  ///
  /// In en, this message translates to:
  /// **'Stop orders activate when the stop price is reached, then execute as a market order.'**
  String get orderEntryInfoStop;

  /// No description provided for @orderEntryInfoStopLimit.
  ///
  /// In en, this message translates to:
  /// **'Stop-limit orders activate when the stop price is reached, then execute as a limit order.'**
  String get orderEntryInfoStopLimit;

  /// No description provided for @stressTestOrderInfoMarket.
  ///
  /// In en, this message translates to:
  /// **'Market orders execute at the best available simulated price. Execution is guaranteed, but the final price may differ from expectations.'**
  String get stressTestOrderInfoMarket;

  /// No description provided for @stressTestOrderInfoLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit orders execute only once the simulated price reaches your chosen price or better. Execution is not guaranteed.'**
  String get stressTestOrderInfoLimit;

  /// No description provided for @orderEntryHoldingsLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get orderEntryHoldingsLimitTitle;

  /// No description provided for @orderEntryHoldingsLimitBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded the allowed limit on asset purchases for this portfolio ({max} companies).'**
  String orderEntryHoldingsLimitBody(int max);

  /// No description provided for @orderEntryHoldingsLimitPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Portfolio holding limit reached'**
  String get orderEntryHoldingsLimitPromoTitle;

  /// No description provided for @orderEntryPriceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the current price'**
  String get orderEntryPriceLoadError;

  /// No description provided for @companyDetailDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Educational Purpose & Legal Disclaimer'**
  String get companyDetailDisclaimerTitle;

  /// No description provided for @companyDetailDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This application operates strictly as an educational simulator designed to help users learn how to analyze and understand business fundamentals. Evaluation scores and analytics are derived from public corporate financial filings, as well as academic frameworks from leading universities and established financial literacy textbooks.\n\nDisplayed market prices and metrics may be delayed, estimated, or differ from live exchange prices. Content within this app does not constitute a solicitation, recommendation, or offer to buy or sell any financial security. All trading decisions are made solely and independently by the user. The developers do not provide financial services and bear no liability for any potential lost profits, financial losses, or loss of real-world capital.\n\nContinued use of this application constitutes your full acknowledgment and acceptance of this disclaimer, including the release of developers from any liability. Failure to read this disclaimer does not exempt the user from compliance nor provide grounds for any claims, disputes, or legal actions.'**
  String get companyDetailDisclaimerBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
