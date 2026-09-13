// ---------------------------------------------------------------------------
// Fund Investor — one row of the Investors screen (ETF Fund Emulation,
// 2026-09-13 ask). `invested` is net subscribe-minus-redeem dollars, same
// ledger fundService.js's _getInvestorCapital sums for the fund-wide
// total — see getFundInvestors's own comment for why this isn't the same
// as a unit-based NAV share. Server already sorts by invested descending
// and drops anyone who's fully redeemed out (invested <= 0).
// ---------------------------------------------------------------------------

class FundInvestor {
  final String userId;
  final String? nickname;
  final double invested;
  final double unitsHeld;
  // Against fund.unitsOutstanding (the same denominator as "Паёв в
  // обращении" on Key Metrics) -- see fundService.js's getFundInvestors.
  final double percentOfFund;

  const FundInvestor({
    required this.userId,
    this.nickname,
    required this.invested,
    required this.unitsHeld,
    required this.percentOfFund,
  });

  factory FundInvestor.fromJson(Map<String, dynamic> json) => FundInvestor(
    userId: json['userId'] as String,
    nickname: json['nickname'] as String?,
    invested: (json['invested'] as num).toDouble(),
    unitsHeld: (json['unitsHeld'] as num?)?.toDouble() ?? 0,
    percentOfFund: (json['percentOfFund'] as num?)?.toDouble() ?? 0,
  );
}
