// ===========================================================================
// Metric Info Content — explanation text shown on MetricInfoScreen via the
// "?" next to a KEY METRICS row. One entry per metric id; a metric with no
// entry here just doesn't get a "?". Filled in incrementally as copy is
// provided by the user.
// ===========================================================================

import '../../../l10n/gen/app_localizations.dart';

class MetricInfoSection {
  final String? header;
  final String body;
  const MetricInfoSection({this.header, required this.body});
}

class MetricInfoContent {
  final String title;
  final String subtitle;
  final List<MetricInfoSection> sections;
  // Small "Educational & Academic Disclaimer" footer — only the 6 Financial
  // Score marker screens (Valuation, Financial Health, Growth Potential,
  // Efficiency, Historical Trend, Shareholder Returns) show it, not the
  // KEY METRICS screens (P/E, ROE, etc.) or the fs-score-legal screen.
  final bool showAcademicDisclaimer;
  // Full StressTestVerdictDisclaimer footer — every Psychology Meter
  // marker screen (psychology-discipline/panic/patience/strategy/
  // diversification, investor-score) shows this instead, matching the
  // same mandatory disclaimer used on Session Complete / the per-marker
  // "More" screen / the Psychology Meter detail screen — see
  // stress_test_verdict_disclaimer.dart. Mutually exclusive with
  // showAcademicDisclaimer in practice (company-detail markers vs.
  // stress-test markers), but not enforced — don't set both.
  final bool showStressTestDisclaimer;
  const MetricInfoContent({
    required this.title,
    required this.subtitle,
    required this.sections,
    this.showAcademicDisclaimer = false,
    this.showStressTestDisclaimer = false,
  });
}

// Maps a KEY METRICS row's label (e.g. 'P/E') to the registry id below —
// separate from the id itself so several labels could share one entry if
// that's ever needed.
const Map<String, String> metricInfoIdByLabel = {
  'P/E': 'pe',
  'Dividend Yield': 'dividend-yield',
  'Net Margin': 'net-margin',
  'Operating Margin': 'operating-margin',
  'Gross Margin': 'gross-margin',
  'ROE': 'roe',
  // Financial Score's 6 markers (financial_score_widget.dart). The "?"
  // icon shows for all of them regardless of registry content below —
  // one without an entry just opens a blank screen until its text is added.
  'Valuation': 'valuation',
  'Financial Health': 'financial-health',
  'Growth Potential': 'growth-potential',
  'Efficiency': 'efficiency',
  'Historical Trend': 'historical-trend',
  'Shareholder Returns': 'capital-return',
};

Map<String, MetricInfoContent> metricInfoRegistryFor(AppLocalizations l10n) => {
  'pe': MetricInfoContent(
    title: l10n.metricInfoPeTitle,
    subtitle: l10n.metricInfoPeSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPeSection1Header,
        body: l10n.metricInfoPeSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection2Header,
        body: l10n.metricInfoPeSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection3Header,
        body: l10n.metricInfoPeSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection4Header,
        body: l10n.metricInfoPeSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection5Header,
        body: l10n.metricInfoPeSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection6Header,
        body: l10n.metricInfoPeSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection7Header,
        body: l10n.metricInfoPeSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection8Header,
        body: l10n.metricInfoPeSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection9Header,
        body: l10n.metricInfoPeSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection10Header,
        body: l10n.metricInfoPeSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection11Header,
        body: l10n.metricInfoPeSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection12Header,
        body: l10n.metricInfoPeSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPeSection13Header,
        body: l10n.metricInfoPeSection13Body,
      ),
    ],
  ),
  'dividend-yield': MetricInfoContent(
    title: l10n.metricInfoDividendYieldTitle,
    subtitle: l10n.metricInfoDividendYieldSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection1Header,
        body: l10n.metricInfoDividendYieldSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection2Header,
        body: l10n.metricInfoDividendYieldSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection3Header,
        body: l10n.metricInfoDividendYieldSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection4Header,
        body: l10n.metricInfoDividendYieldSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection5Header,
        body: l10n.metricInfoDividendYieldSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection6Header,
        body: l10n.metricInfoDividendYieldSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection7Header,
        body: l10n.metricInfoDividendYieldSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection8Header,
        body: l10n.metricInfoDividendYieldSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection9Header,
        body: l10n.metricInfoDividendYieldSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection10Header,
        body: l10n.metricInfoDividendYieldSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection11Header,
        body: l10n.metricInfoDividendYieldSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection12Header,
        body: l10n.metricInfoDividendYieldSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection13Header,
        body: l10n.metricInfoDividendYieldSection13Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoDividendYieldSection14Header,
        body: l10n.metricInfoDividendYieldSection14Body,
      ),
    ],
  ),
  'net-margin': MetricInfoContent(
    title: l10n.metricInfoNetMarginTitle,
    subtitle: l10n.metricInfoNetMarginSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection1Header,
        body: l10n.metricInfoNetMarginSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection2Header,
        body: l10n.metricInfoNetMarginSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection3Header,
        body: l10n.metricInfoNetMarginSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection4Header,
        body: l10n.metricInfoNetMarginSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection5Header,
        body: l10n.metricInfoNetMarginSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection6Header,
        body: l10n.metricInfoNetMarginSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection7Header,
        body: l10n.metricInfoNetMarginSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection8Header,
        body: l10n.metricInfoNetMarginSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection9Header,
        body: l10n.metricInfoNetMarginSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection10Header,
        body: l10n.metricInfoNetMarginSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection11Header,
        body: l10n.metricInfoNetMarginSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection12Header,
        body: l10n.metricInfoNetMarginSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection13Header,
        body: l10n.metricInfoNetMarginSection13Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoNetMarginSection14Header,
        body: l10n.metricInfoNetMarginSection14Body,
      ),
    ],
  ),
  'operating-margin': MetricInfoContent(
    title: l10n.metricInfoOperatingMarginTitle,
    subtitle: l10n.metricInfoOperatingMarginSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection1Header,
        body: l10n.metricInfoOperatingMarginSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection2Header,
        body: l10n.metricInfoOperatingMarginSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection3Header,
        body: l10n.metricInfoOperatingMarginSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection4Header,
        body: l10n.metricInfoOperatingMarginSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection5Header,
        body: l10n.metricInfoOperatingMarginSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection6Header,
        body: l10n.metricInfoOperatingMarginSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection7Header,
        body: l10n.metricInfoOperatingMarginSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection8Header,
        body: l10n.metricInfoOperatingMarginSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection9Header,
        body: l10n.metricInfoOperatingMarginSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection10Header,
        body: l10n.metricInfoOperatingMarginSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection11Header,
        body: l10n.metricInfoOperatingMarginSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection12Header,
        body: l10n.metricInfoOperatingMarginSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection13Header,
        body: l10n.metricInfoOperatingMarginSection13Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoOperatingMarginSection14Header,
        body: l10n.metricInfoOperatingMarginSection14Body,
      ),
    ],
  ),
  'gross-margin': MetricInfoContent(
    title: l10n.metricInfoGrossMarginTitle,
    subtitle: l10n.metricInfoGrossMarginSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection1Header,
        body: l10n.metricInfoGrossMarginSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection2Header,
        body: l10n.metricInfoGrossMarginSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection3Header,
        body: l10n.metricInfoGrossMarginSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection4Header,
        body: l10n.metricInfoGrossMarginSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection5Header,
        body: l10n.metricInfoGrossMarginSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection6Header,
        body: l10n.metricInfoGrossMarginSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection7Header,
        body: l10n.metricInfoGrossMarginSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection8Header,
        body: l10n.metricInfoGrossMarginSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection9Header,
        body: l10n.metricInfoGrossMarginSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection10Header,
        body: l10n.metricInfoGrossMarginSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection11Header,
        body: l10n.metricInfoGrossMarginSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection12Header,
        body: l10n.metricInfoGrossMarginSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection13Header,
        body: l10n.metricInfoGrossMarginSection13Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection14Header,
        body: l10n.metricInfoGrossMarginSection14Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrossMarginSection15Header,
        body: l10n.metricInfoGrossMarginSection15Body,
      ),
    ],
  ),
  'roe': MetricInfoContent(
    title: l10n.metricInfoRoeTitle,
    subtitle: l10n.metricInfoRoeSubtitle,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoRoeSection1Header,
        body: l10n.metricInfoRoeSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection2Header,
        body: l10n.metricInfoRoeSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection3Header,
        body: l10n.metricInfoRoeSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection4Header,
        body: l10n.metricInfoRoeSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection5Header,
        body: l10n.metricInfoRoeSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection6Header,
        body: l10n.metricInfoRoeSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection7Header,
        body: l10n.metricInfoRoeSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection8Header,
        body: l10n.metricInfoRoeSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection9Header,
        body: l10n.metricInfoRoeSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection10Header,
        body: l10n.metricInfoRoeSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection11Header,
        body: l10n.metricInfoRoeSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection12Header,
        body: l10n.metricInfoRoeSection12Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection13Header,
        body: l10n.metricInfoRoeSection13Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoRoeSection14Header,
        body: l10n.metricInfoRoeSection14Body,
      ),
    ],
  ),
  'valuation': MetricInfoContent(
    title: l10n.metricInfoValuationTitle,
    subtitle: l10n.metricInfoValuationSubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoValuationSection1Header,
        body: l10n.metricInfoValuationSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection2Header,
        body: l10n.metricInfoValuationSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection3Header,
        body: l10n.metricInfoValuationSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection4Header,
        body: l10n.metricInfoValuationSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection5Header,
        body: l10n.metricInfoValuationSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection6Header,
        body: l10n.metricInfoValuationSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection7Header,
        body: l10n.metricInfoValuationSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoValuationSection8Header,
        body: l10n.metricInfoValuationSection8Body,
      ),
    ],
  ),
  'financial-health': MetricInfoContent(
    title: l10n.metricInfoFinancialHealthTitle,
    subtitle: l10n.metricInfoFinancialHealthSubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection1Header,
        body: l10n.metricInfoFinancialHealthSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection2Header,
        body: l10n.metricInfoFinancialHealthSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection3Header,
        body: l10n.metricInfoFinancialHealthSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection4Header,
        body: l10n.metricInfoFinancialHealthSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection5Header,
        body: l10n.metricInfoFinancialHealthSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection6Header,
        body: l10n.metricInfoFinancialHealthSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection7Header,
        body: l10n.metricInfoFinancialHealthSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoFinancialHealthSection8Header,
        body: l10n.metricInfoFinancialHealthSection8Body,
      ),
    ],
  ),
  'growth-potential': MetricInfoContent(
    title: l10n.metricInfoGrowthPotentialTitle,
    subtitle: l10n.metricInfoGrowthPotentialSubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection1Header,
        body: l10n.metricInfoGrowthPotentialSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection2Header,
        body: l10n.metricInfoGrowthPotentialSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection3Header,
        body: l10n.metricInfoGrowthPotentialSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection4Header,
        body: l10n.metricInfoGrowthPotentialSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection5Header,
        body: l10n.metricInfoGrowthPotentialSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection6Header,
        body: l10n.metricInfoGrowthPotentialSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection7Header,
        body: l10n.metricInfoGrowthPotentialSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGrowthPotentialSection8Header,
        body: l10n.metricInfoGrowthPotentialSection8Body,
      ),
    ],
  ),
  // Marker label is "Efficiency" (financial_score_widget.dart), computed in
  // scoring_engine.dart from net margin + ROE — i.e. profitability, not
  // day-to-day operational/resource management. Content below matches what
  // the marker actually measures rather than its short label.
  'efficiency': MetricInfoContent(
    title: l10n.metricInfoEfficiencyTitle,
    subtitle: l10n.metricInfoEfficiencySubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection1Header,
        body: l10n.metricInfoEfficiencySection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection2Header,
        body: l10n.metricInfoEfficiencySection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection3Header,
        body: l10n.metricInfoEfficiencySection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection4Header,
        body: l10n.metricInfoEfficiencySection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection5Header,
        body: l10n.metricInfoEfficiencySection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection6Header,
        body: l10n.metricInfoEfficiencySection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection7Header,
        body: l10n.metricInfoEfficiencySection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoEfficiencySection8Header,
        body: l10n.metricInfoEfficiencySection8Body,
      ),
    ],
  ),
  // Marker label is "Historical Trend" (financial_score_widget.dart),
  // computed in scoring_engine.dart from real 5Y share-price CAGR — a
  // market-driven signal (not a fundamental), so "Market Confidence"
  // content maps here rather than to Capital Return (dividends/buybacks).
  'historical-trend': MetricInfoContent(
    title: l10n.metricInfoHistoricalTrendTitle,
    subtitle: l10n.metricInfoHistoricalTrendSubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection1Header,
        body: l10n.metricInfoHistoricalTrendSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection2Header,
        body: l10n.metricInfoHistoricalTrendSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection3Header,
        body: l10n.metricInfoHistoricalTrendSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection4Header,
        body: l10n.metricInfoHistoricalTrendSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection5Header,
        body: l10n.metricInfoHistoricalTrendSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection6Header,
        body: l10n.metricInfoHistoricalTrendSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection7Header,
        body: l10n.metricInfoHistoricalTrendSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoHistoricalTrendSection8Header,
        body: l10n.metricInfoHistoricalTrendSection8Body,
      ),
    ],
  ),
  'capital-return': MetricInfoContent(
    title: l10n.metricInfoCapitalReturnTitle,
    subtitle: l10n.metricInfoCapitalReturnSubtitle,
    showAcademicDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection1Header,
        body: l10n.metricInfoCapitalReturnSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection2Header,
        body: l10n.metricInfoCapitalReturnSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection3Header,
        body: l10n.metricInfoCapitalReturnSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection4Header,
        body: l10n.metricInfoCapitalReturnSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection5Header,
        body: l10n.metricInfoCapitalReturnSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection6Header,
        body: l10n.metricInfoCapitalReturnSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection7Header,
        body: l10n.metricInfoCapitalReturnSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoCapitalReturnSection8Header,
        body: l10n.metricInfoCapitalReturnSection8Body,
      ),
    ],
  ),
  // Reached by tapping the gold "Legal Disclaimer & Methodology" link at
  // the bottom of FinancialScoreWidget — full legal-grade text, the
  // compact on-card line is a summary of this.
  'fs-score-legal': MetricInfoContent(
    title: l10n.metricInfoFsScoreLegalTitle,
    subtitle: l10n.metricInfoFsScoreLegalSubtitle,
    sections: [
      MetricInfoSection(
        body: l10n.metricInfoFsScoreLegalSection1Body,
      ),
    ],
  ),
  // Reached by tapping the "?" in the Portfolio Balance detail screen's
  // 4 widget headers (stress_test_portfolio_balance_screen.dart and its
  // widgets/ files) — not part of company_detail's KEY METRICS/FS Score
  // rows, just reusing the same MetricInfoScreen shape.
  'portfolio-health': MetricInfoContent(
    title: l10n.metricInfoPortfolioHealthTitle,
    subtitle: l10n.metricInfoPortfolioHealthSubtitle,
    sections: [
      MetricInfoSection(
        body: l10n.metricInfoPortfolioHealthSection1Body,
      ),
    ],
  ),
  'asset-allocation-pct': MetricInfoContent(
    title: l10n.metricInfoAssetAllocationPctTitle,
    subtitle: l10n.metricInfoAssetAllocationPctSubtitle,
    sections: [
      MetricInfoSection(
        body: l10n.metricInfoAssetAllocationPctSection1Body,
      ),
    ],
  ),
  'diversification-indicator': MetricInfoContent(
    title: l10n.metricInfoDiversificationIndicatorTitle,
    subtitle: l10n.metricInfoDiversificationIndicatorSubtitle,
    sections: [
      MetricInfoSection(
        body: l10n.metricInfoDiversificationIndicatorSection1Body,
      ),
    ],
  ),
  'diversification-progress': MetricInfoContent(
    title: l10n.metricInfoDiversificationProgressTitle,
    subtitle: l10n.metricInfoDiversificationProgressSubtitle,
    sections: [
      MetricInfoSection(
        body: l10n.metricInfoDiversificationProgressSection1Body,
      ),
    ],
  ),

  // ── Psychology Meter marker widgets (stress_test/widgets/psychology/) ──
  // Stub copy — placeholder text pending final wording from the user.
  'psychology-discipline': MetricInfoContent(
    title: l10n.metricInfoPsychologyDisciplineTitle,
    subtitle: l10n.metricInfoPsychologyDisciplineSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection1Header,
        body: l10n.metricInfoPsychologyDisciplineSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection2Header,
        body: l10n.metricInfoPsychologyDisciplineSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection3Header,
        body: l10n.metricInfoPsychologyDisciplineSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection4Header,
        body: l10n.metricInfoPsychologyDisciplineSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection5Header,
        body: l10n.metricInfoPsychologyDisciplineSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection6Header,
        body: l10n.metricInfoPsychologyDisciplineSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection7Header,
        body: l10n.metricInfoPsychologyDisciplineSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection8Header,
        body: l10n.metricInfoPsychologyDisciplineSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection9Header,
        body: l10n.metricInfoPsychologyDisciplineSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDisciplineSection10Header,
        body: l10n.metricInfoPsychologyDisciplineSection10Body,
      ),
    ],
  ),
  'psychology-panic': MetricInfoContent(
    title: l10n.metricInfoPsychologyPanicTitle,
    subtitle: l10n.metricInfoPsychologyPanicSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection1Header,
        body: l10n.metricInfoPsychologyPanicSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection2Header,
        body: l10n.metricInfoPsychologyPanicSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection3Header,
        body: l10n.metricInfoPsychologyPanicSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection4Header,
        body: l10n.metricInfoPsychologyPanicSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection5Header,
        body: l10n.metricInfoPsychologyPanicSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection6Header,
        body: l10n.metricInfoPsychologyPanicSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection7Header,
        body: l10n.metricInfoPsychologyPanicSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection8Header,
        body: l10n.metricInfoPsychologyPanicSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection9Header,
        body: l10n.metricInfoPsychologyPanicSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPanicSection10Header,
        body: l10n.metricInfoPsychologyPanicSection10Body,
      ),
    ],
  ),
  'psychology-patience': MetricInfoContent(
    title: l10n.metricInfoPsychologyPatienceTitle,
    subtitle: l10n.metricInfoPsychologyPatienceSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection1Header,
        body: l10n.metricInfoPsychologyPatienceSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection2Header,
        body: l10n.metricInfoPsychologyPatienceSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection3Header,
        body: l10n.metricInfoPsychologyPatienceSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection4Header,
        body: l10n.metricInfoPsychologyPatienceSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection5Header,
        body: l10n.metricInfoPsychologyPatienceSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection6Header,
        body: l10n.metricInfoPsychologyPatienceSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection7Header,
        body: l10n.metricInfoPsychologyPatienceSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection8Header,
        body: l10n.metricInfoPsychologyPatienceSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection9Header,
        body: l10n.metricInfoPsychologyPatienceSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyPatienceSection10Header,
        body: l10n.metricInfoPsychologyPatienceSection10Body,
      ),
    ],
  ),
  'psychology-strategy': MetricInfoContent(
    title: l10n.metricInfoPsychologyStrategyTitle,
    subtitle: l10n.metricInfoPsychologyStrategySubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection1Header,
        body: l10n.metricInfoPsychologyStrategySection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection2Header,
        body: l10n.metricInfoPsychologyStrategySection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection3Header,
        body: l10n.metricInfoPsychologyStrategySection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection4Header,
        body: l10n.metricInfoPsychologyStrategySection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection5Header,
        body: l10n.metricInfoPsychologyStrategySection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection6Header,
        body: l10n.metricInfoPsychologyStrategySection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection7Header,
        body: l10n.metricInfoPsychologyStrategySection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection8Header,
        body: l10n.metricInfoPsychologyStrategySection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyStrategySection9Header,
        body: l10n.metricInfoPsychologyStrategySection9Body,
      ),
    ],
  ),
  'investor-score': MetricInfoContent(
    title: l10n.metricInfoInvestorScoreTitle,
    subtitle: l10n.metricInfoInvestorScoreSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection1Header,
        body: l10n.metricInfoInvestorScoreSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection2Header,
        body: l10n.metricInfoInvestorScoreSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection3Header,
        body: l10n.metricInfoInvestorScoreSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection4Header,
        body: l10n.metricInfoInvestorScoreSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection5Header,
        body: l10n.metricInfoInvestorScoreSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection6Header,
        body: l10n.metricInfoInvestorScoreSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection7Header,
        body: l10n.metricInfoInvestorScoreSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection8Header,
        body: l10n.metricInfoInvestorScoreSection8Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection9Header,
        body: l10n.metricInfoInvestorScoreSection9Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection10Header,
        body: l10n.metricInfoInvestorScoreSection10Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection11Header,
        body: l10n.metricInfoInvestorScoreSection11Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoInvestorScoreSection12Header,
        body: l10n.metricInfoInvestorScoreSection12Body,
      ),
    ],
  ),
  'psychology-diversification': MetricInfoContent(
    title: l10n.metricInfoPsychologyDiversificationTitle,
    subtitle: l10n.metricInfoPsychologyDiversificationSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection1Header,
        body: l10n.metricInfoPsychologyDiversificationSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection2Header,
        body: l10n.metricInfoPsychologyDiversificationSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection3Header,
        body: l10n.metricInfoPsychologyDiversificationSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection4Header,
        body: l10n.metricInfoPsychologyDiversificationSection4Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection5Header,
        body: l10n.metricInfoPsychologyDiversificationSection5Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection6Header,
        body: l10n.metricInfoPsychologyDiversificationSection6Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection7Header,
        body: l10n.metricInfoPsychologyDiversificationSection7Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoPsychologyDiversificationSection8Header,
        body: l10n.metricInfoPsychologyDiversificationSection8Body,
      ),
    ],
  ),

  // ── Session Complete — Guardian's Verdict full text ──────────────────
  // Reached via "View your analysis" on the Session Complete screen's
  // first card (verdict_screen.dart's _GuardianVerdictSection). Same
  // short-text + expand-to-full-screen pattern as every other "?" info
  // screen.
  'guardian-verdict': MetricInfoContent(
    title: l10n.metricInfoGuardianVerdictTitle,
    subtitle: l10n.metricInfoGuardianVerdictSubtitle,
    showStressTestDisclaimer: true,
    sections: [
      MetricInfoSection(
        header: l10n.metricInfoGuardianVerdictSection1Header,
        body: l10n.metricInfoGuardianVerdictSection1Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGuardianVerdictSection2Header,
        body: l10n.metricInfoGuardianVerdictSection2Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGuardianVerdictSection3Header,
        body: l10n.metricInfoGuardianVerdictSection3Body,
      ),
      MetricInfoSection(
        header: l10n.metricInfoGuardianVerdictSection4Header,
        body: l10n.metricInfoGuardianVerdictSection4Body,
      ),
    ],
  ),
};

