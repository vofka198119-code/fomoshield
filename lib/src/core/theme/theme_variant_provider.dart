import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// App theme variant — mirrors language_provider.dart's shape exactly.
// `standard` (today's light look) is the default for everyone; `luxuryGold`
// is the admin-only preview theme being built out molecule by molecule
// (see luxury_gold_theme.dart). Persisted so the choice survives restarts.
// ---------------------------------------------------------------------------

const _prefsKey = 'app_theme_variant';

enum AppThemeVariant { standard, luxuryGold }

class ThemeVariantNotifier extends StateNotifier<AppThemeVariant> {
  ThemeVariantNotifier() : super(AppThemeVariant.standard) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKey);
    final match = AppThemeVariant.values.where((v) => v.name == name);
    if (match.isNotEmpty) {
      state = match.first;
    }
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    state = variant;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, variant.name);
  }
}

final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, AppThemeVariant>(
      (ref) => ThemeVariantNotifier(),
    );
