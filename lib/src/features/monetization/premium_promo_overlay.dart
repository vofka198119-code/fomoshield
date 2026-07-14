import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scanco/src/core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Premium Promo Overlay — 5‑second simulated "ad" for free users
// ---------------------------------------------------------------------------
// Shown when a free‑tier user hits a limit (portfolio count, stress test
// sessions, capital, etc.).  The overlay looks like a realistic premium ad
// and auto‑dismisses after [durationSeconds].  After dismissal the optional
// [onComplete] callback fires (e.g. to show the monetization modal).
//
// Uses showGeneralDialog for reliable route lifecycle (works inside GoRouter /
// ShellRoute without hanging).
// ---------------------------------------------------------------------------

/// Shows a full‑screen premium promo overlay with a countdown timer.
///
/// [title] – short reason why this is shown (e.g. "Portfolio limit reached").
/// [durationSeconds] – how long the overlay stays up (default 5).
/// [onComplete] – optional callback fired after the timer finishes.
Future<void> showPremiumPromoOverlay({
  required BuildContext context,
  String title = 'Premium feature',
  int durationSeconds = 5,
  VoidCallback? onComplete,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    barrierLabel: 'Premium promo overlay',
    pageBuilder: (ctx, animation, secondaryAnimation) => _PremiumPromoOverlay(
      title: title,
      durationSeconds: durationSeconds,
      onComplete: () {
        // Pop the dialog first, then fire callback
        Navigator.of(ctx).pop();
        onComplete?.call();
      },
    ),
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

// ===========================================================================
// Overlay widget
// ===========================================================================

class _PremiumPromoOverlay extends StatefulWidget {
  final String title;
  final int durationSeconds;
  final VoidCallback? onComplete;

  const _PremiumPromoOverlay({
    required this.title,
    required this.durationSeconds,
    this.onComplete,
  });

  @override
  State<_PremiumPromoOverlay> createState() => _PremiumPromoOverlayState();
}

class _PremiumPromoOverlayState extends State<_PremiumPromoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  bool _showClose = false;
  static const _closeDelay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.forward();

    // Show close button after a short delay (honest: user can skip)
    Future.delayed(_closeDelay, () {
      if (mounted) setState(() => _showClose = true);
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete?.call();
      }
    });
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
          margin: const EdgeInsets.symmetric(horizontal: 24),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF001A0D), Color(0xFF002E18), Color(0xFF001A0D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.premiumGreen.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.premiumGreen.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Premium badge ────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.premiumGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.premiumGreen.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 16,
                        color: AppTheme.premiumGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PREMIUM',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppTheme.premiumGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ────────────────────────────────────────
                Text(
                  widget.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Upgrade to unlock this and more',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.premiumGreen.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // ── Feature list ─────────────────────────────────
                _featureRow(Icons.search_rounded, 'Unlimited daily searches'),
                const SizedBox(height: 10),
                _featureRow(
                  Icons.account_balance_rounded,
                  'Up to 6 portfolios',
                ),
                const SizedBox(height: 10),
                _featureRow(
                  Icons.monetization_on_rounded,
                  '\$15,000 starting capital',
                ),
                const SizedBox(height: 10),
                _featureRow(Icons.psychology_rounded, 'Up to 5 stress tests'),
                const SizedBox(height: 10),
                _featureRow(Icons.block_rounded, 'Completely ad‑free'),
                const SizedBox(height: 28),

                // ── Countdown timer ──────────────────────────────
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    final remaining =
                        widget.durationSeconds -
                        (_progress.value * widget.durationSeconds).toInt();
                    return SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background ring
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 3,
                              color: AppTheme.premiumGreen.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                          // Progress ring
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              value: _progress.value,
                              strokeWidth: 3,
                              strokeCap: StrokeCap.round,
                              color: AppTheme.premiumGreen,
                            ),
                          ),
                          // Seconds text
                          Text(
                            '${remaining}s',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.premiumGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Neutral countdown status — honest about what's happening
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    final sec =
                        widget.durationSeconds -
                        (_progress.value * widget.durationSeconds).toInt();
                    return Text(
                      'Closing in ${sec}s…',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textDim,
                      ),
                    );
                  },
                ),
                // Close button appears after ~2s — user can skip the wait
                const SizedBox(height: 12),
                if (_showClose)
                  TextButton(
                    onPressed: () {
                      _controller.stop();
                      widget.onComplete?.call();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.premiumGreen.withValues(
                        alpha: 0.6,
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Close'),
                  )
                else
                  const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.premiumGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.premiumGreen.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.premiumGreen.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
