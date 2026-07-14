import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widget_container.dart';

// ---------------------------------------------------------------------------
// Historical Simulator — Premium Widget
// ---------------------------------------------------------------------------
// Simulate portfolio performance over 10Y or 20Y using historical data.
// Only visible to PREMIUM users. FREE users see a locked placeholder.
// ---------------------------------------------------------------------------

class HistoricalSimWidget extends ConsumerWidget {
  const HistoricalSimWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WidgetContainer(
      title: 'Historical Simulator',
      onTap: () => context.push('/historical-sim'),
      footerText: 'Run simulation',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.premiumGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: AppTheme.premiumGreen,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Simulate 10Y / 20Y performance',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'See how your portfolio would have performed historically',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
