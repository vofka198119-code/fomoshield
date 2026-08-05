// ---------------------------------------------------------------------------
// Stress Test — Psychology Meter detail screen. Reached via the chevron
// next to the Psychology Meter widget's title on the main Stress Test
// screen (see PsychologyMeter in shared/widgets/psychology_meter.dart).
// Hosts the trade/portfolio analytics section that used to render directly
// below the ring on the main widget.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
import '../../core/theme/fomo_shield_theme.dart';
import '../../shared/widgets/psychology_meter.dart';
import 'stress_test_engine.dart';

class StressTestPsychologyMeterScreen extends ConsumerWidget {
  final String sessionId;

  const StressTestPsychologyMeterScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stressTestRefreshProvider);
    final session = ref.watch(stressTestSessionProvider(sessionId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ThemeV2.textPrimary,
            size: 22,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'PSYCHOLOGY METER',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: session == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _PsychologyMeterDetailCard(
                data: PsychologyMeterData.fromSession(session),
              ),
            ),
    );
  }
}

class _PsychologyMeterDetailCard extends StatelessWidget {
  final PsychologyMeterData data;

  const _PsychologyMeterDetailCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: FomoShieldTheme.cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            child: Row(
              children: [
                Text('PSYCHOLOGY METER', style: FomoShieldTheme.cardTitle()),
                const Spacer(),
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: FomoShieldTheme.textLight.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            child: PsychologyAnalyticsSection(data: data),
          ),
        ],
      ),
    );
  }
}
