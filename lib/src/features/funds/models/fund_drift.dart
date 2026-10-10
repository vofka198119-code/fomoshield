import 'fund.dart';
import 'fund_target_weight.dart';

// ---------------------------------------------------------------------------
// How far a fund's actual composition has wandered from its plan — the one
// computation behind the drift reading, kept out of the widget because the
// rebalance (phase 4) has to turn exactly these numbers into trade
// proposals. Two screens reading the same arithmetic cannot disagree.
//
// Both shares are percentages of the fund's INVESTED money — the sum of its
// holdings, cash excluded (his call, 2026-10-09). Targets add up to 100% of
// what is bought, so the actual they are compared against has to be measured
// the same way, or a fund sitting on cash would look permanently underweight
// everywhere.
// ---------------------------------------------------------------------------

/// One company's actual share against its intended one.
class FundDriftRow {
  final String symbol;
  final double actualPercent;
  final double targetPercent;

  const FundDriftRow({
    required this.symbol,
    required this.actualPercent,
    required this.targetPercent,
  });

  /// Positive: the fund holds MORE of this than the plan says — the excess
  /// is what a rebalance would sell. Negative: less, and that is what a
  /// rebalance would buy.
  double get gap => actualPercent - targetPercent;

  bool get isOverweight => gap > 0;
}

class FundDrift {
  /// Every company in either set, biggest gap first regardless of direction.
  final List<FundDriftRow> rows;

  /// Whether the fund has a plan at all. Without one there is no distance to
  /// measure — every holding would read as "above a target of zero", which
  /// is arithmetically true and completely useless to look at.
  final bool hasPlan;

  /// What counts as "off the plan" in the count below, in percentage points.
  final double threshold;

  const FundDrift({
    required this.rows,
    required this.threshold,
    required this.hasPlan,
  });

  /// A holding with no target counts as a target of zero, and a target for
  /// something the fund does not hold counts as an actual of zero — both are
  /// real drift, and both are what the editor already means by an absent
  /// row (see [FundTargetWeight]).
  factory FundDrift.from({
    required List<FundHolding> holdings,
    required List<FundTargetWeight> targets,
    double threshold = 1.0,
  }) {
    final totalValue = holdings.fold<double>(0, (sum, h) => sum + h.value);
    final actual = <String, double>{
      for (final h in holdings)
        h.symbol: totalValue > 0 ? h.value / totalValue * 100 : 0,
    };
    final planned = <String, double>{
      for (final t in targets) t.symbol: t.targetPercent,
    };

    final rows =
        <FundDriftRow>[
          for (final symbol in {...actual.keys, ...planned.keys})
            FundDriftRow(
              symbol: symbol,
              actualPercent: actual[symbol] ?? 0,
              targetPercent: planned[symbol] ?? 0,
            ),
        ]..sort((a, b) {
          final byGap = b.gap.abs().compareTo(a.gap.abs());
          // Ties alphabetically, so the list never reshuffles between rebuilds.
          return byGap != 0 ? byGap : a.symbol.compareTo(b.symbol);
        });

    return FundDrift(
      rows: rows,
      threshold: threshold,
      hasPlan: planned.isNotEmpty,
    );
  }

  /// Null when there is nothing to read: no plan, or a plan and an empty
  /// fund with nothing in either set.
  FundDriftRow? get largest => !hasPlan || rows.isEmpty ? null : rows.first;

  /// Rows worth naming. A gap of a few hundredths of a percent is the price
  /// of whole shares, not a decision anyone should act on.
  List<FundDriftRow> get offTarget =>
      rows.where((r) => r.gap.abs() >= threshold).toList();

  int get totalCount => rows.length;
}
