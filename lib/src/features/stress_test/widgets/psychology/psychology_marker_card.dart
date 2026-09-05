// ---------------------------------------------------------------------------
// Shared dark-gradient card shell for the Psychology Meter's per-marker
// detail widgets (Discipline, Panic, Patience, Strategy, Diversification) —
// visual match for StressTestSectorAllocationCard (Diversification
// Indicator, ../stress_test_sector_allocation_widget.dart): title row +
// "?" info icon + divider + body.
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
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;

class PsychologyMarkerCard extends ConsumerWidget {
  final String title;
  final String infoId; // pushes /metric-info/$infoId
  final Widget child;

  const PsychologyMarkerCard({
    super.key,
    required this.title,
    required this.infoId,
    required this.child,
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
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  themedGoldGradient(
                    Text(
                      title,
                      style: FomoShieldTheme.cardTitle(palette.onWindow ?? Colors.white).copyWith(
                        shadows: palette.titleShadow != null
                            ? [palette.titleShadow!]
                            : null,
                      ),
                    ),
                    palette,
                  ),
                  themedHelpIcon(
                    palette: palette,
                    onWindow: true,
                    onTap: () => context.push('/metric-info/$infoId'),
                  ),
                ],
              ),
            ),
          ),
          palette.dividerGradient != null
              ? themedDivider(palette)
              : Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: (palette.onWindow ?? Colors.white).withValues(alpha: 0.12),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}
