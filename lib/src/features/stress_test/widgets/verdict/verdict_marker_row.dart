// ---------------------------------------------------------------------------
// Shared row: color bar + window border + name + "?" + score, no progress
// bar. Used both inside multi-row combo cards (VerdictDiversificationCard,
// VerdictStrategyCard) and, via VerdictSingleMarkerCard, as a standalone
// one-row card for markers that don't share a combo (Discipline/Panic/
// Patience). One shape everywhere on Session Complete — see 2026-08-06/07
// visual-parity asks.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme_v2.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/theme_variant_provider.dart';
import '../../../../core/theme/themed_header.dart';
import '../../../../core/theme/themed_divider.dart';
import '../../../../shared/widgets/card_frame.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;

class VerdictMarkerRow extends ConsumerWidget {
  final String sessionId;
  final String markerId;
  final String label;
  final double score; // 0.0-1.0

  const VerdictMarkerRow({
    super.key,
    required this.sessionId,
    required this.markerId,
    required this.label,
    required this.score,
  });

  Color get _color {
    if (score >= 0.7) return ThemeV2.success;
    if (score >= 0.4) return ThemeV2.warning;
    return ThemeV2.loss;
  }

  String _statusWord(AppLocalizations l10n) {
    if (score >= 0.7) return l10n.verdictMarkerRowGood;
    if (score >= 0.4) return l10n.verdictMarkerRowFair;
    return l10n.verdictMarkerRowNeedsWork;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final color = _color;
    final radius = BorderRadius.circular(12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      // Matches financial_score_widget.dart's _MarkerCard — plain
      // transparent fill + flat white 10% border, no theme gradient/glow.
      // Used to go through themedBorder() (gold under Luxury Gold), which
      // read as off; kept unconditional to match the FS Score reference
      // the user pointed at (2026-09-02).
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Single tap target for "see detailed result" — replaces both the
          // raw score number and the row's own separate "?" icon (2026-08-16,
          // both did the same thing, kept only this one; the card HEADER's
          // own "?" — general explanatory article, not this row's detail
          // screen — is untouched).
          GestureDetector(
            onTap: () => context.push(
              '/stress-test/$sessionId/verdict/marker/$markerId',
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusWord(l10n),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One-row version of the DIVERSIFICATION/STRATEGY combo-card shape, for
/// markers that stand alone (Discipline/Panic/Patience) rather than
/// sharing a card with siblings.
class VerdictSingleMarkerCard extends ConsumerWidget {
  final String sessionId;
  final String markerId;
  final String title; // card header, e.g. 'DISCIPLINE'
  final String label; // row label, e.g. 'Discipline'
  final double score; // 0.0-1.0

  const VerdictSingleMarkerCard({
    super.key,
    required this.sessionId,
    required this.markerId,
    required this.title,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
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
                    title,
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
                      context.push('/metric-info/psychology-$markerId'),
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
            child: VerdictMarkerRow(
              sessionId: sessionId,
              markerId: markerId,
              label: label,
              score: score,
            ),
          ),
        ],
      ),
    );
  }
}
