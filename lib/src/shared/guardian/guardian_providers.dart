// ---------------------------------------------------------------------------
// Guardian Providers — Riverpod providers for GuardianIntelligenceEngine
// ---------------------------------------------------------------------------

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'guardian_engine.dart';

/// Future provider that initializes the GuardianIntelligenceEngine.
///
/// Usage:
/// ```dart
/// final engine = ref.watch(guardianEngineProvider);
/// engine.whenData((e) => e.selectMessage(...));
/// ```
final guardianEngineProvider =
    FutureProvider<GuardianIntelligenceEngine>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return GuardianIntelligenceEngine(prefs);
});
