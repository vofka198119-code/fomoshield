// ---------------------------------------------------------------------------
// Fund Liquidation Payout — one settlement owed to the current user from a
// fund's bankruptcy, not yet claimed. GET /employees/me/liquidation-payouts.
// `details` mirrors what fundBankruptcyService.js writes: reason,
// fundName, fundTicker, assetsSoldValue/brokerCommission/neustoika (the
// latter two investor-only), date. See fomoshield_etf_bankruptcy_flow_spec
// memory for the full formula.
// ---------------------------------------------------------------------------

class FundLiquidationPayout {
  final String id;
  final String fundId;
  final String recipientType; // 'employee' | 'investor'
  final double amount;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  const FundLiquidationPayout({
    required this.id,
    required this.fundId,
    required this.recipientType,
    required this.amount,
    required this.details,
    required this.createdAt,
  });

  String? get fundName => details['fundName'] as String?;
  String? get fundTicker => details['fundTicker'] as String?;
  double? get assetsSoldValue => (details['assetsSoldValue'] as num?)?.toDouble();
  double? get unitsHeld => (details['unitsHeld'] as num?)?.toDouble();
  double? get brokerCommission => (details['brokerCommission'] as num?)?.toDouble();
  double? get neustoika => (details['neustoika'] as num?)?.toDouble();

  factory FundLiquidationPayout.fromJson(Map<String, dynamic> json) {
    return FundLiquidationPayout(
      id: json['id'] as String,
      fundId: json['fundId'] as String,
      recipientType: json['recipientType'] as String,
      amount: (json['amount'] as num).toDouble(),
      details: Map<String, dynamic>.from(json['details'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
