// ---------------------------------------------------------------------------
// Why Today Screen — Explainable AI Experience (Design Bible Chapter 4)
// ---------------------------------------------------------------------------
// Full-screen breakdown of what influenced today's price movement.
//
// Structure (Steps 203):
//   Header -> Summary -> Contribution Breakdown -> Timeline -> Guardian -> Advice -> Technical Details
//
// Data sources (Step 202 — DO NOT MODIFY):
//   - TickExplanation.explanationLog[symbol]  — per-tick explanations
//   - PriceContribution                        — 5-factor decomposition
//   - StressTestSession.devMarketTemperature   — Guardian mood selector
//   - StressTestSession.devMarketPhase         — market context
//
// Color mapping (Steps 267–271):
//   Market -> Blue, Sector -> Green, Company -> Orange, News -> Purple, Noise -> Grey
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../stress_test/stress_test_models.dart';
import '../../../shared/widgets/guardian/guardian_data.dart';
import '../../../core/services/gics_sector_mapper.dart';

// ── Factor color constants (Steps 267–271) ───────────────────────────────
const _marketColor = Color(0xFF6FA7D6);
const _sectorColor = Color(0xFF77C88A);
const _companyColor = Color(0xFFF0B04F);
const _newsColor = Color(0xFF8A76D6);
const _noiseColor = Color(0xFFBFB9AE);

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
  bool _technicalExpanded = false;
  bool _guardianExpanded = false;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: ThemeV2.animNormal,
    );
    // Trigger entrance animation after first frame
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

    final tickLog = session.explanationLog[widget.symbol];
    final ticks = tickLog ?? [];
    final latest = ticks.isNotEmpty ? ticks.last : null;

    // Calculate overall change (Steps 209–211)
    final currentPrice =
        session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        0;
    final basePrice = session.basePrices[widget.symbol] ?? currentPrice;
    final changePercent = basePrice > 0
        ? ((currentPrice - basePrice) / basePrice) * 100
        : 0.0;
    final isPositive = changePercent >= 0;

    // Max display ticks for timeline (to avoid overwhelming UI)
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
                    // 1. Header (Steps 204–207)
                    _buildHeader(),

                    // News micro-scenario headline (news_event.dart) —
                    // only shown when THIS symbol is the one currently
                    // targeted by an active News event.
                    if (session.activeNewsEvent?.symbol == widget.symbol)
                      _buildNewsHeadline(session.activeNewsEvent!),

                    // Hype micro-scenario banner (hype/hype_event.dart) —
                    // only shown when THIS symbol's GICS sector currently
                    // has an active sector-wide Hype event.
                    ..._buildHypeBanners(session),

                    // 2. Summary Card (Steps 208–213)
                    _buildSummaryCard(changePercent, isPositive, latest),

                    // 3. Contribution Breakdown (Steps 214–227)
                    if (latest != null) _buildContributionBreakdown(latest),

                    // 4. Visual Hierarchy indicator (Steps 228–230)
                    // ── applied inside _buildContributionBreakdown ──

                    // 5. Timeline (Steps 231–240)
                    if (displayTicks.isNotEmpty) _buildTimeline(displayTicks),

                    // 6. Guardian Analysis (Steps 241–250)
                    _buildGuardianAnalysis(session, isPositive),

                    // 7. Investor Advice (Steps 251–256)
                    if (latest != null)
                      _buildInvestorAdvice(latest, isPositive),

                    // 8. Technical Details Accordion (Steps 257–261)
                    if (latest != null) _buildTechnicalDetails(latest, session),

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
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 22),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 22,
              color: ThemeV2.textPrimary,
            ),
            onPressed: () => context.pop(),
            splashRadius: 22,
          ),
        ),
        title: Text(
          widget.symbol,
          style: ThemeV2.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 56)], // balance with leading
      ),
    );
  }

  // ─── Header (Steps 204–207) ──────────────────────────────────────────
  Widget _buildHeader() {
    return _FadeSlide(
      index: 0,
      controller: _staggerController,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Large lightbulb icon (Step 205)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ThemeV2.primaryBg,
                borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 28,
                color: ThemeV2.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why did the price change today?',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'AI explanation based on current simulation.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── News headline banner (news_event.dart) ──────────────────────────
  Widget _buildNewsHeadline(NewsEvent event) {
    final color = event.isPositive ? ThemeV2.success : ThemeV2.loss;
    return _FadeSlide(
      index: 1,
      controller: _staggerController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              event.isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.headline,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.isPositive ? '+' : ''}'
                    '${(event.targetAmplitude * 100).toStringAsFixed(1)}% target impact on ${widget.symbol}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hype banner (hype/hype_event.dart) ──────────────────────────────
  List<Widget> _buildHypeBanners(StressTestSession session) {
    final mySector = resolveGicsSector(widget.symbol);
    if (mySector == null) return const [];
    for (final event in session.activeHypeEvents) {
      if (event.sector == mySector) return [_buildHypeBanner(event)];
    }
    return const [];
  }

  Widget _buildHypeBanner(HypeEvent event) {
    final color = event.isPositive ? ThemeV2.success : ThemeV2.loss;
    return _FadeSlide(
      index: 1,
      controller: _staggerController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              event.isPositive
                  ? Icons.local_fire_department_rounded
                  : Icons.trending_down_rounded,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hype: ${event.sector.label} '
                    '${event.isPositive ? 'rallying' : 'declining'}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${event.isPositive ? '+' : ''}'
                    '${(event.targetAmplitude * 100).toStringAsFixed(1)}% sector-wide target impact',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Summary Card (Steps 208–213) ────────────────────────────────────
  Widget _buildSummaryCard(
    double changePercent,
    bool isPositive,
    TickExplanation? latest,
  ) {
    final color = isPositive ? ThemeV2.success : ThemeV2.loss;

    return _FadeSlide(
      index: 1,
      controller: _staggerController,
      child: Container(
        height: 140,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: ThemeV2.borderRadiusLarge,
          boxShadow: ThemeV2.cardShadow,
        ),
        child: Row(
          children: [
            // Left color indicator (Steps 212–213)
            Container(
              width: 5,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ThemeV2.radiusLarge),
                  bottomLeft: Radius.circular(ThemeV2.radiusLarge),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large percentage (Step 209)
                    Text(
                      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                      style: ThemeV2.displayXL.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    // "Today's Movement" label (Step 210)
                    Text(
                      "Today's Movement",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // One-sentence explanation from engine (Step 211)
                    Text(
                      _buildSummarySentence(latest, isPositive),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: ThemeV2.textSecondary.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSummarySentence(TickExplanation? latest, bool isPositive) {
    if (latest == null) {
      return isPositive
          ? 'Market sentiment pushed prices higher today.'
          : 'Market pressure weighed on the asset today.';
    }
    // Use existing engine data — find dominant factor
    final c = latest.contributions;
    final entries = [
      ('Market', c.marketPct),
      ('Sector', c.sectorPct),
      ('Company', c.companyPct),
      ('News', c.newsPct),
      ('Noise', c.noisePct),
    ];
    entries.sort((a, b) => b.$2.compareTo(a.$2));
    final top = entries.first;

    final direction = isPositive ? 'pushed' : 'weighed on';
    return '${top.$1} was the dominant factor that $direction '
        '${widget.symbol} today. '
        '${_factorSentence(top.$1, isPositive)}';
  }

  String _factorSentence(String factor, bool isPositive) {
    return switch (factor) {
      'Market' =>
        isPositive
            ? 'Broad optimism lifted all assets.'
            : 'Macro concerns dragged the market.',
      'Sector' =>
        isPositive
            ? 'Sector tailwinds boosted performance.'
            : 'Sector rotation created headwinds.',
      'Company' =>
        isPositive
            ? 'Company-specific developments drove gains.'
            : 'Company headwinds pressured the stock.',
      'News' =>
        isPositive
            ? 'Positive news flow supported prices.'
            : 'Negative headlines affected sentiment.',
      'Noise' => 'Short-term volatility had no clear driver.',
      _ => '',
    };
  }

  // ─── Contribution Breakdown (Steps 214–227) ──────────────────────────
  Widget _buildContributionBreakdown(TickExplanation latest) {
    final c = latest.contributions;
    final factors = <_WhyFactor>[
      _WhyFactor(
        'Market',
        '🌍',
        c.marketPct,
        _marketColor,
        'Macro-economic forces affecting all stocks.',
      ),
      _WhyFactor(
        'Sector',
        '🏭',
        c.sectorPct,
        _sectorColor,
        'Industry-specific trends and rotation.',
      ),
      _WhyFactor(
        'Company',
        '🏢',
        c.companyPct,
        _companyColor,
        'Company-specific events and fundamentals.',
      ),
      _WhyFactor(
        'News',
        '📰',
        c.newsPct,
        _newsColor,
        'News flow, earnings, and external events.',
      ),
      _WhyFactor(
        'Noise',
        '🎲',
        c.noisePct,
        _noiseColor,
        'Random short-term price fluctuations.',
      ),
    ];

    // Find dominant factor (Steps 228–230)
    factors.sort((a, b) => b.percent.compareTo(a.percent));
    final dominant = factors.first;

    return _FadeSlide(
      index: 2,
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
            // Section title (Step 214)
            Text("What influenced today's movement", style: ThemeV2.section),
            const SizedBox(height: 20),
            // Factor rows (Steps 215–227)
            for (final f in factors) _buildFactorRow(f, f == dominant),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(_WhyFactor factor, bool isDominant) {
    final fraction = (factor.percent / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        height: 72, // ~60px + subtitle (Step 222 + explanation)
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: isDominant
            ? BoxDecoration(
                color: ThemeV2.primaryBg.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
                border: Border(
                  left: BorderSide(color: ThemeV2.success, width: 3),
                ),
              )
            : null,
        child: Row(
          children: [
            // Icon (Steps 217–221)
            Text(factor.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            // Title + subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factor.label,
                    style: ThemeV2.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    factor.explanation,
                    style: ThemeV2.small,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Percentage + Bar
            SizedBox(
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${factor.percent.round()}%',
                    style: ThemeV2.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDominant
                          ? ThemeV2.textPrimary
                          : ThemeV2.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Animated bar (Steps 223–225)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: fraction),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: factor.color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(factor.color),
                          borderRadius: BorderRadius.circular(5),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Timeline (Steps 231–240) ────────────────────────────────────────
  Widget _buildTimeline(List<TickExplanation> ticks) {
    // Reverse: newest first
    final reversed = ticks.reversed.toList();

    return _FadeSlide(
      index: 3,
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
            // Section title (Step 231)
            Text('How the day evolved', style: ThemeV2.section),
            const SizedBox(height: 16),
            // Tick cards (Steps 232–240)
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

    // Compute approximate time from epoch index
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
            // Left: time (Step 235)
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
            // Center: brief event (Step 236)
            Expanded(
              child: Text(
                _tickEventDescription(tick),
                style: ThemeV2.caption.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Right: price change (Steps 237–240)
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
      ('Market', c.marketPct),
      ('Sector', c.sectorPct),
      ('Company', c.companyPct),
      ('News', c.newsPct),
      ('Noise', c.noisePct),
    ];
    entries.sort((a, b) => b.$2.compareTo(a.$2));
    return '${entries.first.$1} moved by ${entries.first.$2.round()}%';
  }

  // ─── Guardian Analysis (Steps 241–250) ───────────────────────────────
  Widget _buildGuardianAnalysis(StressTestSession session, bool isPositive) {
    final temperature = session.devMarketTemperature;
    final state = _guardianStateFromTemperature(temperature);
    final config = GuardianStateConfig.of(state);
    final message = GuardianMessages.forTemperature(temperature, state);

    final hasWarning = temperature < -20 || temperature > 70;
    final isGood = !hasWarning && isPositive;

    return _FadeSlide(
      index: 4,
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
            // Title (Step 245)
            Row(
              children: [
                Text('Guardian Analysis', style: ThemeV2.section),
                const Spacer(),
                if (isGood)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: ThemeV2.success,
                  )
                else if (hasWarning)
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: ThemeV2.loss,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar (Step 243) — 56px
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        config.shieldColor,
                        config.shieldColor.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Advice Bubble (Step 244)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: ThemeV2.body.copyWith(
                          height: 1.45,
                          color: ThemeV2.textPrimary,
                        ),
                        maxLines: _guardianExpanded ? 20 : 4,
                        overflow: _guardianExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (message.length > 200) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => setState(
                            () => _guardianExpanded = !_guardianExpanded,
                          ),
                          child: Text(
                            _guardianExpanded ? 'Show Less' : 'Show More',
                            style: ThemeV2.small.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeV2.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GuardianState _guardianStateFromTemperature(double temp) {
    if (temp >= 60) return GuardianState.bull;
    if (temp >= 20) return GuardianState.sideways;
    if (temp >= -20) return GuardianState.sideways;
    if (temp >= -50) return GuardianState.bear;
    if (temp >= -70) return GuardianState.volatility;
    return GuardianState.crash;
  }

  // ─── Investor Advice (Steps 251–256) ─────────────────────────────────
  Widget _buildInvestorAdvice(TickExplanation latest, bool isPositive) {
    final bullets = _buildAdviceBullets(latest, isPositive);

    return _FadeSlide(
      index: 5,
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
            // Title with icon (Steps 252, 254)
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'What should a long-term investor notice?',
                    style: ThemeV2.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bullet points (Steps 255–256)
            for (final bullet in bullets) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(
                        color: ThemeV2.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bullet,
                        style: ThemeV2.body.copyWith(
                          height: 1.45,
                          color: ThemeV2.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _buildAdviceBullets(TickExplanation latest, bool isPositive) {
    final c = latest.contributions;
    final bullets = <String>[];

    // Dominant factor insight
    final entries = [
      ('Market', c.marketPct),
      ('Sector', c.sectorPct),
      ('Company', c.companyPct),
      ('News', c.newsPct),
      ('Noise', c.noisePct),
    ];
    entries.sort((a, b) => b.$2.compareTo(a.$2));
    final top = entries.first;

    if (top.$2 >= 35) {
      bullets.add(
        'Today\'s movement was driven primarily by ${top.$1.toLowerCase()} '
        'forces (${top.$2.round()}%). Single-factor moves often revert — '
        'avoid overreacting.',
      );
    } else {
      bullets.add(
        'Today\'s change came from multiple balanced factors. '
        'This is normal market behavior — no single narrative dominates.',
      );
    }

    // Market phase insight
    final phase = latest.marketPhase;
    if (phase.contains('bull')) {
      bullets.add(
        'The market is in an uptrend. '
        'Focus on position sizing — avoid chasing momentum.',
      );
    } else if (phase.contains('bear') || phase.contains('crash')) {
      bullets.add(
        'The market is under pressure. '
        'Quality assets often recover — this is when patience matters most.',
      );
    } else if (phase.contains('volatil')) {
      bullets.add(
        'High volatility means wider price swings. '
        'Consider smaller position sizes and wider stop-loss levels.',
      );
    } else {
      bullets.add(
        'Markets are range-bound. '
        'Sideways movement tests discipline — stick to your plan.',
      );
    }

    // Percentage context
    bullets.add(
      'A ${latest.changePercent.abs().toStringAsFixed(1)}% change is '
      '${latest.changePercent.abs() > 3 ? 'notable — review your thesis, not your emotions' : 'within normal daily range — no action needed'}.',
    );

    // Noise reminder
    if (c.noisePct > 15) {
      bullets.add(
        'Noise accounted for ${c.noisePct.round()}% of today\'s movement — '
        'most of this will be irrelevant by next week.',
      );
    } else {
      bullets.add(
        'The signal-to-noise ratio today is healthy. '
        'Focus on the long-term trend, not intraday fluctuations.',
      );
    }

    return bullets.take(5).toList();
  }

  // ─── Technical Details Accordion (Steps 257–261) ─────────────────────
  Widget _buildTechnicalDetails(
    TickExplanation latest,
    StressTestSession session,
  ) {
    return _FadeSlide(
      index: 6,
      controller: _staggerController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: ThemeV2.borderRadiusLarge,
          boxShadow: ThemeV2.cardShadow,
        ),
        child: Column(
          children: [
            // Accordion header (Steps 257–259)
            InkWell(
              onTap: () =>
                  setState(() => _technicalExpanded = !_technicalExpanded),
              borderRadius: BorderRadius.circular(ThemeV2.radiusLarge),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Technical Details',
                      style: ThemeV2.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeV2.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _technicalExpanded ? 0.5 : 0,
                      duration: ThemeV2.animNormal,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: ThemeV2.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content (Steps 260–261)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Divider(height: 1, color: ThemeV2.divider),
                    const SizedBox(height: 16),
                    _techRow(
                      'Market %',
                      '${latest.contributions.marketPct.round()}%',
                      _marketColor,
                    ),
                    const SizedBox(height: 10),
                    _techRow(
                      'Sector %',
                      '${latest.contributions.sectorPct.round()}%',
                      _sectorColor,
                    ),
                    const SizedBox(height: 10),
                    _techRow(
                      'Company %',
                      '${latest.contributions.companyPct.round()}%',
                      _companyColor,
                    ),
                    const SizedBox(height: 10),
                    _techRow(
                      'News %',
                      '${latest.contributions.newsPct.round()}%',
                      _newsColor,
                    ),
                    const SizedBox(height: 10),
                    _techRow(
                      'Noise %',
                      '${latest.contributions.noisePct.round()}%',
                      _noiseColor,
                    ),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: ThemeV2.divider),
                    const SizedBox(height: 16),
                    _techRowMeta('Epoch', '${latest.epochIndex + 1}'),
                    const SizedBox(height: 8),
                    _techRowMeta('Phase', latest.marketPhase),
                    const SizedBox(height: 8),
                    _techRowMeta(
                      'Temperature',
                      '${session.devMarketTemperature.toStringAsFixed(1)}°',
                    ),
                    const SizedBox(height: 8),
                    _techRowMeta(
                      'Scenario',
                      latest.scenario.isNotEmpty ? latest.scenario : 'N/A',
                    ),
                  ],
                ),
              ),
              crossFadeState: _technicalExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: ThemeV2.animNormal,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _techRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: ThemeV2.caption)),
        Text(
          value,
          style: ThemeV2.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: ThemeV2.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _techRowMeta(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: ThemeV2.caption)),
        Text(
          value,
          style: ThemeV2.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: ThemeV2.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Empty State (Steps 272–274) ─────────────────────────────────────
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'No explanation available for this session.',
              style: ThemeV2.body.copyWith(color: ThemeV2.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
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

// ════════════════════════════════════════════════════════════════════════════
// MICRO-ANIMATION HELPERS (Steps 262–266)
// ════════════════════════════════════════════════════════════════════════════

/// Fade + Slide entrance animation for card sections (Steps 262, 264).
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

/// Staggered timeline item — appears one by one (Steps 265–266).
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

/// Factor data holder (Steps 214–227).
class _WhyFactor {
  final String label;
  final String emoji;
  final double percent;
  final Color color;
  final String explanation;

  const _WhyFactor(
    this.label,
    this.emoji,
    this.percent,
    this.color,
    this.explanation,
  );
}
