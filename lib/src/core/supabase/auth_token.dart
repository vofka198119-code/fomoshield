import 'supabase_client.dart';

// ---------------------------------------------------------------------------
// The token every backend client sends, and the one thing that has to be true
// about it: the server will still accept it.
//
// Reading `currentSession?.accessToken` straight was not enough. The session
// is restored from disk at launch, and if the app sat closed past the token's
// hour, what comes back is an EXPIRED token. supabase_flutter does refresh it
// — but as a separate async step, so the app's first requests leave before it
// lands and the server answers 401. Caught on the server 2026-10-09:
//
//   [supabaseAuth] token verification failed: "exp" claim timestamp check
//
// at 13:31:34 and 16:40:05 UTC — both moments the app was being opened, both
// seen on the phone as "не удалось загрузить фонд" on the first screen, gone
// on a pull-to-refresh once the background refresh had finished.
//
// So: ask whether the token is still good, and wait for a new one when it is
// not. gotrue's own `isExpired` carries a 30-second margin, which also covers
// a token that would die mid-flight, and concurrent refreshes of the same
// token are collapsed into one request inside gotrue — a screen firing six
// calls at once does not cause six refreshes.
// ---------------------------------------------------------------------------

/// How long to wait for a refresh before giving up and sending what we have.
/// On a dead connection the refresh cannot succeed anyway, and a request that
/// hangs on the auth step looks exactly like a frozen screen.
const _refreshBudget = Duration(seconds: 6);

/// A valid access token, or null when nobody is signed in.
Future<String?> freshAccessToken() async {
  final auth = SupabaseConfig.client.auth;
  final session = auth.currentSession;
  if (session == null) return null;
  if (!session.isExpired) return session.accessToken;

  try {
    final refreshed = await auth.refreshSession().timeout(_refreshBudget);
    return refreshed.session?.accessToken ?? auth.currentSession?.accessToken;
  } catch (_) {
    // Offline, too slow, or a refresh token the server has retired. Sending
    // the expired one keeps the old behaviour for that request — a 401 the
    // caller already knows how to show — rather than silently dropping the
    // Authorization header, which would read to the server as "not signed
    // in at all" and hide a real session behind the wrong error.
    return auth.currentSession?.accessToken ?? session.accessToken;
  }
}

/// Forces a refresh regardless of what the stored token claims about itself,
/// for the one case the check above cannot see: a phone whose clock is behind
/// the server's. The token then looks valid here and is already expired
/// there, and no amount of local arithmetic will reveal it — only the
/// server's 401 does.
Future<String?> forceRefreshedAccessToken() async {
  final auth = SupabaseConfig.client.auth;
  if (auth.currentSession == null) return null;
  try {
    final refreshed = await auth.refreshSession().timeout(_refreshBudget);
    return refreshed.session?.accessToken;
  } catch (_) {
    return null;
  }
}
