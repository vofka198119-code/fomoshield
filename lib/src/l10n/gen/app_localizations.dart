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
