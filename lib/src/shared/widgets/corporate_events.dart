// ---------------------------------------------------------------------------
// Corporate Events Widget
// ---------------------------------------------------------------------------
// Shows upcoming/past ex-dividend dates, dividend payouts, and brief
// descriptions for each company in the portfolio.
// Each company row is clickable → shows a popup with details.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/services/gics_sector_mapper.dart';
import '../../features/stress_test/stress_test_engine.dart';
import '../../features/stress_test/stress_test_models.dart';

// Hardcoded dividend data for popular stocks
final Map<String, _DividendInfo> _dividendData = {
  'AAPL': _DividendInfo(
    companyName: 'Apple Inc.',
    exDivDate: 'Mar 10, 2025',
    payDate: 'Mar 20, 2025',
    amount: 0.25,
    frequency: 'Quarterly',
    description:
        'Apple continues its capital return program with a \$0.25 quarterly dividend.',
  ),
  'MSFT': _DividendInfo(
    companyName: 'Microsoft Corporation',
    exDivDate: 'Feb 19, 2025',
    payDate: 'Mar 13, 2025',
    amount: 0.83,
    frequency: 'Quarterly',
    description:
        'Microsoft increased its quarterly dividend by 10% reflecting strong cash flow.',
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
    description:
        'NVIDIA maintains a modest dividend while reinvesting heavily in AI.',
  ),
  'META': _DividendInfo(
    companyName: 'Meta Platforms Inc.',
    exDivDate: 'Feb 18, 2025',
    payDate: 'Mar 26, 2025',
    amount: 0.50,
    frequency: 'Quarterly',
    description:
        'Meta initiated a \$0.50 quarterly dividend alongside record profits.',
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
    description:
        'P&G maintains its Dividend King status with 68 consecutive years of growth.',
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
    description:
        'Exxon rewards shareholders with increased dividend amid high energy prices.',
  ),
  'TSLA': _DividendInfo(
    companyName: 'Tesla Inc.',
    exDivDate: 'Mar 20, 2025',
    payDate: 'Apr 5, 2025',
    amount: 0.05,
    frequency: 'Variable',
    description:
        'Tesla pays a small variable dividend as part of shareholder returns.',
  ),
  'NFLX': _DividendInfo(
    companyName: 'Netflix Inc.',
    exDivDate: 'Mar 3, 2025',
    payDate: 'Mar 25, 2025',
    amount: 0.35,
    frequency: 'Quarterly',
    description:
        'Netflix began paying dividends after reaching mature subscriber growth.',
  ),
  'DIS': _DividendInfo(
    companyName: 'The Walt Disney Company',
    exDivDate: 'Feb 26, 2025',
    payDate: 'Mar 19, 2025',
    amount: 0.45,
    frequency: 'Semi-Annual',
    description:
        'Disney restores its dividend as theme parks and streaming turn profitable.',
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

class CorporateEventsWidget extends StatefulWidget {
  final String sessionId;
  final List<StressTestHolding> holdings;
  final NewsEvent? activeNewsEvent;
  final List<HypeEvent> activeHypeEvents;

  const CorporateEventsWidget({
    super.key,
    required this.sessionId,
    required this.holdings,
    this.activeNewsEvent,
    this.activeHypeEvents = const [],
  });

  @override
  State<CorporateEventsWidget> createState() => _CorporateEventsWidgetState();
}

class _CorporateEventsWidgetState extends State<CorporateEventsWidget> {
  bool _showAll = false;

  /// Held symbols currently touched by News (own symbol) or Hype (own
  /// GICS sector) — one row per (event, symbol) pair so a sector-wide
  /// Hype event shows separately for each affected holding.
  List<_LiveEventRow> _buildLiveEventRows() {
    final rows = <_LiveEventRow>[];
    final news = widget.activeNewsEvent;
    if (news != null &&
        widget.holdings.any((h) => h.symbol == news.symbol)) {
      rows.add(_LiveEventRow.news(news));
    }
    for (final hype in widget.activeHypeEvents) {
      for (final h in widget.holdings) {
        if (resolveGicsSector(h.symbol) == hype.sector) {
          rows.add(_LiveEventRow.hype(hype, h.symbol));
        }
      }
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // Match holdings with dividend data
    final events = <MapEntry<StressTestHolding, _DividendInfo>>[];
    for (final h in widget.holdings) {
      final info = _dividendData[h.symbol];
      if (info != null) {
        events.add(MapEntry(h, info));
      }
    }

    final liveEvents = _buildLiveEventRows();

    if (events.isEmpty && liveEvents.isEmpty) return const SizedBox.shrink();

    final displayEvents = _showAll ? events : events.take(3).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
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
          const Divider(
            height: 1,
            indent: 0,
            endIndent: 0,
            color: ThemeV2.divider,
          ),
          const SizedBox(height: 8),
          // Live News/Hype rows — active market-moving events, not the
          // static dividend calendar below.
          for (final row in liveEvents) ...[
            _LiveEventTile(sessionId: widget.sessionId, row: row),
            const SizedBox(height: 8),
          ],
          if (events.isNotEmpty) ...[
            Text(
              'Upcoming ex-dividend dates and payouts',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: ThemeV2.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Events list
          ...displayEvents.map(
            (entry) => _EventRow(holding: entry.key, info: entry.value),
          ),
          if (events.length > 3) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _showAll = !_showAll),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: ThemeV2.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _showAll ? 'Less' : 'More (${events.length - 3})',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live News/Hype event row — active market-moving micro-scenarios, as
// opposed to the static dividend calendar above. Tapping opens the Why
// screen for the affected symbol (same detail already shown there).
// ---------------------------------------------------------------------------

class _LiveEventRow {
  final String symbol;
  final bool isNews;
  final bool isPositive;
  final String title;
  final double targetAmplitude;
  final int currentTick;
  final int rampDurationTicks;

  const _LiveEventRow({
    required this.symbol,
    required this.isNews,
    required this.isPositive,
    required this.title,
    required this.targetAmplitude,
    required this.currentTick,
    required this.rampDurationTicks,
  });

  factory _LiveEventRow.news(NewsEvent event) => _LiveEventRow(
    symbol: event.symbol,
    isNews: true,
    isPositive: event.isPositive,
    title: event.headline,
    targetAmplitude: event.targetAmplitude,
    currentTick: event.currentTick,
    rampDurationTicks: event.rampDurationTicks,
  );

  factory _LiveEventRow.hype(HypeEvent event, String symbol) => _LiveEventRow(
    symbol: symbol,
    isNews: false,
    isPositive: event.isPositive,
    title: '${event.sector.label} sector ${event.isPositive ? 'rally' : 'sell-off'}',
    targetAmplitude: event.targetAmplitude,
    currentTick: event.currentTick,
    rampDurationTicks: event.rampDurationTicks,
  );
}

class _LiveEventTile extends StatelessWidget {
  final String sessionId;
  final _LiveEventRow row;

  const _LiveEventTile({required this.sessionId, required this.row});

  String _remainingLabel() {
    final ticksLeft = (row.rampDurationTicks - row.currentTick).clamp(
      0,
      row.rampDurationTicks,
    );
    final secondsLeft = ticksLeft * tickIntervalSeconds;
    final hours = secondsLeft ~/ 3600;
    final minutes = (secondsLeft % 3600) ~/ 60;
    if (hours > 0) return '≈${hours}h ${minutes}m left';
    if (minutes > 0) return '≈${minutes}m left';
    return 'wrapping up';
  }

  @override
  Widget build(BuildContext context) {
    final color = row.isPositive ? ThemeV2.success : ThemeV2.loss;
    return GestureDetector(
      onTap: () => context.push('/stress-test/$sessionId/stock/${row.symbol}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              row.isNews
                  ? (row.isPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded)
                  : Icons.local_fire_department_rounded,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row.symbol} · ${row.title}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${row.isPositive ? '+' : ''}'
                    '${(row.targetAmplitude * 100).toStringAsFixed(1)}% target · ${_remainingLabel()}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: ThemeV2.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final StressTestHolding holding;
  final _DividendInfo info;

  const _EventRow({required this.holding, required this.info});

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
            _detailRow(
              'Dividend',
              '\$${info.amount.toStringAsFixed(2)} per share',
            ),
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
      Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary),
      ),
      Text(
        value,
        style: interNums(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ThemeV2.textPrimary,
        ),
      ),
    ],
  );
}
