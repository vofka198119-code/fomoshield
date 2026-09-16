import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// App theme variant — mirrors language_provider.dart's shape exactly.
// `standard` (today's light look) is the default for everyone; `luxuryGold`
// is the admin-only preview theme being built out molecule by molecule
// (see luxury_gold_theme.dart). Persisted so the choice survives restarts.
// ---------------------------------------------------------------------------

const _prefsKey = 'app_theme_variant';

enum AppThemeVariant { standard, luxuryGold, blackWhite, graphite, midnightSea }

class ThemeVariantNotifier extends StateNotifier<AppThemeVariant> {
  bool _hasExplicitChoice = false;
  late final Future<void> _loaded;

  ThemeVariantNotifier() : super(AppThemeVariant.standard) {
    _loaded = _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKey);
    final match = AppThemeVariant.values.where((v) => v.name == name);
    if (match.isNotEmpty) {
      _hasExplicitChoice = true;
      state = match.first;
    }
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    state = variant;
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
    await _loaded;
    if (_hasExplicitChoice) return;
    state = AppThemeVariant.luxuryGold;
  }

  /// Forces the in-memory theme back to Standard without touching the
  /// persisted choice or [_hasExplicitChoice] — call on sign-out. This is a
  /// DEVICE-wide setting, not account-scoped, so signed-out screens
  /// (Auth, Disclaimer, onboarding) must never show whatever theme the
  /// previous session had selected (found live 2026-09-16: signing out of
  /// an admin account with a dark theme active left the Auth screen's
  /// background dark too, unreadable against its own hardcoded-standard
  /// text). [restoreFromPrefs] undoes this on the next successful login.
  void resetToStandardForSignOut() {
    state = AppThemeVariant.standard;
  }

  /// Re-reads the persisted choice after a successful login, so a sign-out's
  /// [resetToStandardForSignOut] doesn't strand the device on Standard
  /// forever — whoever signs in next sees this device's last saved theme,
  /// same as before sign-out ever touched it.
  Future<void> restoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKey);
    final match = AppThemeVariant.values.where((v) => v.name == name);
    if (match.isNotEmpty) state = match.first;
  }
}

final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, AppThemeVariant>(
      (ref) => ThemeVariantNotifier(),
    );
