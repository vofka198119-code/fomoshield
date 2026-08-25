// ---------------------------------------------------------------------------
// Asset Row Widget — элемент списка активов
// ---------------------------------------------------------------------------
// Broker style: logo, название, тикер + доля %, справа стоимость + P&L
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart' show themedPriceText;
import '../../../core/theme/themed_divider.dart';
import '../../../core/cache/logo_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_naming.dart';

class AssetRowWidget extends ConsumerWidget {
  final StressTestHolding holding;
  final StressTestSession session;
  final VoidCallback onTap;
  final AppPalette palette;

  const AssetRowWidget({
    super.key,
    required this.holding,
    required this.session,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pnl = session.positionPnL[holding.symbol] ?? 0.0;
    final isPositive = pnl >= 0;
    final costBasis = holding.shares * holding.avgCost;
    final positionValue = costBasis + pnl;
    final totalValue = session.totalValue;
    final allocation = totalValue > 0
        ? (positionValue / totalValue) * 100
        : 0.0;

    final logoAsync = ref.watch(cachedLogoProvider(holding.symbol));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                // Logo
                SizedBox(
                  width: 40,
                  height: 40,
                  child: logoAsync.when(
                    data: (url) => CompanyLogo(
                      ticker: holding.symbol,
                      logoUrl: url,
                      radius: 20,
                    ),
                    error: (_, _) =>
                        CompanyLogo(ticker: holding.symbol, radius: 20),
                    loading: () =>
                        CompanyLogo(ticker: holding.symbol, radius: 20),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + Ticker + Allocation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolveStressTestCompanyName(ref, holding.symbol),
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.textHeader,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${holding.symbol} · ${allocation.toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: palette.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
                // Value + P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    themedPriceText(
                      formatUsd(positionValue),
                      palette,
                      GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      fallbackColor: ThemeV2.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatUsdSigned(pnl),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isPositive ? ThemeV2.success : ThemeV2.loss,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: palette.textBody,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        themedRowDivider(palette),
      ],
    );
  }
}
