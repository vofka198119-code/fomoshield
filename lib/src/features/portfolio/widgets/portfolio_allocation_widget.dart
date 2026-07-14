import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/typography_helpers.dart';
import '../../../shared/widgets/widget_container.dart';
import '../portfolio_providers.dart';

// ---------------------------------------------------------------------------
// Portfolio Allocation Widget — horizontal bars + legend (sorted by weight)
// ---------------------------------------------------------------------------
// NOTE: Donut chart avoided intentionally — stress test screen uses one.
// This uses an editorial horizontal bar layout for visual variety.
// ---------------------------------------------------------------------------

class PortfolioAllocationWidget extends StatefulWidget {
  final List<HoldingPerformance>? holdings;

  const PortfolioAllocationWidget({super.key, this.holdings});

  @override
  State<PortfolioAllocationWidget> createState() =>
      _PortfolioAllocationWidgetState();
}

class _PortfolioAllocationWidgetState extends State<PortfolioAllocationWidget> {
  bool _showAll = false;
  static const int _previewLimit = 6;

  @override
  Widget build(BuildContext context) {
    final holdings = widget.holdings;

    if (holdings == null || holdings.isEmpty) {
      return WidgetContainer(
        title: 'ALLOCATION',
        onTap: () {},
        showFooter: false,
        emptyText: 'No holdings to show',
      );
    }

    // Sort descending by currentValue (largest first)
    final sorted = List<HoldingPerformance>.from(holdings)
      ..sort((a, b) => b.currentValue.compareTo(a.currentValue));
    final total = sorted.fold<double>(0, (s, h) => s + h.currentValue);
    final maxValue = sorted.isNotEmpty ? sorted.first.currentValue : 1.0;
    final display = _showAll ? sorted : sorted.take(_previewLimit).toList();
    final hiddenCount = sorted.length - _previewLimit;

    return WidgetContainer(
      title: 'ALLOCATION',
      onTap: () {},
      showFooter: false,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Total allocation header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${sorted.length} holdings',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ThemeV2.textSecondary,
                    ),
                  ),
                  Text(
                    '\$${_fmtFull(total)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ── Holdings bars ──
              ...display.asMap().entries.map((entry) {
                final i = entry.key;
                final h = entry.value;
                final share = total > 0 ? h.currentValue / total : 0.0;
                final fraction = maxValue > 0 ? h.currentValue / maxValue : 0.0;
                final barColor = _barColor(i);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symbol + percentage + value row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: barColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                h.symbol,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeV2.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(share * 100).toStringAsFixed(1)}%',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeV2.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  '\$${_fmtFull(h.currentValue)}',
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: ThemeV2.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Horizontal bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 6,
                          color: ThemeV2.surfaceDark,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: fraction.clamp(0.02, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // ── Show more / less button ──
              if (sorted.length > _previewLimit)
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAll = !_showAll),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeV2.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _showAll ? 'Show less' : '+ $hiddenCount more',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ThemeV2.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtFull(num n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(2)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(2)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(2)}K';
    return n.toStringAsFixed(2);
  }

  static const _colors = [
    ThemeV2.primary,
    ThemeV2.success,
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF1ABC9C),
    Color(0xFF3498DB),
    ThemeV2.warning,
    ThemeV2.loss,
  ];

  Color _barColor(int i) => _colors[i % _colors.length];
}

