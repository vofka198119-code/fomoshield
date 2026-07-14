// ---------------------------------------------------------------------------
// Portfolio Order Entry Screen — buy/sell for portfolio (Block 3)
// ---------------------------------------------------------------------------
// Trading 212 style (full-featured, like Stress Test):
//   - Top panel: operation, price, change
//   - Order type tabs: Market / Limit
//   - Input mode: Cost / Shares (BottomSheet)
//   - Large input + slider 0-100%
//   - Info box (changes by order type)
//   - Extra toggles: extended hours, expiration
//   - "Review Order" button
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/finnhub_service.dart';
import '../portfolio_providers.dart';
import '../../orders/order_model.dart' as orders;
import '../../orders/order_provider.dart';

/// Order type
enum _OrderType { market, limit, stop, stopLimit }

/// Input mode
enum _InputMode { cost, shares }

class PortfolioOrderEntryScreen extends ConsumerStatefulWidget {
  final String portfolioId;
  final String symbol;
  final String orderType; // 'buy' or 'sell'

  const PortfolioOrderEntryScreen({
    super.key,
    required this.portfolioId,
    required this.symbol,
    required this.orderType,
  });

  @override
  ConsumerState<PortfolioOrderEntryScreen> createState() =>
      _PortfolioOrderEntryScreenState();
}

class _PortfolioOrderEntryScreenState
    extends ConsumerState<PortfolioOrderEntryScreen> {
  _OrderType _selectedOrderType = _OrderType.market;
  _InputMode _inputMode = _InputMode.cost;
  final _amountController = TextEditingController();
  final _limitPriceController = TextEditingController();
  double _sliderValue = 0;
  bool _extendedHours = false;

  // Price data from Finnhub
  bool _isLoading = true;
  double _currentPrice = 0;
  double _prevClose = 0;
  double _changePercent = 0;

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  bool get _isBuy => widget.orderType == 'buy';

  Future<void> _fetchPrice() async {
    try {
      final quote = await FinnhubService().quote(widget.symbol);
      if (mounted) {
        setState(() {
          _currentPrice = (quote['c'] as num?)?.toDouble() ?? 0;
          _prevClose = (quote['pc'] as num?)?.toDouble() ?? 0;
          _changePercent = (quote['dp'] as num?)?.toDouble() ?? 0;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
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

  double get _availableCash {
    final performance = ref
        .read(portfolioPerformanceProvider(widget.portfolioId))
        .maybeWhen(data: (d) => d, orElse: () => null);
    return performance?.cash ?? 0;
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

  void _submitOrder() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }

    double shares;
    if (_inputMode == _InputMode.cost) {
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
    final session = _extendedHours
        ? orders.MarketSession.afterHours
        : orders.currentMarketSession();
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

    // ── Market order warning for closed market ───────────────────
    if (orderType == orders.OrderType.market &&
        session == orders.MarketSession.closed) {
      _showMarketClosedWarning(
        onConfirm: () {
          _executeOrder(
            orderType: orderType,
            session: session,
            side: side,
            shares: shares,
            amount: amount,
            limitPrice: limitPrice,
          );
        },
      );
      return;
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

      if (isImmediate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBuy
                  ? 'Bought ${shares.toStringAsFixed(4)} ${widget.symbol} '
                        'at \$${_currentPrice.toStringAsFixed(2)}'
                  : 'Sold ${shares.toStringAsFixed(4)} ${widget.symbol} '
                        'at \$${_currentPrice.toStringAsFixed(2)}',
            ),
            backgroundColor: _isBuy ? AppTheme.shieldGreen : AppTheme.dangerRed,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${orderType.label} order placed — Pending${limitPrice != null ? ' at \$${limitPrice.toStringAsFixed(2)}' : ''}',
            ),
            backgroundColor: AppTheme.accentBlue,
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
      }
    }
  }

  /// Show warning dialog when placing a market order while market is closed
  Future<void> _showMarketClosedWarning({
    required VoidCallback onConfirm,
  }) async {
    final session = _extendedHours
        ? orders.MarketSession.afterHours
        : orders.currentMarketSession();

    final sessionLabel = session.label;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppTheme.accentBlue,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Market is $sessionLabel',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'The market is currently $sessionLabel. '
          'Your Market order will be queued and executed when the market opens. '
          'You can cancel it anytime before execution.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDim,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Place Order Anyway',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onConfirm();
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
          title: Text(
            '${_isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.accentBlue,
              letterSpacing: 1.5,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isPositive = _changePercent >= 0;
    final change = _currentPrice - _prevClose;
    final displayAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Panel ─────────────────────────────────────
            _buildTopPanel(
              currentPrice: _currentPrice,
              change: change,
              changePercent: _changePercent,
              isPositive: isPositive,
            ),

            // ── Order Type Tabs ───────────────────────────────
            _buildOrderTypeTabs(),

            // ── Scrollable Content ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildInputModeSelector(),
                    _buildAmountInput(),
                    _buildSlider(),
                    if (_selectedOrderType == _OrderType.limit)
                      _buildLimitPriceInput(),
                    _buildInfoBox(),
                    _buildExtendedHoursToggle(),
                    if (_selectedOrderType == _OrderType.limit)
                      _buildExpirationSelector(),
                  ],
                ),
              ),
            ),

            // ── Bottom Button ─────────────────────────────────
            _buildBottomButton(displayAmount: displayAmount),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Top Panel
  // ────────────────────────────────────────────────────────────────
  Widget _buildTopPanel({
    required double currentPrice,
    required double change,
    required double changePercent,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Column(
        children: [
          // Back + title row
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              Text(
                '${_isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Price + change row
          Row(
            children: [
              const SizedBox(width: 12),
              Text(
                '\$${currentPrice.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.shieldGreen.withValues(alpha: 0.12)
                      : AppTheme.dangerRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} '
                  '(${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? AppTheme.shieldGreen
                        : AppTheme.dangerRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Order Type Tabs — Market / Limit (Stop/StopLimit hidden for now)
  // ────────────────────────────────────────────────────────────────
  Widget _buildOrderTypeTabs() {
    const types = {_OrderType.market: 'Market', _OrderType.limit: 'Limit'};

    return Container(
      color: AppTheme.card,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: types.entries.map((entry) {
          final isActive = _selectedOrderType == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedOrderType = entry.key;
                if (entry.key == _OrderType.limit) {
                  // Default limit price: slightly below for buy, above for sell
                  final defaultPrice = _isBuy
                      ? (_currentPrice * 0.98)
                      : (_currentPrice * 1.02);
                  _limitPriceController.text = defaultPrice.toStringAsFixed(2);
                } else {
                  _limitPriceController.clear();
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive
                          ? AppTheme.accentBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppTheme.accentBlue
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Input Mode Selector — Cost / Shares
  // ────────────────────────────────────────────────────────────────
  Widget _buildInputModeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: () => _showInputModeSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _inputMode == _InputMode.cost
                    ? Icons.attach_money_rounded
                    : Icons.inventory_2_rounded,
                color: AppTheme.accentBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _inputMode == _InputMode.cost ? 'Cost' : 'Shares',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                _isBuy
                    ? 'Cash: \$${_fmt(_availableCash)}'
                    : 'Held: ${_heldShares.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textDim),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textDim,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInputModeSheet() async {
    await showModalBottomSheet<_InputMode>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Cost option
            _modeSheetOption(
              icon: Icons.attach_money_rounded,
              title: 'Cost',
              subtitle: 'Invest a fixed dollar amount',
              detail: 'Cash: \$${_fmt(_availableCash)}',
              isSelected: _inputMode == _InputMode.cost,
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() => _inputMode = _InputMode.cost);
              },
            ),
            const SizedBox(height: 8),
            // Shares option
            _modeSheetOption(
              icon: Icons.inventory_2_rounded,
              title: 'Shares',
              subtitle: 'Buy an exact number of shares',
              detail: 'Available: ${_heldShares.toStringAsFixed(2)}',
              isSelected: _inputMode == _InputMode.shares,
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() => _inputMode = _InputMode.shares);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _modeSheetOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.textDim.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentBlue : AppTheme.textDim,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  detail,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textDim,
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.accentBlue,
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Amount Input — 42px Playfair Display
  // ────────────────────────────────────────────────────────────────
  Widget _buildAmountInput() {
    final displayAmount = double.tryParse(_amountController.text) ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentBlue,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDim.withValues(alpha: 0.3),
              ),
              prefixText: _inputMode == _InputMode.cost ? '\$ ' : null,
              prefixStyle: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentBlue,
              ),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) {
              setState(() {
                final val = double.tryParse(_amountController.text) ?? 0;
                final maxVal = _inputMode == _InputMode.cost
                    ? (_isBuy ? _availableCash : _currentPrice * _heldShares)
                    : _heldShares;
                _sliderValue = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0;
              });
            },
          ),
          Text(
            _inputMode == _InputMode.cost ? 'USD' : 'Shares',
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textDim),
          ),
          // Conversion preview
          if (displayAmount > 0 && _inputMode == _InputMode.cost)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '≈ ${displayAmount > 0 && _currentPrice > 0 ? (displayAmount / _currentPrice).toStringAsFixed(4) : '0'} shares',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          if (displayAmount > 0 && _inputMode == _InputMode.shares)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '≈ \$${(displayAmount * _currentPrice).toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Slider — 0–100%, 20 steps
  // ────────────────────────────────────────────────────────────────
  Widget _buildSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: AppTheme.accentBlue,
              inactiveTrackColor: AppTheme.textDim.withValues(alpha: 0.2),
              thumbColor: AppTheme.accentBlue,
              overlayColor: AppTheme.accentBlue.withValues(alpha: 0.12),
              valueIndicatorColor: AppTheme.accentBlue,
              valueIndicatorTextStyle: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) {
                setState(() {
                  _sliderValue = v;
                  final maxVal = _inputMode == _InputMode.cost
                      ? (_isBuy ? _availableCash : _currentPrice * _heldShares)
                      : _heldShares;
                  final newVal = maxVal * v;
                  _amountController.text = newVal > 0
                      ? newVal.toStringAsFixed(newVal < 1 ? 4 : 2)
                      : '';
                });
              },
              divisions: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pctLabel('0%'),
                _pctLabel('25%'),
                _pctLabel('50%'),
                _pctLabel('75%'),
                _pctLabel('100%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pctLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDim),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Limit Price Input (only for Limit orders)
  // ────────────────────────────────────────────────────────────────
  Widget _buildLimitPriceInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.trending_flat_rounded,
              color: AppTheme.accentBlue,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Limit Price',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _limitPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentBlue,
                ),
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentBlue,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Info Box — order type description
  // ────────────────────────────────────────────────────────────────
  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.textDim,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _infoText,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Extended Hours Toggle
  // ────────────────────────────────────────────────────────────────
  Widget _buildExtendedHoursToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppTheme.textDim,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extended Hours',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Pre-market and post-market volatility',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _extendedHours,
              onChanged: (v) => setState(() => _extendedHours = v),
              activeTrackColor: AppTheme.accentBlue,
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Expiration Selector (only for Limit / Stop-Limit)
  // ────────────────────────────────────────────────────────────────
  Widget _buildExpirationSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppTheme.textDim,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expiration',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Valid until end of day',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textDim,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textDim,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Bottom Button — "Review Order"
  // ────────────────────────────────────────────────────────────────
  Widget _buildBottomButton({required double displayAmount}) {
    final canExecute = displayAmount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: const Border(top: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayAmount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _inputMode == _InputMode.cost ? 'Cost:' : 'Qty:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    ),
                  ),
                  Text(
                    _inputMode == _InputMode.cost
                        ? '\$${displayAmount.toStringAsFixed(2)}'
                        : '${displayAmount.toStringAsFixed(4)} sh.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: canExecute ? _submitOrder : null,
            child: Container(
              width: double.infinity,
              height: 52,
              color: canExecute
                  ? (_isBuy ? AppTheme.accentBlue : AppTheme.dangerRed)
                  : AppTheme.textDim.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Text(
                'Review Order',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: canExecute ? Colors.white : AppTheme.textDim,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────
  String _fmt(double v) {
    return NumberFormat('#,##0.00', 'en_US').format(v);
  }
}
