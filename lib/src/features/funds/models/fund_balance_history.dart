// ---------------------------------------------------------------------------
// Fund Balance History — one calendar year's monthly AUM (index 0 =
// January .. 11 = December), powering Fund Management's balance line
// chart (2026-09-13 ask). A null entry means no daily snapshot exists for
// that month yet (a future month, or before the fund existed) — matches
// fundService.js's getFundBalanceHistory.
// ---------------------------------------------------------------------------

class FundBalanceHistory {
  final int year;
  final List<double?> balance;

  const FundBalanceHistory({required this.year, required this.balance});

  factory FundBalanceHistory.fromJson(Map<String, dynamic> json) {
    return FundBalanceHistory(
      year: json['year'] as int,
      balance: (json['balance'] as List<dynamic>)
          .map((e) => (e as num?)?.toDouble())
          .toList(),
    );
  }
}
