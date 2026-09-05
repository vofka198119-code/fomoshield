import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'metric_info_data.dart';

// ===========================================================================
// Key Metrics — P/E, дивиденды, маржинальность (из 30-дневного кэша)
// ===========================================================================

class KeyMetricsSection extends StatelessWidget {
  final Map<String, dynamic> metrics;
  final AppPalette palette;

  const KeyMetricsSection({
    super.key,
    required this.metrics,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m = metrics['metric'] as Map<String, dynamic>? ?? {};
    if (m.isEmpty) return const SizedBox.shrink();

    // Shown as real numbers even when negative (e.g. a loss-making
    // company's margins) — N/A means the field is genuinely absent from
    // Finnhub's response, not that the value happens to be <= 0.
    final pe = _doubleOrNull(m['peTTM']);
    final divYield = _doubleOrNull(m['dividendYieldIndicatedAnnual']);
    final netMargin = _doubleOrNull(m['netProfitMarginTTM']);
    final opMargin = _doubleOrNull(m['operatingMarginTTM']);
    final grossMargin = _doubleOrNull(m['grossMarginTTM']);
    final roe = _doubleOrNull(m['roeTTM']);
    final na = l10n.commonNotAvailable;

    // Tuple is (metricInfoData.dart's stable English lookup key, localized
    // display label, formatted value) — the lookup key must stay the fixed
    // English string since metricInfoIdByLabel's keys aren't translated.
    final items = <(String, String, String)>[
      ('P/E', l10n.companyDetailMetricPe, pe != null ? pe.toStringAsFixed(1) : na),
      (
        'Dividend Yield',
        l10n.companyDetailMetricDividendYield,
        divYield != null ? '${divYield.toStringAsFixed(2)}%' : na,
      ),
      (
        'Net Margin',
        l10n.companyDetailMetricNetMargin,
        netMargin != null ? '${netMargin.toStringAsFixed(1)}%' : na,
      ),
      (
        'Operating Margin',
        l10n.companyDetailMetricOperatingMargin,
        opMargin != null ? '${opMargin.toStringAsFixed(1)}%' : na,
      ),
      (
        'Gross Margin',
        l10n.companyDetailMetricGrossMargin,
        grossMargin != null ? '${grossMargin.toStringAsFixed(1)}%' : na,
      ),
      if (roe != null)
        ('ROE', l10n.companyDetailMetricRoe, '${roe.toStringAsFixed(1)}%'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CardFrame(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: FomoShieldTheme.cardDecoration,
        palette: palette,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            themedHeaderText(
              l10n.companyDetailKeyMetricsTitle,
              palette,
              FomoShieldTheme.cardTitle(),
            ),
            const SizedBox(height: 10),
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _row(context, items[i].$1, items[i].$2, items[i].$3),
            ],
          ],
        ),
      ),
    );
  }

  // Same shape/type-scale as Position Section's "MY INVESTMENTS" `_row` —
  // label/value on one line, no subtitle, no divider between rows. Label
  // and value font match the "Active — {duration}" tile in the Home MY
  // STRESS TEST widget (stress_test_widget.dart) — the app's reference
  // for readable label+number pairs; value uses interNums() (tabular
  // figures) rather than plain GoogleFonts.inter like every other number
  // in the app.
  Widget _row(
    BuildContext context,
    String metricKey,
    String label,
    String value,
  ) {
    final infoId = metricInfoIdByLabel[metricKey];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.textHeader,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            themedPriceText(
              value,
              palette,
              interNums(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (infoId != null) ...[
              const SizedBox(width: 6),
              themedHelpIcon(
                palette: palette,
                onTap: () => context.push('/metric-info/$infoId'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  double? _doubleOrNull(dynamic v) => (v is num) ? v.toDouble() : null;
}
