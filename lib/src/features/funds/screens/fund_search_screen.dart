import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart' show AppPalette, resolveAppPalette;
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../core/theme/themed_divider.dart';
import '../../../core/theme/themed_border.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../../shared/widgets/company_logo.dart';
import '../../search/widgets/exchange_badge.dart';

// ---------------------------------------------------------------------------
// Fund Search — plain company search scoped to a fund's own trading flow
// (2026-09-15, opened from Fund Management's new "Trading" shortcut).
// Tapping a result opens the existing fund-scoped Company Detail
// (fundContext route extra), the same mechanism Fund Management's own
// holdings card already uses to reach it -- FundPositionSection just
// renders a zero position for a symbol the fund doesn't hold yet, which is
// accurate. From there, Buy/Sell opens FundTradeEntryScreen exactly as it
// does for an already-held symbol; nothing about that path needed to
// change.
//
// Deliberately its OWN minimal search, not a reuse of the personal Search
// screen: no Funds tab, no watchlist bookmark button, no browse lanes, and
// -- matching the old ProposeTradeScreen's own inline search -- no personal
// search-quota consumption, since finding a symbol to trade for the fund
// isn't the user's own watchlist search allowance to spend.
// ---------------------------------------------------------------------------

class FundSearchScreen extends ConsumerStatefulWidget {
  final String fundId;
  final String fundName;

  const FundSearchScreen({
    super.key,
    required this.fundId,
    required this.fundName,
  });

  @override
  ConsumerState<FundSearchScreen> createState() => _FundSearchScreenState();
}

class _FundSearchScreenState extends ConsumerState<FundSearchScreen> {
  final _controller = TextEditingController();
  final _api = FinnhubService();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    final q = text.trim();
    setState(() {}); // refresh the field's own clear button
    if (q.length < 2) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final r = await _api.searchLocal(q);
        if (!mounted) return;
        setState(() {
          _results = r;
          _loading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _results = [];
          _loading = false;
        });
      }
    });
  }

  void _openCompany(String symbol) {
    context.push(
      '/company/$symbol',
      extra: {
        'fundContext': {
          'fundId': widget.fundId,
          'fundName': widget.fundName,
          'quantity': 0.0,
          'price': 0.0,
          'value': 0.0,
          'percentOfFund': 0.0,
        },
      },
    );
  }

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
          l10n.searchTitle,
          palette,
          GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: themedBorder(
                palette: palette,
                borderRadius: ThemeV2.borderRadiusMedium,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: palette.windowGradient,
                    borderRadius: ThemeV2.borderRadiusMedium,
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      hintStyle: GoogleFonts.inter(
                        color: palette.textBody,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: palette.textBody,
                      ),
                      border: InputBorder.none,
                      enabledBorder: palette.windowGradient == null
                          ? null
                          : InputBorder.none,
                      focusedBorder: palette.windowGradient == null
                          ? null
                          : InputBorder.none,
                      filled: false,
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: palette.textBody,
                                size: 20,
                              ),
                              onPressed: () {
                                _controller.clear();
                                _onChanged('');
                              },
                            ),
                    ),
                    style: GoogleFonts.inter(
                      color: palette.textHeader,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildResults(l10n, palette)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AppLocalizations l10n, AppPalette palette) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: palette.accentPrimary),
      );
    }
    final q = _controller.text.trim();
    // Same as the personal Search screen's own typed-results branch: no
    // prompt copy while under the 2-char minimum, just blank.
    if (q.length < 2) return const SizedBox.shrink();
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: palette.textBody,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.searchNoResults,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: palette.textBody, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      separatorBuilder: (_, _) => palette.dividerGradient != null
          ? themedDivider(palette, indent: 0, endIndent: 0)
          : const Divider(),
      itemBuilder: (context, i) {
        final item = _results[i];
        final symbol = (item['symbol'] as String? ?? '').split('.').first;
        final name = item['description'] as String? ?? symbol;
        final type = item['type'] as String? ?? '';
        return ListTile(
          key: ValueKey(symbol),
          leading: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: palette.accentPrimary, width: 1.5),
            ),
            child: CompanyLogo(ticker: symbol, radius: 22),
          ),
          title: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: palette.textHeader,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Text(
                symbol,
                style: GoogleFonts.inter(fontSize: 12, color: palette.textBody),
              ),
              const SizedBox(width: 6),
              ExchangeBadge(symbol: symbol, type: type),
            ],
          ),
          onTap: () => _openCompany(symbol),
        );
      },
    );
  }
}
