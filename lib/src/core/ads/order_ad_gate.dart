import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/gen/app_localizations.dart';
import '../supabase/supabase_providers.dart';
import '../theme/app_palette.dart';
import '../theme/theme_variant_provider.dart';
import '../../shared/widgets/ad_or_premium_sheet.dart';
import 'ad_providers.dart';
import 'ad_loading_overlay.dart';
import 'order_ad_provider.dart';

// ---------------------------------------------------------------------------
// Call this right after the user confirms an order (Stress Test or
// Portfolio) and right before actually placing/executing it. Returns true
// if the order may proceed — either it was still within the free
// allowance, the user is Premium/Admin, or they watched the ad to earn
// this one. Returns false if they should stay on the order screen
// (cancelled the ad, or it failed to load/show).
// ---------------------------------------------------------------------------

/// [contextKey] scopes the counter — use `'stress_test'` or `'portfolio'`
/// so the two allowances never share a pool.
Future<bool> checkOrderAdGate(
  BuildContext context,
  WidgetRef ref, {
  required String contextKey,
}) async {
  // Awaits the real tier instead of racing subscriptionTierProvider's
  // async DB fetch — see resolveSubscriptionTier's doc comment.
  final tier = await resolveSubscriptionTier(ref);
  if (!context.mounted) return false;
  if (tier.isPremiumOrAdmin) return true;

  final gated = await ref
      .read(orderAdProvider(contextKey).notifier)
      .incrementAndCheck();
  if (!gated) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context)!;
  final palette = resolveAppPalette(ref.read(themeVariantProvider));
  final wantsAd = await showAdOrPremiumSheet(
    context,
    ref,
    palette: palette,
    icon: Icons.receipt_long_rounded,
    title: l10n.orderAdGateTitle,
    body: l10n.orderAdGateBody,
    watchAdLabel: l10n.companyDetailWatchAdButton,
    goPremiumLabel: l10n.companyEncyclopediaGoPremiumButton,
  );
  if (wantsAd != true || !context.mounted) return false;

  return withAdLoadingOverlay(context, ref.read(adServiceProvider).showRewarded());
}
