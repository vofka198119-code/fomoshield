import 'package:dio/dio.dart';
import '../../../core/utils/constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/fund.dart';
import '../models/trade_proposal.dart';

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

class FundSubscribeResult {
  final double navPerUnit;
  final double unitsIssued;

  const FundSubscribeResult({required this.navPerUnit, required this.unitsIssued});

  factory FundSubscribeResult.fromJson(Map<String, dynamic> json) =>
      FundSubscribeResult(
        navPerUnit: (json['navPerUnit'] as num).toDouble(),
        unitsIssued: (json['unitsIssued'] as num).toDouble(),
      );
}

class FundRedeemResult {
  final double navPerUnit;
  final double payout;

  const FundRedeemResult({required this.navPerUnit, required this.payout});

  factory FundRedeemResult.fromJson(Map<String, dynamic> json) =>
      FundRedeemResult(
        navPerUnit: (json['navPerUnit'] as num).toDouble(),
        payout: (json['payout'] as num).toDouble(),
      );
}

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

  /// Admin-only dev tool — no other UI calls this yet. Head-only
  /// server-side (checked by head_user_id, same as [deleteFund]).
  Future<void> renameFund(String id, String name) async {
    try {
      await _dio.patch('/funds/$id', data: {'name': name});
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to rename fund'),
        code: code,
      );
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

  /// Buy fund units with real money straight out of the caller's own
  /// Portfolio cash (Phase 2 — no separate "Fund Investing" balance). The
  /// backend computes live NAV and atomically credits the fund's own cash/
  /// units_outstanding; the returned nav/units are the authoritative fill,
  /// which may drift a hair from whatever NAV was last shown on-screen.
  Future<FundSubscribeResult> subscribe(String fundId, double amount) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/subscribe',
        data: {'amount': amount},
      );
      return FundSubscribeResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to buy fund units'),
        code: code,
      );
    }
  }

  /// Sell fund units back for cash, credited to the caller's own Portfolio
  /// cash client-side. Always instant, in full, at the current NAV.
  Future<FundRedeemResult> redeem(String fundId, double units) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/redeem',
        data: {'units': units},
      );
      return FundRedeemResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to sell fund units'),
        code: code,
      );
    }
  }

  // ── Phase 4: trade proposals ──────────────────────────────────────────

  Future<TradeProposal> proposeTrade({
    required String fundId,
    required String symbol,
    required String side,
    required String orderType,
    double? limitPrice,
    required double quantity,
    String? justification,
  }) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals',
        data: {
          'symbol': symbol,
          'side': side,
          'orderType': orderType,
          'limitPrice': limitPrice,
          'quantity': quantity,
          'justification': justification,
        },
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to propose trade'),
        code: code,
      );
    }
  }

  Future<List<TradeProposal>> listProposals(String fundId) async {
    try {
      final response = await _dio.get('/funds/$fundId/proposals');
      final list = ((response.data as Map)['proposals'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(TradeProposal.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load proposals'));
    }
  }

  Future<TradeProposal> approveProposal(String fundId, String proposalId) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals/$proposalId/approve',
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to approve proposal'),
        code: code,
      );
    }
  }

  Future<TradeProposal> rejectProposal(
    String fundId,
    String proposalId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals/$proposalId/reject',
        data: {'reason': reason},
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to reject proposal'),
        code: code,
      );
    }
  }

  Future<TradeProposal> executeProposal(String fundId, String proposalId) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals/$proposalId/execute',
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to execute proposal'),
        code: code,
      );
    }
  }

  Future<TradeProposal> flagProposal(String fundId, String proposalId) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals/$proposalId/flag',
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to flag proposal'),
        code: code,
      );
    }
  }
}
