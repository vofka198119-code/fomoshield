import 'package:supabase_flutter/supabase_flutter.dart';

/// F.O.M.O. Shield Supabase configuration.
///
/// All Supabase credentials are defined here in one place.
/// In production, move these to environment variables / .env file.
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectUrl = 'https://zbtcpgbelupoybgrwuub.supabase.co';
  static const String anonKey =
      'sb_publishable_dMlya9CVQ-0D9V5ukNzCQg_E0m9P-Lx';

  // Google Sign-In OAuth client IDs (from Google Cloud Console).
  // Not secrets — safe to ship in the client. The matching Client Secret
  // lives only in the Supabase dashboard's Google provider settings.
  static const String googleWebClientId =
      '699824108192-i554s8fpj2sq7tav0lvs2fdhct1igfhv.apps.googleusercontent.com';
  static const String googleIosClientId =
      '699824108192-a7adcpgfj8dqfvth9otl6c7up5vn1s7k.apps.googleusercontent.com';

  /// Convenience getter for the initialized Supabase client.
  static SupabaseClient get client => Supabase.instance.client;
}
