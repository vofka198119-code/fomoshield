// ---------------------------------------------------------------------------
// WhySheet — Bottom Sheet for Explainable Card (Design Bible Part 9)
// ---------------------------------------------------------------------------
// Показывает полную карточку Explainable + комментарий Guardian.
// Вызывается кнопкой "Why?" рядом с изменением цены.
//
//   ┌──────────────────────────────────────┐
//   │         WHY TODAY?   AAPL +3.28%     │
//   │  ┌────────────────────────────────┐  │
//   │  │ ████ Market ████│Sector│News│N │  │  ← conic composition bar
//   │  └────────────────────────────────┘  │
//   │  46% Market       ████████████       │
//   │  27% Sector       ████████           │
//   │  18% News         █████              │
//   │   9% Noise        ██                 │
//   │                                      │
//   │  Market remained optimistic today.   │
//   │                                      │
//   │  ── Guardian ──                      │
//   │  "Today's market rewarded patience."  │
//   └──────────────────────────────────────┘
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../widgets/guardian/guardian_data.dart';
import 'card_frame.dart';
import 'explainable_card.dart';

/// Opens a WhySheet bottom sheet with the given [data] and [temperature].
///
/// [temperature] is the market temperature (-90..+90) used to select
/// a Guardian commentary message.
void showWhySheet(
  BuildContext context, {
  required ExplainableData data,
  required double temperature,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WhySheet(data: data, temperature: temperature),
  );
}

/// Bottom sheet content: ExplainableCard + Guardian commentary.
class _WhySheet extends StatelessWidget {
  final ExplainableData data;
  final double temperature;

  const _WhySheet({
    required this.data,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: FomoShieldTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
            child: Column(
              children: [
                // ── Drag handle ──
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: FomoShieldTheme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // ── Explainable Card ──
                ExplainableCard(data: data),
                const SizedBox(height: 20),
                // ── Guardian commentary ──
                _GuardianComment(temperature: temperature),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Guardian commentary line below the explainable card.
class _GuardianComment extends StatelessWidget {
  final double temperature;

  const _GuardianComment({required this.temperature});

  @override
  Widget build(BuildContext context) {
    // Determine guardian state from temperature
    final state = _guardianStateFromTemperature(temperature);
    final message = GuardianMessages.forTemperature(temperature, state);

    return CardFrame(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Guardian mini-icon ──
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: GuardianStateConfig.of(state).shieldColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: GuardianStateConfig.of(state).shieldColor,
            ),
          ),
          // ── Message ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GUARDIAN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    color: FomoShieldTheme.text,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
}
