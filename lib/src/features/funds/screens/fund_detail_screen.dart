import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import '../sector_labels.dart';

// ---------------------------------------------------------------------------
// Fund Detail — ETF Fund Emulation, Phase 1. Live on-demand NAV/holdings via
// fundDetailProvider (server-authoritative, see docs/ETF_FUND_EMULATION.md's
// "Технический вызов" section). Read-only for Phase 1 — Buy/Sell (Phase 2)
// and the management blotter (Phase 4) aren't built yet.
// ---------------------------------------------------------------------------

class FundDetailScreen extends ConsumerWidget {
  final String fundId;

  const FundDetailScreen({super.key, required this.fundId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final fundAsync = ref.watch(fundDetailProvider(fundId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: fundAsync.maybeWhen(
          data: (fund) => themedHeaderText(
            fund.ticker,
            palette,
            GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        child: fundAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: palette.accentPrimary),
          ),
          error: (_, _) => Center(
            child: Text(
              l10n.etfFundsListErrorMessage,
              style: GoogleFonts.inter(color: palette.textBody),
            ),
          ),
          data: (fund) => RefreshIndicator(
            color: palette.accentPrimary,
            onRefresh: () async => ref.invalidate(fundDetailProvider(fundId)),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _HeroCard(fund: fund, palette: palette, l10n: l10n),
                const SizedBox(height: 16),
                if (fund.navHistory.length > 1) ...[
                  _NavHistoryCard(fund: fund, palette: palette, l10n: l10n),
                  const SizedBox(height: 16),
                ],
                if (fund.description != null && fund.description!.isNotEmpty) ...[
                  _TextCard(
                    title: l10n.etfFundDetailDescriptionTitle,
                    body: fund.description!,
                    palette: palette,
                  ),
                  const SizedBox(height: 16),
                ],
                if (fund.strategy != null && fund.strategy!.isNotEmpty) ...[
                  _TextCard(
                    title: l10n.etfFundDetailStrategyTitle,
                    body: fund.strategy!,
                    palette: palette,
                  ),
                  const SizedBox(height: 16),
                ],
                CardFrame(
                  palette: palette,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.etfFundDetailSectorsTitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.textBody,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: fund.sectors
                            .map(
                              (code) => Chip(
                                label: Text(sectorLabel(l10n, code)),
                                labelStyle: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: palette.textHeader,
                                ),
                                backgroundColor:
                                    palette.accentPrimary.withValues(alpha: 0.12),
                                side: BorderSide.none,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                CardFrame(
                  palette: palette,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.etfFundDetailHoldingsTitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: palette.textBody,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (fund.holdings.isEmpty)
                        Text(
                          l10n.etfFundDetailHoldingsEmpty,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: palette.textBody,
                          ),
                        )
                      else
                        ...fund.holdings.map(
                          (h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    h.symbol,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: palette.textHeader,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${h.value.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(color: palette.textBody),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;
  final AppLocalizations l10n;

  const _HeroCard({required this.fund, required this.palette, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fund.name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statColumn(l10n.etfFundDetailNavLabel, '\$${fund.navPerUnit.toStringAsFixed(2)}'),
              _statColumn(l10n.etfFundDetailAumLabel, '\$${fund.aum.toStringAsFixed(0)}'),
              _statColumn(
                l10n.etfFundDetailUnitsLabel,
                fund.unitsOutstanding.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: palette.textBody),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: palette.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavHistoryCard extends StatelessWidget {
  final FundDetail fund;
  final AppPalette palette;
  final AppLocalizations l10n;

  const _NavHistoryCard({required this.fund, required this.palette, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final points = fund.navHistory
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.navPerUnit))
        .toList();
    final values = fund.navHistory.map((p) => p.navPerUnit).toList();
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final up = values.last >= values.first;

    return CardFrame(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.etfFundDetailNavHistoryTitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                minY: minY - (maxY - minY) * 0.1 - 0.01,
                maxY: maxY + (maxY - minY) * 0.1 + 0.01,
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: up ? ThemeV2.success : ThemeV2.loss,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (up ? ThemeV2.success : ThemeV2.loss).withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final String body;
  final AppPalette palette;

  const _TextCard({required this.title, required this.body, required this.palette});

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: palette.textBody,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: palette.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
