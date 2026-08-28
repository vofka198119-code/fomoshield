import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/typography_helpers.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/themed_header.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../../shared/widgets/company_logo.dart';
import '../../../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Order Header — plain top bar (back arrow + centered "BUY/SELL Company"
// title + small company logo on the right), same shape as every other
// screen's fixed header (see company_detail_screen.dart's top bar). No
// card/gradient box — that was the previous design, replaced per user's
// explicit ask (2026-08-01). Price sits centered below it, plain text.
//
// Deliberately no day's %/$ change — that figure is tied to the chart
// period selected on the Company Detail screen the user just came from,
// and showing an unrelated daily change here read as confusing/misleading.
// ---------------------------------------------------------------------------

class OrderHeader extends StatelessWidget {
  final String symbol;
  final String companyName;
  final String? logo;
  final bool isBuy;
  final double price;
  final AppPalette palette;

  const OrderHeader({
    super.key,
    required this.symbol,
    required this.companyName,
    this.logo,
    required this.isBuy,
    required this.price,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                themedBackButton(context, palette),
                Expanded(
                  child: Center(
                    child: themedHeaderText(
                      '${isBuy ? l10n.tradeBuy : l10n.tradeSell} $companyName',
                      palette,
                      GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.accentPrimary,
                        width: 1.5,
                      ),
                    ),
                    child: CompanyLogo(
                      ticker: symbol,
                      logoUrl: logo,
                      radius: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        themedPriceText(
          formatUsd(price),
          palette,
          interNums(fontSize: 28, fontWeight: FontWeight.w600),
          fallbackColor: ThemeV2.textPrimary,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Order Type Tabs — Market / Limit. (Stop/Stop-Limit exist in the order
// model but aren't selectable here yet — same as before this split.)
// ---------------------------------------------------------------------------

class OrderTypeTabs extends StatelessWidget {
  final bool isLimit;
  final ValueChanged<bool> onChanged;
  final AppPalette palette;

  const OrderTypeTabs({
    super.key,
    required this.isLimit,
    required this.onChanged,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              context,
              l10n.orderEntryTabMarket,
              !isLimit,
              () => onChanged(false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _tab(
              context,
              l10n.orderEntryTabLimit,
              isLimit,
              () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? palette.windowGradient : null,
          color: active && palette.windowGradient == null
              ? palette.accentPrimary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? palette.accentPrimary : palette.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? palette.accentPrimary : palette.textBody,
          ),
        ),
      ),
    );
  }
}
