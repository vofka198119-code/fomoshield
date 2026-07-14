import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/supabase/supabase_providers.dart';
import '../search/search_counter_provider.dart';

// ---------------------------------------------------------------------------
// Monetization Modal — shown when user hits search limit
// ---------------------------------------------------------------------------
// Two options:
//   1. "Upgrade to Premium" — Coming Soon (stub)
//   2. "Watch Ad (+15 searches)" — simulated 3s ad overlay, then +15
//
// Admin override: "Reset counter" button when isAdminProvider == true
// ---------------------------------------------------------------------------

/// Shows the monetization modal as a bottom sheet.
Future<void> showMonetizationModal(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (_) => _MonetizationSheet(),
  );
}

// ===========================================================================
// Sheet
// ===========================================================================

class _MonetizationSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppTheme.accentBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Search limit reached',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            'You\'ve used all your free searches. Upgrade to Premium for unlimited searches or watch an ad to get 15 more.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // ── Premium Button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoonSnack(context);
              },
              icon: const Icon(Icons.workspace_premium_rounded, size: 20),
              label: Text(
                'Upgrade to Premium',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.premiumGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Watch Ad Button ────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAdOverlay(context, ref);
              },
              icon: const Icon(Icons.play_circle_rounded, size: 20),
              label: Text(
                'Watch Ad (+15 searches)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentBlue,
                side: const BorderSide(color: AppTheme.accentBlue),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          // ── Admin: Reset ───────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(searchCounterProvider.notifier).resetToFree();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔧 Counter reset to 15 (admin)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                label: Text(
                  'Reset counter (admin)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textDim,
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textDim),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ===========================================================================
// Simulated Ad Overlay
// ===========================================================================

void _showAdOverlay(BuildContext context, WidgetRef ref) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AdOverlay(ref: ref),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

class _AdOverlay extends StatefulWidget {
  final WidgetRef ref;
  const _AdOverlay({required this.ref});

  @override
  State<_AdOverlay> createState() => _AdOverlayState();
}

class _AdOverlayState extends State<_AdOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  bool _showSkip = false;
  static const _skipDelay = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.forward();

    // Show skip button after 1s — standard Rewarded Ad practice
    Future.delayed(_skipDelay, () {
      if (mounted) setState(() => _showSkip = true);
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _grantRewardAndClose();
      }
    });
  }

  void _grantRewardAndClose() {
    widget.ref.read(searchCounterProvider.notifier).addSearches(15);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Earned 15 more searches!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinning icon
              const Icon(
                Icons.videocam_rounded,
                color: AppTheme.accentBlue,
                size: 48,
              ),
              const SizedBox(height: 24),

              Text(
                'Sponsored Ad',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Your reward: +15 free searches',
                style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDim),
              ),
              const SizedBox(height: 24),

              // Progress bar
              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: AppTheme.cardDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accentBlue,
                      ),
                      minHeight: 6,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              AnimatedBuilder(
                animation: _progress,
                builder: (context, child) {
                  final remaining = 3 - (_progress.value * 3).toInt();
                  return Text(
                    '${remaining}s remaining',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textDim,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Skip button appears after 1s — standard Rewarded Ad UX
              if (_showSkip)
                TextButton(
                  onPressed: () {
                    _controller.stop();
                    _grantRewardAndClose();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textDim,
                    textStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Skip'),
                )
              else
                const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Helpers
// ===========================================================================

void _showComingSoonSnack(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('🏗️ Premium subscription — coming soon!'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ),
  );
}
