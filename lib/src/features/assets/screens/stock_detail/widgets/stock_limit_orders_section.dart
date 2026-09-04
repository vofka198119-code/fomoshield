import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import '../../../../../core/theme/app_palette.dart';
import '../../../../../core/theme/themed_header.dart';
import '../../../../../core/theme/themed_divider.dart';
import '../../../../../shared/widgets/card_frame.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../../../stress_test/stress_test_pending_orders_provider.dart';
import 'stress_test_order_row_tile.dart';

// ---------------------------------------------------------------------------
// Stress Test Limit Orders — this symbol's active pending limit orders in
// this session, mirroring Company Detail's limit_orders_section.dart
// (same card standard, same 5-item cap + "See all" sheet). Reads from
// Stress Test's own isolated pending-orders provider, not the real orders
// feature.
// ---------------------------------------------------------------------------

const int _inlineLimit = 5;

class StockLimitOrdersSection extends ConsumerWidget {
  final String sessionId;
  final String symbol;
  final AppPalette palette;

  const StockLimitOrdersSection({
    super.key,
    required this.sessionId,
    required this.symbol,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final orders = ref
        .watch(stressTestSessionPendingOrdersProvider(sessionId))
        .where((o) => o.symbol == symbol)
        .toList();

    if (orders.isEmpty) return const SizedBox.shrink();

    final shown = orders.take(_inlineLimit).toList();

    return CardFrame(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          themedHeaderText(
            l10n.stockLimitOrdersTitle,
            palette,
            FomoShieldTheme.cardTitle(),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette, indent: 0, endIndent: 0)
              : const Divider(height: 20, color: Color(0x0F000000)),
          for (final order in shown)
            StressTestOrderRowTile(order: order, palette: palette),
          if (orders.length > _inlineLimit)
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Center(
                child: TextButton(
                  onPressed: () => _showAllSheet(context),
                  child: Text(
                    l10n.stockLimitOrdersSeeAll(orders.length),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: palette.accentPrimary,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showAllSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.stockLimitOrdersSheetTitle(symbol),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    // Watched live (not the snapshot the "See all" button
                    // was built from) so a fill mid-session updates/removes
                    // a row here instead of leaving a stale pending entry.
                    final liveOrders = ref
                        .watch(
                          stressTestSessionPendingOrdersProvider(sessionId),
                        )
                        .where((o) => o.symbol == symbol)
                        .toList();
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: liveOrders.length,
                      itemBuilder: (_, i) => StressTestOrderRowTile(
                        order: liveOrders[i],
                        // This sheet is always light regardless of the
                        // active theme (hardcoded ThemeV2.surface above).
                        palette: AppPalette.standard,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
