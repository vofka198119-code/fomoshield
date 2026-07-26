import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme_v2.dart';
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
          window?.shortHeadline.toUpperCase() ?? 'ПЕРИОД',
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
                  _Section(label: 'Что происходит', body: window.whatHappens),
                  _Section(label: 'Почему это важно', body: window.whyItMatters),
                  if (window.dangerForBeginner != null)
                    _Section(label: 'Опасность для новичка', body: window.dangerForBeginner!),
                  _Section(label: 'Что делать', body: window.whatToDo, isLast: true),
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
  const _Section({required this.label, required this.body, this.isLast = false});

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
              color: ThemeV2.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.inter(fontSize: 14, color: ThemeV2.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
