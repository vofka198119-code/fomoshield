import 'package:dio/dio.dart';

import 'auth_token.dart';

// ---------------------------------------------------------------------------
// One retry, with a new token, when the backend says 401.
//
// The check in freshAccessToken covers a token the phone KNOWS is expired.
// This covers the one it cannot know about: a phone whose clock runs behind
// the server's, where the token looks fine locally and is already dead
// remotely. The server's 401 is the only evidence, so the retry has to hang
// off the error.
//
// Safe to re-send anything: a 401 means the server rejected the request
// before doing any of it, so there is nothing to double up. Capped at one
// attempt per request via `extra`, which travels with the request and not
// with this object — two requests failing at once each get their own retry,
// and neither can loop.
// ---------------------------------------------------------------------------

class AuthRetryInterceptor extends Interceptor {
  final Dio dio;

  AuthRetryInterceptor(this.dio);

  static const _retriedKey = 'authRetried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    final token = await forceRefreshedAccessToken();
    // No session, or the refresh itself failed: the 401 is the honest answer
    // and the caller should see it rather than a silent second attempt.
    if (token == null) return handler.next(err);

    options.extra[_retriedKey] = true;
    try {
      // Through fetch, so the request interceptor re-attaches the token it
      // now finds in the session — the same path a first attempt takes.
      return handler.resolve(await dio.fetch(options));
    } on DioException catch (e) {
      return handler.next(e);
    }
  }
}
