import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../features/market_clock/market_clock_dial.dart'
    show darkCardDecoration, dialBrassLight;
import '../../features/monetization/monetization_modal.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Premium Upsell Banner — a persistent (non-reorderable, always-there)
// "go Premium" card, as opposed to a paywall that only shows once a limit
// is actually hit. Same gold-badge/pill visual language as
// stress_test_setup_screen.dart's own locked-row banner, extracted here
// (2026-09-20) since a THIRD near-identical copy for the Portfolio/Stress
// Test balance-widget upsell would have been one too many to keep
// hand-duplicating.
//
// Self-gates: renders nothing for premium/admin. Tapping it opens the
// voluntary monetization sheet (a deliberate browse, not "you hit a
// wall") — see monetization_modal.dart.
// ---------------------------------------------------------------------------

class PremiumUpsellBanner extends ConsumerWidget {
  final String message;

  const PremiumUpsellBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionTierProvider);
    if (tier.isPremiumOrAdmin) return const SizedBox.shrink();

    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final l10n = AppLocalizations.of(context)!;
    final fg = palette.windowGradient != null
        ? (palette.onWindow ?? palette.accentPrimary)
        : palette.accentPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => showMonetizationModal(
        context,
        ref,
        trigger: MonetizationTrigger.voluntary,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: palette.windowGradient,
          color: palette.windowGradient == null
              ? ThemeV2.primary.withValues(alpha: 0.08)
              : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: palette.accentPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: palette.windowGradient != null
                  ? BoxDecoration(
                      gradient: palette.windowGradient,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : darkCardDecoration(borderRadius: BorderRadius.circular(12)),
              child: Text(
                l10n.profilePremiumBadge,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: palette.marketClockAccent ?? dialBrassLight,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}
