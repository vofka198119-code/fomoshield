// ---------------------------------------------------------------------------
// GuardianWidget — Character display with PNG assets
// ---------------------------------------------------------------------------
// Design Bible Parts 5 & 8:
//   - 7 states via GuardianStateConfig
//   - PNG images instead of CustomPainter
//   - Oval gradient shadow underneath
//   - No mouth, no buy/sell/hold advice
//   - Emotional UX messaging below the character
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'guardian_data.dart';
import '../../../core/theme/fomo_shield_theme.dart';

/// Size variant for the Guardian widget.
enum GuardianSize {
  /// For Hero block (~200px canvas).
  large,

  /// For compact / card embed (~120px canvas).
  small,
}

/// Main Guardian character widget — displays PNG asset + oval shadow + message.
class GuardianWidget extends StatelessWidget {
  /// Current market state.
  final GuardianState state;

  /// Market temperature (-90..+90) for message selection.
  final double temperature;

  /// Size variant.
  final GuardianSize size;

  /// Whether to show the guardian message below the character.
  final bool showMessage;

  /// Optional custom message. If null, auto-selected from temperature + state.
  final String? message;

  const GuardianWidget({
    super.key,
    required this.state,
    this.temperature = 0.0,
    this.size = GuardianSize.large,
    this.showMessage = true,
    this.message,
  });

  /// Map state → asset path.
  /// hype/speculation use bull/volatility PNGs as placeholders.
  String get _assetPath => switch (state) {
    GuardianState.bull => 'assets/images/guardian_bull.png',
    GuardianState.sideways => 'assets/images/guardian_sideways.png',
    GuardianState.bear => 'assets/images/guardian_bear.png',
    GuardianState.volatility => 'assets/images/guardian_volatility.png',
    GuardianState.blackSwan => 'assets/images/guardian_black_swan.png',
    GuardianState.crash => 'assets/images/guardian_crash.png',
    GuardianState.recovery => 'assets/images/guardian_recovery.png',
    GuardianState.hype => 'assets/images/guardian_bull.png',
    GuardianState.speculation => 'assets/images/guardian_volatility.png',
  };

  String _selectMessage() {
    if (message != null) return message!;
    return GuardianMessages.forTemperature(temperature, state);
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = size == GuardianSize.large ? 220.0 : 140.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Guardian with background gradient + ground shadow ──
        SizedBox(
          width: canvasSize,
          height: canvasSize,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Ground shadow — elliptical gradient pushed to bottom
              Align(
                alignment: Alignment(0, 0.70),
                child: Container(
                  width: canvasSize * 0.7,
                  height: canvasSize * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(canvasSize * 0.35, canvasSize * 0.1),
                    ),
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Guardian PNG image
              Positioned.fill(
                child: Image.asset(
                  _assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),

        // ── Message ──
        if (showMessage) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedSwitcher(
              duration: FomoShieldTheme.animNormal,
              child: Text(
                _selectMessage(),
                key: ValueKey('${state}_${temperature.toStringAsFixed(1)}'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: FomoShieldTheme.text,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
