// ---------------------------------------------------------------------------
// Portfolio Order Entry Screen — buy/sell for portfolio (Block 3)
// ---------------------------------------------------------------------------
// Trading 212 style (full-featured, like Stress Test):
//   - Top panel: operation, price, change
//   - Order type tabs: Market / Limit
//   - Input mode: Cost / Shares (BottomSheet)
//   - Large input + slider 0-100%
//   - Info box (changes by order type)
//   - Extra toggle: extended hours
//   - "Review Order" button
//
// Split 2026-08-01 into order_entry/ widget files (header/tabs, amount
// section, config section, bottom button) + restyled to the app's
// dark-green/gold card standard. This file keeps all the state/business
// logic (price loading, order calculation, submission).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../shared/services/finnhub_service.dart';
import '../portfolio_providers.dart';
import '../../orders/order_model.dart' as orders;
import '../../orders/order_provider.dart';
import 'order_entry/order_header.dart';
import 'order_entry/order_amount_section.dart';
import 'order_entry/order_config_section.dart';
import 'order_entry/order_bottom_button.dart';
import 'order_entry/amount_keypad.dart';
import 'order_entry/market_closed_dialog.dart';
import 'order_entry/trade_confirmation_toast.dart';

/// Order type. Stop/StopLimit exist in the order model and are still fully
/// handled by _mapOrderType/_executeOrder below, but the UI only exposes
/// Market/Limit for now (OrderTypeTabs is a plain market/limit toggle).
enum _OrderType { market, limit, stop, stopLimit }

/// Which field (if any) currently owns the shared bottom keypad — amount
/// and limit price both type into the same custom keypad, one at a time.
enum _ActiveKeypad { none, amount, limitPrice }

const String _extendedHoursPrefsKey = 'order_entry_extended_hours';

class PortfolioOrderEntryScreen extends ConsumerStatefulWidget {
  final String portfolioId;
  final String symbol;
  final String orderType; // 'buy' or 'sell'
  // Price/company info already loaded on the screen that pushed here
  // (Company Detail) — when present, skips this screen's own network
  // fetch entirely instead of re-loading a price the user already saw a
  // second ago.
  final double? initialPrice;
  final String? companyName;
  final String? logo;

  const PortfolioOrderEntryScreen({
    super.key,
    required this.portfolioId,
    required this.symbol,
    required this.orderType,
    this.initialPrice,
    this.companyName,
    this.logo,
  });

  @override
  ConsumerState<PortfolioOrderEntryScreen> createState() =>
      _PortfolioOrderEntryScreenState();
}

class _PortfolioOrderEntryScreenState
    extends ConsumerState<PortfolioOrderEntryScreen> {
  _OrderType _selectedOrderType = _OrderType.market;
  OrderInputMode _inputMode = OrderInputMode.cost;
  final _amountController = TextEditingController();
  final _limitPriceController = TextEditingController();
  double _sliderValue = 0;
  bool _extendedHours = false;
  _ActiveKeypad _activeKeypad = _ActiveKeypad.none;
  // Restored if the limit-price keypad is dismissed without typing a new
  // value — tapping the field clears it for fresh entry, but swiping away
  // empty-handed shouldn't leave the price blank.
  String? _limitPriceBeforeEdit;

  // Price data — from the caller's already-loaded quote when available,
  // otherwise fetched here (backend-proxied, see FinnhubService.quote).
  bool _isLoading = true;
  bool _loadFailed = false;
  double _currentPrice = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrice != null) {
      _currentPrice = widget.initialPrice!;
      _isLoading = false;
    } else {
      _fetchPrice();
    }
    _loadExtendedHoursPref();
  }

  Future<void> _loadExtendedHoursPref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_extendedHoursPrefsKey);
    if (saved != null && mounted) setState(() => _extendedHours = saved);
  }

  Future<void> _setExtendedHours(bool value) async {
    setState(() => _extendedHours = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_extendedHoursPrefsKey, value);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  bool get _isBuy => widget.orderType == 'buy';

  Future<void> _fetchPrice() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final quote = await ref.read(finnhubServiceProvider).quote(widget.symbol);
      if (mounted) {
        setState(() {
          _currentPrice = (quote['c'] as num?)?.toDouble() ?? 0;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  double get _heldShares {
    final performance = ref
        .read(portfolioPerformanceProvider(widget.portfolioId))
        .maybeWhen(data: (d) => d, orElse: () => null);
    if (performance == null) return 0;
    final held = performance.holdings.firstWhere(
      (h) => h.symbol == widget.symbol,
      orElse: () => HoldingPerformance(
        symbol: widget.symbol,
        shares: 0,
        avgCost: 0,
        totalCost: 0,
        currentPrice: 0,
        currentValue: 0,
        pnl: 0,
        pnlPercent: 0,
      ),
    );
    return held.shares;
  }

  // Cash still free to commit to a new order — real cash minus whatever's
  // already reserved by this portfolio's other pending BUY orders (see
  // OrderNotifier.reservedCashForPortfolio; real cash isn't touched until
  // a buy actually fills, but it shouldn't be offered twice).
  double get _availableCash {
    final performance = ref
        .read(portfolioPerformanceProvider(widget.portfolioId))
        .maybeWhen(data: (d) => d, orElse: () => null);
    final cash = performance?.cash ?? 0;
    final reserved =
        ref.read(ordersProvider.notifier).reservedCashForPortfolio(widget.portfolioId);
    return (cash - reserved).clamp(0, double.infinity);
  }

  // Same ceiling logic as OrderAmountSection._maxAmount — kept here too
  // since the amount TextField's onChanged (recomputing the slider
  // position from typed text) lives in this state class.
  double get _maxAmountForCurrentMode {
    if (_inputMode == OrderInputMode.cost) {
      return _isBuy ? _availableCash : _currentPrice * _heldShares;
    }
    if (_isBuy) {
      return _currentPrice > 0 ? _availableCash / _currentPrice : 0;
    }
    return _heldShares;
  }

  String get _infoText {
    switch (_selectedOrderType) {
      case _OrderType.market:
        return 'Market orders execute at the best available price. '
            'Execution is guaranteed, but the final price may differ from expectations.';
      case _OrderType.limit:
        return 'Limit orders execute only at the specified price or better. '
            'Partial or full execution is not guaranteed.';
      case _OrderType.stop:
        return 'Stop orders activate when the stop price is reached, then '
            'execute as a market order.';
      case _OrderType.stopLimit:
        return 'Stop-limit orders activate when the stop price is reached, then '
            'execute as a limit order.';
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
      final maxVal = _maxAmountForCurrentMode;
      _sliderValue = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0;
    });
  }

  Future<void> _submitOrder() async {
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

    if (shares <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid quantity')));
      return;
    }

    final orderType = _mapOrderType(_selectedOrderType);
    final session = orders.currentMarketSession();

    // With Extended Hours off, Market orders can only fill while the real
    // exchange is actually open — same rule a real broker enforces. Limit
    // orders are unaffected: they're always queued as PENDING anyway (see
    // OrderNotifier.placeOrder) and fill whenever the market crosses the
    // price, open or not.
    if (orderType == orders.OrderType.market &&
        !_extendedHours &&
        session != orders.MarketSession.regular) {
      final switchToLimit = await showMarketClosedDialog(context);
      if (!mounted) return;
      if (switchToLimit) {
        _onOrderTypeChanged(true);
      }
      return;
    }

    final side = _isBuy ? orders.OrderSide.buy : orders.OrderSide.sell;

    // Validate limit price
    double? limitPrice;
    if (orderType == orders.OrderType.limit) {
      limitPrice = double.tryParse(_limitPriceController.text);
      if (limitPrice == null || limitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid limit price')),
        );
        return;
      }
    }

    // Cash already committed to other pending buy orders isn't free to
    // spend again — see _availableCash.
    if (_isBuy) {
      final orderCost = shares * (limitPrice ?? _currentPrice);
      if (orderCost > _availableCash + 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Not enough available cash — \$${_availableCash.toStringAsFixed(2)} '
              'free (some is reserved for pending orders)',
            ),
          ),
        );
        return;
      }
    }

    _executeOrder(
      orderType: orderType,
      session: session,
      side: side,
      shares: shares,
      amount: amount,
      limitPrice: limitPrice,
    );
  }

  /// Central order execution logic (called directly or after confirmation)
  void _executeOrder({
    required orders.OrderType orderType,
    required orders.MarketSession session,
    required orders.OrderSide side,
    required double shares,
    required double amount,
    double? limitPrice,
  }) {
    final order = ref
        .read(ordersProvider.notifier)
        .placeOrder(
          portfolioId: widget.portfolioId,
          assetSymbol: widget.symbol,
          companyName: widget.companyName ?? widget.symbol,
          side: side,
          type: orderType,
          quantity: shares,
          createdPrice: _currentPrice,
          limitPrice: limitPrice,
          stopPrice: null,
          session: session,
        );

    if (mounted) {
      final isImmediate = order.status == orders.OrderStatus.filled;
      final companyName = widget.companyName ?? widget.symbol;
      final accentColor = _isBuy ? ThemeV2.success : ThemeV2.loss;

      if (isImmediate) {
        showTradeConfirmationToast(
          context,
          title: _isBuy ? 'You Bought' : 'You Sold',
          subtitle: '${shares.toStringAsFixed(4)} shares of $companyName '
              'at \$${_currentPrice.toStringAsFixed(2)}',
          icon: Icons.check_circle_rounded,
          accentColor: accentColor,
        );
        context.pop();
      } else {
        showTradeConfirmationToast(
          context,
          title: '${orderType.label} ${_isBuy ? 'Buy' : 'Sell'} Order Placed',
          subtitle: '${shares.toStringAsFixed(4)} shares of $companyName'
              '${limitPrice != null ? ' at \$${limitPrice.toStringAsFixed(2)}' : ''} — Pending',
          icon: Icons.schedule_rounded,
          accentColor: accentColor,
        );
        context.pop();
      }
    }
  }

  orders.OrderType _mapOrderType(_OrderType type) {
    switch (type) {
      case _OrderType.market:
        return orders.OrderType.market;
      case _OrderType.limit:
        return orders.OrderType.limit;
      case _OrderType.stop:
        return orders.OrderType.stop;
      case _OrderType.stopLimit:
        return orders.OrderType.stopLimit;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            '${_isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeV2.primary,
              letterSpacing: 1.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: ThemeV2.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            '${_isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeV2.primary,
              letterSpacing: 1.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: ThemeV2.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: ThemeV2.textSecondary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load the current price',
                  style: GoogleFonts.inter(
                    color: ThemeV2.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchPrice,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeV2.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
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
              companyName: widget.companyName ?? widget.symbol,
              logo: widget.logo,
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
                        // Typing on the keypad starts a fresh value rather
                        // than appending onto the pre-filled current price.
                        _limitPriceBeforeEdit = _limitPriceController.text;
                        _limitPriceController.clear();
                        _activeKeypad = _ActiveKeypad.limitPrice;
                      }),
                      infoText: _infoText,
                      extendedHours: _extendedHours,
                      onExtendedHoursChanged: _setExtendedHours,
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
