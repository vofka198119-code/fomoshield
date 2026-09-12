import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_button.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../../shared/widgets/company_logo.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Propose Trade — full screen, not a bottom sheet (2026-09-12, explicit ask
// after the sheet version lagged noticeably typing into the typeahead
// field). Same fields/mechanics as the sheet it replaces
// (propose_trade_sheet.dart, now unused): symbol typeahead, side, order
// type, quantity, limit price, justification. On success, pushes straight
// into the new proposal's own detail screen instead of just popping back
// to the blotter.
// ---------------------------------------------------------------------------

class ProposeTradeScreen extends ConsumerStatefulWidget {
  final String fundId;
  // Prefilled when reached from a company card in fund context (2026-09-12:
  // "смотрел на компанию и решил добавить ее или продать") -- the symbol
  // search box starts already resolved to this symbol/name instead of
  // empty, side defaults to whichever button was tapped. Every other entry
  // point (the blotter's own "+") leaves these null and the form starts
  // blank as before.
  final String? initialSymbol;
  final String? initialSymbolName;
  final String? initialSide;

  const ProposeTradeScreen({
    super.key,
    required this.fundId,
    this.initialSymbol,
    this.initialSymbolName,
    this.initialSide,
  });

  @override
  ConsumerState<ProposeTradeScreen> createState() => _ProposeTradeScreenState();
}

class _ProposeTradeScreenState extends ConsumerState<ProposeTradeScreen> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _limitPriceController = TextEditingController();
  final _justificationController = TextEditingController();
  final _api = FinnhubService();
  Timer? _debounce;
  List<Map<String, dynamic>> _symbolResults = [];
  bool _searchingSymbol = false;
  String? _selectedSymbol;
  bool _programmaticTextChange = false;
  String _side = 'buy';
  String _orderType = 'market';
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final symbol = widget.initialSymbol;
    if (symbol != null && symbol.isNotEmpty) {
      _selectedSymbol = symbol;
      _symbolController.text =
          '${widget.initialSymbolName ?? symbol} ($symbol)';
    }
    if (widget.initialSide != null) _side = widget.initialSide!;
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _limitPriceController.dispose();
    _justificationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSymbolChanged(String text) {
    if (_programmaticTextChange) {
      _programmaticTextChange = false;
      return;
    }
    _selectedSymbol = null;
    _debounce?.cancel();
    final q = text.trim();
    if (q.length < 2) {
      setState(() {
        _symbolResults = [];
        _searchingSymbol = false;
      });
      return;
    }
    setState(() => _searchingSymbol = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final r = await _api.searchLocal(q);
        if (!mounted) return;
        setState(() {
          _symbolResults = r;
          _searchingSymbol = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _symbolResults = [];
          _searchingSymbol = false;
        });
      }
    });
  }

  void _pickSymbol(String symbol, String description) {
    _selectedSymbol = symbol;
    _programmaticTextChange = true;
    _symbolController.text = '$description ($symbol)';
    _symbolController.selection = TextSelection.collapsed(
      offset: _symbolController.text.length,
    );
    FocusScope.of(context).unfocus();
    setState(() => _symbolResults = []);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final symbol = _selectedSymbol ?? _symbolController.text.trim();
    if (symbol.isEmpty) {
      setState(() => _error = l10n.etfProposeSymbolRequired);
      return;
    }
    final quantity = double.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _error = l10n.etfProposeQuantityRequired);
      return;
    }
    double? limitPrice;
    if (_orderType == 'limit') {
      limitPrice = double.tryParse(_limitPriceController.text.trim());
      if (limitPrice == null || limitPrice <= 0) {
        setState(() => _error = l10n.etfProposeLimitPriceRequired);
        return;
      }
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(fundApiServiceProvider)
          .proposeTrade(
            fundId: widget.fundId,
            symbol: symbol,
            side: _side,
            orderType: _orderType,
            limitPrice: limitPrice,
            quantity: quantity,
            justification: _justificationController.text.trim(),
          );
      ref.invalidate(fundProposalsProvider(widget.fundId));
      if (!mounted) return;
      // Straight back to the blotter (2026-09-12, reverted the earlier
      // "auto-open the new proposal's own detail screen" ask) — the
      // blotter's own row already shows everything a detail screen would
      // (status, approve/reject/flag), so opening a second view of the
      // exact same data right after submitting just read as a duplicate.
      Navigator.of(context).pop();
    } on FundApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = l10n.etfProposeGenericError);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _sectionLabel(AppPalette palette, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.textHeader,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
        title: themedHeaderText(
          l10n.etfProposeTradeTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(palette, l10n.etfProposeSymbolLabel),
              TextField(
                controller: _symbolController,
                onChanged: _onSymbolChanged,
                style: GoogleFonts.inter(color: palette.textHeader),
                decoration: InputDecoration(
                  hintText: l10n.etfProposeSymbolHint,
                  suffixIcon: _searchingSymbol
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_symbolResults.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 260),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _symbolResults.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (ctx, i) {
                      final item = _symbolResults[i];
                      final symbol = (item['symbol'] as String? ?? '')
                          .split('.')
                          .first;
                      final desc = item['description'] as String? ?? symbol;
                      return ListTile(
                        dense: true,
                        leading: CompanyLogo(ticker: symbol, radius: 16),
                        title: Text(
                          symbol,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: palette.textHeader,
                          ),
                        ),
                        subtitle: Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: palette.textBody,
                          ),
                        ),
                        onTap: () => _pickSymbol(symbol, desc),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeSideLabel),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.tradeBuy),
                    selected: _side == 'buy',
                    onSelected: (_) => setState(() => _side = 'buy'),
                    selectedColor: ThemeV2.success.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _side == 'buy'
                          ? ThemeV2.success
                          : palette.textBody,
                      fontWeight: _side == 'buy'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(l10n.tradeSell),
                    selected: _side == 'sell',
                    onSelected: (_) => setState(() => _side = 'sell'),
                    selectedColor: ThemeV2.loss.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _side == 'sell' ? ThemeV2.loss : palette.textBody,
                      fontWeight: _side == 'sell'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeOrderTypeLabel),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.etfProposeOrderTypeMarket),
                    selected: _orderType == 'market',
                    onSelected: (_) => setState(() => _orderType = 'market'),
                    selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _orderType == 'market'
                          ? palette.accentPrimary
                          : palette.textBody,
                      fontWeight: _orderType == 'market'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(l10n.etfProposeOrderTypeLimit),
                    selected: _orderType == 'limit',
                    onSelected: (_) => setState(() => _orderType = 'limit'),
                    selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _orderType == 'limit'
                          ? palette.accentPrimary
                          : palette.textBody,
                      fontWeight: _orderType == 'limit'
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeQuantityLabel),
              TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.inter(color: palette.textHeader),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_orderType == 'limit') ...[
                const SizedBox(height: 16),
                _sectionLabel(palette, l10n.etfProposeLimitPriceLabel),
                TextField(
                  controller: _limitPriceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.inter(color: palette.textHeader),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeJustificationLabel),
              TextField(
                controller: _justificationController,
                maxLines: 3,
                maxLength: 300,
                style: GoogleFonts.inter(color: palette.textHeader),
                decoration: InputDecoration(
                  hintText: l10n.etfProposeJustificationHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: GoogleFonts.inter(fontSize: 12, color: ThemeV2.loss),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: ThemeV2.buttonHeight,
                child: Material(
                  type: MaterialType.transparency,
                  child: themedDarkCtaButtonShell(
                    palette: palette,
                    borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                    standardDecoration: BoxDecoration(
                      color: ThemeV2.primary,
                      borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(ThemeV2.buttonRadius),
                      onTap: _submitting ? null : _submit,
                      child: Center(
                        child: _submitting
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: themedDarkCtaContentColor(palette),
                                ),
                              )
                            : Text(
                                l10n.etfProposeSubmitButton,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: themedDarkCtaContentColor(palette),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
