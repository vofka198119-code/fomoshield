import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../company_encyclopedia_provider.dart';
import 'company_ad_overlay.dart';
import 'company_encyclopedia_detail_screen.dart';
import 'company_encyclopedia_paywall_sheet.dart';

// ---------------------------------------------------------------------------
// Company Encyclopedia widget — "История компании": two rows, Business
// History and Market History, each opening a full-text reader. Content is
// filled in company-by-company (see company_encyclopedia_provider.dart) —
// a company with nothing yet just shows "no data" on both rows instead of
// hiding the widget, since it's meant to be visible everywhere from day
// one as the backing content grows. Premium/admin read freely; free tier
// gets an ad-gate (2 ads, unlocks reading for the rest of this Company
// Detail visit — see company_encyclopedia_provider.dart's autoDispose
// unlock state for why it re-locks on the next visit).
// ---------------------------------------------------------------------------

class CompanyEncyclopediaWidget extends ConsumerWidget {
  final String symbol;
  final String companyName;
  final AppPalette palette;

  const CompanyEncyclopediaWidget({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(companyEncyclopediaProvider(symbol));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CardFrame(
        showTopBar: false,
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            themedHeaderText(
              l10n.companyEncyclopediaCardTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
            const SizedBox(height: 10),
            themedDivider(palette, indent: 0, endIndent: 0),
            const SizedBox(height: 6),
            ...async.when(
              data: (entry) => [
                _row(
                  context,
                  ref,
                  l10n,
                  l10n.companyEncyclopediaBusinessRow,
                  entry.businessHistory(context),
                ),
                _row(
                  context,
                  ref,
                  l10n,
                  l10n.companyEncyclopediaMarketRow,
                  entry.marketHistory(context),
                ),
                _row(
                  context,
                  ref,
                  l10n,
                  l10n.companyEncyclopediaPresentDayRow,
                  entry.presentDay(context),
                ),
              ],
              loading: () => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: palette.accentPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              error: (_, _) => [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    l10n.companyEncyclopediaLoadError,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: palette.textBody,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String label,
    String? text,
  ) {
    final hasData = text != null && text.isNotEmpty;
    return InkWell(
      onTap: hasData ? () => _handleTap(context, ref, l10n, label, text) : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasData
                      ? palette.textHeader
                      : palette.textBody.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (hasData)
              Icon(
                Icons.chevron_right_rounded,
                color: palette.accentPrimary,
                size: 20,
              )
            else
              Text(
                l10n.companyEncyclopediaNoData,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: palette.textBody.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String rowLabel,
    String text,
  ) async {
    final tier = ref.read(subscriptionTierProvider);
    if (!tier.isPremiumOrAdmin) {
      final unlocked = ref.read(companyEncyclopediaUnlockedProvider(symbol));
      if (!unlocked) {
        final wantsAd = await showCompanyEncyclopediaPaywallSheet(
          context,
          ref,
          palette,
        );
        if (wantsAd != true || !context.mounted) return;
        // Two ads back to back, per spec — a single watch-flow doesn't
        // unlock reading, both have to finish.
        await _showAdOverlay(context);
        if (!context.mounted) return;
        await _showAdOverlay(context);
        if (!context.mounted) return;
        ref.read(companyEncyclopediaUnlockedProvider(symbol).notifier).state =
            true;
      }
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyEncyclopediaDetailScreen(
          rowLabel: rowLabel,
          symbol: symbol,
          companyName: companyName,
          text: text,
          palette: palette,
        ),
      ),
    );
  }

  Future<void> _showAdOverlay(BuildContext context) {
    final completer = Completer<void>();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CompanyAdOverlay(onComplete: () => completer.complete()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
    return completer.future;
  }
}
