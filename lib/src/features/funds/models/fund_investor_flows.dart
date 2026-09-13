// ---------------------------------------------------------------------------
// Fund Investor Flows — one calendar year's monthly subscribe (inflow) vs
// redeem (outflow) totals, powering the Investors screen's two bar charts
// (2026-09-13 ask). index 0 = January .. index 11 = December, matching
// fundService.js's getFundInvestorFlows.
// ---------------------------------------------------------------------------

class FundInvestorFlows {
  final int year;
  final List<double> inflow;
  final List<double> outflow;

  const FundInvestorFlows({
    required this.year,
    required this.inflow,
    required this.outflow,
  });

  factory FundInvestorFlows.fromJson(Map<String, dynamic> json) {
    List<double> monthly(String key) => (json[key] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    return FundInvestorFlows(
      year: json['year'] as int,
      inflow: monthly('inflow'),
      outflow: monthly('outflow'),
    );
  }
}
