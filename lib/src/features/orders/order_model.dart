// ---------------------------------------------------------------------------
// Order Model — Full order lifecycle for the portfolio simulator
// ---------------------------------------------------------------------------
// An Order is NOT a Transaction. Orders are created, then may be executed.
// MarketSession, OrderSide, OrderType, OrderStatus, Order.
// ---------------------------------------------------------------------------

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
// Helper: determine market session by current time
// ---------------------------------------------------------------------------

MarketSession currentMarketSession() {
  final now = DateTime.now();
  final hour = now.hour;
  final minute = now.minute;
  final totalMinutes = hour * 60 + minute;

  // Approximate US market hours (ET):
  //   Pre-market: 4:00-9:30 (240-570 min)
  //   Regular:    9:30-16:00 (570-960 min)
  //   After-hours: 16:00-20:00 (960-1200 min)
  //   Closed:     20:00-4:00
  // Weekends → closed
  if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
    return MarketSession.closed;
  }

  if (totalMinutes >= 240 && totalMinutes < 570) {
    return MarketSession.preMarket;
  } else if (totalMinutes >= 570 && totalMinutes < 960) {
    return MarketSession.regular;
  } else if (totalMinutes >= 960 && totalMinutes < 1200) {
    return MarketSession.afterHours;
  } else {
    return MarketSession.closed;
  }
}
