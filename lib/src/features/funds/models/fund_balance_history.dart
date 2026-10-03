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
  // Migration 025 -- null for a month with no snapshot yet OR a snapshot
  // written before this column existed (both read as "no data").
  final List<double?> cash;

  const FundBalanceHistory({
    required this.year,
    required this.balance,
    required this.navPerUnit,
    required this.cash,
  });

  factory FundBalanceHistory.fromJson(Map<String, dynamic> json) {
    List<double?> monthly(String key) => (json[key] as List<dynamic>)
        .map((e) => (e as num?)?.toDouble())
        .toList();
    return FundBalanceHistory(
      year: json['year'] as int,
      balance: monthly('balance'),
      navPerUnit: monthly('navPerUnit'),
      cash: monthly('cash'),
    );
  }

  /// Holdings-only slice of [balance] -- balance (AUM) is always cash +
  /// holdings value, so this is a pure derivative, not a separate backend
  /// field. Null wherever either side is missing data.
  List<double?> get invested {
    return [
      for (var i = 0; i < balance.length; i++)
        (balance[i] == null || cash[i] == null) ? null : balance[i]! - cash[i]!,
    ];
  }

  /// Peak-to-trough % decline from the running peak NAV per unit, measured
  /// within this response's own year window (not since the fund's
  /// inception -- the backend only ever returns one calendar year of
  /// snapshots at a time). A pure derivative of [navPerUnit], so no
  /// separate backend endpoint was needed for the Drawdown chart. Always
  /// <= 0; null for a month with no snapshot; 0 for the month(s) that set
  /// a new peak.
  List<double?> get drawdownPercent {
    double? peak;
    final result = <double?>[];
    for (final nav in navPerUnit) {
      if (nav == null) {
        result.add(null);
        continue;
      }
      peak = peak == null || nav > peak ? nav : peak;
      result.add(peak > 0 ? (nav - peak) / peak * 100 : 0);
    }
    return result;
  }
}
