import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import 'market_clock_engine.dart';
import 'market_clock_new_york_time_widget.dart';
import 'market_clock_phase_widget.dart';
import 'market_clock_timing_widget.dart';
import 'market_clock_widget_order_provider.dart';
import 'market_clock_widgets_settings_sheet.dart';

class MarketClockScreen extends ConsumerStatefulWidget {
  const MarketClockScreen({super.key});

  @override
  ConsumerState<MarketClockScreen> createState() => _MarketClockScreenState();
}

class _MarketClockScreenState extends ConsumerState<MarketClockScreen> {
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

  void _showWidgetsBottomSheet() {
    final notifier = ref.read(marketClockWidgetsProvider.notifier);
    final currentConfigs = ref.read(marketClockWidgetsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeV2.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return MarketClockWidgetsSettingsSheet(
          initialConfigs: currentConfigs,
          notifier: notifier,
        );
      },
    );
  }

  Widget _buildWidget(String id) {
    switch (id) {
      case 'ny_time':
        return NewYorkTimeWidget(state: _state);
      case 'market_phase':
        return MarketPhaseWidget(
          window: _state.window,
          isEarlyClose: _state.isEarlyCloseDay,
        );
      case 'timing_indicator':
        return FomoShieldStatusWidget(window: _state.window);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetConfigs = ref.watch(marketClockWidgetsProvider);
    final visibleWidgets = widgetConfigs.where((w) => w.visible).toList();

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
            for (int i = 0; i < visibleWidgets.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              KeyedSubtree(
                key: ValueKey(visibleWidgets[i].id),
                child: _buildWidget(visibleWidgets[i].id),
              ),
            ],
            const SizedBox(height: 24),
            // Add widgets button
            Center(
              child: TextButton.icon(
                onPressed: _showWidgetsBottomSheet,
                icon: const Icon(
                  Icons.add_rounded,
                  color: ThemeV2.primary,
                  size: 20,
                ),
                label: Text(
                  'Add widgets',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeV2.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(
                      color: ThemeV2.primary,
                      width: 0.5,
                    ),
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
