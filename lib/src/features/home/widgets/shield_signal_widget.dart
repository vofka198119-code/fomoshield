import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../home_providers.dart';

// ---------------------------------------------------------------------------
// Shield Signal Widget — Accordion
// ---------------------------------------------------------------------------

class ShieldSignalWidget extends ConsumerStatefulWidget {
  const ShieldSignalWidget({super.key});

  @override
  ConsumerState<ShieldSignalWidget> createState() => _ShieldSignalWidgetState();
}

class _ShieldSignalWidgetState extends ConsumerState<ShieldSignalWidget>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heightFactor = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shieldAsync = ref.watch(shieldSignalProvider);

    return shieldAsync.when(
      loading: () => _buildCard(
        level: 'neutral',
        label: 'Loading...',
        spyChange: 0,
        spyPrice: 0,
      ),
      error: (_, _) => _buildCard(
        level: 'neutral',
        label: 'Unable to load signal',
        spyChange: 0,
        spyPrice: 0,
      ),
      data: (signal) => _buildCard(
        level: signal.level,
        label: signal.label,
        spyChange: signal.spyChange,
        spyPrice: signal.spyPrice,
      ),
    );
  }

  Widget _buildCard({
    required String level,
    required String label,
    required double spyChange,
    required double spyPrice,
  }) {
    final isGreen = level == 'greed';
    final isRed = level == 'fear';
    final signalColor = isGreen
        ? AppTheme.shieldGreen
        : (isRed ? AppTheme.shieldRed : AppTheme.shieldYellow);
    final signalBg = signalColor.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: signalBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: signalColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: signalColor.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    isGreen
                        ? Icons.arrow_upward_rounded
                        : isRed
                            ? Icons.arrow_downward_rounded
                            : Icons.remove_rounded,
                    color: signalColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Title + label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SHIELD SIGNAL',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentBlue,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: signalColor,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                // Badge + chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: signalColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(level.toUpperCase(),
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: signalColor)),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textDim,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // SPY price row (always visible)
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SPY \$${spyPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                Text(
                    '${spyChange >= 0 ? '+' : ''}${spyChange.toStringAsFixed(2)}% today',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: spyChange >= 0
                            ? AppTheme.shieldGreen
                            : AppTheme.dangerRed)),
              ],
            ),
            // Expandable details
            SizeTransition(
              sizeFactor: _heightFactor,
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Sentiment Analysis',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The F.O.M.O. Shield signal is based on real-time market '
                        'data and sentiment analysis of the S&P 500 index. '
                        '${isGreen ? 'The market is showing strong bullish momentum.' : isRed ? 'The market is showing bearish sentiment.' : 'The market is currently in a neutral state without clear direction.'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textDim,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
