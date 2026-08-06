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

  /// Calculate weighted composite score (0.0–1.0). [safetyMarkerScore] is
  /// computed separately from the portfolio's holdings (see
  /// safetyMarkerFor() in psychology_engine.dart) rather than stored on
  /// this profile, since it's a pure function of entryFsScore per holding
  /// — pass in `safetyMarkerFor(session.holdings).score`.
  double compositeScore(double safetyMarkerScore) {
    // Веса: panicResistance 0.22, discipline 0.26, patience 0.22,
    // strategyAdherence 0.15, safetyMarker 0.15 — rebalanced 2026-08-06
    // to fold in Safety Marker (previously computed but never actually
    // counted toward the overall score), keeping the original behavioral
    // 3 (panic/discipline/patience) at roughly their original 80%
    // combined share and splitting the rest evenly between the 2
    // portfolio-construction signals (strategy, safety).
    return panicResistance * 0.22 +
        discipline * 0.26 +
        patience * 0.22 +
        strategyAdherence * 0.15 +
        safetyMarkerScore * 0.15;
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
