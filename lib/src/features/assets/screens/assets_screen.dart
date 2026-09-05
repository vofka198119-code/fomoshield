// ---------------------------------------------------------------------------
// Stress Test Assets Screen — holdings list (Block 1)
// ---------------------------------------------------------------------------
// Broker style:
//   - Total Balance (TOTAL VALUE, unrealized P&L, start cash)
//   - Search bar + sort toggles (Value / Market Price)
//   - Holdings list with logo, name, ticker, weight, value, P&L
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../widgets/asset_row_widget.dart';

/// Asset list sort mode
enum AssetSortMode { value, marketPrice }

class AssetsScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AssetsScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  AssetSortMode _sortMode = AssetSortMode.value;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  List<StressTestHolding> _sortedAndFiltered(StressTestSession session) {
    var list = session.holdings.toList();

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toUpperCase();
      list = list.where((h) => h.symbol.contains(q)).toList();
    }

    // Sort
    if (_sortMode == AssetSortMode.value) {
      list.sort((a, b) {
        final priceA = session.currentPrices[a.symbol] ?? a.entryPrice;
        final priceB = session.currentPrices[b.symbol] ?? b.entryPrice;
        return (b.shares * priceB).compareTo(a.shares * priceA);
      });
    } else {
      list.sort((a, b) {
        final priceA = session.currentPrices[a.symbol] ?? a.entryPrice;
        final priceB = session.currentPrices[b.symbol] ?? b.entryPrice;
        return priceB.compareTo(priceA);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(stressTestRefreshProvider);
    final session = _session;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: themedHeaderText(
            l10n.assetsScreenTitle,
            palette,
            GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          leading: themedBackButton(context, palette),
        ),
        body: Center(
          child: Text(
            l10n.stressTestSessionNotFound,
            style: GoogleFonts.inter(color: palette.textBody, fontSize: 14),
          ),
        ),
      );
    }

    final holdings = _sortedAndFiltered(session);
    final totalValue = session.totalValue;
    final startCash = session.startingCash;
    final unrealizedPnl = session.unrealizedPnl;
    final pnlPercent = session.unrealizedPnlPercent;
    final isPositive = unrealizedPnl >= 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: themedHeaderText(
          l10n.assetsScreenTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: themedBackButton(context, palette),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: Column(
          children: [
            // ── Developer Trace Bar (only when enabled) ─────────────
            if (session.enableDeveloperTrace) _buildDevTraceBar(session),

            // ── Total Balance Header ─────────────────────────────
            _buildBalanceHeader(
              l10n: l10n,
              totalValue: totalValue,
              unrealizedPnl: unrealizedPnl,
              pnlPercent: pnlPercent,
              isPositive: isPositive,
              startCash: startCash,
              palette: palette,
            ),

            // ── Search Bar ───────────────────────────────────────
            _buildSearchBar(l10n, palette),

            // ── Sort Toggle ──────────────────────────────────────
            _buildSortToggle(l10n, palette),

            // ── Divider ──────────────────────────────────────────
            palette.dividerGradient != null
                ? themedDivider(palette, indent: 0, endIndent: 0)
                : Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),

            // ── Assets List ──────────────────────────────────────
            Expanded(
              child: holdings.isEmpty
                  ? Center(
                      child: Text(
                        l10n.assetsScreenNoAssets,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: palette.textBody,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: holdings.length,
                      itemBuilder: (context, index) {
                        final h = holdings[index];
                        return AssetRowWidget(
                          holding: h,
                          session: session,
                          palette: palette,
                          onTap: () {
                            context.push(
                              '/stress-test/${widget.sessionId}/stock/${h.symbol}',
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Developer Trace Bar — видна только при enableDeveloperTrace == true.
  /// Отображает текущие метки MarketCycleManager в техническом стиле.
  Widget _buildDevTraceBar(StressTestSession session) {
    final l10n = AppLocalizations.of(context)!;
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A2E),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _devChip(
              l10n.assetsScreenDevPhaseLabel,
              session.devMarketPhase.isNotEmpty
                  ? session.devMarketPhase.toUpperCase()
                  : '—',
              const Color(0xFF7B68EE),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              l10n.assetsScreenDevTempLabel,
              '${session.devMarketTemperature.toStringAsFixed(1)}°',
              _tempColor(session.devMarketTemperature),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              l10n.assetsScreenDevFatigueLabel,
              '${(session.devFatigue * 100).toStringAsFixed(0)}%',
              const Color(0xFFFFA726),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              l10n.assetsScreenDevSeedLabel,
              session.simulationSeed.toString(),
              const Color(0xFF66BB6A),
              monoStyle,
            ),
            const SizedBox(width: 12),
            _devChip(
              l10n.assetsScreenDevTickLabel,
              '#${session.devCurrentTick}',
              const Color(0xFF42A5F5),
              monoStyle,
            ),
            for (final chip in _activeEventChips(session, l10n)) ...[
              const SizedBox(width: 12),
              chip,
            ],
          ],
        ),
      ),
    );
  }

  /// Dev-trace chips for every currently active News/Hype event — elapsed
  /// and remaining ticks, converted to real time via [tickIntervalSeconds].
  /// Replaces the old `devNextEvent`/`devNextEventDays` fields, which were
  /// declared and displayed (bottom_metrics_bar.dart's "Next Event" column)
  /// but never actually assigned anywhere in the engine — always empty.
  List<Widget> _activeEventChips(
    StressTestSession session,
    AppLocalizations l10n,
  ) {
    final monoStyle = GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
    final chips = <Widget>[];

    final news = session.activeNewsEvent;
    if (news != null) {
      chips.add(
        _devChip(
          l10n.assetsScreenDevNewsLabel(news.symbol),
          '${news.currentTick}/${news.rampDurationTicks} '
              '(${_remainingLabel(news.currentTick, news.rampDurationTicks, l10n)})',
          news.isPositive ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
          monoStyle,
        ),
      );
    }
    for (final hype in session.activeHypeEvents) {
      chips.add(
        _devChip(
          l10n.assetsScreenDevHypeLabel(hype.sector.label),
          '${hype.currentTick}/${hype.rampDurationTicks} '
              '(${_remainingLabel(hype.currentTick, hype.rampDurationTicks, l10n)})',
          hype.isPositive ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
          monoStyle,
        ),
      );
    }
    return chips;
  }

  String _remainingLabel(
    int currentTick,
    int rampDurationTicks,
    AppLocalizations l10n,
  ) {
    final ticksLeft = (rampDurationTicks - currentTick).clamp(
      0,
      rampDurationTicks,
    );
    final secondsLeft = ticksLeft * tickIntervalSeconds;
    final hours = secondsLeft ~/ 3600;
    final minutes = (secondsLeft % 3600) ~/ 60;
    if (hours > 0) return l10n.assetsScreenDevTimeLeftHm(hours, minutes);
    if (minutes > 0) return l10n.assetsScreenDevTimeLeftM(minutes);
    return l10n.assetsScreenDevTimeEnding;
  }

  Widget _devChip(String label, String value, Color accent, TextStyle mono) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: mono.copyWith(
            color: accent.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 0.8,
          ),
        ),
        Text(value, style: mono.copyWith(color: accent)),
      ],
    );
  }

  Color _tempColor(double temp) {
    if (temp >= 60) return const Color(0xFFEF5350); // Euphoria → red
    if (temp >= 30) return const Color(0xFFFFA726); // Greed → orange
    if (temp >= 10) return const Color(0xFF66BB6A); // Optimism → green
    if (temp > -10) return const Color(0xFFB0BEC5); // Neutral → grey
    if (temp > -30) return const Color(0xFF42A5F5); // Anxiety → blue
    if (temp > -60) return const Color(0xFF7E57C2); // Fear → purple
    return const Color(0xFFEF5350); // Panic → red
  }

  Widget _buildBalanceHeader({
    required double totalValue,
    required double unrealizedPnl,
    required double pnlPercent,
    required bool isPositive,
    required double startCash,
    required AppLocalizations l10n,
    required AppPalette palette,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOTAL VALUE
          Text(
            l10n.assetsScreenTotalValueLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: palette.accentPrimary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          // Главная сумма — жирный Serif
          themedPriceText(
            formatUsd(totalValue),
            palette,
            GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
            fallbackColor: ThemeV2.textPrimary,
          ),
          const SizedBox(height: 8),
          // Unrealized P&L
          Row(
            children: [
              Text(
                l10n.portfolioUnrealizedPnl,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: palette.textBody,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${formatUsdSigned(unrealizedPnl)} '
                '(${isPositive ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? ThemeV2.success : ThemeV2.loss,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Start cash
          Row(
            children: [
              Text(
                l10n.assetsScreenStartCashLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: palette.textBody,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              themedPriceText(
                formatUsd(startCash),
                palette,
                GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                fallbackColor: ThemeV2.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, AppPalette palette) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        border: Border.all(color: palette.textBody.withValues(alpha: 0.3)),
        color: palette.card,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
        style: GoogleFonts.inter(fontSize: 14, color: palette.textHeader),
        decoration: InputDecoration(
          hintText: l10n.navSearch,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: palette.textBody),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: palette.textBody,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          fillColor: palette.card,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildSortToggle(AppLocalizations l10n, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _sortChip(l10n.assetsScreenSortValue, AssetSortMode.value, palette),
          const SizedBox(width: 16),
          _sortChip(
            l10n.assetsScreenSortMarketPrice,
            AssetSortMode.marketPrice,
            palette,
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, AssetSortMode mode, AppPalette palette) {
    final isActive = _sortMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _sortMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? palette.accentPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? palette.accentPrimary : palette.textBody,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
