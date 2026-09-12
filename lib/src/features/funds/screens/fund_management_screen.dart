import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_border.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import '../../../shared/widgets/circle_shortcut_row.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import '../providers/employee_providers.dart';
import '../services/fund_api_service.dart';
import '../widgets/fund_delete_dialog.dart';

// ---------------------------------------------------------------------------
// Fund Management — the head/team-facing screen, split out from
// FundDetailScreen (which stays the public, anyone-in-search-sees-this
// card). This one is reached only through Home's "My Fund" shortcut (a
// head) for now; team members don't yet have their own entry point into it
// (Phase 4 — trade proposals/blotter — is where their working screen
// actually gets built out). Everything here today is just the isHead-gated
// controls that used to live inline in FundDetailScreen: the team roster's
// Hire/Terminate actions and the delete-fund flow.
// ---------------------------------------------------------------------------

class FundManagementScreen extends ConsumerWidget {
  final String fundId;

  const FundManagementScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: fundAsync.maybeWhen(
          data: (fund) => themedHeaderText(
            fund.ticker,
            palette,
            GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        actions: [
          fundAsync.maybeWhen(
            data: (fund) => fund.headUserId == currentUserId && isAdmin
                ? IconButton(
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
                    onPressed: () =>
                        _showAdminActionsSheet(context, ref, l10n, palette, fund),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          fundAsync.maybeWhen(
            data: (fund) => fund.headUserId == currentUserId
                ? IconButton(
                    icon: Icon(Icons.delete_outline, color: palette.textBody),
                    onPressed: () =>
                        showFundDeleteFlow(context, ref, fund.id, palette),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: fundAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (fund) {
            final isHead = fund.headUserId == currentUserId;
            final teamAsync = ref.watch(fundTeamProvider(fund.id));

            Widget buildBody() => RefreshIndicator(
              color: palette.accentPrimary,
              onRefresh: () async => ref.invalidate(fundDetailProvider(fundId)),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  _buildNameCard(context, l10n, palette, fund),
                  const SizedBox(height: 12),
                  CircleShortcutRow(
                    palette: palette,
                    items: [
                      CircleShortcut(
                        icon: Icons.groups_rounded,
                        label: l10n.etfEmployeeHubTeamRow,
                        onTap: () => context.push('/funds/${fund.id}/team'),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (isHead) return buildBody();

            return teamAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: palette.accentPrimary),
              ),
              error: (_, _) => Center(
                child: Text(
                  l10n.etfFundManagementAccessDenied,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              ),
              data: (team) {
                final isMember = team.any(
                  (m) => m.userId == currentUserId && !m.isPendingTermination,
                );
                if (!isMember) {
                  return Center(
                    child: Text(
                      l10n.etfFundManagementAccessDenied,
                      style: GoogleFonts.inter(color: palette.textBody),
                    ),
                  );
                }
                return buildBody();
              },
            );
          },
        ),
      ),
    );
  }

  // Same avatar/name/chip visual as EmployeeIdentityCard (2026-09-11, per
  // explicit "тот же стиль как и мой профиль" ask) — a fund-icon ring
  // instead of a person icon, the fund's ticker as the descriptor chip
  // instead of a role. The admin-only rename tool lives in the AppBar's ⋮
  // sheet (see _showAdminActionsSheet), not inline here — same relocation
  // as EmployeeIdentityCard's own admin tools.
  Widget _buildNameCard(
    BuildContext context,
    AppLocalizations l10n,
    AppPalette palette,
    FundDetail fund,
  ) {
    return CardFrame(
      padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: FomoShieldTheme.cardRadius,
              boxShadow: FomoShieldTheme.shadowSoft,
            )
          : darkCardDecoration(),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.accentPrimary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: palette.accentPrimary.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
                // windowGradient fill (same recipe as CircleShortcutRow's
                // own inner circle) when the theme defines one, instead
                // of a flat accentPrimary@15% tint — that flat tint is
                // the actual "dirty gray" culprit under Black & White.
                // The ring's own glow above was already fine and
                // untouched.
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: palette.windowGradient,
                    color: palette.windowGradient == null
                        ? palette.accentPrimary.withValues(alpha: 0.15)
                        : null,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: palette.accentPrimary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fund.name,
                      // Exactly PriceHeader's own companyName style
                      // (price_header.dart) — matches EmployeeIdentityCard's
                      // nickname text precisely, not just approximately.
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.onWindow ?? Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _chip(fund.ticker, palette),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          themedDivider(palette, indent: 0, endIndent: 0),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/funds/${fund.id}'),
              child: Text(
                l10n.etfFundManagementViewPublicButton,
                style: GoogleFonts.inter(
                  color: palette.accentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, AppPalette palette) {
    final hasThemedBorder = palette.borderGradient != null;
    return themedBorder(
      palette: palette,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: hasThemedBorder
              ? null
              : palette.accentPrimary.withValues(alpha: 0.15),
          gradient: hasThemedBorder ? palette.windowGradient : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: palette.accentPrimary,
          ),
        ),
      ),
    );
  }

  // Same "Add Widgets"/Portfolio-⋮ sheet recipe (handle bar, themedBorder +
  // windowGradient rows) as portfolio_screen.dart's own
  // _showPortfolioActionsSheet / EmployeeHubScreen's own admin sheet.
  void _showAdminActionsSheet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppPalette palette,
    FundDetail fund,
  ) {
    final isLuxury = palette.windowGradient != null;
    final radius = BorderRadius.circular(14);

    Widget buildRow(BuildContext sheetContext) {
      final content = ListTile(
        onTap: () {
          Navigator.pop(sheetContext);
          _showRenameFundDialog(context, ref, l10n, fund);
        },
        leading: Icon(
          Icons.edit_rounded,
          color: isLuxury ? palette.accentPrimary : ThemeV2.primary,
          size: 20,
        ),
        title: Text(
          l10n.etfAdminRenameFundTooltip,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isLuxury ? palette.accentPrimary : ThemeV2.primary,
          ),
        ),
      );
      return isLuxury
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
            buildRow(sheetContext),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameFundDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    FundDetail fund,
  ) async {
    final controller = TextEditingController(text: fund.name);
    final formKey = GlobalKey<FormState>();
    String? serverError;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            try {
              await ref
                  .read(fundApiServiceProvider)
                  .renameFund(fund.id, controller.text.trim());
              ref.invalidate(fundDetailProvider(fund.id));
              ref.invalidate(fundsListProvider);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            } on FundApiException catch (e) {
              setDialogState(() => serverError = e.message);
              formKey.currentState!.validate();
            } catch (_) {
              setDialogState(
                () => serverError = l10n.etfAdminRenameFundGenericError,
              );
              formKey.currentState!.validate();
            }
          }

          return AlertDialog(
            title: Text(l10n.etfAdminRenameFundTitle),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                onChanged: (_) {
                  if (serverError != null) {
                    setDialogState(() => serverError = null);
                  }
                },
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) return l10n.etfAdminRenameFundNameRequired;
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
