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
// With dt=0.005: 200 ticks ≈ 1 simulated period (~67 min gameplay).
//   Bull KO:     ±0.06% after 15 min (45 ticks)
//   Spec KO:     ±0.8%  after 15 min (1σ), ±2.4% worst-case (3σ)
//   Spec AMD:    ±1.1%  after 15 min (1σ), ±3.3% worst-case (3σ)
const double _dtPerTick = 0.005;

/// Whether we've already printed the dt calibration header this session.
bool _dtCalibrationLogged = false;

/// Precomputed sqrt(_dtPerTick) to avoid calling sqrt() on every tick.
final double _sqrtDt = _sqrtDtCompute();

double _sqrtDtCompute() => sqrt(_dtPerTick);

// ---------------------------------------------------------------------------
// Definitive Market Simulation Matrix — Multi-Sector & Multi-Scenario
// ---------------------------------------------------------------------------
//
// Every asset is classified into an [AssetSector]. Drift (μ) and Volatility (σ)
// are ANNUALIZED values strictly determined by the active [MarketScenario].
//
// GBM formula (per tick, dt = 0.005):
//   P_new = P_old × (1 + μ×dt + σ×ε×√dt + microNoise×ε₂×√dt)
//   where ε ~ Uniform(-0.5, +0.5)
//
// Micro-noise is sector-aware: reduced by 75% for ETFs for smooth charts.

/// Internal 5-scenario classification that maps MarketScenario → matrix row.
enum _MacroRegime { sideways, speculation, volatility, bull, bear }

/// Maps a [MarketScenario] to its [_MacroRegime] for matrix lookup.
/// ── Block 5: hype/speculation are no longer global regimes ────
/// They now operate as per-company bell-shape events (see _maybeFireSpecEvent).
/// When a test rolls hype/speculation as a global scenario, it behaves like
/// sideways — the company events do the actual price impact.
_MacroRegime _toMacroRegime(MarketScenario s) => switch (s) {
  MarketScenario.sideways ||
  MarketScenario.recovery ||
  MarketScenario.hype ||
  MarketScenario.speculation => _MacroRegime.sideways,
  MarketScenario.volatility => _MacroRegime.volatility,
  MarketScenario.bull => _MacroRegime.bull,
  MarketScenario.bear ||
  MarketScenario.blackSwan ||
  MarketScenario.crash => _MacroRegime.bear,
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
/// | BEAR          | techSpeculative   | -0.45      | 0.50       |
/// |               | consumerStaples   | -0.05      | 0.12       |
/// |               | cyclicalConsumer  | -0.30      | 0.30       |
/// |               | realEstateREIT    | -0.15      | 0.18       |
/// |               | etfBroadMarket    | -0.22      | 0.20       |
const Map<_MacroRegime, Map<AssetSector, _SectorParams>> _masterMatrix = {
  _MacroRegime.sideways: {
    AssetSector.techSpeculative: _SectorParams(0.00, 0.06),
    AssetSector.consumerStaples: _SectorParams(0.01, 0.02),
    AssetSector.cyclicalConsumer: _SectorParams(0.00, 0.04),
    AssetSector.realEstateREIT: _SectorParams(0.02, 0.02),
    AssetSector.etfBroadMarket: _SectorParams(0.00, 0.03),
  },
  _MacroRegime.speculation: {
    AssetSector.techSpeculative: _SectorParams(0.40, 0.45),
    AssetSector.consumerStaples: _SectorParams(0.02, 0.06),
    AssetSector.cyclicalConsumer: _SectorParams(0.15, 0.20),
    AssetSector.realEstateREIT: _SectorParams(-0.05, 0.08),
    AssetSector.etfBroadMarket: _SectorParams(0.10, 0.15),
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
  _MacroRegime.bear: {
    AssetSector.techSpeculative: _SectorParams(-0.45, 0.50),
    AssetSector.consumerStaples: _SectorParams(-0.05, 0.12),
    AssetSector.cyclicalConsumer: _SectorParams(-0.30, 0.30),
    AssetSector.realEstateREIT: _SectorParams(-0.15, 0.18),
    AssetSector.etfBroadMarket: _SectorParams(-0.22, 0.20),
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
  _MacroRegime.speculation: _DriftBounds(
    -0.08,
    0.08,
    maxPriceMultiplier: 2.5,
    minPriceMultiplier: 0.2,
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
  _MacroRegime.bear: _DriftBounds(
    -0.06,
    0.03,
    maxPriceMultiplier: 1.3,
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
