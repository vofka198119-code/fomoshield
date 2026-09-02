// ---------------------------------------------------------------------------
// Session Complete screen — combined "DIVERSIFICATION" card, replacing 3
// separate VerdictMarkerCard instances (Sector Diversification, Safety
// Marker, Sector Balance) with one card, 3 rows. Matches the Psychology
// Meter's own PsychologyDiversificationCard naming/grouping.
//
// Visual: light-theme adaptation of company_detail/financial_score_widget's
// _MarkerCard (color indicator bar + window border + name + "?" + score) —
// same shape, but on FomoShieldTheme's light card standard (title+divider)
// instead of the FS Score widget's dark dialLight/dialDark card, and no
// progress bars — those read as noise on a final summary, per explicit ask
// 2026-08-06. The "?" replaces VerdictMarkerCard's old "More" text button
// but pushes the exact same route.
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

class _DiversificationRow {
  final String markerId;
  final String label;
  final double score; // 0.0-1.0
  const _DiversificationRow({
    required this.markerId,
    required this.label,
    required this.score,
  });
}

class VerdictDiversificationCard extends ConsumerWidget {
  final String sessionId;
  final double sectorDiversificationScore;
  final double safetyMarkerScore;
  final double sectorBalanceScore;

  const VerdictDiversificationCard({
    super.key,
    required this.sessionId,
    required this.sectorDiversificationScore,
    required this.safetyMarkerScore,
    required this.sectorBalanceScore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final rows = [
      _DiversificationRow(
        markerId: 'sector-diversification',
        label: l10n.verdictDiversificationCardSectorDiversification,
        score: sectorDiversificationScore,
      ),
      _DiversificationRow(
        markerId: 'safety-marker',
        label: l10n.verdictDiversificationCardSafetyMarker,
        score: safetyMarkerScore,
      ),
      _DiversificationRow(
        markerId: 'sector-balance',
        label: l10n.verdictDiversificationCardSectorBalance,
        score: sectorBalanceScore,
      ),
    ];

    return CardFrame(
      padding: EdgeInsets.zero,
      decoration: palette.windowGradient != null
          ? BoxDecoration(
              gradient: palette.windowGradient,
              borderRadius: BorderRadius.circular(20),
            )
          : darkCardDecoration(borderRadius: BorderRadius.circular(20)),
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
                    l10n.verdictDiversificationCardTitle,
                    style: FomoShieldTheme.cardTitle(Colors.white).copyWith(
                      shadows: palette.titleShadow != null
                          ? [palette.titleShadow!]
                          : null,
                    ),
                  ),
                  palette,
                ),
                GestureDetector(
                  onTap: () =>
                      context.push('/metric-info/psychology-diversification'),
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
