// ---------------------------------------------------------------------------
// BottomMetricsBar — 5-column horizontal metrics strip
// ---------------------------------------------------------------------------
// Design Spec Part 6: dark bar with 5 columns separated by thin vertical
// dividers. Each column: icon + label + value.
// Columns: Fear Index, Fatigue, Recovery, Volatility, Next Event.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../core/theme/typography_helpers.dart';
import '../../core/services/gics_sector_mapper.dart';
import '../../features/stress_test/stress_test_models.dart';
import '../../features/stress_test/stress_test_engine.dart';

/// Data for the Bottom Metrics Bar.
class BottomMetricsData {
  final int fearIndex; // 0-100
  final double fatigue; // 0.0-1.0
  final double recoveryPercent; // 0.0-100.0
  final double volatilityMultiplier; // 0.5-5.0
  final String volatilityLabel;

  /// Label for the currently active News/Hype event, or "No event" when
  /// none is active. Replaces the old `devNextEvent`/`devNextEventDays`
  /// fields — those were declared and read here but never assigned
  /// anywhere in the engine, so this column always showed blank/0d.
  final String eventLabel;

  /// Remaining time on that event (already formatted, e.g. "1h 40m left"),
  /// or "—" when [hasActiveEvent] is false.
  final String eventRemaining;
  final bool hasActiveEvent;

  const BottomMetricsData({
    required this.fearIndex,
    required this.fatigue,
    required this.recoveryPercent,
    required this.volatilityMultiplier,
    required this.volatilityLabel,
    required this.eventLabel,
    required this.eventRemaining,
    required this.hasActiveEvent,
  });

  factory BottomMetricsData.fromSession(StressTestSession session) {
    String label = 'No event';
    String remaining = '—';
    bool active = false;

    final news = session.activeNewsEvent;
    final hype = session.activeHypeEvents.isNotEmpty
        ? session.activeHypeEvents.first
        : null;
    if (news != null) {
      label = '${news.symbol} NEWS';
      remaining = _remainingLabel(news.currentTick, news.rampDurationTicks);
      active = true;
    } else if (hype != null) {
      label = '${hype.sector.label} HYPE';
      remaining = _remainingLabel(hype.currentTick, hype.rampDurationTicks);
      active = true;
    }

    return BottomMetricsData(
      fearIndex: session.devFearIndex,
      fatigue: session.devFatigue,
      recoveryPercent: session.devRecoveryProgress,
      volatilityMultiplier: session.devVolatilityMultiplier,
      volatilityLabel: session.devVolatilityLabel,  // 'Low', 'Normal', 'Elevated', 'High', 'Extreme'
      eventLabel: label,
      eventRemaining: remaining,
      hasActiveEvent: active,
    );
  }

  /// Compact form for this bar's narrow columns — e.g. "1h40m", "42m",
  /// "now". Longer "Xh Ym left" phrasing lives in why_today_screen.dart's
  /// roomier event banners.
  static String _remainingLabel(int currentTick, int rampDurationTicks) {
    final ticksLeft = (rampDurationTicks - currentTick).clamp(
      0,
      rampDurationTicks,
    );
    final secondsLeft = ticksLeft * tickIntervalSeconds;
    final hours = secondsLeft ~/ 3600;
    final minutes = (secondsLeft % 3600) ~/ 60;
    if (hours > 0) return '${hours}h${minutes}m';
    if (minutes > 0) return '${minutes}m';
    return 'now';
  }
}

/// Horizontal metrics bar: 5 columns with icons and values.
class BottomMetricsBar extends StatelessWidget {
  final BottomMetricsData data;

  const BottomMetricsBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: FomoShieldTheme.darkCardDecoration(),
      child: Row(
        children: [
          Expanded(child: _buildMetricColumn(
            icon: Icons.speed_rounded,
            label: 'FEAR\nINDEX',
            value: '${data.fearIndex}',
            color: _fearIndexColor(data.fearIndex),
          )),
          _verticalDivider(),
          Expanded(child: _buildMetricColumn(
            icon: Icons.local_fire_department_rounded,
            label: 'FATIGUE',
            value: '${(data.fatigue * 100).round()}%',
            color: _fatigueColor(data.fatigue),
          )),
          _verticalDivider(),
          Expanded(child: _buildMetricColumn(
            icon: Icons.eco_rounded,
            label: 'RECOVERY',
            value: '${data.recoveryPercent.round()}%',
            color: _recoveryColor(data.recoveryPercent),
          )),
          _verticalDivider(),
          Expanded(child: _buildMetricColumn(
            icon: Icons.show_chart_rounded,
            label: data.volatilityLabel,
            value: '${data.volatilityMultiplier.toStringAsFixed(1)}x',
            color: _volatilityColor(data.volatilityMultiplier),
          )),
          _verticalDivider(),
          Expanded(child: _buildMetricColumn(
            icon: Icons.calendar_month_rounded,
            label: data.eventLabel,
            value: data.eventRemaining,
            color: _eventColor(data.hasActiveEvent),
          )),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 36,
      color: FomoShieldTheme.border.withValues(alpha: 0.3),
    );
  }

  Widget _buildMetricColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: interNums(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: FomoShieldTheme.text,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: FomoShieldTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// 5-tier contrarian color (Task 1.4).
  Color _fearIndexColor(int index) {
    if (index <= 20) return const Color(0xFF00C853); // Extreme Fear
    if (index <= 40) return const Color(0xFF69DB7C); // Fear
    if (index <= 60) return FomoShieldTheme.sideways;  // Neutral
    if (index <= 80) return const Color(0xFFE57373); // Greed
    return const Color(0xFFC62828); // Extreme Greed
  }

  Color _fatigueColor(double fatigue) {
    if (fatigue >= 0.7) return FomoShieldTheme.negative;
    if (fatigue >= 0.3) return FomoShieldTheme.sideways;
    return FomoShieldTheme.positive;
  }

  Color _recoveryColor(double percent) {
    if (percent >= 70) return FomoShieldTheme.positive;
    if (percent >= 30) return FomoShieldTheme.sideways;
    return FomoShieldTheme.textLight;
  }

  Color _volatilityColor(double mult) {
    if (mult >= 3.0) return FomoShieldTheme.negative;
    if (mult >= 1.8) return FomoShieldTheme.sideways;
    return FomoShieldTheme.positive;
  }

  Color _eventColor(bool hasActiveEvent) {
    return hasActiveEvent
        ? FomoShieldTheme.sideways
        : FomoShieldTheme.textLight;
  }
}
