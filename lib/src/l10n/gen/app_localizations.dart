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

  /// No description provided for @verdictCashBufferNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Cash Data Yet'**
  String get verdictCashBufferNoDataTitle;

  /// No description provided for @verdictCashBufferNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any positions — there\'s no cash buffer to measure yet.'**
  String get verdictCashBufferNoDataIntro;

  /// No description provided for @verdictCashBufferTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Fully Invested'**
  String get verdictCashBufferTier1Title;

  /// No description provided for @verdictCashBufferTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Every dollar in your portfolio is currently invested.\n\nAt first glance, that may sound like the ideal strategy.\n\nAfter all, invested money has the potential to grow, while cash sitting on the sidelines does not.\n\nBut investing isn\'t only about maximizing returns.\n\nIt\'s also about being prepared for opportunities.\n\nWithout a cash reserve, your portfolio has very little flexibility.\n\nIf the market suddenly experiences a sharp correction, an outstanding company becomes deeply undervalued, or an unexpected opportunity appears, you may have no capital available to act.\n\nInstead of buying when prices become more attractive, you\'re forced to watch from the sidelines—or sell existing investments to free up cash.\n\nNeither is an ideal position.\n\nCash is often misunderstood.\n\nSome investors see it as \"money doing nothing.\"\n\nExperienced investors often see it as money waiting for the right opportunity.\n\nA cash buffer isn\'t there to outperform the market.\n\nIt\'s there to give you choices when the market becomes unpredictable.'**
  String get verdictCashBufferTier1Intro;

  /// No description provided for @verdictCashBufferTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictCashBufferTier1Section1Label;

  /// No description provided for @verdictCashBufferTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Consider keeping a small portion of your portfolio in cash instead of investing every available dollar immediately.\n\nYou don\'t need a large reserve.\n\nEven a modest cash buffer can provide valuable flexibility during periods of market volatility.\n\nWhen attractive opportunities appear, you\'ll be able to act with confidence rather than regret missing them.\n\nThink of cash as part of your investment strategy—not as money that has failed to find a job.\n\nSometimes the smartest investment decision is simply being ready for the next one.'**
  String get verdictCashBufferTier1Section1Body;

  /// No description provided for @verdictCashBufferTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictCashBufferTier1Section2Label;

  /// No description provided for @verdictCashBufferTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Being fully invested may feel productive.\n\nBeing prepared is often even more valuable.\n\nCash doesn\'t exist to maximize today\'s returns. It exists to give you the freedom to invest when tomorrow\'s opportunities arrive.'**
  String get verdictCashBufferTier1Section2Body;

  /// No description provided for @verdictCashBufferTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Very Limited Flexibility'**
  String get verdictCashBufferTier2Title;

  /// No description provided for @verdictCashBufferTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio includes a small cash reserve, which is a step in the right direction.\n\nHowever, your available cash is still quite limited.\n\nIt may be enough to make a small purchase, but probably not enough to take full advantage of a meaningful market correction or a rare investment opportunity.\n\nOne of the biggest advantages of holding cash isn\'t earning a return.\n\nIt\'s having the ability to act when others cannot.\n\nMarkets don\'t announce when the next opportunity is coming.\n\nA strong company can become temporarily undervalued overnight because of disappointing headlines, economic uncertainty, or broad market fear.\n\nInvestors with available cash have options.\n\nInvestors who are fully invested often have to choose between selling existing positions or watching the opportunity pass by.\n\nThat\'s why a cash reserve isn\'t simply about money.\n\nIt\'s about flexibility.\n\nThe larger your financial cushion, the more freedom you have to make decisions based on opportunity instead of necessity.'**
  String get verdictCashBufferTier2Intro;

  /// No description provided for @verdictCashBufferTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictCashBufferTier2Section1Label;

  /// No description provided for @verdictCashBufferTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to keep a large percentage of your portfolio in cash.\n\nA modest reserve is often enough.\n\nAs your portfolio grows, consider gradually setting aside a small amount of new contributions instead of investing every dollar immediately.\n\nOver time, this creates a financial cushion that can be used whenever exceptional opportunities appear.\n\nThe goal isn\'t to predict market crashes.\n\nThe goal is simply to be ready if they happen.'**
  String get verdictCashBufferTier2Section1Body;

  /// No description provided for @verdictCashBufferTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictCashBufferTier2Section2Label;

  /// No description provided for @verdictCashBufferTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Opportunities don\'t matter if you can\'t afford to take them.\n\nA small cash reserve may seem quiet and unproductive today—but when the market offers exceptional value, it can become one of the most powerful assets in your portfolio.'**
  String get verdictCashBufferTier2Section2Body;

  /// No description provided for @verdictCashBufferTier3Title.
  ///
  /// In en, this message translates to:
  /// **'Building a Safety Buffer'**
  String get verdictCashBufferTier3Title;

  /// No description provided for @verdictCashBufferTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio has started developing a healthy cash reserve.\n\nYou are no longer fully dependent on your current investments to handle every market situation. A portion of your capital remains available, giving you more flexibility when opportunities or unexpected events appear.\n\nThis is an important step in building a disciplined investment strategy.\n\nMany investors focus only on what they own.\n\nExperienced investors also think about what they can do next.\n\nMarkets rarely move in a straight line.\n\nPeriods of uncertainty, fear, and volatility are a normal part of investing. During these moments, having available cash can turn market stress into potential opportunity.\n\nA strong company temporarily drops in price.\n\nA broad market correction creates attractive valuations.\n\nAn unexpected event causes fear among investors.\n\nThese situations can reward investors who have the patience and resources to act.\n\nA cash buffer doesn\'t guarantee better returns.\n\nBut it gives you something extremely valuable:\n\nOptions.'**
  String get verdictCashBufferTier3Intro;

  /// No description provided for @verdictCashBufferTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictCashBufferTier3Section1Label;

  /// No description provided for @verdictCashBufferTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Your current cash position is becoming useful, but continue thinking about its purpose.\n\nCash should have a role in your strategy.\n\nAsk yourself:\n\nIs this money reserved for opportunities?\nIs this a temporary waiting position before investing?\nDoes this amount match my personal investment goals?\n\nThe goal isn\'t to keep as much cash as possible.\n\nThe goal is to find a balance where you feel prepared without allowing too much capital to remain inactive for long periods.\n\nA good investor knows when to invest.\n\nA great investor also knows when to wait.'**
  String get verdictCashBufferTier3Section1Body;

  /// No description provided for @verdictCashBufferTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictCashBufferTier3Section2Label;

  /// No description provided for @verdictCashBufferTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market rewards patience, but patience requires flexibility.\n\nA cash reserve doesn\'t mean you are afraid of investing—it means you are prepared when investing opportunities appear.'**
  String get verdictCashBufferTier3Section2Body;

  /// No description provided for @verdictCashBufferTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Ready for Opportunities'**
  String get verdictCashBufferTier4Title;

  /// No description provided for @verdictCashBufferTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio shows a strong understanding of one of the most overlooked parts of investing: flexibility.\n\nYou have built a meaningful cash reserve while still keeping the majority of your capital invested.\n\nThis balance is what many long-term investors aim for.\n\nYour money is working in the market, but you also have resources available when unexpected opportunities appear.\n\nMarkets are driven by emotions.\n\nPeriods of excitement can push prices too high.\n\nPeriods of fear can create situations where excellent businesses temporarily trade at attractive prices.\n\nThe difference between investors often isn\'t who can find opportunities.\n\nIt\'s who has the ability to act when those opportunities arrive.\n\nA cash buffer gives you that ability.\n\nIt allows you to make decisions based on your strategy rather than emotions.\n\nInstead of thinking:\n\n\"I wish I could buy more right now.\"\n\nYou have the possibility to say:\n\n\"I prepared for this moment.\"\n\nThat mindset can make a significant difference during difficult market periods.'**
  String get verdictCashBufferTier4Intro;

  /// No description provided for @verdictCashBufferTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictCashBufferTier4Section1Label;

  /// No description provided for @verdictCashBufferTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue treating cash as a strategic tool, not just money waiting to be invested.\n\nHave a clear purpose for your reserve:\n\nIs it for market corrections?\nIs it for adding to your strongest companies?\nIs it for unexpected opportunities?\n\nThe most effective investors don\'t keep cash because they are afraid of the market.\n\nThey keep cash because they respect uncertainty.\n\nJust remember that cash is a tool, not the final destination.\n\nOver very long periods, businesses and productive assets are usually the main drivers of wealth creation.\n\nThe goal is not to hold cash forever.\n\nThe goal is to have enough flexibility to use it when it matters most.'**
  String get verdictCashBufferTier4Section1Body;

  /// No description provided for @verdictCashBufferTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictCashBufferTier4Section2Label;

  /// No description provided for @verdictCashBufferTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A prepared investor doesn\'t need to predict the next market move.\n\nThey simply need to be ready when the market creates an opportunity.\n\nCash doesn\'t replace investing—it gives your investing strategy room to breathe.'**
  String get verdictCashBufferTier4Section2Body;

  /// No description provided for @verdictCashBufferTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Cash Gives You Options'**
  String get verdictCashBufferTier5Title;

  /// No description provided for @verdictCashBufferTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio demonstrates excellent cash management discipline.\n\nYou have created a meaningful reserve while still keeping your capital working in the market.\n\nThis balance represents an important investment skill that many investors overlook.\n\nBuilding wealth isn\'t only about finding great companies.\n\nIt\'s also about being prepared for uncertainty.\n\nMarkets will experience periods of excitement, fear, corrections, and unexpected events.\n\nNo investor can predict exactly when these moments will arrive.\n\nBut prepared investors don\'t need perfect timing.\n\nThey need flexibility.\n\nYour cash reserve provides that flexibility.\n\nIt gives you the ability to:\n\ntake advantage of attractive opportunities;\nadd to high-quality companies during market declines;\navoid making emotional decisions during periods of uncertainty.\n\nCash is often viewed as a weakness because it doesn\'t produce the same returns as invested assets.\n\nBut that is only one side of the story.\n\nCash has a different purpose.\n\nIt provides patience.\n\nIt provides control.\n\nIt provides the ability to act when others are forced to wait.'**
  String get verdictCashBufferTier5Intro;

  /// No description provided for @verdictCashBufferTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictCashBufferTier5Section1Label;

  /// No description provided for @verdictCashBufferTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue using cash as a strategic tool rather than simply letting it accumulate without a purpose.\n\nA strong investor knows why they are holding cash.\n\nIs it for market opportunities?\nFor adding to existing positions?\nFor maintaining flexibility during uncertain periods?\n\nHaving a plan helps prevent two common mistakes:\n\nInvesting everything because of fear of missing out.\n\nOr holding too much cash because of fear of investing.\n\nThe ideal amount depends on your personal strategy, goals, and comfort with market volatility.\n\nRemember, cash is not meant to replace investing.\n\nIt\'s meant to support better investing decisions.'**
  String get verdictCashBufferTier5Section1Body;

  /// No description provided for @verdictCashBufferTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictCashBufferTier5Section2Label;

  /// No description provided for @verdictCashBufferTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market rewards those who stay invested.\n\nBut opportunities often reward those who are prepared.\n\nCash doesn\'t make your portfolio stronger by sitting still—it makes your strategy stronger by giving you the freedom to act when it matters most.'**
  String get verdictCashBufferTier5Section2Body;

  /// No description provided for @verdictConcentrationNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Position Data Yet'**
  String get verdictConcentrationNoDataTitle;

  /// No description provided for @verdictConcentrationNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any positions — there\'s no concentration to measure yet.'**
  String get verdictConcentrationNoDataIntro;

  /// No description provided for @verdictConcentrationTier1Title.
  ///
  /// In en, this message translates to:
  /// **'One Company Holds Your Future'**
  String get verdictConcentrationTier1Title;

  /// No description provided for @verdictConcentrationTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio may contain several excellent investments—but one company stands far above the rest.\n\nA single position represents such a large portion of your invested capital that its success or failure will have a disproportionate impact on your entire portfolio.\n\nThis is known as concentration risk.\n\nThe company itself may be outstanding.\n\nIt may be profitable, financially healthy, and a leader in its industry.\n\nBut no business is immune to unexpected challenges.\n\nA disappointing earnings report.\n\nA major product delay.\n\nNew competition.\n\nRegulatory changes.\n\nEconomic uncertainty.\n\nAny of these events can cause even the strongest companies to lose significant value in a short period of time.\n\nWhen too much of your portfolio depends on one stock, you\'re no longer investing in a collection of businesses.\n\nYou\'re placing a large part of your financial future on a single decision.\n\nEven legendary companies have experienced difficult years.\n\nHistory has repeatedly shown that today\'s market leader is not guaranteed to remain tomorrow\'s winner.\n\nGreat businesses deserve confidence.\n\nThey should never require blind faith.'**
  String get verdictConcentrationTier1Intro;

  /// No description provided for @verdictConcentrationTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictConcentrationTier1Section1Label;

  /// No description provided for @verdictConcentrationTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to sell your favorite company.\n\nIf you truly believe in its long-term future, there\'s nothing wrong with making it one of your largest holdings.\n\nThe key is making sure it isn\'t carrying your entire portfolio.\n\nAs you continue investing, consider directing new money toward other high-quality businesses instead of adding even more to your largest position.\n\nOver time, your portfolio will naturally become more balanced while allowing your strongest conviction to remain an important part of your strategy.\n\nA diversified portfolio doesn\'t reduce your confidence.\n\nIt reduces the consequences of being wrong.'**
  String get verdictConcentrationTier1Section1Body;

  /// No description provided for @verdictConcentrationTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictConcentrationTier1Section2Label;

  /// No description provided for @verdictConcentrationTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Every great investor has favorite companies.\n\nThe difference is that experienced investors rarely allow one stock to determine the outcome of their entire portfolio.\n\nBelieve in great businesses—but never let a single company hold your financial future in its hands.'**
  String get verdictConcentrationTier1Section2Body;

  /// No description provided for @verdictConcentrationTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Too Much Confidence in One Stock'**
  String get verdictConcentrationTier2Title;

  /// No description provided for @verdictConcentrationTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is becoming more diversified, but one investment still represents a much larger share of your capital than the rest.\n\nThis doesn\'t necessarily mean you\'ve chosen the wrong company.\n\nIn fact, it may be one of the strongest businesses in your portfolio.\n\nThe risk comes from relying too heavily on a single investment.\n\nNo matter how successful a company appears today, every business will eventually face challenges.\n\nMarkets change.\n\nCompetition evolves.\n\nConsumer demand shifts.\n\nNew technologies emerge.\n\nEven the world\'s most respected companies have experienced periods of disappointing performance.\n\nWhen one stock carries a large portion of your portfolio, those temporary setbacks can have an outsized effect on your overall results.\n\nThat\'s why concentration risk is about position size—not company quality.\n\nA fantastic business can still become a risky investment if too much of your portfolio depends on it.\n\nOwning more shares of your favorite company doesn\'t always make your portfolio stronger.\n\nSometimes it simply makes it less resilient.'**
  String get verdictConcentrationTier2Intro;

  /// No description provided for @verdictConcentrationTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictConcentrationTier2Section1Label;

  /// No description provided for @verdictConcentrationTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to reduce your confidence in your largest holding.\n\nInstead, allow the rest of your portfolio to catch up.\n\nAs you make future investments, consider allocating new capital to other financially strong companies rather than continuing to increase your biggest position.\n\nThis gradually improves your balance without forcing unnecessary sales.\n\nOver time, your portfolio becomes driven by the combined strength of many businesses instead of the performance of just one.'**
  String get verdictConcentrationTier2Section1Body;

  /// No description provided for @verdictConcentrationTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictConcentrationTier2Section2Label;

  /// No description provided for @verdictConcentrationTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'It\'s perfectly reasonable to have a favorite company.\n\nJust don\'t let it become your entire investment strategy.\n\nThe strongest portfolios aren\'t built around one exceptional business—they\'re built around many great businesses working together.'**
  String get verdictConcentrationTier2Section2Body;

  /// No description provided for @verdictConcentrationTier3Title.
  ///
  /// In en, this message translates to:
  /// **'A Portfolio Finding Its Balance'**
  String get verdictConcentrationTier3Title;

  /// No description provided for @verdictConcentrationTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is moving toward a healthier balance.\n\nNo single company completely dominates your investments, but one position still carries noticeably more weight than the others. While this isn\'t a major concern, it does mean that one business still has more influence over your long-term results than it probably should.\n\nThis is a common stage for many investors.\n\nAfter all, when a company consistently delivers strong financial results, it\'s only natural to feel confident investing more money into it.\n\nConfidence is important.\n\nOverconfidence is where risk begins.\n\nEven exceptional businesses experience difficult periods.\n\nA change in leadership, slowing growth, increased competition, changing regulations, or an unexpected economic downturn can temporarily affect even the strongest companies.\n\nIf one position grows too large, those setbacks become portfolio-wide events instead of ordinary fluctuations.\n\nFortunately, your portfolio is already well on its way to avoiding that problem.\n\nA few thoughtful investments in other high-quality companies can make a significant difference without changing the overall strategy you\'ve built.'**
  String get verdictConcentrationTier3Intro;

  /// No description provided for @verdictConcentrationTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictConcentrationTier3Section1Label;

  /// No description provided for @verdictConcentrationTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'There\'s no need to reduce your largest position simply because it\'s your largest.\n\nInstead, focus on creating better balance over time.\n\nAs you continue investing, give slightly more attention to companies that currently represent a smaller part of your portfolio.\n\nAllow your future contributions—not emotional reactions—to shape your allocation.\n\nThis approach keeps your investment strategy disciplined while naturally reducing concentration risk.\n\nRemember, every new investment is an opportunity to strengthen your portfolio—not just increase the size of your favorite holding.'**
  String get verdictConcentrationTier3Section1Body;

  /// No description provided for @verdictConcentrationTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictConcentrationTier3Section2Label;

  /// No description provided for @verdictConcentrationTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Your goal isn\'t to find one company that carries your portfolio.\n\nIt\'s to build a collection of outstanding businesses that succeed together.\n\nA portfolio becomes stronger when its success is shared across many companies—not concentrated in just one.'**
  String get verdictConcentrationTier3Section2Body;

  /// No description provided for @verdictConcentrationTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Balanced Position Sizing'**
  String get verdictConcentrationTier4Title;

  /// No description provided for @verdictConcentrationTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio demonstrates a strong understanding of risk management.\n\nNo single company has enough influence to determine the success or failure of your entire investment strategy. While some positions are naturally larger than others, your capital is distributed in a way that allows multiple businesses to contribute to your long-term results.\n\nThis is an important milestone.\n\nMany investors spend years searching for the \"perfect stock\" and gradually allow one position to grow so large that it begins to dominate their portfolio.\n\nYou have taken a different approach.\n\nRather than depending on a single company to carry your future returns, you\'ve built a portfolio where success can come from multiple sources.\n\nThat doesn\'t mean every company will perform equally well.\n\nSome will exceed expectations.\n\nOthers may disappoint.\n\nThat\'s perfectly normal.\n\nThe strength of a balanced portfolio comes from knowing that a setback in one investment doesn\'t automatically become a setback for your entire financial plan.\n\nThis gives your portfolio something every investor needs:\n\nResilience.'**
  String get verdictConcentrationTier4Intro;

  /// No description provided for @verdictConcentrationTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictConcentrationTier4Section1Label;

  /// No description provided for @verdictConcentrationTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'The most important thing now is maintaining the balance you\'ve already created.\n\nAs your investments grow, keep an eye on positions that begin significantly outperforming the rest of the portfolio.\n\nSometimes concentration risk develops slowly.\n\nA company performs exceptionally well, its share price rises for years, and before long it represents a much larger portion of the portfolio than originally intended.\n\nRegular reviews can help ensure that today\'s balanced portfolio remains balanced in the future.\n\nYou don\'t need perfect equality between positions.\n\nYou simply want to avoid allowing one company to gain too much control over your long-term outcome.'**
  String get verdictConcentrationTier4Section1Body;

  /// No description provided for @verdictConcentrationTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictConcentrationTier4Section2Label;

  /// No description provided for @verdictConcentrationTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A great portfolio doesn\'t need a hero.\n\nIt doesn\'t need one stock to save the day.\n\nInstead, it relies on the combined strength of many well-chosen businesses working together over time.\n\nWhen no single company can make or break your future, your portfolio becomes stronger, more stable, and better prepared for the unexpected.'**
  String get verdictConcentrationTier4Section2Body;

  /// No description provided for @verdictConcentrationTier5Title.
  ///
  /// In en, this message translates to:
  /// **'No Single Company Controls Your Success'**
  String get verdictConcentrationTier5Title;

  /// No description provided for @verdictConcentrationTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio reflects a disciplined and well-balanced approach to investing.\n\nNo individual company has been allowed to dominate your investments. Instead of placing all your confidence in a single business, you\'ve spread your capital across multiple high-quality companies, allowing each one to contribute to your long-term success.\n\nThis is one of the most effective ways to manage investment risk.\n\nNo matter how successful a company appears today, its future is never guaranteed.\n\nMarket leaders can lose their competitive edge.\n\nIndustries evolve.\n\nConsumer preferences change.\n\nUnexpected events can challenge even the strongest businesses.\n\nBy avoiding excessive concentration in any single position, you\'ve accepted one of the most important realities of investing:\n\nNo company deserves complete control over your financial future.\n\nThat\'s a mindset shared by many experienced long-term investors.\n\nThey understand that building wealth isn\'t about finding one stock that changes everything.\n\nIt\'s about owning a collection of outstanding businesses that work together through different market conditions and different stages of the economy.\n\nYour portfolio reflects that philosophy.\n\nRather than relying on one company to produce extraordinary returns, you\'ve built a structure where success is shared across many carefully selected investments.'**
  String get verdictConcentrationTier5Intro;

  /// No description provided for @verdictConcentrationTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'Keep Protecting Your Balance'**
  String get verdictConcentrationTier5Section1Label;

  /// No description provided for @verdictConcentrationTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'As your portfolio continues to grow, remember that concentration risk can appear without making a single new purchase.\n\nA company that performs exceptionally well may naturally become a much larger position over time.\n\nReview your allocation occasionally and make sure your portfolio still reflects your original strategy.\n\nOften, simply directing new investments toward your smaller positions is enough to maintain a healthy balance.\n\nThe goal isn\'t to keep every position identical.\n\nThe goal is to ensure that no single investment becomes more important than the portfolio itself.'**
  String get verdictConcentrationTier5Section1Body;

  /// No description provided for @verdictConcentrationTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictConcentrationTier5Section2Label;

  /// No description provided for @verdictConcentrationTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Every company tells part of your investment story.\n\nNone of them should write the entire ending.\n\nThe strongest portfolios aren\'t built around one brilliant investment—they\'re built around many great decisions working together over time.'**
  String get verdictConcentrationTier5Section2Body;

  /// No description provided for @verdictDisciplineNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Trades Yet'**
  String get verdictDisciplineNoDataTitle;

  /// No description provided for @verdictDisciplineNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any buy trades — there\'s no buying behavior to measure yet.'**
  String get verdictDisciplineNoDataIntro;

  /// No description provided for @verdictDisciplineTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Emotional Investor'**
  String get verdictDisciplineTier1Title;

  /// No description provided for @verdictDisciplineTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment decisions show a strong influence from market emotions.\n\nInvesting is not only a test of financial knowledge.\n\nIt is also a test of patience, discipline, and the ability to stay calm when the market becomes exciting or frightening.\n\nYour recent buying behavior suggests that emotions may sometimes be guiding your decisions more than a long-term strategy.\n\nThis often happens during periods of strong market excitement.\n\nPrices are rising.\n\nEveryone is talking about a specific company or trend.\n\nThe media is full of success stories.\n\nIt can feel like the perfect moment to invest.\n\nBut this is exactly when many investors make their biggest mistakes.\n\nBuying after a large price increase because of excitement can mean paying a premium when expectations are already extremely high.\n\nThe problem is not buying successful companies.\n\nThe problem is buying them without asking:\n\n\"Am I investing because this business is attractive, or because everyone else is talking about it?\"'**
  String get verdictDisciplineTier1Intro;

  /// No description provided for @verdictDisciplineTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictDisciplineTier1Section1Label;

  /// No description provided for @verdictDisciplineTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before making a purchase, create a simple decision process.\n\nAsk yourself:\n\nWould I still buy this company if nobody was talking about it?\nDo I understand the business behind the stock price?\nAm I buying because of research or because I fear missing the opportunity?\n\nStrong investors do not try to avoid every opportunity.\n\nThey try to separate real opportunities from emotional reactions.\n\nA useful habit is learning to wait.\n\nSometimes the best investment decision is not buying immediately.\n\nSometimes patience creates better opportunities than excitement.'**
  String get verdictDisciplineTier1Section1Body;

  /// No description provided for @verdictDisciplineTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictDisciplineTier1Section2Label;

  /// No description provided for @verdictDisciplineTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market will always create exciting stories.\n\nBut successful investing is rarely about following the loudest story.\n\nThe strongest investors are not the ones who react fastest—they are the ones who can stay rational when everyone else becomes emotional.'**
  String get verdictDisciplineTier1Section2Body;

  /// No description provided for @verdictDisciplineTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Learning Discipline'**
  String get verdictDisciplineTier2Title;

  /// No description provided for @verdictDisciplineTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior shows that you are developing the habits of a disciplined investor, but emotional decisions may still influence some of your actions.\n\nYou are no longer making purely impulsive decisions, but your investment process is still evolving.\n\nThis stage is very common.\n\nMany investors understand the basic principles of investing:\n\nbuy quality businesses;\nthink long term;\navoid unnecessary risks.\n\nBut understanding these ideas and consistently following them are two different things.\n\nThe market constantly tests investor discipline.\n\nWhen prices rise quickly, excitement appears.\n\nWhen prices fall sharply, fear takes over.\n\nThe difficult part is not knowing what a disciplined investor should do.\n\nThe difficult part is actually doing it when emotions are strongest.\n\nYour behavior shows signs of improvement, but there is still room to build a stronger decision-making process.'**
  String get verdictDisciplineTier2Intro;

  /// No description provided for @verdictDisciplineTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictDisciplineTier2Section1Label;

  /// No description provided for @verdictDisciplineTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'The next step is creating rules that protect you from emotional decisions.\n\nBefore buying, ask yourself:\n\nAm I buying because the business is attractive, or because the price is moving quickly?\nWould I still make this decision if the market was quiet?\nDo I have a reason for this purchase beyond recent performance?\n\nAnother useful habit is keeping some flexibility.\n\nGreat opportunities often appear when markets become uncomfortable.\n\nInvestors who prepare in advance are usually better positioned than those who react emotionally in the moment.\n\nDiscipline is not built from one perfect decision.\n\nIt is built through repeating good decisions over time.'**
  String get verdictDisciplineTier2Section1Body;

  /// No description provided for @verdictDisciplineTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictDisciplineTier2Section2Label;

  /// No description provided for @verdictDisciplineTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Becoming a disciplined investor is a process, not a single achievement.\n\nThe goal is not to remove emotions completely—it is to make sure your strategy has a stronger voice than your emotions.'**
  String get verdictDisciplineTier2Section2Body;

  /// No description provided for @verdictDisciplineTier3Title.
  ///
  /// In en, this message translates to:
  /// **'Developing Investor'**
  String get verdictDisciplineTier3Title;

  /// No description provided for @verdictDisciplineTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior shows a balanced approach.\n\nYou are not consistently driven by market emotions, but you also have not yet developed a fully established discipline that guides every decision.\n\nThis is a normal stage for many investors.\n\nBuilding a successful investment process takes time.\n\nIt requires learning how to separate:\n\nopportunity from excitement;\nconfidence from overconfidence;\npatience from hesitation.\n\nYour decisions show that you are beginning to understand the importance of timing and context.\n\nYou are not simply reacting to every market movement, but there may still be moments when emotions influence your choices.\n\nThe market constantly creates pressure.\n\nDuring strong rallies, it encourages investors to chase performance.\n\nDuring downturns, it encourages investors to wait for \"perfect conditions.\"\n\nBoth reactions can lead to missed opportunities.\n\nA disciplined investor understands that markets are unpredictable, but their own process can remain consistent.'**
  String get verdictDisciplineTier3Intro;

  /// No description provided for @verdictDisciplineTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictDisciplineTier3Section1Label;

  /// No description provided for @verdictDisciplineTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Focus on building a repeatable investment routine.\n\nBefore every purchase, define:\n\nWhy am I buying this asset?\nWhat makes this company or investment attractive?\nAm I following my strategy or reacting to the current market mood?\n\nTry to judge decisions based on the reasoning behind them—not only on the result afterward.\n\nA good decision can sometimes lose money.\n\nA bad decision can sometimes make money.\n\nDiscipline means focusing on the quality of the decision-making process.\n\nOver time, consistent habits become more valuable than individual wins or losses.'**
  String get verdictDisciplineTier3Section1Body;

  /// No description provided for @verdictDisciplineTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictDisciplineTier3Section2Label;

  /// No description provided for @verdictDisciplineTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Every experienced investor was once learning how to control emotions and build confidence.\n\nDiscipline is not something you are born with—it is a skill built through thousands of thoughtful decisions.'**
  String get verdictDisciplineTier3Section2Body;

  /// No description provided for @verdictDisciplineTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Disciplined Investor'**
  String get verdictDisciplineTier4Title;

  /// No description provided for @verdictDisciplineTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior demonstrates strong control over emotions and a thoughtful approach to decision-making.\n\nYou understand one of the most difficult lessons in investing:\n\nThe market does not reward the investor who reacts the fastest.\n\nIt rewards the investor who can remain patient, analyze opportunities, and follow a clear strategy.\n\nYour buying decisions show that you are less influenced by short-term excitement and more focused on long-term reasoning.\n\nYou appear more comfortable making decisions based on opportunity rather than emotion.\n\nWhen markets become uncertain, many investors freeze.\n\nWhen markets become exciting, many investors chase what is already popular.\n\nYour behavior shows a better balance.\n\nYou recognize that fear can create opportunities, while excessive excitement can create unnecessary risk.\n\nThis doesn\'t mean every decision will be perfect.\n\nNo investor can predict the future.\n\nDiscipline is not about always being right.\n\nIt is about making decisions for the right reasons.'**
  String get verdictDisciplineTier4Intro;

  /// No description provided for @verdictDisciplineTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictDisciplineTier4Section1Label;

  /// No description provided for @verdictDisciplineTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue strengthening the process behind your investments.\n\nEven disciplined investors can improve by regularly reviewing their decisions.\n\nAsk yourself:\n\nDid my original investment idea remain valid?\nAm I still following my long-term plan?\nHas my reason for owning this asset changed?\n\nRemember that discipline is not only about buying at the right moment.\n\nIt is also about having the patience to hold quality investments through different market conditions.\n\nThe strongest investors are not those who never make mistakes.\n\nThey are those who have a process that helps them learn and improve.'**
  String get verdictDisciplineTier4Section1Body;

  /// No description provided for @verdictDisciplineTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictDisciplineTier4Section2Label;

  /// No description provided for @verdictDisciplineTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Markets will always create fear and excitement.\n\nYou cannot control those emotions around you.\n\nBut you can control your response.\n\nA disciplined investor does not try to predict every market movement—they build habits that help them make better decisions regardless of the market environment.'**
  String get verdictDisciplineTier4Section2Body;

  /// No description provided for @verdictDisciplineTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Contrarian Mindset'**
  String get verdictDisciplineTier5Title;

  /// No description provided for @verdictDisciplineTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior demonstrates a high level of discipline and emotional control.\n\nYou understand one of the hardest principles in investing:\n\nThe best opportunities often appear when they feel the most uncomfortable.\n\nWhile many investors react to fear by selling and react to excitement by buying, your decisions show the ability to step back, analyze the situation, and act according to a strategy.\n\nYou are not simply following the crowd.\n\nYou recognize that markets are driven by emotions:\n\nFear can push quality companies to attractive prices.\n\nExcitement can push expectations beyond realistic levels.\n\nA disciplined investor understands that price movements and business value are not always the same thing.\n\nWhen others focus only on what is happening today, you appear more focused on what could matter years from now.\n\nThis mindset does not guarantee perfect results.\n\nNo investor can predict every market movement.\n\nEven the most experienced investors make mistakes.\n\nThe difference is that disciplined investors build a process that helps them avoid emotional decisions and stay focused on long-term goals.'**
  String get verdictDisciplineTier5Intro;

  /// No description provided for @verdictDisciplineTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictDisciplineTier5Section1Label;

  /// No description provided for @verdictDisciplineTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Maintain the habits that helped you build this level of discipline.\n\nContinue asking important questions before every investment:\n\nAm I buying because the opportunity is attractive, or because everyone is excited?\nDoes the business justify the price I am paying?\nWould I still make this decision if the market reacted negatively tomorrow?\n\nRemember that being a contrarian investor does not mean always going against the crowd.\n\nSometimes the crowd is right.\n\nTrue discipline means having the confidence to disagree when the evidence supports it—and the humility to change your mind when the facts change.'**
  String get verdictDisciplineTier5Section1Body;

  /// No description provided for @verdictDisciplineTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictDisciplineTier5Section2Label;

  /// No description provided for @verdictDisciplineTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market rewards patience, but patience requires courage.\n\nThe greatest advantage an investor can have is not predicting the future—it is having the discipline to make rational decisions when emotions are at their strongest.'**
  String get verdictDisciplineTier5Section2Body;

  /// No description provided for @verdictEtfExposureNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No ETF Data Yet'**
  String get verdictEtfExposureNoDataTitle;

  /// No description provided for @verdictEtfExposureNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any positions — there\'s no ETF exposure to measure yet.'**
  String get verdictEtfExposureNoDataIntro;

  /// No description provided for @verdictEtfExposureTier1Title.
  ///
  /// In en, this message translates to:
  /// **'No Safety Net'**
  String get verdictEtfExposureTier1Title;

  /// No description provided for @verdictEtfExposureTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is built entirely from individual stocks, with no exchange-traded funds (ETFs) to provide broader market exposure.\n\nThis isn\'t necessarily a bad strategy.\n\nMany successful investors have built impressive portfolios using only individual companies.\n\nThe challenge is that this approach asks much more from you.\n\nEvery investment decision becomes your responsibility.\n\nYou must identify strong businesses, avoid weak ones, manage diversification, monitor risk, and accept that a single mistake can have a much greater impact on your long-term results.\n\nAn ETF works differently.\n\nInstead of relying on the success of one company, it allows you to invest in dozens—or even hundreds—of businesses through a single investment.\n\nIf one company struggles, the others continue contributing to the portfolio.\n\nThis built-in diversification is one of the main reasons ETFs have become so popular among long-term investors.\n\nWithout at least one broad-market ETF, your portfolio has no automatic safety net.\n\nIts success depends entirely on your ability to consistently select winning companies over many years.\n\nThat\'s a difficult challenge—even for experienced investors.'**
  String get verdictEtfExposureTier1Intro;

  /// No description provided for @verdictEtfExposureTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictEtfExposureTier1Section1Label;

  /// No description provided for @verdictEtfExposureTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Consider adding a broad-market ETF as a foundation for your portfolio.\n\nAn ETF doesn\'t replace individual stock investing.\n\nIt complements it.\n\nThink of it as the stable core of your investment strategy, while individual companies become opportunities to seek additional growth.\n\nMany long-term investors combine both approaches:\n\nA diversified ETF provides stability.\n\nCarefully selected companies provide the potential to outperform the market.\n\nTogether, they create a portfolio that is both resilient and flexible.'**
  String get verdictEtfExposureTier1Section1Body;

  /// No description provided for @verdictEtfExposureTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictEtfExposureTier1Section2Label;

  /// No description provided for @verdictEtfExposureTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need an ETF because individual stocks are bad.\n\nYou need one because no investor can predict every future winner.\n\nA single ETF won\'t make your portfolio exciting—but it can make it significantly more resilient for the decades ahead.'**
  String get verdictEtfExposureTier1Section2Body;

  /// No description provided for @verdictEtfExposureTier2Title.
  ///
  /// In en, this message translates to:
  /// **'A Step Toward Stability'**
  String get verdictEtfExposureTier2Title;

  /// No description provided for @verdictEtfExposureTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio now includes an ETF, and that\'s an important step toward building a more resilient investment strategy.\n\nBy adding broad market exposure, you\'ve reduced your dependence on individual companies and introduced an investment designed to spread risk across many businesses.\n\nThat\'s exactly what ETFs do best.\n\nWhile individual stocks can deliver exceptional returns, they can also disappoint for reasons that are impossible to predict.\n\nAn ETF helps balance that uncertainty by investing in a large group of companies instead of relying on the success of just one.\n\nThink of it as adding a strong foundation beneath the rest of your portfolio.\n\nAt the same time, a single ETF is only the beginning.\n\nYour portfolio still relies primarily on individual stock selection, meaning your long-term performance will continue to depend on the quality of the businesses you choose.\n\nThe ETF provides stability.\n\nYour stock selections provide the opportunity for additional growth.\n\nTogether, they create a healthier balance than either approach alone.'**
  String get verdictEtfExposureTier2Intro;

  /// No description provided for @verdictEtfExposureTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictEtfExposureTier2Section1Label;

  /// No description provided for @verdictEtfExposureTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is already moving in the right direction.\n\nAs it grows, consider whether a second ETF could complement your existing one.\n\nFor example, investors often combine a broad-market ETF with another fund focused on international markets, small-cap companies, bonds, or another area that isn\'t already represented.\n\nThe goal isn\'t to collect ETFs.\n\nThe goal is to make sure each one adds something genuinely different to your portfolio.\n\nQuality matters more than quantity.'**
  String get verdictEtfExposureTier2Section1Body;

  /// No description provided for @verdictEtfExposureTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictEtfExposureTier2Section2Label;

  /// No description provided for @verdictEtfExposureTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'One ETF won\'t eliminate investment risk.\n\nNothing can.\n\nBut it can reduce the impact of unexpected events while giving your portfolio a stronger foundation to build upon.\n\nA solid investment strategy doesn\'t rely on one perfect company—it starts with a portfolio that can weather many different market conditions.'**
  String get verdictEtfExposureTier2Section2Body;

  /// No description provided for @verdictEtfExposureTier3Title.
  ///
  /// In en, this message translates to:
  /// **'A Strong Core'**
  String get verdictEtfExposureTier3Title;

  /// No description provided for @verdictEtfExposureTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio includes a healthy number of ETFs, creating a solid foundation for long-term investing.\n\nRather than relying entirely on individual stock selection, you\'ve chosen to combine broad market exposure with the flexibility to invest in companies you believe in. This is a strategy used by many experienced investors because it balances growth potential with sensible risk management.\n\nETFs offer something individual stocks cannot.\n\nInstant diversification.\n\nWith just a few funds, you can gain exposure to hundreds—or even thousands—of companies across different industries, countries, and sectors of the economy.\n\nThis helps reduce the impact that any single company can have on your overall portfolio while allowing the broader market to work in your favor over time.\n\nYour portfolio reflects that philosophy well.\n\nAt the same time, you\'ve avoided another common mistake—collecting too many ETFs.\n\nEvery fund in your portfolio appears to have a purpose instead of simply adding more investments for the sake of diversification.\n\nThat\'s an important distinction.\n\nA carefully chosen ETF should expand your exposure, not repeat what you already own.'**
  String get verdictEtfExposureTier3Intro;

  /// No description provided for @verdictEtfExposureTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictEtfExposureTier3Section1Label;

  /// No description provided for @verdictEtfExposureTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'The key now isn\'t adding more ETFs.\n\nIt\'s understanding what each one actually holds.\n\nBefore purchasing another fund, ask yourself:\n\nDoes this ETF provide exposure I don\'t already have?\nAm I adding diversification, or simply buying many of the same companies again?\nDoes this fund serve a clear purpose within my portfolio?\n\nA small collection of well-chosen ETFs is often more effective than owning dozens of overlapping funds.\n\nRemember, every investment should have a job.\n\nIf an ETF doesn\'t improve your portfolio in a meaningful way, it probably doesn\'t need to be there.'**
  String get verdictEtfExposureTier3Section1Body;

  /// No description provided for @verdictEtfExposureTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictEtfExposureTier3Section2Label;

  /// No description provided for @verdictEtfExposureTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Great portfolios aren\'t measured by how many ETFs they contain.\n\nThey\'re measured by how well those ETFs work together.\n\nA few carefully selected funds can provide the foundation for decades of investing—without making your portfolio unnecessarily complicated.'**
  String get verdictEtfExposureTier3Section2Body;

  /// No description provided for @verdictEtfExposureTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Broadly Diversified'**
  String get verdictEtfExposureTier4Title;

  /// No description provided for @verdictEtfExposureTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio includes several ETFs, giving you exposure to a wide range of companies and markets.\n\nThat\'s a positive sign.\n\nBy investing through multiple funds, you\'ve reduced the risk of relying too heavily on individual businesses and created a portfolio that can benefit from different parts of the global economy.\n\nHowever, there comes a point where adding more ETFs doesn\'t always add more diversification.\n\nMany popular funds hold the same companies.\n\nFor example, it\'s common for several U.S. equity ETFs to own large positions in businesses like Apple, Microsoft, NVIDIA, Amazon, and other market leaders.\n\nAlthough the fund names may be different, much of the underlying portfolio can look surprisingly similar.\n\nThis is known as overlapping exposure.\n\nIt creates the impression of greater diversification while, in reality, many of your investments are following the same group of companies.\n\nYour portfolio is still well diversified, but it\'s worth making sure each ETF contributes something unique rather than repeating what you already own.'**
  String get verdictEtfExposureTier4Intro;

  /// No description provided for @verdictEtfExposureTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictEtfExposureTier4Section1Label;

  /// No description provided for @verdictEtfExposureTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before adding another ETF, take a moment to understand what it actually contains.\n\nAsk yourself:\n\nDoes this fund invest in companies I don\'t already own through another ETF?\nDoes it provide exposure to a different region, sector, or asset class?\nIs it adding genuine diversification, or simply increasing my exposure to the same businesses?\n\nSometimes replacing two similar ETFs with one broader fund can simplify your portfolio while providing nearly identical market exposure.\n\nA portfolio doesn\'t become stronger simply because it contains more funds.\n\nIt becomes stronger when every investment has a clear purpose.'**
  String get verdictEtfExposureTier4Section1Body;

  /// No description provided for @verdictEtfExposureTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictEtfExposureTier4Section2Label;

  /// No description provided for @verdictEtfExposureTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'More ETFs don\'t always mean more diversification.\n\nSometimes they simply mean owning the same companies several times under different names.\n\nThe goal isn\'t to collect funds—it\'s to build a portfolio where every ETF adds something valuable that wasn\'t already there.'**
  String get verdictEtfExposureTier4Section2Body;

  /// No description provided for @verdictEtfExposureTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Broad Diversification, Simple Strategy'**
  String get verdictEtfExposureTier5Title;

  /// No description provided for @verdictEtfExposureTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio contains a large number of ETFs, giving you exposure to a wide range of markets, industries, and companies.\n\nThere\'s nothing inherently wrong with this approach.\n\nIn fact, many investors choose to build their entire portfolio using ETFs because they offer excellent diversification, low maintenance, and broad exposure to the global economy.\n\nHowever, more ETFs don\'t automatically create a better portfolio.\n\nBeyond a certain point, many funds begin investing in the same companies.\n\nA U.S. market ETF, an S&P 500 ETF, a Large Cap ETF, and a Growth ETF may all hold significant positions in businesses like Apple, Microsoft, NVIDIA, Amazon, and other market leaders.\n\nAlthough your portfolio appears highly diversified, the underlying investments may overlap far more than you realize.\n\nThere\'s another trade-off worth understanding.\n\nETFs are designed to follow the market—not beat it.\n\nThey provide steady, diversified exposure, but they rarely deliver exceptional returns on their own.\n\nThat\'s why many investors combine a small number of broad ETFs with carefully selected individual companies.\n\nThe ETFs provide stability.\n\nThe individual businesses provide the opportunity to outperform the market.\n\nNeither approach is universally better.\n\nThey simply represent different investment philosophies.'**
  String get verdictEtfExposureTier5Intro;

  /// No description provided for @verdictEtfExposureTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictEtfExposureTier5Section1Label;

  /// No description provided for @verdictEtfExposureTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Instead of asking whether you need another ETF, ask whether each ETF has a unique purpose.\n\nDoes it give you exposure to a market you don\'t already own?\n\nOr is it simply another way of buying many of the same companies?\n\nIf your goal is a simple, long-term portfolio, a handful of carefully selected ETFs is often enough.\n\nIf your goal is to outperform the market through stock selection, consider allowing your strongest individual companies to play a larger role while keeping ETFs as the stable core of your portfolio.\n\nThe objective isn\'t to own more funds.\n\nIt\'s to make every fund earn its place.'**
  String get verdictEtfExposureTier5Section1Body;

  /// No description provided for @verdictEtfExposureTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictEtfExposureTier5Section2Label;

  /// No description provided for @verdictEtfExposureTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A portfolio made entirely of ETFs can be an excellent long-term strategy.\n\nA portfolio combining ETFs and outstanding businesses can also be an excellent strategy.\n\nThe important question isn\'t how many ETFs you own.\n\nIt\'s whether each one adds something your portfolio didn\'t already have.\n\nDiversification is powerful. Complexity isn\'t always necessary.'**
  String get verdictEtfExposureTier5Section2Body;

  /// No description provided for @verdictPanicNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Trades Yet'**
  String get verdictPanicNoDataTitle;

  /// No description provided for @verdictPanicNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any trades — there\'s no selling behavior to measure yet.'**
  String get verdictPanicNoDataIntro;

  /// No description provided for @verdictPanicTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Panic Seller'**
  String get verdictPanicTier1Title;

  /// No description provided for @verdictPanicTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your selling behavior shows signs that fear may sometimes influence your investment decisions.\n\nInvesting is not only about choosing good companies.\n\nIt is also about having the patience and emotional control to stay with your decisions when the market becomes uncomfortable.\n\nOne of the most difficult moments for any investor is watching a position decline.\n\nThe natural reaction is to think:\n\n\"Maybe I made a mistake. Maybe I should get out before it gets worse.\"\n\nSometimes selling is the right decision.\n\nA company can lose its competitive advantage.\n\nThe business conditions can change.\n\nThe original investment idea may no longer be valid.\n\nBut selling only because the price is falling is a different situation.\n\nThe biggest losses for many investors do not come from buying bad companies.\n\nThey come from abandoning good investments during the most stressful moments.\n\nA panic sale often happens when fear reaches its highest point.\n\nUnfortunately, this is also the moment when many quality assets are trading at their lowest prices.\n\nYour score suggests that some selling decisions may have happened during periods of strong pressure, possibly close to the worst moments of the decline.'**
  String get verdictPanicTier1Intro;

  /// No description provided for @verdictPanicTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPanicTier1Section1Label;

  /// No description provided for @verdictPanicTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before selling a position at a loss, create a clear checklist.\n\nAsk yourself:\n\nHas the business actually become worse?\nHas the original reason for buying changed?\nAm I making this decision because of new information or because I am afraid?\n\nTry separating the stock price from the business itself.\n\nA falling price does not automatically mean a broken company.\n\nSometimes the market is simply reacting emotionally.\n\nAnother useful habit is creating rules before problems appear.\n\nFor example:\n\nWhy would I sell this company?\nWhat conditions would make me change my opinion?\nHow much volatility am I prepared to accept?\n\nA plan created during calm periods is often more reliable than a decision made during panic.'**
  String get verdictPanicTier1Section1Body;

  /// No description provided for @verdictPanicTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPanicTier1Section2Label;

  /// No description provided for @verdictPanicTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market will test every investor.\n\nPrices will fall.\n\nBad news will appear.\n\nFear will become loud.\n\nThe goal is not to never feel fear—the goal is to avoid letting fear make your investment decisions for you.'**
  String get verdictPanicTier1Section2Body;

  /// No description provided for @verdictPanicTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Emotional Selling'**
  String get verdictPanicTier2Title;

  /// No description provided for @verdictPanicTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior shows that you are learning to manage difficult market situations, but emotions may still influence some selling decisions.\n\nSelling is one of the hardest parts of investing.\n\nBuying a company often feels exciting.\n\nHolding during good times feels easy.\n\nBut watching a position decline tests patience, confidence, and trust in your own analysis.\n\nYour history suggests that some decisions may have been influenced by short-term pressure rather than a complete reassessment of the investment.\n\nThis does not mean every losing trade was a mistake.\n\nGood investors sometimes sell at a loss.\n\nThe difference is why they sell.\n\nA disciplined investor may accept a loss because:\n\nthe business changed;\nthe original investment idea is no longer valid;\na better opportunity appeared.\n\nAn emotional sale happens when the main reason is:\n\n\"I cannot handle this decline anymore.\"\n\nThe market often creates the strongest emotions near the most difficult moments.\n\nFear becomes louder.\n\nConfidence disappears.\n\nAnd many investors exit exactly when patience becomes the most valuable skill.'**
  String get verdictPanicTier2Intro;

  /// No description provided for @verdictPanicTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPanicTier2Section1Label;

  /// No description provided for @verdictPanicTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before selling during a decline, try to slow down the decision process.\n\nAsk yourself:\n\nAm I selling because the company became weaker?\nOr am I selling because the stock price makes me uncomfortable?\nWould I still make this decision if the market was not showing daily price movements?\n\nCreate your selling rules before emotions appear.\n\nA good investment plan should include not only:\n\n\"When should I buy?\"\n\nbut also:\n\n\"When should I sell?\"\n\nRemember that temporary price declines are a normal part of investing.\n\nThe important question is not:\n\n\"Did the price fall?\"\n\nThe important question is:\n\n\"Has the reason I invested changed?\"'**
  String get verdictPanicTier2Section1Body;

  /// No description provided for @verdictPanicTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPanicTier2Section2Label;

  /// No description provided for @verdictPanicTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Every investor feels fear.\n\nThe difference between experienced investors and beginners is not the absence of fear.\n\nIt is the ability to make decisions with a clear mind even when fear is present.'**
  String get verdictPanicTier2Section2Body;

  /// No description provided for @verdictPanicTier3Title.
  ///
  /// In en, this message translates to:
  /// **'Learning Patience'**
  String get verdictPanicTier3Title;

  /// No description provided for @verdictPanicTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your selling behavior shows that you are developing better control over emotional decisions, but your ability to stay calm during difficult market periods is still improving.\n\nYou are no longer reacting purely from fear, but some situations may still create uncertainty and pressure.\n\nThis is a very common stage for investors.\n\nLearning to invest successfully is not only about knowing what to buy.\n\nIt is also about learning when not to act.\n\nMarkets constantly create situations that challenge confidence:\n\nA good company falls because of temporary market fear.\n\nA strong investment declines because the entire sector is under pressure.\n\nNegative headlines create uncertainty.\n\nIn these moments, many investors feel the need to do something immediately.\n\nBut sometimes the most disciplined decision is simply waiting and gathering more information.\n\nYour behavior suggests that you are building this skill, but there is still room to strengthen your patience.'**
  String get verdictPanicTier3Intro;

  /// No description provided for @verdictPanicTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPanicTier3Section1Label;

  /// No description provided for @verdictPanicTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before selling during a difficult period, try separating emotions from facts.\n\nAsk yourself:\n\nHas the company fundamentally changed?\nIs the investment idea still valid?\nAm I reacting to temporary market noise?\n\nRemember that volatility is a normal part of investing.\n\nEven excellent companies experience periods of decline.\n\nA useful habit is reviewing your original reason for buying.\n\nIf the reason is still valid, a lower price does not automatically mean a mistake.\n\nPatience does not mean holding everything forever.\n\nIt means giving a good investment enough time to prove itself while staying ready to change your decision when the facts truly change.'**
  String get verdictPanicTier3Section1Body;

  /// No description provided for @verdictPanicTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPanicTier3Section2Label;

  /// No description provided for @verdictPanicTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Successful investors are not those who never experience uncertainty.\n\nThey are those who learn how to handle uncertainty without making rushed decisions.\n\nPatience is not doing nothing—it is choosing your actions carefully when the market tries to pressure you.'**
  String get verdictPanicTier3Section2Body;

  /// No description provided for @verdictPanicTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Steady Investor'**
  String get verdictPanicTier4Title;

  /// No description provided for @verdictPanicTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your selling behavior demonstrates good emotional control and a growing ability to handle market uncertainty.\n\nYou understand one of the most important lessons in investing:\n\nA falling stock price does not automatically mean a bad investment.\n\nMany investors can stay confident when markets are rising.\n\nThe real test comes during difficult periods.\n\nWhen prices decline, negative headlines appear, and uncertainty increases, emotional decisions become much more tempting.\n\nYour behavior suggests that you are usually able to avoid panic reactions and give your investments time to develop.\n\nYou appear more focused on the reasons behind your investments rather than short-term price movements.\n\nThis does not mean every decision is perfect.\n\nNo investor avoids mistakes completely.\n\nThe difference is that disciplined investors do not let temporary market fear become the main reason for their actions.\n\nThey evaluate the situation, review the facts, and make decisions based on their strategy.'**
  String get verdictPanicTier4Intro;

  /// No description provided for @verdictPanicTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPanicTier4Section1Label;

  /// No description provided for @verdictPanicTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue strengthening your decision-making process.\n\nBefore selling a position, ask yourself:\n\nHas the business changed, or only the stock price?\nWould I still believe this was a good company if the market was closed tomorrow?\nAm I selling because of new information or because of temporary fear?\n\nRemember that patience does not mean refusing to sell.\n\nSometimes selling is the correct decision.\n\nThe key difference is the reason behind it.\n\nA strong investor sells because the investment thesis changed.\n\nAn emotional investor sells because the market became uncomfortable.'**
  String get verdictPanicTier4Section1Body;

  /// No description provided for @verdictPanicTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPanicTier4Section2Label;

  /// No description provided for @verdictPanicTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Markets will always create moments of uncertainty.\n\nThe ability to stay calm during those moments is a powerful investing advantage.\n\nA steady investor does not ignore risk—they understand it, evaluate it, and respond with a clear mind instead of fear.'**
  String get verdictPanicTier4Section2Body;

  /// No description provided for @verdictPanicTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Market Survivor'**
  String get verdictPanicTier5Title;

  /// No description provided for @verdictPanicTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investment behavior demonstrates a very high level of emotional control and patience during difficult market conditions.\n\nYou understand one of the hardest lessons in investing:\n\nA temporary decline is not always a permanent loss.\n\nMany investors can stay confident when markets are rising.\n\nThe real challenge appears when everything moves in the opposite direction.\n\nPrices fall.\n\nNegative headlines dominate the news.\n\nFear spreads among investors.\n\nDuring these moments, emotions often become stronger than analysis.\n\nYour behavior shows that you are capable of staying focused during periods of extreme pressure.\n\nInstead of reacting immediately to falling prices, you appear to give your investments time and evaluate situations more carefully.\n\nThis is one of the biggest differences between short-term reactions and long-term investing.\n\nA strong investor understands that market crashes are not only periods of risk.\n\nThey can also create opportunities.\n\nWhen others are forced to make emotional decisions, patient investors often have the greatest advantage.'**
  String get verdictPanicTier5Intro;

  /// No description provided for @verdictPanicTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictPanicTier5Section1Label;

  /// No description provided for @verdictPanicTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue protecting the habits that created this level of discipline.\n\nEven experienced investors should regularly review their decisions.\n\nAsk yourself:\n\nHas the business changed, or only the market price?\nAm I still confident in the original investment idea?\nAm I making this decision based on facts or emotions?\n\nRemember that patience does not mean holding every investment forever.\n\nA great investor is not afraid to change their mind when the facts change.\n\nThe goal is not to avoid every mistake.\n\nThe goal is to avoid making decisions because of temporary fear.'**
  String get verdictPanicTier5Section1Body;

  /// No description provided for @verdictPanicTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPanicTier5Section2Label;

  /// No description provided for @verdictPanicTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Every market cycle creates moments when investors are tested.\n\nSome investors react to fear.\n\nOthers use patience as their advantage.\n\nThe greatest strength of a long-term investor is not avoiding storms—it is having the discipline to stay focused while they pass.'**
  String get verdictPanicTier5Section2Body;

  /// No description provided for @verdictPatienceNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Trades Yet'**
  String get verdictPatienceNoDataTitle;

  /// No description provided for @verdictPatienceNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any trades — there\'s no waiting behavior to measure yet.'**
  String get verdictPatienceNoDataIntro;

  /// No description provided for @verdictPatienceTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Impatient Investor'**
  String get verdictPatienceTier1Title;

  /// No description provided for @verdictPatienceTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investing behavior shows that patience may be one of the biggest areas for improvement.\n\nInvesting is not only about finding good opportunities.\n\nIt is also about giving your decisions enough time to work.\n\nThe market constantly creates pressure to act:\n\nPrices move every day.\n\nNews creates uncertainty.\n\nOther investors share their success stories.\n\nDuring these moments, it can feel like doing something is always better than waiting.\n\nBut in investing, unnecessary actions can sometimes become the biggest mistake.\n\nA good investment does not always move higher immediately.\n\nEven strong companies can experience:\n\ntemporary declines;\ndifficult market conditions;\nperiods when investors lose confidence.\n\nYour score suggests that you may sometimes react too quickly instead of allowing your investment ideas enough time to develop.\n\nThe problem is not making changes.\n\nSuccessful investors sometimes sell, adjust, and improve their portfolios.\n\nThe important question is:\n\n\"Am I changing my decision because the facts changed, or because the situation became uncomfortable?\"'**
  String get verdictPatienceTier1Intro;

  /// No description provided for @verdictPatienceTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPatienceTier1Section1Label;

  /// No description provided for @verdictPatienceTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before making a quick decision, try creating a short waiting period.\n\nAsk yourself:\n\nHas the company actually become weaker?\nDid something fundamental change?\nAm I reacting to temporary market noise?\nWould I make the same decision if I ignored today\'s price movement?\n\nTry separating movement from meaning.\n\nA falling price does not always mean a bad investment.\n\nA rising price does not always mean a good investment.\n\nStrong investors understand that time is an important part of the investment process.\n\nAnother useful habit is creating your rules before emotions appear:\n\nWhat would make me sell?\nHow long am I willing to wait?\nWhat conditions would change my original idea?\n\nA calm plan created during normal conditions is much stronger than a decision made under pressure.'**
  String get verdictPatienceTier1Section1Body;

  /// No description provided for @verdictPatienceTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPatienceTier1Section2Label;

  /// No description provided for @verdictPatienceTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market rewards investors who can stay focused when others become impatient.\n\nPatience does not mean doing nothing.\n\nIt means having the confidence to wait when waiting is the smartest decision.'**
  String get verdictPatienceTier1Section2Body;

  /// No description provided for @verdictPatienceTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Short-Term Thinking'**
  String get verdictPatienceTier2Title;

  /// No description provided for @verdictPatienceTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investing behavior shows that you are building patience, but difficult market situations may still create pressure that influences some of your decisions.\n\nYou understand the importance of staying invested, but your actions suggest that uncertainty can sometimes make you want to change direction too quickly.\n\nThis is a very common stage for investors.\n\nMany people understand the idea of long-term investing:\n\nbuy quality assets;\nstay invested;\nignore short-term noise.\n\nBut understanding the concept and applying it during stressful moments are two different things.\n\nThe market constantly tests patience.\n\nA company can have strong fundamentals, but the stock price may decline because of:\n\nmarket fear;\neconomic uncertainty;\ntemporary bad news;\nnegative sentiment.\n\nDuring these periods, it is easy to focus only on the falling price and forget the original reason for the investment.\n\nYour score suggests that you sometimes allow short-term events to have too much influence on long-term decisions.'**
  String get verdictPatienceTier2Intro;

  /// No description provided for @verdictPatienceTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPatienceTier2Section1Label;

  /// No description provided for @verdictPatienceTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'The next step is developing a stronger connection between your investment decisions and your original strategy.\n\nBefore making changes, ask yourself:\n\nDid the company actually become worse?\nIs this a permanent problem or a temporary situation?\nWould I still want to own this business if the price movement was hidden from me?\n\nTry reviewing your investments based on the business, not only the chart.\n\nA temporary decline can create discomfort.\n\nBut discomfort alone is not always a reason to act.\n\nRemember:\n\nA long-term investor is not rewarded for reacting to every market movement.\n\nThey are rewarded for making thoughtful decisions and allowing good ideas enough time to work.'**
  String get verdictPatienceTier2Section1Body;

  /// No description provided for @verdictPatienceTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPatienceTier2Section2Label;

  /// No description provided for @verdictPatienceTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market moves faster than any investor can predict.\n\nTrying to react to every movement often creates unnecessary mistakes.\n\nPatience is the ability to give your strategy enough time to prove itself instead of constantly changing direction with every market wave.'**
  String get verdictPatienceTier2Section2Body;

  /// No description provided for @verdictPatienceTier3Title.
  ///
  /// In en, this message translates to:
  /// **'Building Patience'**
  String get verdictPatienceTier3Title;

  /// No description provided for @verdictPatienceTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investing behavior shows that you are developing the ability to stay calm during market uncertainty, but your patience is still a skill that continues to grow.\n\nYou are beginning to understand an important investing principle:\n\nNot every market movement requires a reaction.\n\nSuccessful investing often requires the ability to wait.\n\nWait for the right opportunity.\n\nWait for the market to recognize value.\n\nWait for a good business decision to develop over time.\n\nYour behavior suggests that you are not constantly reacting emotionally, but some situations may still create uncertainty and make you question your decisions.\n\nThis is a normal stage of development for investors.\n\nThe market rarely moves in a straight line.\n\nEven strong investments experience periods of:\n\nslow growth;\ntemporary declines;\nnegative sentiment;\nuncertainty.\n\nThe challenge is learning when action is necessary and when patience is the better choice.'**
  String get verdictPatienceTier3Intro;

  /// No description provided for @verdictPatienceTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPatienceTier3Section1Label;

  /// No description provided for @verdictPatienceTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue building a clear decision process before making changes.\n\nWhen you feel the urge to sell or adjust your portfolio, ask:\n\nIs the business becoming weaker, or is the market simply reacting?\nHas my original investment idea changed?\nAm I making this decision because of facts or because of discomfort?\n\nTry to evaluate your investments based on the long-term picture.\n\nA temporary decline can feel uncomfortable, but discomfort is not always a signal that something is wrong.\n\nAt the same time, patience does not mean ignoring problems.\n\nA patient investor still reviews decisions and changes direction when the facts truly change.\n\nThe goal is not to hold everything forever.\n\nThe goal is to avoid unnecessary actions caused by short-term emotions.'**
  String get verdictPatienceTier3Section1Body;

  /// No description provided for @verdictPatienceTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPatienceTier3Section2Label;

  /// No description provided for @verdictPatienceTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Patience is built through experience.\n\nEvery market decline, every uncertain moment, and every difficult decision is a chance to improve.\n\nA patient investor is not someone who never acts.\n\nA patient investor knows when action is necessary—and when waiting is the smartest decision.'**
  String get verdictPatienceTier3Section2Body;

  /// No description provided for @verdictPatienceTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Patient Investor'**
  String get verdictPatienceTier4Title;

  /// No description provided for @verdictPatienceTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investing behavior demonstrates a strong ability to remain calm and focused during uncertain market conditions.\n\nYou understand one of the most important lessons in long-term investing:\n\nNot every problem in the market requires immediate action.\n\nMany investors feel pressure to constantly make decisions.\n\nWhen prices rise, they feel the need to buy more.\n\nWhen prices fall, they feel the need to protect themselves.\n\nBut experienced investors understand that sometimes the best decision is simply waiting and allowing time to work.\n\nYour behavior suggests that you are able to separate temporary market movements from real changes in the quality of an investment.\n\nYou are more likely to evaluate situations instead of immediately reacting to emotions.\n\nThis is a valuable skill because markets are designed to test investor patience.\n\nThere will always be:\n\nunexpected declines;\nnegative headlines;\nperiods of uncertainty;\nmoments when confidence is challenged.\n\nThe ability to stay focused during these periods can become one of the biggest advantages an investor has.'**
  String get verdictPatienceTier4Intro;

  /// No description provided for @verdictPatienceTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictPatienceTier4Section1Label;

  /// No description provided for @verdictPatienceTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue developing your investment process and protect the habits that created this level of patience.\n\nBefore making changes, continue asking:\n\nHas the business actually changed?\nIs the original investment idea still valid?\nAm I making this decision because of new information or because of temporary market emotions?\n\nRemember that patience does not mean refusing to make decisions.\n\nA patient investor is still willing to sell when the facts change.\n\nThe difference is that decisions come from analysis, not pressure.\n\nKeep focusing on the long-term picture instead of reacting to every short-term movement.'**
  String get verdictPatienceTier4Section1Body;

  /// No description provided for @verdictPatienceTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPatienceTier4Section2Label;

  /// No description provided for @verdictPatienceTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Markets will always create moments that test your confidence.\n\nThe advantage does not belong to the investor who reacts to every change.\n\nIt belongs to the investor who can stay focused, wait for the right moment, and allow good decisions enough time to work.'**
  String get verdictPatienceTier4Section2Body;

  /// No description provided for @verdictPatienceTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Long-Term Mindset'**
  String get verdictPatienceTier5Title;

  /// No description provided for @verdictPatienceTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your investing behavior demonstrates an exceptional level of patience and emotional control.\n\nYou understand one of the most powerful advantages in investing:\n\nTime is not just something investors wait for — it is something they use.\n\nMany investors focus on predicting the next market movement.\n\nThey try to find the perfect entry point.\n\nThey react to every headline.\n\nThey worry about every temporary decline.\n\nBut long-term investors understand that successful investing is often built through consistency, preparation, and the ability to stay focused when the market becomes unpredictable.\n\nYour behavior shows that you are capable of avoiding unnecessary reactions during difficult periods.\n\nInstead of immediately responding to fear or uncertainty, you allow your investment decisions time to develop.\n\nThis is especially important during major market disruptions.\n\nWhen fear spreads, many investors make decisions based on emotion.\n\nThey sell because they want to stop the discomfort.\n\nA patient investor understands that uncertainty is part of investing.\n\nThey evaluate the situation, review the facts, and avoid changing direction simply because the market becomes stressful.'**
  String get verdictPatienceTier5Intro;

  /// No description provided for @verdictPatienceTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictPatienceTier5Section1Label;

  /// No description provided for @verdictPatienceTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Maintaining patience is a strength, but even patient investors should continue reviewing their decisions.\n\nRemember:\n\nPatience does not mean holding every investment forever.\n\nA strong long-term investor still asks:\n\nHas the business changed?\nIs my original investment idea still valid?\nAm I holding because of confidence or because I refuse to admit a mistake?\n\nThe goal is not to avoid every sale.\n\nThe goal is to make sure decisions come from analysis rather than emotion.\n\nContinue balancing patience with awareness.\n\nThe best investors are calm, but they are never careless.'**
  String get verdictPatienceTier5Section1Body;

  /// No description provided for @verdictPatienceTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictPatienceTier5Section2Label;

  /// No description provided for @verdictPatienceTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The market will always create moments of fear, excitement, and uncertainty.\n\nYou cannot control the market.\n\nBut you can control how you respond to it.\n\nThe greatest advantage of a long-term investor is not predicting every storm.\n\nIt is having the patience and confidence to stay focused while the storm passes.'**
  String get verdictPatienceTier5Section2Body;

  /// No description provided for @verdictSafetyMarkerNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Safety Data Yet'**
  String get verdictSafetyMarkerNoDataTitle;

  /// No description provided for @verdictSafetyMarkerNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test doesn\'t have enough data to score the quality of what was bought — either no positions were opened, or the fundamentals for those companies hadn\'t finished loading before the test ended.'**
  String get verdictSafetyMarkerNoDataIntro;

  /// No description provided for @verdictSafetyMarkerTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Building on Hopes, Not Businesses'**
  String get verdictSafetyMarkerTier1Title;

  /// No description provided for @verdictSafetyMarkerTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio shows a clear pattern: many of your investments are based more on future expectations than on the strength of the businesses themselves.\n\nEvery company begins with an idea. Some of those ideas grow into world-changing businesses. Others never become profitable at all.\n\nThe challenge is that the stock market often rewards exciting stories long before those stories become successful businesses.\n\nCompanies with little or no profit, weak financial health, declining revenue, excessive debt, or business models that have yet to prove themselves can experience dramatic price swings. They may occasionally deliver extraordinary returns—but they also carry a much higher risk of permanent losses.\n\nOwning several of these companies at the same time doesn\'t reduce that risk. It simply spreads your money across multiple uncertain outcomes.\n\nThis is especially common with highly speculative industries such as early-stage biotechnology, pre-revenue technology companies, space exploration startups, meme stocks, and businesses whose valuations depend primarily on future expectations rather than current performance.\n\nThere\'s nothing wrong with believing in innovation.\n\nMany of today\'s largest companies once started as ambitious ideas.\n\nThe difference is that successful long-term investors don\'t buy a company simply because its story sounds exciting. They look for evidence that the business is becoming stronger over time.\n\nGrowing revenue.\nHealthy profit margins.\nReasonable debt.\nPositive cash flow.\nConsistent execution.\n\nThese fundamentals often matter far more than headlines or social media excitement.'**
  String get verdictSafetyMarkerTier1Intro;

  /// No description provided for @verdictSafetyMarkerTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSafetyMarkerTier1Section1Label;

  /// No description provided for @verdictSafetyMarkerTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Before buying a company, try asking yourself a few simple questions.\n\nIs this company already generating sustainable profits?\nDoes its business continue to grow year after year?\nCan it survive difficult economic conditions?\nAm I investing because I understand the business—or because I hope the future will be extraordinary?\n\nSometimes the most exciting investment isn\'t the strongest one.\n\nAnd sometimes the strongest business isn\'t the one making the loudest headlines.\n\nYou don\'t have to avoid higher-risk companies completely.\n\nHowever, they should represent only a small portion of a portfolio built on stable, financially healthy businesses.\n\nStrong foundations allow great ideas to become opportunities—not unnecessary risks.'**
  String get verdictSafetyMarkerTier1Section1Body;

  /// No description provided for @verdictSafetyMarkerTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSafetyMarkerTier1Section2Label;

  /// No description provided for @verdictSafetyMarkerTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Innovation creates possibilities.\n\nStrong businesses create long-term wealth.\n\nThe most successful investors learn to tell the difference.\n\nDon\'t invest only in what could become great. Invest in companies that are already proving they can succeed.'**
  String get verdictSafetyMarkerTier1Section2Body;

  /// No description provided for @verdictSafetyMarkerTier2Title.
  ///
  /// In en, this message translates to:
  /// **'High Risk, High Expectations'**
  String get verdictSafetyMarkerTier2Title;

  /// No description provided for @verdictSafetyMarkerTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio shows a mix of promising businesses and highly speculative investments.\n\nYou\'ve started looking beyond headlines, but many of your decisions still place a great deal of trust in what a company might become rather than what it has already achieved.\n\nThere is nothing wrong with investing in future potential.\n\nEvery successful company was once an ambitious idea.\n\nThe challenge is that not every ambitious idea becomes a successful business.\n\nMany companies spend years chasing profitability. Some never reach it. Others rely heavily on debt, repeatedly issue new shares to raise capital, or continue operating without generating sustainable cash flow. While a small number eventually become market leaders, many fail long before reaching that point.\n\nAs an investor, your goal isn\'t to predict every future success story.\n\nYour goal is to improve the odds that the businesses you own can survive long enough to become one.\n\nAt the moment, your portfolio still leans more toward optimism than financial strength.\n\nThat doesn\'t make it a bad portfolio—but it does make it a riskier one.'**
  String get verdictSafetyMarkerTier2Intro;

  /// No description provided for @verdictSafetyMarkerTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSafetyMarkerTier2Section1Label;

  /// No description provided for @verdictSafetyMarkerTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'When evaluating a company, try spending less time asking:\n\n\"How much could this stock go up?\"\n\nAnd more time asking:\n\nIs the company consistently profitable?\nIs revenue growing because the business is improving—not simply because of temporary excitement?\nCan the company support itself without constantly raising new capital?\nDoes management have a proven record of delivering results?\n\nSometimes the strongest investments don\'t look exciting at first.\n\nThey quietly build profits, strengthen their balance sheets, and reward patient investors over many years.\n\nYou don\'t need to eliminate every speculative company from your portfolio.\n\nJust make sure they\'re the exception—not the foundation.\n\nLet financially healthy businesses carry the weight of your portfolio, while higher-risk ideas remain carefully controlled opportunities.'**
  String get verdictSafetyMarkerTier2Section1Body;

  /// No description provided for @verdictSafetyMarkerTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSafetyMarkerTier2Section2Label;

  /// No description provided for @verdictSafetyMarkerTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Hope can be part of an investment.\n\nIt should never be the entire investment strategy.\n\nThe strongest portfolios aren\'t built on the companies with the biggest promises—they\'re built on the companies that consistently deliver on them.'**
  String get verdictSafetyMarkerTier2Section2Body;

  /// No description provided for @verdictSafetyMarkerTier3Title.
  ///
  /// In en, this message translates to:
  /// **'A Portfolio with Potential'**
  String get verdictSafetyMarkerTier3Title;

  /// No description provided for @verdictSafetyMarkerTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio shows clear progress.\n\nMost of your investments are backed by companies with solid business foundations, while a smaller number still carry higher levels of uncertainty. This balance suggests you\'re beginning to look beyond market excitement and pay closer attention to the strength of the businesses you invest in.\n\nThat\'s an important step.\n\nSuccessful investing isn\'t about finding companies with the most exciting stories.\n\nIt\'s about identifying businesses that can continue creating value year after year.\n\nStrong companies often share similar characteristics. They generate consistent revenue, maintain healthy profit margins, manage debt responsibly, and continue growing even when market conditions become difficult.\n\nYour portfolio already reflects many of these qualities.\n\nHowever, there are still a few companies whose future depends more on expectations than proven financial performance.\n\nThat doesn\'t automatically make them bad investments.\n\nSome speculative companies eventually become tomorrow\'s market leaders.\n\nThe challenge is that it\'s impossible to know in advance which ones will succeed and which ones won\'t.\n\nThis is why experienced investors usually build the majority of their portfolio around businesses that have already demonstrated financial strength, while limiting exposure to companies that are still trying to prove themselves.'**
  String get verdictSafetyMarkerTier3Intro;

  /// No description provided for @verdictSafetyMarkerTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSafetyMarkerTier3Section1Label;

  /// No description provided for @verdictSafetyMarkerTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'As your portfolio grows, try making business quality one of your main investment filters.\n\nBefore buying a company, look beyond the share price.\n\nAsk yourself:\n\nIs this business consistently profitable?\nDoes it generate healthy cash flow?\nIs debt under control?\nHas management demonstrated the ability to execute its strategy over time?\nWould I still want to own this company if its stock price didn\'t move for the next three years?\n\nThe answers to these questions often reveal far more than short-term market enthusiasm.\n\nRemember, a strong investment is built on a strong business—not simply on a popular stock.'**
  String get verdictSafetyMarkerTier3Section1Body;

  /// No description provided for @verdictSafetyMarkerTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSafetyMarkerTier3Section2Label;

  /// No description provided for @verdictSafetyMarkerTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A great company doesn\'t have to be exciting.\n\nIt has to be resilient.\n\nThe market often rewards excitement for a while.\n\nIt rewards strong businesses for much longer.\n\nThe more your decisions are guided by business quality instead of market excitement, the stronger your portfolio becomes.'**
  String get verdictSafetyMarkerTier3Section2Body;

  /// No description provided for @verdictSafetyMarkerTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Quality Comes First'**
  String get verdictSafetyMarkerTier4Title;

  /// No description provided for @verdictSafetyMarkerTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio reflects a disciplined approach to investing.\n\nThe companies you\'ve selected are generally supported by strong financial foundations rather than short-term market excitement. Instead of chasing headlines or popular trends, you\'ve focused on businesses that have already demonstrated their ability to generate revenue, earn profits, manage debt responsibly, and create long-term value.\n\nThis is one of the most important habits successful investors develop.\n\nThe market is full of exciting stories.\n\nSome promise revolutionary technologies.\n\nOthers promise to change entire industries.\n\nA few eventually do.\n\nMany never live up to those expectations.\n\nStrong businesses don\'t need extraordinary promises to attract investors. They earn confidence through consistent execution, financial stability, and years of proven performance.\n\nYour portfolio reflects that mindset.\n\nRather than relying on hope, you\'ve built much of your portfolio around companies that have already shown they can survive economic downturns, adapt to changing markets, and continue growing over time.\n\nNo company is completely risk-free.\n\nEven the strongest businesses experience difficult years, disappointing earnings, or unexpected challenges.\n\nHowever, financially healthy companies are often far better equipped to recover from those setbacks than businesses that are already struggling to survive.\n\nThat difference becomes especially valuable during periods of market uncertainty.'**
  String get verdictSafetyMarkerTier4Intro;

  /// No description provided for @verdictSafetyMarkerTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictSafetyMarkerTier4Section1Label;

  /// No description provided for @verdictSafetyMarkerTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Keep doing what you\'re already doing—but never stop asking questions.\n\nEven outstanding companies deserve regular review.\n\nMarkets evolve.\n\nIndustries change.\n\nNew competitors emerge.\n\nBefore adding a new investment, ask yourself:\n\nIs this company still financially strong?\nHas its business improved over the past few years?\nDoes it continue creating value for shareholders?\nWould I still feel comfortable owning this business during a difficult market downturn?\n\nA strong portfolio isn\'t built by finding perfect companies.\n\nIt\'s built by consistently choosing businesses that continue earning your confidence.'**
  String get verdictSafetyMarkerTier4Section1Body;

  /// No description provided for @verdictSafetyMarkerTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSafetyMarkerTier4Section2Label;

  /// No description provided for @verdictSafetyMarkerTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Great investors don\'t search for perfect stocks.\n\nThey search for exceptional businesses.\n\nStock prices rise and fall every day.\n\nStrong businesses continue building value long after today\'s headlines have been forgotten.\n\nWhen you invest in quality businesses, you\'re investing in companies that have already learned how to survive, adapt, and grow.'**
  String get verdictSafetyMarkerTier4Section2Body;

  /// No description provided for @verdictSafetyMarkerTier5Title.
  ///
  /// In en, this message translates to:
  /// **'Investing in Businesses, Not Stories'**
  String get verdictSafetyMarkerTier5Title;

  /// No description provided for @verdictSafetyMarkerTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'You invest in businesses—not promises.\n\nYour portfolio reflects the mindset of a long-term investor.\n\nRather than chasing excitement, market hype, or the latest investment trend, you\'ve consistently chosen companies with strong financial foundations and proven business performance.\n\nThese businesses don\'t rely solely on bold promises or optimistic forecasts.\n\nThey generate real revenue.\n\nThey produce sustainable profits.\n\nThey manage debt responsibly.\n\nThey reward shareholders through disciplined capital allocation.\n\nMost importantly, they have demonstrated an ability to adapt, compete, and grow through changing market conditions.\n\nThat doesn\'t guarantee every investment will succeed.\n\nNo company is immune to economic downturns, unexpected challenges, or periods of poor performance.\n\nHowever, businesses with strong fundamentals are often far better equipped to overcome those obstacles than companies that are still searching for a viable business model.\n\nThis is one of the biggest differences between investing and speculating.\n\nSpeculation asks:\n\n\"What could this company become?\"\n\nInvesting asks:\n\n\"What has this company already proven it can do?\"\n\nYour portfolio suggests you\'re asking the second question more often.\n\nThat habit has helped many successful investors build wealth over decades—not by predicting the future, but by owning businesses capable of creating value year after year.'**
  String get verdictSafetyMarkerTier5Intro;

  /// No description provided for @verdictSafetyMarkerTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'Keep Thinking Like a Business Owner'**
  String get verdictSafetyMarkerTier5Section1Label;

  /// No description provided for @verdictSafetyMarkerTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Even outstanding companies deserve regular review.\n\nMarkets change.\n\nIndustries evolve.\n\nCompetitive advantages can weaken over time.\n\nContinue looking beyond the share price.\n\nReview financial statements.\n\nFollow earnings reports.\n\nPay attention to debt levels, profitability, cash flow, and management decisions.\n\nThe strongest investors don\'t buy great companies and forget about them forever.\n\nThey continue making sure those companies remain great businesses.\n\nRemember, a high-quality company today must continue earning that reputation tomorrow.'**
  String get verdictSafetyMarkerTier5Section1Body;

  /// No description provided for @verdictSafetyMarkerTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSafetyMarkerTier5Section2Label;

  /// No description provided for @verdictSafetyMarkerTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A stock is more than a ticker symbol.\n\nBehind every share is a real business, real employees, real customers, and real financial results.\n\nThe market may reward exciting stories for a season.\n\nBut over the long run, it has consistently rewarded businesses that create lasting value.\n\nThe greatest investment isn\'t finding the next headline. It\'s owning companies that continue proving their worth long after the headlines have faded.'**
  String get verdictSafetyMarkerTier5Section2Body;

  /// No description provided for @verdictSectorBalanceNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Sector Data Yet'**
  String get verdictSectorBalanceNoDataTitle;

  /// No description provided for @verdictSectorBalanceNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without any positions — there\'s no sector concentration to measure yet.'**
  String get verdictSectorBalanceNoDataIntro;

  /// No description provided for @verdictSectorBalanceTier1Title.
  ///
  /// In en, this message translates to:
  /// **'One Sector Rules Them All'**
  String get verdictSectorBalanceTier1Title;

  /// No description provided for @verdictSectorBalanceTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio may contain excellent companies—but they\'re all standing on the same foundation.\n\nA large portion of your investments is concentrated in a single sector of the economy, which means your portfolio\'s future depends heavily on the success of one industry.\n\nThis is known as sector concentration risk.\n\nThe companies themselves may be financially strong.\n\nTheir management teams may be excellent.\n\nTheir products may lead the market.\n\nBut if the entire industry faces unexpected challenges, even outstanding businesses often decline together.\n\nHistory has shown this many times.\n\nTechnology, banking, real estate, energy, biotechnology—every sector has experienced periods of rapid growth followed by years of disappointing performance.\n\nThe strongest companies often survive.\n\nTheir share prices don\'t always escape the downturn.\n\nMarkets don\'t ask whether your companies are good.\n\nThey often ask whether investors still want exposure to that entire industry.\n\nWhen confidence disappears, an entire sector can fall together—even when many of its businesses remain fundamentally healthy.'**
  String get verdictSectorBalanceTier1Intro;

  /// No description provided for @verdictSectorBalanceTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSectorBalanceTier1Section1Label;

  /// No description provided for @verdictSectorBalanceTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Try looking beyond your favorite industry.\n\nInstead of asking:\n\n\"Which is the best company in this sector?\"\n\nAlso ask:\n\n\"Which important parts of the economy am I completely ignoring?\"\n\nHealthcare.\nFinancial services.\nIndustrials.\nConsumer businesses.\nEnergy.\nUtilities.\nCommunication services.\n\nEach sector responds differently to changing economic conditions.\n\nOwning businesses across multiple industries helps ensure that your portfolio isn\'t relying on a single economic story to succeed.\n\nDiversification across sectors doesn\'t eliminate risk.\n\nIt prevents one industry from deciding the fate of your entire portfolio.'**
  String get verdictSectorBalanceTier1Section1Body;

  /// No description provided for @verdictSectorBalanceTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorBalanceTier1Section2Label;

  /// No description provided for @verdictSectorBalanceTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A great company can still be part of a risky portfolio.\n\nNot because the business is weak—\n\nbut because too many of your investments depend on the same part of the economy.\n\nDon\'t put all your confidence into one industry. Build a portfolio that can continue moving forward even when one sector falls behind.'**
  String get verdictSectorBalanceTier1Section2Body;

  /// No description provided for @verdictSectorBalanceTier2Title.
  ///
  /// In en, this message translates to:
  /// **'Too Much Faith in One Industry'**
  String get verdictSectorBalanceTier2Title;

  /// No description provided for @verdictSectorBalanceTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is beginning to diversify, but one sector still carries far more weight than the others.\n\nWhile you own companies from multiple industries, a significant portion of your capital remains concentrated in a single area of the economy. If that sector experiences a prolonged downturn, your entire portfolio could feel the impact far more than you might expect.\n\nThis doesn\'t mean you\'ve chosen bad companies.\n\nIn fact, many of them may be exceptional businesses.\n\nThe challenge is that even excellent companies often move in the same direction when they belong to the same industry.\n\nStrong earnings, product launches, interest rates, government regulations, technological changes, or shifts in investor sentiment can affect an entire sector at once.\n\nWhen that happens, owning several companies from the same industry doesn\'t always provide the diversification investors hope for.\n\nSometimes it simply means taking the same risk multiple times.'**
  String get verdictSectorBalanceTier2Intro;

  /// No description provided for @verdictSectorBalanceTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSectorBalanceTier2Section1Label;

  /// No description provided for @verdictSectorBalanceTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio doesn\'t need a complete overhaul.\n\nIt simply needs better balance.\n\nThe next time you invest, consider adding a company from a sector that currently has a much smaller presence in your portfolio.\n\nInstead of strengthening your largest position even further, strengthen one of your weakest.\n\nOver time, these small decisions can create a portfolio that is more resilient to unexpected market changes.\n\nThe goal isn\'t to avoid your favorite industry.\n\nThe goal is to avoid depending on it.'**
  String get verdictSectorBalanceTier2Section1Body;

  /// No description provided for @verdictSectorBalanceTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorBalanceTier2Section2Label;

  /// No description provided for @verdictSectorBalanceTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'It\'s perfectly fine to have a favorite sector.\n\nJust don\'t let it become your entire investment strategy.\n\nThe strongest portfolios aren\'t built around one successful industry. They\'re built around an economy that never stops changing.'**
  String get verdictSectorBalanceTier2Section2Body;

  /// No description provided for @verdictSectorBalanceTier3Title.
  ///
  /// In en, this message translates to:
  /// **'A Better Balance Is Within Reach'**
  String get verdictSectorBalanceTier3Title;

  /// No description provided for @verdictSectorBalanceTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is moving in the right direction.\n\nYou\'ve already spread your investments across several sectors of the economy, which is an important step toward reducing risk. However, one industry still represents a noticeably larger share of your portfolio than the others.\n\nThis isn\'t a major problem—but it\'s an opportunity to improve.\n\nMarkets don\'t move in perfect harmony.\n\nDifferent sectors respond differently to economic conditions, interest rates, inflation, technological change, and consumer demand. While one industry may struggle for months or even years, another may continue growing under the very same conditions.\n\nThat\'s why balance matters.\n\nA portfolio doesn\'t become stronger by finding one perfect sector.\n\nIt becomes stronger by giving several sectors the opportunity to contribute to your long-term success.\n\nAt the moment, your portfolio still leans a little too heavily toward one part of the economy.\n\nFortunately, you\'re much closer to excellent diversification than poor diversification.'**
  String get verdictSectorBalanceTier3Intro;

  /// No description provided for @verdictSectorBalanceTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSectorBalanceTier3Section1Label;

  /// No description provided for @verdictSectorBalanceTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to sell your existing investments.\n\nInstead, let your future purchases gradually improve the balance.\n\nWhen adding new companies, give a little more attention to sectors that currently make up a smaller portion of your portfolio.\n\nOver time, your allocation will naturally become more balanced without forcing unnecessary trades or creating taxable events.\n\nSmall adjustments made consistently are often more effective than dramatic changes made all at once.'**
  String get verdictSectorBalanceTier3Section1Body;

  /// No description provided for @verdictSectorBalanceTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorBalanceTier3Section2Label;

  /// No description provided for @verdictSectorBalanceTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Diversification isn\'t about making every sector exactly the same size.\n\nIt\'s about making sure no single industry has too much control over your financial future.\n\nYour portfolio already has a solid foundation.\n\nA few thoughtful investments in underrepresented sectors could make it even stronger for whatever the market brings next.'**
  String get verdictSectorBalanceTier3Section2Body;

  /// No description provided for @verdictSectorBalanceTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Balanced Across the Economy'**
  String get verdictSectorBalanceTier4Title;

  /// No description provided for @verdictSectorBalanceTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio demonstrates a healthy level of sector diversification.\n\nNo single industry dominates your investments, allowing different parts of the economy to contribute to your long-term results. This balanced approach helps reduce the impact that any one sector can have on your overall portfolio.\n\nThat\'s an important advantage.\n\nMarkets move in cycles.\n\nTechnology won\'t lead forever.\n\nHealthcare won\'t always outperform.\n\nFinancials, industrials, consumer companies, energy, utilities, and other sectors each have periods of strength and periods of weakness.\n\nNo one can consistently predict which industry will outperform next.\n\nFortunately, your portfolio doesn\'t have to.\n\nBy spreading your investments across multiple sectors, you\'ve built a portfolio that is prepared for different economic environments instead of relying on a single prediction.\n\nThis is exactly how diversification is meant to work.'**
  String get verdictSectorBalanceTier4Intro;

  /// No description provided for @verdictSectorBalanceTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictSectorBalanceTier4Section1Label;

  /// No description provided for @verdictSectorBalanceTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Continue maintaining the balance you\'ve already created.\n\nAs your portfolio grows, avoid allowing one rapidly growing sector to gradually dominate your investments.\n\nA quick review of your sector allocation from time to time is often enough to keep your portfolio well balanced.\n\nAlso remember that sector diversification is only one part of building a resilient portfolio.\n\nThe quality of the businesses you own remains just as important as the industries they belong to.\n\nStrong companies spread across multiple sectors create a stronger portfolio than simply owning many different industries.'**
  String get verdictSectorBalanceTier4Section1Body;

  /// No description provided for @verdictSectorBalanceTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorBalanceTier4Section2Label;

  /// No description provided for @verdictSectorBalanceTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A balanced portfolio doesn\'t try to predict which sector will win next.\n\nIt prepares for the possibility that any sector can have its moment.\n\nYou can\'t control where the next market leader will come from—but you can build a portfolio that\'s ready when it happens.'**
  String get verdictSectorBalanceTier4Section2Body;

  /// No description provided for @verdictSectorBalanceTier5Title.
  ///
  /// In en, this message translates to:
  /// **'No Single Sector Controls Your Future'**
  String get verdictSectorBalanceTier5Title;

  /// No description provided for @verdictSectorBalanceTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio reflects a well-balanced investment strategy.\n\nNo single sector dominates your holdings, which means your long-term success isn\'t tied to the performance of one industry. Instead, your investments are spread across different parts of the economy, allowing your portfolio to benefit from a wide range of businesses, products, and economic cycles.\n\nThis is one of the strongest forms of risk management available to long-term investors.\n\nDifferent industries thrive under different conditions.\n\nTechnology may lead during periods of innovation.\n\nHealthcare often remains resilient during uncertain markets.\n\nIndustrials may benefit from economic expansion.\n\nConsumer companies, financial services, utilities, and energy each have their own opportunities and challenges throughout the market cycle.\n\nRather than trying to predict which sector will become tomorrow\'s winner, you\'ve built a portfolio that is prepared for many different outcomes.\n\nThat\'s exactly how long-term investing should work.\n\nYour portfolio doesn\'t rely on being right about a single industry.\n\nIt relies on the strength of the broader economy.'**
  String get verdictSectorBalanceTier5Intro;

  /// No description provided for @verdictSectorBalanceTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'Keep Protecting Your Balance'**
  String get verdictSectorBalanceTier5Section1Label;

  /// No description provided for @verdictSectorBalanceTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'As your portfolio grows, continue monitoring your sector allocation from time to time.\n\nSometimes a rapidly growing sector can naturally become much larger than the rest of your portfolio without you even noticing.\n\nMaintaining balance doesn\'t require frequent trading.\n\nOften, simply directing new investments toward underrepresented sectors is enough to keep your portfolio well diversified.\n\nRemember, diversification isn\'t a one-time decision.\n\nIt\'s an ongoing habit.'**
  String get verdictSectorBalanceTier5Section1Body;

  /// No description provided for @verdictSectorBalanceTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorBalanceTier5Section2Label;

  /// No description provided for @verdictSectorBalanceTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'The future rarely rewards only one industry.\n\nInnovation shifts.\n\nEconomic cycles change.\n\nNew leaders emerge while yesterday\'s leaders slow down.\n\nYou don\'t need to know which sector will outperform next.\n\nYou\'ve built a portfolio that doesn\'t depend on a single answer.\n\nThe strongest portfolios don\'t bet on one part of the economy. They grow alongside the economy itself.'**
  String get verdictSectorBalanceTier5Section2Body;

  /// No description provided for @verdictSectorDiversificationNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'No Positions Opened'**
  String get verdictSectorDiversificationNoDataTitle;

  /// No description provided for @verdictSectorDiversificationNoDataIntro.
  ///
  /// In en, this message translates to:
  /// **'This test ended without a single purchase — there\'s nothing yet to diversify.'**
  String get verdictSectorDiversificationNoDataIntro;

  /// No description provided for @verdictSectorDiversificationTier1Title.
  ///
  /// In en, this message translates to:
  /// **'Not All Your Eggs in One Basket'**
  String get verdictSectorDiversificationTier1Title;

  /// No description provided for @verdictSectorDiversificationTier1Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio has placed almost all of its trust in just one or two sectors of the economy. It\'s an understandable decision. When a particular industry is booming, it can feel like you\'ve found the obvious winner. The thought naturally follows:\n\n\"Why invest anywhere else if all the biggest opportunities are right here?\"\n\nThe problem is that the market rarely follows a single script.\n\nToday, investors are excited about artificial intelligence. Before that, it was electric vehicles. Earlier, it was internet companies, biotechnology, clean energy, and many other industries that once seemed unstoppable. Some of them truly changed the world—but almost every one of them also experienced periods when prices fell dramatically and investor confidence quickly turned into uncertainty.\n\nThe issue isn\'t the sector you chose.\n\nThe issue is that the future of your entire portfolio now depends on a single idea.\n\nIf that one sector runs into trouble, nearly all of your investments will feel the impact at the same time.\n\nImagine flying in an aircraft powered by only one engine. As long as everything works, the flight is smooth. But if that engine fails, there isn\'t much left to rely on.\n\nA well-built investment portfolio works differently. It\'s more like an aircraft with multiple independent systems. If one part struggles, the others continue doing their job, helping keep the entire portfolio stable.\n\nThat\'s exactly why experienced investors spread their money across different sectors of the economy. Technology, healthcare, financials, industrials, consumer goods, utilities, energy—these industries don\'t move in perfect harmony. When one sector has a difficult year, another may continue growing or simply remain stable. That balance helps reduce the impact of unexpected events.'**
  String get verdictSectorDiversificationTier1Intro;

  /// No description provided for @verdictSectorDiversificationTier1Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How can you improve?'**
  String get verdictSectorDiversificationTier1Section1Label;

  /// No description provided for @verdictSectorDiversificationTier1Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Don\'t try to predict the single winning sector of the next decade. Even professional investors rarely get that right consistently.\n\nInstead, build your portfolio one step at a time.\n\nKeep investing in the sector you believe in—but gradually add exposure to other parts of the economy. You don\'t need to buy everything at once. Every new investment is an opportunity to make your portfolio a little more balanced and a little more resilient.\n\nBefore making your next purchase, ask yourself one simple question:\n\n\"If my favorite sector stopped growing for the next three years, would my portfolio still be in good shape?\"\n\nIf that question makes you uncomfortable, it\'s probably time to broaden your investments.'**
  String get verdictSectorDiversificationTier1Section1Body;

  /// No description provided for @verdictSectorDiversificationTier1Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One last thought'**
  String get verdictSectorDiversificationTier1Section2Label;

  /// No description provided for @verdictSectorDiversificationTier1Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Diversification is rarely exciting.\n\nIt doesn\'t make headlines. It doesn\'t promise overnight wealth. In fact, it can even feel a little boring.\n\nBut diversification isn\'t designed for the days when everything is going up.\n\nIt\'s designed for the days when the market reminds everyone that no sector, no matter how exciting, rises forever.\n\nA successful investor doesn\'t build a portfolio around a single hope. They build it to survive many different futures.'**
  String get verdictSectorDiversificationTier1Section2Body;

  /// No description provided for @verdictSectorDiversificationTier2Title.
  ///
  /// In en, this message translates to:
  /// **'A Strong Foundation, But There\'s Still Room to Grow'**
  String get verdictSectorDiversificationTier2Title;

  /// No description provided for @verdictSectorDiversificationTier2Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio is already moving in the right direction.\n\nInstead of relying on a single industry, you\'ve spread your investments across several sectors of the economy. That\'s an important step because it reduces the risk of one disappointing industry dragging down your entire portfolio.\n\nMany investors never get this far.\n\nHowever, your portfolio still relies almost entirely on individual companies.\n\nEven the strongest businesses can experience unexpected setbacks. A weak earnings report, new competition, regulatory changes, a lawsuit, or simply a shift in market sentiment can cause an individual stock to struggle for months—or even years.\n\nThis is where a broad-market ETF can quietly become one of the most valuable investments in your portfolio.\n\nThink of an ETF as the foundation beneath your house.\n\nYou probably don\'t admire the foundation every day. It isn\'t exciting. It doesn\'t make headlines. Nobody talks about it at family dinners.\n\nBut when the weather turns bad, you\'re very happy it\'s there.\n\nA broad-market ETF spreads your investment across hundreds—or even thousands—of companies with a single purchase. It doesn\'t replace individual stocks. Instead, it helps balance them. While one company may disappoint, many others continue doing their job behind the scenes.\n\nThis creates a portfolio that is often more stable, easier to manage, and less dependent on the success of a handful of companies.'**
  String get verdictSectorDiversificationTier2Intro;

  /// No description provided for @verdictSectorDiversificationTier2Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How can you improve?'**
  String get verdictSectorDiversificationTier2Section1Label;

  /// No description provided for @verdictSectorDiversificationTier2Section1Body.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already done the difficult part by diversifying across multiple sectors.\n\nNow consider adding at least one broad-market ETF to strengthen the overall structure of your portfolio.\n\nYou don\'t need to replace the companies you believe in.\n\nSimply allow an ETF to become the stable core around which the rest of your investments can grow.\n\nMany experienced long-term investors build their portfolios this way:\n\nA solid ETF provides broad market exposure.\nIndividual companies are added around it to pursue additional growth opportunities.\n\nThis combination offers the best of both worlds—stability from the market as a whole and the potential for stronger returns from carefully selected businesses.'**
  String get verdictSectorDiversificationTier2Section1Body;

  /// No description provided for @verdictSectorDiversificationTier2Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One last thought'**
  String get verdictSectorDiversificationTier2Section2Label;

  /// No description provided for @verdictSectorDiversificationTier2Section2Body.
  ///
  /// In en, this message translates to:
  /// **'A well-diversified portfolio isn\'t measured only by how many sectors it owns.\n\nIt\'s also measured by how many different risks it avoids.\n\nIndividual companies can surprise you. An entire market is much harder to surprise.'**
  String get verdictSectorDiversificationTier2Section2Body;

  /// No description provided for @verdictSectorDiversificationTier3Title.
  ///
  /// In en, this message translates to:
  /// **'A Portfolio Built to Weather the Storm'**
  String get verdictSectorDiversificationTier3Title;

  /// No description provided for @verdictSectorDiversificationTier3Intro.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio looks thoughtfully constructed rather than randomly assembled.\n\nYour investments are spread across multiple sectors of the economy, meaning your long-term success doesn\'t depend on a single industry or one big idea. Technology may lead today, while healthcare, industrials, financials, or consumer companies could take the spotlight tomorrow. No one can consistently predict which sector will outperform next—but you\'ve already prepared for different possibilities.\n\nThat\'s exactly what diversification is meant to do.\n\nWhen one sector faces a difficult period, others may continue growing or simply remain stable. This balance helps reduce the impact of unexpected market events and makes your portfolio more resilient during times of volatility.\n\nMost importantly, you resisted the temptation to bet everything on a single trend. Instead of trying to identify one future winner, you\'ve given your investments the opportunity to grow across several parts of the economy. That approach may not deliver the highest return every single year, but it greatly improves your chances of achieving consistent long-term results.\n\nGreat investors don\'t focus only on how much they can make.\n\nThey also focus on staying invested through every market cycle.'**
  String get verdictSectorDiversificationTier3Intro;

  /// No description provided for @verdictSectorDiversificationTier3Section1Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictSectorDiversificationTier3Section1Label;

  /// No description provided for @verdictSectorDiversificationTier3Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Even a strong portfolio can still be improved.\n\nIf you already own a broad-market ETF, you\'ve built a solid foundation. If not, consider adding one. A single diversified ETF can become the stable core of your portfolio while your individual stock picks provide additional growth opportunities.\n\nThere\'s one more habit that experienced investors often develop.\n\nYou don\'t have to invest every available dollar the moment it becomes available.\n\nKeeping a small cash reserve isn\'t a sign of hesitation—it\'s a sign of preparation.\n\nWhen the market suddenly declines, that reserve gives you the freedom to buy quality companies at more attractive prices instead of watching great opportunities pass by.\n\nCash sitting on the sidelines isn\'t always idle money.\n\nSometimes it\'s future opportunity waiting for the right moment.'**
  String get verdictSectorDiversificationTier3Section1Body;

  /// No description provided for @verdictSectorDiversificationTier3Section2Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorDiversificationTier3Section2Label;

  /// No description provided for @verdictSectorDiversificationTier3Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Diversification protects you from relying on a single sector.\n\nA broad-market ETF spreads your risk across hundreds of companies.\n\nA small cash reserve gives you the flexibility to act when others are driven by fear.\n\nIndividually, these habits may seem simple.\n\nTogether, they create the kind of portfolio that is built not only to grow—but to endure.\n\nSuccessful investors don\'t prepare only for rising markets. They also prepare for the opportunities that appear when markets fall.'**
  String get verdictSectorDiversificationTier3Section2Body;

  /// No description provided for @verdictSectorDiversificationTier4Title.
  ///
  /// In en, this message translates to:
  /// **'Diversification Done Right'**
  String get verdictSectorDiversificationTier4Title;

  /// No description provided for @verdictSectorDiversificationTier4Intro.
  ///
  /// In en, this message translates to:
  /// **'You\'ve built a portfolio that reflects patience, balance, and long-term thinking.\n\nYour investments are spread across multiple sectors of the economy, reducing your dependence on any single industry or market trend. Rather than trying to predict one future winner, you\'ve prepared your portfolio for many possible outcomes.\n\nThis is exactly what diversification is designed to achieve.\n\nWhen technology slows down, healthcare may continue growing. When consumer spending weakens, utilities or defensive businesses may provide stability. No one knows which sector will lead next year, but your portfolio doesn\'t need to rely on a single prediction.\n\nYou\'ve built a structure that is designed to adapt rather than guess.\n\nThat is one of the strongest habits a long-term investor can develop.'**
  String get verdictSectorDiversificationTier4Intro;

  /// No description provided for @verdictSectorDiversificationTier4Section1Label.
  ///
  /// In en, this message translates to:
  /// **'One Important Reminder'**
  String get verdictSectorDiversificationTier4Section1Label;

  /// No description provided for @verdictSectorDiversificationTier4Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Good sector diversification doesn\'t automatically mean every investment is a good one.\n\nA portfolio can be perfectly diversified across industries while still containing companies with weak business models, excessive debt, declining revenues, or highly speculative business strategies.\n\nDiversification protects you from concentrating your money in one part of the economy.\n\nIt does not protect you from buying poor-quality businesses.\n\nThis is especially important when investing in highly speculative companies.\n\nEarly-stage biotechnology firms, pre-revenue startups, meme stocks, and businesses that rely more on future promises than proven results can experience extreme price swings. Some may become incredible success stories.\n\nMany others never reach profitability.\n\nOwning companies simply because they belong to different sectors isn\'t enough.\n\nEach investment should earn its place in your portfolio through the strength of its business, not just the excitement surrounding its story.'**
  String get verdictSectorDiversificationTier4Section1Body;

  /// No description provided for @verdictSectorDiversificationTier4Section2Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Make It Even Better?'**
  String get verdictSectorDiversificationTier4Section2Label;

  /// No description provided for @verdictSectorDiversificationTier4Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Continue reviewing your companies—not just your sector allocation.\n\nAsk yourself questions like:\n\nDoes this company have a sustainable business?\nIs it consistently generating revenue and profits?\nDoes it carry manageable debt?\nWould I still want to own this business if the share price stopped rising for several years?\n\nThese questions often reveal far more than a rising stock chart.\n\nRemember, diversification should never become an excuse to buy companies blindly.\n\nA portfolio filled with weak businesses doesn\'t become strong simply because they operate in different industries.'**
  String get verdictSectorDiversificationTier4Section2Body;

  /// No description provided for @verdictSectorDiversificationTier4Section3Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorDiversificationTier4Section3Label;

  /// No description provided for @verdictSectorDiversificationTier4Section3Body.
  ///
  /// In en, this message translates to:
  /// **'Diversification protects your portfolio.\n\nQuality protects your investments.\n\nDiscipline protects your future.\n\nWhen all three work together, you\'re no longer just buying stocks.\n\nYou\'re building an investment portfolio designed to grow, adapt, and endure for decades.'**
  String get verdictSectorDiversificationTier4Section3Body;

  /// No description provided for @verdictSectorDiversificationTier5Title.
  ///
  /// In en, this message translates to:
  /// **'From a Portfolio to a Zoo'**
  String get verdictSectorDiversificationTier5Title;

  /// No description provided for @verdictSectorDiversificationTier5Intro.
  ///
  /// In en, this message translates to:
  /// **'Diversification is one of the most important principles of long-term investing.\n\nBut like many good ideas, it can be taken too far.\n\nYour portfolio now contains so many individual companies that keeping track of them all becomes a challenge in itself.\n\nAt some point, diversification stops reducing risk and starts reducing your ability to understand what you actually own.\n\nAfter all, it\'s difficult to follow earnings reports, financial results, product launches, management changes, and industry developments for dozens of businesses at the same time.\n\nEventually, your investments begin managing you instead of the other way around.\n\nA well-built portfolio doesn\'t need to own everything.\n\nIt needs to own enough.'**
  String get verdictSectorDiversificationTier5Intro;

  /// No description provided for @verdictSectorDiversificationTier5Section1Label.
  ///
  /// In en, this message translates to:
  /// **'More Companies Doesn\'t Always Mean Less Risk'**
  String get verdictSectorDiversificationTier5Section1Label;

  /// No description provided for @verdictSectorDiversificationTier5Section1Body.
  ///
  /// In en, this message translates to:
  /// **'Many new investors believe that buying more stocks automatically makes a portfolio safer.\n\nIn reality, there comes a point where each additional company adds very little protection while making the portfolio significantly more difficult to understand and manage.\n\nImagine trying to care for three pets.\n\nThat\'s manageable.\n\nNow imagine trying to care for thirty.\n\nSooner or later, someone isn\'t getting enough attention.\n\nThe same happens with investments.\n\nIf you no longer remember why you bought a company—or don\'t notice when its business begins to deteriorate—it may no longer deserve a place in your portfolio.'**
  String get verdictSectorDiversificationTier5Section1Body;

  /// No description provided for @verdictSectorDiversificationTier5Section2Label.
  ///
  /// In en, this message translates to:
  /// **'Quality Always Comes Before Quantity'**
  String get verdictSectorDiversificationTier5Section2Label;

  /// No description provided for @verdictSectorDiversificationTier5Section2Body.
  ///
  /// In en, this message translates to:
  /// **'Owning thirty average businesses is rarely better than owning fifteen outstanding ones that you truly understand.\n\nEvery company in your portfolio should have a clear reason for being there.\n\nIf the only answer is...\n\n\"Because I wanted more diversification.\"\n\n...it may be worth asking whether that position is actually improving your portfolio—or simply making it more complicated.\n\nRemember, diversification is about reducing unnecessary risk.\n\nIt is not about collecting as many ticker symbols as possible.'**
  String get verdictSectorDiversificationTier5Section2Body;

  /// No description provided for @verdictSectorDiversificationTier5Section3Label.
  ///
  /// In en, this message translates to:
  /// **'How Can You Improve?'**
  String get verdictSectorDiversificationTier5Section3Label;

  /// No description provided for @verdictSectorDiversificationTier5Section3Body.
  ///
  /// In en, this message translates to:
  /// **'Take some time to review your holdings.\n\nAsk yourself:\n\nDo I still understand this company\'s business?\nWould I buy this company again today?\nDoes this investment add something unique to my portfolio?\nOr is it simply another company that overlaps with several others I already own?\n\nIf two companies serve nearly the same purpose, you may not need both.\n\nA simpler portfolio is often easier to monitor, easier to understand, and easier to stick with during difficult markets.'**
  String get verdictSectorDiversificationTier5Section3Body;

  /// No description provided for @verdictSectorDiversificationTier5Section4Label.
  ///
  /// In en, this message translates to:
  /// **'One Last Thought'**
  String get verdictSectorDiversificationTier5Section4Label;

  /// No description provided for @verdictSectorDiversificationTier5Section4Body.
  ///
  /// In en, this message translates to:
  /// **'A portfolio is not a stamp collection.\n\nYou don\'t earn extra points for owning the most companies.\n\nYou earn them by owning businesses you understand and are confident holding through both good times and bad.\n\nThe goal isn\'t to own everything. The goal is to know why you own each investment.'**
  String get verdictSectorDiversificationTier5Section4Body;

  /// No description provided for @verdictMarkerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available.'**
  String get verdictMarkerNotAvailable;

  /// No description provided for @verdictMarkerFeedbackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detailed feedback for {label} is coming soon.'**
  String verdictMarkerFeedbackComingSoon(String label);

  /// No description provided for @verdictTitle.
  ///
  /// In en, this message translates to:
  /// **'Verdict'**
  String get verdictTitle;

  /// No description provided for @verdictNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Verdict not available — complete the test first.'**
  String get verdictNotAvailable;

  /// No description provided for @verdictSessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'SESSION COMPLETE'**
  String get verdictSessionCompleteTitle;

  /// No description provided for @verdictContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get verdictContinueLearning;

  /// No description provided for @verdictBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get verdictBackToHome;

  /// No description provided for @verdictGuardianVerdictLabel.
  ///
  /// In en, this message translates to:
  /// **'GUARDIAN\'S VERDICT'**
  String get verdictGuardianVerdictLabel;

  /// No description provided for @verdictGuardianHeadline.
  ///
  /// In en, this message translates to:
  /// **'YOU MADE IT THROUGH'**
  String get verdictGuardianHeadline;

  /// No description provided for @verdictGuardianShortText.
  ///
  /// In en, this message translates to:
  /// **'Your stress test is complete. You experienced different market conditions and saw how your portfolio and decisions responded. Now it\'s time to see what your results reveal about your investment behavior.'**
  String get verdictGuardianShortText;

  /// No description provided for @verdictViewYourAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View your analysis →'**
  String get verdictViewYourAnalysis;

  /// No description provided for @verdictHoldingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get verdictHoldingsLabel;

  /// No description provided for @verdictFinalPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'Final P&L'**
  String get verdictFinalPnlLabel;

  /// No description provided for @verdictStartingCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Cash'**
  String get verdictStartingCashLabel;

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
