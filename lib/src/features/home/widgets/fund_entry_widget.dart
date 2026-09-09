import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../funds/onboarding/fund_onboarding_providers.dart';
import '../../funds/providers/employee_providers.dart';
import '../../funds/providers/fund_providers.dart';
import '../../funds/widgets/etf_premium_required_sheet.dart';

// ---------------------------------------------------------------------------
// Fund Entry Widget — Home mini card, sits directly under Market Clock (see
// docs/ETF_FUND_EMULATION.md's onboarding section). Two tappable halves:
// become a fund head (Premium-gated) or an investment assistant (free).
// Each routes through the one-time onboarding stepper the first time it's
// tapped (see fund_onboarding_providers.dart), then to its real destination.
//
// Premium gate is checked AFTER onboarding, not before (2026-09-06 change,
// per the author): a non-Premium user still gets to read what the feature
// is and what it requires first — the paywall only shows once they'd
// actually try to create a fund, not as the very first thing they see.
//
// Once a fund/profile already exists, both halves become a shortcut BACK
// to it instead of the create/onboarding flow (fixed 2026-09-09 — before
// this, tapping "Become a Fund Manager" a second time always pushed
// '/funds/create', which the server would just reject with
// 'fund_limit_reached' since the 1-fund-per-user cap was already hit; the
// user had no other way to find their own fund again except digging
// through the Search screen's Funds tab). Labels flip to match (see
// _FundEntryPanel's title param below).
// ---------------------------------------------------------------------------

class FundEntryWidget extends ConsumerWidget {
  const FundEntryWidget({super.key});

  Future<void> _handleHeadTap(
    BuildContext context,
    WidgetRef ref,
    String? myFundId,
  ) async {
    if (myFundId != null) {
      context.push('/funds/$myFundId');
      return;
    }
    final seen = ref.read(fundOnboardingSeenProvider(FundOnboardingBranch.head));
    if (!seen) {
      final accepted = await context.push<bool>(
        '/funds/onboarding',
        extra: FundOnboardingBranch.head,
      );
      if (accepted != true || !context.mounted) return;
    }
    final tier = ref.read(subscriptionTierProvider);
    if (!tier.isPremiumOrAdmin) {
      if (context.mounted) await showEtfPremiumRequiredSheet(context, ref);
      return;
    }
    if (context.mounted) context.push('/funds/create');
  }

  // Once a profile exists, this tile's daily job is "did anyone invite
  // me" — not re-editing the profile (moved to Portfolio's own ⋮ menu,
  // per the design doc's original "edited from the Portfolio card" call
  // and the author's 2026-09-09 request). First-time-ever tap (no profile
  // yet) still goes through onboarding into the create form, same as
  // before.
  Future<void> _handleAnalystTap(
    BuildContext context,
    WidgetRef ref,
    bool hasProfile,
  ) async {
    if (hasProfile) {
      context.push('/funds/invitations');
      return;
    }
    final seen =
        ref.read(fundOnboardingSeenProvider(FundOnboardingBranch.analyst));
    if (!seen) {
      final accepted = await context.push<bool>(
        '/funds/onboarding',
        extra: FundOnboardingBranch.analyst,
      );
      if (accepted != true || !context.mounted) return;
    }
    if (context.mounted) context.push('/funds/employee-profile');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final tier = ref.watch(subscriptionTierProvider);
    final userId = ref.watch(currentUserProvider)?.id;
    final myFundId = ref
        .watch(fundsListProvider)
        .valueOrNull
        ?.where((f) => f.headUserId == userId)
        .firstOrNull
        ?.id;
    final hasProfile =
        ref.watch(myEmployeeProfileProvider).valueOrNull != null;

    return CardFrame(
      padding: const EdgeInsets.all(4),
      palette: palette,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _FundEntryPanel(
                icon: Icons.account_balance_rounded,
                title: myFundId != null
                    ? l10n.etfHomeCardTitleMyFund
                    : l10n.etfHomeCardTitleHead,
                premiumTag: myFundId == null && !tier.isPremiumOrAdmin,
                palette: palette,
                l10n: l10n,
                onTap: () => _handleHeadTap(context, ref, myFundId),
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 12),
              color: palette.textBody.withValues(alpha: 0.12),
            ),
            Expanded(
              child: _FundEntryPanel(
                icon: Icons.badge_rounded,
                title: hasProfile
                    ? l10n.etfHomeCardTitleVacancies
                    : l10n.etfHomeCardTitleAnalyst,
                premiumTag: false,
                palette: palette,
                l10n: l10n,
                onTap: () => _handleAnalystTap(context, ref, hasProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FundEntryPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool premiumTag;
  final AppPalette palette;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _FundEntryPanel({
    required this.icon,
    required this.title,
    required this.premiumTag,
    required this.palette,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.accentPrimary, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: palette.textHeader,
                height: 1.3,
              ),
            ),
            if (premiumTag) ...[
              const SizedBox(height: 6),
              Text(
                l10n.etfHomeCardPremiumTag,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: palette.accentPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
