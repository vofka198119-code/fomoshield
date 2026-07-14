import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widget_container.dart';

// ---------------------------------------------------------------------------
// Portfolio Journal — Premium Widget
// ---------------------------------------------------------------------------
// Track trade emotions and journal your investing decisions.
// Only visible to PREMIUM users. FREE users see a locked placeholder.
// ---------------------------------------------------------------------------

class PortfolioJournalWidget extends ConsumerWidget {
  const PortfolioJournalWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WidgetContainer(
      title: 'Portfolio Journal',
      onTap: () => context.push('/portfolio-journal'),
      footerText: 'Open journal',
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
                  Icons.auto_stories_rounded,
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
                      'Track your trading emotions',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log wins, losses, and feelings after each trade',
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
