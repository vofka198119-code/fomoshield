// ---------------------------------------------------------------------------
// Trader Psychology Profile — 4 Sub-Indices
// ---------------------------------------------------------------------------
// Pure data holder + persistence. All the "what happens on trade X" logic
// lives in psychology_engine.dart (evaluateBuyTrade / evaluateSellTrade /
// evaluateStrategyPillar), called from trades_engine.dart at the instant a
// trade executes — never per-tick. Two exceptions stay here as simple
// guarded one-off events: recordCatastropheSurvived / recordHeldThrough
// Catastrophe, both still called from noise_engine.dart.
// ---------------------------------------------------------------------------

/// Tracks the psychological state of a trader across 4 independent sub-indices.
///
/// Each index ranges 0.0 (weak) → 1.0 (strong), initialized at 0.5 (neutral).
/// All mutations are clamped to [0.0, 1.0].
class TraderPsychologyProfile {
  /// Resistance to panic selling under pressure.
  double panicResistance;

  /// Discipline to follow a plan (not over-trade, not chase).
  double discipline;

  /// Patience to hold through volatility and avoid impulsive moves.
  double patience;

  /// Adherence to a strategy (diversification, risk management).
  double strategyAdherence;

  TraderPsychologyProfile({
    this.panicResistance = 0.5,
    this.discipline = 0.5,
    this.patience = 0.5,
    this.strategyAdherence = 0.5,
  });

  /// Called when user survives a Black Swan / catastrophe without panic selling.
  void recordCatastropheSurvived() {
    panicResistance = (panicResistance + 0.15).clamp(0.0, 1.0);
    patience = (patience + 0.10).clamp(0.0, 1.0);
  }

  /// Patience: held through catastrophe epoch without panic selling.
  void recordHeldThroughCatastrophe() {
    patience = (patience + 0.2).clamp(0.0, 1.0);
  }

  /// Create a copy with the same values.
  TraderPsychologyProfile copy() {
    return TraderPsychologyProfile(
      panicResistance: panicResistance,
      discipline: discipline,
      patience: patience,
      strategyAdherence: strategyAdherence,
    );
  }

  /// Calculate weighted composite score (0.0–1.0).
  double get compositeScore {
    // Веса: panicResistance 0.25, discipline 0.30, patience 0.25, strategyAdherence 0.20
    return panicResistance * 0.25 +
        discipline * 0.30 +
        patience * 0.25 +
        strategyAdherence * 0.20;
  }

  Map<String, dynamic> toJson() => {
    'panicResistance': panicResistance,
    'discipline': discipline,
    'patience': patience,
    'strategyAdherence': strategyAdherence,
  };

  factory TraderPsychologyProfile.fromJson(Map<String, dynamic> json) =>
      TraderPsychologyProfile(
        panicResistance: (json['panicResistance'] as num?)?.toDouble() ?? 0.5,
        discipline: (json['discipline'] as num?)?.toDouble() ?? 0.5,
        patience: (json['patience'] as num?)?.toDouble() ?? 0.5,
        strategyAdherence:
            (json['strategyAdherence'] as num?)?.toDouble() ?? 0.5,
      );
}
