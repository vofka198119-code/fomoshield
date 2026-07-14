// ---------------------------------------------------------------------------
// HeroBlock — Market Status + Guardian (Design Bible Part 4)
// ---------------------------------------------------------------------------
// Единый вертикальный блок: фаза рынка + Fear/Greed + Guardian + сообщение.
// padding 34px, min-height 360px, центрированный.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guardian_data.dart';
import 'guardian_widget.dart';
import '../../../core/theme/fomo_shield_theme.dart';
import '../card_frame.dart';

/// Данные для HeroBlock.
class HeroBlockData {
  final GuardianState guardianState;
  final String phaseLabel;
  final String temperatureLabel;
  final double fearIndex; // 0..100
  final double temperature; // -90..+90
  final String? customMessage;

  const HeroBlockData({
    required this.guardianState,
    required this.phaseLabel,
    required this.temperatureLabel,
    required this.fearIndex,
    required this.temperature,
    this.customMessage,
  });

  /// Создать из строк фазы и температуры (из engine).
  factory HeroBlockData.fromEngine({
    required String phase,
    required double temperatureValue,
    required double fearIndexValue,
    String? message,
  }) {
    final state = GuardianState.fromString(phase);

    return HeroBlockData(
      guardianState: state,
      phaseLabel: state.displayName.toUpperCase(),
      temperatureLabel: state.mood,
      fearIndex: fearIndexValue,
      temperature: temperatureValue,
      customMessage: message,
    );
  }
}

/// Hero-блок: Market Status + Guardian.
///
/// ```
/// ┌──────────────────────────┐
/// │ BULL MARKET        71   │
/// │ Calm • Optimistic       │
/// │                         │
/// │      Guardian           │
/// │                         │
/// │ "Stay disciplined."     │
/// └──────────────────────────┘
/// ```
class HeroBlock extends StatelessWidget {
  final HeroBlockData data;

  const HeroBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return CardFrame(
      showTopBar: false,
      padding: const EdgeInsets.all(34),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 360),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Top row: Phase label + Fear/Greed ──
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Phase label
                  Expanded(
                    child: Text(
                      data.phaseLabel,
                      style: GoogleFonts.inter(
                        fontSize: FomoShieldTheme.fsCard,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: FomoShieldTheme.phaseColor(
                          data.phaseLabel.trim().toLowerCase(),
                        ),
                      ),
                    ),
                  ),
                  // Fear/Greed gauge — compact badge
                  _FearGreedBadge(index: data.fearIndex),
                ],
              ),
            ),

            // ── Temperature / mood ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data.temperatureLabel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: FomoShieldTheme.textLight,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Guardian ──
            GuardianWidget(
              state: data.guardianState,
              temperature: data.temperature,
              size: GuardianSize.large,
              showMessage: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact circular Fear/Greed badge — tappable with explanation.
/// Uses contrarian logic: low score = fear = buy signal (green),
/// high score = greed = danger signal (red).
class _FearGreedBadge extends StatelessWidget {
  final double index;

  const _FearGreedBadge({required this.index});

  /// 5-tier contrarian color mapping (Task 1.4):
  ///   0-20:  Bright Green  — Extreme Fear (max safety margin)
  ///  21-40:  Light Green   — Fear (undervalued)
  ///  41-60:  Orange/Yellow — Neutral (hold/follow strategy)
  ///  61-80:  Light Red     — Greed (premium prices)
  ///  81-100: Crimson Red   — Extreme Greed (overheated/danger)
  Color get _color {
    if (index <= 20) return const Color(0xFF00C853); // Bright Green
    if (index <= 40) return const Color(0xFF69DB7C); // Light Green
    if (index <= 60) return FomoShieldTheme.sideways; // Orange/Yellow
    if (index <= 80) return const Color(0xFFE57373); // Light Red
    return const Color(0xFFC62828); // Crimson Red
  }

  String get _label => '${index.round()}';

  String get _tierLabel {
    if (index <= 20) return 'Extreme Fear';
    if (index <= 40) return 'Fear';
    if (index <= 60) return 'Neutral';
    if (index <= 80) return 'Greed';
    return 'Extreme Greed';
  }

  String get _signal {
    if (index <= 20) return 'Max Margin of Safety';
    if (index <= 40) return 'Undervalued';
    if (index <= 60) return 'Hold / Follow Strategy';
    if (index <= 80) return 'Premium Prices';
    return 'Overheated / Dangerous';
  }

  String get _explanation {
    if (index <= 20) {
      return 'The Contrarian Sentiment Index is at Extreme Fear levels '
          '(${index.round()}). The market is in panic, and most investors '
          'are selling at any price. From a contrarian perspective, this is '
          'when the greatest opportunities appear — when fear is maximal, '
          'prices often reflect maximum pessimism.\n\n'
          'This does NOT mean "buy now". It means: assess whether the fear '
          'is rational. History shows that the best entries occur when '
          'fear is at its peak, not when everything feels safe.';
    }
    if (index <= 40) {
      return 'The Contrarian Sentiment Index is in Fear territory '
          '(${index.round()}). Pessimism dominates, and prices may have '
          'fallen below fair value. This zone suggests opportunities to '
          'accumulate at a discount — but only if your strategy and '
          'time horizon allow it.\n\n'
          'Remember: the market can stay irrational longer than you '
          'can stay solvent. Dollar-cost averaging beats trying to '
          'catch the exact bottom.';
    }
    if (index <= 60) {
      return 'The Contrarian Sentiment Index is in Neutral territory '
          '(${index.round()}). There is no dominant fear or euphoria. '
          'Prices are generally fair, and the market is uncertain about '
          'the next direction.\n\n'
          'This is the best time to stick to your plan. Review your '
          'allocation, maintain discipline, and avoid making emotional '
          'decisions. In uncertainty, patience is your edge.';
    }
    if (index <= 80) {
      return 'The Contrarian Sentiment Index is in Greed territory '
          '(${index.round()}). Optimism is rising, and prices have moved '
          'above fair value ranges. From a contrarian standpoint, this '
          'is a caution zone — the easy money has been made.\n\n'
          'Consider taking partial profits, tightening stop-losses, and '
          'reducing position sizes. The best defense against a correction '
          'is not trying to time it, but being positioned to survive it.';
    }
    return 'The Contrarian Sentiment Index is at Extreme Greed levels '
        '(${index.round()}). Euphoria dominates — everyone is buying, '
        'FOMO is at its peak, and prices are disconnected from '
        'fundamentals. This is historically the most dangerous time '
        'to buy.\n\n'
        'The higher the euphoria, the harder the eventual fall. '
        'This is the moment to demonstrate true discipline: lock in '
        'profits, reduce risk, and wait for the next cycle. '
        'Remember: the best trades are made when others are fearful, '
        'not when they are greedy.';
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title row: circle + "FEAR & GREED INDEX"
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _color, width: 2),
                    color: _color.withOpacity(0.12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FEAR & GREED INDEX',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: FomoShieldTheme.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Signal subtitle
            Text(
              _signal,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _color,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _explanation,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: FomoShieldTheme.textLight,
              ),
            ),
            const SizedBox(height: 12),
            // Tier label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tierLabel.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: _color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _color.withOpacity(0.3), width: 2),
          color: _color.withOpacity(0.08),
        ),
        alignment: Alignment.center,
        child: Text(
          _label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _color,
          ),
        ),
      ),
    );
  }
}
