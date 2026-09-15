import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/theme_variant_provider.dart';
import '../../../core/theme/themed_header.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/card_frame.dart';
import '../../company_detail/widgets/metric_info_data.dart' show MetricInfoContent, MetricInfoSection;

// ---------------------------------------------------------------------------
// Fund Rulebook — Phase C of the bankruptcy spec
// (fomoshield_etf_bankruptcy_flow_spec memory): a reader-friendly "how funds
// work" reference, reachable any time via the circle-shortcut row's LAST
// entry on both Fund Management and Employee Hub (2026-09-15 ask).
//
// Menu shape, not one long scroll (2026-09-15 revision of the first pass,
// which pushed straight into MetricInfoScreen with every section stacked):
// a list of title rows, each opening a themed bottom sheet card with that
// one topic's full text -- same drag-handle/rounded-top chrome as
// fund_bankruptcy_flow.dart's own explanation sheet.
//
// One neutral document for both branches (head and analyst), unlike
// onboarding's per-branch narrative copy -- a reference someone consults
// from either side of a fund, or before joining one at all.
//
// Only describes the FORCED bankruptcy path (Phase A, live) -- Phase B's
// automatic inactivity/succession trigger isn't built yet, so it isn't
// documented as if it already exists.
// ---------------------------------------------------------------------------

MetricInfoContent fundRulebookContent(AppLocalizations l10n) {
  return MetricInfoContent(
    title: l10n.etfRulebookTitle,
    subtitle: l10n.etfRulebookSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.etfRulebookFundSectionHeader,
        body: l10n.etfRulebookFundSectionBody,
      ),
      MetricInfoSection(
        header: l10n.etfRulebookRolesSectionHeader,
        body: l10n.etfRulebookRolesSectionBody,
      ),
      MetricInfoSection(
        header: l10n.etfRulebookTradeFlowSectionHeader,
        body: l10n.etfRulebookTradeFlowSectionBody,
      ),
      MetricInfoSection(
        header: l10n.etfRulebookNavSectionHeader,
        body: l10n.etfRulebookNavSectionBody,
      ),
      MetricInfoSection(
        header: l10n.etfRulebookBankruptcySectionHeader,
        body: l10n.etfRulebookBankruptcySectionBody,
      ),
      // Same simulator disclaimer copy as onboarding's own closing step --
      // one already-approved piece of text, not a re-drafted duplicate.
      MetricInfoSection(
        header: l10n.etfOnboardingStep7Title,
        body: l10n.etfOnboardingStep7Body,
      ),
    ],
  );
}

class FundRulebookScreen extends ConsumerWidget {
  const FundRulebookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final palette = resolveAppPalette(ref.watch(themeVariantProvider));
    final content = fundRulebookContent(l10n);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: themedBackButton(context, palette),
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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              content.subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: palette.accentPrimary,
              ),
            ),
            const SizedBox(height: 16),
            for (final section in content.sections)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RulebookRow(
                  section: section,
                  palette: palette,
                  onTap: () => _showRulebookSectionSheet(context, palette, section),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RulebookRow extends StatelessWidget {
  final MetricInfoSection section;
  final AppPalette palette;
  final VoidCallback onTap;

  const _RulebookRow({
    required this.section,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = palette.titleGradient != null
        ? Colors.white
        : palette.textHeader;
    return CardFrame(
      padding: EdgeInsets.zero,
      palette: palette,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  section.header ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: palette.textBody,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showRulebookSectionSheet(
  BuildContext context,
  AppPalette palette,
  MetricInfoSection section,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: palette.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _RulebookSectionSheet(section: section, palette: palette),
  );
}

class _RulebookSectionSheet extends StatelessWidget {
  final MetricInfoSection section;
  final AppPalette palette;

  const _RulebookSectionSheet({required this.section, required this.palette});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (section.header != null) ...[
                Text(
                  section.header!,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: palette.textHeader,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    section.body,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: palette.textHeader,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
