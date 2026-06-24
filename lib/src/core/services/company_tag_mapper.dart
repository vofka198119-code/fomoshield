/// Mapper that generates short English descriptions (1-3 words, ≤30 chars)
/// for companies based on their ticker or name.
///
/// Used in watchlist cards instead of the long Finnhub business description.
library;

/// Result of tagging a company.
class CompanyTag {
  /// Short description: e.g. "Semiconductors" or "Tech • Microchips"
  final String tag;

  /// Sector category: e.g. "Technology", "Retail"
  final String? sector;

  const CompanyTag({required this.tag, this.sector});
}

/// Maps company tickers and names to short English descriptions.
class CompanyTagMapper {
  CompanyTagMapper._();

  // ---------------------------------------------------------------------------
  // Primary: fast ticker-based lookup
  // ---------------------------------------------------------------------------

  static const Map<String, CompanyTag> _byTicker = {
    // ---- Technology / IT ----
    'AAPL': CompanyTag(tag: 'Tech • Smartphones', sector: 'Technology'),
    'MSFT': CompanyTag(tag: 'Software', sector: 'Technology'),
    'GOOGL': CompanyTag(tag: 'Tech Giants • Search', sector: 'Technology'),
    'GOOG': CompanyTag(tag: 'Tech Giants • Search', sector: 'Technology'),
    'META': CompanyTag(tag: 'Tech Giants • Social', sector: 'Technology'),
    'AMZN': CompanyTag(tag: 'Tech Giants • E-commerce', sector: 'Technology'),
    'NFLX': CompanyTag(tag: 'Streaming', sector: 'Media'),
    'NVDA': CompanyTag(tag: 'Semiconductors', sector: 'Technology'),
    'AMD': CompanyTag(tag: 'Tech • Microchips', sector: 'Technology'),
    'INTC': CompanyTag(tag: 'Semiconductors', sector: 'Technology'),
    'IBM': CompanyTag(tag: 'IT Services', sector: 'Technology'),
    'ORCL': CompanyTag(tag: 'Enterprise SW', sector: 'Technology'),
    'CRM': CompanyTag(tag: 'CRM Platform', sector: 'Technology'),
    'ADBE': CompanyTag(tag: 'Digital Content', sector: 'Technology'),
    'CSCO': CompanyTag(tag: 'Networking', sector: 'Technology'),
    'QCOM': CompanyTag(tag: 'Chips • Modems', sector: 'Technology'),
    'TXN': CompanyTag(tag: 'Analog Chips', sector: 'Technology'),
    'AVGO': CompanyTag(tag: 'Semiconductors', sector: 'Technology'),
    'INTU': CompanyTag(tag: 'Financial SW', sector: 'Technology'),
    'NOW': CompanyTag(tag: 'IT Platform', sector: 'Technology'),
    'UBER': CompanyTag(tag: 'Ride-hailing • Delivery', sector: 'Technology'),
    'PYPL': CompanyTag(tag: 'Online Payments', sector: 'Technology'),
    'SNAP': CompanyTag(tag: 'Social Network', sector: 'Media'),
    'PINS': CompanyTag(tag: 'Social • Ideas', sector: 'Media'),
    'SPOT': CompanyTag(tag: 'Music Streaming', sector: 'Media'),
    'SQ': CompanyTag(tag: 'Fintech', sector: 'Technology'),
    'SHOP': CompanyTag(tag: 'E-commerce Platform', sector: 'Technology'),
    'PANW': CompanyTag(tag: 'Cybersecurity', sector: 'Technology'),
    'CRWD': CompanyTag(tag: 'Cybersecurity', sector: 'Technology'),
    'ZS': CompanyTag(tag: 'Cybersecurity', sector: 'Technology'),
    'DDOG': CompanyTag(tag: 'Monitoring • DevOps', sector: 'Technology'),
    'PLTR': CompanyTag(tag: 'Data Analytics', sector: 'Technology'),
    'RDDT': CompanyTag(tag: 'Social • Forum', sector: 'Media'),
    'HOOD': CompanyTag(tag: 'Trading Platform', sector: 'Technology'),
    'MSTR': CompanyTag(tag: 'Enterprise SW', sector: 'Technology'),
    'WDAY': CompanyTag(tag: 'HR Platform', sector: 'Technology'),
    'ADSK': CompanyTag(tag: 'Design • 3D', sector: 'Technology'),
    'ROP': CompanyTag(tag: 'IT Solutions', sector: 'Technology'),
    'ANSS': CompanyTag(tag: 'Engineering SW', sector: 'Technology'),
    'MDB': CompanyTag(tag: 'Databases', sector: 'Technology'),
    'FTNT': CompanyTag(tag: 'Cybersecurity', sector: 'Technology'),
    'HUBS': CompanyTag(tag: 'Marketing Platform', sector: 'Technology'),
    'IOT': CompanyTag(tag: 'IoT', sector: 'Technology'),
    'TOST': CompanyTag(tag: 'Restaurant Tech', sector: 'Technology'),
    'GTLB': CompanyTag(tag: 'DevOps Platform', sector: 'Technology'),
    'CFLT': CompanyTag(tag: 'Cloud Platform', sector: 'Technology'),
    'NET': CompanyTag(tag: 'Cloud Networking', sector: 'Technology'),
    'OKTA': CompanyTag(tag: 'Security • SSO', sector: 'Technology'),
    'ESTC': CompanyTag(tag: 'Search • Analytics', sector: 'Technology'),
    'PCOR': CompanyTag(tag: 'Construction Tech', sector: 'Technology'),
    'SMAR': CompanyTag(tag: 'Project Management', sector: 'Technology'),
    'ZM': CompanyTag(tag: 'Video Conferencing', sector: 'Technology'),
    'DOCU': CompanyTag(tag: 'Document Cloud', sector: 'Technology'),
    'AKAM': CompanyTag(tag: 'Cloud Networking', sector: 'Technology'),
    'PAYC': CompanyTag(tag: 'Payroll', sector: 'Technology'),
    'VRSN': CompanyTag(tag: 'Internet Security', sector: 'Technology'),
    'SSNC': CompanyTag(tag: 'Fintech • Software', sector: 'Technology'),
    'FICO': CompanyTag(tag: 'Credit Ratings', sector: 'Technology'),
    'CDNS': CompanyTag(tag: 'EDA • Chip Design', sector: 'Technology'),
    'SNPS': CompanyTag(tag: 'EDA • Chip Design', sector: 'Technology'),
    'KEYS': CompanyTag(tag: 'Test Equipment', sector: 'Technology'),
    'TYL': CompanyTag(tag: 'GovTech', sector: 'Technology'),
    'DT': CompanyTag(tag: 'IT Monitoring', sector: 'Technology'),
    'WIT': CompanyTag(tag: 'IT Outsourcing', sector: 'Technology'),

    // ---- Tesla / Automotive ----
    'TSLA': CompanyTag(tag: 'Electric Vehicles', sector: 'Automotive'),
    'TM': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'F': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'GM': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'RIVN': CompanyTag(tag: 'Electric Vehicles', sector: 'Automotive'),
    'LCID': CompanyTag(tag: 'EV • Luxury', sector: 'Automotive'),
    'TSM': CompanyTag(tag: 'Semiconductors', sector: 'Technology'),
    'HMC': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'VWAGY': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'MBGYY': CompanyTag(tag: 'Auto • Luxury', sector: 'Automotive'),
    'BMWYY': CompanyTag(tag: 'Auto • Luxury', sector: 'Automotive'),
    'STLA': CompanyTag(tag: 'Automotive', sector: 'Automotive'),
    'LI': CompanyTag(tag: 'EV • China', sector: 'Automotive'),
    'NIO': CompanyTag(tag: 'EV • China', sector: 'Automotive'),
    'XPEV': CompanyTag(tag: 'EV • China', sector: 'Automotive'),
    'RACE': CompanyTag(tag: 'Supercars', sector: 'Automotive'),

    // ---- Financial / Banks ----
    'JPM': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'BAC': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'WFC': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'C': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'GS': CompanyTag(tag: 'Inv. Banking', sector: 'Financial'),
    'MS': CompanyTag(tag: 'Inv. Banking', sector: 'Financial'),
    'V': CompanyTag(tag: 'Payment Systems', sector: 'Financial'),
    'MA': CompanyTag(tag: 'Payment Systems', sector: 'Financial'),
    'AXP': CompanyTag(tag: 'Credit Cards', sector: 'Financial'),
    'DFS': CompanyTag(tag: 'Credit Cards', sector: 'Financial'),
    'BX': CompanyTag(tag: 'Investments', sector: 'Financial'),
    'KKR': CompanyTag(tag: 'Investments', sector: 'Financial'),
    'APO': CompanyTag(tag: 'Investments', sector: 'Financial'),
    'BLK': CompanyTag(tag: 'Asset Management', sector: 'Financial'),
    'SCHW': CompanyTag(tag: 'Brokerage', sector: 'Financial'),
    'COIN': CompanyTag(tag: 'Crypto Exchange', sector: 'Financial'),
    'PGR': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'MET': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'PRU': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'ALL': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'AIG': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'TRV': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'BK': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'FITB': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'USB': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'PNC': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'TFC': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'COF': CompanyTag(tag: 'Credit Cards', sector: 'Financial'),
    'SIVBQ': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'MCO': CompanyTag(tag: 'Credit Ratings', sector: 'Financial'),
    'SPGI': CompanyTag(tag: 'Credit Ratings', sector: 'Financial'),
    'ICE': CompanyTag(tag: 'Market Infra', sector: 'Financial'),
    'CME': CompanyTag(tag: 'Market Infra', sector: 'Financial'),
    'NDAQ': CompanyTag(tag: 'Market Infra', sector: 'Financial'),
    'MSCI': CompanyTag(tag: 'Indices • ESG', sector: 'Financial'),
    'AJG': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'AFL': CompanyTag(tag: 'Insurance', sector: 'Financial'),
    'HIG': CompanyTag(tag: 'Insurance', sector: 'Financial'),

    // ---- Consumer Goods ----
    'PG': CompanyTag(tag: 'Consumer Goods', sector: 'Consumer'),
    'KO': CompanyTag(tag: 'Beverages', sector: 'Food'),
    'PEP': CompanyTag(tag: 'Beverages • Snacks', sector: 'Food'),
    'COST': CompanyTag(tag: 'Retail • Supermarkets', sector: 'Retail'),
    'WMT': CompanyTag(tag: 'Retail • Hypermarkets', sector: 'Retail'),
    'TGT': CompanyTag(tag: 'Retail', sector: 'Retail'),
    'HD': CompanyTag(tag: 'Retail • Home Improvement', sector: 'Retail'),
    'LOW': CompanyTag(tag: 'Retail • Home Improvement', sector: 'Retail'),
    'MCD': CompanyTag(tag: 'Fast Food', sector: 'Food Service'),
    'SBUX': CompanyTag(tag: 'Coffee Shops', sector: 'Food Service'),
    'NKE': CompanyTag(tag: 'Sporting Goods', sector: 'Retail'),
    'DIS': CompanyTag(tag: 'Media • Entertainment', sector: 'Media'),
    'CMCSA': CompanyTag(tag: 'Media • Telecom', sector: 'Media'),
    'VZ': CompanyTag(tag: 'Telecom', sector: 'Telecom'),
    'T': CompanyTag(tag: 'Telecom', sector: 'Telecom'),
    'TMUS': CompanyTag(tag: 'Telecom', sector: 'Telecom'),
    'BA': CompanyTag(tag: 'Aerospace', sector: 'Industrial'),
    'GE': CompanyTag(tag: 'Industrial Conglomerate', sector: 'Industrial'),
    'CAT': CompanyTag(tag: 'Construction Equip.', sector: 'Industrial'),
    'DE': CompanyTag(tag: 'Farm Equipment', sector: 'Industrial'),
    'MMM': CompanyTag(tag: 'Industrial Goods', sector: 'Industrial'),
    'HON': CompanyTag(tag: 'Industrial Solutions', sector: 'Industrial'),
    'UPS': CompanyTag(tag: 'Delivery • Logistics', sector: 'Logistics'),
    'FDX': CompanyTag(tag: 'Delivery • Logistics', sector: 'Logistics'),
    'DHL': CompanyTag(tag: 'Delivery • Logistics', sector: 'Logistics'),
    'YUM': CompanyTag(tag: 'Fast Food', sector: 'Food Service'),
    'QSR': CompanyTag(tag: 'Fast Food', sector: 'Food Service'),
    'CMG': CompanyTag(tag: 'Fast Food • Mexican', sector: 'Food Service'),
    'DPZ': CompanyTag(tag: 'Fast Food • Pizza', sector: 'Food Service'),
    'MNST': CompanyTag(tag: 'Energy Drinks', sector: 'Food'),
    'KHC': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'GIS': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'CAG': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'CPB': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'K': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'SJM': CompanyTag(tag: 'Food Industry', sector: 'Food'),
    'HRL': CompanyTag(tag: 'Meat Products', sector: 'Food'),
    'MKC': CompanyTag(tag: 'Spices • Seasonings', sector: 'Food'),
    'CL': CompanyTag(tag: 'Hygiene • Care', sector: 'Consumer'),
    'CLX': CompanyTag(tag: 'Home Care', sector: 'Consumer'),
    'KMB': CompanyTag(tag: 'Paper Products', sector: 'Consumer'),
    'EL': CompanyTag(tag: 'Cosmetics • Care', sector: 'Consumer'),
    'CHD': CompanyTag(tag: 'Home Care', sector: 'Consumer'),
    'SYY': CompanyTag(tag: 'Wholesale', sector: 'Retail'),
    'DG': CompanyTag(tag: 'Retail • Discount', sector: 'Retail'),
    'DLTR': CompanyTag(tag: 'Retail • Discount', sector: 'Retail'),
    'ROST': CompanyTag(tag: 'Retail • Apparel', sector: 'Retail'),
    'TJX': CompanyTag(tag: 'Retail • Apparel', sector: 'Retail'),
    'ORLY': CompanyTag(tag: 'Auto Parts', sector: 'Retail'),
    'AZO': CompanyTag(tag: 'Auto Parts', sector: 'Retail'),
    'GPC': CompanyTag(tag: 'Auto Parts', sector: 'Retail'),
    'TSCO': CompanyTag(tag: 'Home & Garden', sector: 'Retail'),
    'BBY': CompanyTag(tag: 'Electronics Retail', sector: 'Retail'),
    'EBAY': CompanyTag(tag: 'E-commerce', sector: 'Technology'),
    'ETSY': CompanyTag(tag: 'Crafts Marketplace', sector: 'Technology'),
    'CVS': CompanyTag(tag: 'Pharmacy • Insurance', sector: 'Healthcare'),
    'WBA': CompanyTag(tag: 'Pharmacy', sector: 'Healthcare'),
    'KR': CompanyTag(tag: 'Retail • Supermarkets', sector: 'Retail'),

    // ---- Healthcare / Pharma ----
    'UNH': CompanyTag(tag: 'Health Insurance', sector: 'Healthcare'),
    'JNJ': CompanyTag(tag: 'Pharmaceuticals', sector: 'Healthcare'),
    'PFE': CompanyTag(tag: 'Pharmaceuticals', sector: 'Healthcare'),
    'MRK': CompanyTag(tag: 'Pharmaceuticals', sector: 'Healthcare'),
    'ABBV': CompanyTag(tag: 'Pharmaceuticals', sector: 'Healthcare'),
    'ABT': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'TMO': CompanyTag(tag: 'Lab Equipment', sector: 'Healthcare'),
    'DHR': CompanyTag(tag: 'Lab Equipment', sector: 'Healthcare'),
    'MDT': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'ISRG': CompanyTag(tag: 'Surgical Robots', sector: 'Healthcare'),
    'AMGN': CompanyTag(tag: 'Biotechnology', sector: 'Healthcare'),
    'GILD': CompanyTag(tag: 'Biotechnology', sector: 'Healthcare'),
    'REGN': CompanyTag(tag: 'Biotechnology', sector: 'Healthcare'),
    'VRTX': CompanyTag(tag: 'Biotechnology', sector: 'Healthcare'),
    'BIIB': CompanyTag(tag: 'Biotechnology', sector: 'Healthcare'),
    'ILMN': CompanyTag(tag: 'Genomics', sector: 'Healthcare'),
    'BSX': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'SYK': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'BDX': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'EW': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),
    'ZTS': CompanyTag(tag: 'Veterinary', sector: 'Healthcare'),
    'MRNA': CompanyTag(tag: 'Biotech • Vaccines', sector: 'Healthcare'),
    'BNTX': CompanyTag(tag: 'Biotech • Vaccines', sector: 'Healthcare'),
    'CI': CompanyTag(tag: 'Health Insurance', sector: 'Healthcare'),
    'HUM': CompanyTag(tag: 'Health Insurance', sector: 'Healthcare'),
    'ANTM': CompanyTag(tag: 'Health Insurance', sector: 'Healthcare'),
    'ELV': CompanyTag(tag: 'Health Insurance', sector: 'Healthcare'),
    'IQV': CompanyTag(tag: 'Clinical Research', sector: 'Healthcare'),
    'DOW': CompanyTag(tag: 'Chemical Industry', sector: 'Industrial'),

    // ---- Energy ----
    'XOM': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'CVX': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'COP': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'EOG': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'OXY': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'SLB': CompanyTag(tag: 'Oil Services', sector: 'Energy'),
    'HAL': CompanyTag(tag: 'Oil Services', sector: 'Energy'),
    'BKR': CompanyTag(tag: 'Oil Services', sector: 'Energy'),
    'PSX': CompanyTag(tag: 'Refining', sector: 'Energy'),
    'VLO': CompanyTag(tag: 'Refining', sector: 'Energy'),
    'MPC': CompanyTag(tag: 'Refining', sector: 'Energy'),
    'KMI': CompanyTag(tag: 'Pipelines • Infrastructure', sector: 'Energy'),
    'WMB': CompanyTag(tag: 'Pipelines', sector: 'Energy'),
    'OKE': CompanyTag(tag: 'Pipelines', sector: 'Energy'),
    'NEE': CompanyTag(tag: 'Electric Utilities', sector: 'Energy'),
    'DUK': CompanyTag(tag: 'Electric Utilities', sector: 'Energy'),
    'SO': CompanyTag(tag: 'Electric Utilities', sector: 'Energy'),
    'D': CompanyTag(tag: 'Electric Utilities', sector: 'Energy'),
    'AEP': CompanyTag(tag: 'Electric Utilities', sector: 'Energy'),
    'ENPH': CompanyTag(tag: 'Solar Energy', sector: 'Energy'),
    'SEDG': CompanyTag(tag: 'Solar Energy', sector: 'Energy'),
    'FSLR': CompanyTag(tag: 'Solar Panels', sector: 'Energy'),
    'PLUG': CompanyTag(tag: 'Hydrogen Energy', sector: 'Energy'),
    'BE': CompanyTag(tag: 'Renewable Energy', sector: 'Energy'),
    'GEV': CompanyTag(tag: 'Energy Equipment', sector: 'Industrial'),

    // ---- Industrial ----
    'ETN': CompanyTag(tag: 'Electrical Equipment', sector: 'Industrial'),
    'EMR': CompanyTag(tag: 'Automation', sector: 'Industrial'),
    'PH': CompanyTag(tag: 'Automation', sector: 'Industrial'),
    'ROK': CompanyTag(tag: 'Industrial Automation', sector: 'Industrial'),
    'AME': CompanyTag(tag: 'Industrial Equipment', sector: 'Industrial'),
    'IR': CompanyTag(tag: 'Industrial Equipment', sector: 'Industrial'),
    'ITW': CompanyTag(tag: 'Industrial Components', sector: 'Industrial'),
    'PWR': CompanyTag(tag: 'Power Construction', sector: 'Industrial'),
    'CMI': CompanyTag(tag: 'Engines • Power Systems', sector: 'Industrial'),
    'LMT': CompanyTag(tag: 'Defense', sector: 'Industrial'),
    'RTX': CompanyTag(tag: 'Defense', sector: 'Industrial'),
    'NOC': CompanyTag(tag: 'Defense', sector: 'Industrial'),
    'GD': CompanyTag(tag: 'Defense', sector: 'Industrial'),
    'LHX': CompanyTag(tag: 'Defense', sector: 'Industrial'),
    'HWM': CompanyTag(tag: 'Aerospace Components', sector: 'Industrial'),
    'TDG': CompanyTag(tag: 'Aerospace Components', sector: 'Industrial'),
    'GEHC': CompanyTag(tag: 'Medical Devices', sector: 'Healthcare'),

    // ---- Chinese Companies ----
    'BABA': CompanyTag(tag: 'E-commerce • China', sector: 'Technology'),
    'JD': CompanyTag(tag: 'E-commerce • China', sector: 'Technology'),
    'PDD': CompanyTag(tag: 'E-commerce • China', sector: 'Technology'),
    'BIDU': CompanyTag(tag: 'Search • AI • China', sector: 'Technology'),
    'TCEHY': CompanyTag(tag: 'Tech Giant • China', sector: 'Technology'),

    // ---- Russian (historical) ----
    'SBER': CompanyTag(tag: 'Banking', sector: 'Financial'),
    'GAZP': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'LKOH': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'ROSN': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'YNDX': CompanyTag(tag: 'IT • Search • AI', sector: 'Technology'),
    'NVTK': CompanyTag(tag: 'Oil & Gas', sector: 'Energy'),
    'MGNT': CompanyTag(tag: 'Retail', sector: 'Retail'),

    // ---- ETF ----
    'SPY': CompanyTag(tag: 'S&P 500 Index', sector: 'ETF'),
    'QQQ': CompanyTag(tag: 'NASDAQ-100 Index', sector: 'ETF'),
    'DIA': CompanyTag(tag: 'Dow Jones Index', sector: 'ETF'),
    'IVV': CompanyTag(tag: 'S&P 500 Index', sector: 'ETF'),
    'VOO': CompanyTag(tag: 'S&P 500 Index', sector: 'ETF'),
    'VTI': CompanyTag(tag: 'US Total Market', sector: 'ETF'),
    'VT': CompanyTag(tag: 'Global', sector: 'ETF'),
    'BND': CompanyTag(tag: 'Bonds', sector: 'ETF'),
    'AGG': CompanyTag(tag: 'Bonds', sector: 'ETF'),
    'GLD': CompanyTag(tag: 'Gold', sector: 'ETF'),
    'IAU': CompanyTag(tag: 'Gold', sector: 'ETF'),
    'SLV': CompanyTag(tag: 'Silver', sector: 'ETF'),
    'TLT': CompanyTag(tag: 'Long-Term Bonds', sector: 'ETF'),
    'IWM': CompanyTag(tag: 'Small Cap (Russell 2000)', sector: 'ETF'),
    'EEM': CompanyTag(tag: 'Emerging Markets', sector: 'ETF'),
    'VWO': CompanyTag(tag: 'Emerging Markets', sector: 'ETF'),
    'XLF': CompanyTag(tag: 'Financial Sector', sector: 'ETF'),
    'XLK': CompanyTag(tag: 'Technology Sector', sector: 'ETF'),
    'XLE': CompanyTag(tag: 'Energy Sector', sector: 'ETF'),
    'XLV': CompanyTag(tag: 'Healthcare', sector: 'ETF'),
    'XLI': CompanyTag(tag: 'Industrial Sector', sector: 'ETF'),
    'XLP': CompanyTag(tag: 'Consumer Staples', sector: 'ETF'),
    'XLU': CompanyTag(tag: 'Utilities', sector: 'ETF'),
    'XLB': CompanyTag(tag: 'Materials', sector: 'ETF'),
    'XLRE': CompanyTag(tag: 'Real Estate', sector: 'ETF'),
    'SMH': CompanyTag(tag: 'Semiconductors', sector: 'ETF'),
    'SOXX': CompanyTag(tag: 'Semiconductors', sector: 'ETF'),
    'ARKK': CompanyTag(tag: 'Innovation • ARK', sector: 'ETF'),
    'ARKF': CompanyTag(tag: 'Fintech • ARK', sector: 'ETF'),
    'ARKW': CompanyTag(tag: 'Internet • ARK', sector: 'ETF'),
    'ARKG': CompanyTag(tag: 'Genomics • ARK', sector: 'ETF'),
    'TQQQ': CompanyTag(tag: 'NASDAQ x3', sector: 'ETF'),
    'SPXL': CompanyTag(tag: 'S&P 500 x3', sector: 'ETF'),
    'SQQQ': CompanyTag(tag: 'NASDAQ x3 Inverse', sector: 'ETF'),
    'SPXS': CompanyTag(tag: 'S&P 500 x3 Inverse', sector: 'ETF'),
    'UVXY': CompanyTag(tag: 'Volatility', sector: 'ETF'),
    'BITO': CompanyTag(tag: 'Bitcoin Futures', sector: 'ETF'),
    'IBIT': CompanyTag(tag: 'Bitcoin', sector: 'ETF'),
    'FBTC': CompanyTag(tag: 'Bitcoin', sector: 'ETF'),
    'GBTC': CompanyTag(tag: 'Bitcoin', sector: 'ETF'),
    'ETHA': CompanyTag(tag: 'Ethereum', sector: 'ETF'),

    // ---- Crypto / Blockchain ----
    'MARA': CompanyTag(tag: 'Bitcoin Mining', sector: 'Technology'),
    'RIOT': CompanyTag(tag: 'Bitcoin Mining', sector: 'Technology'),
    'CLSK': CompanyTag(tag: 'Bitcoin Mining', sector: 'Technology'),
    'WULF': CompanyTag(tag: 'Bitcoin Mining', sector: 'Technology'),
    'BTC': CompanyTag(tag: 'Bitcoin', sector: 'Crypto'),
    'ETH': CompanyTag(tag: 'Ethereum', sector: 'Crypto'),
    'SOL': CompanyTag(tag: 'Solana', sector: 'Crypto'),
    'XRP': CompanyTag(tag: 'Ripple', sector: 'Crypto'),
  };

  // ---------------------------------------------------------------------------
  // Fallback: keyword-based detection from company name
  // ---------------------------------------------------------------------------

  static final List<_NameRule> _nameRules = [
    _NameRule('Bank', 'Banking', 'Financial'),
    _NameRule('Bancorp', 'Banking', 'Financial'),
    _NameRule('Financial', 'Financial Services', 'Financial'),
    _NameRule('Insurance', 'Insurance', 'Financial'),
    _NameRule('Pharma', 'Pharmaceuticals', 'Healthcare'),
    _NameRule('Therapeutics', 'Biotechnology', 'Healthcare'),
    _NameRule('Biotech', 'Biotechnology', 'Healthcare'),
    _NameRule('Diagnostics', 'Diagnostics', 'Healthcare'),
    _NameRule('Medical', 'Medical Devices', 'Healthcare'),
    _NameRule('Health', 'Healthcare', 'Healthcare'),
    _NameRule('Hospital', 'Hospitals', 'Healthcare'),
    _NameRule('Oil', 'Oil & Gas', 'Energy'),
    _NameRule('Gas', 'Oil & Gas', 'Energy'),
    _NameRule('Energy', 'Energy', 'Energy'),
    _NameRule('Electric', 'Electric Utilities', 'Energy'),
    _NameRule('Renewable', 'Renewable Energy', 'Energy'),
    _NameRule('Solar', 'Solar Energy', 'Energy'),
    _NameRule('Airlines', 'Airlines', 'Logistics'),
    _NameRule('Airline', 'Airlines', 'Logistics'),
    _NameRule('Aviation', 'Aviation', 'Industrial'),
    _NameRule('Aerospace', 'Aerospace', 'Industrial'),
    _NameRule('Defense', 'Defense', 'Industrial'),
    _NameRule('Auto', 'Automotive', 'Automotive'),
    _NameRule('Motors', 'Automotive', 'Automotive'),
    _NameRule('Automotive', 'Automotive', 'Automotive'),
    _NameRule('Electric Vehicle', 'Electric Vehicles', 'Automotive'),
    _NameRule('Software', 'Software', 'Technology'),
    _NameRule('Technology', 'Technology', 'Technology'),
    _NameRule('Semiconductor', 'Semiconductors', 'Technology'),
    _NameRule('Micro', 'Semiconductors', 'Technology'),
    _NameRule('Cloud', 'Cloud Technology', 'Technology'),
    _NameRule('Cyber', 'Cybersecurity', 'Technology'),
    _NameRule('Security', 'Security', 'Technology'),
    _NameRule('Data', 'Data Analytics', 'Technology'),
    _NameRule('Communications', 'Telecom', 'Telecom'),
    _NameRule('Telecom', 'Telecom', 'Telecom'),
    _NameRule('Wireless', 'Telecom', 'Telecom'),
    _NameRule('Retail', 'Retail', 'Retail'),
    _NameRule('Supermarket', 'Retail • Supermarkets', 'Retail'),
    _NameRule('Grocery', 'Retail • Supermarkets', 'Retail'),
    _NameRule('Restaurant', 'Restaurants', 'Food Service'),
    _NameRule('Food', 'Food Industry', 'Food'),
    _NameRule('Beverage', 'Beverages', 'Food'),
    _NameRule('Consumer', 'Consumer Goods', 'Consumer'),
    _NameRule('Home', 'Home Goods', 'Consumer'),
    _NameRule('Apparel', 'Apparel', 'Retail'),
    _NameRule('Footwear', 'Footwear', 'Retail'),
    _NameRule('Sport', 'Sporting Goods', 'Retail'),
    _NameRule('Hotel', 'Hotels', 'Travel'),
    _NameRule('Resort', 'Resorts', 'Travel'),
    _NameRule('Travel', 'Travel', 'Travel'),
    _NameRule('Entertainment', 'Entertainment', 'Media'),
    _NameRule('Media', 'Media', 'Media'),
    _NameRule('Network', 'Media • Telecom', 'Media'),
    _NameRule('Real Estate', 'Real Estate', 'Real Estate'),
    _NameRule('REIT', 'Real Estate', 'Real Estate'),
    _NameRule('Industrial', 'Industrial', 'Industrial'),
    _NameRule('Machinery', 'Machinery', 'Industrial'),
    _NameRule('Construction', 'Construction', 'Industrial'),
    _NameRule('Engineering', 'Engineering', 'Industrial'),
    _NameRule('Chemical', 'Chemical Industry', 'Industrial'),
    _NameRule('Materials', 'Materials', 'Industrial'),
    _NameRule('Mining', 'Mining', 'Industrial'),
    _NameRule('Gold', 'Gold Mining', 'Industrial'),
    _NameRule('Copper', 'Copper', 'Industrial'),
    _NameRule('Steel', 'Steel', 'Industrial'),
    _NameRule('Logistics', 'Logistics', 'Logistics'),
    _NameRule('Delivery', 'Delivery', 'Logistics'),
    _NameRule('Transport', 'Transport', 'Logistics'),
    _NameRule('Rail', 'Railways', 'Logistics'),
    _NameRule('Freight', 'Freight', 'Logistics'),
    _NameRule('Payment', 'Payments', 'Financial'),
    _NameRule('Fintech', 'Fintech', 'Technology'),
    _NameRule('Venture', 'Venture Capital', 'Financial'),
    _NameRule('Capital', 'Investments', 'Financial'),
    _NameRule('Holdings', 'Holding', 'Financial'),
    _NameRule('Laborator', 'Pharmaceuticals', 'Healthcare'),
    _NameRule('Brewing', 'Brewing', 'Food'),
    _NameRule('Tobacco', 'Tobacco', 'Food'),
    _NameRule('Gaming', 'Gaming', 'Media'),
    _NameRule('Casino', 'Casinos', 'Travel'),
    _NameRule('Gambling', 'Gambling', 'Travel'),
    _NameRule('Betting', 'Betting', 'Travel'),
    _NameRule('Education', 'Education', 'Education'),
    _NameRule('Learning', 'Education', 'Education'),
    _NameRule('Tech', 'Technology', 'Technology'),
    _NameRule('Digital', 'Digital Technology', 'Technology'),
    _NameRule('eCommerce', 'E-commerce', 'Technology'),
    _NameRule('E-Commerce', 'E-commerce', 'Technology'),
    _NameRule('Online', 'Online Services', 'Technology'),
    _NameRule('Platform', 'Platform', 'Technology'),
    _NameRule('Corp', 'Corporation', null),
    _NameRule('Inc', 'Corporation', null),
    _NameRule('Limited', 'Corporation', null),
    _NameRule('Ltd', 'Corporation', null),
    _NameRule('PLC', 'Public Company', null),
    _NameRule('Group', 'Group', null),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns a short English tag for the given [ticker] and/or [companyName].
  ///
  /// Prioritises exact ticker match. Falls back to keyword detection
  /// from the company name. Returns `null` if no tag can be determined.
  static CompanyTag? tag(String ticker, {String? companyName}) {
    final cleanTicker = ticker.trim().toUpperCase();

    // 1. Exact ticker match
    final exact = _byTicker[cleanTicker];
    if (exact != null) return exact;

    // 2. Try with common suffixes stripped (e.g. ".ME", ".SS", ".L", ".DE")
    final baseTicker = cleanTicker.split('.').first;
    final baseMatch = _byTicker[baseTicker];
    if (baseMatch != null) return baseMatch;

    // 3. Try hyphenated (e.g. "BRK-B" -> "BRK.B"... skip, just try base)
    final hyphenBase = baseTicker.split('-').first;
    if (hyphenBase != baseTicker) {
      final hyphenMatch = _byTicker[hyphenBase];
      if (hyphenMatch != null) return hyphenMatch;
    }

    // 4. Keyword-based fallback from company name
    if (companyName != null && companyName.isNotEmpty) {
      return _matchByName(companyName);
    }

    return null;
  }

  /// Attempts to match a company name against keyword rules.
  static CompanyTag? _matchByName(String name) {
    final upper = name.toUpperCase();

    // Collect all matching rules with their priority (longer keyword = higher priority)
    _NameRule? best;
    int bestLen = 0;

    for (final rule in _nameRules) {
      if (upper.contains(rule.keyword.toUpperCase())) {
        final len = rule.keyword.length;
        // Skip generic fallback rules if we have a better match
        if (len > bestLen ||
            (len == bestLen && rule.sector != null && (best?.sector == null))) {
          best = rule;
          bestLen = len;
        }
      }
    }

    if (best != null) {
      return CompanyTag(tag: best.tag, sector: best.sector);
    }

    return null;
  }

  /// Returns `true` if the given [ticker] has a known tag.
  static bool hasTag(String ticker) {
    return _byTicker.containsKey(ticker.trim().toUpperCase());
  }

  /// Returns the number of known tickers in the map.
  static int get knownTickersCount => _byTicker.length;
}

// ---------------------------------------------------------------------------
// Internal: keyword-to-tag rule
// ---------------------------------------------------------------------------

class _NameRule {
  final String keyword;
  final String tag;
  final String? sector;

  const _NameRule(this.keyword, this.tag, this.sector);
}
