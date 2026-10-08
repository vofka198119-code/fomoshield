// One company's intended share of a fund — what it SHOULD be, as opposed to
// what it currently is. Stored server-side in fund_target_weights
// (Migration 034), two decimals.
//
// There is no zero: a target of nothing is the absence of a row, not a row
// saying nothing. Clearing a company's target deletes it.
class FundTargetWeight {
  final String symbol;
  final double targetPercent;

  const FundTargetWeight({required this.symbol, required this.targetPercent});

  factory FundTargetWeight.fromJson(Map<String, dynamic> json) =>
      FundTargetWeight(
        symbol: json['symbol'] as String,
        targetPercent: (json['targetPercent'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'targetPercent': targetPercent,
  };

  FundTargetWeight copyWith({double? targetPercent}) => FundTargetWeight(
    symbol: symbol,
    targetPercent: targetPercent ?? this.targetPercent,
  );
}
