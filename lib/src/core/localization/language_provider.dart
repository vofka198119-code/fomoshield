import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// App language override — null means "follow the device's system locale"
// (MaterialApp.locale accepts null for exactly that), a Locale means the
// user picked one explicitly in Profile → Language. Persisted so the
// choice survives app restarts; SharedPreferences key intentionally
// separate from every other stored preference in the app.
// ---------------------------------------------------------------------------

const _prefsKey = 'app_locale_override';

/// Locale codes the app actually ships translations for — MaterialApp
/// falls back to the first of these (English) for anything else the
/// device might report, so this list must stay in sync with
/// supportedLocales in main.dart and the .arb files in lib/src/l10n/.
const supportedLanguageCodes = ['en', 'ru'];

class LanguageNotifier extends StateNotifier<Locale?> {
  LanguageNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supportedLanguageCodes.contains(code)) {
      state = Locale(code);
    }
  }

  /// Sets an explicit language override. Pass `null` to go back to
  /// following the system locale.
  Future<void> setLanguage(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, Locale?>(
  (ref) => LanguageNotifier(),
);
