// ---------------------------------------------------------------------------
// Order Execution Tests — Limit order simulation
// ---------------------------------------------------------------------------
// Tests the pure OrderExecutionService logic:
//   - Buy limit: set below market, wait for price drop → execution
//   - Sell limit: set above market, wait for price rise → execution
//   - Market order: immediate fill
//   - Limit at exact price: immediate fill
// ---------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/features/orders/order_model.dart';
import '../../lib/src/features/orders/order_execution_service.dart';
import '../../lib/src/features/portfolio/portfolio_providers.dart';

void main() {
  final service = OrderExecutionService();

  group('1. Market Orders — Immediate Execution', () {
    test('1.1 Buy market fills instantly at current price', () {
      final order = Order(
        orderId: 'test_mkt_buy',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.market,
        quantity: 10,
        createdPrice: 150.0,
      );

      final result = service.evaluateOrder(
        order: order,
        currentPrice: 150.0,
        session: MarketSession.regular,
      );

      expect(result.wasExecuted, isTrue);
      expect(result.updatedOrder.status, OrderStatus.filled);
      expect(result.updatedOrder.filledQuantity, closeTo(10, 0.01));
      expect(result.transaction, isNotNull);
      expect(result.transaction!.shares, closeTo(10, 0.01));
      expect(
        result.transaction!.price,
        inInclusiveRange(149.0, 151.0), // within slippage
      );
    });

    test('1.2 Sell market fills instantly at current price', () {
      final order = Order(
        orderId: 'test_mkt_sell',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.sell,
        type: OrderType.market,
        quantity: 5,
        createdPrice: 150.0,
      );

      final result = service.evaluateOrder(
        order: order,
        currentPrice: 150.0,
        session: MarketSession.regular,
      );

      expect(result.wasExecuted, isTrue);
      expect(result.updatedOrder.status, OrderStatus.filled);
      expect(result.transaction!.shares, closeTo(5, 0.01));
    });
  });

  group('2. Limit Orders — Conditional Execution', () {
    test('2.1 Buy limit below market — waits then executes on price drop', () {
      // Price is 150. Set limit at 145 (below market)
      final order = Order(
        orderId: 'test_limit_buy',
        portfolioId: 'pf1',
        assetSymbol: 'MSFT',
        side: OrderSide.buy,
        type: OrderType.limit,
        quantity: 20,
        createdPrice: 150.0,
        limitPrice: 145.0,
      );

      // Initially, price is 150 > 145 → should NOT execute
      final initialResult = service.evaluateOrder(
        order: order,
        currentPrice: 150.0,
        session: MarketSession.regular,
      );
      expect(initialResult.wasExecuted, isFalse);
      expect(initialResult.updatedOrder.status, OrderStatus.pending);
      expect(initialResult.message, contains('current > limit'));

      // Price drops to 144 (below 145 limit) → SHOULD execute
      final executedResult = service.evaluateOrder(
        order: initialResult.updatedOrder,
        currentPrice: 144.0,
        session: MarketSession.regular,
      );
      expect(executedResult.wasExecuted, isTrue);
      // Accept filled or partiallyFilled (partial fill is random 20%)
      expect(
        executedResult.updatedOrder.status.isTerminal ||
            executedResult.updatedOrder.status == OrderStatus.partiallyFilled,
        isTrue,
      );
      expect(executedResult.transaction, isNotNull);
      expect(executedResult.transaction!.symbol, equals('MSFT'));
      expect(executedResult.transaction!.type, TransactionType.buy);
      // Should execute at min(currentPrice, limit) = min(144, 145) = 144
      expect(executedResult.transaction!.price, closeTo(144.0, 0.01));
    });

    test('2.2 Sell limit above market — waits then executes on price rise', () {
      // Price is 100. Set limit at 105 (above market)
      final order = Order(
        orderId: 'test_limit_sell',
        portfolioId: 'pf1',
        assetSymbol: 'GOOGL',
        side: OrderSide.sell,
        type: OrderType.limit,
        quantity: 15,
        createdPrice: 100.0,
        limitPrice: 105.0,
      );

      // Initially, price is 100 < 105 → should NOT execute
      final initialResult = service.evaluateOrder(
        order: order,
        currentPrice: 100.0,
        session: MarketSession.regular,
      );
      expect(initialResult.wasExecuted, isFalse);
      expect(initialResult.updatedOrder.status, OrderStatus.pending);
      expect(initialResult.message, contains('current < limit'));

      // Price rises to 106 (above 105 limit) → SHOULD execute
      final executedResult = service.evaluateOrder(
        order: initialResult.updatedOrder,
        currentPrice: 106.0,
        session: MarketSession.regular,
      );
      expect(executedResult.wasExecuted, isTrue);
      // Accept filled or partiallyFilled (partial fill is random 20%)
      expect(
        executedResult.updatedOrder.status.isTerminal ||
            executedResult.updatedOrder.status == OrderStatus.partiallyFilled,
        isTrue,
      );
      expect(executedResult.transaction, isNotNull);
      expect(executedResult.transaction!.type, TransactionType.sell);
      // Should execute at max(currentPrice, limit) = max(106, 105) = 106
      expect(executedResult.transaction!.price, closeTo(106.0, 0.01));
    });

    test('2.3 Buy limit at exact price — executes immediately', () {
      // Price is 200. Limit is exactly 200.
      final order = Order(
        orderId: 'test_limit_exact',
        portfolioId: 'pf1',
        assetSymbol: 'NVDA',
        side: OrderSide.buy,
        type: OrderType.limit,
        quantity: 1, // quantity=1 avoids partial fill (requires remaining > 1)
        createdPrice: 200.0,
        limitPrice: 200.0,
      );

      final result = service.evaluateOrder(
        order: order,
        currentPrice: 200.0,
        session: MarketSession.regular,
      );

      expect(result.wasExecuted, isTrue);
      expect(result.updatedOrder.status, OrderStatus.filled);
      expect(result.transaction!.price, closeTo(200.0, 0.01));
    });

    test('2.4 Sell limit at exact price — executes immediately', () {
      final order = Order(
        orderId: 'test_limit_exact_sell',
        portfolioId: 'pf1',
        assetSymbol: 'KO',
        side: OrderSide.sell,
        type: OrderType.limit,
        quantity: 1, // quantity=1 avoids partial fill
        createdPrice: 68.0,
        limitPrice: 68.0,
      );

      final result = service.evaluateOrder(
        order: order,
        currentPrice: 68.0,
        session: MarketSession.regular,
      );

      expect(result.wasExecuted, isTrue);
      expect(result.updatedOrder.status, OrderStatus.filled);
      expect(result.transaction!.price, closeTo(68.0, 0.01));
    });
  });

  group('3. Batch Processing', () {
    test('3.1 Process multiple pending orders at once', () {
      final orders = [
        Order(
          orderId: 'batch_mkt',
          portfolioId: 'pf1',
          assetSymbol: 'AAPL',
          side: OrderSide.buy,
          type: OrderType.market,
          quantity: 5,
          createdPrice: 150.0,
        ),
        Order(
          orderId: 'batch_limit',
          portfolioId: 'pf1',
          assetSymbol: 'MSFT',
          side: OrderSide.buy,
          type: OrderType.limit,
          quantity: 1, // quantity=1 avoids partial fill
          createdPrice: 300.0,
          limitPrice: 290.0,
        ),
      ];

      // Price = 295. Market fills, limit waits (295 > 290)
      final batchResult = service.processPendingOrders(
        pendingOrders: orders,
        currentPrice: 295.0,
        session: MarketSession.regular,
      );

      expect(batchResult.results.length, equals(2));

      // Market order should be filled
      final mktResult = batchResult.results[0];
      expect(mktResult.wasExecuted, isTrue);
      expect(mktResult.updatedOrder.status, OrderStatus.filled);

      // Limit order should still be pending
      final limitResult = batchResult.results[1];
      expect(limitResult.wasExecuted, isFalse);
      expect(limitResult.updatedOrder.status, OrderStatus.pending);

      // Now price drops to 285 → limit should fill
      // NOTE: processPendingOrders skips filled orders (status not active)
      // So only the 1 pending limit order is processed on second pass
      final batchResult2 = service.processPendingOrders(
        pendingOrders: batchResult.updatedOrders,
        currentPrice: 285.0,
        session: MarketSession.regular,
      );

      // Only the pending (limit) order was processed
      expect(batchResult2.results.length, equals(1));
      final limitResult2 = batchResult2.results[0];
      expect(limitResult2.wasExecuted, isTrue);
      expect(limitResult2.updatedOrder.status, OrderStatus.filled);
    });
  });

  group('4. Market Session Rules', () {
    test('4.1 Market orders work in all trading sessions', () {
      final order = Order(
        orderId: 'session_mkt',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.market,
        quantity: 1,
        createdPrice: 150.0,
      );

      for (final session in [
        MarketSession.regular,
        MarketSession.preMarket,
        MarketSession.afterHours,
      ]) {
        final result = service.evaluateOrder(
          order: order,
          currentPrice: 150.0,
          session: session,
        );
        expect(result.wasExecuted, isTrue,
            reason: 'Market should execute in $session');
      }
    });

    test('4.2 Market orders wait if market is closed', () {
      final order = Order(
        orderId: 'session_closed',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.market,
        quantity: 1,
        createdPrice: 150.0,
      );

      final result = service.evaluateOrder(
        order: order,
        currentPrice: 150.0,
        session: MarketSession.closed,
      );

      expect(result.wasExecuted, isFalse);
      expect(result.updatedOrder.status, OrderStatus.pending);
    });

    test('4.3 Limit orders work in all sessions', () {
      final order = Order(
        orderId: 'session_limit',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.limit,
        quantity: 1, // quantity=1 avoids partial fill
        createdPrice: 150.0,
        limitPrice: 148.0,
      );

      for (final session in [
        MarketSession.regular,
        MarketSession.preMarket,
        MarketSession.afterHours,
        MarketSession.closed,
      ]) {
        final result = service.evaluateOrder(
          order: order.copyWith(status: OrderStatus.pending),
          currentPrice: 147.0,
          session: session,
        );
        expect(result.wasExecuted, isTrue,
            reason: 'Limit should execute in $session');
      }
    });
  });

  group('5. Real-World Simulation: Buy/Sell Limit', () {
    // Simulates: "Set limit slightly below current price, wait for drop"
    test('AAPL buy limit 2% below market → fills when price dips', () {
      final currentPrice = 178.0;
      final limitPrice = (currentPrice * 0.98); // 2% below = ~174.44

      final order = Order(
        orderId: 'sim_aapl_buy',
        portfolioId: 'pf1',
        assetSymbol: 'AAPL',
        side: OrderSide.buy,
        type: OrderType.limit,
        quantity: 50,
        createdPrice: currentPrice,
        limitPrice: limitPrice,
      );

      // Price stays high → no execution
      final result1 = service.evaluateOrder(
        order: order,
        currentPrice: 180.0,
        session: MarketSession.regular,
      );
      expect(result1.wasExecuted, isFalse);

      // Price dips to 174 (below limit of 174.44) → fills
      final result2 = service.evaluateOrder(
        order: result1.updatedOrder,
        currentPrice: 174.0,
        session: MarketSession.regular,
      );
      expect(result2.wasExecuted, isTrue);
      expect(result2.transaction, isNotNull);
      expect(result2.transaction!.price, closeTo(174.0, 0.01));
      print('  → Bought 50 AAPL at \$${result2.transaction!.price.toStringAsFixed(2)} '
          '(limit: \$${limitPrice.toStringAsFixed(2)}, market was: \$178.00)');
    });

    test('MSFT sell limit 2% above market → fills when price rises', () {
      final currentPrice = 378.0;
      final limitPrice = (currentPrice * 1.02); // 2% above = ~385.56

      final order = Order(
        orderId: 'sim_msft_sell',
        portfolioId: 'pf1',
        assetSymbol: 'MSFT',
        side: OrderSide.sell,
        type: OrderType.limit,
        quantity: 20,
        createdPrice: currentPrice,
        limitPrice: limitPrice,
      );

      // Price stays low → no execution
      final result1 = service.evaluateOrder(
        order: order,
        currentPrice: 376.0,
        session: MarketSession.regular,
      );
      expect(result1.wasExecuted, isFalse);

      // Price rises to 386 (above limit of 385.56) → fills
      final result2 = service.evaluateOrder(
        order: result1.updatedOrder,
        currentPrice: 386.0,
        session: MarketSession.regular,
      );
      expect(result2.wasExecuted, isTrue);
      expect(result2.transaction, isNotNull);
      // Should execute at max(currentPrice, limit) = max(386, 385.56) = 386
      expect(result2.transaction!.price, closeTo(386.0, 0.01));
      print('  → Sold 20 MSFT at \$${result2.transaction!.price.toStringAsFixed(2)} '
          '(limit: \$${limitPrice.toStringAsFixed(2)}, market was: \$378.00)');
    });
  });
}
