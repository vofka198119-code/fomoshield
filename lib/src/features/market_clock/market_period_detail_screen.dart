import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../stress_test/stress_test_hub_screen.dart';
import 'market_clock_engine.dart';

class MarketPeriodDetailScreen extends StatelessWidget {
  final String windowId;
  const MarketPeriodDetailScreen({super.key, required this.windowId});

  @override
  Widget build(BuildContext context) {
    final window = findWindowById(windowId);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          window?.shortHeadline.toUpperCase() ?? 'PERIOD',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: window == null
          ? const SizedBox()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(window.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          window.fullTitle,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeV2.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    window.timeRangeLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemeV2.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    label: 'What\'s Happening?',
                    body: window.whatHappens,
                  ),
                  _Section(
                    label: 'Why Does It Matter?',
                    body: window.whyItMatters,
                  ),
                  if (window.dangerForBeginner != null)
                    _Section(
                      label: 'What Can Go Wrong?',
                      body: window.dangerForBeginner!,
                    ),
                  _Section(
                    label: 'What Should Beginners Do?',
                    body: window.whatToDo,
                    isLast:
                        window.stressTestPromoTitle == null &&
                        window.fomoShieldTip == null,
                  ),
                  if (window.stressTestPromoTitle != null &&
                      window.stressTestPromoBody != null) ...[
                    _StressTestPromo(
                      title: window.stressTestPromoTitle!,
                      body: window.stressTestPromoBody!,
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (window.fomoShieldTip != null)
                    _TipCallout(body: window.fomoShieldTip!),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final String body;
  final bool isLast;
  const _Section({
    required this.label,
    required this.body,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemeV2.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Callout shown only on non-trading windows (weekend/holiday), nudging the
/// user toward Stress Test with a direct link while the real market is
/// closed.
class _StressTestPromo extends StatelessWidget {
  final String title;
  final String body;
  const _StressTestPromo({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeV2.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (_) => const StressTestHubScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeV2.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Open Stress Test',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlighted callout for the closing "F.O.M.O. Shield Tip" — distinct from
/// the plain label+body sections above it, since it's a branded takeaway
/// rather than another explanatory section.
class _TipCallout extends StatelessWidget {
  final String body;
  const _TipCallout({required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeV2.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeV2.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'F.O.M.O. SHIELD TIP',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: ThemeV2.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: ThemeV2.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
