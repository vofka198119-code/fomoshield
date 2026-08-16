import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Search Provider with 500ms Debounce
// ---------------------------------------------------------------------------

final searchProvider = ChangeNotifierProvider<SearchNotifier>(
  (ref) => SearchNotifier(ref.read(finnhubServiceProvider)),
);

/// Kept as a type instead of a raw error string — this provider has no
/// BuildContext to localize through, so the UI layer (search_screen.dart)
/// maps this to the actual displayed text via AppLocalizations.
enum SearchErrorType {
  connectionTimeout,
  serverNotResponding,
  noInternet,
  rateLimited,
  generic,
}

class SearchNotifier extends ChangeNotifier {
  final FinnhubService _api;
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  String query = '';
  SearchErrorType? errorType;
  Timer? _debounce;

  // Bumped on every keystroke; a pending request only applies its result if
  // it's still the most recent one when it resolves — otherwise a slow
  // response for an older query could land after (and overwrite) a faster
  // response for a newer one.
  int _requestId = 0;

  SearchNotifier(this._api);

  /// Called on every keystroke — debounces 500ms before actual API call
  void onSearchInput(String q) {
    query = q;
    errorType = null;
    _debounce?.cancel();
    final requestId = ++_requestId;

    if (q.length < 2) {
      results = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      List<Map<String, dynamic>> newResults = [];
      SearchErrorType? newError;
      try {
        newResults = await _api.searchLocal(q);
      } catch (e) {
        debugPrint('❌ Search error for "$q": $e');
        if (e is DioException) {
          switch (e.type) {
            case DioExceptionType.connectionTimeout:
              newError = SearchErrorType.connectionTimeout;
            case DioExceptionType.receiveTimeout:
              newError = SearchErrorType.serverNotResponding;
            case DioExceptionType.connectionError:
              newError = SearchErrorType.noInternet;
            case DioExceptionType.badResponse:
              newError = e.response?.statusCode == 429
                  ? SearchErrorType.rateLimited
                  : SearchErrorType.generic;
            default:
              newError = SearchErrorType.generic;
          }
        }
      }

      if (requestId != _requestId) return; // superseded by a newer keystroke

      results = newResults;
      errorType = newError;
      isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
