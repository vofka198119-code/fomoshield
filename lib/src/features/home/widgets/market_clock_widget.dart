import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/market_clock/market_clock_dial.dart';
import '../../../features/market_clock/market_clock_engine.dart';

// ---------------------------------------------------------------------------
// Market Clock Widget — Home mini card. Same instrument-panel dial as the
// full Market Clock screen (market_clock_screen.dart), scaled down, with a
// compact status readout next to it. Tapping anywhere opens the full screen.
// ---------------------------------------------------------------------------

class MarketClockWidget extends StatefulWidget {
  const MarketClockWidget({super.key});

  @override
  State<MarketClockWidget> createState() => _MarketClockWidgetState();
}

class _MarketClockWidgetState extends State<MarketClockWidget> {
  late Timer _timer;
  late MarketClockState _state;

  @override
  void initState() {
    super.initState();
    _state = resolveMarketClockState(nowInNewYork());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _state = resolveMarketClockState(nowInNewYork()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final window = _state.window;

    return InkWell(
      onTap: () => context.push('/market-clock'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        decoration: marketClockCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
              child: Row(
                children: [
                  Text(
                    'MARKET CLOCK',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.7), size: 20),
                ],
              ),
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MarketClockDial(state: _state, size: 88, ringStroke: 8),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(window.emoji, style: const TextStyle(fontSize: 15)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                window.shortHeadline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: dialIvory,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          window.shortDetail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: dialIvory.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          window.timeRangeLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: dialBrassLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
