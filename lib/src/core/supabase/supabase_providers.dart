import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

// ---------------------------------------------------------------------------
// Admin email for testing — hardcoded until remote config is implemented
// ---------------------------------------------------------------------------

/// Email that unlocks the Admin Sandbox panel.
const String adminEmail = 'fomoshield@gmail.com';

// ---------------------------------------------------------------------------
// Subscription tier
// ---------------------------------------------------------------------------

/// Subscription tier enum.
enum SubscriptionTier { free, premium, admin }

/// Internal state — holds the subscription tier fetched from the DB.
/// Updated asynchronously by [_premiumLoaderProvider].
final _dbSubscriptionTierProvider = StateProvider<SubscriptionTier?>(
  (ref) => null,
);

/// Loads subscription_tier and expiry from public.users on login.
/// Re-runs automatically when currentUserProvider changes.
final _premiumLoaderProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    ref.read(_dbSubscriptionTierProvider.notifier).state = null;
    return;
  }
  // Admin is detected synchronously, no need for DB call
  if (user.email == adminEmail) return;

  try {
    final response = await SupabaseConfig.client
        .from('users')
        .select('subscription_tier, subscription_expires_at')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      final tier = response['subscription_tier'] as String?;
      if (tier == 'premium') {
        final expiresAtStr = response['subscription_expires_at'] as String?;
        if (expiresAtStr != null) {
          final expiresAt = DateTime.tryParse(expiresAtStr);
          if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
            ref.read(_dbSubscriptionTierProvider.notifier).state =
                SubscriptionTier.premium;
            return;
          }
        } else {
          // NULL expiry = lifetime premium
          ref.read(_dbSubscriptionTierProvider.notifier).state =
              SubscriptionTier.premium;
          return;
        }
      }
    }
    ref.read(_dbSubscriptionTierProvider.notifier).state =
        SubscriptionTier.free;
  } catch (_) {
    // DB unavailable — keep state as null (falls back to free)
  }
});

/// Debug override — allows admin to temporarily test as Free/Premium.
/// Set to `null` (default) to use real tier logic.
final debugTierOverrideProvider = StateProvider<SubscriptionTier?>(
  (ref) => null,
);

/// Returns the subscription tier for the current user.
/// 1. [debugTierOverrideProvider] wins when non-null (admin testing)
/// 2. Admin email → admin (hardcoded)
/// 3. DB-fetched premium → premium (from public.users table)
/// 4. Everything else → free
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  // Debug override takes precedence (admin testing)
  final override = ref.watch(debugTierOverrideProvider);
  if (override != null) return override;

  final user = ref.watch(currentUserProvider);
  if (user == null) return SubscriptionTier.free;
  if (user.email == adminEmail) return SubscriptionTier.admin;

  // Trigger DB load (runs once, re-runs on user change)
  ref.watch(_premiumLoaderProvider);

  // Read fetched value
  final dbTier = ref.watch(_dbSubscriptionTierProvider);
  if (dbTier != null) return dbTier;

  return SubscriptionTier.free;
});

/// True if the current user is an admin (matches hardcoded admin email).
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email == adminEmail;
});

// ---------------------------------------------------------------------------
// Premium details for the Profile screen gold card
// ---------------------------------------------------------------------------

/// Detailed premium subscription info fetched from the DB.
class PremiumDetails {
  final DateTime? expiresAt;
  final int daysRemaining;

  PremiumDetails({this.expiresAt})
    : daysRemaining = expiresAt != null
          ? DateTime.now().difference(expiresAt).inDays.abs()
          : 365; // NULL = lifetime, show 365+

  bool get isLifetime => expiresAt == null;
  bool get isExpired {
    final exp = expiresAt;
    return exp != null && exp.isBefore(DateTime.now());
  }
}

/// Fetches premium details (expiry, days left) from public.users.
final premiumDetailsProvider = FutureProvider<PremiumDetails?>((ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return null;

  try {
    final response = await SupabaseConfig.client
        .from('users')
        .select('subscription_tier, subscription_expires_at')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    if (response['subscription_tier'] != 'premium') return null;

    final expiresAtStr = response['subscription_expires_at'] as String?;
    return PremiumDetails(
      expiresAt: expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null,
    );
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// Auth state — streams the current Supabase session
// ---------------------------------------------------------------------------

/// Streams authentication state changes (login, logout, token refresh).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.client.auth.onAuthStateChange;
});

/// The currently authenticated user, or null if not logged in.
/// Watches authStateProvider so it reactively updates on login/logout.
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
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
