import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/cache/logo_providers.dart';
import '../../shared/services/finnhub_service.dart';
import '../../shared/widgets/company_logo.dart';
import '../home/home_providers.dart';

// ---------------------------------------------------------------------------
// Search Provider with 500ms Debounce
// ---------------------------------------------------------------------------

final searchProvider = ChangeNotifierProvider<SearchNotifier>(
  (ref) => SearchNotifier(),
);

class SearchNotifier extends ChangeNotifier {
  final FinnhubService _api = FinnhubService();
  List<Map<String, dynamic>> results = [];
  List<String> recentSearches = [];
  bool isLoading = false;
  String query = '';
  Timer? _debounce;

  SearchNotifier();

  /// Called on every keystroke — debounces 500ms before actual API call
  void onSearchInput(String q) {
    query = q;
    _debounce?.cancel();

    if (q.length < 2) {
      results = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        results = await _api.search(q);
      } catch (e) {
        debugPrint('❌ Search error for "$q": $e');
        results = [];
      }
      isLoading = false;
      notifyListeners();
    });
  }

  void selectCompany(String symbol) {
    if (!recentSearches.contains(symbol)) {
      recentSearches.insert(0, symbol);
      if (recentSearches.length > 10) recentSearches.removeLast();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Search Screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (q) => ref.read(searchProvider.notifier).onSearchInput(q),
          decoration: InputDecoration(
            hintText: 'Search ticker or company...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
            border: InputBorder.none,
            filled: false,
          ),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        ),
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentBlue),
            )
          : state.results.isEmpty && state.query.isNotEmpty
          ? Center(
              child: Text(
                'No results',
                style: GoogleFonts.inter(color: AppTheme.textDim, fontSize: 14),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.results.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final item = state.results[i];
                final symbol = item['symbol'] as String? ?? '';
                final name = item['description'] as String? ?? '';
                final type = item['type'] as String? ?? '';

                return ListTile(
                  key: ValueKey(symbol),
                  leading: Consumer(
                    builder: (context, ref, _) {
                      final logoAsync = ref.watch(cachedLogoProvider(symbol));
                      final logoUrl = logoAsync.valueOrNull;
                      return CompanyLogo(ticker: symbol, logoUrl: logoUrl);
                    },
                  ),
                  title: Text(
                    symbol,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textDim,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Consumer(
                        builder: (context, ref, _) {
                          final inWatchlist = ref
                              .watch(watchlistSymbolsProvider)
                              .contains(symbol);
                          return IconButton(
                            icon: Icon(
                              inWatchlist
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              size: 20,
                              color: inWatchlist
                                  ? AppTheme.accentBlue
                                  : AppTheme.textDim,
                            ),
                            onPressed: () {
                              if (inWatchlist) {
                                ref
                                    .read(watchlistSymbolsProvider.notifier)
                                    .remove(symbol);
                              } else {
                                ref
                                    .read(watchlistSymbolsProvider.notifier)
                                    .add(symbol);
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    ref.read(searchProvider.notifier).selectCompany(symbol);
                    // Debounce 1s guard against double-tap
                    ref
                        .read(debouncerProvider)
                        .run(() => context.push('/company/$symbol'));
                  },
                );
              },
            ),
    );
  }
}
