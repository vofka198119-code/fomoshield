import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/infinite_circle_shortcut_row.dart';
import '../providers/employee_providers.dart';
import '../widgets/employee_identity_card.dart';

// ---------------------------------------------------------------------------
// Employee Hub — the analyst's own landing point once a profile exists
// (Home's "My Profile" tile routes here now, not straight to the profile
// form — 2026-09-10, per the reference mockups the author shared). Name
// card up top (EmployeeIdentityCard, shared with EmployeeProfileScreen),
// then an infinite circle-shortcut row to jump anywhere in "the profile"
// from one starting screen — reuses InfiniteCircleShortcutRow so adding a
// 5th/6th shortcut later is a one-line addition, not a redesign.
//
// Profile and My Invitations are real destinations; Vacancies/My
// Applications are ComingSoonScreen stubs — the "analyst applies to an
// open posting" direction is a new, not-yet-built mechanic that runs
// ALONGSIDE the existing "head browses analysts and invites" direction
// (EmployeeMarketplaceScreen), not a replacement — per the author's own
// call: relying on heads alone to reach out would leave too many analyst
// profiles never contacted.
// ---------------------------------------------------------------------------

class EmployeeHubScreen extends ConsumerWidget {
  const EmployeeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final invitationsCount =
        ref.watch(myInvitationsProvider).valueOrNull?.length ?? 0;

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
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            EmployeeIdentityCard(palette: palette),
            InfiniteCircleShortcutRow(
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
          ],
        ),
      ),
    );
  }
}
