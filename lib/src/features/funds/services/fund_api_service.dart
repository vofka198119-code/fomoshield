import 'package:dio/dio.dart';
import '../../../core/utils/constants.dart';
import '../../../core/supabase/auth_retry_interceptor.dart';
import '../../../core/supabase/auth_token.dart';
import '../models/rebalance_leg.dart';
import '../models/fund.dart';
import '../models/fund_target_weight.dart';
import '../models/fund_balance_history.dart';
import '../models/fund_bankruptcy_preview.dart';
import '../models/fund_commission_history.dart';
import '../models/fund_investor.dart';
import '../models/fund_investor_flows.dart';
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
        onRequest: (options, handler) async {
          // Not just "read it fresh" — WAIT for a valid one. A token restored
          // from disk at launch can already be expired, and that is what made
          // the app's first screen fail while a retry worked (2026-10-09, see
          // freshAccessToken).
          final accessToken = await freshAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          handler.next(options);
        },
      ),
    );
    // Last in the chain: it only ever acts on an error the others let
    // through.
    _dio.interceptors.add(AuthRetryInterceptor(_dio));
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
  /// Edits a fund's descriptive fields. Each is optional — an omitted one
  /// is left untouched server-side, so a caller may save just the field
  /// the user changed. Name, ticker and starting capital are NOT editable
  /// here: the name has renameFund (uniqueness checks), and the other two
  /// are deliberately immutable (see updateFundDetails in the backend's
  /// fundService.js for why).
  Future<void> updateFundDetails(
    String id, {
    String? description,
    String? strategy,
    List<String>? sectors,
  }) async {
    try {
      await _dio.patch(
        '/funds/$id/details',
        data: {
          'description': ?description,
          'strategy': ?strategy,
          'sectors': ?sectors,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to update fund'),
        code: code,
      );
    }
  }

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

  /// The liquidation payout plan, computed but not written -- powers the
  /// bankruptcy confirm flow's explanation sheet with real numbers.
  Future<FundBankruptcyPreview> previewBankruptcy(String id) async {
    try {
      final response = await _dio.get('/funds/$id/bankruptcy-preview');
      return FundBankruptcyPreview.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to preview liquidation'),
        code: code,
      );
    }
  }

  /// Sells every holding, pays active employees + investors, marks the
  /// fund 'bankrupt'. Real payouts land in a server-side ledger the
  /// recipients' own clients claim on next load (no server write path to
  /// a user's personal Portfolio cash) -- see
  /// fomoshield_etf_bankruptcy_flow_spec memory.
  Future<void> triggerBankruptcy(String id) async {
    try {
      await _dio.post('/funds/$id/bankruptcy');
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to liquidate fund'),
        code: code,
      );
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

  /// Head + active team members only — server-gated, unlike listProposals'
  /// wider permission set (see fundService.js's getFundInvestors). Already
  /// sorted by net invested descending.
  Future<List<FundInvestor>> getFundInvestors(String fundId) async {
    try {
      final response = await _dio.get('/funds/$fundId/investors');
      final list = ((response.data as Map)['investors'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(FundInvestor.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load investors'));
    }
  }

  /// Same access gate as getFundInvestors. [year] defaults server-side to
  /// the current calendar year.
  Future<FundInvestorFlows> getFundInvestorFlows(
    String fundId, {
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        '/funds/$fundId/investor-flows',
        queryParameters: year != null ? {'year': year} : null,
      );
      return FundInvestorFlows.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load investor flows'));
    }
  }

  /// Same access gate as getFundInvestors. [year] defaults server-side to
  /// the current calendar year.
  Future<FundBalanceHistory> getFundBalanceHistory(
    String fundId, {
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        '/funds/$fundId/balance-history',
        queryParameters: year != null ? {'year': year} : null,
      );
      return FundBalanceHistory.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load balance history'));
    }
  }

  /// Same access gate as getFundInvestors. [year] defaults server-side to
  /// the current calendar year.
  Future<FundCommissionHistory> getFundCommissionHistory(
    String fundId, {
    int? year,
  }) async {
    try {
      final response = await _dio.get(
        '/funds/$fundId/commission-history',
        queryParameters: year != null ? {'year': year} : null,
      );
      return FundCommissionHistory.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load commission history'));
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

  /// The fund's target allocation. Insiders only server-side — the head and
  /// any active team member; an outside investor gets a 403, since the plan
  /// is internal even though the holdings themselves are public.
  Future<List<FundTargetWeight>> getFundTargets(String fundId) async {
    try {
      final response = await _dio.get('/funds/$fundId/targets');
      final list = ((response.data as Map)['targets'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(FundTargetWeight.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load targets'));
    }
  }

  /// Replaces the whole set at once — the server takes a complete picture,
  /// not a patch, because the percentages only mean anything relative to
  /// each other. An empty list clears the plan. Requires canSetTargets.
  Future<List<FundTargetWeight>> setFundTargets(
    String fundId,
    List<FundTargetWeight> targets,
  ) async {
    try {
      final response = await _dio.put(
        '/funds/$fundId/targets',
        data: {'targets': targets.map((t) => t.toJson()).toList()},
      );
      final list = ((response.data as Map)['targets'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(FundTargetWeight.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to save targets'));
    }
  }

  /// What a rebalance WOULD do — the plan, before anyone commits to it.
  /// Changes nothing on the server.
  Future<RebalancePlan> previewRebalance(
    String fundId,
    String mode, {
    /// Companies the head has unticked — left exactly as they are.
    List<String> exclude = const [],

    /// 'cash' mode only: spend at most this much of the free cash.
    double? amount,
  }) async {
    try {
      final response = await _dio.get(
        '/funds/$fundId/rebalance',
        queryParameters: {
          'mode': mode,
          if (exclude.isNotEmpty) 'exclude': exclude.join(','),
          'amount': ?amount,
        },
      );
      return RebalancePlan.fromJson((response.data as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to plan the rebalance'));
    }
  }

  /// Files that plan as ONE proposal carrying every leg (Migration 035), for
  /// the fund's usual approval chain. Returns how many trades are in it.
  Future<int> proposeRebalance(
    String fundId,
    String mode, {
    String? justification,
    List<String> exclude = const [],
    double? amount,
  }) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/rebalance',
        // The same choices the preview was drawn with, so what is filed is
        // what he was looking at.
        data: {
          'mode': mode,
          'justification': ?justification,
          if (exclude.isNotEmpty) 'exclude': exclude,
          'amount': ?amount,
        },
      );
      return ((response.data as Map)['legCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to propose the rebalance'));
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

  Future<TradeProposal> reworkProposal(
    String fundId,
    String proposalId, {
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/proposals/$proposalId/rework',
        data: {'reason': reason},
      );
      return TradeProposal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map ? data['code'] as String? : null;
      throw FundApiException(
        _errorMessage(e, 'Failed to send proposal back for revision'),
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
