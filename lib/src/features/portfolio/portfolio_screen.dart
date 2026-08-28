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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ThemeV2.textSecondary),
            color: ThemeV2.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              final pid = effectiveId;
              if (pid == null) return;
              if (value == 'rename') {
                final current = portfolios.firstWhere((p) => p.id == pid);
                _showRenamePortfolioDialog(context, pid, current.name);
              } else if (value == 'reset') {
                _showResetPortfolioDialog(context, pid);
              } else if (value == 'delete') {
                _showDeletePortfolioDialog(context, pid, portfolios);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: const Icon(
                    Icons.edit_rounded,
                    color: ThemeV2.primary,
                    size: 20,
                  ),
                  title: Text(
                    l10n.portfolioRenameMenu,
                    style: const TextStyle(color: ThemeV2.primary),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: const Icon(
                    Icons.refresh_rounded,
                    color: ThemeV2.warning,
                    size: 20,
                  ),
                  title: Text(
                    l10n.portfolioResetMenu,
                    style: const TextStyle(color: ThemeV2.warning),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_rounded,
                    color: ThemeV2.loss,
                    size: 20,
                  ),
                  title: Text(
                    l10n.portfolioDeleteMenu,
                    style: const TextStyle(color: ThemeV2.loss),
                  ),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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

  void _showRenamePortfolioDialog(
    BuildContext context,
    String portfolioId,
    String currentName,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          l10n.portfolioRenameMenu,
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
                color: ThemeV2.primary,
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

  void _showDeletePortfolioDialog(
    BuildContext context,
    String portfolioId,
    List<Portfolio> ps,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (ps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.portfolioCannotDeleteLast,
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: ThemeV2.loss,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          l10n.portfolioDeleteDialogTitle,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          l10n.portfolioDeleteDialogBody,
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
              ref
                  .read(portfoliosProvider.notifier)
                  .deletePortfolio(portfolioId);
              if (ref.read(activePortfolioIdProvider) == portfolioId) {
                ref.read(activePortfolioIdProvider.notifier).state = null;
              }
              Navigator.pop(ctx);
            },
            child: Text(
              l10n.profileDelete,
              style: GoogleFonts.inter(
                color: ThemeV2.loss,
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
