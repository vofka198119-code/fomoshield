import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../supabase/supabase_providers.dart'
    show
        currentUserProvider,
        subscriptionTierProvider,
        subscriptionTierResolvedProvider,
        SubscriptionTierAccess;

// ---------------------------------------------------------------------------
// App theme variant — mirrors language_provider.dart's shape, but keyed
// PER ACCOUNT (not per device) — themes moved from admin-only to
// premium+admin 2026-09-18 (see profile_screen.dart's gating), and a
// device-wide key meant one account's theme visibly leaked into whichever
// account logged in next on the same phone (found live testing this same
// change, before it shipped — a real risk now that ordinary testers with
// multiple accounts on one device can hit this, not just the rare admin
// dev device the device-wide key was originally written for).
// `standard` (today's light look) is the default for everyone.
// ---------------------------------------------------------------------------

const _prefsKeyBase = 'app_theme_variant';

enum AppThemeVariant { standard, luxuryGold, blackWhite, graphite, midnightSea }

class ThemeVariantNotifier extends StateNotifier<AppThemeVariant> {
  final Ref _ref;
  bool _hasExplicitChoice = false;

  /// What this account actually PICKED, as opposed to what is on screen.
  /// The two diverge while the subscription is lapsed: every non-standard
  /// theme is a paid feature, so [_publish] shows Standard instead — but the
  /// pick is never erased from SharedPreferences, so resuming Premium brings
  /// the account's own theme straight back with no action from the user.
  /// Before this existed the applied theme simply survived expiry forever,
  /// which is how a lapsed account could still be sitting in Graphite
  /// (found during an end-of-term audit, 2026-09-28).
  AppThemeVariant _choice = AppThemeVariant.standard;

  /// True from [resetToStandardForSignOut] until the next [restoreFromPrefs]
  /// — blocks [applyAdminDefaultIfUnset] for that whole window. Without
  /// this, AppShell can rebuild (any of the several providers
  /// invalidateSessionScopedProviders touches can trigger one) WHILE
  /// `clearAllSessionData()`'s `signOut()` call is still in flight —
  /// `isAdminProvider` reads stale-true until Supabase's auth-state stream
  /// actually fires, so `applyAdminDefaultIfUnset` ran again mid-sign-out
  /// and silently reapplied Luxury Gold moments after the reset, right
  /// back over the standard background it just set (found live via
  /// [main.dart]'s own debug trace, 2026-09-18).
  bool _signedOut = false;

  /// The MOST RECENT load/restore operation — reassigned by
  /// [restoreFromPrefs] on every login, not just once at construction.
  /// [applyAdminDefaultIfUnset] awaits this (not a one-time constructor
  /// future) so it can't run its "unset" check against a stale
  /// [_hasExplicitChoice] left over from before the current account's own
  /// restore finished — that exact race (re-login racing this check)
  /// silently downgraded a real explicit choice back to Luxury Gold,
  /// found live 2026-09-18 testing the per-account scoping below.
  late Future<void> _pendingLoad;

  ThemeVariantNotifier(this._ref) : super(AppThemeVariant.standard) {
    _pendingLoad = _load();
    // Re-publish whenever the tier changes OR merely becomes known: a user
    // who is genuinely free produces no CHANGE in the tier value (free ->
    // free), only a change in whether that free is trustworthy yet, so
    // listening to the tier alone would miss exactly the downgrade case.
    _ref.listen(subscriptionTierProvider, (_, _) => _publish());
    _ref.listen(subscriptionTierResolvedProvider, (_, _) => _publish());
  }

  /// Pushes [_choice] to the screen, gated on the subscription.
  ///
  /// While the tier is still unknown the choice is shown as-is. Downgrading
  /// on an unresolved tier would flash a paying user back to Standard on
  /// every cold start, because the tier reads free until the DB answers —
  /// see [subscriptionTierResolvedProvider].
  void _publish() {
    if (_signedOut) return;
    final resolved = _ref.read(subscriptionTierResolvedProvider);
    final entitled = _ref.read(subscriptionTierProvider).isPremiumOrAdmin;
    state = (!resolved || entitled) ? _choice : AppThemeVariant.standard;
  }

  /// Scoped to whichever account is signed in RIGHT NOW — read fresh every
  /// time rather than cached, so it tracks account switches within the
  /// same app session (sign-out clears the session before any of these
  /// methods run again, and a fresh sign-in's [restoreFromPrefs] call
  /// picks up the new uid automatically).
  String get _prefsKey {
    final uid = _ref.read(currentUserProvider)?.id;
    return uid != null ? '${_prefsKeyBase}_$uid' : _prefsKeyBase;
  }

  Future<void> _applyPersistedChoice(SharedPreferences prefs) async {
    final name = prefs.getString(_prefsKey);
    final match = AppThemeVariant.values.where((v) => v.name == name);
    _hasExplicitChoice = match.isNotEmpty;
    if (match.isNotEmpty) _choice = match.first;
    _publish();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await _applyPersistedChoice(prefs);
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    _choice = variant;
    _publish();
    _hasExplicitChoice = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, variant.name);
  }

  /// Called on every login for an admin account. A fresh install/reinstall
  /// wipes SharedPreferences, so with no explicit local choice on record
  /// this would otherwise silently fall back to Standard every time —
  /// defaults straight into Luxury Gold instead. A no-op once any explicit
  /// choice has been made (including switching back to Standard), so it
  /// never fights a deliberate pick.
  Future<void> applyAdminDefaultIfUnset() async {
    if (_signedOut) return;
    await _pendingLoad;
    if (_signedOut || _hasExplicitChoice) return;
    _choice = AppThemeVariant.luxuryGold;
    _publish();
  }

  /// Forces the in-memory theme back to Standard on sign-out — signed-out
  /// screens (Auth, Disclaimer, onboarding) must never show whatever
  /// theme the previous account had selected (found live 2026-09-16:
  /// signing out of an admin account with a dark theme active left the
  /// Auth screen's background dark too, unreadable against its own
  /// hardcoded-standard text). Also clears [_hasExplicitChoice] since no
  /// account is signed in right now to own that flag; [restoreFromPrefs]
  /// re-derives both for whichever account signs in next.
  void resetToStandardForSignOut() {
    _choice = AppThemeVariant.standard;
    state = AppThemeVariant.standard;
    _signedOut = true;
  }

  /// Re-reads the persisted choice after a successful login, so a sign-out's
  /// [resetToStandardForSignOut] doesn't strand the device on Standard
  /// forever — whoever signs in next sees THEIR OWN saved theme (via
  /// [_prefsKey] reading the now-current uid), or Standard if this
  /// account has never explicitly picked one.
  Future<void> restoreFromPrefs() async {
    _signedOut = false;
    _choice = AppThemeVariant.standard;
    state = AppThemeVariant.standard;
    _hasExplicitChoice = false;
    _pendingLoad = _load();
    await _pendingLoad;
  }
}

final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, AppThemeVariant>(
      (ref) => ThemeVariantNotifier(ref),
    );
