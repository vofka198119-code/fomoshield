// ---------------------------------------------------------------------------
// Holdings Widget — Portfolio holdings preview (Bible Part 2, section 8)
// ---------------------------------------------------------------------------
// Показывает упрощённый список активов из активной stress test сессии
// или ссылку на портфель. Для реального портфеля использует portfoliosProvider.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../stress_test/stress_test_models.dart';
import '../../portfolio/portfolio_providers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';

class HoldingsWidget extends ConsumerWidget {
  const HoldingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try real portfolio first
    final portfolios = ref.watch(portfoliosProvider);

    if (portfolios.isNotEmpty) {
      final pf = portfolios.first;
      final cash = pf.cash;
      final holdingMap = pf.holdings;
      final symbols = holdingMap.keys.toList();

      // Total cost basis
      final totalCost = holdingMap.values.fold<double>(
        0,
        (s, h) => s + (h['shares']! * (h['cost']! / h['shares']!)),
      );

      return WidgetContainer(
        title: 'HOLDINGS',
        onTap: () => context.go('/portfolio'),
        showFooter: true,
        footerText: 'Full portfolio',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${_format(cash + totalCost)}',
                  style: interNums(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ThemeV2.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${symbols.length} holding${symbols.length == 1 ? '' : 's'} · \$${_format(cash)} cash',
                  style: interNums(
                    fontSize: 12,
                    color: ThemeV2.textSecondary,
                  ),
                ),
                if (symbols.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...symbols.take(3).map((sym) {
                    final h = holdingMap[sym]!;
                    final shares = h['shares']!;
                    final avgCost = h['cost']! / shares;
                    final value = shares * avgCost;
                    return _simpleHoldingRow(sym, value, null);
                  }),
                  if (symbols.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${symbols.length - 3} more',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    // Fallback: stress test holdings
    final sessions = ref.watch(stressTestProvider);
    final activeSession = sessions.where(
      (s) => s.status == StressTestStatus.active ||
          s.status == StressTestStatus.setup,
    ).firstOrNull;

    if (activeSession != null && activeSession.holdings.isNotEmpty) {
      final holdings = activeSession.holdings;
      final prices = activeSession.currentPrices;

      return WidgetContainer(
        title: 'HOLDINGS',
        onTap: () => context.go('/stress-test/${activeSession.id}'),
        showFooter: true,
        footerText: 'Open stress test',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...holdings.take(3).map((h) {
                  final currentPrice = prices[h.symbol] ?? h.avgCost;
                  final value = h.shares * currentPrice;
                  final change =
                      ((currentPrice - h.avgCost) / h.avgCost * 100);
                  return _simpleHoldingRow(
                    h.symbol,
                    value,
                    change,
                  );
                }),
                if (holdings.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '+${holdings.length - 3} more',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ),
                if (holdings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No holdings yet',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // Empty state
    return WidgetContainer(
      title: 'HOLDINGS',
      onTap: () => context.go('/stress-test-hub'),
      showFooter: true,
      footerText: 'Start stress test',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Icon(Icons.account_balance_rounded,
                  size: 32, color: ThemeV2.textSecondary.withOpacity(0.3)),
              const SizedBox(height: 8),
              Text(
                'No holdings yet.\nStart a stress test to invest.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeV2.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simpleHoldingRow(String symbol, double value, double? change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ThemeV2.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.substring(0, 1),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              symbol,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${_format(value)}',
                style: interNums(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.textPrimary,
                ),
              ),
              if (change != null)
                Text(
                  '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                  style: interNums(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: change >= 0 ? ThemeV2.success : ThemeV2.loss,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double v) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return fmt.format(v);
  }
}

