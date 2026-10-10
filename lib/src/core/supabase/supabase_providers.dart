import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

// ---------------------------------------------------------------------------
// Admin emails for testing — hardcoded until remote config is implemented
// ---------------------------------------------------------------------------

/// Email that unlocks the Admin Sandbox panel. The primary one, kept as its
/// own constant for anywhere that means *the* admin rather than "is this an
/// admin" — use [isAdminEmail] for the latter.
const String adminEmail = 'fomoshield@gmail.com';

/// A second address, added 2026-10-10. The fund team features — hiring,
/// permissions, the treasurer's budget — cannot be exercised by one account
/// at all: somebody has to be the employee, and the Funds module redirects
/// every non-admin away from /funds (see funds_visibility.dart and
/// app_router's own redirect). Both addresses here belong to the author, so
/// the module stays exactly as closed to real users as it was behind one.
const String adminEmailSecondary = 'vofka198119@gmail.com';

const List<String> adminEmails = [adminEmail, adminEmailSecondary];

/// Case-insensitive on purpose: a sign-in form will take
/// "Fomoshield@Gmail.com" without complaint, and an address differing only
/// in case is the same mailbox. The same trap already cost a premium grant
/// in Supabase, which had to be rewritten with ILIKE.
bool isAdminEmail(String? email) {
  if (email == null) return false;
  final normalized = email.trim().toLowerCase();
  return adminEmails.any((candidate) => candidate == normalized);
}

// ---------------------------------------------------------------------------
// Subscription tier
// ---------------------------------------------------------------------------

/// Subscription tier enum.
enum SubscriptionTier { free, premium, admin }

extension SubscriptionTierAccess on SubscriptionTier {
  /// True for premium or admin — the single predicate for "has premium
  /// access", used everywhere a feature is gated on paid status. Was
  /// re-derived inline as `tier == SubscriptionTier.premium || tier ==
  /// SubscriptionTier.admin` (or the equivalent isPremium-then-OR-isAdmin
  /// shape) at 12+ call sites — a future tier (e.g. a trial tier) needs
  /// updating in exactly one place now instead of an N-site sweep.
  bool get isPremiumOrAdmin =>
      this == SubscriptionTier.premium || this == SubscriptionTier.admin;
}

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
  if (isAdminEmail(user.email)) return;

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

/// Returns the subscription tier for the current user.
/// 1. Admin email → admin (hardcoded)
/// 2. DB-fetched premium → premium (from public.users table)
/// 3. Everything else → free
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return SubscriptionTier.free;
  if (isAdminEmail(user.email)) return SubscriptionTier.admin;

  // Trigger DB load (runs once, re-runs on user change)
  ref.watch(_premiumLoaderProvider);

  // Read fetched value
  final dbTier = ref.watch(_dbSubscriptionTierProvider);
  if (dbTier != null) return dbTier;

  return SubscriptionTier.free;
});

/// True once the tier is actually KNOWN, as opposed to merely defaulting.
///
/// [subscriptionTierProvider] reports `free` while the DB fetch behind it is
/// still in flight (see [_premiumLoaderProvider]), which is harmless for
/// anything that GRANTS on premium — it just re-renders once the real tier
/// lands. It is not harmless for anything that TAKES SOMETHING AWAY on a
/// free reading: acting on that early free would punish a paying user for
/// the length of a network round-trip on every cold start. Gate any such
/// downgrade on this provider first.
final subscriptionTierResolvedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  // Signed out: free is the final answer, nothing is pending.
  if (user == null) return true;
  // Admin is decided synchronously from the email, no fetch involved.
  if (isAdminEmail(user.email)) return true;
  ref.watch(_premiumLoaderProvider);
  return ref.watch(_dbSubscriptionTierProvider) != null;
});

/// True if the current user is an admin (one of [adminEmails]).
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return isAdminEmail(user?.email);
});

/// Awaits the async DB fetch behind [subscriptionTierProvider] so a caller
/// gets the REAL tier instead of racing it. Reading subscriptionTierProvider
/// before the fetch resolves silently returns SubscriptionTier.free (see
/// _premiumLoaderProvider above) — harmless for most UI (it just re-renders
/// once the real tier lands) but wrong for a one-shot decision like "show
/// this ad now", which never gets a second chance. Confirmed live 2026-09-25:
/// the App Open ad's fixed post-splash delay wasn't always enough to beat
/// the DB round-trip, so it fired for a premium tester and (rarer — auth
/// session restore, not the DB fetch) an admin account. Bounded by [timeout]
/// so a stuck/offline fetch can't hang the caller forever — falls back to
/// whatever's cached (free, if nothing loaded yet) same as before.
Future<SubscriptionTier> resolveSubscriptionTier(
  WidgetRef ref, {
  Duration timeout = const Duration(seconds: 6),
}) async {
  // Supabase.initialize() in main() already awaits local session restore,
  // so currentUser is normally populated by the first frame — this only
  // matters on the rare device where that still lags.
  if (ref.read(currentUserProvider) == null) {
    try {
      await ref
          .read(authStateProvider.future)
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // timeout or no session — fall through, still not logged in
    }
  }

  final user = ref.read(currentUserProvider);
  if (user != null && !isAdminEmail(user.email)) {
    try {
      await ref.read(_premiumLoaderProvider.future).timeout(timeout);
    } catch (_) {
      // timeout or DB error — fall through with whatever's cached
    }
  }

  return ref.read(subscriptionTierProvider);
}

/// Forces a fresh subscription_tier/subscription_expires_at fetch from
/// Supabase — call right after a Play Billing purchase is verified
/// server-side (see purchase_service.dart) so the UI reflects premium
/// immediately instead of waiting for whatever next triggers
/// [_premiumLoaderProvider] on its own. [_premiumLoaderProvider] is
/// private to this file, so this is the one exported way for other
/// features to ask for a re-fetch.
void refreshSubscriptionTier(WidgetRef ref) {
  ref.invalidate(_premiumLoaderProvider);
}

// ---------------------------------------------------------------------------
// Premium details for the Profile screen gold card
// ---------------------------------------------------------------------------

/// Detailed premium subscription info fetched from the DB.
class PremiumDetails {
  final DateTime? expiresAt;
  final int daysRemaining;

  PremiumDetails({this.expiresAt})
    : daysRemaining = expiresAt == null
          ? 365 // NULL = lifetime, show 365+
          : _daysUntil(expiresAt);

  // Clamped at 0 rather than going negative once expired — .abs() used to
  // be here, which reported "N days remaining" for a subscription that
  // actually expired N days ago instead of 0.
  static int _daysUntil(DateTime expiresAt) {
    final days = expiresAt.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

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

  // Admin status is a hardcoded-email override (see isAdminProvider above),
  // not necessarily reflected in the DB's subscription_tier — always
  // lifetime, regardless of what that row says.
  if (isAdminEmail(user.email)) return PremiumDetails();

  try {
    final response = await SupabaseConfig.client
        .from('users')
        .select('subscription_tier, subscription_expires_at')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) return null;
    final tier = response['subscription_tier'];
    if (tier != 'premium' && tier != 'admin') return null;

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

// ---------------------------------------------------------------------------
// Global account nickname (Migration 017) — one persistent handle per user,
// chosen once via ChooseNicknameScreen and never editable after. Stored on
// public.users so it survives a reinstall (unlike anything in
// SharedPreferences) — see that screen's own doc comment for the full flow.
// ---------------------------------------------------------------------------

/// The current user's chosen nickname, or null if they haven't set one yet.
final myNicknameProvider = FutureProvider<String?>((ref) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return null;

  final response = await SupabaseConfig.client
      .from('users')
      .select('nickname')
      .eq('id', user.id)
      .maybeSingle();
  return response?['nickname'] as String?;
});

/// Regex enforced both here (client-side, for instant feedback) and by the
/// `users_nickname_format` CHECK constraint in Migration 017 — Latin
/// letters/digits/underscore only, 1-25 chars.
final RegExp nicknamePattern = RegExp(r'^[A-Za-z0-9_]{1,25}$');

/// Attempts to set the current user's nickname. Throws
/// [NicknameTakenException] on a uniqueness conflict (Postgres 23505 from
/// the `users_nickname_unique_idx` case-insensitive index) — checked by
/// attempting the write and reading the error back, not a separate
/// pre-check call, so there's no check-then-write race.
Future<void> setMyNickname(String nickname) async {
  final user = SupabaseConfig.client.auth.currentUser;
  if (user == null) return;
  try {
    await SupabaseConfig.client
        .from('users')
        .update({'nickname': nickname})
        .eq('id', user.id);
  } on PostgrestException catch (e) {
    if (e.code == '23505') throw NicknameTakenException();
    rethrow;
  }
}

class NicknameTakenException implements Exception {}
