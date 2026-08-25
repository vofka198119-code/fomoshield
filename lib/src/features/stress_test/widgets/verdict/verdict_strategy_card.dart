// ---------------------------------------------------------------------------
// Session Complete screen — combined "STRATEGY" card, mirrors
// VerdictDiversificationCard's shape exactly (color bar + window border +
// name + "?" + score, no progress bars) but for the Strategy pillar's other
// 3 sub-signals: Concentration, ETF Exposure, Cash Buffer. Replaces the old
// separate generic "Strategy" composite VerdictMarkerCard and the standalone
// Concentration VerdictMarkerCard.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_variant_provider.dart';
import '../../../../core/theme/themed_header.dart';
import '../../../../core/theme/themed_divider.dart';
import '../../../../shared/widgets/card_frame.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;
import 'verdict_marker_row.dart';

class _StrategyRow {
  final String markerId;
  final String label;
  final double score; // 0.0-1.0
  const _StrategyRow({
    required this.markerId,
    required this.label,
    required this.score,
  });
}

class VerdictStrategyCard extends ConsumerWidget {
  final String sessionId;
  final double concentrationScore;
  final double etfExposureScore;
  final double cashBufferScore;

  const VerdictStrategyCard({
    super.key,
    required this.sessionId,
    required this.concentrationScore,
    required this.etfExposureScore,
    required this.cashBufferScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final rows = [
      _StrategyRow(
        markerId: 'concentration',
        label: l10n.verdictStrategyCardConcentration,
        score: concentrationScore,
      ),
      _StrategyRow(
        markerId: 'etf-exposure',
        label: l10n.verdictStrategyCardEtfExposure,
        score: etfExposureScore,
      ),
      _StrategyRow(
        markerId: 'cash-buffer',
        label: l10n.verdictStrategyCardCashBuffer,
        score: cashBufferScore,
      ),
    ];

    return CardFrame(
      showTopBar: false,
      padding: EdgeInsets.zero,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(22)),
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                themedGoldGradient(
                  Text(
                    l10n.verdictStrategyCardTitle,
                    style: FomoShieldTheme.cardTitle(Colors.white).copyWith(
                      shadows: palette.titleShadow != null
                          ? [palette.titleShadow!]
                          : null,
                    ),
                  ),
                  palette,
                ),
                GestureDetector(
                  onTap: () => context.push('/metric-info/psychology-strategy'),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 18),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == rows.length - 1 ? 0 : 10,
                    ),
                    child: VerdictMarkerRow(
                      sessionId: sessionId,
                      markerId: rows[i].markerId,
                      label: rows[i].label,
                      score: rows[i].score,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
