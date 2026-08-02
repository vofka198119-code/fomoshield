// ---------------------------------------------------------------------------
// Stress Test Order Entry Screen — buy/sell for stress test
// ---------------------------------------------------------------------------
// Visual layer restyled 2026-08-02 to match Portfolio's order entry
// exactly — reuses Portfolio's shared order_entry/ widgets (they're pure
// presentational components, no coupling to the real orders/portfolio
// providers) so both screens stay pixel-identical for free. The
// MECHANICS stay entirely separate: Market orders call the existing,
// unmodified StressTestNotifier.executeTrade; Limit orders are handled
// by Stress Test's own stress_test_pending_orders_provider.dart, never
// the real orders feature. No Extended Hours toggle — the simulated
// market is always open.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/guardian/guardian_engine.dart';
import '../../../shared/guardian/guardian_providers.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';
import '../../stress_test/stress_test_pending_orders_provider.dart';
import '../../portfolio/screens/order_entry/order_header.dart';
import '../../portfolio/screens/order_entry/order_amount_section.dart';
import '../../portfolio/screens/order_entry/order_config_section.dart';
import '../../portfolio/screens/order_entry/order_bottom_button.dart';
import '../../portfolio/screens/order_entry/amount_keypad.dart';
import '../../portfolio/screens/order_entry/trade_confirmation_toast.dart';

enum _OrderType { market, limit }
enum _ActiveKeypad { none, amount, limitPrice }

class OrderEntryScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String symbol;
  final String orderType; // 'buy' or 'sell'
  final double price;

  const OrderEntryScreen({
    super.key,
    required this.sessionId,
    required this.symbol,
    required this.orderType,
    required this.price,
  });

  @override
  ConsumerState<OrderEntryScreen> createState() => _OrderEntryScreenState();
}

class _OrderEntryScreenState extends ConsumerState<OrderEntryScreen> {
  _OrderType _selectedOrderType = _OrderType.market;
  OrderInputMode _inputMode = OrderInputMode.cost;
  final _amountController = TextEditingController();
  final _limitPriceController = TextEditingController();
  double _sliderValue = 0;
  _ActiveKeypad _activeKeypad = _ActiveKeypad.none;
  String? _limitPriceBeforeEdit;

  @override
  void dispose() {
    _amountController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  bool get _isBuy => widget.orderType == 'buy';

  StressTestSession? get _session {
    return ref.read(stressTestProvider.notifier).getSession(widget.sessionId);
  }

  StressTestHolding? _findHolding(StressTestSession session) {
    try {
      return session.holdings.firstWhere((h) => h.symbol == widget.symbol);
    } catch (_) {
      return null;
    }
  }

  double get _availableCash => _session?.cash ?? 0;

  double get _heldShares {
    final session = _session;
    if (session == null) return 0;
    return _findHolding(session)?.shares ?? 0;
  }

  double get _currentPrice {
    final session = _session;
    if (session == null) return widget.price;
    return session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        widget.price;
  }

  String get _infoText {
    switch (_selectedOrderType) {
      case _OrderType.market:
        return 'Market orders execute at the best available simulated price. '
            'Execution is guaranteed, but the final price may differ from expectations.';
      case _OrderType.limit:
        return 'Limit orders execute only once the simulated price reaches your '
            'chosen price or better. Execution is not guaranteed.';
    }
  }

  void _onOrderTypeChanged(bool isLimit) {
    setState(() {
      _selectedOrderType = isLimit ? _OrderType.limit : _OrderType.market;
      if (isLimit) {
        _limitPriceController.text = _currentPrice.toStringAsFixed(2);
      } else {
        _limitPriceController.clear();
      }
    });
  }

  void _onAmountTextChanged() {
    setState(() {
      final val = double.tryParse(_amountController.text) ?? 0;
      final maxVal = _maxForCurrentMode;
      _sliderValue = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0;
    });
  }

  double get _maxForCurrentMode {
    if (_inputMode == OrderInputMode.cost) {
      return _isBuy ? _availableCash : _currentPrice * _heldShares;
    }
    if (_isBuy) {
      return _currentPrice > 0 ? _availableCash / _currentPrice : 0;
    }
    return _heldShares;
  }

  void _submitOrder() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }

    double shares;
    if (_inputMode == OrderInputMode.cost) {
      shares = _currentPrice > 0 ? amount / _currentPrice : 0;
    } else {
      shares = amount;
    }
    // Full-sale precision: selling 100% via the slider should clear the
    // exact held position, not a rounded fraction of it.
    if (!_isBuy && _sliderValue >= 0.9999) {
      shares = _heldShares;
    }

    if (shares <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid quantity')));
      return;
    }

    if (_selectedOrderType == _OrderType.limit) {
      final limitPrice = double.tryParse(_limitPriceController.text);
      if (limitPrice == null || limitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid limit price')),
        );
        return;
      }
      ref.read(stressTestPendingOrdersProvider.notifier).placeLimitOrder(
            sessionId: widget.sessionId,
            symbol: widget.symbol,
            isBuy: _isBuy,
            quantity: shares,
            limitPrice: limitPrice,
          );

      showTradeConfirmationToast(
        context,
        title: 'Limit ${_isBuy ? 'Buy' : 'Sell'} Order Placed',
        subtitle: '${shares.toStringAsFixed(4)} shares of ${widget.symbol} '
            'at \$${limitPrice.toStringAsFixed(2)} — Pending',
        icon: Icons.schedule_rounded,
        accentColor: _isBuy ? ThemeV2.success : ThemeV2.loss,
      );
      Navigator.of(context).pop();
      return;
    }

    final result = ref
        .read(stressTestProvider.notifier)
        .executeTrade(
          widget.sessionId,
          widget.symbol,
          _isBuy,
          shares,
          useShares: true,
        );

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.reason), backgroundColor: ThemeV2.loss),
      );
      return;
    }

    if (_isBuy) {
      // Fire-and-forget: same live Finnhub sector fetch+cache as the
      // stress-test search sheet's buy flow — this is the OTHER buy path
      // (order entry / stock detail "Buy" button) and used to skip it
      // entirely, leaving GICS sector permanently unresolved (null) for
      // any holding bought here.
      ref.read(sectorRepositoryProvider).loadSector(widget.symbol);
    }

    ref.read(guardianEngineProvider).whenData((engine) {
      engine.recordAction(
        _isBuy ? UserAction.boughtAsset : UserAction.soldAsset,
      );
    });

    showTradeConfirmationToast(
      context,
      title: _isBuy ? 'You Bought' : 'You Sold',
      subtitle: '${shares.toStringAsFixed(4)} shares of ${widget.symbol} '
          'at \$${_currentPrice.toStringAsFixed(2)}',
      icon: Icons.check_circle_rounded,
      accentColor: _isBuy ? ThemeV2.success : ThemeV2.loss,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    final session = _session;
    if (session == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Session not found')),
      );
    }

    final displayAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            OrderHeader(
              symbol: widget.symbol,
              companyName: widget.symbol,
              isBuy: _isBuy,
              price: _currentPrice,
            ),
            OrderTypeTabs(
              isLimit: _selectedOrderType == _OrderType.limit,
              onChanged: _onOrderTypeChanged,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    OrderAmountSection(
                      controller: _amountController,
                      inputMode: _inputMode,
                      onInputModeChanged: (m) => setState(() => _inputMode = m),
                      isBuy: _isBuy,
                      currentPrice: _currentPrice,
                      availableCash: _availableCash,
                      heldShares: _heldShares,
                      sliderValue: _sliderValue,
                      onSliderChanged: (v) => setState(() => _sliderValue = v),
                      onAmountChanged: _onAmountTextChanged,
                      onTapAmount: () =>
                          setState(() => _activeKeypad = _ActiveKeypad.amount),
                    ),
                    OrderConfigSection(
                      isLimit: _selectedOrderType == _OrderType.limit,
                      limitPriceController: _limitPriceController,
                      currentPrice: _currentPrice,
                      isBuy: _isBuy,
                      onTapLimitPriceField: () => setState(() {
                        _limitPriceBeforeEdit = _limitPriceController.text;
                        _limitPriceController.clear();
                        _activeKeypad = _ActiveKeypad.limitPrice;
                      }),
                      infoText: _infoText,
                      // No Extended Hours — simulated market is always open.
                    ),
                  ],
                ),
              ),
            ),
            if (_activeKeypad != _ActiveKeypad.none)
              AmountKeypad(
                controller: _activeKeypad == _ActiveKeypad.amount
                    ? _amountController
                    : _limitPriceController,
                onChanged: _activeKeypad == _ActiveKeypad.amount
                    ? _onAmountTextChanged
                    : () => setState(() {}),
                onDone: () => setState(() {
                  if (_activeKeypad == _ActiveKeypad.limitPrice &&
                      _limitPriceController.text.isEmpty &&
                      _limitPriceBeforeEdit != null) {
                    _limitPriceController.text = _limitPriceBeforeEdit!;
                  }
                  _activeKeypad = _ActiveKeypad.none;
                }),
                isBuy: _isBuy,
                inputMode: _inputMode,
                displayAmount: displayAmount,
                onSubmit: displayAmount > 0 ? _submitOrder : null,
              )
            else
              OrderBottomButton(
                isBuy: _isBuy,
                inputMode: _inputMode,
                displayAmount: displayAmount,
                onSubmit: displayAmount > 0 ? _submitOrder : null,
              ),
          ],
        ),
      ),
    );
  }
}
