import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/fomo_shield_theme.dart';

// ===========================================================================
// Events Stub
// ===========================================================================

class EventsStub extends StatelessWidget {
  const EventsStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(FomoShieldTheme.cardPadding),
        decoration: FomoShieldTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UPCOMING EVENTS',
              style: FomoShieldTheme.cardTitle(),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.black.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_rounded, size: 20, color: ThemeV2.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'No upcoming events',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ThemeV2.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
