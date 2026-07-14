// ---------------------------------------------------------------------------
// Corporate Events Widget
// ---------------------------------------------------------------------------
// Shows upcoming/past ex-dividend dates, dividend payouts, and brief
// descriptions for each company in the portfolio.
// Each company row is clickable → shows a popup with details.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';

// Hardcoded dividend data for popular stocks
final Map<String, _DividendInfo> _dividendData = {
  'AAPL': _DividendInfo(
    companyName: 'Apple Inc.',
    exDivDate: 'Mar 10, 2025',
    payDate: 'Mar 20, 2025',
    amount: 0.25,
    frequency: 'Quarterly',
    description: 'Apple continues its capital return program with a \$0.25 quarterly dividend.',
  ),
  'MSFT': _DividendInfo(
    companyName: 'Microsoft Corporation',
    exDivDate: 'Feb 19, 2025',
    payDate: 'Mar 13, 2025',
    amount: 0.83,
    frequency: 'Quarterly',
    description: 'Microsoft increased its quarterly dividend by 10% reflecting strong cash flow.',
  ),
  'GOOGL': _DividendInfo(
    companyName: 'Alphabet Inc.',
    exDivDate: 'Mar 5, 2025',
    payDate: 'Mar 20, 2025',
    amount: 0.20,
    frequency: 'Quarterly',
    description: 'Alphabet initiated a dividend program for the first time.',
  ),
  'AMZN': _DividendInfo(
    companyName: 'Amazon.com Inc.',
    exDivDate: 'Feb 25, 2025',
    payDate: 'Mar 28, 2025',
    amount: 0.15,
    frequency: 'Quarterly',
    description: 'Amazon pays its first-ever regular quarterly dividend.',
  ),
  'NVDA': _DividendInfo(
    companyName: 'NVIDIA Corporation',
    exDivDate: 'Mar 12, 2025',
    payDate: 'Apr 2, 2025',
    amount: 0.04,
    frequency: 'Quarterly',
    description: 'NVIDIA maintains a modest dividend while reinvesting heavily in AI.',
  ),
  'META': _DividendInfo(
    companyName: 'Meta Platforms Inc.',
    exDivDate: 'Feb 18, 2025',
    payDate: 'Mar 26, 2025',
    amount: 0.50,
    frequency: 'Quarterly',
    description: 'Meta initiated a \$0.50 quarterly dividend alongside record profits.',
  ),
  'JPM': _DividendInfo(
    companyName: 'JPMorgan Chase & Co.',
    exDivDate: 'Mar 7, 2025',
    payDate: 'Apr 1, 2025',
    amount: 1.25,
    frequency: 'Quarterly',
    description: 'JPMorgan raises dividend after Fed stress test approval.',
  ),
  'V': _DividendInfo(
    companyName: 'Visa Inc.',
    exDivDate: 'Feb 14, 2025',
    payDate: 'Mar 5, 2025',
    amount: 0.59,
    frequency: 'Quarterly',
    description: 'Visa continues its consistent dividend growth policy.',
  ),
  'KO': _DividendInfo(
    companyName: 'The Coca-Cola Company',
    exDivDate: 'Mar 14, 2025',
    payDate: 'Apr 1, 2025',
    amount: 0.51,
    frequency: 'Quarterly',
    description: 'Coca-Cola extends its 62-year dividend growth streak.',
  ),
  'PG': _DividendInfo(
    companyName: 'Procter & Gamble Co.',
    exDivDate: 'Feb 21, 2025',
    payDate: 'Mar 17, 2025',
    amount: 1.03,
    frequency: 'Quarterly',
    description: 'P&G maintains its Dividend King status with 68 consecutive years of growth.',
  ),
  'JNJ': _DividendInfo(
    companyName: 'Johnson & Johnson',
    exDivDate: 'Feb 28, 2025',
    payDate: 'Mar 18, 2025',
    amount: 1.24,
    frequency: 'Quarterly',
    description: 'J&J continues its 61-year dividend growth track record.',
  ),
  'XOM': _DividendInfo(
    companyName: 'Exxon Mobil Corporation',
    exDivDate: 'Mar 13, 2025',
    payDate: 'Apr 10, 2025',
    amount: 0.95,
    frequency: 'Quarterly',
    description: 'Exxon rewards shareholders with increased dividend amid high energy prices.',
  ),
  'TSLA': _DividendInfo(
    companyName: 'Tesla Inc.',
    exDivDate: 'Mar 20, 2025',
    payDate: 'Apr 5, 2025',
    amount: 0.05,
    frequency: 'Variable',
    description: 'Tesla pays a small variable dividend as part of shareholder returns.',
  ),
  'NFLX': _DividendInfo(
    companyName: 'Netflix Inc.',
    exDivDate: 'Mar 3, 2025',
    payDate: 'Mar 25, 2025',
    amount: 0.35,
    frequency: 'Quarterly',
    description: 'Netflix began paying dividends after reaching mature subscriber growth.',
  ),
  'DIS': _DividendInfo(
    companyName: 'The Walt Disney Company',
    exDivDate: 'Feb 26, 2025',
    payDate: 'Mar 19, 2025',
    amount: 0.45,
    frequency: 'Semi-Annual',
    description: 'Disney restores its dividend as theme parks and streaming turn profitable.',
  ),
};

class _DividendInfo {
  final String companyName;
  final String exDivDate;
  final String payDate;
  final double amount;
  final String frequency;
  final String description;

  const _DividendInfo({
    required this.companyName,
    required this.exDivDate,
    required this.payDate,
    required this.amount,
    required this.frequency,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Corporate Events Widget
// ---------------------------------------------------------------------------

class CorporateEventsWidget extends StatelessWidget {
  final List<StressTestHolding> holdings;

  const CorporateEventsWidget({super.key, required this.holdings});

  @override
  Widget build(BuildContext context) {
    // Match holdings with dividend data
    final events = <MapEntry<StressTestHolding, _DividendInfo>>[];
    for (final h in holdings) {
      final info = _dividendData[h.symbol];
      if (info != null) {
        events.add(MapEntry(h, info));
      }
    }

    if (events.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.event_note, size: 14, color: ThemeV2.primary),
              const SizedBox(width: 6),
              Text(
                'CORPORATE EVENTS',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, endIndent: 0, color: ThemeV2.divider),
          const SizedBox(height: 8),
          Text(
            'Upcoming ex-dividend dates and payouts',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          // Events list
          ...events.map((entry) => _EventRow(
            holding: entry.key,
            info: entry.value,
          )),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final StressTestHolding holding;
  final _DividendInfo info;

  const _EventRow({
    required this.holding,
    required this.info,
  });

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeV2.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(
              info.companyName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Symbol', holding.symbol),
            const SizedBox(height: 6),
            _detailRow('Ex-Dividend Date', info.exDivDate),
            const SizedBox(height: 6),
            _detailRow('Pay Date', info.payDate),
            const SizedBox(height: 6),
            _detailRow('Dividend', '\$${info.amount.toStringAsFixed(2)} per share'),
            const SizedBox(height: 6),
            _detailRow('Frequency', info.frequency),
            const SizedBox(height: 12),
            Text(
              info.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: ThemeV2.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            // Estimated payout for this holding
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ThemeV2.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on, size: 16, color: ThemeV2.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Est. payout: \$${(info.amount * holding.shares).toStringAsFixed(2)} on ${info.payDate}',
                      style: interNums(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: ThemeV2.success),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPayout = info.amount * holding.shares;

    return GestureDetector(
      onTap: () => _showPopup(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ThemeV2.divider.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          children: [
            // Symbol
            SizedBox(
              width: 44,
              child: Text(
                holding.symbol,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
                ),
              ),
            ),
            // Event details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ex-div: ${info.exDivDate}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  Text(
                    'Pays \$${info.amount.toStringAsFixed(2)}/share on ${info.payDate}',
                    style: interNums(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Est. total
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeV2.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${totalPayout.toStringAsFixed(1)}',
                style: interNums(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.success,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: ThemeV2.textSecondary),
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary)),
      Text(value, style: interNums(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeV2.textPrimary)),
    ],
  );
}
