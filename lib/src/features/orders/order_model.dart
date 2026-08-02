// ---------------------------------------------------------------------------
// Order Model — Full order lifecycle for the portfolio simulator
// ---------------------------------------------------------------------------
// An Order is NOT a Transaction. Orders are created, then may be executed.
// MarketSession, OrderSide, OrderType, OrderStatus, Order.
// ---------------------------------------------------------------------------

import '../market_clock/market_clock_engine.dart' as market_clock;

/// Market session modes
enum MarketSession {
  regular('Regular'),
  preMarket('Pre-Market'),
  afterHours('After-Hours'),
  closed('Closed');

  final String label;
  const MarketSession(this.label);

  bool get isTrading => this != closed;
  bool get isRegular => this == regular;
}

/// Order side
enum OrderSide { buy, sell }

/// Order type
enum OrderType {
  market('Market'),
  limit('Limit'),
  stop('Stop'),
  stopLimit('Stop-Limit');

  final String label;
  const OrderType(this.label);
}

/// Order status
enum OrderStatus {
  pending('Pending'),
  partiallyFilled('Partially Filled'),
  filled('Filled'),
  cancelled('Cancelled'),
  expired('Expired');

  final String label;
  const OrderStatus(this.label);

  bool get isActive => this == pending || this == partiallyFilled;
  bool get isTerminal => this == filled || this == cancelled || this == expired;
}

// ---------------------------------------------------------------------------
// Order entity
// ---------------------------------------------------------------------------

class Order {
  final String orderId;
  final String? userId;
  final String portfolioId;
  final String assetSymbol;
  final OrderSide side;
  final OrderType type;
  final double quantity;
  final double createdPrice;
  final double? limitPrice;
  final double? stopPrice;
  OrderStatus status;
  double filledQuantity;
  double? filledPrice;
  DateTime? filledAt;
  final DateTime createdAt;
  MarketSession session;

  Order({
    required this.orderId,
    this.userId,
    required this.portfolioId,
    required this.assetSymbol,
    required this.side,
    required this.type,
    required this.quantity,
    required this.createdPrice,
    this.limitPrice,
    this.stopPrice,
    this.status = OrderStatus.pending,
    this.filledQuantity = 0,
    this.filledPrice,
    this.filledAt,
    DateTime? createdAt,
    this.session = MarketSession.regular,
  }) : createdAt = createdAt ?? DateTime.now();

  // -----------------------------------------------------------------------
  // Computed
  // -----------------------------------------------------------------------

  /// Remaining unfilled quantity
  double get remainingQuantity => quantity - filledQuantity;

  /// Whether the order is fully filled
  bool get isFullyFilled => filledQuantity >= quantity;

  /// Whether this order can be cancelled
  bool get canCancel => status.isActive;

  // -----------------------------------------------------------------------
  // JSON
  // -----------------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'userId': userId,
        'portfolioId': portfolioId,
        'assetSymbol': assetSymbol,
        'side': side.name,
        'type': type.name,
        'quantity': quantity,
        'createdPrice': createdPrice,
        'limitPrice': limitPrice,
        'stopPrice': stopPrice,
        'status': status.name,
        'filledQuantity': filledQuantity,
        'filledPrice': filledPrice,
        'filledAt': filledAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'session': session.name,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json['orderId'] as String,
        userId: json['userId'] as String?,
        portfolioId: json['portfolioId'] as String,
        assetSymbol: json['assetSymbol'] as String,
        side: OrderSide.values.firstWhere((e) => e.name == json['side']),
        type: OrderType.values.firstWhere((e) => e.name == json['type']),
        quantity: (json['quantity'] as num).toDouble(),
        createdPrice: (json['createdPrice'] as num).toDouble(),
        limitPrice: (json['limitPrice'] as num?)?.toDouble(),
        stopPrice: (json['stopPrice'] as num?)?.toDouble(),
        status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
        filledQuantity: (json['filledQuantity'] as num?)?.toDouble() ?? 0,
        filledPrice: (json['filledPrice'] as num?)?.toDouble(),
        filledAt: json['filledAt'] != null
            ? DateTime.parse(json['filledAt'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        session: json['session'] != null
            ? MarketSession.values.firstWhere((e) => e.name == json['session'])
            : MarketSession.regular,
      );

  Order copyWith({
    OrderStatus? status,
    double? filledQuantity,
    double? filledPrice,
    DateTime? filledAt,
    MarketSession? session,
  }) =>
      Order(
        orderId: orderId,
        userId: userId,
        portfolioId: portfolioId,
        assetSymbol: assetSymbol,
        side: side,
        type: type,
        quantity: quantity,
        createdPrice: createdPrice,
        limitPrice: limitPrice,
        stopPrice: stopPrice,
        status: status ?? this.status,
        filledQuantity: filledQuantity ?? this.filledQuantity,
        filledPrice: filledPrice ?? this.filledPrice,
        filledAt: filledAt ?? this.filledAt,
        createdAt: createdAt,
        session: session ?? this.session,
      );
}

// ---------------------------------------------------------------------------
// Helper: determine market session by current (real) time
// ---------------------------------------------------------------------------

/// Real NYSE session right now, delegating to the Market Clock engine so
/// this stays correct for New York time (not device-local time) and knows
/// about weekends/holidays/early closes — all things a naive hour/minute
/// check here used to get wrong.
MarketSession currentMarketSession() {
  final state = market_clock.resolveMarketClockState(market_clock.nowInNewYork());
  switch (state.phase) {
    case market_clock.MarketPhase.preMarket:
      return MarketSession.preMarket;
    case market_clock.MarketPhase.marketOpen:
      return MarketSession.regular;
    case market_clock.MarketPhase.afterHours:
      return MarketSession.afterHours;
    case market_clock.MarketPhase.closed:
      return MarketSession.closed;
  }
}
