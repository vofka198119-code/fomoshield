import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/layout/bottom_clearance.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_button.dart';
import '../../core/theme/themed_border.dart';
import '../../core/router/navigation_history_provider.dart';
import '../../core/supabase/supabase_providers.dart';
import 'portfolio_providers.dart';
import 'portfolio_limits_provider.dart';
import 'weekly_payout_provider.dart';
import '../orders/pending_orders_checker.dart';
import 'portfolio_widget_order_provider.dart';
import 'widgets/portfolio_balance_widget.dart';
import 'widgets/portfolio_cash_widget.dart';
import 'widgets/target_widget.dart';
import 'widgets/portfolio_holdings_widget.dart';
import 'widgets/portfolio_trade_history_widget.dart';
import '../../shared/utils/currency_format.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../shared/widgets/disclaimer_footer.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import 'widgets/my_limit_orders_widget.dart';

part 'widgets/portfolio_body.dart';
part 'widgets/portfolio_widgets_settings_sheet.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final portfolios = ref.watch(portfoliosProvider);
    final activeId = ref.watch(activePortfolioIdProvider);
    final effectiveId =
        activeId ?? (portfolios.isNotEmpty ? portfolios.first.id : null);
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(
          context,
          palette,
          onPressed: () => context.go(ref.read(previousTabRouteProvider)),
        ),
        title: themedHeaderText(
          l10n.portfolioWidgetTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            // Flat accentPrimary before — every other header icon (back
            // arrow, notification bell) gets the same metallic gold
            // ShaderMask sheen under Luxury via themedGoldGradient; this
            // one was missed. Standard is a no-op, exact same gray as
            // before.
            icon: themedGoldGradient(
              Icon(
                Icons.more_vert,
                color: palette.windowGradient == null
                    ? ThemeV2.textSecondary
                    : Colors.white,
                shadows: palette.titleShadow != null
                    ? [palette.titleShadow!]
                    : null,
              ),
              palette,
            ),
            onPressed: () {
              final pid = effectiveId;
              if (pid == null) return;
              _showPortfolioActionsSheet(context, pid, palette);
            },
          ),
        ],
      ),
      body: portfolios.isEmpty
          ? _emptyState(context, palette)
          : effectiveId == null
          ? _emptyState(context, palette)
          : _PortfolioBody(portfolioId: effectiveId),
    );
  }

  Widget _emptyState(BuildContext context, AppPalette palette) {
    final l10n = AppLocalizations.of(context)!;
    final tier = ref.watch(subscriptionTierProvider);
    final startingCapital = startingCapitalForTier(tier);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: palette.textBody,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.portfolioNoPortfoliosYet,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: palette.textHeader,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.portfolioCreateFirstMsg(formatUsd(startingCapital)),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePortfolioDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.portfolioCreateButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeV2.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet for the header's ⋮ actions — matches the "Add Widgets"
  // sheets' now-canonical recipe (handle bar, themedBorder + windowGradient
  // rows) instead of a native PopupMenuButton, which has no way to render
  // this app's gradient border/window fill and always looked out of place
  // no matter how its flat color/border were tuned.
  void _showPortfolioActionsSheet(
    BuildContext context,
    String portfolioId,
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
              label: l10n.portfolioRenameMenu,
              onTap: () {
                Navigator.pop(sheetContext);
                final current = ref
                    .read(portfoliosProvider)
                    .firstWhere((p) => p.id == portfolioId);
                _showRenamePortfolioDialog(
                  context,
                  portfolioId,
                  current.displayName(l10n),
                );
              },
            ),
            row(
              icon: Icons.refresh_rounded,
              color: ThemeV2.warning,
              label: l10n.portfolioResetMenu,
              onTap: () {
                Navigator.pop(sheetContext);
                _showResetPortfolioDialog(context, portfolioId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenamePortfolioDialog(
    BuildContext context,
    String portfolioId,
    String currentName,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.read(themeVariantProvider));
    final isLuxury = palette.windowGradient != null;
    final controller = TextEditingController(text: currentName);
    final fieldRadius = BorderRadius.circular(10);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: palette.card,
        shape: isLuxury
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: palette.accentPrimary, width: 1),
              )
            : null,
        title: SizedBox(
          width: double.infinity,
          child: Text(
            l10n.portfolioRenameMenu,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
        ),
        // Same gold-ring + graphite-window recipe as the Search field
        // (search_screen.dart) — Standard keeps the original plain filled
        // box untouched.
        content: isLuxury
            ? themedBorder(
                palette: palette,
                borderRadius: fieldRadius,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: palette.windowGradient,
                    borderRadius: fieldRadius,
                  ),
                  // Cursor/selection-handle color otherwise falls back to
                  // the app-wide TextSelectionTheme (green, tied to
                  // ThemeV2.primary) regardless of this field's own
                  // palette-aware colors — override locally so it reads as
                  // gold under Luxury.
                  child: Theme(
                    data: Theme.of(ctx).copyWith(
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: palette.accentPrimary,
                        selectionColor: palette.accentPrimary.withValues(
                          alpha: 0.3,
                        ),
                        selectionHandleColor: palette.accentPrimary,
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      cursorColor: palette.accentPrimary,
                      // Renaming is a short single-word edit — the
                      // drag-to-reposition "teardrop" handle just gets in
                      // the way here, so drop interactive selection
                      // entirely rather than only recoloring it.
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        hintText: l10n.portfolioNameHint,
                        hintStyle: GoogleFonts.inter(
                          color: palette.textBody,
                          fontSize: 14,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      style: GoogleFonts.inter(
                        color: palette.textHeader,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            : TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.portfolioNameHint,
                  hintStyle: GoogleFonts.inter(
                    color: palette.textBody,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: ThemeV2.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: fieldRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.inter(
                  color: palette.textHeader,
                  fontSize: 14,
                ),
              ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.profileCancel,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref
                    .read(portfoliosProvider.notifier)
                    .renamePortfolio(portfolioId, newName);
                Navigator.pop(ctx);
              }
            },
            child: Text(
              l10n.portfolioSave,
              style: GoogleFonts.inter(
                color: palette.accentPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPortfolioDialog(BuildContext context, String portfolioId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          l10n.portfolioResetDialogTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          l10n.portfolioResetDialogBody,
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.profileCancel,
              style: GoogleFonts.inter(color: ThemeV2.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(portfoliosProvider.notifier).resetPortfolio(portfolioId);
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.homeReset,
              style: GoogleFonts.inter(
                color: ThemeV2.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Library-scoped (not a class member) so both PortfolioScreen's empty-state
// button and _PortfolioSelector's premium-slot tap (portfolio_selector.dart)
// can open it without one needing an instance of the other's State class.
void _showCreatePortfolioDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ThemeV2.surface,
      title: Text(
        l10n.portfolioNewDialogTitle,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ThemeV2.textPrimary,
        ),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.portfolioNameHint,
          hintStyle: GoogleFonts.inter(
            color: ThemeV2.textSecondary,
            fontSize: 14,
          ),
          filled: true,
          fillColor: ThemeV2.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        style: GoogleFonts.inter(color: ThemeV2.textPrimary, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            l10n.profileCancel,
            style: GoogleFonts.inter(color: ThemeV2.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              final maxP = ref.read(maxPortfoliosProvider);
              final currentCount = ref.read(portfoliosProvider).length;
              if (currentCount >= maxP) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      maxP == 1
                          ? l10n.portfolioFreeLimitOne
                          : l10n.portfolioMaxReached(maxP),
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    backgroundColor: ThemeV2.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              ref
                  .read(portfoliosProvider.notifier)
                  .addPortfolio(
                    controller.text.trim(),
                    startingBalance: startingCapitalForTier(
                      ref.read(subscriptionTierProvider),
                    ),
                  );
              Navigator.pop(ctx);
            }
          },
          child: Text(
            l10n.portfolioCreate,
            style: GoogleFonts.inter(
              color: ThemeV2.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
