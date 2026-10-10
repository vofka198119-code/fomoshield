import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/employee.dart';
import '../models/fund_vacancy.dart';
import '../models/fund_succession_offer.dart';
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
final myInvitationsProvider = FutureProvider.autoDispose<List<FundInvitation>>((
  ref,
) {
  return ref.watch(employeeApiServiceProvider).listMyInvitations();
});

/// Pending "the head went missing, want the fund?" offers (Phase B).
/// Watched alongside myInvitationsProvider on My Invitations — both are
/// "someone is offering you something, act before it expires".
final mySuccessionOffersProvider =
    FutureProvider.autoDispose<List<FundSuccessionOffer>>((ref) {
      return ref.watch(employeeApiServiceProvider).listMySuccessionOffers();
    });

/// A fund's roster — public, like the rest of a fund's data.
/// The exchange board — every open advert, for anyone. autoDispose so it is
/// re-read each time the screen is opened: an advert posted a minute ago by
/// somebody else should be there.
final vacancyBoardProvider = FutureProvider.autoDispose<List<FundVacancy>>((
  ref,
) {
  return ref.watch(employeeApiServiceProvider).listVacancyBoard();
});

/// One fund's own adverts, for its head.
final fundVacanciesProvider = FutureProvider.autoDispose
    .family<List<FundVacancy>, String>((ref, fundId) {
      return ref.watch(employeeApiServiceProvider).listFundVacancies(fundId);
    });

final fundTeamProvider = FutureProvider.autoDispose
    .family<List<FundTeamMember>, String>((ref, fundId) {
      return ref.watch(employeeApiServiceProvider).getTeam(fundId);
    });

/// "Companies I've worked for" — every stint, open or closed, newest first.
final myEmploymentHistoryProvider =
    FutureProvider.autoDispose<List<EmploymentRecord>>((ref) {
      return ref.watch(employeeApiServiceProvider).getMyEmploymentHistory();
    });
