import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Market Phases Screen — full list of all 11 Market Clock windows (9 daily
// phases in chronological order, then Weekend/Holiday and Early Close),
// each rendered as its own Home-style widget card. Reached via the chevron
// next to the MARKET PHASE widget's title on the Market Clock screen.
// ---------------------------------------------------------------------------

class MarketPhasesScreen extends StatefulWidget {
  const MarketPhasesScreen({super.key});

  @override
  State<MarketPhasesScreen> createState() => _MarketPhasesScreenState();
}

class _MarketPhasesScreenState extends State<MarketPhasesScreen> {
  late Timer _timer;
  late String _activeWindowId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final l10n = AppLocalizations.of(context)!;
    _activeWindowId = resolveMarketClockState(l10n, nowInNewYork()).window.id;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final l10n = AppLocalizations.of(context)!;
      final id = resolveMarketClockState(l10n, nowInNewYork()).window.id;
      if (id != _activeWindowId) setState(() => _activeWindowId = id);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allWindows = [
      ...marketWindowsFor(l10n),
      weekendClosedWindowFor(l10n),
      marketHolidayWindowFor(l10n),
      earlyCloseWindowFor(l10n),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          l10n.marketPhasesScreenTitle,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              for (int i = 0; i < allWindows.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _PhaseListCard(
                  window: allWindows[i],
                  isActive: allWindows[i].id == _activeWindowId,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One phase card — sized like the compact MARKET PHASE widget. Title bar IS
// the phase's own name (not a generic "MARKET PHASE" repeated 11 times).
// ---------------------------------------------------------------------------

class _PhaseListCard extends StatelessWidget {
  final MarketWindow window;
  final bool isActive;
  const _PhaseListCard({required this.window, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: FomoShieldTheme.card,
        borderRadius: FomoShieldTheme.cardRadius,
        border: Border.all(
          color: isActive ? ThemeV2.primary : FomoShieldTheme.border,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              children: [
                Text(window.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    window.shortHeadline,
                    style: FomoShieldTheme.cardTitle(),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeV2.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.marketPhasesScreenNowBadge,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  window.timeRangeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _ClampedBody(text: window.whatHappens, windowId: window.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Clamps [text] to 4 lines; only when it actually overflows does a "More"
/// link appear, taking the user to the existing full period-detail screen.
class _ClampedBody extends StatelessWidget {
  final String text;
  final String windowId;
  const _ClampedBody({required this.text, required this.windowId});

  static const int _maxLines = 4;
  static final TextStyle _bodyStyle = GoogleFonts.inter(
    fontSize: 13,
    color: ThemeV2.textSecondary,
    height: 1.4,
  );

  bool _overflows(double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: _bodyStyle),
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final overflow = _overflows(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
              style: _bodyStyle,
            ),
            if (overflow) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      context.push('/market-clock/period/$windowId'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.marketPhasesScreenMoreLink,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ThemeV2.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
