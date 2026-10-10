import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/supabase/supabase_providers.dart'
    show currentUserProvider, isAdminProvider;
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/admin_badge.dart';
import '../../../shared/widgets/card_frame.dart';
import '../fund_labels.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import 'team_member_permissions_sheet.dart';

// ---------------------------------------------------------------------------
// Fund Team Card — the real roster (ETF Fund Emulation, Phase 3), replacing
// the old "Employees: —" stub row in FundInfoCard. Public — anyone viewing
// the fund sees who's on the team (design doc's insider-holding
// transparency requirement). The head-only "Hire"/"Remove" actions are
// gated on `isHead`, passed in from FundDetailScreen (already resolves
// currentUserProvider vs fund.headUserId for the delete button, same
// check).
// ---------------------------------------------------------------------------

/// The spend-alone limit belongs on the roster line and not only inside the
/// permissions sheet: it is the one setting that lets someone trade without
/// the head, and a head should see who holds one without opening four
/// sheets. Shown to the head alone -- the roster itself is public, and who
/// may spend what inside the team is the head's business.
String _roleWithBudget(
  AppLocalizations l10n,
  FundTeamMember member, {
  required bool showBudget,
}) {
  final role = _roleLabel(l10n, member.role);
  final budget = member.treasurerLimitAmount;
  if (!showBudget || budget == null || budget <= 0) return role;
  return '$role · '
      '${l10n.etfTreasurerBudgetBadge(treasurerBudgetMoney(budget))}';
}

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
  // The head is never a fund_team_members row (see fundTradeService.js --
  // full authority on their own fund without one), so the real roster
  // list below never includes them. Shown as the card's own first,
  // unremovable entry instead (2026-09-14 ask: "уже можно прописать
  // владельца фонда"), even while the team is otherwise empty.
  final String? headNickname;
  // Distinct from [isHead], which callers can hardcode false to hide
  // hire/fire actions (e.g. the public FundDetailScreen) regardless of who
  // is actually looking -- the admin badge instead needs to know for real
  // whether the CURRENT viewer is this fund's head, so it still shows on
  // that same public screen when the head is looking at their own fund.
  final String? headUserId;

  const FundTeamCard({
    super.key,
    required this.fundId,
    required this.isHead,
    required this.palette,
    this.headNickname,
    this.headUserId,
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
        content: Text(
          l10n.etfTeamMemberTerminateConfirmBody,
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.profileCancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.etfTeamMemberTerminateConfirmAction,
              style: GoogleFonts.inter(color: ThemeV2.loss),
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
    // "мой админ значок" (2026-09-14) -- same self-view-only precedent as
    // EmployeeIdentityCard's own badge (there's no lookup yet for whether
    // an ARBITRARY other user is the admin account, only the current
    // session's own status), so this only ever lights up for the admin
    // looking at a fund where they themselves are the head.
    final viewerId = ref.watch(currentUserProvider)?.id;
    final viewerIsAdmin = ref.watch(isAdminProvider);
    final showHeadAdminBadge =
        viewerIsAdmin && headUserId != null && viewerId == headUserId;

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
                l10n.etfFundDetailEmployeesLabel.toUpperCase(),
                palette,
                FomoShieldTheme.cardTitle(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 12),
          _memberRow(
            nickname: headNickname,
            roleLabel: l10n.etfRoleHead,
            roleColor: palette.textBody,
            nameBadge: showHeadAdminBadge ? const AdminBadge() : null,
          ),
          teamAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (team) {
              if (team.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  for (final member in team)
                    _memberRow(
                      onTap: isHead && !member.isPendingTermination
                          ? () => _openPermissions(context, ref, member)
                          : null,
                      nickname: member.nickname,
                      roleLabel: member.isPendingTermination
                          ? l10n.etfTeamMemberPendingTerminationLabel
                          : _roleWithBudget(l10n, member, showBudget: isHead),
                      roleColor: member.isPendingTermination
                          ? ThemeV2.loss
                          : palette.textBody,
                      trailing: !isHead
                          ? null
                          : member.isPendingTermination
                          ? TextButton(
                              onPressed: () => _cancelTermination(ref, member),
                              child: Text(
                                l10n.etfTeamMemberCancelTerminationButton,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: palette.accentPrimary,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed: () =>
                                  _confirmTerminate(context, ref, member),
                              child: Text(
                                l10n.etfTeamMemberTerminateButton,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: ThemeV2.loss,
                                ),
                              ),
                            ),
                    ),
                ],
              );
            },
          ),
          // A real button, at the bottom of the card, the way every other
          // fund card offers its action (fund_rebalance_card.dart and
          // fund_allocation_summary_card.dart both do exactly this). The
          // word used to sit in the header as plain text on the right and
          // did not read as something you could press -- his words,
          // 2026-10-10.
          if (isHead) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: brandCtaButton(
                palette: palette,
                label: l10n.etfFundTeamHireFullButton,
                onTap: () =>
                    context.push('/funds/exchange?fund=$fundId&tab=candidates'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Refreshes the roster however the sheet closed, not only on a saved
  /// result: changing a ROLE saves immediately inside the sheet, so a head
  /// who changes a role and then dismisses without touching the switches
  /// has still changed something the list is showing.
  Future<void> _openPermissions(
    BuildContext context,
    WidgetRef ref,
    FundTeamMember member,
  ) async {
    await showTeamMemberPermissionsSheet(
      context: context,
      ref: ref,
      fundId: fundId,
      member: member,
      palette: palette,
    );
    ref.invalidate(fundTeamProvider(fundId));
  }

  Widget _memberRow({
    required String? nickname,
    required String roleLabel,
    required Color roleColor,
    Widget? nameBadge,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // Only the head ever passes onTap, and only for a member who isn't on
    // their way out -- everyone else gets the same plain row as before.
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nickname ?? '—',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                    ),
                    if (nameBadge != null) ...[
                      const SizedBox(width: 6),
                      nameBadge,
                    ],
                  ],
                ),
                Text(
                  roleLabel,
                  style: GoogleFonts.inter(fontSize: 12, color: roleColor),
                ),
              ],
            ),
          ),
          // Without this the row gives no sign it can be opened at all --
          // the trailing slot already holds the Remove button, so the tap
          // target would have been invisible. Shown only when the row is
          // actually tappable.
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.tune_rounded,
                size: 16,
                color: palette.accentPrimary,
              ),
            ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      borderRadius: ThemeV2.borderRadiusMedium,
      onTap: onTap,
      child: row,
    );
  }
}
