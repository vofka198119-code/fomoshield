import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/supabase/supabase_providers.dart' show myNicknameProvider;
import '../../core/theme/theme_variant_provider.dart';
import '../../shared/services/finnhub_service.dart';
import '../disclaimer/disclaimer_providers.dart';
import '../home/home_providers.dart' show watchlistSymbolsProvider;
import '../home/widget_order_provider.dart' show homeWidgetsProvider;
import '../portfolio/portfolio_providers.dart' show portfoliosProvider;
import '../search/search_provider.dart' show searchProvider;
import '../search/search_counter_provider.dart' show searchCounterProvider;

// ---------------------------------------------------------------------------
// Supabase Session Check (for splash screen)
// ---------------------------------------------------------------------------
//
// Supabase's own SDK persists the session locally and restores it during
// Supabase.initialize() in main() — before this provider (or anything else)
// ever runs. This is the single source of truth for "is there a live
// session", for every sign-in method (email/password AND Google) alike.
// There is deliberately no separate stored-password/re-login mechanism —
// that used to exist here and caused a real bug: Google accounts have no
// password to replay, so they were always treated as "can't restore" and
// force-signed-out on every cold start (fixed 2026-08-14).

/// True if a valid Supabase session exists (user is logged in).
final hasSupabaseSessionProvider = FutureProvider<bool>((ref) async {
  final session = SupabaseConfig.client.auth.currentSession;
  return session != null;
});

// ---------------------------------------------------------------------------
// isLoggedIn — the user's own "Remember me" choice
// ---------------------------------------------------------------------------
//
// This does NOT gate whether a session can be restored (Supabase always
// restores its own session regardless). It gates whether SplashScreen
// honors that restored session or deliberately signs the user back out —
// i.e. "Remember me" unchecked means "don't keep me signed in past this
// app session", same intent for every sign-in method.

/// Whether user checked "Remember me" in a previous session.
/// Read by SplashScreen to decide: honor the restored Supabase session, or
/// sign out and send the user to /auth.
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
});

/// Sets the is_logged_in flag (call after successful login/signup).
Future<void> setIsLoggedIn(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', value);
}

// ---------------------------------------------------------------------------
// Session Data Cleanup — call on logout to prevent data leaks between accounts
// ---------------------------------------------------------------------------

/// Clears auth session data. Does NOT clear SharedPreferences (portfolios,
/// watchlist, widget order) so data persists for the next login under the
/// same email.
///
/// Also signs out of the native GoogleSignIn session (found 2026-09-19,
/// live on-device debugging a Play Store closed-testing round): this was
/// never called anywhere, so every sign-out only cleared the Supabase side
/// — the native Android Credential Manager session GoogleSignIn.instance
/// holds stayed alive underneath. The very next authenticate() call inside
/// that same still-alive native session behaved inconsistently (silent
/// failures with no error reaching Dart), which is why sign-in tended to
/// work once per fresh app install/process but broke on a sign-out-then-
/// sign-back-in cycle with the SAME process still running.
Future<void> clearAllSessionData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false);
  await SupabaseConfig.client.auth.signOut();
  try {
    await GoogleSignIn.instance.signOut();
  } catch (_) {
    // Not signed in via Google, or the plugin isn't initialized yet on
    // this path (e.g. signing out an email/password-only account) —
    // safe to ignore, this is best-effort cleanup only.
  }
}

/// Invalidates every cached provider that must not leak from one account
/// into the next — call this immediately before every [clearAllSessionData]
/// (all synchronous, no `await` between them, same reasoning as
/// profile_screen.dart's own sign-out buttons: signOut() fires the auth-
/// state stream that drives the router's session redirect, which can
/// dispose the caller mid-sequence and silently skip whatever came after).
///
/// Originally only profile_screen.dart's two sign-out buttons did this
/// (added 2026-09-16 after a stale myNicknameProvider let a new sign-in
/// skip the mandatory nickname gate). Three MORE sign-out call sites
/// existed without it — [resolveEntryRoute]'s "remember me" unchecked
/// path (hit on every cold start, including every `flutter run` restart
/// during dev testing), account_restore_screen.dart, and auth_screen
/// .dart's duplicate-email sign-up probe — found live 2026-09-18 when an
/// admin account got bounced back to the choose-nickname screen after a
/// plain account switch, because one of these paths left a DIFFERENT
/// account's stale (null) nickname cached. Consolidated into one function
/// so a future sign-out path can't independently forget a provider this
/// one already knows about.
void invalidateSessionScopedProviders(WidgetRef ref) {
  ref.invalidate(isLoggedInProvider);
  ref.invalidate(hasSupabaseSessionProvider);
  ref.invalidate(watchlistSymbolsProvider);
  ref.invalidate(portfoliosProvider);
  ref.invalidate(homeWidgetsProvider);
  ref.invalidate(searchProvider);
  ref.invalidate(searchCounterProvider);
  ref.invalidate(myNicknameProvider);
  ref.read(themeVariantProvider.notifier).resetToStandardForSignOut();
}

// ---------------------------------------------------------------------------
// Post-auth destination — shared by SplashScreen (cold-start session
// resume) and AuthScreen (email/password + Google sign-in), so a
// pending-deletion account is caught the same way no matter how the user
// ends up authenticated.
// ---------------------------------------------------------------------------

/// Resolves where a just-authenticated (or session-resumed) user should
/// land: the full-block Restore Account screen if this account is pending
/// deletion (2026-08-16, see profile_screen.dart's Delete Account flow),
/// otherwise the existing disclaimer-gate → home logic. A failed status
/// check (network hiccup) doesn't block sign-in — falls through to normal
/// resolution, same as every other non-critical startup check. `extra`
/// carries the deletion status through to AccountRestoreScreen when the
/// route is '/account-restore' — GoRouter's `extra:` param, not encoded in
/// the route string itself.
Future<({String route, Object? extra})> resolvePostAuthRoute(
  WidgetRef ref,
) async {
  // Theme is a device setting a prior sign-out may have temporarily reset
  // to Standard (see resetToStandardForSignOut's doc comment) — restore
  // whatever this device had saved, for whichever account just signed in.
  await ref.read(themeVariantProvider.notifier).restoreFromPrefs();
  try {
    final status = await FinnhubService().accountDeletionStatus();
    if (status.pendingDeletion) {
      return (route: '/account-restore', extra: status);
    }
  } catch (_) {
    // Ignore — see doc comment above.
  }
  final disclaimerAccepted = await ref.read(
    isDisclaimerAcceptedProvider.future,
  );
  // TEMP DEBUG 2026-09-20 — chasing a cross-account state leak on rapid
  // sign-out/sign-in switches (see mac_migration_gotchas memory). Remove
  // once confirmed fixed.
  debugPrint(
    '🚪 resolvePostAuthRoute: currentUser.id=${SupabaseConfig.client.auth.currentUser?.id} '
    'disclaimerAccepted=$disclaimerAccepted',
  );
  if (!disclaimerAccepted) return (route: '/disclaimer', extra: null);

  // Global account nickname (Migration 017) — mandatory, one-time. Checked
  // AFTER disclaimer so a not-yet-accepted account always sees that first.
  //
  // Force-invalidated right here (not just relying on the sign-out-time
  // invalidate in invalidateSessionScopedProviders) — found live 2026-09-20:
  // on a rapid sign-out → sign-in-as-different-account cycle, SOMETHING
  // (router redirect re-evaluation, most likely) reads myNicknameProvider
  // during the brief window where Supabase's currentUser is still null
  // (old session cleared, new one not yet set). That premature read short-
  // circuits to `return null` and gets cached by Riverpod — and since
  // nothing invalidates it again before this line runs, the mandatory-
  // nickname check below was consuming that stale null instead of ever
  // querying the new account's real nickname, incorrectly bouncing an
  // existing account to the choose-nickname screen.
  ref.invalidate(myNicknameProvider);
  final nickname = await ref.read(myNicknameProvider.future);
  debugPrint('🚪 resolvePostAuthRoute: nickname=$nickname');
  if (nickname == null) return (route: '/onboarding-choice', extra: null);

  return (route: '/home', extra: null);
}

// ---------------------------------------------------------------------------
// Entry route — the session-check half of SplashScreen's resolution,
// factored out so LanguageOnboardingScreen's "Continue" button can land an
// upgrading existing user exactly where Splash would have (straight to
// /home, or whatever gate is still pending) instead of hardcoding /auth,
// which would force a already-signed-in user back through login.
// ---------------------------------------------------------------------------

Future<({String route, Object? extra})> resolveEntryRoute(WidgetRef ref) async {
  final rememberMe = await ref.read(isLoggedInProvider.future);
  if (!rememberMe) {
    invalidateSessionScopedProviders(ref);
    await clearAllSessionData();
    return (route: '/auth', extra: null);
  }

  final hasSession = await ref.read(hasSupabaseSessionProvider.future);
  if (!hasSession) {
    return (route: '/auth', extra: null);
  }

  return resolvePostAuthRoute(ref);
}
