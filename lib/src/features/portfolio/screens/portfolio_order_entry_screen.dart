// ---------------------------------------------------------------------------
// Portfolio Order Entry Screen — buy/sell for portfolio (Block 3)
// ---------------------------------------------------------------------------
// Broker style (full-featured, like Stress Test):
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
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/overlay/app_notification_popup.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../monetization/monetization_modal.dart';
import '../../monetization/premium_promo_overlay.dart';
import '../portfolio_limits_provider.dart';
import '../portfolio_providers.dart';
import '../../orders/order_model.dart' as orders;
import '../../orders/order_provider.dart';
import 'order_entry/order_header.dart';
import 'order_entry/order_amount_section.dart';
import 'order_entry/order_config_section.dart';
import 'order_entry/order_bottom_button.dart';
import 'order_entry/amount_keypad.dart';
import 'order_entry/market_closed_dialog.dart';

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
    final reserved = ref
        .read(ordersProvider.notifier)
        .reservedCashForPortfolio(widget.portfolioId);
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

  String _infoText(AppLocalizations l10n) {
    switch (_selectedOrderType) {
      case _OrderType.market:
        return l10n.orderEntryInfoMarket;
      case _OrderType.limit:
        return l10n.orderEntryInfoLimit;
      case _OrderType.stop:
        return l10n.orderEntryInfoStop;
      case _OrderType.stopLimit:
        return l10n.orderEntryInfoStopLimit;
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
    final l10n = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.orderEntryEnterAmount)));
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
      ).showSnackBar(SnackBar(content: Text(l10n.orderEntryInvalidQuantity)));
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
          SnackBar(content: Text(l10n.orderEntryEnterValidLimitPrice)),
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
              l10n.orderEntryNotEnoughCash(formatUsd(_availableCash)),
            ),
          ),
        );
        return;
      }

      // Cap on distinct companies held per portfolio — real Portfolio buys
      // hit the app's live-quote backend, so an unbounded number of tiny
      // positions is unbounded live-quote traffic. Only blocks a BUY that
      // would ADD a new symbol; topping up a symbol already held never
      // increases the count.
      final portfolios = ref.read(portfoliosProvider);
      final portfolio = portfolios.firstWhere(
        (p) => p.id == widget.portfolioId,
      );
      final alreadyHeld = portfolio.holdings.containsKey(widget.symbol);
      if (!alreadyHeld) {
        final maxHoldings = ref.read(maxHoldingsPerPortfolioProvider);
        if (portfolio.holdings.length >= maxHoldings) {
          _showHoldingsLimitReached(l10n, maxHoldings);
          return;
        }
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

  /// Free tier gets the same premium-upsell stub used elsewhere (real
  /// payment isn't wired up yet); premium is already at its own higher cap,
  /// so it just gets a plain notice — there's nothing to upsell them to.
  void _showHoldingsLimitReached(AppLocalizations l10n, int maxHoldings) {
    final tier = ref.read(subscriptionTierProvider);
    final isPremium =
        tier == SubscriptionTier.premium || tier == SubscriptionTier.admin;
    if (isPremium) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ThemeV2.surface,
          title: Text(
            l10n.orderEntryHoldingsLimitTitle,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeV2.textPrimary,
            ),
          ),
          content: Text(
            l10n.orderEntryHoldingsLimitBody(maxHoldings),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.commonOk,
                style: GoogleFonts.inter(
                  color: ThemeV2.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      showPremiumPromoOverlay(
        context: context,
        title: l10n.orderEntryHoldingsLimitPromoTitle,
        durationSeconds: 5,
        onComplete: () {
          if (context.mounted) showMonetizationModal(context, ref);
        },
      );
    }
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
    final l10n = AppLocalizations.of(context)!;
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
      final portfolioName = ref
          .read(portfoliosProvider)
          .where((p) => p.id == widget.portfolioId)
          .firstOrNull
          ?.name;

      if (isImmediate) {
        pushAppNotification(
          ref.read(notificationsProvider.notifier),
          AppNotification(
            id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
            type: _isBuy ? AppNotificationType.buy : AppNotificationType.sell,
            portfolioKind: NotificationPortfolioKind.real,
            portfolioId: widget.portfolioId,
            portfolioLabel: portfolioName,
            symbol: widget.symbol,
            companyName: widget.companyName,
            logoUrl: widget.logo,
            title: _isBuy
                ? l10n.orderEntryNotifYouBought
                : l10n.orderEntryNotifYouSold,
            detail: l10n.orderEntryNotifFilledDetail(
              shares.toStringAsFixed(4),
              companyName,
              formatUsd(_currentPrice),
            ),
            createdAt: DateTime.now(),
          ),
        );
        _resetForm();
      } else {
        pushAppNotification(
          ref.read(notificationsProvider.notifier),
          AppNotification(
            id: 'notif_${DateTime.now().microsecondsSinceEpoch}',
            type: AppNotificationType.limitOrderPlaced,
            portfolioKind: NotificationPortfolioKind.real,
            portfolioId: widget.portfolioId,
            portfolioLabel: portfolioName,
            symbol: widget.symbol,
            companyName: widget.companyName,
            logoUrl: widget.logo,
            title: l10n.orderEntryNotifOrderPlacedTitle(
              orderType.label,
              _isBuy
                  ? l10n.orderEntryNotifBuyWord
                  : l10n.orderEntryNotifSellWord,
            ),
            detail:
                '${l10n.orderEntryNotifPendingDetailBase(shares.toStringAsFixed(4), companyName)}'
                '${limitPrice != null ? l10n.orderEntryNotifAtPrice(formatUsd(limitPrice)) : ''}'
                '${l10n.orderEntryNotifPendingSuffix}',
            createdAt: DateTime.now(),
          ),
        );
        _resetForm();
      }
    }
  }

  // After a successful order we now stay on this Buy/Sell card instead of
  // popping back to Company Detail — popping used to race the notification
  // popup's entrance animation and made it look like the popup was
  // glitching onto the card underneath.
  void _resetForm() {
    if (!mounted) return;
    setState(() {
      _amountController.clear();
      _sliderValue = 0;
      _activeKeypad = _ActiveKeypad.none;
      if (_selectedOrderType == _OrderType.limit) {
        _limitPriceController.text = _currentPrice.toStringAsFixed(2);
      }
    });
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
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            '${_isBuy ? l10n.tradeBuy : l10n.tradeSell} ${widget.symbol}',
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
            '${_isBuy ? l10n.tradeBuy : l10n.tradeSell} ${widget.symbol}',
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
                  l10n.orderEntryPriceLoadError,
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
                  label: Text(l10n.commonRetry),
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
                      infoText: _infoText(l10n),
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
