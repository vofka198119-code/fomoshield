import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/cache/logo_providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../utils/currency_format.dart';
import 'company_logo.dart';

/// Shared trade-history row: ringed logo, asset name, BUY/SELL badge.
/// Used by both the Stress Test and the real-market Portfolio trade
/// history widgets/screens so the visual stays identical everywhere.
/// Divider color/width shared with the Holdings row list, so the two lists
/// read as one visual system.
const _kRowDividerColor = Color(0x0F000000); // Colors.black @ 6% alpha
const _kRowDividerWidth = 0.5;

class TradeHistoryTile extends StatelessWidget {
  final String symbol;
  final String companyName;
  final bool isBuy;
  final double totalValue;
  final VoidCallback? onTap;
  final bool showDivider;

  const TradeHistoryTile({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.isBuy,
    required this.totalValue,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isBuy ? ThemeV2.success : ThemeV2.loss;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: showDivider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _kRowDividerColor,
                      width: _kRowDividerWidth,
                    ),
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final logoAsync = ref.watch(cachedLogoProvider(symbol));
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: logoAsync.when(
                          data: (url) => CompanyLogo(
                            ticker: symbol,
                            logoUrl: url,
                            radius: 17,
                          ),
                          error: (_, _) =>
                              CompanyLogo(ticker: symbol, radius: 17),
                          loading: () =>
                              CompanyLogo(ticker: symbol, radius: 17),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatUsd(totalValue),
                    style: interNums(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isBuy
                          ? AppLocalizations.of(context)!.tradeBuy
                          : AppLocalizations.of(context)!.tradeSell,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
