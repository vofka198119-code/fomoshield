// ---------------------------------------------------------------------------
// Stress Test Simulation — standalone run for portfolio verification
// Replicates the core simulation logic from stress_test_engine.dart
// ---------------------------------------------------------------------------
import 'dart:math';

// ── Market Sector & Scenario (mirrors stress_test_models.dart) ──────────────

enum MarketSector {
  technology,
  finance,
  healthcare,
  consumerStaples,
  energy,
  realEstate,
  biotech,
  cyclical,
  other,
}

enum MarketScenario {
  bull,
  bear,
  recovery,
  hype,
  speculation,
  blackSwan,
  crash;

  bool get isCatastrophe =>
      this == MarketScenario.blackSwan || this == MarketScenario.crash;
}

// ── Sector Behavior ─────────────────────────────────────────────────────────

class _SectorBehavior {
  final double drift;
  final double volatility;
  const _SectorBehavior(this.drift, this.volatility);
}

// ── Symbol → Sector map (copied from stress_test_engine.dart) ───────────────

MarketSector _getSector(String symbol) {
  const map = <String, MarketSector>{
    'AAPL': MarketSector.technology, 'MSFT': MarketSector.technology,
    'GOOGL': MarketSector.technology, 'GOOG': MarketSector.technology,
    'AMZN': MarketSector.technology, 'META': MarketSector.technology,
    'NVDA': MarketSector.technology, 'TSLA': MarketSector.technology,
    'AMD': MarketSector.technology, 'INTC': MarketSector.technology,
    'CRM': MarketSector.technology, 'ADBE': MarketSector.technology,
    'NFLX': MarketSector.technology, 'CSCO': MarketSector.technology,
    'ORCL': MarketSector.technology, 'IBM': MarketSector.technology,
    'QCOM': MarketSector.technology, 'TXN': MarketSector.technology,
    'AVGO': MarketSector.technology, 'MU': MarketSector.technology,
    'JPM': MarketSector.finance, 'BAC': MarketSector.finance,
    'C': MarketSector.finance, 'GS': MarketSector.finance,
    'MS': MarketSector.finance, 'WFC': MarketSector.finance,
    'AXP': MarketSector.finance, 'V': MarketSector.finance,
    'MA': MarketSector.finance, 'BLK': MarketSector.finance,
    'SCHW': MarketSector.finance, 'PYPL': MarketSector.finance,
    'JNJ': MarketSector.healthcare, 'PFE': MarketSector.healthcare,
    'UNH': MarketSector.healthcare, 'ABBV': MarketSector.healthcare,
    'MRK': MarketSector.healthcare, 'ABT': MarketSector.healthcare,
    'LLY': MarketSector.healthcare, 'MDT': MarketSector.healthcare,
    'BMY': MarketSector.healthcare, 'AMGN': MarketSector.healthcare,
    'KO': MarketSector.consumerStaples, 'PEP': MarketSector.consumerStaples,
    'PG': MarketSector.consumerStaples, 'WMT': MarketSector.consumerStaples,
    'COST': MarketSector.consumerStaples, 'MO': MarketSector.consumerStaples,
    'CL': MarketSector.consumerStaples, 'KMB': MarketSector.consumerStaples,
    'SYY': MarketSector.consumerStaples, 'GIS': MarketSector.consumerStaples,
    'XOM': MarketSector.energy, 'CVX': MarketSector.energy,
    'COP': MarketSector.energy, 'EOG': MarketSector.energy,
    'SLB': MarketSector.energy, 'OXY': MarketSector.energy,
    'MPC': MarketSector.energy, 'PSX': MarketSector.energy,
    'BP': MarketSector.energy, 'SHEL': MarketSector.energy,
    'PLD': MarketSector.realEstate, 'AMT': MarketSector.realEstate,
    'CCI': MarketSector.realEstate, 'EQIX': MarketSector.realEstate,
    'PSA': MarketSector.realEstate, 'O': MarketSector.realEstate,
    'SPG': MarketSector.realEstate, 'WELL': MarketSector.realEstate,
    // Biotech
    'BIIB': MarketSector.biotech, 'GILD': MarketSector.biotech,
    'MRNA': MarketSector.biotech, 'ILMN': MarketSector.biotech,
    'VRTX': MarketSector.biotech,
    // Cyclical
    'WHR': MarketSector.cyclical, 'HPQ': MarketSector.cyclical,
    'HMC': MarketSector.cyclical, 'CAT': MarketSector.cyclical,
    'DE': MarketSector.cyclical, 'FCX': MarketSector.cyclical,
    'X': MarketSector.cyclical, 'NEM': MarketSector.cyclical,
    'CLF': MarketSector.cyclical,
  };
  return map[symbol] ?? MarketSector.other;
}

// ── Sector Behaviors per Scenario (Task 1.8 calibrated) ──────────────────

const Map<MarketScenario, Map<MarketSector, _SectorBehavior>> _sectorBehaviors =
    {
      MarketScenario.bull: {
        MarketSector.technology: _SectorBehavior(0.008, 0.010),
        MarketSector.finance: _SectorBehavior(0.007, 0.008),
        MarketSector.healthcare: _SectorBehavior(0.005, 0.005),
        MarketSector.consumerStaples: _SectorBehavior(0.003, 0.004),
        MarketSector.energy: _SectorBehavior(0.007, 0.012),
        MarketSector.realEstate: _SectorBehavior(0.006, 0.007),
        MarketSector.biotech: _SectorBehavior(0.003, 0.010),
        MarketSector.cyclical: _SectorBehavior(0.008, 0.010),
        MarketSector.other: _SectorBehavior(0.005, 0.006),
      },
      MarketScenario.bear: {
        MarketSector.technology: _SectorBehavior(-0.012, 0.010),
        MarketSector.finance: _SectorBehavior(-0.013, 0.010),
        MarketSector.healthcare: _SectorBehavior(-0.007, 0.006),
        MarketSector.consumerStaples: _SectorBehavior(-0.005, 0.005),
        MarketSector.energy: _SectorBehavior(-0.011, 0.012),
        MarketSector.realEstate: _SectorBehavior(-0.013, 0.010),
        MarketSector.biotech: _SectorBehavior(-0.014, 0.012),
        MarketSector.cyclical: _SectorBehavior(-0.014, 0.012),
        MarketSector.other: _SectorBehavior(-0.010, 0.008),
      },
      MarketScenario.recovery: {
        MarketSector.technology: _SectorBehavior(0.025, 0.012),
        MarketSector.finance: _SectorBehavior(0.022, 0.012),
        MarketSector.healthcare: _SectorBehavior(0.025, 0.010),
        MarketSector.consumerStaples: _SectorBehavior(0.018, 0.008),
        MarketSector.energy: _SectorBehavior(0.023, 0.014),
        MarketSector.realEstate: _SectorBehavior(0.020, 0.012),
        MarketSector.biotech: _SectorBehavior(0.022, 0.016),
        MarketSector.cyclical: _SectorBehavior(0.025, 0.014),
        MarketSector.other: _SectorBehavior(0.022, 0.012),
      },
      MarketScenario.hype: {
        MarketSector.technology: _SectorBehavior(0.085, 0.040),
        MarketSector.finance: _SectorBehavior(0.010, 0.012),
        MarketSector.healthcare: _SectorBehavior(-0.003, 0.010),
        MarketSector.consumerStaples: _SectorBehavior(-0.005, 0.008),
        MarketSector.energy: _SectorBehavior(0.015, 0.018),
        MarketSector.realEstate: _SectorBehavior(0.005, 0.012),
        MarketSector.biotech: _SectorBehavior(0.065, 0.045),
        MarketSector.cyclical: _SectorBehavior(0.030, 0.025),
        MarketSector.other: _SectorBehavior(0.005, 0.012),
      },
      MarketScenario.speculation: {
        MarketSector.technology: _SectorBehavior(0.000, 0.080),
        MarketSector.finance: _SectorBehavior(0.000, 0.075),
        MarketSector.healthcare: _SectorBehavior(0.000, 0.065),
        MarketSector.consumerStaples: _SectorBehavior(0.000, 0.055),
        MarketSector.energy: _SectorBehavior(0.000, 0.090),
        MarketSector.realEstate: _SectorBehavior(0.000, 0.065),
        MarketSector.biotech: _SectorBehavior(0.000, 0.090),
        MarketSector.cyclical: _SectorBehavior(0.000, 0.085),
        MarketSector.other: _SectorBehavior(0.000, 0.065),
      },
      MarketScenario.blackSwan: {
        MarketSector.technology: _SectorBehavior(-0.300, 0.090),
        MarketSector.finance: _SectorBehavior(-0.320, 0.085),
        MarketSector.healthcare: _SectorBehavior(-0.250, 0.065),
        MarketSector.consumerStaples: _SectorBehavior(-0.230, 0.055),
        MarketSector.energy: _SectorBehavior(-0.280, 0.100),
        MarketSector.realEstate: _SectorBehavior(-0.340, 0.085),
        MarketSector.biotech: _SectorBehavior(-0.310, 0.100),
        MarketSector.cyclical: _SectorBehavior(-0.340, 0.085),
        MarketSector.other: _SectorBehavior(-0.280, 0.085),
      },
      MarketScenario.crash: {
        MarketSector.technology: _SectorBehavior(-0.115, 0.040),
        MarketSector.finance: _SectorBehavior(-0.120, 0.035),
        MarketSector.healthcare: _SectorBehavior(-0.100, 0.025),
        MarketSector.consumerStaples: _SectorBehavior(-0.090, 0.020),
        MarketSector.energy: _SectorBehavior(-0.110, 0.045),
        MarketSector.realEstate: _SectorBehavior(-0.125, 0.035),
        MarketSector.biotech: _SectorBehavior(-0.120, 0.045),
        MarketSector.cyclical: _SectorBehavior(-0.125, 0.035),
        MarketSector.other: _SectorBehavior(-0.105, 0.035),
      },
    };

// ── Scenario Rolling ────────────────────────────────────────────────────────

final Map<MarketScenario, int> _scenarioWeights = {
  MarketScenario.bull: 52,
  MarketScenario.bear: 4,
  MarketScenario.hype: 14,
  MarketScenario.speculation: 14,
  MarketScenario.recovery: 5,
  MarketScenario.blackSwan: 4,
  MarketScenario.crash: 4,
};

MarketScenario _rollScenario(
  Random rng,
  int cooldown,
  int declineStreak, {
  bool allowCatastrophe = true,
}) {
  if (declineStreak >= 2) {
    return rng.nextDouble() < 0.6
        ? MarketScenario.bull
        : MarketScenario.speculation;
  }

  final pool = [..._scenarioWeights.keys];
  List<int> weights;

  if (cooldown > 0 || !allowCatastrophe) {
    pool.removeWhere((s) => s.isCatastrophe);
    weights = pool.map((s) => _scenarioWeights[s]!).toList();
    // Redistribute catastrophe weight to recovery and bull
    int catWeight = 0;
    for (final s in MarketScenario.values) {
      if (s.isCatastrophe) catWeight += (_scenarioWeights[s] ?? 0);
    }
    final redistBull = (catWeight * 0.6).round();
    final redistRecovery = catWeight - redistBull;
    final bullIdx = pool.indexOf(MarketScenario.bull);
    final recIdx = pool.indexOf(MarketScenario.recovery);
    if (bullIdx >= 0) weights[bullIdx] += redistBull;
    if (recIdx >= 0) weights[recIdx] += redistRecovery;
  } else {
    weights = pool.map((s) => _scenarioWeights[s]!).toList();
  }

  final totalWeight = weights.fold(0, (a, b) => a + b);
  int roll = rng.nextInt(totalWeight);
  for (int i = 0; i < pool.length; i++) {
    roll -= weights[i];
    if (roll < 0) return pool[i];
  }
  return MarketScenario.bull;
}

// ── Price Simulation ────────────────────────────────────────────────────────

double _simulatePrice(
  double currentPrice,
  double basePrice,
  MarketScenario scenario,
  MarketSector sector,
  Random rng,
  Map<String, double> bounceMap,
  String symbol,
) {
  // Apply pending bounce from a previous correction
  if (bounceMap.containsKey(symbol)) {
    currentPrice *= (1 + bounceMap[symbol]!);
    currentPrice = currentPrice.clamp(basePrice * 0.3, basePrice * 3.0);
    bounceMap.remove(symbol);
  }

  final behaviors = _sectorBehaviors[scenario] ?? {};
  final behavior = behaviors[sector] ?? const _SectorBehavior(0.0, 0.015);

  final effectiveDrift = behavior.drift;
  final effectiveVol = behavior.volatility;
  final noise = (rng.nextDouble() - 0.5) * effectiveVol * 0.3;

  double price = currentPrice * (1 + effectiveDrift / 24 + noise);
  price = price.clamp(basePrice * 0.3, basePrice * 3.0);

  // Micro-corrections — scenario-aware, realistic magnitudes (Task 1.8)
  double correctionProb, correctionMin, correctionMax;
  if (scenario.isCatastrophe) {
    correctionProb = 0.005;
    correctionMin = 0.005;
    correctionMax = 0.015;
  } else if (scenario == MarketScenario.hype) {
    switch (sector) {
      case MarketSector.technology:
      case MarketSector.biotech:
        correctionProb = 0.030;
        correctionMin = 0.03;
        correctionMax = 0.08;
      case MarketSector.cyclical:
        correctionProb = 0.015;
        correctionMin = 0.02;
        correctionMax = 0.05;
      default:
        correctionProb = 0.005;
        correctionMin = 0.005;
        correctionMax = 0.02;
    }
  } else if (scenario == MarketScenario.speculation) {
    correctionProb = 0.015;
    correctionMin = 0.02;
    correctionMax = 0.05;
  } else {
    switch (sector) {
      case MarketSector.technology:
      case MarketSector.energy:
        correctionProb = 0.008;
        correctionMin = 0.005;
        correctionMax = 0.02;
      case MarketSector.finance:
      case MarketSector.realEstate:
        correctionProb = 0.006;
        correctionMin = 0.005;
        correctionMax = 0.02;
      case MarketSector.healthcare:
      case MarketSector.consumerStaples:
      case MarketSector.other:
        correctionProb = 0.004;
        correctionMin = 0.003;
        correctionMax = 0.015;
      case MarketSector.biotech:
        correctionProb = 0.012;
        correctionMin = 0.01;
        correctionMax = 0.03;
      case MarketSector.cyclical:
        correctionProb = 0.015;
        correctionMin = 0.01;
        correctionMax = 0.03;
    }
  }
  if (rng.nextDouble() < correctionProb) {
    final correction =
        correctionMin + rng.nextDouble() * (correctionMax - correctionMin);
    price *= (1 - correction);
    price = price.clamp(basePrice * 0.3, basePrice * 3.0);
    // Schedule bounce recovery for next epoch (realistic 0.5-5%)
    double bounceRate;
    switch (sector) {
      case MarketSector.consumerStaples:
      case MarketSector.healthcare:
        bounceRate = 0.010 + rng.nextDouble() * 0.020; // 1-3%
      case MarketSector.technology:
        bounceRate = 0.020 + rng.nextDouble() * 0.030; // 2-5%
      case MarketSector.finance:
      case MarketSector.realEstate:
        bounceRate = 0.010 + rng.nextDouble() * 0.020; // 1-3%
      case MarketSector.energy:
        bounceRate = 0.015 + rng.nextDouble() * 0.020; // 1.5-3.5%
      case MarketSector.biotech:
        bounceRate = 0.005 + rng.nextDouble() * 0.010; // 0.5-1.5%
      case MarketSector.cyclical:
        bounceRate = 0.010 + rng.nextDouble() * 0.020; // 1-3%
      default:
        bounceRate = 0.010 + rng.nextDouble() * 0.015; // 1-2.5%
    }
    bounceMap[symbol] = bounceRate;
  }

  return price;
}

// ── Trade Record (for P&L tracking) ────────────────────────────────────────

class _TradeRecord {
  final int epoch;
  final String symbol;
  final bool isBuy;
  final double shares;
  final double price;
  final double? realizedPnl; // null for buys
  _TradeRecord({
    required this.epoch,
    required this.symbol,
    required this.isBuy,
    required this.shares,
    required this.price,
    this.realizedPnl,
  });
}

// ── Main Simulation ─────────────────────────────────────────────────────────

void main() {
  // Test durations: change this to test different lengths
  // week=19, month=60, months3=90, infinite=156
  const String testMode = 'month'; // 'week', 'month', 'months3', 'infinite'

  // ── Random seed — новый прогон каждый раз ──
  final rng = Random();
  const double startingCash = 5000.0;

  // ── Portfolio Setup — 15 companies, unequal weights ──
  // Biotech 30% ($1500) · Cyclical 40% ($2000) · Benchmark 30% ($1500)
  final Map<String, double> entryPrices = {
    // 🧬 BIOTECH (30%) — вечно падающий сектор
    'BIIB': 215.0, // $350  (7%) — Biotech
    'GILD': 68.0, // $300  (6%) — Biotech
    'MRNA': 85.0, // $300  (6%) — Biotech
    'ILMN': 120.0, // $300  (6%) — Biotech
    'VRTX': 420.0, // $250  (5%) — Biotech
    // 🔄 CYCLICAL (40%) — год взлёта, 5 лет падения
    'WHR': 110.0, // $400  (8%) — Cyclical
    'HPQ': 30.0, // $350  (7%) — Cyclical
    'HMC': 32.0, // $350  (7%) — Cyclical
    'CAT': 340.0, // $300  (6%) — Cyclical
    'DE': 400.0, // $300  (6%) — Cyclical
    'FCX': 45.0, // $300  (6%) — Cyclical
    // 📊 BENCHMARK (30%) — для сравнения
    'KO': 80.0, // $400  (8%) — Consumer Staples
    'JPM': 200.0, // $350  (7%) — Finance
    'MSFT': 376.0, // $300  (6%) — Technology
    'XOM': 115.0, // $350  (7%) — Energy
  };

  final Map<String, double> positionAmounts = {
    'BIIB': 350.0,
    'GILD': 300.0,
    'MRNA': 300.0,
    'ILMN': 300.0,
    'VRTX': 250.0,
    'WHR': 400.0,
    'HPQ': 350.0,
    'HMC': 350.0,
    'CAT': 300.0,
    'DE': 300.0,
    'FCX': 300.0,
    'KO': 400.0,
    'JPM': 350.0,
    'MSFT': 300.0,
    'XOM': 350.0,
  };

  final Map<String, double> shares = {};
  double totalInvested = 0;
  for (final e in entryPrices.entries) {
    final amount = positionAmounts[e.key]!;
    shares[e.key] = amount / e.value;
    totalInvested += amount;
  }

  final cash = startingCash - totalInvested;

  // ── Generate Epochs based on test mode ──
  final int totalEpochs = switch (testMode) {
    'week' => 19,
    'month' => 60,
    'months3' => 90,
    'infinite' => 780,
    _ => 60,
  };
  final String durationLabel = switch (testMode) {
    'week' => '1 WEEK (19 epochs × 9h = ~7 days)',
    'month' => '1 MONTH (60 epochs × 12h = 30 days)',
    'months3' => '3 MONTHS (90 epochs × 24h = 90 days)',
    'infinite' => 'INFINITE (780 epochs × weekdays only = ~3 yr trading)',
    _ => 'UNKNOWN',
  };

  print(
    '╔════════════════════════════════════════════════════════════════════╗',
  );
  print('║       STRESS TEST — $durationLabel');
  print(
    '║       Buy & Hold · 15 positions · bio+cyclical test               ║',
  );
  print(
    '╚════════════════════════════════════════════════════════════════════╝',
  );
  print('');
  print('PORTFOLIO SETUP');
  print('───────────────');
  print('Starting Cash: \$${startingCash.toStringAsFixed(2)}');
  print('');
  print('  🧬 BIOTECH (30%) — вечно падающий сектор');
  double bioTotal = 0;
  for (final sym in ['BIIB', 'GILD', 'MRNA', 'ILMN', 'VRTX']) {
    final e = entryPrices[sym]!;
    final amt = positionAmounts[sym]!;
    bioTotal += amt;
    final pct = (amt / startingCash * 100).toStringAsFixed(0);
    print(
      '    ${sym.padRight(6)} \$${e.toStringAsFixed(2)} × ${shares[sym]!.toStringAsFixed(2)} shares'
      ' = \$${amt.toStringAsFixed(2)}  (${pct}%)  [${_getSector(sym).name}]',
    );
  }
  print('    ─────────────────────────────────────────────────');
  print('    Biotech subtotal: \$${bioTotal.toStringAsFixed(2)}');
  print('');
  print('  🔄 CYCLICAL (40%) — год взлёта, 5 лет падения');
  double cycTotal = 0;
  for (final sym in ['WHR', 'HPQ', 'HMC', 'CAT', 'DE', 'FCX']) {
    final e = entryPrices[sym]!;
    final amt = positionAmounts[sym]!;
    cycTotal += amt;
    final pct = (amt / startingCash * 100).toStringAsFixed(0);
    print(
      '    ${sym.padRight(6)} \$${e.toStringAsFixed(2)} × ${shares[sym]!.toStringAsFixed(2)} shares'
      ' = \$${amt.toStringAsFixed(2)}  (${pct}%)  [${_getSector(sym).name}]',
    );
  }
  print('    ─────────────────────────────────────────────────');
  print('    Cyclical subtotal: \$${cycTotal.toStringAsFixed(2)}');
  print('');
  print('  📊 BENCHMARK (30%) — для сравнения');
  double benchTotal = 0;
  for (final sym in ['KO', 'JPM', 'MSFT', 'XOM']) {
    final e = entryPrices[sym]!;
    final amt = positionAmounts[sym]!;
    benchTotal += amt;
    final pct = (amt / startingCash * 100).toStringAsFixed(0);
    print(
      '    ${sym.padRight(6)} \$${e.toStringAsFixed(2)} × ${shares[sym]!.toStringAsFixed(2)} shares'
      ' = \$${amt.toStringAsFixed(2)}  (${pct}%)  [${_getSector(sym).name}]',
    );
  }
  print('    ─────────────────────────────────────────────────');
  print('    Benchmark subtotal: \$${benchTotal.toStringAsFixed(2)}');
  print('');
  print('  TOTAL INVESTED: \$${totalInvested.toStringAsFixed(2)}');
  print('  CASH REMAINING: \$${cash.toStringAsFixed(2)}');
  print('');

  // ── Generate Scenario Sequence ──
  final List<MarketScenario> epochs = [];

  int catastropheCooldown = 0;
  int declineStreak = 0;
  int catastropheCount = 0;
  final int maxCatastrophes = switch (testMode) {
    'week' => 0,
    'month' => 1,
    'months3' => 2,
    'infinite' => 3,
    _ => 1,
  };
  final bool isFinite = testMode != 'infinite';

  // Infinite mode: начинаем с понедельника
  DateTime _epochCursor = DateTime(2026, 6, 29); // Monday
  int _epochIndex = 0;

  while (_epochIndex < totalEpochs) {
    // Infinite: skip weekends
    if (!isFinite &&
        (_epochCursor.weekday == DateTime.saturday ||
            _epochCursor.weekday == DateTime.sunday)) {
      _epochCursor = _epochCursor.add(const Duration(days: 1));
      continue;
    }

    final allowCatastrophe = isFinite
        ? (catastropheCount < 1)
        : (catastropheCount < maxCatastrophes);
    final scenario = _rollScenario(
      rng,
      catastropheCooldown,
      declineStreak,
      allowCatastrophe: allowCatastrophe,
    );
    if (scenario == MarketScenario.blackSwan ||
        scenario == MarketScenario.crash) {
      catastropheCount++;
      catastropheCooldown = 2;
      declineStreak = 0;
    } else if (scenario == MarketScenario.bear) {
      declineStreak++;
    } else {
      declineStreak = 0;
      if (catastropheCooldown > 0) catastropheCooldown--;
    }
    epochs.add(scenario);
    _epochIndex++;
    _epochCursor = _epochCursor.add(const Duration(days: 1));
  }

  // ── Track per-position prices ──
  final Map<String, double> prices = Map.from(entryPrices);
  final Map<String, double> basePrices = Map.from(entryPrices);
  final Map<String, List<double>> priceHistory = {};
  final Map<String, double> positionMin = {};
  final Map<String, double> positionMax = {};
  for (final sym in entryPrices.keys) {
    priceHistory[sym] = [entryPrices[sym]!];
    positionMin[sym] = entryPrices[sym]!;
    positionMax[sym] = entryPrices[sym]!;
  }

  // Epoch-by-epoch scenario log
  final Map<int, MarketScenario> scenarioLog = {};
  final Map<String, double> bounceMap = {}; // tracks correction bounces

  // ── Trading simulation state ─────────────────────────────────────────────
  // P&L tracking: shares owned, avg cost, realized P&L, trade log
  final Map<String, double> dynShares = Map<String, double>.from(shares);
  final Map<String, double> dynAvgCost = Map<String, double>.from(entryPrices);
  final Map<String, double> runningHigh = Map<String, double>.from(entryPrices);
  final Map<String, double> runningLow = Map<String, double>.from(entryPrices);
  final Map<String, int> dipBuyEpoch = {}; // epoch when we last bought a dip
  double dynCash = cash;
  final List<_TradeRecord> trades = [];
  double totalRealizedPnl = 0;

  // Symbols to actively trade (high volatility — biotech + cyclical)
  const activeTradeSymbols = {
    'BIIB',
    'MRNA',
    'WHR',
    'FCX',
    'HPQ',
    'ILMN',
    'CAT',
  };

  for (int ep = 0; ep < totalEpochs; ep++) {
    final scenario = epochs[ep];
    scenarioLog[ep] = scenario;

    for (final sym in entryPrices.keys) {
      final sector = _getSector(sym);
      final oldPrice = prices[sym]!;
      final newPrice = _simulatePrice(
        oldPrice,
        basePrices[sym]!,
        scenario,
        sector,
        rng,
        bounceMap,
        sym,
      );

      // Track corrections

      prices[sym] = newPrice;
      priceHistory[sym]!.add(newPrice);
      if (newPrice < positionMin[sym]!) positionMin[sym] = newPrice;
      if (newPrice > positionMax[sym]!) positionMax[sym] = newPrice;

      // ── Running high/low for active trade symbols ──
      if (activeTradeSymbols.contains(sym)) {
        if (newPrice > runningHigh[sym]!) runningHigh[sym] = newPrice;
        if (newPrice < runningLow[sym]!) runningLow[sym] = newPrice;

        final range = runningHigh[sym]! - runningLow[sym]!;
        final pctFromHigh = (runningHigh[sym]! - newPrice) / runningHigh[sym]!;
        final pctFromAvg = (newPrice - dynAvgCost[sym]!) / dynAvgCost[sym]!;
        final currentValue = dynShares[sym]! * newPrice;

        // ── FOMO buy: price near peak (>80% of range) ──
        // Человек видит, что акция растёт, покупает на хайте
        if (range > 0 &&
            ep > 5 &&
            newPrice >= runningLow[sym]! + range * 0.80 &&
            newPrice > runningHigh[sym]! * 0.95 &&
            dynCash > 150 &&
            currentValue < dynCash * 1.5) {
          final fomoAmount = 100.0 + rng.nextDouble() * 150.0; // $100-250
          final actualAmount = fomoAmount < dynCash
              ? fomoAmount
              : dynCash * 0.3;
          if (actualAmount >= 50) {
            final buyShares = actualAmount / newPrice;
            final totalCost = dynShares[sym]! * dynAvgCost[sym]! + actualAmount;
            dynCash -= actualAmount;
            dynShares[sym] = dynShares[sym]! + buyShares;
            dynAvgCost[sym] = totalCost / dynShares[sym]!;
            trades.add(
              _TradeRecord(
                epoch: ep,
                symbol: sym,
                isBuy: true,
                shares: buyShares,
                price: newPrice,
              ),
            );
          }
        }

        // ── Dip buy: price dropped >12% from running high ──
        // Человек докупает после просадки
        if (pctFromHigh > 0.12 &&
            ep > 3 &&
            dynCash > 100 &&
            !dipBuyEpoch.containsKey(sym)) {
          final dipAmount = 80.0 + rng.nextDouble() * 120.0; // $80-200
          final actualAmount = dipAmount < dynCash ? dipAmount : dynCash * 0.25;
          if (actualAmount >= 50) {
            final buyShares = actualAmount / newPrice;
            final totalCost = dynShares[sym]! * dynAvgCost[sym]! + actualAmount;
            dynCash -= actualAmount;
            dynShares[sym] = dynShares[sym]! + buyShares;
            dynAvgCost[sym] = totalCost / dynShares[sym]!;
            dipBuyEpoch[sym] = ep;
            trades.add(
              _TradeRecord(
                epoch: ep,
                symbol: sym,
                isBuy: true,
                shares: buyShares,
                price: newPrice,
              ),
            );
          }
        }

        // ── Profit sell: after dip buy, price recovers >8% above avg cost ──
        // Купил на просадке, продал часть когда отскочило
        if (dipBuyEpoch.containsKey(sym) &&
            pctFromAvg > 0.08 &&
            dynShares[sym]! > 0.5) {
          final sellRatio = 0.3 + rng.nextDouble() * 0.3; // sell 30-60%
          final sellShares = dynShares[sym]! * sellRatio;
          final revenue = sellShares * newPrice;
          final costBasis = sellShares * dynAvgCost[sym]!;
          final realizedPnl = revenue - costBasis;
          totalRealizedPnl += realizedPnl;
          dynCash += revenue;
          dynShares[sym] = dynShares[sym]! - sellShares;
          dipBuyEpoch.remove(sym);
          trades.add(
            _TradeRecord(
              epoch: ep,
              symbol: sym,
              isBuy: false,
              shares: sellShares,
              price: newPrice,
              realizedPnl: realizedPnl,
            ),
          );
        }

        // ── FOMO sell: price at new high, take profit ──
        // Купил на хайте, продал когда ещё выше — взял прибыль
        if (ep > 10 &&
            newPrice >= runningHigh[sym]! * 0.98 &&
            pctFromAvg > 0.12 &&
            dynShares[sym]! > 0.3) {
          final sellRatio = 0.2 + rng.nextDouble() * 0.2; // sell 20-40%
          final sellShares = dynShares[sym]! * sellRatio;
          final revenue = sellShares * newPrice;
          final costBasis = sellShares * dynAvgCost[sym]!;
          final realizedPnl = revenue - costBasis;
          totalRealizedPnl += realizedPnl;
          dynCash += revenue;
          dynShares[sym] = dynShares[sym]! - sellShares;
          trades.add(
            _TradeRecord(
              epoch: ep,
              symbol: sym,
              isBuy: false,
              shares: sellShares,
              price: newPrice,
              realizedPnl: realizedPnl,
            ),
          );
        }
      }
    }
  }

  // ── RESULTS ──
  print('EPOCH GENERATION ($totalEpochs epochs)');
  print('─────────────────────────────────────────────');

  // Scenario distribution
  final counts = <MarketScenario, int>{};
  for (final s in epochs) {
    counts[s] = (counts[s] ?? 0) + 1;
  }
  for (final e in counts.entries) {
    final pct = (e.value / totalEpochs * 100).toStringAsFixed(1);
    print(
      '  ${e.key.name.padRight(20)} ${e.value.toString().padLeft(2)} epochs  ($pct%)',
    );
  }

  // Scenario timeline (show every 5th epoch)
  print('');
  print('SCENARIO TIMELINE (every 5th epoch)');
  print('───────────────────────────────────');
  for (int ep = 0; ep < totalEpochs; ep += 5) {
    final chunk = epochs.sublist(ep, min(ep + 5, totalEpochs));
    final labels = chunk
        .map((s) {
          switch (s) {
            case MarketScenario.bull:
              return '🐂';
            case MarketScenario.bear:
              return '🐻';
            case MarketScenario.recovery:
              return '🌱';
            case MarketScenario.hype:
              return '🚀';
            case MarketScenario.speculation:
              return '🌪️';
            case MarketScenario.blackSwan:
              return '🦢';
            case MarketScenario.crash:
              return '💥';
          }
        })
        .join(' ');
    final epEnd = min(ep + 5, totalEpochs);
    print(
      '  Epoch ${ep.toString().padLeft(2)}-${(epEnd - 1).toString().padLeft(2)}: $labels',
    );
  }

  print('');
  print('══════════════════════════════════════════════════════════════');
  print('                  PER-POSITION RESULTS                        ');
  print('══════════════════════════════════════════════════════════════');
  print('');

  double totalPortfolioValue = cash;
  num totalPnlDollars = 0;

  for (final sym in entryPrices.keys) {
    final entry = entryPrices[sym]!;
    final finalPrice = prices[sym]!;
    final shrs = shares[sym]!;
    final sector = _getSector(sym);
    final positionValue = shrs * finalPrice;
    final costBasis = shrs * entry;
    final pnlDollar = positionValue - costBasis;
    final pnlPercent = ((finalPrice - entry) / entry) * 100;
    final lowPct = ((positionMin[sym]! - entry) / entry) * 100;
    final highPct = ((positionMax[sym]! - entry) / entry) * 100;
    final volRange = ((positionMax[sym]! - positionMin[sym]!) / entry) * 100;

    totalPortfolioValue += positionValue;
    totalPnlDollars += pnlDollar;

    print('  ┌─ ${sym} ───────────────────────────────────────────────');
    print('  │ Company: ${_companyName(sym)}');
    print('  │ Sector:  ${sector.name}');
    print(
      '  │ Entry:   \$${entry.toStringAsFixed(2)}  →  Exit: \$${finalPrice.toStringAsFixed(2)}',
    );
    print(
      '  │ Shares:  ${shrs.toStringAsFixed(2)}  ×  Value: \$${positionValue.toStringAsFixed(2)}',
    );
    print(
      '  │ PnL:     ${pnlDollar >= 0 ? '+' : ''}\$${pnlDollar.toStringAsFixed(2)}  (${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
    );
    print(
      '  │ Range:   Low \$${positionMin[sym]!.toStringAsFixed(2)} (${lowPct.toStringAsFixed(1)}%)  High \$${positionMax[sym]!.toStringAsFixed(2)} (${highPct >= 0 ? '+' : ''}${highPct.toStringAsFixed(1)}%)',
    );
    print('  │ Volatility span: ${volRange.toStringAsFixed(1)}%');
    print('  └${'─' * 48}');
    print('');
  }

  print('  ┌─ CASH ──────────────────────────────────────────────────');
  print('  │ Remaining cash: \$${cash.toStringAsFixed(2)}');
  print('  └${'─' * 48}');
  print('');

  // ── Portfolio Summary ──
  print('══════════════════════════════════════════════════════════════');
  print('                  PORTFOLIO SUMMARY                           ');
  print('══════════════════════════════════════════════════════════════');
  print('');
  final totalPnlPct = (totalPortfolioValue - startingCash) / startingCash * 100;
  print('  Starting Capital:  \$${startingCash.toStringAsFixed(2)}');
  print('  Final Value:       \$${totalPortfolioValue.toStringAsFixed(2)}');
  print(
    '  Total PnL:         ${totalPnlDollars >= 0 ? '+' : ''}\$${totalPnlDollars.toStringAsFixed(2)}',
  );
  print(
    '  Return:            ${totalPnlPct >= 0 ? '+' : ''}${totalPnlPct.toStringAsFixed(2)}%',
  );
  print('');

  // ── TRADE LOG + P&L BREAKDOWN ──
  if (trades.isNotEmpty) {
    print('══════════════════════════════════════════════════════════════');
    print('                  TRADE LOG (Dynamic Trades)                  ');
    print('══════════════════════════════════════════════════════════════');
    print('');
    for (final t in trades) {
      final action = t.isBuy ? 'BUY ' : 'SELL';
      final pnlStr = t.realizedPnl != null
          ? '  PnL: ${t.realizedPnl! >= 0 ? '+' : ''}\$${t.realizedPnl!.toStringAsFixed(2)}'
          : '';
      print(
        '  [Epoch ${t.epoch.toString().padLeft(3)}] $action ${t.shares.toStringAsFixed(2)} × ${t.symbol} @ \$${t.price.toStringAsFixed(2)}$pnlStr',
      );
    }
    print('');
  }

  // Dynamic portfolio value (with trading)
  double dynPortfolioValue = dynCash;
  num dynTotalPnl = 0;
  for (final sym in entryPrices.keys) {
    final finalPrice = prices[sym]!;
    final val = dynShares[sym]! * finalPrice;
    dynPortfolioValue += val;
    final cost = dynShares[sym]! * dynAvgCost[sym]!;
    dynTotalPnl += val - cost;
  }
  final dynTotalPnlPct =
      (dynPortfolioValue - startingCash) / startingCash * 100;

  print('══════════════════════════════════════════════════════════════');
  print('              P&L BREAKDOWN (with trading)                    ');
  print('══════════════════════════════════════════════════════════════');
  print('');
  print('  ┌─ REALIZED P&L (закрытые сделки) ────────────────────────');
  print('  │ Total Realized PnL:  \$${totalRealizedPnl.toStringAsFixed(2)}');
  print('  └──────────────────────────────────────────────────────────');
  print('');
  print('  ┌─ UNREALIZED P&L (открытые позиции) ─────────────────────');
  for (final sym in entryPrices.keys) {
    final val = dynShares[sym]! * prices[sym]!;
    final cost = dynShares[sym]! * dynAvgCost[sym]!;
    final pnl = val - cost;
    final pnlPct = cost > 0 ? (pnl / cost) * 100 : 0;
    if (dynShares[sym]! > 0.001) {
      print(
        '  │ ${sym.padRight(6)} ${dynShares[sym]!.toStringAsFixed(2)} sh × avg \$${dynAvgCost[sym]!.toStringAsFixed(2)} → \$${prices[sym]!.toStringAsFixed(2)}  '
        '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)} (${pnlPct >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
      );
    }
  }
  print('  └──────────────────────────────────────────────────────────');
  print('');
  print('  Dynamic Cash:  \$${dynCash.toStringAsFixed(2)}');
  print('  Dynamic Value: \$${dynPortfolioValue.toStringAsFixed(2)}');
  print(
    '  Total Return:  ${dynTotalPnlPct >= 0 ? '+' : ''}${dynTotalPnlPct.toStringAsFixed(2)}%',
  );
  print(
    '  Realized PnL:  ${totalRealizedPnl >= 0 ? '+' : ''}\$${totalRealizedPnl.toStringAsFixed(2)}',
  );
  print('  Unrealized PnL: \$${dynTotalPnl.toStringAsFixed(2)}');
  print('');
  print('  COMPARED TO BUY & HOLD:');
  print(
    '    B&H Return:       ${totalPnlPct >= 0 ? '+' : ''}${totalPnlPct.toStringAsFixed(2)}%',
  );
  print(
    '    With Trading:     ${dynTotalPnlPct >= 0 ? '+' : ''}${dynTotalPnlPct.toStringAsFixed(2)}%',
  );
  final diff = dynTotalPnlPct - totalPnlPct;
  print(
    '    Difference:       ${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)}%',
  );
  print('');

  // Diversification / allocation
  print('  ALLOCATION BREAKDOWN (final):');
  for (final sym in entryPrices.keys) {
    final val = shares[sym]! * prices[sym]!;
    final alloc = (val / totalPortfolioValue) * 100;
    print(
      '    ${sym.padRight(6)} \$${val.toStringAsFixed(2)}  →  ${alloc.toStringAsFixed(1)}%',
    );
  }
  print(
    '    CASH     \$${cash.toStringAsFixed(2)}  →  ${(cash / totalPortfolioValue * 100).toStringAsFixed(1)}%',
  );

  // Volatility comparison
  print('');
  print('  VOLATILITY RANKING (most volatile → least):');
  final vols = <String, double>{};
  for (final sym in entryPrices.keys) {
    vols[sym] =
        ((positionMax[sym]! - positionMin[sym]!) / entryPrices[sym]!) * 100;
  }
  final sorted = vols.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (int i = 0; i < sorted.length; i++) {
    print(
      '    ${(i + 1)}. ${sorted[i].key} — ${sorted[i].value.toStringAsFixed(1)}% swing',
    );
  }

  // Scenario count table
  print('');
  print('  SCENARIO DISTRIBUTION:');
  final scenarioIcons = {
    MarketScenario.bull: '🐂 Bull',
    MarketScenario.bear: '🐻 Bear',
    MarketScenario.recovery: '🌱 Recovery',
    MarketScenario.hype: '🚀 Hype',
    MarketScenario.speculation: '🌪️ Speculation',
    MarketScenario.blackSwan: '🦢 BlackSwan',
    MarketScenario.crash: '💥 Crash',
  };
  for (final e in counts.entries) {
    final icon = scenarioIcons[e.key] ?? e.key.name;
    final pct = (e.value / totalEpochs * 100).toStringAsFixed(1);
    print('    $icon: ${e.value} epochs ($pct%)');
  }

  print('');
  print('══════════════════════════════════════════════════════════════');
}

String _companyName(String sym) {
  const names = {
    'BIIB': 'Biogen',
    'GILD': 'Gilead Sciences',
    'MRNA': 'Moderna',
    'ILMN': 'Illumina',
    'VRTX': 'Vertex Pharma',
    'WHR': 'Whirlpool',
    'HPQ': 'HP Inc',
    'HMC': 'Honda Motor',
    'CAT': 'Caterpillar',
    'DE': 'Deere & Co',
    'FCX': 'Freeport-McMoRan',
    'KO': 'Coca-Cola',
    'JPM': 'JPMorgan Chase',
    'MSFT': 'Microsoft',
    'XOM': 'Exxon Mobil',
  };
  return names[sym] ?? sym;
}
