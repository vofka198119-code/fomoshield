// ---------------------------------------------------------------------------
// Fund models — ETF Fund Emulation, Phase 1 (docs/ETF_FUND_EMULATION.md).
// Mirrors the shapes returned by scanco-backend's fundService.js
// (shapeFund/getFundDetail) — see src/routes/funds.js in that repo.
// ---------------------------------------------------------------------------

class Fund {
  final String id;
  final String headUserId;
  final String name;
  final String ticker;
  final String? description;
  final String? strategy;
  final List<String> sectors;
  final double startingCapital;
  final double unitsOutstanding;
  final String status;
  final DateTime createdAt;
  final double navPerUnit;
  final double aum;
  final String? lastInviteMessage;

  const Fund({
    required this.id,
    required this.headUserId,
    required this.name,
    required this.ticker,
    this.description,
    this.strategy,
    required this.sectors,
    required this.startingCapital,
    required this.unitsOutstanding,
    required this.status,
    required this.createdAt,
    required this.navPerUnit,
    required this.aum,
    this.lastInviteMessage,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'] as String,
      headUserId: json['headUserId'] as String,
      name: json['name'] as String,
      ticker: json['ticker'] as String,
      description: json['description'] as String?,
      strategy: json['strategy'] as String?,
      sectors: (json['sectors'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      startingCapital: (json['startingCapital'] as num).toDouble(),
      unitsOutstanding: (json['unitsOutstanding'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      navPerUnit: (json['navPerUnit'] as num).toDouble(),
      aum: (json['aum'] as num).toDouble(),
      lastInviteMessage: json['lastInviteMessage'] as String?,
    );
  }
}

class FundHolding {
  final String symbol;
  final double quantity;
  final double price;
  final double value;
  // Weighted-average buy price, maintained server-side by fund_execute_trade
  // (Migration 021) — 0 for a holding bought before that migration ran, so
  // callers should treat 0 as "no cost basis yet" rather than a real P&L.
  final double avgCost;

  const FundHolding({
    required this.symbol,
    required this.quantity,
    required this.price,
    required this.value,
    required this.avgCost,
  });

  double get costBasis => quantity * avgCost;
  double get pnl => value - costBasis;
  double get pnlPercent => avgCost > 0 ? (price - avgCost) / avgCost * 100 : 0;

  factory FundHolding.fromJson(Map<String, dynamic> json) => FundHolding(
    symbol: json['symbol'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    price: (json['price'] as num).toDouble(),
    value: (json['value'] as num).toDouble(),
    avgCost: (json['avgCost'] as num?)?.toDouble() ?? 0,
  );
}

class FundNavPoint {
  final DateTime date;
  final double navPerUnit;

  const FundNavPoint({required this.date, required this.navPerUnit});

  factory FundNavPoint.fromJson(Map<String, dynamic> json) => FundNavPoint(
    date: DateTime.parse(json['date'] as String),
    navPerUnit: (json['navPerUnit'] as num).toDouble(),
  );
}

/// The fund detail endpoint returns every [Fund] field flattened alongside
/// cash/holdings/navHistory — [Fund.fromJson] on the same map picks out its
/// own subset, this just adds the rest.
class FundDetail extends Fund {
  final double cash;
  final List<FundHolding> holdings;
  final List<FundNavPoint> navHistory;

  const FundDetail({
    required super.id,
    required super.headUserId,
    required super.name,
    required super.ticker,
    super.description,
    super.strategy,
    required super.sectors,
    required super.startingCapital,
    required super.unitsOutstanding,
    required super.status,
    required super.createdAt,
    required super.navPerUnit,
    required super.aum,
    super.lastInviteMessage,
    required this.cash,
    required this.holdings,
    required this.navHistory,
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    final base = Fund.fromJson(json);
    return FundDetail(
      id: base.id,
      headUserId: base.headUserId,
      name: base.name,
      ticker: base.ticker,
      description: base.description,
      strategy: base.strategy,
      sectors: base.sectors,
      startingCapital: base.startingCapital,
      unitsOutstanding: base.unitsOutstanding,
      status: base.status,
      createdAt: base.createdAt,
      navPerUnit: base.navPerUnit,
      aum: base.aum,
      lastInviteMessage: base.lastInviteMessage,
      cash: (json['cash'] as num).toDouble(),
      holdings: (json['holdings'] as List<dynamic>? ?? const [])
          .map((e) => FundHolding.fromJson(e as Map<String, dynamic>))
          .toList(),
      navHistory: (json['navHistory'] as List<dynamic>? ?? const [])
          .map((e) => FundNavPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
