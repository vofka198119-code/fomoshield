// ---------------------------------------------------------------------------
// Fund Commission History — one calendar year's monthly broker commission
// paid by the fund (index 0 = January .. 11 = December), powering the
// Charts screen's Broker Commission chart (2026-09-13 ask). Unlike
// FundBalanceHistory, a month with no executed trades is a real $0, not
// "no data yet" -- matches fundService.js's getFundCommissionHistory.
// ---------------------------------------------------------------------------

class FundCommissionHistory {
  final int year;
  final List<double> commission;

  const FundCommissionHistory({required this.year, required this.commission});

  factory FundCommissionHistory.fromJson(Map<String, dynamic> json) {
    return FundCommissionHistory(
      year: json['year'] as int,
      commission: (json['commission'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}
