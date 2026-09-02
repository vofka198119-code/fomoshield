// ---------------------------------------------------------------------------
// Weekly Payout Detail Screen — reached by tapping a "weekly deposit" bell
// notification. Used to just navigate to /portfolio with no actual detail
// shown, even though the notification's own copy says "tap to view"
// (weeklyPayoutDetail ARB string). Same card shape as Trade Detail (see
// stress_test_trade_detail_screen.dart / portfolio_trade_detail_screen.dart)
// so it reads as one family with the app's other "what just happened"
// screens rather than a one-off popup.
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

class WeeklyPayoutDetailScreen extends ConsumerWidget {
  final AppNotification? notification;

  const WeeklyPayoutDetailScreen({super.key, required this.notification});

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
          l10n.weeklyPayoutDetailTitle,
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
                child: _PayoutDetailCard(notification: n, palette: palette),
              ),
      ),
    );
  }
}

class _PayoutDetailCard extends StatelessWidget {
  final AppNotification notification;
  final AppPalette palette;

  const _PayoutDetailCard({required this.notification, required this.palette});

  // Notifications saved before [AppNotification.payoutAmount] existed have
  // no value there — fall back to pulling it out of the already-formatted
  // `detail` string (always "$X,XXX.XX ..." — formatUsd's own output, see
  // currency_format.dart) instead of just hiding the row for every payout
  // notification a user already had in their history at the time this
  // screen shipped.
  double? get _amount {
    if (notification.payoutAmount != null) return notification.payoutAmount;
    final match = RegExp(r'\$([\d\s]+(?:\.\d+)?)').firstMatch(notification.detail);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(' ', ''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPaused =
        notification.type == AppNotificationType.weeklyPayoutPaused;
    final accent = isPaused ? ThemeV2.loss : ThemeV2.success;
    final amount = _amount;

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
                  color: accent.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isPaused
                      ? Icons.pause_circle_outline_rounded
                      : Icons.savings_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
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
          if (amount != null)
            _DetailRow(
              label: l10n.weeklyPayoutDetailAmountLabel,
              value: formatUsd(amount),
              valueColor: accent,
              palette: palette,
            ),
          if (notification.portfolioLabel != null)
            _DetailRow(
              label: l10n.weeklyPayoutDetailAccountLabel,
              value: notification.portfolioLabel!,
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
