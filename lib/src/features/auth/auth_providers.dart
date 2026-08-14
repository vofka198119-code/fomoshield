import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_client.dart';

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
Future<void> clearAllSessionData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false);
  await SupabaseConfig.client.auth.signOut();
}
