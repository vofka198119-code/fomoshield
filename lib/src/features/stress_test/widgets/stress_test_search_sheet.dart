// ---------------------------------------------------------------------------
// StressTestSearchSheet — Search + Buy for Stress Test Portfolio
// ---------------------------------------------------------------------------
// Modal bottom sheet that lets the user search for a company via Finnhub,
// enter an investment amount, and buy it directly into the stress test
// session engine cache (not the main finhub portfolio).
// ---------------------------------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/finnhub_service.dart';
import '../../../shared/widgets/company_logo.dart';
import '../stress_test_engine.dart';
import '../stress_test_models.dart';

/// Shows a search bottom sheet for adding assets to a stress test session.
/// Returns `true` if at least one asset was purchased.
Future<bool?> showStressTestSearchSheet(
  BuildContext context,
  WidgetRef ref,
  String sessionId,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _StressTestSearchSheet(sessionId: sessionId),
  );
}

// ---------------------------------------------------------------------------
// Internal State
// ---------------------------------------------------------------------------

class _StressTestSearchSheet extends ConsumerStatefulWidget {
  final String sessionId;
  const _StressTestSearchSheet({required this.sessionId});

  @override
  ConsumerState<_StressTestSearchSheet> createState() =>
      _StressTestSearchSheetState();
}

class _StressTestSearchSheetState
    extends ConsumerState<_StressTestSearchSheet> {
  final _searchController = TextEditingController();
  final _api = FinnhubService();
  Timer? _debounce;

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _showAmountInput = false;
  String _selectedSymbol = '';
  String _selectedDescription = '';
  double _selectedPrice = 0;
  double _amount = 500;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Debounced Search ────────────────────────────────────────────

  void _onSearchChanged() {
    _debounce?.cancel();
    final q = _searchController.text.trim();
    if (q.length < 2) {
      setState(() {
        _results = [];
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }
    setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final r = await _api.search(q);
        if (!mounted) return;
        setState(() {
          _results = r;
          _isLoading = false;
          _errorMessage = null;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _results = [];
          _isLoading = false;
          _errorMessage = 'Search failed. Check your connection.';
        });
      }
    });
  }

  // ── Step 2: Fetch Price & Show Amount Input ────────────────────

  Future<void> _selectCompany(String symbol, String description) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final quote = await _api.quote(symbol);
      if (!mounted) return;
      final price = (quote['c'] as num?)?.toDouble() ?? 0;
      if (price <= 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No price data available for $symbol.';
        });
        return;
      }
      setState(() {
        _selectedSymbol = symbol;
        _selectedDescription = description;
        _selectedPrice = price;
        _amount = 500;
        _showAmountInput = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not fetch price for $symbol.';
      });
    }
  }

  // ── Step 3: Confirm Purchase ────────────────────────────────────

  Future<void> _confirmPurchase() async {
    if (_amount <= 0) return;
    setState(() => _isLoading = true);

    final engine = ref.read(stressTestProvider.notifier);
    final session = engine.getSession(widget.sessionId);
    final isSetup = session?.status == StressTestStatus.setup;

    bool success;
    if (isSetup) {
      success = await engine.buyAssetSetup(
        widget.sessionId, _selectedSymbol, _amount, _selectedPrice,
      );
    } else {
      // Active phase — use executeTrade
      final result = engine.executeTrade(
        widget.sessionId, _selectedSymbol, true, _amount,
      );
      success = result.success;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _errorMessage = 'Not enough cash or unable to trade.');
    }
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              _showAmountInput ? 'Confirm Purchase' : 'Add Asset',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          if (!_showAmountInput) ...[
            // ── Step 1: Search ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search company (e.g. Apple, Cola)...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textDim,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.textDim),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.accentBlue,
                            ),
                          ),
                        )
                      : (_searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 20, color: AppTheme.textDim),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _results = [];
                                  _errorMessage = null;
                                });
                              },
                            )
                          : null),
                  filled: true,
                  fillColor: AppTheme.stressBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),

            // Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.dangerRed,
                  ),
                ),
              ),

            // Results
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.length < 2
                            ? 'Type at least 2 characters to search'
                            : 'No results found',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textDim,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 56,
                        color: Colors.black12,
                      ),
                      itemBuilder: (ctx, i) {
                        final item = _results[i];
                        final symbol =
                            (item['symbol'] as String? ?? '').split('.').first;
                        final desc =
                            item['description'] as String? ?? symbol;
                        final type = item['type'] as String? ?? '';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          leading: CompanyLogo(
                            ticker: symbol,
                            radius: 20,
                          ),
                          title: Text(
                            symbol,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            desc,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textDim,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            type,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textDim,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _selectCompany(symbol, desc),
                        );
                      },
                    ),
            ),
          ] else ...[
            // ── Step 2: Amount Input ────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset + 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Company info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CompanyLogo(
                          ticker: _selectedSymbol,
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedSymbol,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedDescription,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.textDim,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price info
                    Text(
                      'Current price: \$${_selectedPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textDim,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quick amounts
                    Text(
                      'How much do you want to invest?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount text field
                    TextField(
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        hintText: '500',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDim,
                        ),
                        filled: true,
                        fillColor: AppTheme.stressBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      onChanged: (v) {
                        _amount = double.tryParse(v.replaceAll('\$', '')) ?? 0;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quick select chips
                    Wrap(
                      spacing: 8,
                      children: [100, 500, 1000, 2500, 5000].map((v) {
                        final selected = _amount == v;
                        return ChoiceChip(
                          label: Text(
                            '\$$v',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          selected: selected,
                          selectedColor: AppTheme.accentBlue,
                          backgroundColor: AppTheme.stressBg,
                          onSelected: (_) =>
                              setState(() => _amount = v.toDouble()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Error
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.dangerRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Buy button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading || _amount <= 0 ? null : _confirmPurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.accentBlue.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Buy \$${_amount.toStringAsFixed(0)} worth',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Back button
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAmountInput = false;
                          _selectedSymbol = '';
                          _selectedDescription = '';
                          _selectedPrice = 0;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        'Choose another company',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textDim,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
