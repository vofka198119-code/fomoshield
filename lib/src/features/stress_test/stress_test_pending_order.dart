// ---------------------------------------------------------------------------
// Stress Test Pending Order — Limit orders for the simulator
// ---------------------------------------------------------------------------
// Deliberately its own model/provider, entirely separate from the real
// `lib/src/features/orders/` order system and from `StressTestSession`
// itself — per user's explicit ask (2026-08-02) to keep Stress Test's new
// limit-order mechanics isolated so nothing "намешалось" (gets mixed in)
// with either the real orders feature or the simulation engine's own
// state. Fills are executed via the existing, UNMODIFIED
// `StressTestNotifier.executeTrade` — this file never touches
// stress_test_engine.dart/trades_engine.dart's logic, only calls into it.
// ---------------------------------------------------------------------------

enum StressTestOrderStatus { pending, filled, cancelled }

class StressTestPendingOrder {
  final String id;
  final String sessionId;
  final String symbol;
  final bool isBuy;
  final double quantity; // shares
  final double limitPrice;
  final DateTime createdAt;
  final StressTestOrderStatus status;

  const StressTestPendingOrder({
    required this.id,
    required this.sessionId,
    required this.symbol,
    required this.isBuy,
    required this.quantity,
    required this.limitPrice,
    required this.createdAt,
    this.status = StressTestOrderStatus.pending,
  });

  StressTestPendingOrder copyWith({StressTestOrderStatus? status}) =>
      StressTestPendingOrder(
        id: id,
        sessionId: sessionId,
        symbol: symbol,
        isBuy: isBuy,
        quantity: quantity,
        limitPrice: limitPrice,
        createdAt: createdAt,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'symbol': symbol,
    'isBuy': isBuy,
    'quantity': quantity,
    'limitPrice': limitPrice,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
  };

  factory StressTestPendingOrder.fromJson(Map<String, dynamic> json) =>
      StressTestPendingOrder(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        symbol: json['symbol'] as String,
        isBuy: json['isBuy'] as bool,
        quantity: (json['quantity'] as num).toDouble(),
        limitPrice: (json['limitPrice'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: StressTestOrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => StressTestOrderStatus.pending,
        ),
      );
}
