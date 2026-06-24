import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Markets Widget — Accordion with debounced clicks
// ---------------------------------------------------------------------------

class MarketsWidget extends ConsumerStatefulWidget {
  const MarketsWidget({super.key});

  @override
  ConsumerState<MarketsWidget> createState() => _MarketsWidgetState();
}

class _MarketsWidgetState extends ConsumerState<MarketsWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _onIndexTap(String symbol) {
    ref.read(debouncerProvider).run(() {
      context.push('/company/$symbol');
    });
  }

  @override
  Widget build(BuildContext context) {
    final indicesAsync = ref.watch(marketIndicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        GestureDetector(
          onTap: _toggle,
          child: Row(
            children: [
              Text(
                'MARKETS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDim,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textDim,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        indicesAsync.when(
          loading: () => _marketLoading(),
          error: (err, _) {
            debugPrint('❌ MarketsWidget error: $err');
            return _marketFallback();
          },
          data: (indices) => Column(
            children: indices
                .map(
                  (i) => _MarketCard(
                    name: i.name,
                    symbol: i.symbol,
                    price: i.price,
                    change: i.change,
                    onTap: () => _onIndexTap(i.symbol),
                  ),
                )
                .toList(),
          ),
        ),
        // Expandable details
        SizeTransition(
          sizeFactor: _heightFactor,
          axisAlignment: -1.0,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Major market indices snapshot from the previous trading day. '
                'S&P 500 tracks large-cap US stocks, NASDAQ tracks tech-heavy '
                'companies, and Dow Jones tracks 30 major US corporations.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textDim,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _marketLoading() => Column(
    children: [0, 1, 2]
        .map(
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentBlue,
                ),
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget _marketFallback() => Column(
    children: ['S&P 500', 'NASDAQ', 'DOW JONES']
        .map(
          (name) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '--',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$0.00',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '0.00%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textDim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .toList(),
  );
}

// ---------------------------------------------------------------------------
// Market Card (internal)
// ---------------------------------------------------------------------------

class _MarketCard extends StatelessWidget {
  final String name;
  final String symbol;
  final double price;
  final double change;
  final VoidCallback onTap;

  const _MarketCard({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = change >= 0;
    final changeColor = isUp ? AppTheme.shieldGreen : AppTheme.shieldRed;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isUp ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isUp ? '+' : ''}${change.toStringAsFixed(2)}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
