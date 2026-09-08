import 'package:dio/dio.dart';
import '../../../core/utils/constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/fund.dart';

/// A fund-creation/validation error from the backend, carrying the stable
/// `code` field (e.g. "name_taken") alongside the raw (English, log-only)
/// `message` — callers switch on [code] to show a localized string and
/// highlight the right form field, instead of surfacing [message] directly
/// (that used to happen and shipped an untranslated error with no field
/// highlighted — found live 2026-09-06).
class FundApiException implements Exception {
  final String message;
  final String? code;

  FundApiException(this.message, {this.code});

  @override
  String toString() => message;
}

// ---------------------------------------------------------------------------
// Fund API Service — talks to scanco-backend's /api/v1/funds routes
// (ETF Fund Emulation, Phase 1). A separate, lean Dio client rather than
// reusing FinnhubService: that class's caching/rate-limiting machinery is
// tuned for bursty Finnhub-proxy reads (company logos/quotes across a whole
// list at once); fund create/list/detail calls are infrequent one-offs,
// including a POST, so they don't need any of that. Same base
// URL/auth-header/JWT-interceptor setup as FinnhubService for consistency.
// ---------------------------------------------------------------------------

class FundApiService {
  final Dio _dio;

  FundApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: '${AppConstants.backendBaseUrl}/api/v1',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: AppConstants.backendApiKey.isEmpty
              ? null
              : {'X-API-Key': AppConstants.backendApiKey},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Read the current session token fresh on every request — see
          // FinnhubService's identical comment on why this can't be cached.
          final accessToken =
              SupabaseConfig.client.auth.currentSession?.accessToken;
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
      ),
    );
  }

  String _errorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) return data['error'] as String;
    return fallback;
  }

  Future<List<String>> getSectors() async {
    try {
      final response = await _dio.get('/funds/sectors');
      return ((response.data as Map)['sectors'] as List)
          .map((e) => e as String)
          .toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load sectors'));
    }
  }

  Future<Fund> createFund({
    required String name,
    required String ticker,
    String? description,
    String? strategy,
    required List<String> sectors,
    required double startingCapital,
  }) async {
    try {
      final response = await _dio.post(
        '/funds',
        data: {
          'name': name,
          'ticker': ticker,
          'description': description,
          'strategy': strategy,
          'sectors': sectors,
          'startingCapital': startingCapital,
        },
      );
      return Fund.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to create fund'),
        code: code,
      );
    }
  }

  Future<List<Fund>> listFunds() async {
    try {
      final response = await _dio.get('/funds');
      final list = ((response.data as Map)['funds'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(Fund.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load funds'));
    }
  }

  Future<void> deleteFund(String id) async {
    try {
      await _dio.delete('/funds/$id');
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to delete fund'));
    }
  }

  Future<FundDetail> getFundDetail(String id) async {
    try {
      final response = await _dio.get('/funds/$id');
      return FundDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load fund'));
    }
  }
}
