// ---------------------------------------------------------------------------
// Fund Balance History — one calendar year's monthly AUM + NAV-per-unit
// (index 0 = January .. 11 = December), powering the Charts screen's
// Balance History and NAV-per-unit line charts (2026-09-13 ask). A null
// entry means no daily snapshot exists for that month yet (a future
// month, or before the fund existed) — matches fundService.js's
// getFundBalanceHistory. Both series come from the same snapshot rows,
// hence one model/endpoint for both charts.
// ---------------------------------------------------------------------------

class FundBalanceHistory {
  final int year;
  final List<double?> balance;
  final List<double?> navPerUnit;

  const FundBalanceHistory({
    required this.year,
    required this.balance,
    required this.navPerUnit,
  });

  factory FundBalanceHistory.fromJson(Map<String, dynamic> json) {
    List<double?> monthly(String key) => (json[key] as List<dynamic>)
        .map((e) => (e as num?)?.toDouble())
        .toList();
    return FundBalanceHistory(
      year: json['year'] as int,
      balance: monthly('balance'),
      navPerUnit: monthly('navPerUnit'),
    );
  }
}
