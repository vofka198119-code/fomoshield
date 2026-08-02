import 'package:intl/intl.dart';

// ---------------------------------------------------------------------------
// Shared formatting/lookup helpers for the Stress Test stock detail screen's
// widget files — split out of the old monolithic stock_detail_screen.dart
// verbatim, no logic changes.
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

/// Full currency format — NEVER compact (4.67K, 1.5M). Always $X,XXX.XX
String fmtFullCurrency(double v) =>
    NumberFormat.currency(locale: 'en_US', symbol: r'$').format(v);

/// Date formatter: "Jan 15"
String fmtTradeDate(DateTime d) => DateFormat('MMM d').format(d);

/// Time formatter: "14:30"
String fmtTradeTime(DateTime d) => DateFormat('HH:mm').format(d);
