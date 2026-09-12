// ---------------------------------------------------------------------------
// Trade Proposal — ETF Fund Emulation, Phase 4. Mirrors
// scanco-backend's fundTradeService.js shape (fund_trade_proposals table).
// See docs/ETF_FUND_EMULATION.md's "Ветка «Инвестиционный помощник»" +
// "Роли и права сотрудников" for the full propose -> approve/reject ->
// (auto-execute or Trader-queued) -> executed flow this backs.
// ---------------------------------------------------------------------------

class TradeProposal {
  final String id;
  final String fundId;
  final String proposerUserId;
  final String symbol;
  final String side; // 'buy' | 'sell'
  final String orderType; // 'market' | 'limit'
  final double? limitPrice;
  final double quantity;
  final String? justification;
  final String status; // 'pending' | 'approved' | 'rejected' | 'executed'
  final bool flaggedRisky;
  final String? flaggedBy;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? rejectionReason;
  final double? executedPrice;
  final DateTime? executedAt;
  final DateTime createdAt;

  const TradeProposal({
    required this.id,
    required this.fundId,
    required this.proposerUserId,
    required this.symbol,
    required this.side,
    required this.orderType,
    this.limitPrice,
    required this.quantity,
    this.justification,
    required this.status,
    required this.flaggedRisky,
    this.flaggedBy,
    this.resolvedBy,
    this.resolvedAt,
    this.rejectionReason,
    this.executedPrice,
    this.executedAt,
    required this.createdAt,
  });

  bool get isBuy => side == 'buy';
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';

  factory TradeProposal.fromJson(Map<String, dynamic> json) => TradeProposal(
    id: json['id'] as String,
    fundId: json['fundId'] as String,
    proposerUserId: json['proposerUserId'] as String,
    symbol: json['symbol'] as String,
    side: json['side'] as String,
    orderType: json['orderType'] as String,
    limitPrice: (json['limitPrice'] as num?)?.toDouble(),
    quantity: (json['quantity'] as num).toDouble(),
    justification: json['justification'] as String?,
    status: json['status'] as String,
    flaggedRisky: json['flaggedRisky'] as bool? ?? false,
    flaggedBy: json['flaggedBy'] as String?,
    resolvedBy: json['resolvedBy'] as String?,
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'] as String)
        : null,
    rejectionReason: json['rejectionReason'] as String?,
    executedPrice: (json['executedPrice'] as num?)?.toDouble(),
    executedAt: json['executedAt'] != null
        ? DateTime.parse(json['executedAt'] as String)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
