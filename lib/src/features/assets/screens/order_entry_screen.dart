// ---------------------------------------------------------------------------
// Stress Test Order Entry Screen — buy/sell for stress test (Block 3)
// ---------------------------------------------------------------------------
// Market-only orders for stress test simulation.
// Uses stress test engine prices (not Finnhub).
// No market closed warning (stress test is simulated, always open).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/cache/sector_providers.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/guardian/guardian_engine.dart';
import '../../../shared/guardian/guardian_providers.dart';
import '../../stress_test/stress_test_models.dart';
import '../../stress_test/stress_test_engine.dart';

/// Input mode
enum _InputMode { cost, shares }

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
  _InputMode _inputMode = _InputMode.cost;
  final _amountController = TextEditingController();
  double _sliderValue = 0;
  bool _extendedHours = false;
  bool _isFullSale = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isBuy => widget.orderType == 'buy';

  Color get _accent => ThemeV2.primary;

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

  double get _maxForCurrentMode {
    if (_inputMode == _InputMode.cost) {
      return _isBuy ? _availableCash : _currentPrice * _heldShares;
    } else if (_isBuy) {
      return _availableCash / _currentPrice;
    } else {
      return _heldShares;
    }
  }

  double get _currentPrice {
    final session = _session;
    if (session == null) return widget.price;
    return session.currentPrices[widget.symbol] ??
        session.basePrices[widget.symbol] ??
        widget.price;
  }

  String get _infoText {
    return 'Market orders execute at the best available price. '
        'Execution is guaranteed, but the final price may differ from expectations.';
  }

  void _submitOrder() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }

    final isFullSale = _isFullSale || _sliderValue >= 0.9999;

    // tradeAmount = что передаём в executeTrade (USD или shares)
    double tradeAmount;
    bool useShares;
    // Для SnackBar — реальное количество акций в сделке
    double realShares;

    if (isFullSale && !_isBuy) {
      // Full sale: pass EXACT held shares, engine uses useShares=true
      tradeAmount = _heldShares;
      useShares = true;
      realShares = _heldShares;
    } else if (_inputMode == _InputMode.cost) {
      // Cost mode: pass USD → engine does cost/price internally
      tradeAmount = amount;
      useShares = false;
      realShares = _currentPrice > 0 ? amount / _currentPrice : 0;
    } else {
      // Shares mode: pass share count directly
      tradeAmount = amount;
      useShares = true;
      realShares = amount;
    }

    if (tradeAmount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid quantity')));
      return;
    }

    final result = ref
        .read(stressTestProvider.notifier)
        .executeTrade(
          widget.sessionId,
          widget.symbol,
          _isBuy,
          tradeAmount,
          useShares: useShares,
        );

    if (!result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.reason),
          backgroundColor: ThemeV2.loss,
        ),
      );
      return;
    }

    if (mounted) {
      if (_isBuy) {
        // Fire-and-forget: same live Finnhub sector fetch+cache as the
        // stress-test search sheet's buy flow (stress_test_search_sheet.dart)
        // — this is the OTHER buy path (order entry / company detail "Buy"
        // button) and used to skip it entirely, leaving GICS sector
        // permanently unresolved (null) for any holding bought here until
        // some other purchase of the same ticker happened to go through the
        // search sheet instead. Doesn't block the trade — the engine's
        // static heuristic covers this symbol until the fetch resolves.
        ref.read(sectorRepositoryProvider).loadSector(widget.symbol);
      }

      // Record the trading action for Guardian intelligence
      ref.read(guardianEngineProvider).whenData((engine) {
        engine.recordAction(
          _isBuy ? UserAction.boughtAsset : UserAction.soldAsset,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBuy
                ? 'Bought ${realShares.toStringAsFixed(4)} ${widget.symbol} '
                      'at \$${_currentPrice.toStringAsFixed(2)}'
                : 'Sold ${realShares.toStringAsFixed(4)} ${widget.symbol} '
                      'at \$${_currentPrice.toStringAsFixed(2)}',
          ),
          backgroundColor: _isBuy ? ThemeV2.success : ThemeV2.loss,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(stressTestRefreshProvider);
    final session = _session;
    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(child: Text('Session not found')),
      );
    }

    final currentPrice = _currentPrice;
    final basePrice = session.basePrices[widget.symbol] ?? currentPrice;
    final change = currentPrice - basePrice;
    final changePercent = basePrice > 0 ? (change / basePrice) * 100 : 0.0;
    final isPositive = change >= 0;
    final displayAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Panel ─────────────────────────────────────
            _buildTopPanel(
              currentPrice: currentPrice,
              change: change,
              changePercent: changePercent,
              isPositive: isPositive,
            ),

            // ── Market Label ─────────────────────────────────
            _buildOrderTypeLabel(),

            // ── Scrollable Content ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    _buildInputModeSelector(),
                    _buildAmountInput(),
                    _buildSlider(),
                    _buildInfoBox(),
                    _buildExtendedHoursToggle(),
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

  // ──────────────────────────────────────────────────────────────
  // Top Panel
  // ──────────────────────────────────────────────────────────────
  Widget _buildTopPanel({
    required double currentPrice,
    required double change,
    required double changePercent,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(14),
        border: const Border(bottom: BorderSide(color: Color(0xFFE8E5DF))),
      ),
      child: Column(
        children: [
          // Back + title row
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: ThemeV2.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              Text(
                '${_isBuy ? 'Buy' : 'Sell'} ${widget.symbol}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ThemeV2.textPrimary,
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
                  color: ThemeV2.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? ThemeV2.success.withValues(alpha: 0.12)
                      : ThemeV2.loss.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(2)} '
                  '(${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? ThemeV2.success
                        : ThemeV2.loss,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Order Type Tabs — Market / Limit only
  // ──────────────────────────────────────────────────────────────
  Widget _buildOrderTypeLabel() {
    return Container(
      color: ThemeV2.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _accent, width: 2)),
            ),
            child: Text(
              'Market',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Input Mode Selector — Cost / Shares (BottomSheet)
  // ──────────────────────────────────────────────────────────────
  Widget _buildInputModeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: () => _showInputModeSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ThemeV2.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ThemeV2.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _inputMode == _InputMode.cost
                    ? Icons.attach_money_rounded
                    : Icons.inventory_2_rounded,
                color: _accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                _inputMode == _InputMode.cost ? 'Cost' : 'Shares',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeV2.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                _isBuy
                    ? 'Cash: ${_fmt(_availableCash)}'
                    : 'Held: ${_heldShares.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontSize: 11, color: ThemeV2.textSecondary),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: ThemeV2.textSecondary,
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
      backgroundColor: ThemeV2.surface,
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
              detail: 'Cash: ${_fmt(_availableCash)}',
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
              ? _accent.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? _accent
                : ThemeV2.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _accent : ThemeV2.textSecondary,
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
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
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
                    color: ThemeV2.textSecondary,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: _accent, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Amount Input — 42px Playfair Display
  // ──────────────────────────────────────────────────────────────
  Widget _buildAmountInput() {
    final displayAmount = double.tryParse(_amountController.text) ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: _accent,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.playfairDisplay(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: ThemeV2.textSecondary.withValues(alpha: 0.3),
              ),
              prefixText: _inputMode == _InputMode.cost ? '\$ ' : null,
              prefixStyle: GoogleFonts.playfairDisplay(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: _accent,
              ),
              border: InputBorder.none,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (_) {
              setState(() {
                final val = double.tryParse(_amountController.text) ?? 0;
                final maxVal = _maxForCurrentMode;
                _sliderValue = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0;
                _isFullSale = !_isBuy && maxVal > 0 && (val / maxVal) >= 0.9999;
              });
            },
          ),
          Text(
            _inputMode == _InputMode.cost ? 'USD' : 'Shares',
            style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.textSecondary),
          ),
          // Conversion preview
          if (displayAmount > 0 && _inputMode == _InputMode.cost)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '≈ ${displayAmount > 0 && _currentPrice > 0 ? (displayAmount / _currentPrice).toStringAsFixed(4) : '0'} shares',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ThemeV2.textSecondary,
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
                  color: ThemeV2.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Slider — 0–100%, 20 steps
  // ──────────────────────────────────────────────────────────────
  Widget _buildSlider() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              activeTrackColor: _accent,
              inactiveTrackColor: ThemeV2.textSecondary.withValues(alpha: 0.2),
              thumbColor: _accent,
              overlayColor: _accent.withValues(alpha: 0.12),
              valueIndicatorColor: _accent,
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
                  final maxVal = _maxForCurrentMode;
                  final atMax = v >= 0.9999;
                  _isFullSale = !_isBuy && atMax;
                  final isCostMode = _inputMode == _InputMode.cost;
                  if (atMax) {
                    // Fill with EXACT max, formatted per mode
                    _amountController.text = isCostMode
                        ? maxVal.toStringAsFixed(2)
                        : maxVal.toStringAsFixed(4);
                  } else {
                    final newVal = maxVal * v;
                    _amountController.text = newVal > 0
                        ? (isCostMode
                              ? newVal.toStringAsFixed(newVal < 1 ? 4 : 2)
                              : newVal.toStringAsFixed(4))
                        : '';
                  }
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
      style: GoogleFonts.inter(fontSize: 10, color: ThemeV2.textSecondary),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Limit Price Input (only for Limit orders)
  // ──────────────────────────────────────────────────────────────
  // ──────────────────────────────────────────────────────────────
  // Info Box — order type description
  // ──────────────────────────────────────────────────────────────
  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeV2.surfaceDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: ThemeV2.textSecondary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _infoText,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ThemeV2.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Extended Hours Toggle
  // ──────────────────────────────────────────────────────────────
  Widget _buildExtendedHoursToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ThemeV2.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: ThemeV2.textSecondary,
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
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                  Text(
                    'Pre-market and post-market volatility',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _extendedHours,
              onChanged: (v) => setState(() => _extendedHours = v),
              activeTrackColor: _accent,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Expiration Selector (only for Limit orders)
  // ──────────────────────────────────────────────────────────────
  // ──────────────────────────────────────────────────────────────
  // Bottom Button — "Review Order"
  // ──────────────────────────────────────────────────────────────
  Widget _buildBottomButton({required double displayAmount}) {
    final canExecute = displayAmount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: const Border(top: BorderSide(color: Color(0xFFE8E5DF))),
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
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                  Text(
                    _inputMode == _InputMode.cost
                        ? '\$${displayAmount.toStringAsFixed(2)}'
                        : '${displayAmount.toStringAsFixed(4)} sh.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
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
                  ? (_isBuy ? _accent : ThemeV2.loss)
                  : ThemeV2.textSecondary.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: Text(
                'Review Order',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: canExecute ? Colors.white : ThemeV2.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────
  String _fmt(double v) {
    return NumberFormat.currency(locale: 'en_US', symbol: r'$').format(v);
  }
}

