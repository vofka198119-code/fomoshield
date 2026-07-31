import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import 'metric_info_data.dart';

// ---------------------------------------------------------------------------
// Metric Info Screen — title + a list of header/body sections, reached by
// tapping the "?" next to a KEY METRICS row. Same simple full-screen shape
// as Market Clock's period detail screen (label+body sections stacked).
// ---------------------------------------------------------------------------

class MetricInfoScreen extends StatelessWidget {
  final MetricInfoContent content;

  const MetricInfoScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          content.title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: ThemeV2.primary,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeV2.primary,
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < content.sections.length; i++)
              _Section(
                section: content.sections[i],
                isLast: i == content.sections.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final MetricInfoSection section;
  final bool isLast;
  const _Section({required this.section, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.header != null) ...[
            Text(
              section.header!,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: ThemeV2.primary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            section.body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.black,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
