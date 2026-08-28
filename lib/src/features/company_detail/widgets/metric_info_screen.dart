import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme_v2.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../stress_test/widgets/verdict/stress_test_verdict_disclaimer.dart';
import 'metric_info_data.dart';

// ---------------------------------------------------------------------------
// Metric Info Screen — title + a list of header/body sections, reached by
// tapping the "?" next to a KEY METRICS row. Same simple full-screen shape
// as Market Clock's period detail screen (label+body sections stacked).
// ---------------------------------------------------------------------------

class MetricInfoScreen extends ConsumerWidget {
  final MetricInfoContent content;

  const MetricInfoScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette, size: 22),
        title: themedHeaderText(
          content.title.toUpperCase(),
          palette,
          GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.accentPrimary,
                ),
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < content.sections.length; i++)
                _Section(
                  section: content.sections[i],
                  isLast:
                      i == content.sections.length - 1 &&
                      !content.showAcademicDisclaimer &&
                      !content.showStressTestDisclaimer,
                  palette: palette,
                ),
              if (content.showAcademicDisclaimer) ...[
                const SizedBox(height: 18),
                // Was left-aligned (inherited from this screen's own
                // Column) and palette-based — unified 2026-08-25 to the
                // same centered, fixed-muted-gray "Company Card style"
                // every other disclaimer uses (see DisclaimerFooter).
                Column(
                  children: [
                    Text(
                      l10n.companyDetailAcademicDisclaimerTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ThemeV2.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.companyDetailAcademicDisclaimerBody,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: ThemeV2.textSecondary.withValues(alpha: 0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
              if (content.showStressTestDisclaimer)
                const StressTestVerdictDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final MetricInfoSection section;
  final bool isLast;
  final AppPalette palette;
  const _Section({
    required this.section,
    required this.palette,
    this.isLast = false,
  });

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
                color: palette.accentPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            section.body,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: palette.textHeader,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
