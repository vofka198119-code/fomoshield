// ---------------------------------------------------------------------------
// Guardian — State Configuration & Data (Design Bible Parts 5, 6, 10)
// ---------------------------------------------------------------------------
// 7 состояний Guardian + настройки цвета, анимаций и сообщений.
// Нет рта — эмоции через глаза, брови и щит.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../../core/theme/fomo_shield_theme.dart';

/// 7 состояний Guardian, соответствующие фазам рынка.
/// Добавлены hype (эйфория) и speculation (хайп/неопределённость).
enum GuardianState {
  bull,
  sideways,
  bear,
  volatility,
  blackSwan,
  crash,
  recovery,
  hype,
  speculation;

  /// Создать из строки (например из `session.devMarketPhase`).
  static GuardianState fromString(String phase) =>
      switch (phase.toLowerCase()) {
        'bull' => GuardianState.bull,
        'bear' => GuardianState.bear,
        'sideways' => GuardianState.sideways,
        'recovery' => GuardianState.recovery,
        'volatility' => GuardianState.volatility,
        'blackswan' || 'black_swan' => GuardianState.blackSwan,
        'crash' => GuardianState.crash,
        'hype' => GuardianState.hype,
        'speculation' => GuardianState.speculation,
        _ => () {
          debugPrint(
            '[FOMO-Guardian] Unknown phase "$phase" — falling back to sideways',
          );
          return GuardianState.sideways;
        }(),
      };

  /// Человекочитаемое название.
  String get displayName => switch (this) {
    GuardianState.bull => 'Bull Market',
    GuardianState.sideways => 'Sideways',
    GuardianState.bear => 'Bear Market',
    GuardianState.volatility => 'Volatile',
    GuardianState.blackSwan => 'Black Swan',
    GuardianState.crash => 'Crash',
    GuardianState.recovery => 'Recovery',
    GuardianState.hype => 'Hype / Euphoria',
    GuardianState.speculation => 'Speculation',
  };

  /// Краткое описание настроения рынка.
  String get mood => switch (this) {
    GuardianState.bull => 'Optimistic',
    GuardianState.sideways => 'Calm',
    GuardianState.bear => 'Pessimistic',
    GuardianState.volatility => 'Uneasy',
    GuardianState.blackSwan => 'Shocked',
    GuardianState.crash => 'Panic',
    GuardianState.recovery => 'Hopeful',
    GuardianState.hype => 'Euphoric',
    GuardianState.speculation => 'Uncertain',
  };
}

/// Конфигурация внешнего вида Guardian для каждого состояния.
class GuardianStateConfig {
  final GuardianState state;

  // ── Aura ──
  final Color auraColor;
  final double auraRadiusMultiplier;

  // ── Body ──
  final Color bodyColor;
  final Color bodyHighlight;

  // ── Eyes ──
  final double eyeOpenAmount; // 0.0 = closed, 1.0 = fully open
  final Color eyeIrisColor;
  final double eyeGlowIntensity; // 0.0–1.0

  // ── Brows ──
  /// Угол наклона бровей в градусах. Положительный = приподняты.
  final double browAngleDeg;

  // ── Shield ──
  final Color shieldColor;
  final double shieldScale; // 0.5–1.2
  final double shieldBrightness; // 0.0–1.0
  final bool shieldCracked; // трещины (BlackSwan/Crash)

  // ── Background gradient (radial, center → edge) ──
  final List<Color> backgroundGradientColors;

  // ── Message ──
  final String message;

  const GuardianStateConfig({
    required this.state,
    required this.auraColor,
    required this.auraRadiusMultiplier,
    required this.bodyColor,
    required this.bodyHighlight,
    required this.eyeOpenAmount,
    required this.eyeIrisColor,
    required this.eyeGlowIntensity,
    required this.browAngleDeg,
    required this.shieldColor,
    required this.shieldScale,
    required this.shieldBrightness,
    required this.shieldCracked,
    required this.backgroundGradientColors,
    required this.message,
  });

  /// Карта конфигов для всех 9 состояний.
  static const Map<GuardianState, GuardianStateConfig> all = {
    // ═══════════════════════════════════════════════════════════════
    //  BULL — +25% glow, eyes wide, brows raised
    // ═══════════════════════════════════════════════════════════════
    GuardianState.bull: GuardianStateConfig(
      state: GuardianState.bull,
      auraColor: FomoShieldTheme.bull,
      auraRadiusMultiplier: 1.25,
      bodyColor: FomoShieldTheme.guardianBody,
      bodyHighlight: const Color(0xFF6B9AC4),
      eyeOpenAmount: 1.0,
      eyeIrisColor: FomoShieldTheme.guardianEye,
      eyeGlowIntensity: 0.4,
      browAngleDeg: 8.0,
      shieldColor: FomoShieldTheme.primary,
      shieldScale: 0.95,
      shieldBrightness: 1.0,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF1B3A5C), // deep navy center
        const Color(0xFF6FA7D6), // market blue mid
        Colors.white, // edge
      ],
      message:
          'The market is in good shape. Stay disciplined and trust your plan.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  SIDEWAYS — calm, neutral, minimal animation
    // ═══════════════════════════════════════════════════════════════
    GuardianState.sideways: GuardianStateConfig(
      state: GuardianState.sideways,
      auraColor: FomoShieldTheme.sideways,
      auraRadiusMultiplier: 1.0,
      bodyColor: FomoShieldTheme.guardianBody,
      bodyHighlight: const Color(0xFF6B9AC4),
      eyeOpenAmount: 0.9,
      eyeIrisColor: FomoShieldTheme.guardianEye,
      eyeGlowIntensity: 0.2,
      browAngleDeg: 0.0,
      shieldColor: FomoShieldTheme.primaryDark,
      shieldScale: 1.0,
      shieldBrightness: 0.7,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF5A5A5A), // graphite center
        const Color(0xFFBFB9AE), // taupe / noise mid
        Colors.white, // edge
      ],
      message: 'Markets are quiet. Use this time to review your strategy.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  BEAR — brows lower, shield darker, eyes slightly narrowed
    // ═══════════════════════════════════════════════════════════════
    GuardianState.bear: GuardianStateConfig(
      state: GuardianState.bear,
      auraColor: FomoShieldTheme.bear,
      auraRadiusMultiplier: 0.9,
      bodyColor: const Color(0xFF3D5A73),
      bodyHighlight: const Color(0xFF557D5D),
      eyeOpenAmount: 0.7,
      eyeIrisColor: const Color(0xFF4A8BC4),
      eyeGlowIntensity: 0.15,
      browAngleDeg: -12.0,
      shieldColor: const Color(0xFF2A4A5A),
      shieldScale: 1.05,
      shieldBrightness: 0.5,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF5C1A1A), // dark red center
        const Color(0xFFD46F6F), // soft red mid
        Colors.white, // edge
      ],
      message:
          'Markets are declining. Remember: downturns are part of the cycle.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  VOLATILITY — pulsing aura, shield vibration
    // ═══════════════════════════════════════════════════════════════
    GuardianState.volatility: GuardianStateConfig(
      state: GuardianState.volatility,
      auraColor: FomoShieldTheme.volatility,
      auraRadiusMultiplier: 1.15,
      bodyColor: const Color(0xFF4A6580),
      bodyHighlight: const Color(0xFF6B89A4),
      eyeOpenAmount: 0.85,
      eyeIrisColor: const Color(0xFFE8C84A),
      eyeGlowIntensity: 0.5,
      browAngleDeg: -5.0,
      shieldColor: FomoShieldTheme.volatility,
      shieldScale: 1.02,
      shieldBrightness: 0.8,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF5C4A1A), // dark amber center
        const Color(0xFFE8C84A), // gold mid
        Colors.white, // edge
      ],
      message:
          'High volatility. Breathe. Stick to your plan, not your impulses.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  BLACK SWAN — purple glow, cracked shield
    // ═══════════════════════════════════════════════════════════════
    GuardianState.blackSwan: GuardianStateConfig(
      state: GuardianState.blackSwan,
      auraColor: FomoShieldTheme.blackSwan,
      auraRadiusMultiplier: 1.3,
      bodyColor: const Color(0xFF2A1F3D),
      bodyHighlight: const Color(0xFF4A3D5D),
      eyeOpenAmount: 0.9,
      eyeIrisColor: const Color(0xFFB07CFF),
      eyeGlowIntensity: 0.7,
      browAngleDeg: -15.0,
      shieldColor: const Color(0xFF1A1040),
      shieldScale: 0.85,
      shieldBrightness: 0.3,
      shieldCracked: true,
      backgroundGradientColors: [
        const Color(0xFF2A1A4A), // deep purple center
        const Color(0xFF8A76D6), // news purple mid
        Colors.white, // edge
      ],
      message:
          'Unexpected market shock. This is the ultimate test of discipline.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  CRASH — shield 60%, red haze, eyes half-closed
    // ═══════════════════════════════════════════════════════════════
    GuardianState.crash: GuardianStateConfig(
      state: GuardianState.crash,
      auraColor: FomoShieldTheme.crash,
      auraRadiusMultiplier: 0.8,
      bodyColor: const Color(0xFF2A1A1A),
      bodyHighlight: const Color(0xFF4A3030),
      eyeOpenAmount: 0.4,
      eyeIrisColor: const Color(0xFFCC4444),
      eyeGlowIntensity: 0.3,
      browAngleDeg: -20.0,
      shieldColor: const Color(0xFF401515),
      shieldScale: 0.6,
      shieldBrightness: 0.2,
      shieldCracked: true,
      backgroundGradientColors: [
        const Color(0xFF4A1010), // near-black red center
        const Color(0xFFCC4444), // crash red mid
        Colors.white, // edge
      ],
      message:
          'Markets are crashing. Fear is natural. Do not make impulsive decisions.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  RECOVERY — cracks disappear, slow color return
    // ═══════════════════════════════════════════════════════════════
    GuardianState.recovery: GuardianStateConfig(
      state: GuardianState.recovery,
      auraColor: FomoShieldTheme.recovery,
      auraRadiusMultiplier: 1.1,
      bodyColor: const Color(0xFF3D6B4D),
      bodyHighlight: const Color(0xFF6B9B7D),
      eyeOpenAmount: 0.9,
      eyeIrisColor: const Color(0xFF7ADB7A),
      eyeGlowIntensity: 0.35,
      browAngleDeg: 4.0,
      shieldColor: const Color(0xFF2A6B3A),
      shieldScale: 0.95,
      shieldBrightness: 0.7,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF1A4A2A), // deep green center
        const Color(0xFF77C88A), // sector green mid
        Colors.white, // edge
      ],
      message: 'Recovery is underway. Patience rewards those who waited.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  HYPE — extreme euphoria, high glow, brows raised high
    //  (placeholder: uses bull-like config with intensified glow)
    // ═══════════════════════════════════════════════════════════════
    GuardianState.hype: GuardianStateConfig(
      state: GuardianState.hype,
      auraColor: FomoShieldTheme.bull,
      auraRadiusMultiplier: 1.4,
      bodyColor: FomoShieldTheme.guardianBody,
      bodyHighlight: const Color(0xFF6B9AC4),
      eyeOpenAmount: 1.0,
      eyeIrisColor: const Color(0xFFFFD700),
      eyeGlowIntensity: 0.8,
      browAngleDeg: 14.0,
      shieldColor: const Color(0xFFD04E4E),
      shieldScale: 0.85,
      shieldBrightness: 0.9,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF4A1A1A), // red center
        const Color(0xFFFF8800), // orange mid
        Colors.white, // edge
      ],
      message:
          'Euphoria is dangerous. The higher you fly, the harder the fall.',
    ),

    // ═══════════════════════════════════════════════════════════════
    //  SPECULATION — multi-directional, high volatility, uneasy
    //  (placeholder: uses volatility-like config with amber tones)
    // ═══════════════════════════════════════════════════════════════
    GuardianState.speculation: GuardianStateConfig(
      state: GuardianState.speculation,
      auraColor: FomoShieldTheme.volatility,
      auraRadiusMultiplier: 1.2,
      bodyColor: const Color(0xFF4A5065),
      bodyHighlight: const Color(0xFF6B7A94),
      eyeOpenAmount: 0.8,
      eyeIrisColor: const Color(0xFFFF8800),
      eyeGlowIntensity: 0.6,
      browAngleDeg: -8.0,
      shieldColor: const Color(0xFFB8860B),
      shieldScale: 1.0,
      shieldBrightness: 0.7,
      shieldCracked: false,
      backgroundGradientColors: [
        const Color(0xFF3A3A1A), // olive center
        const Color(0xFFD7AE42), // sideways gold mid
        Colors.white, // edge
      ],
      message: 'Speculation is noisy. Stick to fundamentals, not rumors.',
    ),
  };

  /// Получить конфиг по состоянию.
  static GuardianStateConfig of(GuardianState state) => all[state]!;
}

/// Набор сообщений для разных температурных режимов (Emotional UX).
class GuardianMessages {
  /// Сообщение для данной температуры и фазы.
  static String forTemperature(double temperature, GuardianState state) {
    if (temperature >= 60) {
      return _random(_euphoria);
    }
    if (temperature >= 30) {
      return _random(_greedy);
    }
    if (temperature >= 10) {
      return _random(_optimistic);
    }
    if (temperature >= -10) {
      return _random(_neutral);
    }
    if (temperature >= -30) {
      return _random(_anxious);
    }
    if (temperature >= -60) {
      return _random(_fear);
    }
    return _random(_panic);
  }

  static final _euphoria = [
    'Euphoria is dangerous. Stay grounded.',
    'When everyone is greedy, be cautious.',
    'Success feels great. Do not let it cloud your judgment.',
  ];

  static final _greedy = [
    'Greed is natural. Discipline is your shield.',
    'The market rewards patience, not impulsiveness.',
    'Remember why you started this simulation.',
  ];

  static final _optimistic = [
    'Optimism is good. Overconfidence is not.',
    'Enjoy the green. But prepare for red.',
    'A calm mind makes better decisions.',
  ];

  static final _neutral = [
    'Stay disciplined.',
    'Follow your strategy, not the noise.',
    'Every decision is a learning opportunity.',
  ];

  static final _anxious = [
    'Anxiety is a signal, not a command.',
    'Breathe. Markets recover.',
    'Fear makes us sell low. Patience pays.',
  ];

  static final _fear = [
    'Fear is loud. Wisdom is quiet.',
    'This is exactly why you are here — to learn control.',
    'The best trades are made in calm, not in panic.',
  ];

  static final _panic = [
    'Panic is the enemy of reason.',
    'Extreme fear creates extreme opportunity.',
    'Stop. Breathe. Do not act now.',
  ];

  static String _random(List<String> messages) {
    return messages[DateTime.now().microsecondsSinceEpoch % messages.length];
  }
}
