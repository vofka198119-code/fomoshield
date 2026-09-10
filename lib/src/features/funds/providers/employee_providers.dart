import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee.dart';
import '../services/employee_api_service.dart';

final employeeApiServiceProvider = Provider<EmployeeApiService>((ref) {
  return EmployeeApiService();
});

/// The caller's own analyst profile — null (not an error) when they've
/// never created one yet. Deliberately NOT autoDispose — same reasoning as
/// fundsListProvider (see its doc comment): Home's FundEntryWidget remounts
/// on every return to Home, and autoDispose meant it always restarted from
/// `loading` (no value) for a frame, flashing the pre-profile label before
/// flipping to the real one. employee_profile_screen.dart already
/// ref.invalidates this after a successful save.
final myEmployeeProfileProvider = FutureProvider<EmployeeProfile?>((ref) {
  return ref.watch(employeeApiServiceProvider).getMyProfile();
});

/// The hiring marketplace — pass a fundId to also drop that fund's current
/// roster from the results (no point showing a head someone already
/// hired). Family key is nullable-friendly via the empty-string sentinel
/// since Riverpod family params can't be null directly.
final employeeMarketplaceProvider = FutureProvider.autoDispose
    .family<List<EmployeeProfile>, String?>((ref, excludeFundId) {
      return ref
          .watch(employeeApiServiceProvider)
          .listMarketplace(excludeFundId: excludeFundId);
    });

/// The caller's own pending invite envelopes.
final myInvitationsProvider =
    FutureProvider.autoDispose<List<FundInvitation>>((ref) {
      return ref.watch(employeeApiServiceProvider).listMyInvitations();
    });

/// A fund's roster — public, like the rest of a fund's data.
final fundTeamProvider = FutureProvider.autoDispose
    .family<List<FundTeamMember>, String>((ref, fundId) {
      return ref.watch(employeeApiServiceProvider).getTeam(fundId);
    });
