import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';

// ===========================================================================
// Key Metrics — P/E, дивиденды, маржинальность (из 30-дневного кэша)
// ===========================================================================

class KeyMetricsSection extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const KeyMetricsSection({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final m = metrics['metric'] as Map<String, dynamic>? ?? {};
    if (m.isEmpty) return const SizedBox.shrink();

    final pe = _double(m['peTTM']);
    final divYield = _double(m['dividendYieldIndicatedAnnual']);
    final netMargin = _double(m['netProfitMarginTTM']);
    final opMargin = _double(m['operatingMarginTTM']);
    final grossMargin = _double(m['grossMarginTTM']);
    final roe = _double(m['roeTTM']);

    final items = <_MetricItem>[
      _MetricItem(
        'P/E',
        pe > 0 ? pe.toStringAsFixed(1) : 'N/A',
        'Price-to-Earnings',
      ),
      _MetricItem(
        'Div. Yield',
        divYield > 0 ? '${(divYield * 100).toStringAsFixed(2)}%' : 'N/A',
        'Dividend Yield',
      ),
      _MetricItem(
        'Net Margin',
        netMargin > 0 ? '${(netMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Net Profit Margin',
      ),
      _MetricItem(
        'Op. Margin',
        opMargin > 0 ? '${(opMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Operating Margin',
      ),
      _MetricItem(
        'Gross Margin',
        grossMargin > 0 ? '${(grossMargin * 100).toStringAsFixed(1)}%' : 'N/A',
        'Gross Margin',
      ),
      if (m['roeTTM'] != null)
        _MetricItem(
          'ROE',
          '${(roe * 100).toStringAsFixed(1)}%',
          'Return on Equity',
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Metrics',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final showDivider = i < items.length - 1;
              return _metricRow(item, showDivider: showDivider);
            }),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(_MetricItem item, {required bool showDivider}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeV2.primary,
              ),
            ),
          ],
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(height: 1, color: ThemeV2.divider),
          ),
      ],
    );
  }

  double _double(dynamic v) => (v is num) ? v.toDouble() : 0.0;
}

class _MetricItem {
  final String label;
  final String value;
  final String subtitle;
  const _MetricItem(this.label, this.value, this.subtitle);
}
