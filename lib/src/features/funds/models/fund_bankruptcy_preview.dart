// ---------------------------------------------------------------------------
// Fund Bankruptcy Preview — the liquidation payout plan computed WITHOUT
// writing anything (GET /funds/:id/bankruptcy-preview), so the 2-step
// confirm flow's explanation sheet can show real numbers before the head
// commits. Same math the real POST /funds/:id/bankruptcy run uses -- see
// fomoshield_etf_bankruptcy_flow_spec memory for the full formula.
// ---------------------------------------------------------------------------

class FundBankruptcyInvestorPayout {
  final String userId;
  final String? nickname;
  final double invested;
  final double amount;
  final double neustoika;

  const FundBankruptcyInvestorPayout({
    required this.userId,
    required this.nickname,
    required this.invested,
    required this.amount,
    required this.neustoika,
  });

  factory FundBankruptcyInvestorPayout.fromJson(Map<String, dynamic> json) {
    return FundBankruptcyInvestorPayout(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String?,
      invested: (json['invested'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      neustoika: (json['neustoika'] as num).toDouble(),
    );
  }
}

class FundBankruptcyPreview {
  final String fundId;
  final String fundName;
  final String fundTicker;
  final double holdingsValue;
  final double brokerCommission;
  final double cashAfterSale;
  final int employeeCount;
  final double employeePayoutEach;
  final bool solvent;
  final List<FundBankruptcyInvestorPayout> investorPayouts;

  const FundBankruptcyPreview({
    required this.fundId,
    required this.fundName,
    required this.fundTicker,
    required this.holdingsValue,
    required this.brokerCommission,
    required this.cashAfterSale,
    required this.employeeCount,
    required this.employeePayoutEach,
    required this.solvent,
    required this.investorPayouts,
  });

  double get totalEmployeePayout => employeeCount * employeePayoutEach;
  double get totalInvestorPayout =>
      investorPayouts.fold(0, (sum, p) => sum + p.amount);
  double get totalPayout => totalEmployeePayout + totalInvestorPayout;

  factory FundBankruptcyPreview.fromJson(Map<String, dynamic> json) {
    return FundBankruptcyPreview(
      fundId: json['fundId'] as String,
      fundName: json['fundName'] as String,
      fundTicker: json['fundTicker'] as String,
      holdingsValue: (json['holdingsValue'] as num).toDouble(),
      brokerCommission: (json['brokerCommission'] as num).toDouble(),
      cashAfterSale: (json['cashAfterSale'] as num).toDouble(),
      employeeCount: json['employeeCount'] as int,
      employeePayoutEach: (json['employeePayoutEach'] as num).toDouble(),
      solvent: json['solvent'] as bool,
      investorPayouts: (json['investorPayouts'] as List<dynamic>)
          .map(
            (e) => FundBankruptcyInvestorPayout.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}
