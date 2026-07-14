// ---------------------------------------------------------------------------
// Order Execution Service — evaluates and executes pending orders
// ---------------------------------------------------------------------------
// Pure logic, no state. Operates on orders passed to it.
// Handles: Market (immediate), Limit (price check), Stop (trigger),
// Stop-Limit (trigger → limit), Partial fills, Market session rules.
// ---------------------------------------------------------------------------

import 'dart:math';
import 'order_model.dart';
import '../portfolio/portfolio_providers.dart';

/// Result of evaluating/executing a single order
class OrderExecutionResult {
  final Order updatedOrder;
  final Transaction? transaction;
  final bool wasExecuted;
  final String? message;

  const OrderExecutionResult({
    required this.updatedOrder,
    this.transaction,
    required this.wasExecuted,
    this.message,
  });
}

/// Batch result from processing all pending orders
class OrderBatchResult {
  final List<OrderExecutionResult> results;
  final MarketSession session;
  final DateTime processedAt;

  const OrderBatchResult({
    required this.results,
    required this.session,
    required this.processedAt,
  });

  List<Order> get updatedOrders => results.map((r) => r.updatedOrder).toList();
  List<Transaction> get transactions =>
      results.where((r) => r.transaction != null).map((r) => r.transaction!).toList();
}

// ---------------------------------------------------------------------------
// Execution Engine
// ---------------------------------------------------------------------------

class OrderExecutionService {
  final Random _random = Random();

  // -----------------------------------------------------------------------
  // Market session rules
  // -----------------------------------------------------------------------

  /// Whether an order of [type] can be placed/executed in [session]
  bool canTradeInSession(OrderType type, MarketSession session) {
    if (session == MarketSession.closed) return false;
    if (session == MarketSession.regular) return true;
    // Pre-market / After-hours
    if (type == OrderType.market) return true;
    if (type == OrderType.limit) return true;
    return session == MarketSession.regular;
  }

  /// Estimated spread multiplier by session (for realistic fills)
  double _spreadMultiplier(MarketSession session) {
    switch (session) {
      case MarketSession.regular:
        return 1.0; // normal
      case MarketSession.preMarket:
        return 1.5; // 50% wider spread
      case MarketSession.afterHours:
        return 1.3; // 30% wider spread
      case MarketSession.closed:
        return 2.0; // 2x spread (theoretical)
    }
  }

  // -----------------------------------------------------------------------
  // Main evaluation
  // -----------------------------------------------------------------------

  /// Evaluate a single order against current market conditions.
  /// Returns the updated order + optional transaction.
  OrderExecutionResult evaluateOrder({
    required Order order,
    required double currentPrice,
    required MarketSession session,
  }) {
    // Only active orders can be evaluated
    if (!order.status.isActive) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Order is ${order.status.label}',
      );
    }

    // Check if market is closed
    if (session == MarketSession.closed && order.type == OrderType.market) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Market is closed. Order will wait for opening.',
      );
    }

    // Evaluate based on order type
    switch (order.type) {
      case OrderType.market:
        return _evaluateMarket(order, currentPrice, session);
      case OrderType.limit:
        return _evaluateLimit(order, currentPrice, session);
      case OrderType.stop:
        return _evaluateStop(order, currentPrice, session);
      case OrderType.stopLimit:
        return _evaluateStopLimit(order, currentPrice, session);
    }
  }

  /// Process a batch of pending orders
  OrderBatchResult processPendingOrders({
    required List<Order> pendingOrders,
    required double currentPrice,
    required MarketSession session,
  }) {
    final results = <OrderExecutionResult>[];

    for (final order in pendingOrders) {
      if (!order.status.isActive) continue;
      final result = evaluateOrder(
        order: order,
        currentPrice: currentPrice,
        session: session,
      );
      results.add(result);
    }

    return OrderBatchResult(
      results: results,
      session: session,
      processedAt: DateTime.now(),
    );
  }

  // -----------------------------------------------------------------------
  // Market order — immediate execution
  // -----------------------------------------------------------------------

  OrderExecutionResult _evaluateMarket(
    Order order,
    double currentPrice,
    MarketSession session,
  ) {
    final spread = _spreadMultiplier(session);
    // Market buy: pay ask price (slightly above), sell: get bid price (slightly below)
    final slippage = currentPrice * 0.001 * spread; // 0.1% base slippage
    final executionPrice = order.side == OrderSide.buy
        ? currentPrice + slippage
        : currentPrice - slippage;

    return _fillOrder(order, executionPrice, order.remainingQuantity);
  }

  // -----------------------------------------------------------------------
  // Limit order — executes when price is at or better than limit
  // -----------------------------------------------------------------------

  OrderExecutionResult _evaluateLimit(
    Order order,
    double currentPrice,
    MarketSession session,
  ) {
    if (order.limitPrice == null) {
      return OrderExecutionResult(
        updatedOrder: order.copyWith(status: OrderStatus.cancelled),
        wasExecuted: true,
        message: 'Invalid: limit price not set',
      );
    }

    final limit = order.limitPrice!;
    bool canExecute;

    if (order.side == OrderSide.buy) {
      // Buy: execute if currentPrice <= limitPrice
      canExecute = currentPrice <= limit;
    } else {
      // Sell: execute if currentPrice >= limitPrice
      canExecute = currentPrice >= limit;
    }

    if (!canExecute) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Waiting: ${order.side == OrderSide.buy ? 'current > limit' : 'current < limit'}',
      );
    }

    // Execute — use limit price (or better)
    final executionPrice = order.side == OrderSide.buy
        ? min(currentPrice, limit)
        : max(currentPrice, limit);

    return _fillWithPartial(order, executionPrice);
  }

  // -----------------------------------------------------------------------
  // Stop order — triggers market order when price hits stop
  // -----------------------------------------------------------------------

  OrderExecutionResult _evaluateStop(
    Order order,
    double currentPrice,
    MarketSession session,
  ) {
    if (order.stopPrice == null) {
      return OrderExecutionResult(
        updatedOrder: order.copyWith(status: OrderStatus.cancelled),
        wasExecuted: true,
        message: 'Invalid: stop price not set',
      );
    }

    final stop = order.stopPrice!;
    bool triggered;

    if (order.side == OrderSide.buy) {
      // Buy stop (often used to buy on breakout): trigger when price >= stop
      triggered = currentPrice >= stop;
    } else {
      // Sell stop (stop-loss): trigger when price <= stop
      triggered = currentPrice <= stop;
    }

    if (!triggered) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Stop not triggered',
      );
    }

    // Convert to market execution once triggered
    final slippage = currentPrice * 0.002; // 0.2% slippage on stop
    final executionPrice = order.side == OrderSide.buy
        ? currentPrice + slippage
        : currentPrice - slippage;

    return _fillOrder(order, executionPrice, order.remainingQuantity);
  }

  // -----------------------------------------------------------------------
  // Stop-Limit — trigger → limit order
  // -----------------------------------------------------------------------

  OrderExecutionResult _evaluateStopLimit(
    Order order,
    double currentPrice,
    MarketSession session,
  ) {
    if (order.stopPrice == null || order.limitPrice == null) {
      return OrderExecutionResult(
        updatedOrder: order.copyWith(status: OrderStatus.cancelled),
        wasExecuted: true,
        message: 'Invalid: stop/limit price not set',
      );
    }

    final stop = order.stopPrice!;
    final limit = order.limitPrice!;
    bool triggered;

    if (order.side == OrderSide.buy) {
      triggered = currentPrice >= stop;
    } else {
      triggered = currentPrice <= stop;
    }

    if (!triggered) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Stop not triggered',
      );
    }

    // Once triggered, behaves like a limit order
    bool canExecute;
    if (order.side == OrderSide.buy) {
      canExecute = currentPrice <= limit;
    } else {
      canExecute = currentPrice >= limit;
    }

    if (!canExecute) {
      return OrderExecutionResult(
        updatedOrder: order,
        wasExecuted: false,
        message: 'Stop triggered, waiting for limit price',
      );
    }

    final executionPrice = order.side == OrderSide.buy
        ? min(currentPrice, limit)
        : max(currentPrice, limit);

    return _fillWithPartial(order, executionPrice);
  }

  // -----------------------------------------------------------------------
  // Filling logic
  // -----------------------------------------------------------------------

  /// Full fill of remaining quantity
  OrderExecutionResult _fillOrder(
    Order order,
    double executionPrice,
    double fillQuantity,
  ) {
    final newFilled = order.filledQuantity + fillQuantity;
    final isFull = newFilled >= order.quantity - 0.0001;

    final updatedOrder = order.copyWith(
      status: isFull ? OrderStatus.filled : OrderStatus.partiallyFilled,
      filledQuantity: newFilled,
      filledPrice: executionPrice,
      filledAt: isFull ? DateTime.now() : null,
    );

    final tx = Transaction(
      symbol: order.assetSymbol,
      type: order.side == OrderSide.buy
          ? TransactionType.buy
          : TransactionType.sell,
      shares: fillQuantity,
      price: executionPrice,
      date: DateTime.now(),
    );

    return OrderExecutionResult(
      updatedOrder: updatedOrder,
      transaction: tx,
      wasExecuted: true,
      message: isFull ? 'Filled at \$${executionPrice.toStringAsFixed(2)}' : 'Partially filled',
    );
  }

  /// Fill with potential partial fill for realism
  OrderExecutionResult _fillWithPartial(Order order, double executionPrice) {
    // For limit orders, simulate partial fill ~20% of the time
    // Fill between 30-100% of remaining
    final remaining = order.remainingQuantity;
    final willBePartial = remaining > 1 && _random.nextDouble() < 0.2;

    double fillQuantity;
    if (willBePartial) {
      fillQuantity = remaining * (0.3 + _random.nextDouble() * 0.5);
      fillQuantity = (fillQuantity * 100).round() / 100; // round to 2 decimals
    } else {
      fillQuantity = remaining;
    }

    return _fillOrder(order, executionPrice, fillQuantity);
  }
}
