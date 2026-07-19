import 'company_tag_mapper.dart';

/// The 11 standard GICS (Global Industry Classification Standard) sectors.
/// Used wherever a real-world sector grouping is needed — e.g. the stress
/// test's per-sector Hype mechanism and the company card's sector badge.
enum GicsSector {
  technology,
  financials,
  healthCare,
  consumerDiscretionary,
  consumerStaples,
  energy,
  industrials,
  materials,
  communicationServices,
  realEstate,
  utilities,
}

extension GicsSectorLabel on GicsSector {
  /// Standard display name for this sector.
  String get label => switch (this) {
    GicsSector.technology => 'Technology',
    GicsSector.financials => 'Financials',
    GicsSector.healthCare => 'Health Care',
    GicsSector.consumerDiscretionary => 'Consumer Discretionary',
    GicsSector.consumerStaples => 'Consumer Staples',
    GicsSector.energy => 'Energy',
    GicsSector.industrials => 'Industrials',
    GicsSector.materials => 'Materials',
    GicsSector.communicationServices => 'Communication Services',
    GicsSector.realEstate => 'Real Estate',
    GicsSector.utilities => 'Utilities',
  };
}

/// Resolves a ticker to one of the 11 GICS sectors.
///
/// Two layers:
/// 1. [_overrides] — per-ticker corrections for well-known names where
///    [CompanyTagMapper]'s coarser ~15-bucket classification (built for
///    short display tags, not real sector accuracy) lands in the wrong
///    GICS sector — e.g. Amazon tagged "Technology" there is really
///    Consumer Discretionary; utilities like NEE/DUK were folded into
///    "Energy" there but belong in their own GICS Utilities sector.
/// 2. Fallback — bridges [CompanyTagMapper]'s existing sector string
///    (covers the same ticker universe plus its name-keyword fallback
///    for unlisted tickers) into the nearest GICS bucket, so every
///    symbol the app already recognizes gets a GICS sector for free
///    without maintaining a second full ticker table.
///
/// Returns `null` for instruments that don't map to a real economic
/// sector (broad-market/leveraged/bond/commodity ETFs, crypto assets) —
/// callers should treat these as ineligible for sector-based mechanics.
GicsSector? resolveGicsSector(String symbol, {String? companyName}) {
  final ticker = symbol.trim().toUpperCase();
  final override = _overrides[ticker];
  if (override != null) return override;

  final tag = CompanyTagMapper.tag(ticker, companyName: companyName);
  final bucket = tag?.sector;
  if (bucket == null) return null;
  return _bucketToGics[bucket];
}

/// Per-ticker corrections against [CompanyTagMapper]'s coarse buckets.
const Map<String, GicsSector> _overrides = {
  // ── Communication Services (not "Technology"/"Media" bucket) ──
  'GOOGL': GicsSector.communicationServices,
  'GOOG': GicsSector.communicationServices,
  'META': GicsSector.communicationServices,
  'NFLX': GicsSector.communicationServices,
  'DIS': GicsSector.communicationServices,
  'CMCSA': GicsSector.communicationServices,
  'SNAP': GicsSector.communicationServices,
  'PINS': GicsSector.communicationServices,
  'SPOT': GicsSector.communicationServices,
  'RDDT': GicsSector.communicationServices,
  'VZ': GicsSector.communicationServices,
  'T': GicsSector.communicationServices,
  'TMUS': GicsSector.communicationServices,
  'BIDU': GicsSector.communicationServices,
  'TCEHY': GicsSector.communicationServices,
  'YNDX': GicsSector.communicationServices,

  // ── Consumer Discretionary (not "Technology"/"Retail" bucket) ──
  'AMZN': GicsSector.consumerDiscretionary,
  'BABA': GicsSector.consumerDiscretionary,
  'JD': GicsSector.consumerDiscretionary,
  'PDD': GicsSector.consumerDiscretionary,
  'EBAY': GicsSector.consumerDiscretionary,
  'ETSY': GicsSector.consumerDiscretionary,
  'TGT': GicsSector.consumerDiscretionary,
  'HD': GicsSector.consumerDiscretionary,
  'LOW': GicsSector.consumerDiscretionary,
  'MCD': GicsSector.consumerDiscretionary,
  'SBUX': GicsSector.consumerDiscretionary,
  'YUM': GicsSector.consumerDiscretionary,
  'QSR': GicsSector.consumerDiscretionary,
  'CMG': GicsSector.consumerDiscretionary,
  'DPZ': GicsSector.consumerDiscretionary,
  'NKE': GicsSector.consumerDiscretionary,

  // ── Financials (payment/data processors, not "Technology") ──
  'V': GicsSector.financials,
  'MA': GicsSector.financials,
  'PYPL': GicsSector.financials,
  'SQ': GicsSector.financials,
  'FICO': GicsSector.financials,

  // ── Industrials (ride-hailing = ground transportation, not "Tech") ──
  'UBER': GicsSector.industrials,
  // Solar/hydrogen equipment makers, not "Energy" utilities/producers.
  'ENPH': GicsSector.industrials,
  'SEDG': GicsSector.industrials,
  'FSLR': GicsSector.industrials,
  'PLUG': GicsSector.industrials,
  'BE': GicsSector.industrials,

  // ── Utilities (electric utilities, not "Energy") ──
  'NEE': GicsSector.utilities,
  'DUK': GicsSector.utilities,
  'SO': GicsSector.utilities,
  'D': GicsSector.utilities,
  'AEP': GicsSector.utilities,

  // ── Materials (chemicals, not "Industrial") ──
  'DOW': GicsSector.materials,

  // ── Health Care (insurers/pharmacy, not "Financial"/"Retail") ──
  'UNH': GicsSector.healthCare,
  'CI': GicsSector.healthCare,
  'HUM': GicsSector.healthCare,
  'ANTM': GicsSector.healthCare,
  'ELV': GicsSector.healthCare,
  'CVS': GicsSector.healthCare,
  'WBA': GicsSector.healthCare,

  // ── Consumer Staples (grocery/food distribution, not "Retail") ──
  'WMT': GicsSector.consumerStaples,
  'COST': GicsSector.consumerStaples,
  'KR': GicsSector.consumerStaples,
  'SYY': GicsSector.consumerStaples,
  'MGNT': GicsSector.consumerStaples,

  // ── Sector ETFs — map directly to the sector they track ──
  'XLF': GicsSector.financials,
  'XLK': GicsSector.technology,
  'XLE': GicsSector.energy,
  'XLV': GicsSector.healthCare,
  'XLI': GicsSector.industrials,
  'XLP': GicsSector.consumerStaples,
  'XLU': GicsSector.utilities,
  'XLB': GicsSector.materials,
  'XLRE': GicsSector.realEstate,
  'SMH': GicsSector.technology,
  'SOXX': GicsSector.technology,
  'ARKK': GicsSector.technology,
  'ARKF': GicsSector.technology,
  'ARKW': GicsSector.technology,
  'ARKG': GicsSector.technology,

  // ── Broad-market / leveraged / bond / commodity / crypto — no single
  // real-economy sector applies. Explicit null-equivalent: simply absent
  // from every layer, but listed here so their exclusion is a deliberate,
  // documented decision rather than an accidental gap.
  // SPY, QQQ, DIA, IVV, VOO, VTI, VT, BND, AGG, GLD, IAU, SLV, TLT, IWM,
  // EEM, VWO, TQQQ, SPXL, SQQQ, SPXS, UVXY, BITO, IBIT, FBTC, GBTC, ETHA,
  // BTC, ETH, SOL, XRP
};

/// Bridges [CompanyTagMapper]'s coarse sector-string buckets to GICS.
/// `null` means "no single real-economy sector" (index funds, crypto).
const Map<String, GicsSector?> _bucketToGics = {
  'Technology': GicsSector.technology,
  'Automotive': GicsSector.consumerDiscretionary,
  'Financial': GicsSector.financials,
  'Food': GicsSector.consumerStaples,
  'Retail': GicsSector.consumerDiscretionary,
  'Media': GicsSector.communicationServices,
  'Telecom': GicsSector.communicationServices,
  'Industrial': GicsSector.industrials,
  'Logistics': GicsSector.industrials,
  'Healthcare': GicsSector.healthCare,
  'Energy': GicsSector.energy,
  'Consumer': GicsSector.consumerStaples,
  'Food Service': GicsSector.consumerDiscretionary,
  'Travel': GicsSector.consumerDiscretionary,
  'Education': GicsSector.consumerDiscretionary,
  'Real Estate': GicsSector.realEstate,
  'ETF': null,
  'Crypto': null,
};
