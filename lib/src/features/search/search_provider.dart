import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/finnhub_service.dart';

// ---------------------------------------------------------------------------
// Search Provider with 500ms Debounce
// ---------------------------------------------------------------------------

final searchProvider = ChangeNotifierProvider<SearchNotifier>(
  (ref) => SearchNotifier(),
);

class SearchNotifier extends ChangeNotifier {
  final FinnhubService _api = FinnhubService();
  List<Map<String, dynamic>> results = [];
  List<String> recentSearches = [];
  bool isLoading = false;
  String query = '';
  String? errorMessage;
  Timer? _debounce;

  SearchNotifier();

  /// Called on every keystroke — debounces 500ms before actual API call
  void onSearchInput(String q) {
    query = q;
    errorMessage = null;
    _debounce?.cancel();

    if (q.length < 2) {
      results = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        results = await _api.search(q);
        errorMessage = null;
      } catch (e) {
        debugPrint('❌ Search error for "$q": $e');
        if (e is DioException && e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timed out. Check your internet.';
        } else if (e is DioException && e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Server not responding. Try again.';
        } else if (e.toString().contains('API') ||
            e.toString().contains('limit') ||
            e.toString().contains('rate')) {
          errorMessage = 'API limit reached. Please try again later.';
        } else {
          errorMessage = null; // quiet fail for non-API errors
        }
        results = [];
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void selectCompany(String symbol) {
    if (!recentSearches.contains(symbol)) {
      recentSearches.insert(0, symbol);
      if (recentSearches.length > 10) recentSearches.removeLast();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
