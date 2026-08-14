// ---------------------------------------------------------------------------
// Shared dark-gradient card shell for the Psychology Meter's per-marker
// detail widgets (Discipline, Panic, Patience, Strategy, Diversification) —
// visual match for StressTestSectorAllocationCard (Diversification
// Indicator, ../stress_test_sector_allocation_widget.dart): title row +
// "?" info icon + divider + body.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/fomo_shield_theme.dart';
import '../../../market_clock/market_clock_dial.dart' show darkCardDecoration;

class PsychologyMarkerCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: darkCardDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: FomoShieldTheme.cardTitle(Colors.white)),
                  GestureDetector(
                    onTap: () => context.push('/metric-info/$infoId'),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.help_outline_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.white.withValues(alpha: 0.12),
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
