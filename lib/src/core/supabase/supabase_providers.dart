import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

// ---------------------------------------------------------------------------
// Auth state — streams the current Supabase session
// ---------------------------------------------------------------------------

/// Streams authentication state changes (login, logout, token refresh).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

/// The currently authenticated user, or null if not logged in.
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseConfig.client.auth.currentUser;
});

/// True while an auth operation (sign in / sign up) is in flight.
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Auth error message to display on the UI (null = no error).
final authErrorProvider = StateProvider<String?>((ref) => null);

// ---------------------------------------------------------------------------
// Setup completion check — reads is_setup_complete from the users table
// ---------------------------------------------------------------------------

/// Whether the current user has completed the full setup (PIN + disclaimer).
/// Returns `false` if not logged in or the fetch fails.
final isSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return false;

  try {
    final response = await SupabaseConfig.client
        .from('users')
        .select('is_setup_complete')
        .eq('id', user.id)
        .maybeSingle();
    return (response?['is_setup_complete'] as bool?) ?? false;
  } catch (_) {
    // If the DB call fails (offline, etc.), fall back to local check
    return false;
  }
});
