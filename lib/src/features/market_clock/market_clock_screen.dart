import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_dial.dart';
import 'market_clock_engine.dart';

class MarketClockScreen extends StatefulWidget {
  const MarketClockScreen({super.key});

  @override
  State<MarketClockScreen> createState() => _MarketClockScreenState();
}

class _MarketClockScreenState extends State<MarketClockScreen> {
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'MARKET CLOCK',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: marketClockCardDecoration(),
              child: MarketClockDial(state: _state),
            ),
            const SizedBox(height: 24),
            _TimingBox(window: window, isEarlyClose: _state.isEarlyCloseDay),
          ],
        ),
      ),
    );
  }
}

class _TimingBox extends StatelessWidget {
  final MarketWindow window;
  final bool isEarlyClose;
  const _TimingBox({required this.window, required this.isEarlyClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeV2.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeV2.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(window.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        window.shortHeadline,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ThemeV2.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  window.shortDetail,
                  style: GoogleFonts.inter(fontSize: 13, color: ThemeV2.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  window.timeRangeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ThemeV2.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/market-clock/period/${window.id}'),
            icon: const Icon(Icons.help_outline_rounded, color: ThemeV2.primary),
            tooltip: 'Подробнее',
          ),
        ],
      ),
    );
  }
}
