import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/theme_v2.dart';
import '../../../../../core/theme/fomo_shield_theme.dart';
import 'stock_detail_helpers.dart';

// ---------------------------------------------------------------------------
// Stress Test "Why Today" card — split out of the old monolithic
// stock_detail_screen.dart, restyled to the FomoShieldTheme card standard
// (was ThemeV2.surface + ad-hoc shadow). Content/logic unchanged.
// ---------------------------------------------------------------------------

class StockWhyTodayCard extends StatelessWidget {
  final String sessionId;
  final String symbol;
  final double priceChange;
  final double priceChangePercent;
  final bool isPositive;
  final double? marketPct;
  final double? sectorPct;
  final double? newsPct;
  final double? noisePct;

  const StockWhyTodayCard({
    super.key,
    required this.sessionId,
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.isPositive,
    this.marketPct,
    this.sectorPct,
    this.newsPct,
    this.noisePct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
      decoration: FomoShieldTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WHY TODAY', style: FomoShieldTheme.cardTitle()),
              FilledButton.tonal(
                onPressed: () =>
                    context.push('/stress-test/$sessionId/stock/$symbol/why'),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeV2.primaryBg,
                  foregroundColor: ThemeV2.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeV2.radiusSmall),
                  ),
                  textStyle: ThemeV2.small.copyWith(fontWeight: FontWeight.w600),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 14),
                    SizedBox(width: 6),
                    Text('Why today?'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0x0F000000)),
          Text(
            '${isPositive ? '+' : ''}${fmtFullCurrency(priceChange)} '
            '(${isPositive ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%)',
            style: ThemeV2.displayL.copyWith(
              color: isPositive ? ThemeV2.success : ThemeV2.loss,
            ),
          ),
          const SizedBox(height: 20),
          _factorBar('Scenario', (marketPct ?? 47) / 100, FomoShieldTheme.factorMarket),
          const SizedBox(height: 10),
          _factorBar('Sector Skew', (sectorPct ?? 29) / 100, FomoShieldTheme.factorSector),
          const SizedBox(height: 10),
          _factorBar('News', (newsPct ?? 14) / 100, FomoShieldTheme.factorNews),
          const SizedBox(height: 10),
          _factorBar('Noise', (noisePct ?? 10) / 100, FomoShieldTheme.factorNoise),
          const SizedBox(height: 16),
          Text(
            _defaultExplanation(isPositive),
            style: ThemeV2.body.copyWith(height: 1.5, color: ThemeV2.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(ThemeV2.radiusMedium),
            ),
            child: Row(
              children: [
                const Text('🧠', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guardian insight available — tap "Why today?" for full analysis',
                    style: ThemeV2.small.copyWith(color: ThemeV2.textSecondary),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: ThemeV2.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _factorBar(String label, double fraction, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: ThemeV2.small.copyWith(fontWeight: FontWeight.w600, color: ThemeV2.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ThemeV2.radiusSmall / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                  borderRadius: BorderRadius.circular(6),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          child: Text(
            '${(fraction * 100).round()}%',
            style: ThemeV2.small.copyWith(
              fontWeight: FontWeight.w600,
              color: ThemeV2.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  String _defaultExplanation(bool isPositive) {
    return isPositive
        ? 'Market sentiment is positive today. Broad market strength and '
            'sector tailwinds are driving this asset higher. Company-specific '
            'news adds extra momentum.'
        : 'Market pressure is weighing on this asset. A combination of '
            'sector rotation and company-specific headwinds explains today\'s '
            'decline. Noise accounts for some volatility.';
  }
}
