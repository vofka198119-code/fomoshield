import 'rebalance_leg.dart';

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
  final String? proposerNickname;

  /// 'trade' — one company, the shape every proposal had before phase 4.
  /// 'rebalance' — a whole batch, carried in [legs] (Migration 035).
  final String kind;

  /// The batch, for a rebalance. Null for an ordinary trade.
  final List<RebalanceLeg>? legs;

  /// 'cash' or 'full' — which route produced the batch. Null for a trade.
  final String? rebalanceMode;

  // The four below describe a single trade and are therefore NULL on a
  // rebalance. Nullable on purpose: every screen that shows a proposal has
  // to decide what it does with a batch, and the compiler is a better
  // reminder of that than a comment.
  final String? symbol;
  final String? side; // 'buy' | 'sell'
  final String? orderType; // 'market' | 'limit'
  final double? limitPrice;
  final double? quantity;
  final String? justification;
  final String status; // 'pending' | 'approved' | 'rejected' | 'executed'
  final bool flaggedRisky;
  final String? flaggedBy;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String? rejectionReason;
  final double? executedPrice;
  final double? commission;
  final DateTime? executedAt;
  final DateTime createdAt;

  const TradeProposal({
    required this.id,
    required this.fundId,
    required this.proposerUserId,
    this.proposerNickname,
    this.kind = 'trade',
    this.legs,
    this.rebalanceMode,
    this.symbol,
    this.side,
    this.orderType,
    this.limitPrice,
    this.quantity,
    this.justification,
    required this.status,
    required this.flaggedRisky,
    this.flaggedBy,
    this.resolvedBy,
    this.resolvedAt,
    this.rejectionReason,
    this.executedPrice,
    this.commission,
    this.executedAt,
    required this.createdAt,
  });

  bool get isRebalance => kind == 'rebalance';
  bool get isBuy => side == 'buy';

  /// Legs, or an empty list — saves every caller a null check on a list that
  /// means "nothing to show" when absent.
  List<RebalanceLeg> get legList => legs ?? const [];
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';

  factory TradeProposal.fromJson(Map<String, dynamic> json) => TradeProposal(
    id: json['id'] as String,
    fundId: json['fundId'] as String,
    proposerUserId: json['proposerUserId'] as String,
    proposerNickname: json['proposerNickname'] as String?,
    // Defaults to 'trade' so a server that has not been updated yet, or a
    // row written before Migration 035, still reads correctly.
    kind: json['kind'] as String? ?? 'trade',
    legs: (json['legs'] as List?)
        ?.map((e) => RebalanceLeg.fromJson(e as Map<String, dynamic>))
        .toList(),
    rebalanceMode: json['rebalanceMode'] as String?,
    symbol: json['symbol'] as String?,
    side: json['side'] as String?,
    orderType: json['orderType'] as String?,
    limitPrice: (json['limitPrice'] as num?)?.toDouble(),
    quantity: (json['quantity'] as num?)?.toDouble(),
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
    commission: (json['commission'] as num?)?.toDouble(),
    executedAt: json['executedAt'] != null
        ? DateTime.parse(json['executedAt'] as String)
        : null,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
