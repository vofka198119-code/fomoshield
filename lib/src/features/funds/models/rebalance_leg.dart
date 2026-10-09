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

  const RebalancePlan({
    required this.mode,
    required this.legs,
    required this.invested,
    required this.cash,
    this.reason,
    this.skipped = const [],
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
