// ---------------------------------------------------------------------------
// FundVacancy — one hiring advert on the employee exchange (migration 036).
//
// A head posts it; every signed-in user sees it on the board. The fund fields
// below are filled only by the board endpoint, where a candidate is choosing
// between funds and the fund is most of what they are choosing between; a
// head listing their own adverts gets them as null and does not need them.
// ---------------------------------------------------------------------------

class FundVacancy {
  final String id;
  final String fundId;
  final String role;

  /// "Кого ищем", in the head's own words. Optional — a role and a fund is
  /// already an offer.
  final String? pitch;

  /// The discretionary budget the advert promises, or null if none is
  /// offered. Advertised, not granted: the head still sets the real limit on
  /// the team member after hiring.
  final double? offeredLimitAmount;

  final String status; // 'open' | 'paused' (migration 037)
  final DateTime createdAt;
  final DateTime? closedAt;

  final String? fundName;
  final String? fundTicker;
  final double? fundCash;
  final List<String>? fundSectors;
  final String? fundHeadNickname;
  final int? fundTeamSize;

  const FundVacancy({
    required this.id,
    required this.fundId,
    required this.role,
    this.pitch,
    this.offeredLimitAmount,
    required this.status,
    required this.createdAt,
    this.closedAt,
    this.fundName,
    this.fundTicker,
    this.fundCash,
    this.fundSectors,
    this.fundHeadNickname,
    this.fundTeamSize,
  });

  bool get isOpen => status == 'open';

  /// Anything that is not open is paused, rather than strictly 'paused'.
  /// There are only two states since migration 037, and asking the strict
  /// question let a leftover 'closed' row from the old schema read as paused
  /// in the status line while the button beside it still offered to pause
  /// it -- two tests for one fact, disagreeing on screen (2026-10-10).
  bool get isPaused => !isOpen;

  factory FundVacancy.fromJson(Map<String, dynamic> json) => FundVacancy(
    id: json['id'] as String,
    fundId: json['fundId'] as String,
    role: json['role'] as String,
    pitch: json['pitch'] as String?,
    offeredLimitAmount: (json['offeredLimitAmount'] as num?)?.toDouble(),
    status: json['status'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    closedAt: json['closedAt'] != null
        ? DateTime.parse(json['closedAt'] as String)
        : null,
    fundName: json['fundName'] as String?,
    fundTicker: json['fundTicker'] as String?,
    fundCash: (json['fundCash'] as num?)?.toDouble(),
    fundSectors: (json['fundSectors'] as List?)?.cast<String>(),
    fundHeadNickname: json['fundHeadNickname'] as String?,
    fundTeamSize: (json['fundTeamSize'] as num?)?.toInt(),
  );
}
