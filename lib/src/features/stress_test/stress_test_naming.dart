import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/cache/logo_providers.dart';

// ---------------------------------------------------------------------------
// Stress Test naming/sector lookups — company display names and the coarse
// sector bucket for Stress Test's curated ~50 famous tickers + its own
// fictional assets. Moved out of the Stock Detail screen's own widgets/
// folder (stock_detail_helpers.dart) 2026-08-09: this is domain data
// consumed by the engine (psychology_engine.dart) and half a dozen other
// widgets that have nothing to do with that screen — reaching into a
// screen's private widget folder for it was backwards layering.
// ---------------------------------------------------------------------------

const Map<String, String> _stressTestCompanyNames = <String, String>{
  'AAPL': 'Apple',
  'MSFT': 'Microsoft',
  'GOOGL': 'Alphabet',
  'GOOG': 'Alphabet',
  'AMZN': 'Amazon',
  'META': 'Meta',
  'NVDA': 'NVIDIA',
  'TSLA': 'Tesla',
  'AMD': 'AMD',
  'INTC': 'Intel',
  'CRM': 'Salesforce',
  'ADBE': 'Adobe',
  'NFLX': 'Netflix',
  'CSCO': 'Cisco',
  'ORCL': 'Oracle',
  'IBM': 'IBM',
  'QCOM': 'Qualcomm',
  'TXN': 'Texas Instruments',
  'AVGO': 'Broadcom',
  'MU': 'Micron',
  'JPM': 'JPMorgan Chase',
  'BAC': 'Bank of America',
  'C': 'Citigroup',
  'GS': 'Goldman Sachs',
  'MS': 'Morgan Stanley',
  'WFC': 'Wells Fargo',
  'AXP': 'American Express',
  'V': 'Visa',
  'MA': 'Mastercard',
  'BLK': 'BlackRock',
  'SCHW': 'Charles Schwab',
  'PYPL': 'PayPal',
  'JNJ': 'Johnson & Johnson',
  'PFE': 'Pfizer',
  'UNH': 'UnitedHealth',
  'ABBV': 'AbbVie',
  'MRK': 'Merck',
  'ABT': 'Abbott',
  'LLY': 'Eli Lilly',
  'MDT': 'Medtronic',
  'BMY': 'Bristol-Myers',
  'AMGN': 'Amgen',
  'KO': 'Coca-Cola',
  'PEP': 'PepsiCo',
  'PG': 'Procter & Gamble',
  'WMT': 'Walmart',
  'COST': 'Costco',
  'MO': 'Altria',
  'CL': 'Colgate',
  'KMB': 'Kimberly-Clark',
  'SYY': 'Sysco',
  'GIS': 'General Mills',
  'NOVA': 'NovaGenix',
  'ZEN': 'Zenith AI',
  'AURA': 'Aura Energy',
  'VERT': 'VertiCarbon',
  'CORE': 'CoreVault',
  'MORF': 'Morphic Labs',
  'DRIF': 'Drift Auto',
  'PULS': 'Pulse Health',
  'CASP': 'Caspian Data',
  'NEXO': 'NexoGene',
};

String stressTestCompanyName(String symbol) =>
    _stressTestCompanyNames[symbol] ?? symbol;

/// Same as [stressTestCompanyName], but for real tickers outside the curated
/// map above (anything buyable via Search that isn't one of the ~50 famous
/// companies or Stress Test's own fictional assets) — falls through to the
/// real cached/fetched name via [resolvedCompanyNameProvider] instead of
/// giving up and showing the raw ticker.
String resolveStressTestCompanyName(WidgetRef ref, String symbol) {
  final curated = stressTestCompanyName(symbol);
  if (curated != symbol) return curated;
  return ref.watch(resolvedCompanyNameProvider(symbol)).valueOrNull ?? symbol;
}

String stressTestSectorName(String symbol) {
  const tech = {
    'AAPL', 'MSFT', 'GOOGL', 'GOOG', 'AMZN', 'META', 'NVDA', 'AMD', 'INTC',
    'CRM', 'ADBE', 'NFLX', 'CSCO', 'ORCL', 'IBM', 'QCOM', 'TXN', 'AVGO', 'MU',
  };
  const finance = {
    'JPM', 'BAC', 'C', 'GS', 'MS', 'WFC', 'AXP', 'V', 'MA', 'BLK', 'SCHW',
    'PYPL',
  };
  const healthcare = {
    'JNJ', 'PFE', 'UNH', 'ABBV', 'MRK', 'ABT', 'LLY', 'MDT', 'BMY', 'AMGN',
  };
  const consumer = {
    'KO', 'PEP', 'PG', 'WMT', 'COST', 'MO', 'CL', 'KMB', 'SYY', 'GIS',
  };
  if (tech.contains(symbol)) return 'Technology';
  if (finance.contains(symbol)) return 'Finance';
  if (healthcare.contains(symbol)) return 'Healthcare';
  if (consumer.contains(symbol)) return 'Consumer';
  if (['TSLA', 'DRIF'].contains(symbol)) return 'Automotive';
  if (['NOVA', 'ZEN', 'MORF', 'PULS', 'NEXO'].contains(symbol)) {
    return 'Biotech';
  }
  if (['AURA', 'VERT'].contains(symbol)) return 'Energy';
  if (['CORE', 'CASP'].contains(symbol)) return 'Tech';
  return 'Other';
}
