// ---------------------------------------------------------------------------
// Market Timeline — compact vertical epoch timeline (Bible Part 7)
// ---------------------------------------------------------------------------
// Shows a scrollable vertical timeline of market epochs centered on the
// current epoch. Each item: colored phase dot + label + epoch #.
// Past epochs are dimmed, current is prominent, upcoming are lighter.
//
// Design Bible Part 7: .timelineItem { vertical line ::after, dots ::before }
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../features/stress_test/stress_test_models.dart';

/// Compact vertical timeline of market epochs.
///
/// Shows epochs in reverse order (active/current at top, oldest at bottom).
/// Default max visible = 5. After that, a "MORE" button expands inline.
class MarketTimeline extends StatefulWidget {
  final List<EpochRecord> epochs;
  final int? currentEpochIndex;

  /// Progress of the active epoch (0.0–1.0).
  /// When provided, overrides [EpochRecord.progress] for the current epoch.
  final double? activeEpochProgress;

  /// How many epochs to show when collapsed. Default: 5.
  final int initialLimit;

  const MarketTimeline({
    super.key,
    required this.epochs,
    this.currentEpochIndex,
    this.activeEpochProgress,
    this.initialLimit = 5,
  });

  /// Find the current (active) epoch index: the one with endedAt == null.
  /// Falls back to the last epoch if all are closed.
  static int? findCurrentEpoch(List<EpochRecord> epochs) {
    if (epochs.isEmpty) return null;
    for (int i = 0; i < epochs.length; i++) {
      if (epochs[i].isActive) return i;
    }
    return epochs.length - 1;
  }

  @override
  State<MarketTimeline> createState() => _MarketTimelineState();
}

class _MarketTimelineState extends State<MarketTimeline> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.epochs.isEmpty) return const SizedBox.shrink();

    final currentIdx =
        widget.currentEpochIndex ??
        MarketTimeline.findCurrentEpoch(widget.epochs);
    if (currentIdx == null) return const SizedBox.shrink();

    // Build visible range: show up to initialLimit when collapsed, all when expanded.
    // Show in reverse order: current (top), then earlier epochs below.
    final totalCount = widget.epochs.length;
    final visibleCount = _expanded
        ? totalCount
        : widget.initialLimit.clamp(1, totalCount);

    // Build a reversed list: newest (highest index) first.
    // We want the current epoch at the top, so walk backwards from currentIdx.
    final reversed = <int>[];
    for (int i = currentIdx; i >= 0; i--) {
      reversed.add(i);
    }
    // If there are future epochs (uncommon but possible), append them after past ones.
    for (int i = currentIdx + 1; i < totalCount; i++) {
      reversed.add(i);
    }

    final shown = reversed.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              Text(
                'MARKET TIMELINE',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.primary,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                '${currentIdx + 1} of ${widget.epochs.length} epochs',
                style: interNums(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ThemeV2.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 20, endIndent: 20, color: ThemeV2.divider),
        // ── Epoch rows (no scroll, natural height) ──
        ...shown.asMap().entries.map((entry) {
          final i = entry.key;
          final absIndex = entry.value;
          final epoch = widget.epochs[absIndex];
          final isCurrent = absIndex == currentIdx;
          final isPast = absIndex < currentIdx;
          return _TimelineRow(
            epoch: epoch,
            epochNumber: absIndex + 1,
            isCurrent: isCurrent,
            isPast: isPast,
            isFirst: i == 0,
            isLast: i == shown.length - 1 && !_canExpand,
            epochProgress: isCurrent ? widget.activeEpochProgress : null,
          );
        }),
        // ── MORE button ──
        if (_canExpand)
          Center(
            child: TextButton(
              onPressed: () => setState(() => _expanded = true),
              child: Text(
                'MORE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool get _canExpand =>
      !_expanded && widget.epochs.length > widget.initialLimit;
}

/// A single row in the timeline: dot + connecting line + phase info.
class _TimelineRow extends StatelessWidget {
  final EpochRecord epoch;
  final int epochNumber;
  final bool isCurrent;
  final bool isPast;
  final bool isFirst;
  final bool isLast;

  /// Override for the progress bar value (0.0–1.0).
  /// When null, falls back to [EpochRecord.progress].
  final double? epochProgress;

  const _TimelineRow({
    required this.epoch,
    required this.epochNumber,
    required this.isCurrent,
    required this.isPast,
    required this.isFirst,
    required this.isLast,
    this.epochProgress,
  });

  Color get _phaseColor => FomoShieldTheme.phaseColor(epoch.scenario.name);

  String get _phaseLabel => epoch.scenario.name.toUpperCase();

  String get _description {
    // Short single-line description, e.g. "Broad growth" for bull
    return switch (epoch.scenario) {
      MarketScenario.bull => 'Broad market growth',
      MarketScenario.sideways => 'Calm, range-bound',
      MarketScenario.bear => 'Gradual decline',
      MarketScenario.volatility => 'Sharp swings, no trend',
      MarketScenario.blackSwan => 'Everything crashes',
      MarketScenario.crash => 'Heavy sector-wide drop',
      MarketScenario.recovery => 'Post-crisis rebound',
      MarketScenario.hype => 'Target sector spike',
      MarketScenario.speculation => 'Multi-directional volatility',
    };
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = isCurrent ? 14.0 : 10.0;
    final dotColor = _phaseColor;
    final opacity = isCurrent
        ? 1.0
        : isPast
        ? 0.45
        : 0.65;

    return SizedBox(
      height: 56,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + connecting line column ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top connecting line (hidden for first item)
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ThemeV2.divider.withValues(alpha: 0.4),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
                // Dot
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(color: dotColor, width: 2.5)
                        : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: dotColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
                // Bottom connecting line (hidden for last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: ThemeV2.divider.withValues(alpha: 0.4),
                    ),
                  )
                else
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Phase info ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: isCurrent ? 2.0 : 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _phaseLabel,
                        style: GoogleFonts.inter(
                          fontSize: isCurrent ? 14 : 12,
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: ThemeV2.textPrimary.withValues(
                            alpha: opacity,
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _phaseColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _phaseColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Ep. $epochNumber · $_description',
                    style: interNums(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: ThemeV2.textSecondary.withValues(alpha: opacity),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          // ── Progress bar for current epoch ──
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${((epochProgress ?? epoch.progress) * 100).toStringAsFixed(0)}%',
                    style: interNums(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _phaseColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 32,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: epochProgress ?? epoch.progress,
                        backgroundColor: ThemeV2.divider.withValues(
                          alpha: 0.25,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(_phaseColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
