import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_v2.dart';

// ---------------------------------------------------------------------------
// Stress Test "market status" flavor — purely cosmetic simulated session
// display (Pre-market/Open/After-hours/Closed by wall-clock hour), NOT
// tied to actual trading permission: trades_engine.dart's simulated market
// is always tradeable regardless of this label. Split out of the old
// monolithic stock_detail_screen.dart verbatim, no logic changes.
// ---------------------------------------------------------------------------

enum StressTestMarketPhase { preMarket, regular, postMarket, closed }

StressTestMarketPhase currentStressTestMarketPhase() {
  final now = DateTime.now();
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    return StressTestMarketPhase.closed;
  }
  final hour = now.hour;
  if (hour < 9 || hour >= 19) return StressTestMarketPhase.closed;
  if (hour < 11) return StressTestMarketPhase.preMarket;
  if (hour < 17) return StressTestMarketPhase.regular;
  return StressTestMarketPhase.postMarket;
}

({String label, String emoji, Color color}) stressTestMarketPhaseDisplay(
  StressTestMarketPhase phase,
) {
  return switch (phase) {
    StressTestMarketPhase.preMarket => (
        label: 'Pre-market',
        emoji: '🌅',
        color: const Color(0xFFE67E22),
      ),
    StressTestMarketPhase.regular => (
        label: 'Open',
        emoji: '🟢',
        color: ThemeV2.success,
      ),
    StressTestMarketPhase.postMarket => (
        label: 'After-hours',
        emoji: '🌆',
        color: const Color(0xFF8E44AD),
      ),
    StressTestMarketPhase.closed => (
        label: 'Market closed',
        emoji: '🌙',
        color: ThemeV2.textSecondary,
      ),
  };
}

/// Show market hours bottom sheet (Revolut-style).
void showStressTestMarketHoursSheet(BuildContext context) {
  final currentPhase = currentStressTestMarketPhase();

  showModalBottomSheet(
    context: context,
    backgroundColor: ThemeV2.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(ctx).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeV2.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Market Hours', style: ThemeV2.section),
                const SizedBox(height: 6),
                Text(
                  'Trading schedule for simulated market engine',
                  style: ThemeV2.caption,
                ),
                const SizedBox(height: 20),
                _marketHourRow(
                  emoji: '🌅',
                  label: 'Pre-market',
                  time: '09:00 – 10:59',
                  desc: 'Low volatility, sleepy price action',
                  isActive: currentPhase == StressTestMarketPhase.preMarket,
                ),
                const SizedBox(height: 12),
                _marketHourRow(
                  emoji: '🟢',
                  label: 'Main session',
                  time: '11:00 – 16:59',
                  desc: 'Full activity, maximum volatility',
                  isActive: currentPhase == StressTestMarketPhase.regular,
                ),
                const SizedBox(height: 12),
                _marketHourRow(
                  emoji: '🌆',
                  label: 'After-hours',
                  time: '17:00 – 18:59',
                  desc: 'Fading activity, noise dies down',
                  isActive: currentPhase == StressTestMarketPhase.postMarket,
                ),
                const SizedBox(height: 12),
                _marketHourRow(
                  emoji: '🌙',
                  label: 'Market closed',
                  time: '19:00 – 08:59',
                  desc: 'No trading, weekend included',
                  isActive: currentPhase == StressTestMarketPhase.closed,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _marketHourRow({
  required String emoji,
  required String label,
  required String time,
  required String desc,
  required bool isActive,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isActive ? ThemeV2.primaryBg : Colors.transparent,
      borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
      border: isActive
          ? Border.all(color: ThemeV2.primary.withValues(alpha: 0.25), width: 1.5)
          : null,
    ),
    child: Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: ThemeV2.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isActive ? ThemeV2.primary : ThemeV2.textPrimary,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeV2.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NOW',
                        style: ThemeV2.small.copyWith(
                          fontWeight: FontWeight.w800,
                          color: ThemeV2.primary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(time, style: ThemeV2.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 1),
              Text(desc, style: ThemeV2.small),
            ],
          ),
        ),
      ],
    ),
  );
}
