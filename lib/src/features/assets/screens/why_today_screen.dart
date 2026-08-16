// ---------------------------------------------------------------------------
// Why Today Screen — admin-only engine diagnostics for one symbol's price.
// ---------------------------------------------------------------------------
// Reached only via the admin-gated "Why today?" button on Stress Test's
// Company Card (stock_why_today_card.dart) — this is a debugging tool for
// understanding the simulation, not a consumer-facing feature. Redesigned
// 2026-08-09: cut the old "AI explains your portfolio" framing (Guardian
// mood commentary, generated investor-advice bullets, decorative emoji) —
// all of that was written for a regular user, not an admin reading engine
// internals. devMarketTemperature (the old Guardian mood driver) was cut
// entirely: it's initialized to 0 and never recomputed anywhere in the
// engine, so it was permanently stuck and every Guardian message built on
// it was reading a dead value.
//
// Windows, each a flat olive-tinted panel (ThemeV2.primary @ 8% fill / 20%
// border — same treatment as the Admin Sandbox on the Profile screen):
//   1. Today's change — $ and % in two boxes.
//   2. This tick's factor bars (Market Trends/Sector/News/Sector Hype/Noise).
//   3. Whole-period factor bars — same 5 factors, averaged across every
//      tick in explanationLog[symbol] (weighted by each tick's own price
//      move so bigger swings count more), i.e. what's actually shaped this
//      position's price from its first tick to now.
//   4. Raw (unnormalized) drift values for the latest tick — the actual
//      computed magnitudes behind the normalized % bars above, previously
//      computed by the engine every tick but never surfaced anywhere.
//   5. News & Hype — live active event (if any) + a derived history of
//      past episodes. No event-log field exists in the model (see the
//      session-reconstruction risk noted above), so history here is
//      reconstructed from explanationLog's newsRaw/hypeRaw trace fields —
//      real timing/magnitude/direction, no headline text (not stored
//      anywhere past the event's own lifetime).
//   6. Market phase / epoch history for the whole session.
//   7. Ticks — unchanged from before, per explicit ask.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../stress_test/stress_test_models.dart';
import '../../../core/services/gics_sector_mapper.dart';
import '../../../shared/utils/currency_format.dart';

const _marketColor = FomoShieldTheme.factorMarket;
const _sectorColor = FomoShieldTheme.factorSector;
const _newsColor = FomoShieldTheme.factorNews;
const _hypeColor = FomoShieldTheme.factorHype;
const _noiseColor = FomoShieldTheme.factorNoise;

BoxDecoration get _olivePanel => BoxDecoration(
  color: ThemeV2.primary.withValues(alpha: 0.08),
  borderRadius: FomoShieldTheme.cardRadius,
  border: Border.all(color: ThemeV2.primary.withValues(alpha: 0.2)),
);

class WhyTodayScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String symbol;

  const WhyTodayScreen({
    super.key,
    required this.sessionId,
    required this.symbol,
  });

  @override
  ConsumerState<WhyTodayScreen> createState() => _WhyTodayScreenState();
}

class _WhyTodayScreenState extends ConsumerState<WhyTodayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: ThemeV2.animNormal,
    );
    Future.microtask(() => _staggerController.forward());
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  StressTestSession? get _session {
    return ref.read(stressTestSessionProvider(widget.sessionId));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    final session = _session;
    if (session == null) return _emptyScreen('Session not found');

    final ticks = session.explanationLog[widget.symbol] ?? [];
    final latest = ticks.isNotEmpty ? ticks.last : null;
    // Whole-period source of truth — folds every tick as it happens, so it
    // isn't limited to explanationLog's capped last-50 window. Falls back
    // to deriving from the capped log only if nothing's accumulated yet
    // (e.g. right after this feature shipped, before any new ticks landed).
    final diagnostics = ref
        .read(stressTestProvider.notifier)
        .whyDiagnosticsFor(widget.sessionId, widget.symbol);

    final currentPrice =
        session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        0;
    final basePrice = session.basePrices[widget.symbol] ?? currentPrice;
    final priceChange = currentPrice - basePrice;
    final changePercent = basePrice > 0 ? (priceChange / basePrice) * 100 : 0.0;
    final isPositive = changePercent >= 0;

    final displayTicks = ticks.length > 20
        ? ticks.sublist(ticks.length - 20)
        : ticks;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: ticks.isEmpty
            ? _buildEmptyState()
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _window(
                      index: 0,
                      title: "TODAY'S CHANGE",
                      child: Row(
                        children: [
                          Expanded(
                            child: _changeBox(
                              label: 'DOLLARS',
                              value: formatUsdSigned(priceChange),
                              color: isPositive
                                  ? ThemeV2.success
                                  : ThemeV2.loss,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _changeBox(
                              label: 'PERCENT',
                              value:
                                  '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                              color: isPositive
                                  ? ThemeV2.success
                                  : ThemeV2.loss,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (latest != null)
                      _window(
                        index: 1,
                        title: 'THIS TICK — FACTOR BREAKDOWN',
                        child: _factorBars(latest.contributions),
                      ),
                    if (ticks.isNotEmpty)
                      _window(
                        index: 2,
                        title: 'WHOLE PERIOD — FACTOR BREAKDOWN',
                        subtitle:
                            'Weighted by each tick\'s own price move — '
                            '${diagnostics?.tickCount ?? ticks.length} ticks since first purchase'
                            '${diagnostics == null ? ' (recent only — no cache yet)' : ''}.',
                        child: _factorBars(
                          diagnostics?.averaged ??
                              _aggregateContributions(ticks),
                        ),
                      ),
                    if (latest != null)
                      _window(
                        index: 3,
                        title: 'RAW DRIFT VALUES (LATEST TICK)',
                        subtitle:
                            'Unnormalized — before the 5 factors above are scaled to sum to 100%.',
                        child: Column(
                          children: [
                            _rawRow('Market drift', latest.marketDriftRaw),
                            _rawRow('Sector drift', latest.sectorDriftRaw),
                            _rawRow('Noise', latest.noiseRaw),
                            _rawRow('News', latest.newsRaw),
                            _rawRow('Hype', latest.hypeRaw),
                          ],
                        ),
                      ),
                    _window(
                      index: 4,
                      title: 'NEWS & SECTOR HYPE',
                      child: _newsAndHypeSection(session, ticks, diagnostics),
                    ),
                    if (session.epochHistory.isNotEmpty)
                      _window(
                        index: 5,
                        title: 'MARKET PHASE / EPOCHS',
                        child: Column(
                          children: [
                            for (final e in session.epochHistory.reversed)
                              _epochRow(e),
                          ],
                        ),
                      ),
                    if (displayTicks.isNotEmpty) _buildTimeline(displayTicks),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: true,
        title: Text(
          '${widget.symbol} DIAGNOSTICS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
    );
  }

  // ─── Window shell ────────────────────────────────────────────────────
  Widget _window({
    required int index,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return _FadeSlide(
      index: index,
      controller: _staggerController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: _olivePanel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: FomoShieldTheme.cardTitle()),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: ThemeV2.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Divider(height: 1, color: ThemeV2.primary.withValues(alpha: 0.15)),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _changeBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: ThemeV2.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: ThemeV2.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: interNums(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Factor bars (shared by "this tick" and "whole period") ──────────
  PriceContribution _aggregateContributions(List<TickExplanation> ticks) {
    double wMarket = 0,
        wSector = 0,
        wNews = 0,
        wHype = 0,
        wNoise = 0,
        totalW = 0;
    for (final t in ticks) {
      final w = t.changePercent.abs();
      final effectiveW = w > 0 ? w : 0.0001;
      wMarket += t.contributions.marketPct * effectiveW;
      wSector += t.contributions.sectorPct * effectiveW;
      wNews += t.contributions.newsPct * effectiveW;
      wHype += t.contributions.hypePct * effectiveW;
      wNoise += t.contributions.noisePct * effectiveW;
      totalW += effectiveW;
    }
    if (totalW <= 0) {
      return const PriceContribution(
        marketPct: 0,
        sectorPct: 0,
        newsPct: 0,
        noisePct: 0,
      );
    }
    return PriceContribution(
      marketPct: wMarket / totalW,
      sectorPct: wSector / totalW,
      newsPct: wNews / totalW,
      hypePct: wHype / totalW,
      noisePct: wNoise / totalW,
    );
  }

  Widget _factorBars(PriceContribution c) {
    return Column(
      children: [
        _factorBar('Market Trends', c.marketPct, _marketColor),
        _factorBar('Sector', c.sectorPct, _sectorColor),
        _factorBar('News', c.newsPct, _newsColor),
        _factorBar('Sector Hype', c.hypePct, _hypeColor),
        _factorBar('Noise', c.noisePct, _noiseColor),
      ],
    );
  }

  Widget _factorBar(String label, double percent, Color color) {
    final clamped = (percent / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeV2.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: clamped,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            child: Text(
              '${percent.round()}%',
              textAlign: TextAlign.right,
              style: interNums(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Raw drift values ──────────────────────────────────────────────
  Widget _rawRow(String label, double? raw) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ThemeV2.caption),
          Text(
            raw == null
                ? '—'
                : '${raw >= 0 ? '+' : ''}${(raw * 100).toStringAsFixed(3)}%',
            style: ThemeV2.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  // ─── News & Hype: live state + whole-period history from the Why
  // Diagnostics accumulator (folds every tick — see stress_test_why_
  // diagnostics.dart — so this survives past explanationLog's 50-tick
  // cap). Empty until the accumulator has folded at least one tick.
  Widget _newsAndHypeSection(
    StressTestSession session,
    List<TickExplanation> ticks,
    WhyDiagnosticsAccumulator? diagnostics,
  ) {
    final newsActive = session.activeNewsEvent?.symbol == widget.symbol
        ? session.activeNewsEvent
        : null;
    final mySector = resolveGicsSector(widget.symbol);
    final hypeActive = mySector == null
        ? null
        : session.activeHypeEvents
              .where((e) => e.sector == mySector)
              .firstOrNull;

    final newsEpisodes =
        diagnostics?.newsEpisodes ?? const <WhyDiagnosticsEpisode>[];
    final hypeEpisodes =
        diagnostics?.hypeEpisodes ?? const <WhyDiagnosticsEpisode>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (newsActive != null) ...[
          _liveEventRow(
            'News — LIVE: ${newsActive.headline}',
            newsActive.isPositive,
            '${newsActive.isPositive ? '+' : ''}${(newsActive.targetAmplitude * 100).toStringAsFixed(1)}% target',
            _formatRemaining(
              newsActive.currentTick,
              newsActive.rampDurationTicks,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (hypeActive != null) ...[
          _liveEventRow(
            'Sector Hype — LIVE',
            hypeActive.isPositive,
            '${hypeActive.isPositive ? '+' : ''}${(hypeActive.targetAmplitude * 100).toStringAsFixed(1)}% sector target',
            _formatRemaining(
              hypeActive.currentTick,
              hypeActive.rampDurationTicks,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          'NEWS HISTORY (${newsEpisodes.length})',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: ThemeV2.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (newsEpisodes.isEmpty)
          Text('No News episodes yet.', style: ThemeV2.small)
        else
          for (final ep in newsEpisodes) _episodeRow(ep),
        const SizedBox(height: 14),
        Text(
          'SECTOR HYPE HISTORY (${hypeEpisodes.length})',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: ThemeV2.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (hypeEpisodes.isEmpty)
          Text('No Sector Hype episodes yet.', style: ThemeV2.small)
        else
          for (final ep in hypeEpisodes) _episodeRow(ep),
      ],
    );
  }

  Widget _liveEventRow(
    String label,
    bool isPositive,
    String detail,
    String countdown,
  ) {
    final color = isPositive ? ThemeV2.success : ThemeV2.loss;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
      ),
      child: Row(
        children: [
          Icon(
            isPositive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label — $detail',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          Text(
            countdown,
            style: ThemeV2.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// "≈2h 40m left" style label from ticks remaining on a ramping event.
  String _formatRemaining(int currentTick, int rampDurationTicks) {
    final ticksLeft = (rampDurationTicks - currentTick).clamp(
      0,
      rampDurationTicks,
    );
    final secondsLeft = ticksLeft * tickIntervalSeconds;
    final hours = secondsLeft ~/ 3600;
    final minutes = (secondsLeft % 3600) ~/ 60;
    if (hours > 0) return '≈${hours}h ${minutes}m left';
    if (minutes > 0) return '≈${minutes}m left';
    return 'wrapping up';
  }

  Widget _episodeRow(WhyDiagnosticsEpisode ep) {
    final color = ep.isUp ? ThemeV2.success : ThemeV2.loss;
    final epochLabel = ep.startEpoch == ep.endEpoch
        ? 'Epoch ${ep.startEpoch + 1}'
        : 'Epoch ${ep.startEpoch + 1}–${ep.endEpoch + 1}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            ep.isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              epochLabel,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          Text(
            '${ep.isUp ? '+' : ''}${ep.netPercent.toStringAsFixed(2)}%',
            style: interNums(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Market phase / epochs ────────────────────────────────────────
  Widget _epochRow(EpochRecord e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: e.isActive
                  ? ThemeV2.success
                  : ThemeV2.textSecondary.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Epoch ${e.index + 1} — ${e.scenario.name}',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ThemeV2.textPrimary,
              ),
            ),
          ),
          Text(
            e.isActive ? 'active' : _fmtDuration(e.duration),
            style: ThemeV2.small.copyWith(color: ThemeV2.textSecondary),
          ),
        ],
      ),
    );
  }

  String _fmtDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  // ─── Ticks — unchanged per explicit ask ──────────────────────────
  Widget _buildTimeline(List<TickExplanation> ticks) {
    final reversed = ticks.reversed.toList();

    return _FadeSlide(
      index: 6,
      controller: _staggerController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: ThemeV2.borderRadiusLarge,
          boxShadow: ThemeV2.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ticks', style: ThemeV2.section),
            const SizedBox(height: 16),
            for (var i = 0; i < reversed.length; i++)
              _buildTickCard(reversed[i], i),
          ],
        ),
      ),
    );
  }

  Widget _buildTickCard(TickExplanation tick, int index) {
    final change = tick.changePercent;
    final isUp = change > 0;
    final isFlat = change.abs() < 0.01;
    final color = isFlat
        ? ThemeV2.textSecondary
        : isUp
        ? ThemeV2.success
        : ThemeV2.loss;
    final arrow = isFlat ? '→' : (isUp ? '⬆' : '⬇');

    final epochNum = tick.epochIndex + 1;
    final timeLabel = 'Epoch $epochNum';

    return _StaggerItem(
      index: index,
      controller: _staggerController,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: ThemeV2.background,
          borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                timeLabel,
                style: ThemeV2.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                _tickEventDescription(tick),
                style: ThemeV2.caption.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  '$arrow ',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: ThemeV2.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _tickEventDescription(TickExplanation tick) {
    final c = tick.contributions;
    final entries = [
      ('Market Trends', c.marketPct),
      ('Sector', c.sectorPct),
      ('News', c.newsPct),
      ('Sector Hype', c.hypePct),
      ('Noise', c.noisePct),
    ];
    entries.sort((a, b) => b.$2.compareTo(a.$2));
    return '${entries.first.$1} moved by ${entries.first.$2.round()}%';
  }

  // ─── Empty states ─────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: ThemeV2.borderRadiusLarge,
          boxShadow: ThemeV2.cardShadow,
        ),
        child: Text(
          'No tick data yet for this position.',
          style: ThemeV2.body.copyWith(color: ThemeV2.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _emptyScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: Text(message, style: ThemeV2.body)),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Fade/stagger entrance helpers (unchanged from before the rework)
// ════════════════════════════════════════════════════════════════════════

class _FadeSlide extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _FadeSlide({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final begin = (0.1 * index).clamp(0.0, 0.6);
    final end = (begin + 0.2).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          ((controller.value - begin) / (end - begin)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _StaggerItem extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _StaggerItem({
    required this.index,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = 0.1 + (0.05 * index);
    final start = delay.clamp(0.0, 0.9);
    final end = (start + 0.2).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          ((controller.value - start) / (end - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
