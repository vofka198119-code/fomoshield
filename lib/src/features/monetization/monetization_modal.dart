import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/purchases/purchase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../portfolio/portfolio_limits_provider.dart' show premiumMaxHoldingsPerPortfolio;
import '../search/search_counter_provider.dart';

// ---------------------------------------------------------------------------
// Monetization Modal — one sheet, three reasons to show it, each with its
// own framing:
//
//   - [MonetizationTrigger.stressTestLimit] (hit the concurrent Stress
//     Test session cap): its own title/description naming the real
//     numbers.
//   - [MonetizationTrigger.holdingsLimit] (too many distinct positions in
//     one portfolio): its own title/description naming the cap.
//   - [MonetizationTrigger.voluntary] (Profile's free-tier upsell card,
//     or any locked-feature tap that isn't about a numeric limit at all —
//     a locked theme, a locked Stress Test duration, ad-free browsing,
//     locked Encyclopedia articles): generic Premium pitch — full
//     benefits list, a note that monthly/quarterly/annual billing all
//     exist.
//
// A 4th variant, [MonetizationTrigger.limitReached] (the original —
// and until 2026-09-05, only — trigger, for the search limit), was
// retired 2026-09-23 along with the search-limit gate itself: every ad
// gate in the app (Company Detail, Company Encyclopedia, the order
// placement gate) now has its own dedicated ad-or-Premium sheet
// (ad_or_premium_sheet.dart) instead of routing through here, so this
// modal no longer needs a "Watch Ad" off-ramp of its own — see
// fomoshield_admob_plan_2026_09_22 memory.
//
// All variants share: "Upgrade to Premium" (real Play Billing purchase,
// monthly plan only for now — see purchase_service.dart) and "Restore
// purchases". Admin override: "Reset counter" button when
// isAdminProvider == true.
// ---------------------------------------------------------------------------

enum MonetizationTrigger { stressTestLimit, holdingsLimit, voluntary }

/// Shows the monetization modal as a bottom sheet.
Future<void> showMonetizationModal(
  BuildContext context,
  WidgetRef ref, {
  required MonetizationTrigger trigger,
}) {
  return showModalBottomSheet(
    context: context,
    // Without this, the sheet pushes onto the ShellRoute's own nested
    // Navigator, whose Scaffold paints its persistent bottom nav bar on
    // top of the sheet's lower edge instead of the sheet covering it —
    // same fix as home_screen.dart's _showWidgetsBottomSheet and
    // portfolio_body.dart's identical one. Went unnoticed here until the
    // Restore Purchases button (2026-09-20) made the sheet just tall
    // enough to visibly clip behind the nav bar.
    useRootNavigator: true,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) => _MonetizationSheet(trigger: trigger),
  );
}

// ===========================================================================
// Sheet
// ===========================================================================

class _MonetizationSheet extends ConsumerWidget {
  final MonetizationTrigger trigger;

  const _MonetizationSheet({required this.trigger});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final isPurchasing = ref.watch(purchaseInFlightProvider);
    final isVoluntary = trigger == MonetizationTrigger.voluntary;
    final l10n = AppLocalizations.of(context)!;
    // Google's own region-priced label (see monthlyPriceLabelProvider's
    // doc comment) — null while still loading or if the query failed,
    // in which case the button falls back to a price-less label rather
    // than blocking on it.
    final priceLabel = ref.watch(monthlyPriceLabelProvider).valueOrNull;

    final IconData headerIcon;
    final String title;
    final String description;
    switch (trigger) {
      case MonetizationTrigger.stressTestLimit:
        headerIcon = Icons.psychology_rounded;
        title = l10n.stressTestLimitReachedTitle;
        description = l10n.monetizationModalStressTestLimitDescription;
      case MonetizationTrigger.holdingsLimit:
        headerIcon = Icons.account_balance_rounded;
        title = l10n.orderEntryHoldingsLimitPromoTitle;
        description = l10n.monetizationModalHoldingsLimitDescription(
          premiumMaxHoldingsPerPortfolio,
        );
      case MonetizationTrigger.voluntary:
        headerIcon = Icons.workspace_premium_rounded;
        title = l10n.monetizationModalVoluntaryTitle;
        description = l10n.premiumPromoOverlaySubtitle;
    }

    // Reacts to the app-wide purchase listener (purchase_listener.dart)
    // finishing whatever this sheet just started — NOT scoped to this
    // widget's own onPressed callback, since the real result always comes
    // back asynchronously via Play's purchaseStream, well after the tap
    // that triggered it.
    ref.listen<PurchaseOutcome?>(purchaseOutcomeProvider, (previous, next) {
      if (next == null) return;
      ref.read(purchaseOutcomeProvider.notifier).state = null;
      switch (next) {
        case PurchaseOutcome.success:
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.subscriptionUpgradedDetail),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        case PurchaseOutcome.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.monetizationModalPurchaseError),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case PurchaseOutcome.canceled:
          // User backed out of Play's own sheet — nothing to say.
          break;
      }
    });

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (isVoluntary ? AppTheme.premiumGreen : AppTheme.accentBlue)
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              headerIcon,
              color: isVoluntary ? AppTheme.premiumGreen : AppTheme.accentBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textDim,
              height: 1.5,
            ),
          ),

          // ── Benefits + billing-period note (voluntary only) ──────
          // The limit-reached variant deliberately stays as-is here —
          // it's about getting UNBLOCKED, not about the full pitch.
          if (isVoluntary) ...[
            const SizedBox(height: 20),
            _benefitRow(Icons.search_rounded, l10n.premiumBenefitSearches),
            const SizedBox(height: 8),
            _benefitRow(
              Icons.account_balance_rounded,
              l10n.premiumBenefitPortfolios,
            ),
            const SizedBox(height: 8),
            _benefitRow(
              Icons.monetization_on_rounded,
              l10n.premiumBenefitCapital,
            ),
            const SizedBox(height: 8),
            _benefitRow(
              Icons.psychology_rounded,
              l10n.premiumBenefitStressTests,
            ),
            const SizedBox(height: 8),
            _benefitRow(Icons.savings_rounded, l10n.premiumBenefitWeeklyPayout),
            const SizedBox(height: 8),
            _benefitRow(Icons.palette_rounded, l10n.premiumBenefitThemes),
            const SizedBox(height: 8),
            _benefitRow(Icons.block_rounded, l10n.premiumBenefitAdFree),
            const SizedBox(height: 16),
            Text(
              l10n.monetizationModalVoluntaryPlansNote,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textDim,
              ),
            ),
          ],
          const SizedBox(height: 28),

          // ── Premium Button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isPurchasing
                  ? null
                  : () => _startPurchase(context, ref, l10n),
              icon: isPurchasing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.workspace_premium_rounded, size: 20),
              label: Text(
                isPurchasing
                    ? l10n.monetizationModalProcessing
                    : priceLabel != null
                    ? l10n.monetizationModalUpgradeButtonWithPrice(priceLabel)
                    : l10n.monetizationModalUpgradeButton,
                // A long localized price+currency string (some locales run
                // noticeably longer than "$4.99") combined with the fixed
                // "Upgrade to Premium —" prefix could overflow this
                // full-width button on a narrow device — clip with an
                // ellipsis instead of wrapping/overflowing ugly.
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.premiumGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Restore Purchases ───────────────────────────────────
          // Required by Play policy for subscriptions, and the only way
          // back to premium after a reinstall/device switch without
          // support intervention — the purchase itself lives on the
          // Google account, not this app install.
          TextButton(
            onPressed: isPurchasing
                ? null
                : () => _restorePurchases(context, ref, l10n),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textDim),
            child: Text(
              l10n.monetizationModalRestorePurchases,
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),

          // ── Admin: Reset ───────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(searchCounterProvider.notifier).resetToFree();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.monetizationModalCounterResetAdmin),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: Text(
                  l10n.monetizationModalResetCounterAdmin,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textDim,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textDim),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Benefit row for the voluntary variant's pitch — left-aligned, unlike
  /// _PremiumStatusCard's near-identical row (right column of the gold
  /// card, so it's fine to duplicate rather than share across files for
  /// a ~10-line row builder.
  Widget _benefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.premiumGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// Helpers
// ===========================================================================

/// Kicks off the real Play Billing purchase flow for the monthly plan.
/// Doesn't await a result here — [purchaseInFlightProvider] and
/// [purchaseOutcomeProvider] (set by purchase_listener.dart, watched by
/// _MonetizationSheet above) carry the async outcome back to the UI once
/// Play's own sheet and the backend verification round-trip finish.
Future<void> _startPurchase(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  final userId = ref.read(currentUserProvider)?.id;
  // Diagnostic logging — kept until real purchases are re-verified on a
  // Play-installed build (see purchase_service.dart's own doc comment and
  // fomoshield_admob_plan_2026_09_22 memory's 2026-09-25 findings).
  debugPrint('MonetizationModal: _startPurchase tapped, userId=$userId');
  if (userId == null) return;

  ref.read(purchaseInFlightProvider.notifier).state = true;
  final started = await ref
      .read(purchaseServiceProvider)
      .buyMonthly(userId);
  if (!started) {
    // Nothing launched at all (billing unavailable, product/offer not
    // found) — no purchaseStream event will ever arrive for this
    // attempt, so reset the spinner ourselves instead of waiting.
    ref.read(purchaseInFlightProvider.notifier).state = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.monetizationModalPurchaseError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Restores a previous purchase (reinstall/device switch). A genuine
/// restore is delivered asynchronously through the same purchase stream
/// as a fresh buy (handled by purchase_listener.dart); the "nothing to
/// restore" case emits no stream event at all, so this falls back to a
/// short timeout before assuming that's what happened.
Future<void> _restorePurchases(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) async {
  ref.read(purchaseInFlightProvider.notifier).state = true;
  await ref.read(purchaseServiceProvider).restorePurchases();
  await Future.delayed(const Duration(seconds: 3));
  if (ref.read(purchaseInFlightProvider)) {
    ref.read(purchaseInFlightProvider.notifier).state = false;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.monetizationModalRestoreNotFound),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
