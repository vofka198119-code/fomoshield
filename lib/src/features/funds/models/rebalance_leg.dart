// One line of a rebalance: a company, which way it moves, and how much.
//
// Frozen as planned when the proposal is filed — the price and the two shares
// are what the proposer was looking at, so an approver reads the same screen
// the proposer did. Execution re-prices at the market, the way any market
// order here does, and writes the realised price back into [executedPrice].
class RebalanceLeg {
  final String symbol;
  final String side; // 'buy' | 'sell'
  final double quantity;

  /// The price the plan was drawn at, not the price it was filled at.
  final double price;

  /// quantity × price, as planned.
  final double amount;

  /// The company's share of the fund's invested money, before and after —
  /// the same pair the impact card shows for a single trade.
  final double shareNow;
  final double shareAfter;

  /// Only present once the batch has run. [executed] false with a [error]
  /// code means this one line could not be filled while the others were.
  final bool? executed;
  final String? error;
  final double? executedPrice;
  final double? commission;

  const RebalanceLeg({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.shareNow,
    required this.shareAfter,
    this.executed,
    this.error,
    this.executedPrice,
    this.commission,
  });

  bool get isBuy => side == 'buy';

  /// True only for a leg that ran and failed — an unexecuted batch has no
  /// opinion about its legs yet.
  bool get didFail => executed == false;

  factory RebalanceLeg.fromJson(Map<String, dynamic> json) => RebalanceLeg(
    symbol: json['symbol'] as String,
    side: json['side'] as String,
    quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    shareNow: (json['shareNow'] as num?)?.toDouble() ?? 0,
    shareAfter: (json['shareAfter'] as num?)?.toDouble() ?? 0,
    executed: json['executed'] as bool?,
    error: json['error'] as String?,
    executedPrice: (json['executedPrice'] as num?)?.toDouble(),
    commission: (json['commission'] as num?)?.toDouble(),
  );
}

/// A company the head has left alone: still in the fund, still measured, just
/// not traded. Kept in the preview so its box can be ticked back on.
class UntouchedHolding {
  final String symbol;
  final double shareNow;
  final double targetPercent;

  const UntouchedHolding({
    required this.symbol,
    required this.shareNow,
    required this.targetPercent,
  });

  factory UntouchedHolding.fromJson(Map<String, dynamic> json) =>
      UntouchedHolding(
        symbol: json['symbol'] as String,
        shareNow: (json['shareNow'] as num?)?.toDouble() ?? 0,
        targetPercent: (json['targetPercent'] as num?)?.toDouble() ?? 0,
      );
}

/// The widest gap that will still be there once the batch has run. With every
/// company ticked it is rounding dust; with one left alone it is the price of
/// that choice, stated before anyone commits.
class RebalanceResidual {
  final String symbol;
  final double actual;
  final double target;
  final double gap;

  const RebalanceResidual({
    required this.symbol,
    required this.actual,
    required this.target,
    required this.gap,
  });

  factory RebalanceResidual.fromJson(Map<String, dynamic> json) =>
      RebalanceResidual(
        symbol: json['symbol'] as String,
        actual: (json['actual'] as num?)?.toDouble() ?? 0,
        target: (json['target'] as num?)?.toDouble() ?? 0,
        gap: (json['gap'] as num?)?.toDouble() ?? 0,
      );
}

/// What a rebalance preview comes back as — the plan, before anyone commits
/// to it.
class RebalancePlan {
  final String mode; // 'cash' | 'full'
  final List<RebalanceLeg> legs;
  final double invested;
  final double cash;

  /// Why there is nothing to do, when there is nothing to do:
  /// 'no_targets', 'missing_prices', or null when the plan is simply empty.
  final String? reason;

  /// Companies left out, each with a reason ('no_price', 'too_small').
  final List<({String symbol, String reason})> skipped;

  /// Companies the head unticked.
  final List<UntouchedHolding> untouched;

  /// What this batch will not fix.
  final RebalanceResidual? residual;

  const RebalancePlan({
    required this.mode,
    required this.legs,
    required this.invested,
    required this.cash,
    this.reason,
    this.skipped = const [],
    this.untouched = const [],
    this.residual,
  });

  bool get isEmpty => legs.isEmpty;

  double get sellTotal => legs
      .where((l) => !l.isBuy)
      .fold<double>(0, (sum, l) => sum + l.amount);

  double get buyTotal =>
      legs.where((l) => l.isBuy).fold<double>(0, (sum, l) => sum + l.amount);

  factory RebalancePlan.fromJson(Map<String, dynamic> json) => RebalancePlan(
    mode: json['mode'] as String? ?? 'full',
    legs: ((json['legs'] as List?) ?? const [])
        .map((e) => RebalanceLeg.fromJson(e as Map<String, dynamic>))
        .toList(),
    invested: (json['invested'] as num?)?.toDouble() ?? 0,
    cash: (json['cash'] as num?)?.toDouble() ?? 0,
    reason: json['reason'] as String?,
    untouched: ((json['untouched'] as List?) ?? const [])
        .map((e) => UntouchedHolding.fromJson(e as Map<String, dynamic>))
        .toList(),
    residual: json['residual'] == null
        ? null
        : RebalanceResidual.fromJson(
            (json['residual'] as Map).cast<String, dynamic>(),
          ),
    skipped: ((json['skipped'] as List?) ?? const [])
        .map(
          (e) => (
            symbol: (e as Map)['symbol'] as String? ?? '',
            reason: e['reason'] as String? ?? '',
          ),
        )
        .toList(),
  );
}
