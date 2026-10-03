// ---------------------------------------------------------------------------
// Fund Liquidation Detail Screen — reached by tapping a "fund bankruptcy
// settlement" bell notification. Same card shape as
// weekly_payout_detail_screen.dart (this app's "what just happened" family)
// but with the itemized breakdown the bankruptcy spec asked for: assets
// sold, broker commission, and the neustойка/+5% line (investor payouts
// only -- both are null for an employee's 1% cut).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_notification.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/theme_variant_provider.dart';
import '../../core/theme/themed_header.dart';
import '../../core/theme/themed_divider.dart';
import '../../shared/widgets/card_frame.dart';
import '../../shared/utils/currency_format.dart';
import '../../l10n/gen/app_localizations.dart';

class FundLiquidationDetailScreen extends ConsumerWidget {
  final AppNotification? notification;

  const FundLiquidationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final n = notification;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          l10n.fundLiquidationDetailTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: n == null
            ? Center(
                child: Text(
                  l10n.tradeNotFound,
                  style: GoogleFonts.inter(color: palette.textBody),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _SettlementDetailCard(notification: n, palette: palette),
              ),
      ),
    );
  }
}

class _SettlementDetailCard extends StatelessWidget {
  final AppNotification notification;
  final AppPalette palette;

  const _SettlementDetailCard({
    required this.notification,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isInvestor = notification.fundLiquidationRecipientType == 'investor';

    return CardFrame(
      decoration: FomoShieldTheme.cardDecoration,
      palette: palette,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeV2.loss.withValues(alpha: 0.12),
                  border: Border.all(
                    color: ThemeV2.loss.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: ThemeV2.loss,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isInvestor
                      ? l10n.fundLiquidationDetailRecipientInvestor
                      : l10n.fundLiquidationDetailRecipientEmployee,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textHeader,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          themedDivider(palette, indent: 0, endIndent: 0, height: 1),
          const SizedBox(height: 16),
          if (notification.payoutAmount != null)
            _DetailRow(
              label: l10n.fundLiquidationDetailAmountLabel,
              value: formatUsd(notification.payoutAmount!),
              valueColor: ThemeV2.success,
              palette: palette,
            ),
          if (notification.fundLiquidationFundName != null)
            _DetailRow(
              label: l10n.fundLiquidationDetailFundLabel,
              value: notification.fundLiquidationFundName!,
              palette: palette,
            ),
          // How many of the investor's own units were liquidated (2026-09-14
          // follow-up ask: "сколько было паев у инвестора и сколько
          // продались") -- always ALL of them in a full liquidation, so
          // "held" and "sold" are the same number, shown once.
          if (notification.fundLiquidationUnitsHeld != null)
            _DetailRow(
              label: l10n.fundLiquidationDetailUnitsLabel,
              value: l10n.fundUnitsCount(
                notification.fundLiquidationUnitsHeld!.toStringAsFixed(4),
              ),
              palette: palette,
            ),
          // The real sale value and the real commission the fund actually
          // paid stay exactly as computed server-side (see
          // fundBankruptcyService.js) -- an investor's settlement just
          // doesn't need to see either number (2026-09-14 ask: "для
          // инвестора не нужно"). Assets sold reads as a plain fact
          // ("sold at market price") instead of a dollar figure; broker
          // commission always displays as $0 here, distinct from the real
          // fund-side charge.
          if (notification.fundLiquidationAssetsSoldValue != null)
            _DetailRow(
              label: l10n.fundLiquidationDetailAssetsSoldLabel,
              value: l10n.fundLiquidationDetailSoldAtMarketValue,
              palette: palette,
            ),
          if (notification.fundLiquidationBrokerCommission != null)
            _DetailRow(
              label: l10n.fundLiquidationDetailCommissionLabel,
              value: formatUsd(0),
              palette: palette,
            ),
          if (notification.fundLiquidationNeustoika != null &&
              notification.fundLiquidationNeustoika! > 0)
            _DetailRow(
              label: l10n.fundLiquidationDetailNeustoikaLabel,
              value: formatUsd(notification.fundLiquidationNeustoika!),
              valueColor: ThemeV2.success,
              palette: palette,
            ),
          _DetailRow(
            label: l10n.fundLiquidationDetailReasonLabel,
            value: l10n.fundLiquidationDetailReasonValue,
            palette: palette,
          ),
          _DetailRow(
            label: l10n.tradeDateLabel,
            value: _formatDate(context, notification.createdAt),
            isLast: true,
            palette: palette,
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.yMMMd(locale).add_Hm().format(d);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;
  final AppPalette palette;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.palette,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: palette.textBody),
          ),
          valueColor != null
              ? Text(
                  value,
                  style: interNums(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                )
              : themedPriceText(
                  value,
                  palette,
                  interNums(fontSize: 14, fontWeight: FontWeight.w600),
                ),
        ],
      ),
    );
  }
}
