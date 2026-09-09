import 'package:dio/dio.dart';
import '../../../core/utils/constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../models/employee.dart';
import 'fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Employee API Service — talks to scanco-backend's /api/v1/employees and
// /api/v1/invitations routes (ETF Fund Emulation, Phase 3). Same lean-Dio-
// client shape as FundApiService, for the same reason (infrequent one-offs,
// not the bursty-batch traffic FinnhubService is tuned for).
// ---------------------------------------------------------------------------

class EmployeeApiService {
  final Dio _dio;

  EmployeeApiService()
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

  FundApiException _apiException(DioException e, String fallback) {
    final data = e.response?.data;
    final code = data is Map ? data['code'] as String? : null;
    return FundApiException(_errorMessage(e, fallback), code: code);
  }

  /// Null when the caller has never created a profile yet (backend 404s).
  Future<EmployeeProfile?> getMyProfile() async {
    try {
      final response = await _dio.get('/employees/me');
      return EmployeeProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(_errorMessage(e, 'Failed to load profile'));
    }
  }

  Future<EmployeeProfile> saveMyProfile({
    required String nickname,
    String? bio,
    String? language,
    required bool availableForHire,
  }) async {
    try {
      final response = await _dio.put(
        '/employees/me',
        data: {
          'nickname': nickname,
          'bio': bio,
          'language': language,
          'availableForHire': availableForHire,
        },
      );
      return EmployeeProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to save profile');
    }
  }

  Future<List<EmployeeProfile>> listMarketplace({String? excludeFundId}) async {
    try {
      final response = await _dio.get(
        '/employees',
        queryParameters: excludeFundId != null
            ? {'excludeFundId': excludeFundId}
            : null,
      );
      final list = ((response.data as Map)['profiles'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(EmployeeProfile.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load marketplace'));
    }
  }

  Future<List<FundInvitation>> listMyInvitations() async {
    try {
      final response = await _dio.get('/invitations/me');
      final list = ((response.data as Map)['invitations'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(FundInvitation.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load invitations'));
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      await _dio.post('/invitations/$invitationId/accept');
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to accept invitation');
    }
  }

  Future<void> declineInvitation(String invitationId) async {
    try {
      await _dio.post('/invitations/$invitationId/decline');
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to decline invitation');
    }
  }

  Future<void> cancelInvitation(String fundId, String invitationId) async {
    try {
      await _dio.post('/funds/$fundId/invitations/$invitationId/cancel');
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to cancel invitation');
    }
  }

  Future<FundInvitation> sendInvitation({
    required String fundId,
    required String inviteeUserId,
    required String role,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/funds/$fundId/invitations',
        data: {
          'inviteeUserId': inviteeUserId,
          'role': role,
          'message': message,
        },
      );
      return FundInvitation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to send invitation');
    }
  }

  Future<List<FundTeamMember>> getTeam(String fundId) async {
    try {
      final response = await _dio.get('/funds/$fundId/team');
      final list = ((response.data as Map)['team'] as List)
          .cast<Map<String, dynamic>>();
      return list.map(FundTeamMember.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to load team'));
    }
  }

  Future<FundTeamMember> updateTeamMember({
    required String fundId,
    required String userId,
    String? role,
    Map<String, bool>? permissions,
    double? treasurerLimitAmount,
  }) async {
    try {
      final response = await _dio.patch(
        '/funds/$fundId/team/$userId',
        data: {
          'role': ?role,
          'permissions': ?permissions,
          'treasurerLimitAmount': ?treasurerLimitAmount,
        },
      );
      return FundTeamMember.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to update team member');
    }
  }

  Future<void> terminateTeamMember(String fundId, String userId) async {
    try {
      await _dio.post('/funds/$fundId/team/$userId/terminate');
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to terminate team member');
    }
  }

  Future<void> cancelTermination(String fundId, String userId) async {
    try {
      await _dio.post('/funds/$fundId/team/$userId/cancel-termination');
    } on DioException catch (e) {
      throw _apiException(e, 'Failed to cancel termination');
    }
  }
}
