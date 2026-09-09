import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';

// ---------------------------------------------------------------------------
// Fund Team Card — the real roster (ETF Fund Emulation, Phase 3), replacing
// the old "Employees: —" stub row in FundInfoCard. Public — anyone viewing
// the fund sees who's on the team (design doc's insider-holding
// transparency requirement). The head-only "Hire"/"Remove" actions are
// gated on `isHead`, passed in from FundDetailScreen (already resolves
// currentUserProvider vs fund.headUserId for the delete button, same
// check).
// ---------------------------------------------------------------------------

String _roleLabel(AppLocalizations l10n, String role) {
  switch (role) {
    case 'co_manager':
      return l10n.etfRoleCoManager;
    case 'trader':
      return l10n.etfRoleTrader;
    case 'risk_manager':
      return l10n.etfRoleRiskManager;
    default:
      return l10n.etfRoleAnalyst;
  }
}

class FundTeamCard extends ConsumerWidget {
  final String fundId;
  final bool isHead;
  final AppPalette palette;

  const FundTeamCard({
    super.key,
    required this.fundId,
    required this.isHead,
    required this.palette,
  });

  Future<void> _confirmTerminate(
    BuildContext context,
    WidgetRef ref,
    FundTeamMember member,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          l10n.etfTeamMemberTerminateConfirmTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(l10n.etfTeamMemberTerminateConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.etfTeamMemberTerminateConfirmAction,
              style: const TextStyle(color: ThemeV2.loss),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(employeeApiServiceProvider)
          .terminateTeamMember(fundId, member.userId);
      ref.invalidate(fundTeamProvider(fundId));
    } catch (_) {
      // Best-effort — the roster just won't reflect it; user can retry.
    }
  }

  Future<void> _cancelTermination(WidgetRef ref, FundTeamMember member) async {
    try {
      await ref
          .read(employeeApiServiceProvider)
          .cancelTermination(fundId, member.userId);
      ref.invalidate(fundTeamProvider(fundId));
    } catch (_) {
      // Best-effort, same as above.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final teamAsync = ref.watch(fundTeamProvider(fundId));

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              themedHeaderText(
                l10n.etfFundDetailEmployeesLabel,
                palette,
                FomoShieldTheme.cardTitle(),
              ),
              if (isHead)
                TextButton(
                  onPressed: () => context.push('/funds/$fundId/marketplace'),
                  child: Text(
                    l10n.etfFundDetailHireButton,
                    style: GoogleFonts.inter(
                      color: palette.accentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 12),
          teamAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (team) {
              if (team.isEmpty) {
                return Text(
                  l10n.etfFundDetailEmployeesStub,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: palette.textBody,
                  ),
                );
              }
              return Column(
                children: [
                  for (final member in team)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.nickname ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textHeader,
                                  ),
                                ),
                                Text(
                                  member.isPendingTermination
                                      ? l10n
                                          .etfTeamMemberPendingTerminationLabel
                                      : _roleLabel(l10n, member.role),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: member.isPendingTermination
                                        ? ThemeV2.loss
                                        : palette.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isHead)
                            member.isPendingTermination
                                ? TextButton(
                                    onPressed: () =>
                                        _cancelTermination(ref, member),
                                    child: Text(
                                      l10n
                                          .etfTeamMemberCancelTerminationButton,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: palette.accentPrimary,
                                      ),
                                    ),
                                  )
                                : TextButton(
                                    onPressed: () => _confirmTerminate(
                                      context,
                                      ref,
                                      member,
                                    ),
                                    child: Text(
                                      l10n.etfTeamMemberTerminateButton,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: ThemeV2.loss,
                                      ),
                                    ),
                                  ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
