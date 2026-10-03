// ---------------------------------------------------------------------------
// Fund Succession Offer — Phase B of the bankruptcy spec. Raised by the
// backend's daily sweep (fundSuccessionService.js) once a fund's head has
// been away for INACTIVITY_DAYS; every ACTIVE team member of that fund sees
// it via GET /employees/me/succession-offers, but only a premium/admin one
// can actually accept (the backend rejects the rest with `not_eligible`) --
// so the client gates the button itself rather than surfacing that error.
//
// Accepting is NOT an immediate promotion: it enters the caller into the
// running, and the winner is decided at [deadline] by seniority in the fund.
// Nobody accepting by then auto-liquidates the fund via the Phase A engine.
// See fomoshield_etf_bankruptcy_flow_spec memory for the full rules.
// ---------------------------------------------------------------------------

class FundSuccessionOffer {
  final String id;
  final String fundId;
  final String? fundName;
  final String? fundTicker;
  final DateTime startedAt;
  final DateTime deadline;

  /// True once this user has already entered the running — the client shows
  /// "waiting on the deadline" instead of the Accept button.
  final bool alreadyAccepted;

  const FundSuccessionOffer({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.fundTicker,
    required this.startedAt,
    required this.deadline,
    required this.alreadyAccepted,
  });

  String get displayName => fundName ?? fundTicker ?? '';

  /// Whole days left before the winner is picked, floored at 0. Rounded UP
  /// so a deadline 30 minutes out still reads "1 day left" rather than "0" —
  /// the offer is genuinely still open at that point, and "0 days left" on a
  /// card that still takes a tap reads as already-expired. Computed in
  /// minutes on purpose: `inHours / 24` truncates to 0 for anything under an
  /// hour, so ceil() on it can never round that last stretch up to 1.
  int get daysLeft {
    final remaining = deadline.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return (remaining.inMinutes / (24 * 60)).ceil();
  }

  factory FundSuccessionOffer.fromJson(Map<String, dynamic> json) {
    return FundSuccessionOffer(
      id: json['id'] as String,
      fundId: json['fundId'] as String,
      fundName: json['fundName'] as String?,
      fundTicker: json['fundTicker'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      deadline: DateTime.parse(json['deadline'] as String),
      alreadyAccepted: json['alreadyAccepted'] as bool? ?? false,
    );
  }
}
