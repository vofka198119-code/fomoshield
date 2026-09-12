import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/themed_button.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../providers/fund_providers.dart';
import '../services/fund_api_service.dart' show FundApiException;

// ---------------------------------------------------------------------------
// Propose Trade Sheet — Phase 4 (docs/ETF_FUND_EMULATION.md). Same bottom-
// sheet shell + ChoiceChip picker recipe as send_invite_sheet.dart. Doc:
// "краткое обоснование + лимитная цена + количество" — justification,
// limit price (only for a limit order), and quantity are the fields the
// design calls for; symbol + side (buy/sell) + order type round it out.
// ---------------------------------------------------------------------------

Future<bool?> showProposeTradeSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String fundId,
  required AppPalette palette,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ProposeTradeSheet(fundId: fundId, palette: palette),
  );
}

class _ProposeTradeSheet extends ConsumerStatefulWidget {
  final String fundId;
  final AppPalette palette;

  const _ProposeTradeSheet({required this.fundId, required this.palette});

  @override
  ConsumerState<_ProposeTradeSheet> createState() => _ProposeTradeSheetState();
}

class _ProposeTradeSheetState extends ConsumerState<_ProposeTradeSheet> {
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _limitPriceController = TextEditingController();
  final _justificationController = TextEditingController();
  String _side = 'buy';
  String _orderType = 'market';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _symbolController.dispose();
    _quantityController.dispose();
    _limitPriceController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final symbol = _symbolController.text.trim();
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
      Navigator.of(context).pop(true);
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
    final palette = widget.palette;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeV2.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.etfProposeTradeTitle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: palette.textHeader,
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeSymbolLabel),
              TextField(
                controller: _symbolController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z.]')),
                ],
                style: GoogleFonts.inter(color: palette.textHeader),
                decoration: InputDecoration(
                  hintText: l10n.etfProposeSymbolHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      color: _side == 'buy' ? ThemeV2.success : palette.textBody,
                      fontWeight: _side == 'buy' ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(l10n.tradeSell),
                    selected: _side == 'sell',
                    onSelected: (_) => setState(() => _side = 'sell'),
                    selectedColor: ThemeV2.loss.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _side == 'sell' ? ThemeV2.loss : palette.textBody,
                      fontWeight: _side == 'sell' ? FontWeight.w700 : FontWeight.w500,
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
                      color: _orderType == 'market' ? palette.accentPrimary : palette.textBody,
                      fontWeight: _orderType == 'market' ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(l10n.etfProposeOrderTypeLimit),
                    selected: _orderType == 'limit',
                    onSelected: (_) => setState(() => _orderType = 'limit'),
                    selectedColor: palette.accentPrimary.withValues(alpha: 0.2),
                    labelStyle: GoogleFonts.inter(
                      color: _orderType == 'limit' ? palette.accentPrimary : palette.textBody,
                      fontWeight: _orderType == 'limit' ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionLabel(palette, l10n.etfProposeQuantityLabel),
              TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 16),
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
