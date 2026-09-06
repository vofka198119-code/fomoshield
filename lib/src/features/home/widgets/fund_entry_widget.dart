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
import '../../monetization/monetization_modal.dart';

// ---------------------------------------------------------------------------
// Fund Entry Widget — Home mini card, sits directly under Market Clock (see
// docs/ETF_FUND_EMULATION.md's onboarding section). Two tappable halves:
// become a fund head (Premium-gated) or an investment assistant (free).
// Each routes through the one-time onboarding stepper the first time it's
// tapped (see fund_onboarding_providers.dart), then to its real destination.
// ---------------------------------------------------------------------------

class FundEntryWidget extends ConsumerWidget {
  const FundEntryWidget({super.key});

  Future<void> _handleHeadTap(BuildContext context, WidgetRef ref) async {
    final tier = ref.read(subscriptionTierProvider);
    if (!tier.isPremiumOrAdmin) {
      await showMonetizationModal(context, ref);
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
    if (context.mounted) context.push('/funds/create');
  }

  Future<void> _handleAnalystTap(BuildContext context, WidgetRef ref) async {
    final seen =
        ref.read(fundOnboardingSeenProvider(FundOnboardingBranch.analyst));
    if (!seen) {
      final accepted = await context.push<bool>(
        '/funds/onboarding',
        extra: FundOnboardingBranch.analyst,
      );
      if (accepted != true || !context.mounted) return;
    }
    // Phase 3 (hiring marketplace/analyst profile) isn't built yet — see
    // docs/ETF_FUND_EMULATION.md's phased plan. Nothing to route to yet.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.etfOnboardingComingSoon)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final tier = ref.watch(subscriptionTierProvider);

    return CardFrame(
      padding: const EdgeInsets.all(4),
      palette: palette,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _FundEntryPanel(
                icon: Icons.account_balance_rounded,
                title: l10n.etfHomeCardTitleHead,
                premiumTag: !tier.isPremiumOrAdmin,
                palette: palette,
                l10n: l10n,
                onTap: () => _handleHeadTap(context, ref),
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
                title: l10n.etfHomeCardTitleAnalyst,
                premiumTag: false,
                palette: palette,
                l10n: l10n,
                onTap: () => _handleAnalystTap(context, ref),
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
