import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/layout/bottom_clearance.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/router/navigation_history_provider.dart';
import '../../core/supabase/supabase_providers.dart';
import '../market_clock/market_clock_dial.dart'
    show dialBrassLight, darkCardDecoration;
import '../monetization/monetization_modal.dart';
import '../monetization/premium_promo_overlay.dart';
import 'portfolio_providers.dart';
import 'portfolio_limits_provider.dart';
import '../orders/pending_orders_checker.dart';
import 'portfolio_ad_provider.dart';
import 'portfolio_widget_order_provider.dart';
import 'widgets/portfolio_balance_widget.dart';
import 'widgets/portfolio_cash_widget.dart';
import 'widgets/target_widget.dart';
import 'widgets/portfolio_holdings_widget.dart';
import 'widgets/portfolio_trade_history_widget.dart';
import '../../shared/utils/currency_format.dart';
import '../../shared/widgets/disclaimer_footer.dart';
import '../../shared/widgets/stagger_fade_in.dart';
import 'widgets/my_limit_orders_widget.dart';

part 'widgets/portfolio_body.dart';
part 'widgets/portfolio_selector.dart';
part 'widgets/portfolio_widgets_settings_sheet.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    final portfolios = ref.watch(portfoliosProvider);
    final activeId = ref.watch(activePortfolioIdProvider);
    final effectiveId =
        activeId ?? (portfolios.isNotEmpty ? portfolios.first.id : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: ThemeV2.primary),
          onPressed: () => context.go(ref.read(previousTabRouteProvider)),
        ),
        title: Text(
          'PORTFOLIO',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
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
                  title: const Text(
                    'Rename Portfolio',
                    style: TextStyle(color: ThemeV2.primary),
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
                  title: const Text(
                    'Reset Portfolio',
                    style: TextStyle(color: ThemeV2.warning),
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
                  title: const Text(
                    'Delete Portfolio',
                    style: TextStyle(color: ThemeV2.loss),
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
          ? _emptyState(context)
          : effectiveId == null
          ? _emptyState(context)
          : _PortfolioBody(portfolioId: effectiveId),
    );
  }

  Widget _emptyState(BuildContext context) {
    final startingCapital = startingCapitalForIndex(0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: ThemeV2.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No portfolios yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first virtual portfolio\nwith ${formatUsd(startingCapital)} starting balance',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: ThemeV2.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePortfolioDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text('Create Portfolio'),
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
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'Rename Portfolio',
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
            hintText: 'e.g. Tech Growth',
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
              'Cancel',
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
              'Save',
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        title: Text(
          'Reset Portfolio?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          'All holdings and history will be cleared.\nBalance will be restored to its original amount.',
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: ThemeV2.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(portfoliosProvider.notifier).resetPortfolio(portfolioId);
              Navigator.pop(ctx);
            },
            child: Text(
              'Reset',
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
    if (ps.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete the last portfolio. Create a new one first.',
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
          'Delete Portfolio?',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        content: Text(
          'All holdings and history will be lost.',
          style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
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
              'Delete',
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
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ThemeV2.surface,
      title: Text(
        'New Portfolio',
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
          hintText: 'e.g. Tech Growth',
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
            'Cancel',
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
                          ? 'FREE limit: 1 portfolio. Upgrade to Premium (3).'
                          : 'Max $maxP portfolios reached.',
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
                    startingBalance: startingCapitalForIndex(currentCount),
                  );
              Navigator.pop(ctx);
            }
          },
          child: Text(
            'Create',
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
