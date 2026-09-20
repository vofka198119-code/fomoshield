import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';

/// True once the app has opened a password-recovery deep link this
/// process (`AuthChangeEvent.passwordRecovery` from Supabase's own auth
/// stream) — read synchronously by app_router.dart's `redirect` callback,
/// which can't await a Future or watch a Riverpod provider directly.
///
/// Supabase's SDK treats a recovery link like any other magic-link sign-in
/// (it creates a real, live session) but tags the resulting event
/// differently so the app can tell "just opened the reset-password link"
/// apart from "signed in normally" — without this, the router would just
/// send the user to Home instead of the set-new-password screen.
bool isInPasswordRecovery = false;

/// Call once, right after `Supabase.initialize()` in main() — mirrors how
/// GoogleSignIn.instance.initialize() is set up once at startup rather
/// than per-screen.
void initPasswordRecoveryListener() {
  SupabaseConfig.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.passwordRecovery) {
      isInPasswordRecovery = true;
    }
  });
}
