import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart' show AppPalette, resolveAppPalette;
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../portfolio/portfolio_providers.dart' show brokerCommissionRate;
import '../models/fund.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;
import '../../portfolio/screens/order_entry/order_header.dart';
import '../../portfolio/screens/order_entry/order_amount_section.dart';
import '../../portfolio/screens/order_entry/order_config_section.dart';
import '../../portfolio/screens/order_entry/order_bottom_button.dart';
import '../../portfolio/screens/order_entry/order_confirmation_sheet.dart';
import '../../portfolio/screens/order_entry/amount_keypad.dart';

// ---------------------------------------------------------------------------
// Fund Trade Entry — the real Buy/Sell order-entry screen's visual/state
// shape (PortfolioOrderEntryScreen), adapted for creating a fund TRADE
// PROPOSAL instead of executing an order (2026-09-15, replaces the old
// ProposeTradeScreen's plain-form look entirely). Reuses every
// order_entry/ widget as-is.
//
// Deliberately DROPS two things PortfolioOrderEntryScreen has: the
// market-closed gate (a proposal isn't an instant fill, so market hours
// don't gate creating one) and the hard "not enough cash/shares" block
// (matches the old ProposeTradeScreen's own permissive behavior -- the
// approver reviews before it executes, and the backend still enforces
// insufficient_cash/insufficient_shares at actual execution time).
//
// Requires an already-resolved symbol -- always reached via
// FundSearchScreen -> fund-context Company Detail -> this screen's own
// Buy/Sell buttons (see fund_search_screen.dart).
// ---------------------------------------------------------------------------

enum _ActiveKeypad { none, amount, limitPrice }

class FundTradeEntryScreen extends ConsumerStatefulWidget {
  final String fundId;
  final String symbol;
  final String? companyName;
  final String? logo;
  final String initialSide; // 'buy' or 'sell'

  const FundTradeEntryScreen({
    super.key,
    required this.fundId,
    required this.symbol,
    this.companyName,
    this.logo,
    required this.initialSide,
  });

  @override
  ConsumerState<FundTradeEntryScreen> createState() =>
      _FundTradeEntryScreenState();
}

class _FundTradeEntryScreenState extends ConsumerState<FundTradeEntryScreen> {
  bool _isLimit = false;
  OrderInputMode _inputMode = OrderInputMode.cost;
  final _amountController = TextEditingController();
  final _limitPriceController = TextEditingController();
  final _justificationController = TextEditingController();
  double _sliderValue = 0;
  _ActiveKeypad _activeKeypad = _ActiveKeypad.none;
  String? _limitPriceBeforeEdit;

  bool _isLoading = true;
  bool _loadFailed = false;
  double _currentPrice = 0;
  bool _submitting = false;

  bool get _isBuy => widget.initialSide != 'sell';

  @override
  void initState() {
    super.initState();
    _fetchPrice();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _limitPriceController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

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
    final fund = ref.read(fundDetailProvider(widget.fundId)).valueOrNull;
    if (fund == null) return 0;
    final holding = fund.holdings.firstWhere(
      (h) => h.symbol.toUpperCase() == widget.symbol.toUpperCase(),
      orElse: () => FundHolding(
        symbol: widget.symbol,
        quantity: 0,
        price: 0,
        value: 0,
        avgCost: 0,
      ),
    );
    return holding.quantity;
  }

  double get _availableCash {
    final fund = ref.read(fundDetailProvider(widget.fundId)).valueOrNull;
    return fund?.cash ?? 0;
  }

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
    return _isLimit ? l10n.orderEntryInfoLimit : l10n.orderEntryInfoMarket;
  }

  void _onOrderTypeChanged(bool isLimit) {
    setState(() {
      _isLimit = isLimit;
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

    double? limitPrice;
    if (_isLimit) {
      limitPrice = double.tryParse(_limitPriceController.text);
      if (limitPrice == null || limitPrice <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.etfProposeLimitPriceRequired)),
        );
        return;
      }
    }

    final orderPrice = limitPrice ?? _currentPrice;
    // Same 0.5% rate the fund actually charges on execution
    // (migration_024_fund_trade_commission.sql) -- shown here as an
    // estimate, same as Stress Test/Portfolio's own order-entry screens,
    // not left blank just because this step only creates a proposal
    // rather than filling immediately.
    final orderFee = shares * orderPrice * brokerCommissionRate;
    final confirmed = await showOrderConfirmationSheet(
      context: context,
      palette: resolveAppPalette(ref.read(themeVariantProvider)),
      symbol: widget.symbol,
      companyName: widget.companyName ?? widget.symbol,
      logoUrl: widget.logo,
      isBuy: _isBuy,
      orderTypeLabel: _isLimit
          ? l10n.orderEntryTabLimit
          : l10n.orderEntryTabMarket,
      shares: shares,
      price: orderPrice,
      fee: orderFee,
    );
    if (confirmed != true || !mounted) return;

    await _submitProposal(shares: shares, limitPrice: limitPrice);
  }

  Future<void> _submitProposal({
    required double shares,
    double? limitPrice,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await ref
          .read(fundApiServiceProvider)
          .proposeTrade(
            fundId: widget.fundId,
            symbol: widget.symbol,
            side: _isBuy ? 'buy' : 'sell',
            orderType: _isLimit ? 'limit' : 'market',
            limitPrice: limitPrice,
            quantity: shares,
            justification: _justificationController.text.trim(),
          );
      ref.invalidate(fundProposalsProvider(widget.fundId));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.etfProposeSubmitButton)));
      Navigator.of(context).pop();
    } on FundApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.etfProposeGenericError)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _justificationField(AppLocalizations l10n, AppPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.etfProposeJustificationLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: palette.textHeader,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _justificationController,
            maxLines: 3,
            maxLength: 300,
            style: GoogleFonts.inter(color: palette.textHeader),
            decoration: InputDecoration(
              hintText: l10n.etfProposeJustificationHint,
              hintStyle: GoogleFonts.inter(
                color: palette.textBody,
                fontSize: 14,
              ),
              filled: false,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: palette.accentPrimary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final title =
        '${_isBuy ? l10n.tradeBuy : l10n.tradeSell} ${widget.companyName ?? widget.symbol}';

    if (_isLoading || fundAsync.isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: themedHeaderText(
            title,
            palette,
            GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          leading: themedBackButton(context, palette),
        ),
        body: Center(
          child: CircularProgressIndicator(color: palette.accentPrimary),
        ),
      );
    }

    if (_loadFailed) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: themedHeaderText(
            title,
            palette,
            GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          leading: themedBackButton(context, palette),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  color: palette.textBody,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.orderEntryPriceLoadError,
                  style: GoogleFonts.inter(
                    color: palette.textHeader,
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
              palette: palette,
            ),
            OrderTypeTabs(
              isLimit: _isLimit,
              onChanged: _onOrderTypeChanged,
              palette: palette,
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
                      palette: palette,
                    ),
                    OrderConfigSection(
                      isLimit: _isLimit,
                      limitPriceController: _limitPriceController,
                      currentPrice: _currentPrice,
                      isBuy: _isBuy,
                      onTapLimitPriceField: () => setState(() {
                        _limitPriceBeforeEdit = _limitPriceController.text;
                        _limitPriceController.clear();
                        _activeKeypad = _ActiveKeypad.limitPrice;
                      }),
                      infoText: _infoText(l10n),
                      // No extended-hours concept for a proposal -- null
                      // hides the toggle entirely (same as Stress Test).
                      palette: palette,
                    ),
                    _justificationField(l10n, palette),
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
                onSubmit: (displayAmount > 0 && !_submitting)
                    ? _submitOrder
                    : null,
                submitLabel: l10n.etfProposeSubmitButton,
                palette: palette,
              )
            else
              OrderBottomButton(
                isBuy: _isBuy,
                inputMode: _inputMode,
                displayAmount: displayAmount,
                onSubmit: (displayAmount > 0 && !_submitting)
                    ? _submitOrder
                    : null,
                label: l10n.etfProposeSubmitButton,
                palette: palette,
              ),
          ],
        ),
      ),
    );
  }
}
