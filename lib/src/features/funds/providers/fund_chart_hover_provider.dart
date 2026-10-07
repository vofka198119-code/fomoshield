import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/daily_snapshot_chart.dart';

/// The NAV point the user is currently holding on a fund's chart, with the
/// day before it, or null when nothing is held.
///
/// Lets the fund card's price header follow the scrub without the chart and
/// the header knowing about each other — the same arrangement Company Detail
/// already uses between PriceChart and PriceHeader via
/// `chartHoverPriceProvider`. Keyed by fund id for the same reason it is
/// keyed by symbol there: moving between funds must not leak a stale value
/// from the previous one.
///
/// Carries the previous day as well as the held point because a fund's
/// change badge is a day-over-day figure — the header would otherwise have
/// to re-derive it from a history it has already been handed in a different
/// shape.
final fundChartHoverProvider = StateProvider.autoDispose
    .family<({DailySnapshotPoint point, DailySnapshotPoint? previous})?, String>(
      (ref, fundId) => null,
    );
