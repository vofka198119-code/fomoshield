import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/widget_container.dart';

// ---------------------------------------------------------------------------
// Portfolio Widget — Revolut-style placeholder
// ---------------------------------------------------------------------------
// Displays a large $0.00 balance with "coming soon" status.
// ---------------------------------------------------------------------------

class PortfolioWidget extends ConsumerWidget {
  const PortfolioWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WidgetContainer(
      title: 'MY PORTFOLIO',
      onTap: () => context.go('/portfolio'),
      showFooter: false,
      children: [
        // Balance section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance label
              Text(
                'Total Balance',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textDim,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              // Large balance
              Text(
                '\$0.00',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              // Status label
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.shieldYellow,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Simulation mode',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.shieldYellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Divider
        const Divider(height: 1, indent: 16, endIndent: 16),
        const SizedBox(height: 12),
        // Coming soon badge
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentBlue.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.science_rounded,
                  color: AppTheme.accentBlue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulation & Stress Testing mode is coming soon',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textDim,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
