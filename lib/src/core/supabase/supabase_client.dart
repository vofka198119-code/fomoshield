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

  /// Convenience getter for the initialized Supabase client.
  static SupabaseClient get client => Supabase.instance.client;
}
