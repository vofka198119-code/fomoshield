import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/supabase/supabase_client.dart';

// ---------------------------------------------------------------------------
// Secure Storage instance (single shared instance)
// ---------------------------------------------------------------------------

const _secureStorage = FlutterSecureStorage();

// ---------------------------------------------------------------------------
// Supabase Session Check (for splash screen)
// ---------------------------------------------------------------------------

/// True if a valid Supabase session exists (user is logged in).
final hasSupabaseSessionProvider = FutureProvider<bool>((ref) async {
  final session = SupabaseConfig.client.auth.currentSession;
  return session != null;
});

// ---------------------------------------------------------------------------
// Remember Me — saved email + password in secure storage
// ---------------------------------------------------------------------------

class RememberMeCredentials {
  final String email;
  final String password;

  const RememberMeCredentials({required this.email, required this.password});
}

class RememberMeNotifier extends StateNotifier<RememberMeCredentials?> {
  RememberMeNotifier() : super(null) {
    _load();
  }

  static const _emailKey = 'saved_email';
  static const _passwordKey = 'saved_password';

  Future<void> _load() async {
    final email = await _secureStorage.read(key: _emailKey);
    final password = await _secureStorage.read(key: _passwordKey);
    if (email != null && password != null) {
      state = RememberMeCredentials(email: email, password: password);
    }
  }

  Future<void> save(String email, String password) async {
    await _secureStorage.write(key: _emailKey, value: email);
    await _secureStorage.write(key: _passwordKey, value: password);
    state = RememberMeCredentials(email: email, password: password);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _emailKey);
    await _secureStorage.delete(key: _passwordKey);
    state = null;
  }
}

final rememberMeProvider =
    StateNotifierProvider<RememberMeNotifier, RememberMeCredentials?>((ref) {
  return RememberMeNotifier();
});

/// Reads saved credentials directly from secure storage (for splash screen).
final savedCredentialsProvider = FutureProvider<RememberMeCredentials?>((ref) async {
  final email = await _secureStorage.read(key: RememberMeNotifier._emailKey);
  final password = await _secureStorage.read(key: RememberMeNotifier._passwordKey);
  if (email != null && password != null) {
    return RememberMeCredentials(email: email, password: password);
  }
  return null;
});

// ---------------------------------------------------------------------------
// isLoggedIn — the ONLY flag that controls auto-login on splash
// True ONLY if user checked "Remember Me" and login succeeded.
// ---------------------------------------------------------------------------

/// Whether user checked "Remember me" in a previous session.
/// Read by SplashScreen to decide: go to /auth or auto-login.
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_logged_in') ?? false;
});

/// Sets the is_logged_in flag (call after successful login with Remember Me).
Future<void> setIsLoggedIn(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', value);
}

// ---------------------------------------------------------------------------
// Session Data Cleanup — call on logout to prevent data leaks between accounts
// ---------------------------------------------------------------------------

/// Clears auth session data and credentials.
/// Does NOT clear SharedPreferences (portfolios, watchlist, widget order)
/// so data persists for the next login under the same email.
Future<void> clearAllSessionData() async {
  // 1) Clear Remember Me credentials from FlutterSecureStorage
  await _secureStorage.delete(key: RememberMeNotifier._emailKey);
  await _secureStorage.delete(key: RememberMeNotifier._passwordKey);

  // 2) Clear is_logged_in flag
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_logged_in', false);

  // 3) Sign out from Supabase
  await SupabaseConfig.client.auth.signOut();
}
