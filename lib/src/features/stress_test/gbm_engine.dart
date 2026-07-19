part of 'stress_test_engine.dart';

// ---------------------------------------------------------------------------
// GBM Engine — Geometric Brownian Motion core: drift/volatility formula,
// per-regime drift clamping, per-regime price bounds, and sector resolution.
// ---------------------------------------------------------------------------
// Extracted verbatim from stress_test_engine.dart as part of the mechanism
// split (Задание 1). No logic was changed during this move.
// ---------------------------------------------------------------------------

// ── Per-Epoch Noise ───────────────────────────────────────────────
// Prices update per epoch (not per tick). Each epoch applies:
//   Delta = SectorDrift + FullVolatility + MicroNoise
// MicroNoise prevents perfectly linear charts between epoch rolls.
const double _microNoiseRange = 0.003; // ±0.3% intra-epoch micro-fluctuation

// ── Time-Delta Scaling (Geometric Brownian Motion) ─────────────────
// Without dt scaling, full per-epoch drift/volatility was applied every
// 20-second UI tick, causing hyper-inflation (+197% AMD in 15 min).
//
// GBM formula:  P_new = P_old × (1 + μ×dt + σ×ε×√dt)
//   where ε ~ Uniform(-0.5, +0.5)  (zero-mean, symmetric)
//
// dt = fraction of a simulated period per 20-second UI tick.
//
// dt is NOT a fixed constant — it's computed per call in
// noise_engine.dart's `_simulateCurrentPrices` as
// `1.0 / ticksPerEpoch(session.duration.rollInterval)`, so the full
// annual-equivalent drift/volatility for the active scenario is spread
// evenly across that epoch's actual real-world length (12h/24h/5d/7d),
// not a fixed ~67 real minutes regardless of epoch length. A fixed dt
// (previously 0.005, tuned for a 12h epoch) let every scenario's full
// designed magnitude "burn through" in ~200 ticks and then keep randomly
// walking — unanchored — for the rest of whatever real time the epoch
// actually spanned, until it hit the regime's price clamp and sat pinned
// there (confirmed on-device: a Bull epoch parked at exactly its +100%
// ceiling, oscillating ±1-2%/tick against it).

/// Whether we've already printed the dt calibration header this session.
bool _dtCalibrationLogged = false;

// ---------------------------------------------------------------------------
// Definitive Market Simulation Matrix — Multi-Sector & Multi-Scenario
// ---------------------------------------------------------------------------
//
// Every asset is classified into an [AssetSector]. Drift (μ) and Volatility (σ)
// are ANNUALIZED values strictly determined by the active [MarketScenario].
//
// GBM formula (per tick, dt = 1 / ticks in the current epoch):
//   P_new = P_old × (1 + μ×dt + σ×ε×√dt + microNoise×ε₂×√dt)
//   where ε ~ Uniform(-0.5, +0.5)
//
// Micro-noise is sector-aware: reduced by 75% for ETFs for smooth charts.

/// Internal scenario classification that maps MarketScenario → matrix row.
/// [speculation] (the old global-regime row) was removed — dead code, see
/// below: MarketScenario.speculation has mapped to [sideways] since Block 5
/// and nothing ever reached the old [speculation] row through
/// [_toMacroRegime].
enum _MacroRegime { sideways, volatility, bull, bear, crash, blackSwan, recovery }

/// Maps a [MarketScenario] to its [_MacroRegime] for matrix lookup.
/// ── Block 5: hype/speculation are no longer global regimes ────
/// Hype now operates sector-wide (see ../hype/hype_event.dart); Speculation
/// was per-company but its implementation was removed 2026-07-19 (see
/// repair queue in project memory for the "add back later" list).
/// When a test rolls hype/speculation as a global scenario, it behaves like
/// sideways. In practice this branch is unreachable: both are excluded from
/// the epoch roulette's
/// pool (see [MarketScenario.isPerCompanyEvent]), kept only so this switch
/// stays exhaustive.
///
/// Recovery has its OWN row (not sideways) — real post-crash recovery isn't
/// flat/calm, it has genuine swings, and it's not guaranteed to net positive
/// (see _MacroRegime.recovery row below: half of Bull's drift, same
/// volatility as Bull, so a run of bad ticks can still leave a holding down
/// even during the "recovery" window — a company can fail to recover, same
/// as in real life).
///
/// bear/crash/blackSwan each get their OWN row now — they used to all
/// share [bear]'s row (identical price math for three scenarios with very
/// different declared severities: bear "gradual decline" ~-1%/epoch, crash
/// "heavy drop" ~-11%/epoch, blackSwan "everything crashes hard"
/// ~-29%/epoch per [MarketScenario.drift] — confirmed via harness: two
/// forced epochs with the same seed landed on the exact same price because
/// they used to resolve to identical GBM params).
_MacroRegime _toMacroRegime(MarketScenario s) => switch (s) {
  MarketScenario.sideways ||
  MarketScenario.hype ||
  MarketScenario.speculation => _MacroRegime.sideways,
  MarketScenario.volatility => _MacroRegime.volatility,
  MarketScenario.bull => _MacroRegime.bull,
  MarketScenario.recovery => _MacroRegime.recovery,
  MarketScenario.bear => _MacroRegime.bear,
  MarketScenario.crash => _MacroRegime.crash,
  MarketScenario.blackSwan => _MacroRegime.blackSwan,
};

/// Annualized drift (μ) and volatility (σ) for a sector under a regime.
class _SectorParams {
  final double annualDrift;
  final double annualVolatility;
  const _SectorParams(this.annualDrift, this.annualVolatility);
}

/// ── Master Matrix ──────────────────────────────────────────────────
///
/// | Regime        | Sector            | μ (annual) | σ (annual) |
/// |---------------|-------------------|------------|------------|
/// | SIDEWAYS      | techSpeculative   | 0.00       | 0.06       |
/// |               | consumerStaples   | 0.01       | 0.02       |
/// |               | cyclicalConsumer  | 0.00       | 0.04       |
/// |               | realEstateREIT    | 0.02       | 0.02       |
/// |               | etfBroadMarket    | 0.00       | 0.03       |
/// | SPECULATION   | techSpeculative   | 0.40       | 0.45       |
/// |               | consumerStaples   | 0.02       | 0.06       |
/// |               | cyclicalConsumer  | 0.15       | 0.20       |
/// |               | realEstateREIT    | -0.05      | 0.08       |
/// |               | etfBroadMarket    | 0.10       | 0.15       |
/// | BULL          | techSpeculative   | 0.25       | 0.18       |
/// |               | consumerStaples   | 0.08       | 0.06       |
/// |               | cyclicalConsumer  | 0.18       | 0.12       |
/// |               | realEstateREIT    | 0.10       | 0.05       |
/// |               | etfBroadMarket    | 0.12       | 0.08       |
/// | BEAR          | techSpeculative   | -0.08      | 0.12       |
/// |               | consumerStaples   | -0.01      | 0.03       |
/// |               | cyclicalConsumer  | -0.05      | 0.07       |
/// |               | realEstateREIT    | -0.03      | 0.04       |
/// |               | etfBroadMarket    | -0.04      | 0.05       |
/// | CRASH         | techSpeculative   | -0.25      | 0.28       |
/// |               | consumerStaples   | -0.03      | 0.07       |
/// |               | cyclicalConsumer  | -0.17      | 0.17       |
/// |               | realEstateREIT    | -0.08      | 0.10       |
/// |               | etfBroadMarket    | -0.12      | 0.11       |
/// | BLACK SWAN    | techSpeculative   | -0.50      | 0.55       |
/// |               | consumerStaples   | -0.06      | 0.13       |
/// |               | cyclicalConsumer  | -0.33      | 0.33       |
/// |               | realEstateREIT    | -0.17      | 0.20       |
/// |               | etfBroadMarket    | -0.24      | 0.22       |
///
/// bear/crash/blackSwan used to share ONE row (identical price math for
/// three scenarios with very different declared severities — see
/// [_toMacroRegime]'s doc comment). Now scaled to roughly match their
/// declared per-epoch averages ([MarketScenario.drift]: bear ~-1.1%,
/// crash ~-11%, blackSwan ~-29% — a ~1:10:26 ratio on drift), with a
/// gentler ~1:3:5 ratio on volatility (a "gradual decline" bear market
/// still has real day-to-day noise, just far less than a crash/blackSwan).
const Map<_MacroRegime, Map<AssetSector, _SectorParams>> _masterMatrix = {
  _MacroRegime.sideways: {
    AssetSector.techSpeculative: _SectorParams(0.00, 0.06),
    AssetSector.consumerStaples: _SectorParams(0.01, 0.02),
    AssetSector.cyclicalConsumer: _SectorParams(0.00, 0.04),
    AssetSector.realEstateREIT: _SectorParams(0.02, 0.02),
    AssetSector.etfBroadMarket: _SectorParams(0.00, 0.03),
  },
  _MacroRegime.bull: {
    AssetSector.techSpeculative: _SectorParams(0.25, 0.18),
    AssetSector.consumerStaples: _SectorParams(0.08, 0.06),
    AssetSector.cyclicalConsumer: _SectorParams(0.18, 0.12),
    AssetSector.realEstateREIT: _SectorParams(0.10, 0.05),
    AssetSector.etfBroadMarket: _SectorParams(0.12, 0.08),
  },
  _MacroRegime.volatility: {
    AssetSector.techSpeculative: _SectorParams(0.00, 0.40),
    AssetSector.consumerStaples: _SectorParams(0.00, 0.12),
    AssetSector.cyclicalConsumer: _SectorParams(0.00, 0.25),
    AssetSector.realEstateREIT: _SectorParams(0.00, 0.18),
    AssetSector.etfBroadMarket: _SectorParams(0.00, 0.20),
  },
  // Bear: mild, "gradual decline, staples resilient" — the calmest of the
  // three decline scenarios.
  _MacroRegime.bear: {
    AssetSector.techSpeculative: _SectorParams(-0.08, 0.12),
    AssetSector.consumerStaples: _SectorParams(-0.01, 0.03),
    AssetSector.cyclicalConsumer: _SectorParams(-0.05, 0.07),
    AssetSector.realEstateREIT: _SectorParams(-0.03, 0.04),
    AssetSector.etfBroadMarket: _SectorParams(-0.04, 0.05),
  },
  // Crash: "heavy sector-wide drop" — meaningfully worse than Bear,
  // clearly milder than blackSwan.
  _MacroRegime.crash: {
    AssetSector.techSpeculative: _SectorParams(-0.25, 0.28),
    AssetSector.consumerStaples: _SectorParams(-0.03, 0.07),
    AssetSector.cyclicalConsumer: _SectorParams(-0.17, 0.17),
    AssetSector.realEstateREIT: _SectorParams(-0.08, 0.10),
    AssetSector.etfBroadMarket: _SectorParams(-0.12, 0.11),
  },
  // Black swan: "everything crashes hard" — the most extreme scenario in
  // the whole matrix (previously this same magnitude was also applied to
  // Bear and Crash, which is what made all three indistinguishable).
  _MacroRegime.blackSwan: {
    AssetSector.techSpeculative: _SectorParams(-0.50, 0.55),
    AssetSector.consumerStaples: _SectorParams(-0.06, 0.13),
    AssetSector.cyclicalConsumer: _SectorParams(-0.33, 0.33),
    AssetSector.realEstateREIT: _SectorParams(-0.17, 0.20),
    AssetSector.etfBroadMarket: _SectorParams(-0.24, 0.22),
  },
  // Recovery: half of Bull's drift (a lean toward recovering, not a
  // guarantee), same volatility as Bull (real swings — the same magnitude
  // already in production for the Bull regime, not a new untested number).
  // A run of bad ticks can still leave a holding net negative by the end
  // of the 2 scripted recovery epochs — a company can fail to recover.
  _MacroRegime.recovery: {
    AssetSector.techSpeculative: _SectorParams(0.125, 0.18),
    AssetSector.consumerStaples: _SectorParams(0.04, 0.06),
    AssetSector.cyclicalConsumer: _SectorParams(0.09, 0.12),
    AssetSector.realEstateREIT: _SectorParams(0.05, 0.05),
    AssetSector.etfBroadMarket: _SectorParams(0.06, 0.08),
  },
};

/// Lookup sector params for a symbol + scenario.
_SectorParams _getSectorParams(String symbol, MarketScenario scenario) {
  final assetSector = _getAssetSector(symbol);
  final regime = _toMacroRegime(scenario);
  return _masterMatrix[regime]![assetSector]!;
}

// ── Sandbox Isolation (Step 3): Drift Bounds per MacroRegime ──────────
// Prevents unrealistic single-tick price spikes. Each regime defines
// the max absolute per-tick price change (drift + noise + micro).
// After 1 full day (200 ticks), max cumulative change is bounded.
//
// Bear regime: asymmetric — can drop -6% but only rise +3% per tick.
// This replaces the old universal clamp(basePrice×0.3, basePrice×3.0).

class _DriftBounds {
  final double minPerTick;
  final double maxPerTick;

  /// Max price as a multiple of basePrice (per-regime cap).
  final double maxPriceMultiplier;

  /// Min price as a multiple of basePrice (per-regime floor).
  final double minPriceMultiplier;

  const _DriftBounds(
    this.minPerTick,
    this.maxPerTick, {
    this.maxPriceMultiplier = 1.5,
    this.minPriceMultiplier = 0.4,
  });
}

const _driftBounds = <_MacroRegime, _DriftBounds>{
  _MacroRegime.sideways: _DriftBounds(
    -0.025,
    0.025,
    maxPriceMultiplier: 1.3,
    minPriceMultiplier: 0.6,
  ),
  _MacroRegime.bull: _DriftBounds(
    -0.05,
    0.05,
    maxPriceMultiplier: 2.0,
    minPriceMultiplier: 0.3,
  ),
  _MacroRegime.volatility: _DriftBounds(
    -0.08,
    0.08,
    maxPriceMultiplier: 2.0,
    minPriceMultiplier: 0.3,
  ),
  // Bear: mildest floor of the three decline regimes — "gradual decline",
  // shouldn't be able to fall as far as a crash/blackSwan within one epoch.
  _MacroRegime.bear: _DriftBounds(
    -0.03,
    0.02,
    maxPriceMultiplier: 1.2,
    minPriceMultiplier: 0.6,
  ),
  // Crash: between Bear and blackSwan.
  _MacroRegime.crash: _DriftBounds(
    -0.05,
    0.025,
    maxPriceMultiplier: 1.25,
    minPriceMultiplier: 0.4,
  ),
  // Black swan: the deepest floor in the whole matrix — "everything
  // crashes hard". Same numbers the old shared bear/crash/blackSwan row
  // used, kept here since blackSwan is the scenario that actually earns
  // this severity.
  _MacroRegime.blackSwan: _DriftBounds(
    -0.06,
    0.03,
    maxPriceMultiplier: 1.3,
    minPriceMultiplier: 0.3,
  ),
  // Same bounds as Bull — recovery shares Bull's volatility character,
  // just a weaker (non-guaranteed) upward lean. See _masterMatrix above.
  _MacroRegime.recovery: _DriftBounds(
    -0.05,
    0.05,
    maxPriceMultiplier: 2.0,
    minPriceMultiplier: 0.3,
  ),
};

/// Clamp the effective per-tick price change to regime-appropriate bounds.
/// Prevents impossible anomalies like +100% in a bear market.
double _clampDrift(double rawChange, _MacroRegime regime) {
  final bounds = _driftBounds[regime]!;
  return rawChange.clamp(bounds.minPerTick, bounds.maxPerTick);
}

/// Get per-regime price bounds for final clamping.
_DriftBounds _getRegimeBounds(_MacroRegime regime) => _driftBounds[regime]!;

/// Resolve a ticker symbol to its legacy market sector.
MarketSector _getSector(String symbol) {
  return _symbolSectorMap[symbol] ?? MarketSector.other;
}

/// Resolve a ticker symbol to its definitive [AssetSector].
/// Delegates to the canonical SSOT mapping in [resolveAssetSector].
AssetSector _getAssetSector(String symbol) {
  return resolveAssetSector(symbol);
}

/// Known symbol → [MarketSector] mapping (legacy, for backward compat).
const Map<String, MarketSector> _symbolSectorMap = {
  // Technology
  'AAPL': MarketSector.technology,
  'MSFT': MarketSector.technology,
  'GOOGL': MarketSector.technology,
  'GOOG': MarketSector.technology,
  'AMZN': MarketSector.technology,
  'META': MarketSector.technology,
  'NVDA': MarketSector.technology,
  'TSLA': MarketSector.technology,
  'AMD': MarketSector.technology,
  'INTC': MarketSector.technology,
  'CRM': MarketSector.technology,
  'ADBE': MarketSector.technology,
  'NFLX': MarketSector.technology,
  'CSCO': MarketSector.technology,
  'ORCL': MarketSector.technology,
  'IBM': MarketSector.technology,
  'QCOM': MarketSector.technology,
  'TXN': MarketSector.technology,
  'AVGO': MarketSector.technology,
  'MU': MarketSector.technology,
  // Finance
  'JPM': MarketSector.finance,
  'BAC': MarketSector.finance,
  'C': MarketSector.finance,
  'GS': MarketSector.finance,
  'MS': MarketSector.finance,
  'WFC': MarketSector.finance,
  'AXP': MarketSector.finance,
  'V': MarketSector.finance,
  'MA': MarketSector.finance,
  'BLK': MarketSector.finance,
  'SCHW': MarketSector.finance,
  'PYPL': MarketSector.finance,
  // Healthcare
  'JNJ': MarketSector.healthcare,
  'PFE': MarketSector.healthcare,
  'UNH': MarketSector.healthcare,
  'ABBV': MarketSector.healthcare,
  'MRK': MarketSector.healthcare,
  'ABT': MarketSector.healthcare,
  'LLY': MarketSector.healthcare,
  'MDT': MarketSector.healthcare,
  'BMY': MarketSector.healthcare,
  'AMGN': MarketSector.healthcare,
  // Consumer Staples
  'KO': MarketSector.consumerStaples,
  'PEP': MarketSector.consumerStaples,
  'PG': MarketSector.consumerStaples,
  'WMT': MarketSector.consumerStaples,
  'COST': MarketSector.consumerStaples,
  'MO': MarketSector.consumerStaples,
  'CL': MarketSector.consumerStaples,
  'KMB': MarketSector.consumerStaples,
  'SYY': MarketSector.consumerStaples,
  'GIS': MarketSector.consumerStaples,
  // Energy
  'XOM': MarketSector.energy,
  'CVX': MarketSector.energy,
  'COP': MarketSector.energy,
  'EOG': MarketSector.energy,
  'SLB': MarketSector.energy,
  'OXY': MarketSector.energy,
  'MPC': MarketSector.energy,
  'PSX': MarketSector.energy,
  'BP': MarketSector.energy,
  'SHEL': MarketSector.energy,
  'ECL': MarketSector.energy,
  // Real Estate
  'PLD': MarketSector.realEstate,
  'AMT': MarketSector.realEstate,
  'CCI': MarketSector.realEstate,
  'EQIX': MarketSector.realEstate,
  'PSA': MarketSector.realEstate,
  'O': MarketSector.realEstate,
  'SPG': MarketSector.realEstate,
  'WELL': MarketSector.realEstate,
  // Biotech
  'BIIB': MarketSector.biotech,
  'GILD': MarketSector.biotech,
  'MRNA': MarketSector.biotech,
  'ILMN': MarketSector.biotech,
  'VRTX': MarketSector.biotech,
  // Cyclical
  'WHR': MarketSector.cyclical,
  'HPQ': MarketSector.cyclical,
  'HMC': MarketSector.cyclical,
  'CAT': MarketSector.cyclical,
  'DE': MarketSector.cyclical,
  'FCX': MarketSector.cyclical,
  'X': MarketSector.cyclical,
  'NEM': MarketSector.cyclical,
  'CLF': MarketSector.cyclical,
  // ── ETF Broad Market ───────────────────────────────────────────
  'SPY': MarketSector.other,
  'QQQ': MarketSector.other,
  'DIA': MarketSector.other,
  'IWM': MarketSector.other,
  'VTI': MarketSector.other,
  'VOO': MarketSector.other,
  'IVV': MarketSector.other,
  'SCHB': MarketSector.other,
  'ITOT': MarketSector.other,
  'VEA': MarketSector.other,
  'VWO': MarketSector.other,
  'AGG': MarketSector.other,
  'BND': MarketSector.other,
};

// _symbolAssetSectorMap removed — canonical mapping lives in resolveAssetSector()
// (stress_test_models.dart) which is the Single Source of Truth (SSOT).
