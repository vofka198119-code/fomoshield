import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart'
    show
        isAdminProvider,
        myNicknameProvider,
        setMyNickname,
        nicknamePattern,
        NicknameTakenException;
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../shared/widgets/circle_shortcut_row.dart';
import '../../../shared/widgets/widget_container.dart';
import '../models/employee.dart';
import '../providers/employee_providers.dart';
import '../widgets/company_history_tile.dart';
import '../widgets/rating_stars_row.dart';
import '../widgets/employee_identity_card.dart';

// ---------------------------------------------------------------------------
// Employee Hub — the analyst's own landing point once a profile exists
// (Home's "My Profile" tile routes here now, not straight to the profile
// form — 2026-09-10, per the reference mockups the author shared). Name
// card up top (EmployeeIdentityCard, shared with EmployeeProfileScreen),
// then a circle-shortcut row to jump anywhere in "the profile" from one
// starting screen — reuses CircleShortcutRow so adding a 5th/6th shortcut
// later is a one-line addition, not a redesign.
//
// Profile and My Invitations are real destinations; Vacancies/My
// Applications are ComingSoonScreen stubs — the "analyst applies to an
// open posting" direction is a new, not-yet-built mechanic that runs
// ALONGSIDE the existing "head browses analysts and invites" direction
// (EmployeeMarketplaceScreen), not a replacement — per the author's own
// call: relying on heads alone to reach out would leave too many analyst
// profiles never contacted.
//
// Admin-only dev tools (2026-09-11, explicit ask — "мне как для
// разработчика нужно больше функций"): the AppBar's ⋮ action (only the
// hardcoded admin account ever sees it) opens the same header-actions-
// sheet Portfolio uses for its own ⋮ menu — rename this nickname past the
// normal one-time gate (reuses setMyNickname/ChooseNicknameScreen's own
// validation, just callable again), and jump straight to fund creation
// bypassing the normal "already have a fund → redirect to it" shortcut
// (the backend already exempts admin from the one-fund-per-user cap —
// see assertUnderFundLimit in fundService.js — the client just never
// offered a way back into /funds/create once a fund existed).
// ---------------------------------------------------------------------------

class EmployeeHubScreen extends ConsumerWidget {
  const EmployeeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final invitationsCount =
        ref.watch(myInvitationsProvider).valueOrNull?.length ?? 0;
    final isAdmin = ref.watch(isAdminProvider);
    final profile = ref.watch(myEmployeeProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfEmployeeHubTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: themedGoldGradient(
                Icon(
                  Icons.more_vert,
                  color: palette.windowGradient == null
                      ? ThemeV2.textSecondary
                      : palette.accentPrimary,
                  shadows: palette.titleShadow != null
                      ? [palette.titleShadow!]
                      : null,
                ),
                palette,
              ),
              onPressed: () => _showAdminActionsSheet(context, ref, palette),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            EmployeeIdentityCard(palette: palette),
            CircleShortcutRow(
              palette: palette,
              items: [
                CircleShortcut(
                  icon: Icons.badge_rounded,
                  label: l10n.etfEmployeeProfileButtonLabel,
                  onTap: () => context.push('/funds/employee-profile'),
                ),
                CircleShortcut(
                  icon: Icons.mail_rounded,
                  label: invitationsCount > 0
                      ? '${l10n.etfEmployeeHubInvitationsRow} ($invitationsCount)'
                      : l10n.etfEmployeeHubInvitationsRow,
                  onTap: () => context.push('/funds/invitations'),
                ),
                CircleShortcut(
                  icon: Icons.work_outline_rounded,
                  label: l10n.etfHomeCardTitleVacancies,
                  onTap: () => context.push('/funds/vacancies'),
                ),
                CircleShortcut(
                  icon: Icons.assignment_outlined,
                  label: l10n.etfEmployeeHubApplicationsRow,
                  onTap: () => context.push('/funds/my-applications'),
                ),
              ],
            ),
            if (profile != null) ...[
              const SizedBox(height: 20),
              _companiesWidget(context, ref, palette, l10n),
              const SizedBox(height: 16),
              _ratingCard(palette, l10n, profile.rating),
              const SizedBox(height: 16),
              _statsCard(palette, l10n, profile),
            ],
          ],
        ),
      ),
    );
  }

  // Same role list + label mapping as send_invite_sheet.dart's own role
  // selector — no shared helper exists across these call sites yet
  // (fund_team_card.dart, invitation_detail_sheet.dart, send_invite_sheet.dart
  // each keep their own copy), matching that existing convention.
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

  // Same 5-visible + WidgetContainer "More" recipe as
  // portfolio_trade_history_widget.dart — hidden entirely (not an empty
  // card) when there's no history yet, same as that widget does for zero
  // transactions.
  Widget _companiesWidget(
    BuildContext context,
    WidgetRef ref,
    AppPalette palette,
    AppLocalizations l10n,
  ) {
    final history = ref.watch(myEmploymentHistoryProvider).valueOrNull ?? [];
    if (history.isEmpty) return const SizedBox.shrink();
    final displayed = history.take(5).toList();
    final hasMore = history.length > 5;

    return WidgetContainer(
      title: l10n.etfEmployeeHubCompaniesTitle,
      showFooter: hasMore,
      footerText: l10n.commonMoreCount(history.length - 5),
      palette: palette,
      onTap: hasMore ? () => context.push('/funds/employment-history') : null,
      children: displayed
          .map(
            (record) => CompanyHistoryTile(
              fundName: record.fundName ?? record.fundTicker ?? '—',
              fundTicker: record.fundTicker ?? '',
              roleLabel: _roleLabel(l10n, record.role),
              isActive: record.isActive,
              palette: palette,
              onTap: () => context.push(
                '/funds/employment-history/detail',
                extra: record,
              ),
            ),
          )
          .toList(),
    );
  }

  // Moved here from EmployeeProfileScreen's form (2026-09-11) — read-only
  // career record belongs on the hub landing point, not buried in the
  // editable "Анкета" form.
  // Header/divider/body layout matches target_widget.dart's own CardFrame
  // recipe exactly (padding: zero on the frame, title padded on its own,
  // themedDivider between title and body, body padded separately) — the
  // Career Record/Rating cards were missing the divider every other
  // light-card widget in the app has between its title and body.
  Widget _statsCard(
    AppPalette palette,
    AppLocalizations l10n,
    EmployeeProfile profile,
  ) {
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: themedHeaderText(
              l10n.etfEmployeeProfileStatsTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          themedDivider(palette),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow(
                  palette,
                  l10n.etfEmployeeProfileStatsApproved,
                  '${profile.approvedProposalsCount}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  palette,
                  l10n.etfEmployeeProfileStatsRejected,
                  '${profile.rejectedProposalsCount}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  palette,
                  l10n.etfEmployeeProfileStatsFundsChanged,
                  '${profile.fundsChangedCount}',
                ),
                const SizedBox(height: 8),
                _statRow(
                  palette,
                  l10n.etfEmployeeProfileStatsRegisteredAt,
                  DateFormat.yMMMd(
                    l10n.localeName,
                  ).format(profile.createdAt.toLocal()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Above the career-stats card (explicit ask, 2026-09-12) — the rating
  // used to be one more stat row there; pulled out into its own card since
  // a 0-10 star rating with a fractional fill genuinely needs the room a
  // plain label/value row doesn't have.
  Widget _ratingCard(AppPalette palette, AppLocalizations l10n, double? rating) {
    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: themedHeaderText(
              l10n.etfEmployeeProfileRatingCardTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
          ),
          themedDivider(palette),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RatingStarsRow(rating: rating, palette: palette),
                    const Spacer(),
                    Text(
                      '${(rating ?? 0).toStringAsFixed(1)}/${RatingStarsRow.starCount}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: palette.textHeader,
                      ),
                    ),
                  ],
                ),
                if (rating == null) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.etfEmployeeProfileRatingPending,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: palette.textBody,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(AppPalette palette, String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
      ),
      Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: palette.textHeader,
        ),
      ),
    ],
  );

  // Same "Add Widgets"/Portfolio-⋮ sheet recipe (handle bar, themedBorder +
  // windowGradient rows) as portfolio_screen.dart's own
  // _showPortfolioActionsSheet — not a native PopupMenuButton, which can't
  // render this app's gradient border/window fill.
  void _showAdminActionsSheet(
    BuildContext context,
    WidgetRef ref,
    AppPalette palette,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isLuxury = palette.windowGradient != null;
    final radius = BorderRadius.circular(14);

    Widget row({
      required IconData icon,
      required Color color,
      required String label,
      required VoidCallback onTap,
    }) {
      final content = ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: isLuxury
            ? themedBorder(
                palette: palette,
                borderRadius: radius,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: palette.windowGradient,
                    borderRadius: radius,
                  ),
                  child: content,
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: ThemeV2.surfaceDark,
                  borderRadius: radius,
                  border: Border.all(color: Colors.black12),
                ),
                child: content,
              ),
      );
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: palette.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom:
              MediaQuery.of(sheetContext).viewInsets.bottom +
              MediaQuery.of(sheetContext).padding.bottom +
              16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isLuxury
                    ? Colors.white.withValues(alpha: 0.24)
                    : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            row(
              icon: Icons.edit_rounded,
              color: isLuxury ? palette.accentPrimary : ThemeV2.primary,
              label: l10n.etfAdminRenameNicknameTooltip,
              onTap: () {
                Navigator.pop(sheetContext);
                _showRenameNicknameDialog(context, ref);
              },
            ),
            row(
              icon: Icons.add_business_rounded,
              color: isLuxury ? palette.accentPrimary : ThemeV2.primary,
              label: l10n.etfAdminCreateFundTooltip,
              onTap: () {
                Navigator.pop(sheetContext);
                context.push('/funds/create');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameNicknameDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: ref.read(myNicknameProvider).valueOrNull ?? '',
    );
    final formKey = GlobalKey<FormState>();
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            try {
              await setMyNickname(controller.text.trim());
              ref.invalidate(myNicknameProvider);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            } on NicknameTakenException {
              setDialogState(() {
                serverError = l10n.chooseNicknameTakenError;
              });
              formKey.currentState!.validate();
            } catch (_) {
              setDialogState(() {
                serverError = l10n.chooseNicknameGenericError;
              });
              formKey.currentState!.validate();
            }
          }

          return AlertDialog(
            title: Text(l10n.etfAdminRenameNicknameTitle),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                maxLength: 25,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9_]')),
                ],
                onChanged: (_) {
                  if (serverError != null) {
                    setDialogState(() => serverError = null);
                  }
                },
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return l10n.chooseNicknameRequired;
                  if (!nicknamePattern.hasMatch(v)) {
                    return l10n.chooseNicknameInvalidChars;
                  }
                  return serverError;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  MaterialLocalizations.of(dialogContext).cancelButtonLabel,
                ),
              ),
              TextButton(
                onPressed: submit,
                child: Text(l10n.chooseNicknameContinueButton),
              ),
            ],
          );
        },
      ),
    );
  }
}
